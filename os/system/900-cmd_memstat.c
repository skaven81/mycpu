// Wire Wrap Odyssey -- memstat: display malloc and extended memory allocation state

#include "types.h"
#include "terminal_output.h"
#include "extmalloc.h"

// BIOS global variables -- accessed directly via $variable name mapping
extern uint16_t malloc_range_start;
extern uint8_t  malloc_segments;
extern uint16_t exec_loop_program_ptr;
extern uint8_t  extmalloc_ledger;
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
static uint16_t s_alloc_pos;
static uint16_t s_alloc_remaining;
static uint16_t s_segs16;
static uint16_t s_b16;
static uint8_t  s_num_segs;
static uint8_t  s_b;
static uint8_t  s_in_alloc;
static uint8_t  s_is_sysody;
static uint8_t  s_is_blk;
static uint8_t  s_is_last;
static uint8_t  s_cur_color;
static uint8_t  s_last_color;
static uint8_t  s_ch;
static char    *s_dwin;

// File-scope statics for memstat_show_ext_ram.
static uint8_t  *se_ext_ledger;
static uint16_t se_page;
static uint16_t se_cnt16;
static uint8_t  se_byte_idx;
static uint8_t  se_bit_mask;
static uint8_t  se_allocated;
static uint8_t  se_alloc_count;
static uint8_t  se_ext_free;
static uint8_t  se_cur_color;
static uint8_t  se_last_color;
static uint8_t  se_ch;
static uint16_t se_alloc_kib;
static uint16_t se_free_kib;

static void memstat_show_main_ram(void) {
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

    // Determine SYSTEM.ODY ledger range for yellow highlighting
    s_sysody_ls    = 0;
    s_sysody_le    = 0;
    s_sysody_bytes = 0;
    if (s_sysody_addr != 0 &&
        s_sysody_addr >= s_range_start &&
        s_sysody_addr < s_range_start + s_total_bytes) {
        s_sysody_ls = (s_sysody_addr - s_range_start) >> 4;
        s_b = (uint8_t)s_dwin[s_sysody_ls];
        if (s_b >= 1 && s_b <= 0xEF) {
            s_b16 = s_b;
            s_b16 = s_b16 & 0x00FF;
            s_sysody_bytes = s_b16 << 7;
            s_sysody_le    = s_b16 << 3;
            s_sysody_le    = s_sysody_ls + s_sysody_le - (uint16_t)1;
        }
    }

    printf("@37Main RAM@r @17base:@36 0x%X @17segs:@36 %u @17total:@36 %U@17 B (1 char=16B)@r\n",
           s_range_start, s_num_segs, s_total_bytes);

    s_in_alloc        = 0;
    s_alloc_total     = 0;
    s_alloc_pos       = 0;
    s_alloc_remaining = 0;
    s_free_bytes      = 0;
    s_alloc_count     = 0;
    s_max_free        = 0;
    s_cur_free        = 0;
    s_last_color      = 255;

    for (s_i = 0; s_i < s_ledger_count; s_i++) {
        s_b = (uint8_t)s_dwin[s_i];
        s_is_sysody = (s_sysody_addr != 0 && s_i >= s_sysody_ls && s_i <= s_sysody_le);

        if (s_b == 0x00) {
            s_ch        = 0xB0;
            s_cur_color = 0;
            s_in_alloc  = 0;
            s_alloc_pos = 0;
            s_free_bytes = s_free_bytes + 16;
            s_cur_free   = s_cur_free   + 16;

        } else if (s_b != 0xFF) {
            s_is_blk = (s_b >= 0xF1);
            if (s_is_blk) {
                s_alloc_total = s_b & 0x0F;
                s_alloc_total = s_alloc_total & 0x00FF;
            } else {
                s_b16 = s_b;
                s_b16 = s_b16 & 0x00FF;
                s_alloc_total = s_b16 << 3;
            }
            s_alloc_pos       = 0;
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

            if (s_alloc_total == (uint16_t)1) {
                s_ch = 0x07;
            } else {
                s_ch = '[';
            }

            if (s_cur_free > s_max_free) s_max_free = s_cur_free;
            s_cur_free = 0;
            s_alloc_count = s_alloc_count + (uint16_t)1;

        } else {
            s_alloc_pos = s_alloc_pos + (uint16_t)1;
            s_is_last   = (s_alloc_remaining == (uint16_t)1);

            if (s_is_last) {
                s_ch = ']';
                if (s_is_sysody) {
                    s_cur_color = 5;
                } else if (s_in_alloc == 2) {
                    s_cur_color = 3;
                } else {
                    s_cur_color = 1;
                }
            } else {
                if (s_is_sysody) {
                    s_ch        = 0xF9;
                    s_cur_color = 6;
                } else if (s_in_alloc == 2) {
                    s_ch        = 0xB1;
                    s_cur_color = 4;
                } else {
                    s_ch        = 0xB2;
                    s_cur_color = 2;
                }
            }

            s_alloc_remaining = s_alloc_remaining - (uint16_t)1;
        }

        if (s_cur_color != s_last_color) {
            if      (s_cur_color == 0) print("@31");
            else if (s_cur_color == 1) print("@37");
            else if (s_cur_color == 2) print("@33");
            else if (s_cur_color == 3) print("@35");
            else if (s_cur_color == 4) print("@25");
            else if (s_cur_color == 5) print("@36");
            else                       print("@26");
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
    if (s_sysody_addr != 0 && s_sysody_bytes != 0) {
        printf("   @36SYSTEM.ODY: %U@17 B (reclaim)@r", s_sysody_bytes);
    }
    print("@r\n");
}

static void memstat_show_ext_ram(void) {
    se_ext_ledger = &extmalloc_ledger;

    memstat_sep_d();
    print("@37Extended RAM@r 256 pages x 4 KiB = 1024 KiB @17(1 char=1 page)@r\n");

    se_alloc_count = 0;
    se_last_color  = 255;
    se_bit_mask    = 0x80;

    for (se_page = 0; se_page < 256; se_page++) {
        se_byte_idx  = (uint8_t)(se_page >> 3);
        se_allocated = se_ext_ledger[se_byte_idx] & se_bit_mask;

        if (se_page == 0) {
            se_cur_color = 2;
            se_ch        = 0xB2;
        } else if (se_allocated) {
            se_cur_color = 1;
            se_ch        = 0xDB;
            se_alloc_count = se_alloc_count + 1;
        } else {
            se_cur_color = 0;
            se_ch        = 0xB0;
        }

        if (se_cur_color != se_last_color) {
            if      (se_cur_color == 0) print("@31");
            else if (se_cur_color == 1) print("@35");
            else                        print("@34");
            se_last_color = se_cur_color;
        }
        emit_ch(se_ch);

        se_bit_mask = se_bit_mask >> 1;
        if (se_bit_mask == 0) se_bit_mask = 0x80;
    }
    print("@r\n");

    se_ext_free = 255 - se_alloc_count;
    se_cnt16 = se_alloc_count;
    se_cnt16 = se_cnt16 & 0x00FF;
    se_alloc_kib = se_cnt16 << 2;
    se_cnt16 = se_ext_free;
    se_cnt16 = se_cnt16 & 0x00FF;
    se_free_kib  = se_cnt16 << 2;
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
