# vim: syntax=asm-mycpu

# Tests for 40-t_readline.asm (TERMINAL_REFACTOR.md 2.4.1/2.4.2). Every
# test injects a scripted key sequence via :kb_inject *before* calling
# :t_readline (which then consumes it synchronously from the poll loop),
# and asserts the returned AL/AH plus buffer and/or screen content.

:tests_readline_run
LDI_C .suite_name
CALL :tt_suite
ST $t_term_flags 0x00                # fast path, ctrl chars on, echo via putchar

# --- "hi" + Enter ---

CALL :t_cursor_init
LDI_C .seq_hi_enter
LDI_AL 3
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01                          # echo on
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len
ALUOP_ADDR %A%+%AH% .rt_status

LDI_AH 0x02
LD_AL .rt_len
LDI_C .tn_hi_len
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rt_status
LDI_C .tn_hi_status
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL .rl_buf
LDI_C .tn_hi_buf0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL .rl_buf+1
LDI_C .tn_hi_buf1
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf+2
LDI_C .tn_hi_buf2
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL %display_chars%
LDI_C .tn_hi_screen0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL %display_chars%+1
LDI_C .tn_hi_screen1
CALL :tt_assert_eq

# --- Enter alone ---

CALL :t_cursor_init
LDI_C .seq_enter_only
LDI_AL 1
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len
ALUOP_ADDR %A%+%AH% .rt_status

LDI_AH 0x00
LD_AL .rt_len
LDI_C .tn_empty_len
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rt_status
LDI_C .tn_empty_status
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf
LDI_C .tn_empty_buf0
CALL :tt_assert_eq

# --- "abc" + BS + "d" + Enter -> "abd" ---

CALL :t_cursor_init
LDI_C .seq_abc_bs_d
LDI_AL 6
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_bs_len
CALL :tt_assert_eq
LDI_AH 'a'
LD_AL .rl_buf
LDI_C .tn_bs_buf0
CALL :tt_assert_eq
LDI_AH 'b'
LD_AL .rl_buf+1
LDI_C .tn_bs_buf1
CALL :tt_assert_eq
LDI_AH 'd'
LD_AL .rl_buf+2
LDI_C .tn_bs_buf2
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf+3
LDI_C .tn_bs_buf3
CALL :tt_assert_eq

# --- "abd" + Left + Left + "X" + Enter -> "aXbd" (insert, default mode) ---

CALL :t_cursor_init
LDI_C .seq_abd_ll_x
LDI_AL 7
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x04
LD_AL .rt_len
LDI_C .tn_ins_len
CALL :tt_assert_eq
LDI_AH 'a'
LD_AL .rl_buf
LDI_C .tn_ins_buf0
CALL :tt_assert_eq
LDI_AH 'X'
LD_AL .rl_buf+1
LDI_C .tn_ins_buf1
CALL :tt_assert_eq
LDI_AH 'b'
LD_AL .rl_buf+2
LDI_C .tn_ins_buf2
CALL :tt_assert_eq
LDI_AH 'd'
LD_AL .rl_buf+3
LDI_C .tn_ins_buf3
CALL :tt_assert_eq
LDI_AH 'a'
LD_AL %display_chars%
LDI_C .tn_ins_screen0
CALL :tt_assert_eq
LDI_AH 'X'
LD_AL %display_chars%+1
LDI_C .tn_ins_screen1
CALL :tt_assert_eq
LDI_AH 'b'
LD_AL %display_chars%+2
LDI_C .tn_ins_screen2
CALL :tt_assert_eq
LDI_AH 'd'
LD_AL %display_chars%+3
LDI_C .tn_ins_screen3
CALL :tt_assert_eq

# --- "ab" + Left + Left + Insert + "X" + Enter -> "Xb" (overwrite) ---

CALL :t_cursor_init
LDI_C .seq_ab_ll_ins_x
LDI_AL 7
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x02
LD_AL .rt_len
LDI_C .tn_ovw_len
CALL :tt_assert_eq
LDI_AH 'X'
LD_AL .rl_buf
LDI_C .tn_ovw_buf0
CALL :tt_assert_eq
LDI_AH 'b'
LD_AL .rl_buf+1
LDI_C .tn_ovw_buf1
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf+2
LDI_C .tn_ovw_buf2
CALL :tt_assert_eq

# --- "abcd" + Home + DEL + Enter -> "bcd" ---

