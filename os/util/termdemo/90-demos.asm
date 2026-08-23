# vim: syntax=asm-mycpu

# Visual demos + throughput benchmark for the new terminal I/O library
# (TERMINAL_REFACTOR.md 2.2.3 color tables, 2.3.1 perf goal). Unlike the
# test suites, these are not self-checking -- they exist to be screencapped
# (`odyctl screencap`) and eyeballed, and to report PERF lines over the
# same UART wire the test suites use. Never promoted to the BIOS; this file
# stays a label-data scratch file like the rest of the harness.
#
# Demo screens pause via the ROM's :sleep so a human/agent has time to
# capture each one before the next overwrites it.

######
# Runs all four demo screens, then the print-throughput benchmark.
:demos_run
CALL :t_ansi_reset
ST $t_term_flags 0x02                # ANSI on, raw off -- baseline for demos

CALL .demo_colors16
CALL .demo_grid256
CALL .demo_attrs
CALL .demo_edges

CALL .bench_run
RET

######
# Demo 1: the 16 base SGR colors (30-37, 90-97), each printed with its
# code and name.
.demo_colors16
CALL :t_cursor_init
CALL :t_cursor_off                    # static demo screen: no blinking
                                       # cursor, and no cursor-bit artifacts
                                       # left behind when jumping between
                                       # disjoint screen regions (the cursor
                                       # bit is baked into the color plane
                                       # by :t_cursor_display_sync -- it is
                                       # not a transient render-time overlay,
                                       # so leaving it on and moving away
                                       # from a synced position leaves a
                                       # permanent stray mark there)
ST $t_term_flags 0x02
LDI_C .d1_clear
CALL :t_print

LDI_C .d1_title
CALL :t_print
LDI_C .d1_c30
CALL :t_print
LDI_C .d1_c31
CALL :t_print
LDI_C .d1_c32
CALL :t_print
LDI_C .d1_c33
CALL :t_print
LDI_C .d1_c34
CALL :t_print
LDI_C .d1_c35
CALL :t_print
LDI_C .d1_c36
CALL :t_print
LDI_C .d1_c37
CALL :t_print
LDI_C .d1_c90
CALL :t_print
LDI_C .d1_c91
CALL :t_print
LDI_C .d1_c92
CALL :t_print
LDI_C .d1_c93
CALL :t_print
LDI_C .d1_c94
CALL :t_print
LDI_C .d1_c95
CALL :t_print
LDI_C .d1_c96
CALL :t_print
LDI_C .d1_c97
CALL :t_print
LDI_C .d1_reset
CALL :t_print

LDI_AH 0x08                   # BCD seconds
LDI_AL 0x00                   # BCD subseconds
CALL :heap_push_AH
CALL :heap_push_AL
CALL :sleep
RET

######
# Demo 2: 256-color grid -- 16x16 cells of ESC[38;5;Nm + block glyph 0xDB,
# n = row*16+col running 0..255.
.demo_grid256
CALL :t_cursor_init
CALL :t_cursor_off                    # static demo screen: no blinking
                                       # cursor, and no cursor-bit artifacts
                                       # left behind when jumping between
                                       # disjoint screen regions (the cursor
                                       # bit is baked into the color plane
                                       # by :t_cursor_display_sync -- it is
                                       # not a transient render-time overlay,
                                       # so leaving it on and moving away
                                       # from a synced position leaves a
                                       # permanent stray mark there)
ST $t_term_flags 0x02
LDI_C .d1_clear
CALL :t_print
LDI_C .d2_title
CALL :t_print

ST .d2_row 0x00
.d2_row_loop
ST .d2_col 0x00
.d2_col_loop
LD_AL .d2_row
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%          # AL = row * 16
LD_BL .d2_col
ALUOP_AL %A+B%+%AL%+%BL%      # AL = row*16 + col = n (0-255)
CALL :heap_push_AL
LDI_C .d2_fmt
CALL :t_printf

