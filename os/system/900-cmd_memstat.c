// Wire Wrap Odyssey -- memstat: display malloc and extended memory allocation state

#include "types.h"
#include "terminal_output.h"
#include "extmalloc.h"

// BIOS global variables -- accessed directly via $variable name mapping
extern uint16_t malloc_range_start;
extern uint8_t  malloc_segments;
extern uint16_t exec_loop_program_ptr;
extern uint8_t  extmalloc_ledger[32];  // 32-byte bitmap: 1 bit per page
extern uint8_t  term_color_enabled;
extern uint8_t  term_current_color;  // current color byte (set by print @XX codes)
extern uint16_t crsr_addr_color;     // address of cursor in color framebuffer

// Assembly helpers (defined in 900a-cmd_memstat_helpers.asm)
// emit_ch: heap_push_AL(c) then CALL; callee retreats 1 byte. Writes
//          the character and then writes term_current_color to color memory.
extern void emit_ch(uint8_t c);
extern void memstat_sep_d(void);
extern void memstat_sep_s(void);

// File-scope statics for memstat_show_main_ram.
// These are file-scope so the C compiler can use direct (non-frame) addressing,
// which is much cheaper than heap-frame offset arithmetic for deeply-nested locals.
// Safe because these functions are never called recursively.
static uint16_t s_range_start;
static uint16_t s_total_bytes;
static uint16_t s_ledger_count;
static uint16_t s_sysody_addr;
static uint16_t s_sysody_ls;
static uint16_t s_sysody_le;
static uint16_t s_sysody_bytes;
static uint16_t s_free_bytes;
static uint16_t s_used_bytes;
static uint16_t s_alloc_count;
static uint16_t s_max_free;
static uint16_t s_cur_free;
static uint16_t s_i;
static uint16_t s_alloc_total;
static uint16_t s_alloc_remaining;
static uint16_t s_segs16;
static uint16_t s_b16;
static uint16_t s_col_off;
static uint8_t  s_num_segs;
static uint8_t  s_b;
static uint8_t  s_in_alloc;
static uint8_t  s_is_sysody;
static uint8_t  s_is_blk;
static uint8_t  s_cur_color;
static uint8_t  s_last_color;
static uint8_t  s_ch;
static char    *s_dwin;

// File-scope statics for memstat_show_ext_ram.
static uint8_t  se_page;        // uint8_t: natural 8-bit wrap drives the loop exit
static uint8_t  se_bit_mask;
static uint8_t  se_alloc_count;
static uint8_t  se_ext_free;
static uint8_t  se_cur_color;
static uint8_t  se_last_color;
static uint8_t  se_ch;
static uint16_t se_alloc_kib;
static uint16_t se_free_kib;

