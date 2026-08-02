#include "types.h"
#include "terminal_output.h"
#include "malloc.h"
#include "extmalloc.h"
#include "fat16_dirent.h"
#include "fat16_odyexe.h"
#include "uart.h"
#include "keyboard.h"

/* Bespoke helpers specific to serrun -- see serrun_helpers.asm. (The
   UART/keyboard primitives above are plain BIOS externs now, dispatched
   through c_compiler/special_functions.py -- no local wrapper needed.) */
extern uint8_t size_to_segments(uint16_t size);
extern char *copy_arg_string(char *src);
extern void uart_rx_enable(void);
extern void uart_rx_disable(void);

/* BIOS direct-exec IPC fields -- see os/bios/80-run_system_ody.asm and
   os/README-bios-exec.md.  $exec_argc/$exec_argv_ptr are shared with the
   dirent-based chaining path. */
extern uint8_t exec_direct_pending;
extern uint16_t exec_direct_program_ptr;
extern uint16_t exec_direct_entry_ptr;
extern uint8_t exec_direct_flags;
extern uint8_t exec_argc;
extern uint16_t exec_argv_ptr;

#define ODY_FLAGS_MAIN 0x00
#define ODY_FLAGS_EXTD 0x01
#define ODY_FLAGS_EXTE 0x02
#define ODY_FLAGS_EXTDE 0x03

/* Approximate spin count for one rendezvous retry interval.  There is no
   RTC-based delay used here -- this is a coarse, tunable busy-wait, not a
   calibrated time value. */
#define RETRY_SPINS 10000

static uint8_t s_name_field[12];
static uint16_t s_size;
static uint8_t s_hdr_cache[4];
static uint16_t s_recv;
static uint8_t *s_buf;

static void send_token(char *tok, uint8_t len) {
    uint8_t i;
    i = 0;
    while (i < len) {
        uart_sendchar(tok[i]);
        i++;
    }
}

/* Returns 1 if 'q' (not a key-release) was seen this call. */
static uint8_t check_abort_key(void) {
    uint16_t kb;
    uint8_t ch;
    uint8_t flags;
    kb = kb_readbuf();
    ch = kb & 0x00FF;
    if (ch) {
        flags = kb >> 8;
        if (!(flags & KB_KEYFLAG_BREAK)) {
            if (ch == 'q') {
                return 1;
            }
        }
    }
    return 0;
}

/* Blocks until a byte arrives or 'q' is pressed.  Returns 1 on abort. */
static uint8_t read_byte_blocking(uint8_t *out) {
    while (1) {
        if (uart_bufsize()) {
            *out = uart_readbuf();
            return 0;
        }
        if (check_abort_key()) {
            return 1;
        }
    }
}

/* Waits up to 'spins' iterations for a byte.  Returns 1 if one arrived
   (stored in *out); sets *aborted and returns 0 if 'q' was pressed;
   returns 0 with *aborted left alone on a plain timeout. */
static uint8_t wait_byte_timeout(uint8_t *out, uint16_t spins, uint8_t *aborted) {
    uint16_t i;
    i = 0;
    while (i < spins) {
        if (uart_bufsize()) {
            *out = uart_readbuf();
            return 1;
        }
        if (check_abort_key()) {
            *aborted = 1;
            return 0;
        }
        i++;
    }
    return 0;
}

/* Rendezvous: repeatedly announce ourselves and wait for the PC to reply.
   Odyssey is the active side (it "connects out"); the PC side sits in a
   passive listen loop from the moment it starts, so this works whichever
   side the user starts first -- retries sent before the PC script opens
   the port are simply lost.  Returns 0 on success, 1 on abort. */
static uint8_t rendezvous(void) {
    uint8_t b;
    uint8_t c;
    uint8_t aborted;
    print("serrun: waiting for PC (press q to abort)...");
    while (1) {
	print("o");
        send_token("SERODY", 6);
        aborted = 0;
        if (wait_byte_timeout(&b, RETRY_SPINS, &aborted)) {
            if (b == 'O') {
                if (read_byte_blocking(&c)) {
		    print("\n");
                    return 1;
                }
                if (c == 'K') {
		    print("\n");
                    return 0;
                }
            }
        }
        if (aborted) {
	    print("\n");
            return 1;
        }
    }
}

/* Reads the 14-byte header: 12-byte 8.3 name field (8-byte space-padded
   name + 3-byte space-padded extension + 1 reserved byte) followed by a
   2-byte big-endian total size.  Returns 0 on success, 1 on abort. */
static uint8_t read_header(void) {
    uint8_t i;
    uint8_t hi;
    uint8_t lo;
    i = 0;
    while (i < 12) {
        if (read_byte_blocking(&s_name_field[i])) {
            return 1;
        }
        i++;
    }
    if (read_byte_blocking(&hi)) {
        return 1;
    }
    if (read_byte_blocking(&lo)) {
        return 1;
    }
    s_size = hi;
    s_size = s_size << 8;
    s_size = s_size | lo;
    return 0;
}

/* Builds a "NAME.EXT" display/argv string from the 8.3 name field,
   reusing the FAT16 library's own name formatter instead of
   reimplementing space-trimming and dot-insertion.  fat16_dirent_filename
   only reads the first 11 bytes (filename[8] + extension[3]) at the given
   address, so reinterpreting s_name_field in place is sufficient -- no
   need to populate the rest of the struct. */
