# vim: syntax=asm-mycpu

VAR global byte $timer_flag

# Test #1: MEMFILL
CALL .start_1sec_timer
LDI_AH 0x00                 # character we are filling
LDI_B 0x0000                # we will store frame count in B
.memfill_loop
LDI_C %display_chars%
ALUOP_AH %A+1%+%AH%
LDI_AL 29                   # 30 128 byte segments  -> 60 lines
CALL :memfill_segments
LD_AL $timer_flag           # check if timer expired during this fill
ALUOP_FLAGS %A%+%AL%
JNZ .memfill_loop_done      # If so, don't count this as a completed frame and exit the loop
CALL :incr16_b
JMP .memfill_loop

.memfill_loop_done
LDI_AH 0x00         # char to fill
LDI_AL %white%      # color to fille
CALL :clear_screen
CALL :cursor_init
CALL :cursor_display_sync   # reset cursor to 0,0
CALL :heap_push_B
LDI_C .memfill_str
CALL :printf

# Test #2: MEMCPY4_C_D

# Test #3: Procedural generation

RET

.memfill_str "MEMFILL: %U frames in 1 second\n\0"

.timeout
ST $timer_flag 0x01
CALL :timer_set_idle
ST16    %IRQ3addr%  :timer_clear_irq
RETI

.start_1sec_timer
MASKINT
ST16    %IRQ3addr%  .timeout
ST $timer_flag 0x00
LDI_AL 0x01     # seconds
CALL :heap_push_AL
LDI_AL 0x00     # subseconds
CALL :heap_push_AL
CALL :timer_set_watchdog
UMASKINT
RET
