# vim: syntax=asm-mycpu

# Tests for 30-t_termout.asm (TERMINAL_REFACTOR.md 2.2, 2.3.1).

:tests_output_run
LDI_C .suite_name
CALL :tt_suite

ST :t_term_flags 0x00
ST :t_term_render_color 0x00

# --- basic putchar: write + advance, flags=0x00, render_color=0 ---
CALL :t_cursor_init
ST %display_chars% 0x00
LDI_AL 'A'
CALL :t_putchar
LD_AL %display_chars%
LDI_AH 'A'
LDI_C .tn_putchar_char
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_putchar_row
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL :t_crsr_col
LDI_C .tn_putchar_col
CALL :tt_assert_eq

# --- render_color writes the color byte alongside the char ---
CALL :t_cursor_init
LDI_AH 0x01
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
ST %display_color%+64 0x00
ST :t_term_render_color 0x01
ST :t_term_current_color 0x2a
LDI_AL 'Z'
CALL :t_putchar
LD_AL %display_color%+64
LDI_AH 0x2a
LDI_C .tn_color_written
CALL :tt_assert_eq
ST :t_term_render_color 0x00

# --- putchar_raw: no ctrl-char handling, just writes + advances ---
CALL :t_cursor_init
LDI_AH 0x02
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
ST %display_chars%+128 0x00
LDI_AL 0x0a
CALL :t_putchar_raw
LD_AL %display_chars%+128
LDI_AH 0x0a
LDI_C .tn_raw_char
CALL :tt_assert_eq
LDI_AH 0x02
LD_AL :t_crsr_row
LDI_C .tn_raw_row
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL :t_crsr_col
LDI_C .tn_raw_col
CALL :tt_assert_eq

# --- CR: col 0, same row ---
CALL :t_cursor_init
LDI_AH 0x03
LDI_AL 0x05
CALL :t_cursor_goto_rowcol
LDI_AL 0x0d
CALL :t_putchar
LDI_AH 0x03
LD_AL :t_crsr_row
LDI_C .tn_cr_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_cr_col
CALL :tt_assert_eq

# --- LF: next row, col 0 ---
CALL :t_cursor_init
LDI_AH 0x04
LDI_AL 0x05
CALL :t_cursor_goto_rowcol
LDI_AL 0x0a
CALL :t_putchar
LDI_AH 0x05
LD_AL :t_crsr_row
LDI_C .tn_lf_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_lf_col
CALL :tt_assert_eq

# --- Backspace: shifts chars+colors left in lockstep, cursor moves left ---
ST %display_chars%+384 'A'
ST %display_chars%+385 'B'
ST %display_chars%+386 0x00
ST %display_color%+384 0x01
ST %display_color%+385 0x02
ST %display_color%+386 0x03
LDI_AH 0x06
LDI_AL 0x02
CALL :t_cursor_goto_rowcol
LDI_AL 0x08
CALL :t_putchar
LD_AL %display_chars%+384
LDI_AH 'A'
LDI_C .tn_bs_char384
CALL :tt_assert_eq
LD_AL %display_chars%+385
LDI_AH 0x00
LDI_C .tn_bs_char385
CALL :tt_assert_eq
LD_AL %display_color%+385
LDI_AH 0x03
LDI_C .tn_bs_color385
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL :t_crsr_col
LDI_C .tn_bs_col
CALL :tt_assert_eq

# --- Delete: shifts chars+colors left, cursor stays in place ---
ST %display_chars%+448 'X'
ST %display_chars%+449 'Y'
ST %display_chars%+450 0x00
ST %display_color%+448 0x01
ST %display_color%+449 0x02
ST %display_color%+450 0x03
LDI_AH 0x07
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_AL 0x7f
CALL :t_putchar
LD_AL %display_chars%+448
LDI_AH 'Y'
LDI_C .tn_del_char448
CALL :tt_assert_eq
LD_AL %display_color%+448
LDI_AH 0x02
LDI_C .tn_del_color448
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_del_col
CALL :tt_assert_eq

