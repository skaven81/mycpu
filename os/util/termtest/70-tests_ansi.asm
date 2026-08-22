# vim: syntax=asm-mycpu

# Tests for 35-t_ansi.asm (TERMINAL_REFACTOR.md 2.2.3, non-SGR sequences).
# Every test enables ANSI mode (:t_term_flags bit 1) and drives the parser
# through :t_print so the string-end flush path gets exercised too.

:tests_ansi_run
LDI_C .suite_name
CALL :tt_suite

# --- basic movement, defaults, clamping ---

CALL :t_cursor_init
ST :t_term_flags 0x02                # ANSI on, raw off
LDI_C .seq_5c
CALL :t_print                        # ESC[5C from (0,0) -> (0,5)
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_5c_row
CALL :tt_assert_eq
LDI_AH 0x05
LD_AL :t_crsr_col
LDI_C .tn_5c_col
CALL :tt_assert_eq

LDI_C .seq_b_default
CALL :t_print                        # ESC[B default n=1 -> (1,5)
LDI_AH 0x01
LD_AL :t_crsr_row
LDI_C .tn_b_row
CALL :tt_assert_eq
LDI_AH 0x05
LD_AL :t_crsr_col
LDI_C .tn_b_col
CALL :tt_assert_eq

LDI_C .seq_gotorc
CALL :t_print                        # ESC[10;20H -> row 9, col 19
LDI_AH 0x09
LD_AL :t_crsr_row
LDI_C .tn_gotorc_row
CALL :tt_assert_eq
LDI_AH 0x13
LD_AL :t_crsr_col
LDI_C .tn_gotorc_col
CALL :tt_assert_eq

LDI_C .seq_h_default
CALL :t_print                        # ESC[H -> (0,0)
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_h_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_crsr_col
LDI_C .tn_h_col
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_AH 0x03
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .seq_99a
CALL :t_print                        # ESC[99A from row 3 -> clamp to row 0
LDI_AH 0x00
LD_AL :t_crsr_row
LDI_C .tn_clamp_row
CALL :tt_assert_eq

# --- save/restore ---

CALL :t_cursor_init
LDI_AH 0x08
LDI_AL 0x08
CALL :t_cursor_goto_rowcol
LDI_C .seq_save
CALL :t_print
LDI_AH 0x00
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .seq_restore
CALL :t_print
LDI_AH 0x08
LD_AL :t_crsr_row
LDI_C .tn_restore_row
CALL :tt_assert_eq
LDI_AH 0x08
LD_AL :t_crsr_col
LDI_C .tn_restore_col
CALL :tt_assert_eq

# --- erase screen (2J) ---

CALL :t_cursor_init
ST %display_chars% 0x41              # sentinel so we can see it get cleared
LDI_C .seq_2j
CALL :t_print
LD_AL %display_chars%
LDI_AH 0x00
LDI_C .tn_2j_cleared
CALL :tt_assert_eq
LD_AL %display_chars%+3839
LDI_AH 0x00
LDI_C .tn_2j_cleared_end
CALL :tt_assert_eq

# --- erase line (K), all three modes on a prepared row ---

CALL :t_cursor_init
LDI_D %display_chars%
LDI_AL 0x00
.el_fill_loop
LDI_BL 0x58                          # 'X'
ALUOP_ADDR_D %B%+%BL%
INCR_D
ALUOP_AL %A+1%+%AL%
LDI_BL 64
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .el_fill_loop

LDI_AH 0x00
LDI_AL 0x20
CALL :t_cursor_goto_rowcol            # cursor at (0,32)
LDI_C .seq_0k
CALL :t_print                         # clear cursor..end of line
LD_AL %display_chars%
LDI_AH 0x58
LDI_C .tn_0k_before
CALL :tt_assert_eq                    # col 0 untouched
LD_AL %display_chars%+32
LDI_AH 0x00
LDI_C .tn_0k_at_cursor
CALL :tt_assert_eq                    # col 32 cleared
LD_AL %display_chars%+63
LDI_AH 0x00
LDI_C .tn_0k_end
CALL :tt_assert_eq                    # col 63 cleared

# --- ANSI ?25h / ?25l toggles the cursor flag + display bit ---

CALL :t_cursor_init
ST %display_color% 0x00
LDI_C .seq_hide
CALL :t_print
LDI_AH 0x00
LD_AL :t_crsr_on
LDI_C .tn_hide_flag
CALL :tt_assert_eq
LD_AL %display_color%
LDI_AH 0x00
LDI_C .tn_hide_bit
CALL :tt_assert_eq

LDI_C .seq_show
CALL :t_print
LDI_AH 0x01
LD_AL :t_crsr_on
LDI_C .tn_show_flag
CALL :tt_assert_eq
LD_AL %display_color%
LDI_AH 0x40
LDI_C .tn_show_bit
CALL :tt_assert_eq

# --- ANSI sequences never touch the ROM's own cursor state ---

LD_AL $crsr_row
LDI_AH 0x00
LDI_C .tn_rom_cursor_untouched
CALL :tt_assert_eq

