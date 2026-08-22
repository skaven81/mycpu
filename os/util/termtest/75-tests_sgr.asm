# vim: syntax=asm-mycpu

# Tests for the SGR + 256-color extension to 35-t_ansi.asm's 'm' dispatch
# (TERMINAL_REFACTOR.md 2.2.3 color table, 2.2.3.1 256-color quantization).
# Every test enables ANSI mode, resets the cursor to (0,0), sends an escape
# sequence immediately followed by 'X' through :t_print, and checks the
# character/color bytes at the framebuffer origin. Tests that need a known
# starting color set $t_term_render_color/$t_term_current_color directly
# first (2.2.4's documented direct-write pattern).

:tests_sgr_run
LDI_C .suite_name
CALL :tt_suite

ST $t_term_flags 0x02                # ANSI on, raw off

# --- all 16 base foreground colors (SGR 30-37, 90-97) ---

CALL :t_cursor_init
LDI_C .seq_c30
CALL :t_print
LD_AL %display_color%
LDI_AH 0x00
LDI_C .tn_c30
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c31
CALL :t_print
LD_AL %display_color%
LDI_AH 0x20
LDI_C .tn_c31
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c32
CALL :t_print
LD_AL %display_color%
LDI_AH 0x08
LDI_C .tn_c32
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c33
CALL :t_print
LD_AL %display_color%
LDI_AH 0x28
LDI_C .tn_c33
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c34
CALL :t_print
LD_AL %display_color%
LDI_AH 0x02
LDI_C .tn_c34
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c35
CALL :t_print
LD_AL %display_color%
LDI_AH 0x22
LDI_C .tn_c35
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c36
CALL :t_print
LD_AL %display_color%
LDI_AH 0x0a
LDI_C .tn_c36
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c37
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_c37
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c90
CALL :t_print
LD_AL %display_color%
LDI_AH 0x15
LDI_C .tn_c90
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c91
CALL :t_print
LD_AL %display_color%
LDI_AH 0x30
LDI_C .tn_c91
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c92
CALL :t_print
LD_AL %display_color%
LDI_AH 0x0c
LDI_C .tn_c92
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c93
CALL :t_print
LD_AL %display_color%
LDI_AH 0x3c
LDI_C .tn_c93
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c94
CALL :t_print
LD_AL %display_color%
LDI_AH 0x03
LDI_C .tn_c94
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c95
CALL :t_print
LD_AL %display_color%
LDI_AH 0x33
LDI_C .tn_c95
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c96
CALL :t_print
LD_AL %display_color%
LDI_AH 0x0f
LDI_C .tn_c96
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_c97
CALL :t_print
LD_AL %display_color%
LDI_AH 0x3f
LDI_C .tn_c97
CALL :tt_assert_eq

# --- attributes: reset, bold upgrade, normal downgrade, blink on/off ---

CALL :t_cursor_init
ST $t_term_render_color 0x00
ST $t_term_current_color 0x15        # garbage baseline, distinct from 0x3f
LDI_C .seq_reset
CALL :t_print
LD_AL %display_color%
LDI_AH 0x3f
LDI_C .tn_reset
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_bold_red                  # ESC[1;31m -- bold applied after color
CALL :t_print
LD_AL %display_color%
LDI_AH 0x30
LDI_C .tn_bold_red
CALL :tt_assert_eq

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x30        # light red (shade-3 red)
LDI_C .seq_normal
CALL :t_print
LD_AL %display_color%
LDI_AH 0x20
LDI_C .tn_normal
CALL :tt_assert_eq

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a        # white, no blink
LDI_C .seq_blink_on
CALL :t_print
LD_AL %display_color%
LDI_AH 0xaa
LDI_C .tn_blink_on
CALL :tt_assert_eq

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0xaa        # white, blinking
LDI_C .seq_blink_off
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_blink_off
CALL :tt_assert_eq

# --- ignored codes leave the color untouched ---

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_ignored_reverse           # ESC[7m
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_ignored_reverse
CALL :tt_assert_eq

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_ignored_bg                # ESC[44m
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_ignored_bg
CALL :tt_assert_eq

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_ignored_defbg             # ESC[49m
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_ignored_defbg
CALL :tt_assert_eq

# --- 256-color quantization spot checks (2.2.3.1) ---

CALL :t_cursor_init
LDI_C .seq_256_1
CALL :t_print
LD_AL %display_color%
LDI_AH 0x20
LDI_C .tn_256_1
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_9
CALL :t_print
LD_AL %display_color%
LDI_AH 0x30
LDI_C .tn_256_9
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_16
CALL :t_print
LD_AL %display_color%
LDI_AH 0x00
LDI_C .tn_256_16
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_21
CALL :t_print
LD_AL %display_color%
LDI_AH 0x03
LDI_C .tn_256_21
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_110
CALL :t_print
LD_AL %display_color%
LDI_AH 0x1a
LDI_C .tn_256_110
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_196
CALL :t_print
LD_AL %display_color%
LDI_AH 0x30
LDI_C .tn_256_196
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_231
CALL :t_print
LD_AL %display_color%
LDI_AH 0x3f
LDI_C .tn_256_231
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_232
CALL :t_print
LD_AL %display_color%
LDI_AH 0x00
LDI_C .tn_256_232
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_244
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_256_244
CALL :tt_assert_eq

CALL :t_cursor_init
LDI_C .seq_256_255
CALL :t_print
LD_AL %display_color%
LDI_AH 0x3f
LDI_C .tn_256_255
CALL :tt_assert_eq

