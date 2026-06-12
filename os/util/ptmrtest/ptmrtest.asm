# vim: syntax=asm-mycpu

# Programmable Timer Test Utility
#
# Exercises all three programmable timers (IRQ2) plus the RTC watchdog
# (IRQ3) concurrently.  Two clock sources and both modes are exercised:
#
#   T0: mode 2 @ 32.768 kHz  (self-reloading; no handler reload needed)
#   T1: mode 0 @ 32.768 kHz  (one-shot; handler reloads count each fire)
#   T2: mode 2 @ 1.000 MHz   (self-reloading; different clock from T0/T1)
#
# Each timer's per-timer ISR moves its character one column right
# (wrapping back to column 0 after the row end).  The RTC watchdog
# fires after 10 seconds and signals the main loop to clean up and exit.
#
# Typical invocation: ptmrtest 3277 3277 50000
#   At those counts T0 and T1 fire at ~10 Hz, T2 at ~20 Hz.
#
# Usage: ptmrtest <count0> <count1> <count2>
#   countN is the 16-bit initial count for timer N.

:cmd_ptmrtest
JMP .run_program

.start_prog_mark
CALL :trace_begin
RET

.run_program
# --- Argument parsing ---
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                                # 4 blocks = 64 bytes
CALL :memcpy_blocks

# Validate argv[1] non-null (high byte of pointer != 0)
LD_AH .argv_buf+2
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Validate argv[2] non-null
LD_AH .argv_buf+4
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Validate argv[3] non-null
LD_AH .argv_buf+6
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Parse argv[1] -> $t0_count
LDI_A .argv_buf+2
LDA_A_CH
LDI_A .argv_buf+3
LDA_A_CL
CALL :strtoi
ALUOP_FLAGS %B%+%BL%
JNZ .usage
ALUOP_ADDR %A%+%AH% $t0_count
ALUOP_ADDR %A%+%AL% $t0_count+1

# Parse argv[2] -> $t1_count
LDI_A .argv_buf+4
LDA_A_CH
LDI_A .argv_buf+5
LDA_A_CL
CALL :strtoi
ALUOP_FLAGS %B%+%BL%
JNZ .usage
ALUOP_ADDR %A%+%AH% $t1_count
ALUOP_ADDR %A%+%AL% $t1_count+1

# Parse argv[3] -> $t2_count
LDI_A .argv_buf+6
LDA_A_CH
LDI_A .argv_buf+7
LDA_A_CL
CALL :strtoi
ALUOP_FLAGS %B%+%BL%
JNZ .usage
ALUOP_ADDR %A%+%AH% $t2_count
ALUOP_ADDR %A%+%AL% $t2_count+1

# --- Screen initialization ---
LDI_AH 0x00                             # fill char: space
LDI_AL %white%                          # color
CALL :clear_screen

# Print start and end debug markers
LDI_A 0x0f00 # row 16, col 0
CALL :cursor_goto_rowcol
CALL .start_prog_mark
CALL .end_prog_mark

# Initialize tracking state
ST16 $t0_col 0x4000
ST16 $t1_col 0x4100
ST16 $t2_col 0x4200
ST $done_flag 0x00

# Place numbers in initial positions
ST 0x4000 '0'
ST 0x4100 '1'
ST 0x4200 '2'

# --- Timer setup (interrupts masked during configuration) ---
MASKINT

# Clock select: T0 and T1 at 32.768 kHz, T2 at 1.000 MHz
ST %ptmr_clk_sel%   %ptmr_clk_tmr0_32k%|%ptmr_clk_tmr1_32k%|%ptmr_clk_tmr2_10M%
ST $ptmr_clk_select %ptmr_clk_tmr0_32k%|%ptmr_clk_tmr1_32k%|%ptmr_clk_tmr2_10M%

# Control words.  Mode 0 idle drives OUT low; mode 2 idle drives OUT
# high.  The T0/T2 mode-2 control-word writes generate rising edges on
# their OUT pins, arming their IRQ latches.  The %ptmr_clr_all_irq%
# write below clears those stale latches before UMASKINT.
ST %ptmr_ctrl_write% %ptmr_cw_t0_mode2%
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode2%

# Install per-timer handlers in the BIOS dispatch table
ST16 $ptmr_t0_handler .t0_isr_handler
ST16 $ptmr_t1_handler .t1_isr_handler
ST16 $ptmr_t2_handler .t2_isr_handler

# Write counts (LSB then MSB) to start each counter
LD_AL $t0_count+1
ALUOP_ADDR %A%+%AL% %ptmr_counter0%
LD_AL $t0_count
ALUOP_ADDR %A%+%AL% %ptmr_counter0%

LD_AL $t1_count+1
ALUOP_ADDR %A%+%AL% %ptmr_counter1%
LD_AL $t1_count
ALUOP_ADDR %A%+%AL% %ptmr_counter1%

LD_AL $t2_count+1
ALUOP_ADDR %A%+%AL% %ptmr_counter2%
LD_AL $t2_count
ALUOP_ADDR %A%+%AL% %ptmr_counter2%

# Clear any stale latches that may have been set during setup
ST %ptmr_clr_all_irq% 0x00

# Save the BIOS IRQ3 vector and install our watchdog handler
LD_DH %IRQ3addr%
LD_DL %IRQ3addr%+1
PUSH_DH
PUSH_DL
ST16 %IRQ3addr% .watchdog_isr

# Clear any pending RTC IRQ before arming
LD_TD %tmr_ctrl_a%