CALL :t_cursor_init
LDI_C .seq_abcd_home_del
LDI_AL 7
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_del_len
CALL :tt_assert_eq
LDI_AH 'b'
LD_AL .rl_buf
LDI_C .tn_del_buf0
CALL :tt_assert_eq
LDI_AH 'c'
LD_AL .rl_buf+1
LDI_C .tn_del_buf1
CALL :tt_assert_eq
LDI_AH 'd'
LD_AL .rl_buf+2
LDI_C .tn_del_buf2
CALL :tt_assert_eq

# --- "abcd" + Home + End + "e" + Enter -> "abcde" (End returns to tail) ---

CALL :t_cursor_init
LDI_C .seq_abcd_home_end_e
LDI_AL 8
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x05
LD_AL .rt_len
LDI_C .tn_end_len
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL .rl_buf+4
LDI_C .tn_end_buf4
CALL :tt_assert_eq

# --- maxlen clamp: buffer size 5, "abcdefg" + Enter -> "abcd" ---

CALL :t_cursor_init
LDI_C .seq_maxlen
LDI_AL 8
CALL :kb_inject
LDI_C .rl_buf5
LDI_AL 5
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x04
LD_AL .rt_len
LDI_C .tn_max_len
CALL :tt_assert_eq
LDI_AH 'a'
LD_AL .rl_buf5
LDI_C .tn_max_buf0
CALL :tt_assert_eq
LDI_AH 'd'
LD_AL .rl_buf5+3
LDI_C .tn_max_buf3
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf5+4
LDI_C .tn_max_buf4
CALL :tt_assert_eq

# --- Ctrl+C mid-entry ---

CALL :t_cursor_init
LDI_C .seq_ctrlc
LDI_AL 2
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len
ALUOP_ADDR %A%+%AH% .rt_status

LDI_AH 0x00
LD_AL .rt_len
LDI_C .tn_ctrlc_len
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL .rt_status
LDI_C .tn_ctrlc_status
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf
LDI_C .tn_ctrlc_buf0
CALL :tt_assert_eq

# --- Echo off: screen untouched, buffer still edited ---

CALL :t_cursor_init
ST %display_chars% 0x40              # sentinel ('@') at the start position
LDI_C .seq_hi_enter
LDI_AL 3
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x00                          # echo off
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x02
LD_AL .rt_len
LDI_C .tn_noecho_len
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL .rl_buf
LDI_C .tn_noecho_buf0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL .rl_buf+1
LDI_C .tn_noecho_buf1
CALL :tt_assert_eq
LDI_AH 0x40
LD_AL %display_chars%
LDI_C .tn_noecho_screen
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_crsr_row
LDI_C .tn_noecho_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_crsr_col
LDI_C .tn_noecho_col
CALL :tt_assert_eq

# --- Wrap: start at col 60, type 8 digits + Enter -> continues on next row ---

CALL :t_cursor_init
LDI_AH 0x05
LDI_AL 0x3c                          # (row 5, col 60)
CALL :t_cursor_goto_rowcol
LDI_C .seq_wrap_type
LDI_AL 9                             # 8 digits + Enter
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x08
LD_AL .rt_len
LDI_C .tn_wrap_len
CALL :tt_assert_eq
LDI_AH '1'
LD_AL .rl_buf
LDI_C .tn_wrap_buf0
CALL :tt_assert_eq
LDI_AH '4'
LD_AL %display_chars%+383            # row 5, col 63 (5*64+63)
LDI_C .tn_wrap_screen_row5col63
CALL :tt_assert_eq
LDI_AH '5'
LD_AL %display_chars%+384            # row 6, col 0
LDI_C .tn_wrap_screen_row6col0
CALL :tt_assert_eq

# --- BS back across the wrap: same start, 8 digits then 5 backspaces ---

CALL :t_cursor_init
LDI_AH 0x05
LDI_AL 0x3c                          # (row 5, col 60)
CALL :t_cursor_goto_rowcol
LDI_C .seq_wrap_bs
LDI_AL 14                            # 8 digits + 5 backspaces + Enter
CALL :kb_inject
LDI_C .rl_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_wrapbs_len
CALL :tt_assert_eq
LDI_AH '1'
LD_AL .rl_buf
LDI_C .tn_wrapbs_buf0
CALL :tt_assert_eq
LDI_AH '3'
LD_AL .rl_buf+2
LDI_C .tn_wrapbs_buf2
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .rl_buf+3
LDI_C .tn_wrapbs_buf3
CALL :tt_assert_eq

CALL :tt_result
RET

.suite_name "readline\0"