# --- 48;5;n (256-color background): parsed, no color change ---

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_256_bg
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_256_bg
CALL :tt_assert_eq
LD_AL %display_chars%
LDI_AH 'X'
LDI_C .tn_256_bg_char
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_ansi_state
LDI_C .tn_256_bg_state
CALL :tt_assert_eq

# --- combined: bold + 256-color (4 params) ---

CALL :t_cursor_init
LDI_C .seq_bold_256
CALL :t_print
LD_AL %display_color%
LDI_AH 0x34
LDI_C .tn_bold_256
CALL :tt_assert_eq

# --- 38;2 truecolor: silently discarded, color unchanged ---

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_truecolor
CALL :t_print
LD_AL %display_color%
LDI_AH 0x2a
LDI_C .tn_truecolor
CALL :tt_assert_eq
LD_AL %display_chars%
LDI_AH 'X'
LDI_C .tn_truecolor_char
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_ansi_state
LDI_C .tn_truecolor_state
CALL :tt_assert_eq

# --- 6-param overflow (38;5;n;48;5;n): flushed raw, color unchanged ---

CALL :t_cursor_init
ST $t_term_render_color 0x01
ST $t_term_current_color 0x2a
LDI_C .seq_overflow6
CALL :t_print
LD_AL %display_chars%
LDI_AH 0x1b
LDI_C .tn_overflow6_esc
CALL :tt_assert_eq
LD_AL $t_term_current_color
LDI_AH 0x2a
LDI_C .tn_overflow6_color
CALL :tt_assert_eq
LDI_AH 0x00
LD_AL $t_ansi_state
LDI_C .tn_overflow6_state
CALL :tt_assert_eq

CALL :tt_result
RET

.suite_name "sgr\0"

.seq_c30 0x1b "[30mX\0"
.seq_c31 0x1b "[31mX\0"
.seq_c32 0x1b "[32mX\0"
.seq_c33 0x1b "[33mX\0"
.seq_c34 0x1b "[34mX\0"
.seq_c35 0x1b "[35mX\0"
.seq_c36 0x1b "[36mX\0"
.seq_c37 0x1b "[37mX\0"
.seq_c90 0x1b "[90mX\0"
.seq_c91 0x1b "[91mX\0"
.seq_c92 0x1b "[92mX\0"
.seq_c93 0x1b "[93mX\0"
.seq_c94 0x1b "[94mX\0"
.seq_c95 0x1b "[95mX\0"
.seq_c96 0x1b "[96mX\0"
.seq_c97 0x1b "[97mX\0"
.seq_reset 0x1b "[0mX\0"
.seq_bold_red 0x1b "[1;31mX\0"
.seq_normal 0x1b "[22mX\0"
.seq_blink_on 0x1b "[5mX\0"
.seq_blink_off 0x1b "[25mX\0"
.seq_ignored_reverse 0x1b "[7mX\0"
.seq_ignored_bg 0x1b "[44mX\0"
.seq_ignored_defbg 0x1b "[49mX\0"
.seq_256_1 0x1b "[38;5;1mX\0"
.seq_256_9 0x1b "[38;5;9mX\0"
.seq_256_16 0x1b "[38;5;16mX\0"
.seq_256_21 0x1b "[38;5;21mX\0"
.seq_256_110 0x1b "[38;5;110mX\0"
.seq_256_196 0x1b "[38;5;196mX\0"
.seq_256_231 0x1b "[38;5;231mX\0"
.seq_256_232 0x1b "[38;5;232mX\0"
.seq_256_244 0x1b "[38;5;244mX\0"
.seq_256_255 0x1b "[38;5;255mX\0"
.seq_256_bg 0x1b "[48;5;9mX\0"
.seq_bold_256 0x1b "[1;38;5;208mX\0"
.seq_truecolor 0x1b "[38;2;255;0;0mX\0"
.seq_overflow6 0x1b "[38;5;208;48;5;22mX\0"

.tn_c30 "c30\0"
.tn_c31 "c31\0"
.tn_c32 "c32\0"
.tn_c33 "c33\0"
.tn_c34 "c34\0"
.tn_c35 "c35\0"
.tn_c36 "c36\0"
.tn_c37 "c37\0"
.tn_c90 "c90\0"
.tn_c91 "c91\0"
.tn_c92 "c92\0"
.tn_c93 "c93\0"
.tn_c94 "c94\0"
.tn_c95 "c95\0"
.tn_c96 "c96\0"
.tn_c97 "c97\0"
.tn_reset "reset\0"
.tn_bold_red "bold_red\0"
.tn_normal "normal\0"
.tn_blink_on "blink_on\0"
.tn_blink_off "blink_off\0"
.tn_ignored_reverse "ign_reverse\0"
.tn_ignored_bg "ign_bg\0"
.tn_ignored_defbg "ign_defbg\0"
.tn_256_1 "c256_1\0"
.tn_256_9 "c256_9\0"
.tn_256_16 "c256_16\0"
.tn_256_21 "c256_21\0"
.tn_256_110 "c256_110\0"
.tn_256_196 "c256_196\0"
.tn_256_231 "c256_231\0"
.tn_256_232 "c256_232\0"
.tn_256_244 "c256_244\0"
.tn_256_255 "c256_255\0"
.tn_256_bg "c256_bg\0"
.tn_256_bg_char "c256_bg_char\0"
.tn_256_bg_state "c256_bg_state\0"
.tn_bold_256 "bold_256\0"
.tn_truecolor "truecolor\0"
.tn_truecolor_char "truecolor_char\0"
.tn_truecolor_state "truecolor_state\0"
.tn_overflow6_esc "overflow6_esc\0"
.tn_overflow6_color "overflow6_color\0"
.tn_overflow6_state "overflow6_state\0"