# --- error handling ---

CALL :t_cursor_init
LDI_C .seq_invalid_esc                # "A\x1bQB"
CALL :t_print
LD_AL %display_chars%
LDI_AH 'A'
LDI_C .tn_inv_a
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 0x1b
LDI_C .tn_inv_esc
CALL :tt_assert_eq
LD_AL %display_chars%+2
LDI_AH 'Q'
LDI_C .tn_inv_q
CALL :tt_assert_eq
LD_AL %display_chars%+3
LDI_AH 'B'
LDI_C .tn_inv_b
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_ansi_state
LDI_C .tn_inv_state
CALL :tt_assert_eq

# --- valid but unsupported: ESC[6n renders nothing, resets state ---

CALL :t_cursor_init
LDI_C .seq_devstatus                  # "X\x1b[6n"
CALL :t_print
LD_AL %display_chars%
LDI_AH 'X'
LDI_C .tn_devstatus_x
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 0x00
LDI_C .tn_devstatus_nothing
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_ansi_state
LDI_C .tn_devstatus_state
CALL :tt_assert_eq

# --- parameter overflow: 5+ params flushes the raw sequence ---

CALL :t_cursor_init
LDI_C .seq_param_overflow              # "\x1b[1;2;3;4;5m"
CALL :t_print
LD_AL %display_chars%
LDI_AH 0x1b
LDI_C .tn_overflow_esc
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_ansi_state
LDI_C .tn_overflow_state
CALL :tt_assert_eq

# --- mid-string termination: print("AB\x1b[3") flushes on the null ---

CALL :t_cursor_init
LDI_C .seq_midterm                     # "AB\x1b[3"
CALL :t_print
LD_AL %display_chars%
LDI_AH 'A'
LDI_C .tn_mid_a
CALL :tt_assert_eq
LD_AL %display_chars%+1
LDI_AH 'B'
LDI_C .tn_mid_b
CALL :tt_assert_eq
LD_AL %display_chars%+2
LDI_AH 0x1b
LDI_C .tn_mid_esc
CALL :tt_assert_eq
LD_AL %display_chars%+3
LDI_AH '['
LDI_C .tn_mid_bracket
CALL :tt_assert_eq
LD_AL %display_chars%+4
LDI_AH '3'
LDI_C .tn_mid_three
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL :t_ansi_state
LDI_C .tn_mid_state
CALL :tt_assert_eq

CALL :tt_result
RET

.suite_name "ansi\0"
.seq_5c 0x1b "[5C\0"
.seq_b_default 0x1b "[B\0"
.seq_gotorc 0x1b "[10;20H\0"
.seq_h_default 0x1b "[H\0"
.seq_99a 0x1b "[99A\0"
.seq_save 0x1b "[s\0"
.seq_restore 0x1b "[u\0"
.seq_2j 0x1b "[2J\0"
.seq_0k 0x1b "[0K\0"
.seq_hide 0x1b "[?25l\0"
.seq_show 0x1b "[?25h\0"
.seq_invalid_esc "A" 0x1b "QB\0"
.seq_devstatus "X" 0x1b "[6n\0"
.seq_param_overflow 0x1b "[1;2;3;4;5m\0"
.seq_midterm "AB" 0x1b "[3\0"

.tn_5c_row "5c_row\0"
.tn_5c_col "5c_col\0"
.tn_b_row "b_row\0"
.tn_b_col "b_col\0"
.tn_gotorc_row "gotorc_row\0"
.tn_gotorc_col "gotorc_col\0"
.tn_h_row "h_row\0"
.tn_h_col "h_col\0"
.tn_clamp_row "clamp_row\0"
.tn_restore_row "restore_row\0"
.tn_restore_col "restore_col\0"
.tn_2j_cleared "2j_cleared\0"
.tn_2j_cleared_end "2j_cleared_end\0"
.tn_0k_before "0k_before\0"
.tn_0k_at_cursor "0k_at_cursor\0"
.tn_0k_end "0k_end\0"
.tn_hide_flag "hide_flag\0"
.tn_hide_bit "hide_bit\0"
.tn_show_flag "show_flag\0"
.tn_show_bit "show_bit\0"
.tn_rom_cursor_untouched "rom_cursor_untouched\0"
.tn_inv_a "inv_a\0"
.tn_inv_esc "inv_esc\0"
.tn_inv_q "inv_q\0"
.tn_inv_b "inv_b\0"
.tn_inv_state "inv_state\0"
.tn_devstatus_x "devstatus_x\0"
.tn_devstatus_nothing "devstatus_nothing\0"
.tn_devstatus_state "devstatus_state\0"
.tn_overflow_esc "overflow_esc\0"
.tn_overflow_state "overflow_state\0"
.tn_mid_a "mid_a\0"
.tn_mid_b "mid_b\0"
.tn_mid_esc "mid_esc\0"
.tn_mid_bracket "mid_bracket\0"
.tn_mid_three "mid_three\0"
.tn_mid_state "mid_state\0"
