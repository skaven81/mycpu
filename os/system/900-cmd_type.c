#include "types.h"
#include "terminal_output.h"
#include "malloc.h"
#include "fat16_util.h"
#include "fat16_dirent.h"
#include "fat16_pathfind.h"
#include "fat16_readfile.h"
#include "extmalloc.h"
#include "shell_argv.h"

static void print_file(struct fat16_dirent *entry, struct fs_handle *h);
static void print_bytes(uint16_t addr, uint16_t count);

// Entry point called by the shell dispatch loop.
void cmd_type(void) {
    uint16_t entry_raw;
    char *path = shell_get_argv_n(1);
    if (path == 0) {
        print("Usage: type PATH\n");
        return;
    }

    struct fs_handle *h;
    struct fat16_dirent *entry = fat16_pathfind(path, &h);

    // Valid dirent pointers have high byte >= 0x40 (RAM at 0x6000+).
    // Error codes: 0x0000 = not found, 0x0001 = bad path, 0x01xx = ATA error.
    entry_raw = (uint16_t)entry;
    if (entry_raw == 0) {
        print("File not found\n");
        return;
    }
    if ((entry_raw >> 8) < 0x40) {
        if (entry_raw == 1) {
            print("Error: unparseable path spec\n");
        } else {
            printf("ATA error: %x\n", (uint8_t)(entry_raw & 0x00ff));
        }
        return;
    }

    // Check if it is a directory
    if (fat16_dirent_attribute(entry) & 0x10) {
        free(entry);
        print("Path is a directory, not a file\n");
        return;
    }

    print_file(entry, h);
    free(entry);
}

// Print file contents using a 4 KiB extended-memory buffer.
static void print_file(struct fat16_dirent *entry, struct fs_handle *h) {
    uint16_t size_hi;
    uint16_t size_lo;
    struct fat16_readfile_ctx *ctx;
    uint8_t page;
    uint16_t remaining;
    uint16_t to_print;
    uint8_t status;
    char *d_buf;

    // Get true file size (low word; high word ignored for files < 64 KiB)
    size_lo = fat16_dirent_filesize(entry, &size_hi);

    // Allocate streaming context (1 block = 16 bytes, pre-zeroed so flags = 0)
    ctx = (struct fat16_readfile_ctx *)calloc_blocks(1);
    if (ctx == 0) {
        print("Out of memory\n");
        return;
    }

    // Allocate a 4 KiB extended memory page for the read buffer
    page = extmalloc();
    if (page == 0) {
        free(ctx);
        print("Out of ext memory\n");
        return;
    }

    // Map page into D-window (0xD000-0xDFFF)
    extpage_d_push(page);
    d_buf = (char *)0xD000;

    // Streaming read loop: 8 sectors (4096 bytes) per iteration
    remaining = size_lo;
    while (1) {
        status = fat16_readfile(ctx, entry, 8, d_buf, h);
        if (status != 0) {
            printf("ATA error: %x\n", status);
            break;
        }

        // Print only up to remaining bytes to avoid garbage after EOF
        if (remaining > 4096) {
            to_print = 4096;
        } else {
            to_print = remaining;
        }
        print_bytes(0xD000, to_print);
        remaining = remaining - to_print;

        if ((ctx->flags & 0x02) || remaining == 0) {
            break;
        }
    }

    // Tear down in reverse order
    extpage_d_pop();
    extfree(page);
    free(ctx);
}

// Print count bytes starting at RAM address addr.
static void print_bytes(uint16_t addr, uint16_t count) {
    uint16_t i;
    char *p = (char *)addr;
    for (i = 0; i < count; i++) {
        putchar(p[i]);
    }
}
