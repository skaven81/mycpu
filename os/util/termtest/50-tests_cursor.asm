# vim: syntax=asm-mycpu

# Tests for 20-t_cursor.asm (TERMINAL_REFACTOR.md 2.3).

:tests_cursor_run
LDI_C .suite_name
CALL :tt_suite

# --- :t_cursor_conv_rowcol ---

# (0,0) -> offset 0x0000
LDI_AH 0x00
LDI_AL 0x00
CALL :t_cursor_conv_rowcol
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x00
LD_AL .cc_result_hi
LDI_C .tn_convrc_00_hi
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .cc_result_lo
LDI_C .tn_convrc_00_lo
CALL :tt_assert_eq

# (0,63) -> offset 0x003F
LDI_AH 0x00
LDI_AL 0x3f
CALL :t_cursor_conv_rowcol
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x00
LD_AL .cc_result_hi
LDI_C .tn_convrc_063_hi
CALL :tt_assert_eq
LDI_AH 0x3f
LD_AL .cc_result_lo
LDI_C .tn_convrc_063_lo
CALL :tt_assert_eq

# (1,0) -> offset 0x0040
LDI_AH 0x01
LDI_AL 0x00
CALL :t_cursor_conv_rowcol
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x00
LD_AL .cc_result_hi
LDI_C .tn_convrc_10_hi
CALL :tt_assert_eq
LDI_AH 0x40
LD_AL .cc_result_lo
LDI_C .tn_convrc_10_lo
CALL :tt_assert_eq

# (59,63) -> offset 0x0EFF
LDI_AH 0x3b
LDI_AL 0x3f
CALL :t_cursor_conv_rowcol
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x0e
LD_AL .cc_result_hi
LDI_C .tn_convrc_5963_hi
CALL :tt_assert_eq
LDI_AH 0xff
LD_AL .cc_result_lo
LDI_C .tn_convrc_5963_lo
CALL :tt_assert_eq

# --- :t_cursor_conv_addr (round-trips the offsets above) ---

# 0x4000 -> row 0, col 0
LDI_AH 0x40
LDI_AL 0x00
CALL :t_cursor_conv_addr
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x00
LD_AL .cc_result_hi
LDI_C .tn_convaddr_4000_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .cc_result_lo
LDI_C .tn_convaddr_4000_col
CALL :tt_assert_eq

# 0x403F -> row 0, col 63
LDI_AH 0x40
LDI_AL 0x3f
CALL :t_cursor_conv_addr
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x00
LD_AL .cc_result_hi
LDI_C .tn_convaddr_403f_row
CALL :tt_assert_eq
LDI_AH 0x3f
LD_AL .cc_result_lo
LDI_C .tn_convaddr_403f_col
CALL :tt_assert_eq

# 0x4040 -> row 1, col 0
LDI_AH 0x40
LDI_AL 0x40
CALL :t_cursor_conv_addr
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x01
LD_AL .cc_result_hi
LDI_C .tn_convaddr_4040_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL .cc_result_lo
LDI_C .tn_convaddr_4040_col
CALL :tt_assert_eq

# 0x4EFF -> row 59, col 63
LDI_AH 0x4e
LDI_AL 0xff
CALL :t_cursor_conv_addr
ALUOP_ADDR %A%+%AH% .cc_result_hi
ALUOP_ADDR %A%+%AL% .cc_result_lo
LDI_AH 0x3b
LD_AL .cc_result_hi
LDI_C .tn_convaddr_4eff_row
CALL :tt_assert_eq
LDI_AH 0x3f
LD_AL .cc_result_lo
LDI_C .tn_convaddr_4eff_col
CALL :tt_assert_eq

# --- :t_cursor_goto_rowcol(5,10) -> row/col/addr_chars/addr_color ---

CALL :t_cursor_init
LDI_AH 0x05
LDI_AL 0x0a
CALL :t_cursor_goto_rowcol

LDI_AH 0x05
LD_AL $t_crsr_row
LDI_C .tn_goto_row
CALL :tt_assert_eq

LDI_AH 0x0a
LD_AL $t_crsr_col
LDI_C .tn_goto_col
CALL :tt_assert_eq

LDI_AH 0x41
LD_AL $t_crsr_addr_chars
LDI_C .tn_goto_ach_hi
CALL :tt_assert_eq

LDI_AH 0x4a
LD_AL $t_crsr_addr_chars+1
LDI_C .tn_goto_ach_lo
CALL :tt_assert_eq

LDI_AH 0x51
LD_AL $t_crsr_addr_color
LDI_C .tn_goto_acl_hi
CALL :tt_assert_eq

LDI_AH 0x4a
LD_AL $t_crsr_addr_color+1
LDI_C .tn_goto_acl_lo
CALL :tt_assert_eq

# --- goto must NOT touch the color framebuffer (2.3.2) ---

