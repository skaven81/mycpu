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
# Save E page, set E page to $ring_read_page
# Copy frame data from the E page to either character memory (ASCII mode, 0x4000)
# or color memory (color mode, 0x5000) based on $color_mode.
# Restore E page (in case BIOS was using it e.g. fat16_next_cluster)
# Increment $ring_read_page (rollover to 0x06 if rolls to zero)
# Decrement $frames_in_buffer
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

# Increment $ring_read_page
LD_AL $ring_read_page
ALUOP_AL %A+1%+%AL%
JNO .no_overflow
LDI_AL 0x06                 # rollover to 0x06
.no_overflow
ALUOP_ADDR %A%+%AL% $ring_read_page

# Decrement $frames_in_buffer
LD_AL $frames_in_buffer
ALUOP_ADDR %A-1%+%AL% $frames_in_buffer

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