static char *build_name_string(void) {
    struct fat16_dirent *d;
    d = (struct fat16_dirent *)s_name_field;
    return fat16_dirent_filename(d);
}

/* Caches the first 4 payload bytes, validates the ODY magic, and
   allocates the real buffer based on the flags byte and the already-known
   total size -- same allocation dispatch as .exec_alloc_main/_d/_e/_de in
   os/bios/80-run_system_ody.asm, just sourcing the size from the wire
   header instead of a FAT16 dirent.  Returns 0 on success, 1 on abort, 2
   if the payload does not start with a valid ODY header. */
static uint8_t alloc_buffer(void) {
    uint8_t i;
    uint8_t flags;
    uint8_t segs;
    uint8_t page;

    i = 0;
    while (i < 4) {
        if (read_byte_blocking(&s_hdr_cache[i])) {
            return 1;
        }
        i++;
    }
    s_recv = 4;

    flags = fat16_inspect_ody(s_hdr_cache);
    if (flags == 0xFF) {
        return 2;
    }
    flags = flags & 0x03;
    exec_direct_flags = flags;

    if (flags == ODY_FLAGS_MAIN) {
        segs = size_to_segments(s_size);
        s_buf = malloc_segments(segs);
        exec_direct_program_ptr = (uint16_t)s_buf;
    } else if (flags == ODY_FLAGS_EXTD) {
        page = extmalloc();
        extpage_d_push(page);
        s_buf = (uint8_t *)0xD000;
        exec_direct_program_ptr = 0;
    } else if (flags == ODY_FLAGS_EXTE) {
        page = extmalloc();
        extpage_e_push(page);
        s_buf = (uint8_t *)0xE000;
        exec_direct_program_ptr = 0;
    } else {
        page = extmalloc();
        extpage_d_push(page);
        page = extmalloc();
        extpage_e_push(page);
        s_buf = (uint8_t *)0xD000;
        exec_direct_program_ptr = 0;
    }

    i = 0;
    while (i < 4) {
        s_buf[i] = s_hdr_cache[i];
        i++;
    }
    return 0;
}

/* Streams the remaining bytes directly into the allocated buffer, showing
   a print-over-itself "bytes received / total" progress line.  Returns 0
   on success, 1 on abort. */
static uint8_t receive_payload(void) {
    while (s_recv < s_size) {
        if (read_byte_blocking(&s_buf[s_recv])) {
            return 1;
        }
        s_recv++;
        if (!(s_recv & 0x3F)) {
            printf("Receiving: %U / %U bytes\r", s_recv, s_size);
        }
    }
    printf("Receiving: %U / %U bytes\r\n", s_recv, s_size);
    return 0;
}

int main(int argc, char **argv) {
    uint8_t result;
    char *name;
    uint16_t entry;
    uint8_t new_argc;
    uint16_t array_bytes;
    uint8_t array_blocks;
    char **new_argv;
    uint8_t i;

    print("serrun - receive and run an ODY binary over serial\n");

    /* The BIOS boot default discards every received UART byte without
       buffering it (see uart_rx_enable's doc comment) -- must install the
       buffering IRQ5 handler before waiting for anything from the PC. */
    uart_rx_enable();

    if (rendezvous()) {
        print("Aborted.\n");
        uart_rx_disable();
        return 1;
    }
    print("Connected; reading header...\n");

    if (read_header()) {
        print("Aborted.\n");
        uart_rx_disable();
        return 1;
    }

    if (s_size < 4) {
        print("Error: invalid size in header\n");
        send_token("FAIL", 4);
        uart_rx_disable();
        return 1;
    }

    name = build_name_string();
    printf("Receiving %s...\n", name, s_size);

    result = alloc_buffer();
    if (result == 1) {
        print("Aborted.\n");
        uart_rx_disable();
        return 1;
    }
    if (result == 2) {
        print("Error: not a valid ODY executable\n");
        send_token("FAIL", 4);
        uart_rx_disable();
        return 1;
    }

    if (receive_payload()) {
        print("Aborted.\n");
        uart_rx_disable();
        return 1;
    }

    send_token("DONE", 4);

    entry = fat16_localize_ody(s_buf);

    /* Build argv for the launched program: argv[0] = the name we just
       received, argv[1..] = copies of our own argv[1..].  Our own argv
       strings are BIOS-owned and freed as soon as we return below, before
       the launched program ever runs, so they must be duplicated here --
       not shared -- or the launched program would see dangling
       pointers. */
    new_argc = argc;
    if (new_argc < 1) {
        new_argc = 1;
    }
    array_bytes = (new_argc + 1) << 1;
    array_blocks = (array_bytes + 15) >> 4;
    new_argv = (char **)malloc_blocks(array_blocks);

    new_argv[0] = name;
    i = 1;
    while (i < new_argc) {
        new_argv[i] = copy_arg_string(argv[i]);
        i++;
    }
    new_argv[new_argc] = NULL;

    print("Running...\n");

    uart_rx_disable();

    exec_direct_entry_ptr = entry;
    exec_argc = new_argc;
    exec_argv_ptr = (uint16_t)new_argv;
    exec_direct_pending = 1;

    return 0;
}