static void memstat_show_main_ram(void) {
    // Color escape table: 7 entries of "@XX\0" (4 bytes each), indexed 0-6.
    // 0=free, 1=seg-struct, 2=seg-fill, 3=blk-struct, 4=blk-fill,
    // 5=sysody-struct, 6=sysody-fill.
    static char s_col_strs[28] = {
        '@','3','1',0,
        '@','3','7',0,
        '@','3','3',0,
        '@','3','5',0,
        '@','2','5',0,
        '@','3','6',0,
        '@','2','6',0
    };
    // Read BIOS globals
    s_range_start = malloc_range_start;
    s_num_segs    = malloc_segments;
    s_sysody_addr = exec_loop_program_ptr;

    // Compute total_bytes = num_segs * 128 and ledger_count = num_segs * 8
    // Mask after widening: uint8_t -> uint16_t assignment leaves AH garbage
    s_segs16 = s_num_segs;
    s_segs16 = s_segs16 & 0x00FF;
    s_total_bytes  = s_segs16 << 7;
    s_ledger_count = s_segs16 << 3;

    // Map extended memory page 0 (the malloc ledger) into the D-window
    extpage_d_push(0);
    s_dwin = (char *)0xD000;

    // Determine SYSTEM.ODY ledger range for yellow highlighting.
    // s_sysody_ls=0xFFFF sentinel: ensures s_i >= s_sysody_ls is always
    // false in the loop when sysody is not loaded (avoids needing an
    // explicit s_sysody_addr != 0 guard in the per-iteration check).
    s_sysody_ls    = 0xFFFF;
    s_sysody_le    = 0;
    s_sysody_bytes = 0;
    if (s_sysody_addr >= s_range_start) {
        if (s_sysody_addr < s_range_start + s_total_bytes) {
            s_sysody_ls = (s_sysody_addr - s_range_start) >> 4;
            s_b = (uint8_t)s_dwin[s_sysody_ls];
            if (s_b) {               // >= 1 (non-zero = truthy)
                if (s_b <= 0xEF) {   // valid segment alloc header range
                    s_b16 = s_b;
                    s_b16 = s_b16 & 0x00FF;
                    s_sysody_bytes = s_b16 << 7;
                    s_sysody_le    = s_b16 << 3;
                    s_sysody_le    = s_sysody_ls + s_sysody_le - (uint16_t)1;
                }
            }
        }
    }

    printf("@37Main RAM@r @17base:@36 0x%X @17segs:@36 %u @17total:@36 %U@17 B (1 char=16B)@r\n",
           s_range_start, s_num_segs, s_total_bytes);

    s_in_alloc        = 0;
    s_alloc_total     = 0;
    s_alloc_remaining = 0;
    s_free_bytes      = 0;
    s_alloc_count     = 0;
    s_max_free        = 0;
    s_cur_free        = 0;
    s_last_color      = 255;

    for (s_i = 0; s_i < s_ledger_count; s_i++) {
        s_b = (uint8_t)s_dwin[s_i];
        s_is_sysody = 0;
        if (s_i >= s_sysody_ls) {
            if (s_i <= s_sysody_le) {
                s_is_sysody = 1;
            }
        }

        if (!s_b) {
            s_ch        = 0xB0;
            s_cur_color = 0;
            s_in_alloc  = 0;
            s_free_bytes = s_free_bytes + 16;
            s_cur_free   = s_cur_free   + 16;

        } else if (s_b ^ 0xFF) {
            s_is_blk = (s_b >= 0xF1);
            if (s_is_blk) {
                s_alloc_total = s_b & 0x0F;
                s_alloc_total = s_alloc_total & 0x00FF;
            } else {
                s_b16 = s_b;
                s_b16 = s_b16 & 0x00FF;
                s_alloc_total = s_b16 << 3;
            }
            s_alloc_remaining = s_alloc_total - (uint16_t)1;

            if (s_is_sysody) {
                s_in_alloc  = 3;
                s_cur_color = 5;
            } else if (s_is_blk) {
                s_in_alloc  = 2;
                s_cur_color = 3;
            } else {
                s_in_alloc  = 1;
                s_cur_color = 1;
            }

            // s_alloc_remaining > 0 means multi-byte alloc (open bracket),
            // s_alloc_remaining == 0 means single-byte alloc (bullet).
            if (s_alloc_remaining) {
                s_ch = '[';
            } else {
                s_ch = 0x07;
            }

            if (s_cur_free > s_max_free) s_max_free = s_cur_free;
            s_cur_free = 0;
            s_alloc_count = s_alloc_count + (uint16_t)1;

        } else {
            // Decrement first, then test for zero = "was the last byte".
            s_alloc_remaining = s_alloc_remaining - (uint16_t)1;

            if (s_alloc_remaining) {   // still bytes remaining after this one
                if (s_is_sysody) {
                    s_ch        = 0xF9;
                    s_cur_color = 6;
                } else if (s_is_blk) {
                    s_ch        = 0xB1;
                    s_cur_color = 4;
                } else {
                    s_ch        = 0xB2;
                    s_cur_color = 2;
                }
            } else {                   // remaining == 0: this is the last byte
                s_ch = ']';
                if (s_is_sysody) {
                    s_cur_color = 5;
                } else if (s_is_blk) {
                    s_cur_color = 3;
                } else {
                    s_cur_color = 1;
                }
            }
        }

        if (s_cur_color ^ s_last_color) {
            s_col_off = s_cur_color;
            s_col_off = s_col_off & 0x00FF;
            s_col_off = s_col_off << 2;
            printf("%s", &s_col_strs[s_col_off]);
            s_last_color = s_cur_color;
        }
        emit_ch(s_ch);
    }
    print("@r\n");
    extpage_d_pop();
    if (s_cur_free > s_max_free) s_max_free = s_cur_free;

    s_used_bytes = s_total_bytes - s_free_bytes;
    memstat_sep_s();
    printf("@17Used:@36 %U@17 B  Free:@36 %U@17 B  Total:@36 %U@17 B  Allocs:@36 %U@r\n",
           s_used_bytes, s_free_bytes, s_total_bytes, s_alloc_count);
    printf("@17Largest free:@36 %U@17 B", s_max_free);
    if (s_sysody_bytes) {
        printf("   @36SYSTEM.ODY: %U@17 B (reclaim)@r", s_sysody_bytes);
    }
    print("@r\n");
}

