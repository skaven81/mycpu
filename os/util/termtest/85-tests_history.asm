# vim: syntax=asm-mycpu

# Tests for readline history (TERMINAL_REFACTOR.md 2.4.3, Task 6). Allocates
# a small 4-entry x 16-byte history buffer via :malloc_segments and wires it
# into :t_rl_history_*, exactly the pattern a real caller (the shell) would
# use at startup.
#
# The "circular eviction" check needs to inspect what got recalled WITHOUT
# also appending it back into history (an Enter would mutate write_idx/count
# and corrupt the next check in the same group). Ctrl+C is the tool for
# this: like Enter it seeks the cursor to the end of whatever is currently
# loaded before returning, but it never appends (see .rl_ctrlc) -- so the
# recalled text is verified by reading the SCREEN cells it echoed to,
# not the returned buffer (which Ctrl+C always empties).

:tests_history_run
LDI_C .suite_name
CALL :tt_suite
ST $t_term_flags 0x00

LDI_AL 0x01                          # 1 segment = 128 bytes (>= 4*16)
CALL :malloc_segments
ALUOP_ADDR %A%+%AH% $t_rl_history_buf
ALUOP_ADDR %A%+%AL% $t_rl_history_buf+1
ST $t_rl_history_capacity 0x04
ST $t_rl_history_entry_sz 0x10       # 16 bytes/entry, matches .h_buf below

# --- Enter "one"; new call: Up+Enter -> "one" ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_up_enter
LDI_AL 2
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_single_len
CALL :tt_assert_eq
LDI_AH 'o'
LD_AL .h_buf
LDI_C .tn_single_buf0
CALL :tt_assert_eq
LDI_AH 'n'
LD_AL .h_buf+1
LDI_C .tn_single_buf1
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL .h_buf+2
LDI_C .tn_single_buf2
CALL :tt_assert_eq

# --- Enter "one","two"; Up,Up+Enter -> "one" ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_two
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_up_up_enter
LDI_AL 3
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_uu_len
CALL :tt_assert_eq
LDI_AH 'o'
LD_AL .h_buf
LDI_C .tn_uu_buf0
CALL :tt_assert_eq
LDI_AH 'n'
LD_AL .h_buf+1
LDI_C .tn_uu_buf1
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL .h_buf+2
LDI_C .tn_uu_buf2
CALL :tt_assert_eq

# --- Same precondition; Up,Up,Down+Enter -> "two" ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_two
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_uu_down_enter
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_uud_len
CALL :tt_assert_eq
LDI_AH 't'
LD_AL .h_buf
LDI_C .tn_uud_buf0
CALL :tt_assert_eq
LDI_AH 'w'
LD_AL .h_buf+1
LDI_C .tn_uud_buf1
CALL :tt_assert_eq
LDI_AH 'o'
LD_AL .h_buf+2
LDI_C .tn_uud_buf2
CALL :tt_assert_eq

# --- Same precondition; Up,Down+Enter -> "" (back to the fresh line) ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_two
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_up_down_enter
LDI_AL 3
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x00
LD_AL .rt_len
LDI_C .tn_ud_len
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .h_buf
LDI_C .tn_ud_buf0
CALL :tt_assert_eq

# --- Recall then edit: Up, BS, "X", Enter -> "twX" (recalled text is
#     editable, and the edited result becomes its own history entry) ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_two
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_up_bs_x_enter
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x03
LD_AL .rt_len
LDI_C .tn_edit_len
CALL :tt_assert_eq
LDI_AH 't'
LD_AL .h_buf
LDI_C .tn_edit_buf0
CALL :tt_assert_eq
LDI_AH 'w'
LD_AL .h_buf+1
LDI_C .tn_edit_buf1
CALL :tt_assert_eq
LDI_AH 'X'
LD_AL .h_buf+2
LDI_C .tn_edit_buf2
CALL :tt_assert_eq

# --- Circular: 5 entries into a 4-slot ring -> oldest ("one") evicted,
#     newest 4 recallable in order (five, four, three, two). Each check
#     recalls via Up*N then Ctrl+C (never Enter) so it doesn't itself
#     append and corrupt the next check's browse depth; the recalled text
#     is verified on screen, since Ctrl+C always returns an empty buffer. ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_pop_one
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_two
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_three
LDI_AL 6
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_four
LDI_AL 5
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

CALL :t_cursor_init
LDI_C .seq_pop_five
LDI_AL 5
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