LDI_AL 0xdb                   # CP437 full-block glyph
CALL :t_putchar

LD_AL .d2_col
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .d2_col
LDI_BL 16
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .d2_col_loop

LDI_AL 0x0a                   # newline: next row, col 0
CALL :t_putchar

LD_AL .d2_row
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .d2_row
LDI_BL 16
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .d2_row_loop

LDI_C .d1_reset
CALL :t_print
LDI_AH 0x08                   # BCD seconds
LDI_AL 0x00                   # BCD subseconds
CALL :heap_push_AH
CALL :heap_push_AL
CALL :sleep
RET

######
# Demo 3: attribute sampler (bold upgrade/downgrade, blink on/off, reset).
.demo_attrs
CALL :t_cursor_init
CALL :t_cursor_off                    # static demo screen: no blinking
                                       # cursor, and no cursor-bit artifacts
                                       # left behind when jumping between
                                       # disjoint screen regions (the cursor
                                       # bit is baked into the color plane
                                       # by :t_cursor_display_sync -- it is
                                       # not a transient render-time overlay,
                                       # so leaving it on and moving away
                                       # from a synced position leaves a
                                       # permanent stray mark there)
ST $t_term_flags 0x02
LDI_C .d1_clear
CALL :t_print

LDI_C .d3_title
CALL :t_print
LDI_C .d3_normal
CALL :t_print
LDI_C .d3_bold
CALL :t_print
LDI_C .d3_downgrade
CALL :t_print
LDI_C .d3_blink_on
CALL :t_print
LDI_C .d3_blink_off
CALL :t_print
LDI_C .d3_bold_yellow
CALL :t_print
LDI_C .d1_reset
CALL :t_print

LDI_AH 0x08                   # BCD seconds
LDI_AL 0x00                   # BCD subseconds
CALL :heap_push_AH
CALL :heap_push_AL
CALL :sleep
RET

######
# Demo 4: the 4 right-edge behavior combos (flags bits 2-3), each printed
# as a labeled row + 8 letters starting at col 58 so the edge crossing
# (col 63 -> col 64) is visible on screen.
.demo_edges
CALL :t_cursor_init
CALL :t_cursor_off                    # static demo screen: no blinking
                                       # cursor, and no cursor-bit artifacts
                                       # left behind when jumping between
                                       # disjoint screen regions (the cursor
                                       # bit is baked into the color plane
                                       # by :t_cursor_display_sync -- it is
                                       # not a transient render-time overlay,
                                       # so leaving it on and moving away
                                       # from a synced position leaves a
                                       # permanent stray mark there)
ST $t_term_flags 0x02
LDI_C .d1_clear
CALL :t_print
LDI_C .d4_title
CALL :t_print

# --- combo A: flags=0x02 (wrap, newline) ---
LDI_AH 0x02
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .d4_label_a
CALL :t_print
ST $t_term_flags 0x02
LDI_AH 0x03
LDI_AL 0x3a
CALL :t_cursor_goto_rowcol
LDI_C .d4_letters
CALL :t_print

# --- combo B: flags=0x06 (no-wrap, newline) ---
ST $t_term_flags 0x02
LDI_AH 0x05
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .d4_label_b
CALL :t_print
ST $t_term_flags 0x06
LDI_AH 0x06
LDI_AL 0x3a
CALL :t_cursor_goto_rowcol
LDI_C .d4_letters
CALL :t_print

# --- combo C: flags=0x0a (wrap, no-newline) ---
ST $t_term_flags 0x02
LDI_AH 0x09
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .d4_label_c
CALL :t_print
ST $t_term_flags 0x0a
LDI_AH 0x0a
LDI_AL 0x3a
CALL :t_cursor_goto_rowcol
LDI_C .d4_letters
CALL :t_print