static void memstat_show_ext_ram(void) {
    memstat_sep_d();
    print("@37Extended RAM@r 256 pages x 4 KiB = 1024 KiB @17(1 char=1 page)@r\n");

    se_alloc_count = 0;

    // Page 0 is always the zero-page scratch page (not allocatable).
    // Handle it explicitly to avoid a per-iteration branch in the main loop.
    print("@34");
    emit_ch(0xB2);
    se_last_color = 2;
    se_bit_mask   = 0x40;   // page 1's bit (already past page 0)

    // Loop pages 1-255.  se_page is uint8_t: after se_page++ from 255, it
    // wraps to 0 and the truthiness test "while (se_page)" exits naturally.
    se_page = 1;
    do {
        if (extmalloc_ledger[se_page >> 3] & se_bit_mask) {
            se_cur_color = 1;
            se_ch        = 0xDB;
            se_alloc_count = se_alloc_count + 1;
        } else {
            se_cur_color = 0;
            se_ch        = 0xB0;
        }

        if (se_cur_color ^ se_last_color) {
            if (se_cur_color) print("@35");
            else              print("@31");
            se_last_color = se_cur_color;
        }
        emit_ch(se_ch);

        se_bit_mask = se_bit_mask >> 1;
        if (!se_bit_mask) se_bit_mask = 0x80;
        se_page++;
    } while (se_page);

    print("@r\n");

    // KiB values: zero-extend uint8_t count to uint16_t, mask garbage high
    // byte, then shift left by 2 (multiply by 4).
    se_ext_free  = 255 - se_alloc_count;
    se_alloc_kib = se_alloc_count;
    se_alloc_kib = se_alloc_kib & 0x00FF;
    se_alloc_kib = se_alloc_kib << 2;
    se_free_kib  = se_ext_free;
    se_free_kib  = se_free_kib & 0x00FF;
    se_free_kib  = se_free_kib << 2;
    memstat_sep_s();
    printf("@17Alloc:@36 %u@17 pg (%U@17 KiB)  Free:@36 %u@17 pg (%U@17 KiB)  Zero-pg:@34 1@r\n",
           se_alloc_count, se_alloc_kib, se_ext_free, se_free_kib);
}

static void memstat_show_legend(void) {
    memstat_sep_d();
    print("@37Legend (main):@r  ");
    print("@37"); emit_ch('['); print("@33"); emit_ch(0xB2); print("@37"); emit_ch(']'); print("@r=seg  ");
    print("@35"); emit_ch('['); print("@25"); emit_ch(0xB1); print("@35"); emit_ch(']'); print("@r=blk  ");
    print("@35"); emit_ch(0x07); print("@r=1blk  ");
    print("@36"); emit_ch(0xF9); print("@r=sys  ");
    print("@31"); emit_ch(0xB0); print("@r=free\n");
    print("@37Legend (ext):@r   ");
    print("@35"); emit_ch(0xDB); print("@r=ext-alloc  ");
    print("@34"); emit_ch(0xB2); print("@r=zero-pg  ");
    print("@31"); emit_ch(0xB0); print("@r=free\n");
}

void cmd_memstat(void) {
    term_color_enabled = 1;
    memstat_sep_d();
    print("@37     Wire Wrap Odyssey -- Memory Status@r\n");
    memstat_sep_d();
    memstat_show_main_ram();
    memstat_show_ext_ram();
    memstat_show_legend();
    memstat_sep_d();
    term_color_enabled = 0;
}