# 1 Up -> newest = "five"
CALL :t_cursor_init
LDI_C .seq_1up_ctrlc
LDI_AL 2
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len
ALUOP_ADDR %A%+%AH% .rt_status
LDI_AH 0x00
LD_AL .rt_len
LDI_C .tn_circ1_len
CALL :tt_assert_eq
LDI_AH 0x01
LD_AL .rt_status
LDI_C .tn_circ1_status
CALL :tt_assert_eq
LDI_AH 'f'
LD_AL %display_chars%
LDI_C .tn_circ1_c0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL %display_chars%+1
LDI_C .tn_circ1_c1
CALL :tt_assert_eq
LDI_AH 'v'
LD_AL %display_chars%+2
LDI_C .tn_circ1_c2
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL %display_chars%+3
LDI_C .tn_circ1_c3
CALL :tt_assert_eq

# 2 Up -> "four"
CALL :t_cursor_init
LDI_C .seq_2up_ctrlc
LDI_AL 3
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
LDI_AH 'f'
LD_AL %display_chars%
LDI_C .tn_circ2_c0
CALL :tt_assert_eq
LDI_AH 'o'
LD_AL %display_chars%+1
LDI_C .tn_circ2_c1
CALL :tt_assert_eq
LDI_AH 'u'
LD_AL %display_chars%+2
LDI_C .tn_circ2_c2
CALL :tt_assert_eq
LDI_AH 'r'
LD_AL %display_chars%+3
LDI_C .tn_circ2_c3
CALL :tt_assert_eq

# 3 Up -> "three"
CALL :t_cursor_init
LDI_C .seq_3up_ctrlc
LDI_AL 4
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
LDI_AH 't'
LD_AL %display_chars%
LDI_C .tn_circ3_c0
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL %display_chars%+1
LDI_C .tn_circ3_c1
CALL :tt_assert_eq
LDI_AH 'r'
LD_AL %display_chars%+2
LDI_C .tn_circ3_c2
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL %display_chars%+3
LDI_C .tn_circ3_c3
CALL :tt_assert_eq
LDI_AH 'e'
LD_AL %display_chars%+4
LDI_C .tn_circ3_c4
CALL :tt_assert_eq

# 4 Up -> "two" (the oldest survivor; "one" was evicted)
CALL :t_cursor_init
LDI_C .seq_4up_ctrlc
LDI_AL 5
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
LDI_AH 't'
LD_AL %display_chars%
LDI_C .tn_circ4_c0
CALL :tt_assert_eq
LDI_AH 'w'
LD_AL %display_chars%+1
LDI_C .tn_circ4_c1
CALL :tt_assert_eq
LDI_AH 'o'
LD_AL %display_chars%+2
LDI_C .tn_circ4_c2
CALL :tt_assert_eq

# --- Empty Enter is not recorded (count unchanged) ---

ST $t_rl_history_count 0x00
ST $t_rl_history_write_idx 0x00

CALL :t_cursor_init
LDI_C .seq_empty_enter
LDI_AL 1
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline

LDI_AH 0x00
LD_AL $t_rl_history_count
LDI_C .tn_empty_count
CALL :tt_assert_eq

# --- Disabled ($t_rl_history_buf == 0): Up/Down are no-ops; typed text is
#     unaffected on both the buffer and the screen ---

LD_AH $t_rl_history_buf
LD_AL $t_rl_history_buf+1
ALUOP_ADDR %A%+%AH% .saved_hist_buf
ALUOP_ADDR %A%+%AL% .saved_hist_buf+1
ST $t_rl_history_buf 0x00
ST $t_rl_history_buf+1 0x00

CALL :t_cursor_init
LDI_C .seq_hi_up_down_enter
LDI_AL 5
CALL :kb_inject
LDI_C .h_buf
LDI_AL 16
LDI_AH 0x01
CALL :t_readline
ALUOP_ADDR %A%+%AL% .rt_len

LDI_AH 0x02
LD_AL .rt_len
LDI_C .tn_dis_len
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL .h_buf
LDI_C .tn_dis_buf0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL .h_buf+1
LDI_C .tn_dis_buf1
CALL :tt_assert_eq
LDI_AH 'h'
LD_AL %display_chars%
LDI_C .tn_dis_c0
CALL :tt_assert_eq
LDI_AH 'i'
LD_AL %display_chars%+1
LDI_C .tn_dis_c1
CALL :tt_assert_eq