# --- combo D: flags=0x0e (no-wrap, no-newline) ---
ST $t_term_flags 0x02
LDI_AH 0x0c
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
LDI_C .d4_label_d
CALL :t_print
ST $t_term_flags 0x0e
LDI_AH 0x0d
LDI_AL 0x3a
CALL :t_cursor_goto_rowcol
LDI_C .d4_letters
CALL :t_print

ST $t_term_flags 0x02                # leave flags sane for anything after
LDI_AH 0x08                   # BCD seconds
LDI_AL 0x00                   # BCD subseconds
CALL :heap_push_AH
CALL :heap_push_AL
CALL :sleep
RET

######
# Print-throughput benchmark: repeatedly prints a fixed 40-char line for a
# fixed 2-second window (same "count reps in a fixed real-time window"
# idiom as os/util/fps/00-cmd_fps.asm -- a direct "time N chars" measurement
# would round to 0 or 1 elapsed RTC second at this CPU's speed and be
# useless data). Reports "PERF <name> <chars> <secs>\n" per candidate over
# the UART, same wire as the TT harness but not part of its protocol.
.bench_run
CALL :cursor_init
LDI_AH 0x00
LDI_AL %white%
CALL :clear_screen
ST .bench_chars 0x00
ST .bench_chars+1 0x00
CALL .bench_arm_timer
.bench_rom_loop
LDI_C .bench_line
CALL :print
CALL .bench_add40
LD_AL .bench_timer_flag
ALUOP_FLAGS %A%+%AL%
JZ .bench_rom_loop
LDI_C .bench_name_rom
CALL .bench_report

CALL :t_cursor_init
ST $t_term_flags 0x00                # fast path, no ANSI/raw
ST $t_term_render_color 0x00
LDI_AH 0x00
LDI_AL %white%
CALL :clear_screen
ST .bench_chars 0x00
ST .bench_chars+1 0x00
CALL .bench_arm_timer
.bench_tprint_loop
LDI_C .bench_line
CALL :t_print
CALL .bench_add40
LD_AL .bench_timer_flag
ALUOP_FLAGS %A%+%AL%
JZ .bench_tprint_loop
LDI_C .bench_name_tprint
CALL .bench_report

CALL :t_cursor_init
ST $t_term_flags 0x00
LDI_AH 0x00
LDI_AL %white%
CALL :clear_screen
ST .bench_chars 0x00
ST .bench_chars+1 0x00
CALL .bench_arm_timer
.bench_traw_loop
LDI_C .bench_line
CALL :t_print_raw
CALL .bench_add40
LD_AL .bench_timer_flag
ALUOP_FLAGS %A%+%AL%
JZ .bench_traw_loop
LDI_C .bench_name_traw
CALL .bench_report

LDI_AH 0x00
LDI_AL %white%
CALL :clear_screen
CALL :cursor_init
RET

######
# Adds the fixed 40-char line length to the running .bench_chars counter.
# .bench_chars is a 16-bit unsigned counter with no overflow check -- it
# would wrap past 65535 if a 2-second window printed >32K chars. Measured
# hardware throughput for the fastest candidate (t_print_raw) is ~5380
# chars/sec (10760 chars/2sec), roughly 6x below that ceiling, so this is
# a real but not currently reachable gap; revisit if a much faster print
# path is ever benchmarked here.
.bench_add40
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD_AH .bench_chars
LD_AL .bench_chars+1
LDI_B 0x0028                  # 40
ALUOP16O_A %ALU16_A+B%
ALUOP_ADDR %A%+%AH% .bench_chars
ALUOP_ADDR %A%+%AL% .bench_chars+1
POP_BL
POP_BH
RET

