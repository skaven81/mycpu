# vim: syntax=asm-mycpu

VAR global word $save_old_timer_isr

#### Begin the frame renderer
# Calling convention: no arguments, no return value.
# Installs a timer IRQ3 watchdog that fires at ~14fps and copies one
# extended-memory page to the framebuffer on each tick.
# Saves/restores AH, AL, CH, CL.
# Side effects: installs .frame_isr as IRQ3 vector, starts watchdog timer,
#   overwrites $save_old_timer_isr.
:start_frame_isr
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Mask interrupts while we set all this up
MASKINT

# Save the current IRQ3 vector
LD_CH %IRQ3addr%
LD_CL %IRQ3addr%+1
ST_CH $save_old_timer_isr
ST_CL $save_old_timer_isr+1

# Set the frame renderer as the IRQ3 vector
ST16 %IRQ3addr% .frame_isr

# Start the timer
LDI_AH 0x00 # BCD seconds
LDI_AL 0x07 # BCD subseconds (0.07 sec, 14fps)
CALL :timer_set_watchdog

UMASKINT

POP_CL
POP_CH
POP_AL
POP_AH
RET

#### Stop the frame renderer
# Calling convention: no arguments, no return value.
# Disables the watchdog timer and restores the previous IRQ3 vector.
# Saves/restores CH, CL.
# Side effects: stops watchdog timer, restores IRQ3 vector from $save_old_timer_isr.
:stop_frame_isr
PUSH_CH
PUSH_CL

MASKINT

# Disable the watchdog timer interrupt
CALL :timer_set_idle

# Restore the old IRQ3 vector
LD_CH $save_old_timer_isr
LD_CL $save_old_timer_isr+1
ST_CH %IRQ3addr%
ST_CL %IRQ3addr%+1

UMASKINT

POP_CL
POP_CH
RET

#### Frame renderer IRQ vector
# Save E page, set E page to $ring_read_page.
# Copy frame data from the E page to either character memory (ASCII mode, 0x4000)
# or color memory (color mode, 0x5000) based on $color_mode.
# Restore E page (in case BIOS was using it e.g. fat16_next_cluster).
# Streaming mode ($loop_mode=0): increment $ring_read_page (rollover 0xFF->0x06),
#   decrement $frames_in_buffer.
# Loop mode ($loop_mode=1): advance $ring_read_page; when $frames_until_wrap reaches
#   zero, reset to page 0x06 and decrement $loops_remaining.  When $loops_remaining
#   reaches zero, set $frames_in_buffer=0 to signal completion to the main loop.
.frame_isr
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Check if $ring_read_page is valid (> 0 frames in buffer)
LD_AL $frames_in_buffer
ALUOP_FLAGS %A%+%AL%
JZ .isr_exit                # do nothing if no frames in buffer

# Save current E page (BIOS functions like fat16_next_cluster may be using it)
LD_AL %e_page%
ALUOP_ADDR %A%+%AL% $isr_saved_e_page

# Set E page to $ring_read_page
LD_AL $ring_read_page
ALUOP_ADDR %A%+%AL% %e_page%

# Copy data to framebuffer. Destination depends on $color_mode:
#   color_mode=0: copy to character memory at 0x4000 (ASCII video)
#   color_mode=1: copy to color memory at 0x5000 (color video)
LDI_C 0xe000                # source address
LD_AL $color_mode
ALUOP_FLAGS %A%+%AL%
JZ .ascii_dest
LDI_D %display_color%       # color mode: color framebuffer (0x5000)
JMP .start_copy
.ascii_dest
LDI_D %display_chars%       # ascii mode: character framebuffer
.start_copy
LD_AL $frame_segments       # N-1 128-byte segments (set from frame 0 file size)
CALL :memcpy_segments

# Restore E page so BIOS functions can continue using it
LD_AL $isr_saved_e_page
ALUOP_ADDR %A%+%AL% %e_page%

# Manage $ring_read_page and buffer accounting (behavior differs by mode)
LD_AL $loop_mode
ALUOP_FLAGS %A%+%AL%
JNZ .loop_advance

# Streaming mode: increment $ring_read_page with byte-overflow rollover to 0x06,
# then decrement $frames_in_buffer to reflect one frame consumed from the ring buffer.
LD_AL $ring_read_page
ALUOP_AL %A+1%+%AL%
JNO .streaming_no_overflow
LDI_AL 0x06                 # rollover from 0xFF to 0x06
.streaming_no_overflow
ALUOP_ADDR %A%+%AL% $ring_read_page
LD_AL $frames_in_buffer
ALUOP_ADDR %A-1%+%AL% $frames_in_buffer
JMP .advance_done

# Loop mode: $frames_until_wrap counts down frames within one loop pass.
# When it hits zero we've completed one pass: decrement $loops_remaining and
# either reset for the next pass or signal done via $frames_in_buffer=0.
.loop_advance
LD_AL $frames_until_wrap
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% $frames_until_wrap
JNZ .loop_normal_advance    # Z=0: still frames left in this pass, just advance

# End of one loop pass: decrement loops_remaining
LD_AL $loops_remaining
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% $loops_remaining
JNZ .loop_more_passes       # Z=0: more passes remain, reset ring and counter

# All loops done: signal completion to main loop
ALUOP_ADDR %zero% $frames_in_buffer
JMP .advance_done

.loop_more_passes
# Reset ring_read_page to first frame page and reload per-loop frame counter
LDI_AL 0x06
ALUOP_ADDR %A%+%AL% $ring_read_page
LD_AL $frames_per_loop
ALUOP_ADDR %A%+%AL% $frames_until_wrap
JMP .advance_done

.loop_normal_advance
# Not at loop boundary: advance ring_read_page to next frame page
LD_AL $ring_read_page
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $ring_read_page

.advance_done
# Increment $playback_frame
LD_DH $playback_frame
LD_DL $playback_frame+1
INCR_D
ST_DH $playback_frame
ST_DL $playback_frame+1

.isr_exit
# Clear interrupt timer and re-arm for next frame.
# timer_set_watchdog uses AH/AL directly (no heap) so it is
# safe to call from within an ISR.
LD_TD %tmr_ctrl_a%
LDI_AH 0x00 # BCD seconds
LDI_AL 0x07 # BCD subseconds (0.07 sec, 14fps)
CALL :timer_set_watchdog

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
RETI