# --- right-edge behavior matrix (2.2.1 bits 2-3), from (10,63) ---

# (0,0) default: wrap col0 + next row
CALL :t_cursor_init
LDI_AH 0x0a
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x00
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x0b
LD_AL :t_crsr_row
LDI_C .tn_edge00_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_edge00_col
CALL :tt_assert_eq

# (0,1) TERM_NONEWLINE_R: wrap col0, same row
CALL :t_cursor_init
LDI_AH 0x0a
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x08
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x0a
LD_AL :t_crsr_row
LDI_C .tn_edge01_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_edge01_col
CALL :tt_assert_eq

# (1,0) TERM_NOWRAP_R: stay col 63, next row
CALL :t_cursor_init
LDI_AH 0x0a
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x04
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x0b
LD_AL :t_crsr_row
LDI_C .tn_edge10_row
CALL :tt_assert_eq
LDI_AH 0x3f
LD_AL :t_crsr_col
LDI_C .tn_edge10_col
CALL :tt_assert_eq

# (1,1) TERM_NOWRAP_R|TERM_NONEWLINE_R: stay col 63, same row
CALL :t_cursor_init
LDI_AH 0x0a
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x0c
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x0a
LD_AL :t_crsr_row
LDI_C .tn_edge11_row
CALL :tt_assert_eq
LDI_AH 0x3f
LD_AL :t_crsr_col
LDI_C .tn_edge11_col
CALL :tt_assert_eq

ST :t_term_flags 0x00

# --- bottom-edge behavior matrix (2.2.1 bits 4-5), from (59,63) ---

# default (flags=0x00, fast path): scroll, land on (59,0)
CALL :t_cursor_init
ST %display_chars%+64 'S'
ST %display_color%+64 0x2a
LDI_AH 0x3b
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x00
LDI_AL 'Q'
CALL :t_putchar
LD_AL %display_chars%
LDI_AH 'S'
LDI_C .tn_bottom_default_scrolled
CALL :tt_assert_eq
LDI_AH 0x3b
LD_AL :t_crsr_row
LDI_C .tn_bottom_default_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_bottom_default_col
CALL :tt_assert_eq

# TERM_NOSCROLL_B: stop at bottom row, no scroll (col still wraps per bits2-3)
CALL :t_cursor_init
LDI_AH 0x3b
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x10
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x3b
LD_AL :t_crsr_row
LDI_C .tn_bottom_noscroll_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_bottom_noscroll_col
CALL :tt_assert_eq

# TERM_NOSCROLL_B|TERM_WRAPTOP_B: wrap cursor to (0,0), no scroll
CALL :t_cursor_init
LDI_AH 0x3b
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
ST :t_term_flags 0x30
LDI_AL 'Q'
CALL :t_putchar
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_bottom_wraptop_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_bottom_wraptop_col
CALL :tt_assert_eq

ST :t_term_flags 0x00

# --- :t_term_scroll directly: rows shift, last row cleared ---
CALL :t_cursor_init
ST %display_chars%+64 'T'
ST %display_color%+64 0x15
CALL :t_term_scroll
LD_AL %display_chars%
LDI_AH 'T'
LDI_C .tn_scroll_char
CALL :tt_assert_eq
LD_AL %display_color%
LDI_AH 0x15
LDI_C .tn_scroll_color
CALL :tt_assert_eq
LD_AL %display_chars%+3776
LDI_AH 0x00
LDI_C .tn_scroll_lastrow_char
CALL :tt_assert_eq
LD_AL %display_color%+3776
LDI_AH 0x3f
LDI_C .tn_scroll_lastrow_color
CALL :tt_assert_eq

# --- :t_print: string output via :t_putchar, newline included ---
CALL :t_cursor_init
LDI_C .str_hi
CALL :t_print
LD_AL %display_chars%
LDI_AH 'H'
LDI_C .tn_print_h
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 'i'
LDI_C .tn_print_i
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL :t_crsr_row
LDI_C .tn_print_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_print_col
CALL :tt_assert_eq