CALL :t_cursor_init
ST %display_color% 0x00
LD_AL %display_color%
LDI_BL 0x40
ALUOP_AL %A|B%+%AL%+%BL%
ALUOP_ADDR %A%+%AL% %display_color%   # display_color[0] = 0x40 (simulated cursor glyph)
LDI_AH 0x03
LDI_AL 0x03
CALL :t_cursor_goto_rowcol            # move away -- must not touch color RAM
LD_AL %display_color%
LDI_AH 0x40
LDI_C .tn_goto_no_color_touch
CALL :tt_assert_eq

# --- :t_cursor_display_sync sets/clears the cursor bit per $t_crsr_on ---

CALL :t_cursor_init
ST %display_color% 0x00
CALL :t_cursor_display_sync           # on=1 (from init) -> bit should be set
LD_AL %display_color%
LDI_AH 0x40
LDI_C .tn_sync_on
CALL :tt_assert_eq

CALL :t_cursor_off                    # sets on=0 and syncs -> bit should clear
LD_AL %display_color%
LDI_AH 0x00
LDI_C .tn_sync_off
CALL :tt_assert_eq

# --- edge bounds: address-linear movement, no-op at screen edges ---

# right at (2,63) moves to (3,0), address-linear
CALL :t_cursor_init
LDI_AH 0x02
LDI_AL 0x3f
CALL :t_cursor_goto_rowcol
CALL :t_cursor_right
LDI_AH 0x03
LD_AL $t_crsr_row
LDI_C .tn_right_wrap_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_crsr_col
LDI_C .tn_right_wrap_col
CALL :tt_assert_eq

# left at (0,0) is a no-op
CALL :t_cursor_init
CALL :t_cursor_left
LDI_AH 0x00
LD_AL $t_crsr_row
LDI_C .tn_left_edge_row
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_crsr_col
LDI_C .tn_left_edge_col
CALL :tt_assert_eq

# down at (59,0) is a no-op
CALL :t_cursor_init
LDI_AH 0x3b
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
CALL :t_cursor_down
LDI_AH 0x3b
LD_AL $t_crsr_row
LDI_C .tn_down_edge_row
CALL :tt_assert_eq

# up at (0,0) is a no-op
CALL :t_cursor_init
CALL :t_cursor_up
LDI_AH 0x00
LD_AL $t_crsr_row
LDI_C .tn_up_edge_row
CALL :tt_assert_eq

# --- :t_cursor_save / :t_cursor_restore round trip ---

CALL :t_cursor_init
LDI_AH 0x0a
LDI_AL 0x14
CALL :t_cursor_goto_rowcol
CALL :t_cursor_save
LDI_AH 0x00
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
CALL :t_cursor_restore
LDI_AH 0x0a
LD_AL $t_crsr_row
LDI_C .tn_saverestore_row
CALL :tt_assert_eq
LDI_AH 0x14
LD_AL $t_crsr_col
LDI_C .tn_saverestore_col
CALL :tt_assert_eq

CALL :tt_result
RET

.cc_result_hi "\0"
.cc_result_lo "\0"

.suite_name "cursor\0"
.tn_convrc_00_hi "convrc_00_hi\0"
.tn_convrc_00_lo "convrc_00_lo\0"
.tn_convrc_063_hi "convrc_063_hi\0"
.tn_convrc_063_lo "convrc_063_lo\0"
.tn_convrc_10_hi "convrc_10_hi\0"
.tn_convrc_10_lo "convrc_10_lo\0"
.tn_convrc_5963_hi "convrc_5963_hi\0"
.tn_convrc_5963_lo "convrc_5963_lo\0"
.tn_convaddr_4000_row "convaddr_4000_row\0"
.tn_convaddr_4000_col "convaddr_4000_col\0"
.tn_convaddr_403f_row "convaddr_403f_row\0"
.tn_convaddr_403f_col "convaddr_403f_col\0"
.tn_convaddr_4040_row "convaddr_4040_row\0"
.tn_convaddr_4040_col "convaddr_4040_col\0"
.tn_convaddr_4eff_row "convaddr_4eff_row\0"
.tn_convaddr_4eff_col "convaddr_4eff_col\0"
.tn_goto_row "goto_row\0"
.tn_goto_col "goto_col\0"
.tn_goto_ach_hi "goto_ach_hi\0"
.tn_goto_ach_lo "goto_ach_lo\0"
.tn_goto_acl_hi "goto_acl_hi\0"
.tn_goto_acl_lo "goto_acl_lo\0"
.tn_goto_no_color_touch "goto_no_color_touch\0"
.tn_sync_on "sync_on\0"
.tn_sync_off "sync_off\0"
.tn_right_wrap_row "right_wrap_row\0"
.tn_right_wrap_col "right_wrap_col\0"
.tn_left_edge_row "left_edge_row\0"
.tn_left_edge_col "left_edge_col\0"
.tn_down_edge_row "down_edge_row\0"
.tn_up_edge_row "up_edge_row\0"
.tn_saverestore_row "saverestore_row\0"
.tn_saverestore_col "saverestore_col\0"