LD_AH .saved_hist_buf
LD_AL .saved_hist_buf+1
ALUOP_ADDR %A%+%AH% $t_rl_history_buf
ALUOP_ADDR %A%+%AL% $t_rl_history_buf+1

# --- Teardown: free the history allocation ---

LD_AH $t_rl_history_buf
LD_AL $t_rl_history_buf+1
CALL :free

CALL :tt_result
RET

.suite_name "history\0"

.seq_pop_one    0x00 'o' 0x00 'n' 0x00 'e' 0x00 0x0d
.seq_pop_two    0x00 't' 0x00 'w' 0x00 'o' 0x00 0x0d
.seq_pop_three  0x00 't' 0x00 'h' 0x00 'r' 0x00 'e' 0x00 'e' 0x00 0x0d
.seq_pop_four   0x00 'f' 0x00 'o' 0x00 'u' 0x00 'r' 0x00 0x0d
.seq_pop_five   0x00 'f' 0x00 'i' 0x00 'v' 0x00 'e' 0x00 0x0d

.seq_up_enter          0x00 0x12 0x00 0x0d
.seq_up_up_enter       0x00 0x12 0x00 0x12 0x00 0x0d
.seq_uu_down_enter     0x00 0x12 0x00 0x12 0x00 0x11 0x00 0x0d
.seq_up_down_enter     0x00 0x12 0x00 0x11 0x00 0x0d
.seq_up_bs_x_enter     0x00 0x12 0x00 0x08 0x00 'X' 0x00 0x0d
.seq_empty_enter       0x00 0x0d
.seq_hi_up_down_enter  0x00 'h' 0x00 'i' 0x00 0x12 0x00 0x11 0x00 0x0d

.seq_1up_ctrlc  0x00 0x12 0x02 'c'
.seq_2up_ctrlc  0x00 0x12 0x00 0x12 0x02 'c'
.seq_3up_ctrlc  0x00 0x12 0x00 0x12 0x00 0x12 0x02 'c'
.seq_4up_ctrlc  0x00 0x12 0x00 0x12 0x00 0x12 0x00 0x12 0x02 'c'

.h_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.rt_len "\0"
.rt_status "\0"
.saved_hist_buf "\0\0"

.tn_single_len "single_len\0"
.tn_single_buf0 "single_buf0\0"
.tn_single_buf1 "single_buf1\0"
.tn_single_buf2 "single_buf2\0"
.tn_uu_len "uu_len\0"
.tn_uu_buf0 "uu_buf0\0"
.tn_uu_buf1 "uu_buf1\0"
.tn_uu_buf2 "uu_buf2\0"
.tn_uud_len "uud_len\0"
.tn_uud_buf0 "uud_buf0\0"
.tn_uud_buf1 "uud_buf1\0"
.tn_uud_buf2 "uud_buf2\0"
.tn_ud_len "ud_len\0"
.tn_ud_buf0 "ud_buf0\0"
.tn_edit_len "edit_len\0"
.tn_edit_buf0 "edit_buf0\0"
.tn_edit_buf1 "edit_buf1\0"
.tn_edit_buf2 "edit_buf2\0"
.tn_circ1_len "circ1_len\0"
.tn_circ1_status "circ1_status\0"
.tn_circ1_c0 "circ1_c0\0"
.tn_circ1_c1 "circ1_c1\0"
.tn_circ1_c2 "circ1_c2\0"
.tn_circ1_c3 "circ1_c3\0"
.tn_circ2_c0 "circ2_c0\0"
.tn_circ2_c1 "circ2_c1\0"
.tn_circ2_c2 "circ2_c2\0"
.tn_circ2_c3 "circ2_c3\0"
.tn_circ3_c0 "circ3_c0\0"
.tn_circ3_c1 "circ3_c1\0"
.tn_circ3_c2 "circ3_c2\0"
.tn_circ3_c3 "circ3_c3\0"
.tn_circ3_c4 "circ3_c4\0"
.tn_circ4_c0 "circ4_c0\0"
.tn_circ4_c1 "circ4_c1\0"
.tn_circ4_c2 "circ4_c2\0"
.tn_empty_count "empty_count\0"
.tn_dis_len "dis_len\0"
.tn_dis_buf0 "dis_buf0\0"
.tn_dis_buf1 "dis_buf1\0"
.tn_dis_c0 "dis_c0\0"
.tn_dis_c1 "dis_c1\0"