######
# Arms a 2-second one-shot watchdog on IRQ3 and clears .bench_timer_flag.
# Same pattern as os/util/fps/00-cmd_fps.asm's .start_1sec_timer.
.bench_arm_timer
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
MASKINT
ST16 %IRQ3addr% .bench_timeout
ST .bench_timer_flag 0x00
LD_TD %tmr_ctrl_a%            # clear any pending timer interrupt first
LDI_AH 0x02                   # BCD seconds
LDI_AL 0x00                   # BCD subseconds
CALL :timer_set_watchdog
UMASKINT
POP_AL
POP_AH
RET

.bench_timeout
ST .bench_timer_flag 0x01
CALL :timer_set_idle
ST16 %IRQ3addr% :timer_clear_irq
RETI

######
# Formats and sends "PERF <name> <chars> <secs>\n" over the UART.
#
# Inputs:
#  C - address of candidate name string
.bench_report
PUSH_CH
PUSH_CL
LDI_AL 0x02                   # fixed benchmark duration (see .bench_arm_timer)
CALL :heap_push_AL
LD_AH .bench_chars
LD_AL .bench_chars+1
CALL :heap_push_A
POP_CL
POP_CH
CALL :heap_push_C
LDI_C .perf_fmt
LDI_D .perf_scratch
CALL :sprintf
LDI_C .perf_scratch
CALL :ser_puts
RET

.d1_clear 0x1b "[2J\0"
.d1_title "16-color strip (SGR 30-37, 90-97)\n\n\0"
.d1_c30 0x1b "[30m30 black\n\0"
.d1_c31 0x1b "[31m31 red\n\0"
.d1_c32 0x1b "[32m32 green\n\0"
.d1_c33 0x1b "[33m33 yellow\n\0"
.d1_c34 0x1b "[34m34 blue\n\0"
.d1_c35 0x1b "[35m35 magenta\n\0"
.d1_c36 0x1b "[36m36 cyan\n\0"
.d1_c37 0x1b "[37m37 white\n\0"
.d1_c90 0x1b "[90m90 bright black\n\0"
.d1_c91 0x1b "[91m91 bright red\n\0"
.d1_c92 0x1b "[92m92 bright green\n\0"
.d1_c93 0x1b "[93m93 bright yellow\n\0"
.d1_c94 0x1b "[94m94 bright blue\n\0"
.d1_c95 0x1b "[95m95 bright magenta\n\0"
.d1_c96 0x1b "[96m96 bright cyan\n\0"
.d1_c97 0x1b "[97m97 bright white\n\0"
.d1_reset 0x1b "[0m\0"

.d2_title "256-color grid (ESC[38;5;nm), n=0..255, row-major\n\0"
.d2_fmt 0x1b "[38;5;%um\0"
.d2_row "\0"
.d2_col "\0"

.d3_title "Attribute sampler\n\n\0"
.d3_normal 0x1b "[0mnormal (reset)\n\0"
.d3_bold 0x1b "[1mbold (attribute 1)\n\0"
.d3_downgrade 0x1b "[22mnormal again (attribute 22)\n\0"
.d3_blink_on 0x1b "[5mblinking (attribute 5)\n\0"
.d3_blink_off 0x1b "[25mblink off (attribute 25)\n\0"
.d3_bold_yellow 0x1b "[1;33mbold yellow (1;33)\n\0"

.d4_title "Right-edge behavior (flags bits 2-3): letters start at col 58\n\n\0"
.d4_label_a "combo A flags=0x02: wrap, newline\n\0"
.d4_label_b "combo B flags=0x06: no-wrap, newline\n\0"
.d4_label_c "combo C flags=0x0a: wrap, no-newline\n\0"
.d4_label_d "combo D flags=0x0e: no-wrap, no-newline\n\0"
.d4_letters "ABCDEFGH\0"

.bench_line "The quick brown fox jumps over 123456789\0"
.bench_chars "\0\0"
.bench_timer_flag "\0"
.bench_name_rom "rom_print\0"
.bench_name_tprint "t_print\0"
.bench_name_traw "t_print_raw\0"
.perf_fmt "PERF %s %U %u\n\0"
.perf_scratch "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