.seq_hi_enter        0x00 'h' 0x00 'i' 0x00 0x0d
.seq_enter_only       0x00 0x0d
.seq_abc_bs_d          0x00 'a' 0x00 'b' 0x00 'c' 0x00 0x08 0x00 'd' 0x00 0x0d
.seq_abd_ll_x          0x00 'a' 0x00 'b' 0x00 'd' 0x00 0x13 0x00 0x13 0x00 'X' 0x00 0x0d
.seq_ab_ll_ins_x       0x00 'a' 0x00 'b' 0x00 0x13 0x00 0x13 0x00 0x0f 0x00 'X' 0x00 0x0d
.seq_abcd_home_del     0x00 'a' 0x00 'b' 0x00 'c' 0x00 'd' 0x00 0x02 0x00 0x7f 0x00 0x0d
.seq_abcd_home_end_e   0x00 'a' 0x00 'b' 0x00 'c' 0x00 'd' 0x00 0x02 0x00 0x1e 0x00 'e' 0x00 0x0d
.seq_maxlen            0x00 'a' 0x00 'b' 0x00 'c' 0x00 'd' 0x00 'e' 0x00 'f' 0x00 'g' 0x00 0x0d
.seq_ctrlc             0x00 'a' 0x02 'c'
.seq_wrap_type         0x00 '1' 0x00 '2' 0x00 '3' 0x00 '4' 0x00 '5' 0x00 '6' 0x00 '7' 0x00 '8' 0x00 0x0d
.seq_wrap_bs           0x00 '1' 0x00 '2' 0x00 '3' 0x00 '4' 0x00 '5' 0x00 '6' 0x00 '7' 0x00 '8' 0x00 0x08 0x00 0x08 0x00 0x08 0x00 0x08 0x00 0x08 0x00 0x0d

.rl_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.rl_buf5 "\0\0\0\0\0"
.rt_len "\0"
.rt_status "\0"

.tn_hi_len "hi_len\0"
.tn_hi_status "hi_status\0"
.tn_hi_buf0 "hi_buf0\0"
.tn_hi_buf1 "hi_buf1\0"
.tn_hi_buf2 "hi_buf2\0"
.tn_hi_screen0 "hi_screen0\0"
.tn_hi_screen1 "hi_screen1\0"
.tn_empty_len "empty_len\0"
.tn_empty_status "empty_status\0"
.tn_empty_buf0 "empty_buf0\0"
.tn_bs_len "bs_len\0"
.tn_bs_buf0 "bs_buf0\0"
.tn_bs_buf1 "bs_buf1\0"
.tn_bs_buf2 "bs_buf2\0"
.tn_bs_buf3 "bs_buf3\0"
.tn_ins_len "ins_len\0"
.tn_ins_buf0 "ins_buf0\0"
.tn_ins_buf1 "ins_buf1\0"
.tn_ins_buf2 "ins_buf2\0"
.tn_ins_buf3 "ins_buf3\0"
.tn_ins_screen0 "ins_screen0\0"
.tn_ins_screen1 "ins_screen1\0"
.tn_ins_screen2 "ins_screen2\0"
.tn_ins_screen3 "ins_screen3\0"
.tn_ovw_len "ovw_len\0"
.tn_ovw_buf0 "ovw_buf0\0"
.tn_ovw_buf1 "ovw_buf1\0"
.tn_ovw_buf2 "ovw_buf2\0"
.tn_del_len "del_len\0"
.tn_del_buf0 "del_buf0\0"
.tn_del_buf1 "del_buf1\0"
.tn_del_buf2 "del_buf2\0"
.tn_end_len "end_len\0"
.tn_end_buf4 "end_buf4\0"
.tn_max_len "max_len\0"
.tn_max_buf0 "max_buf0\0"
.tn_max_buf3 "max_buf3\0"
.tn_max_buf4 "max_buf4\0"
.tn_ctrlc_len "ctrlc_len\0"
.tn_ctrlc_status "ctrlc_status\0"
.tn_ctrlc_buf0 "ctrlc_buf0\0"
.tn_noecho_len "noecho_len\0"
.tn_noecho_buf0 "noecho_buf0\0"
.tn_noecho_buf1 "noecho_buf1\0"
.tn_noecho_screen "noecho_screen\0"
.tn_noecho_row "noecho_row\0"
.tn_noecho_col "noecho_col\0"
.tn_wrap_len "wrap_len\0"
.tn_wrap_buf0 "wrap_buf0\0"
.tn_wrap_screen_row5col63 "wrap_scr_r5c63\0"
.tn_wrap_screen_row6col0 "wrap_scr_r6c0\0"
.tn_wrapbs_len "wrapbs_len\0"
.tn_wrapbs_buf0 "wrapbs_buf0\0"
.tn_wrapbs_buf2 "wrapbs_buf2\0"
.tn_wrapbs_buf3 "wrapbs_buf3\0"