# --- :t_print with ESC while ANSI is off: ESC prints as a plain glyph ---
CALL :t_cursor_init
LDI_C .str_esc
CALL :t_print
LD_AL %display_chars%
LDI_AH 0x1b
LDI_C .tn_print_esc_char
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 'A'
LDI_C .tn_print_esc_char2
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_print_esc_row
CALL :tt_assert_eq
LDI_AH 0x02
LD_AL :t_crsr_col
LDI_C .tn_print_esc_col
CALL :tt_assert_eq

# --- :t_printf: sprintf into the private buffer, then :t_print ---
CALL :t_cursor_init
LDI_C .str_world
CALL :heap_push_C          # last specifier (%s) pushed first
LDI_AL 0xab
CALL :heap_push_AL          # first specifier (%x) pushed second/last
LDI_C .fmt_hexstr
CALL :t_printf
LD_AL %display_chars%
LDI_AH 'a'
LDI_C .tn_printf_c0
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 'b'
LDI_C .tn_printf_c1
CALL :tt_assert_eq
LD_AL %display_chars%+2
LDI_AH '-'
LDI_C .tn_printf_c2
CALL :tt_assert_eq
LD_AL %display_chars%+3
LDI_AH 'w'
LDI_C .tn_printf_c3
CALL :tt_assert_eq

CALL :tt_result
RET

.suite_name "output\0"
.str_hi "Hi\n\0"
.str_esc 0x1b "A\0"
.str_world "world\0"
.fmt_hexstr "%x-%s\0"

.tn_putchar_char "putchar_char\0"
.tn_putchar_row "putchar_row\0"
.tn_putchar_col "putchar_col\0"
.tn_color_written "color_written\0"
.tn_raw_char "raw_char\0"
.tn_raw_row "raw_row\0"
.tn_raw_col "raw_col\0"
.tn_cr_row "cr_row\0"
.tn_cr_col "cr_col\0"
.tn_lf_row "lf_row\0"
.tn_lf_col "lf_col\0"
.tn_bs_char384 "bs_char384\0"
.tn_bs_char385 "bs_char385\0"
.tn_bs_color385 "bs_color385\0"
.tn_bs_col "bs_col\0"
.tn_del_char448 "del_char448\0"
.tn_del_color448 "del_color448\0"
.tn_del_col "del_col\0"
.tn_edge00_row "edge00_row\0"
.tn_edge00_col "edge00_col\0"
.tn_edge01_row "edge01_row\0"
.tn_edge01_col "edge01_col\0"
.tn_edge10_row "edge10_row\0"
.tn_edge10_col "edge10_col\0"
.tn_edge11_row "edge11_row\0"
.tn_edge11_col "edge11_col\0"
.tn_bottom_default_scrolled "bottom_default_scrolled\0"
.tn_bottom_default_row "bottom_default_row\0"
.tn_bottom_default_col "bottom_default_col\0"
.tn_bottom_noscroll_row "bottom_noscroll_row\0"
.tn_bottom_noscroll_col "bottom_noscroll_col\0"
.tn_bottom_wraptop_row "bottom_wraptop_row\0"
.tn_bottom_wraptop_col "bottom_wraptop_col\0"
.tn_scroll_char "scroll_char\0"
.tn_scroll_color "scroll_color\0"
.tn_scroll_lastrow_char "scroll_lastrow_char\0"
.tn_scroll_lastrow_color "scroll_lastrow_color\0"
.tn_print_h "print_h\0"
.tn_print_i "print_i\0"
.tn_print_row "print_row\0"
.tn_print_col "print_col\0"
.tn_print_esc_char "print_esc_char\0"
.tn_print_esc_char2 "print_esc_char2\0"
.tn_print_esc_row "print_esc_row\0"
.tn_print_esc_col "print_esc_col\0"
.tn_printf_c0 "printf_c0\0"
.tn_printf_c1 "printf_c1\0"
.tn_printf_c2 "printf_c2\0"
.tn_printf_c3 "printf_c3\0"