# Arm the 10-second one-shot watchdog
LDI_AH 0x10                             # BCD seconds = 10
LDI_AL 0x00                             # BCD subseconds = 00
CALL :timer_set_watchdog

UMASKINT

# --- Main wait loop ---
LDI_D 0x4d00
LDI_BL '#'
.main_loop
ALUOP_ADDR_D %B%+%BL%
INCR_D
MOV_DL_AL
ALUOP_FLAGS %A%+%AL%
JNZ .notoggle
LDI_D 0x4d00
ALUOP_BL %B+1%+%BL%
.notoggle
LD_AL $done_flag
ALUOP_FLAGS %A%+%AL%
JZ .main_loop

# --- Cleanup ---
.cleanup
MASKINT

# Restore per-timer dispatch to the no-op stub so any
# spurious IRQ2 is a CALL_D into a 2-cycle RET (the
# dispatcher no longer skips on handler==0x0000).
ST16 $ptmr_t0_handler :ptmr_noop_handler
ST16 $ptmr_t1_handler :ptmr_noop_handler
ST16 $ptmr_t2_handler :ptmr_noop_handler

# Idle all programmable timers
ST %ptmr_ctrl_write% %ptmr_cw_t0_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%
ST %ptmr_clr_all_irq% 0x00

# Restore the BIOS default clock select (1 MHz on all three) and shadow
ST %ptmr_clk_sel%   %ptmr_clk_tmr0_10M%|%ptmr_clk_tmr1_10M%|%ptmr_clk_tmr2_10M%
ST $ptmr_clk_select %ptmr_clk_tmr0_10M%|%ptmr_clk_tmr1_10M%|%ptmr_clk_tmr2_10M%

# Stop the RTC watchdog
CALL :timer_set_idle

# Restore the BIOS IRQ3 vector
POP_DL
POP_DH
ST_DH %IRQ3addr%
ST_DL %IRQ3addr%+1

UMASKINT

LDI_A 0x0000
CALL :heap_push_A
RET

# --- Error path ---
.usage
LDI_C .usage_str
CALL :print
LDI_A 0x0001
CALL :heap_push_A
RET

# ====================================================================
# Watchdog ISR (IRQ3, full ISR -> RETI)
# ====================================================================
.watchdog_isr
LD_TD %tmr_ctrl_a%                      # clear IRQ3
ST %tmr_ctrl_b% %tmr_TE_mask%           # also drop WDE so timer fully stops
ST $done_flag 0x01
ST 0x4000 'W'                           # indicate that the watchdog timer fired
RETI

# ====================================================================
# Per-timer handlers (called from :ptmr_isr_std via CALL_D, end with RET)
#
# Odyssey calling convention: every function (including these handlers)
# must preserve every register it modifies.  The dispatcher relies on
# this; in particular it parks the IRQ latch snapshot in AL across
# CALL_D, so handlers MUST save and restore AL even though it looks
# unused on entry.  Each handler below modifies AL, CH, and CL and
# saves/restores those three registers.
# ====================================================================

# --- Timer 0 handler: base 0x4000, char '0', Mode 2 @ 32 kHz -> no reload
.t0_isr_handler
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Erase character at OLD column position
LD_CH $t0_col
LD_CL $t0_col+1
LDI_AL ' '
ALUOP_ADDR_C %A%+%AL%

# Increment column
INCR_C
LD_CH $t0_col
ST_CL $t0_col+1

# Write character at NEW column position
LDI_AL '0'
ALUOP_ADDR_C %A%+%AL%

# Mode 2: no reload required, hardware reloads the counter.

POP_CL
POP_CH
POP_AL
RET

# --- Timer 1 handler: base 0x4100, char '1', Mode 0 @ 32 kHz -> handler reloads count
.t1_isr_handler
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Erase character at OLD column position
LD_CH $t1_col
LD_CL $t1_col+1
LDI_AL ' '
ALUOP_ADDR_C %A%+%AL%

# Increment column
INCR_C
LD_CH $t1_col
ST_CL $t1_col+1

# Write character at NEW column position
LDI_AL '1'
ALUOP_ADDR_C %A%+%AL%

# Mode 0: reload count so the timer fires again
LD_AL $t1_count+1
ALUOP_ADDR %A%+%AL% %ptmr_counter1%
LD_AL $t1_count
ALUOP_ADDR %A%+%AL% %ptmr_counter1%

POP_CL
POP_CH
POP_AL
RET

# --- Timer 2 handler: base 0x4200, char '2', Mode 2 @ 1 MHz -> no reload
.t2_isr_handler
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Erase character at OLD column position
LD_CH $t2_col
LD_CL $t2_col+1
LDI_AL ' '
ALUOP_ADDR_C %A%+%AL%

# Increment column
INCR_C
LD_CH $t2_col
ST_CL $t2_col+1

# Write character at NEW column position
LDI_AL '2'
ALUOP_ADDR_C %A%+%AL%

# Mode 2: hardware reloads automatically, no handler action needed.

POP_CL
POP_CH
POP_AL
RET

# ====================================================================
# Static data
# ====================================================================
.usage_str "Usage: ptmrtest <count0> <count1> <count2>\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

# ====================================================================
# Variable declarations (allocated in hidden framebuffer global area)
# ====================================================================
VAR global word $t0_count
VAR global word $t1_count
VAR global word $t2_count
VAR global word $t0_col
VAR global word $t1_col
VAR global word $t2_col
VAR global byte $done_flag

.end_prog_mark
CALL :trace_end
RET
