# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a simple '>' prompt and waits for input.
# The cursor turns into a red box while the CPU is busy sleeping (but still
# accepting keystrokes into the buffer).  When not sleeping, the buffer
# is flushed and keystrokes are printed to the screen.
#
# The C register is used as a global var and stores the current
# cursor location.  The D register stores the same location but
# in the color region of the display memory.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Put the initialization string on screen
LDI_C   .data0
LDI_D   %display_chars%
CALL :strcpy

# Initialize the keyboard
CALL :keyboard_init

# Track cursor position in regs C (char) and D (color)
LDI_C   %display_chars%
LDI_TD  '>'             # prompt character
STA_C_TD                # Write '>' to first byte
INCR_C                  # move cursor to the right
LDI_D   %display_color%+1
LDI_TD  %white%+%cursor%
STA_D_TD                # enable blinking cursor

#######
# Main loop
#######
LD_TD  %kb_key%         # clear any pending KB interrupt
ST16 %IRQ1addr%  :kb_irq_buf
UMASKINT                # Enable KB interrupt
.main_loop
# Put a red box over the current cursor location
LDI_TD  0xff
STA_C_TD
LDI_TD %red%+%cursor%
STA_D_TD
# Sleep for 1.5 seconds
LDI_AH 0x01 # BCD seconds
LDI_AL 0x50 # BCD subseconds
CALL :sleep
# Back from sleeping, process any buffered keystrokes
.buf_loop
CALL :kb_bufsize # bufsize into AL
ALUOP_FLAGS %A%+%AL%
JZ .main_loop
CALL :kb_readbuf
LDI_BH %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .buf_loop           # if a break event, ignore it and move on
ALUOP_ADDR_C %A%+%AL%   # put the key char at the current char address
LDI_TD %white%
STA_D_TD        # turn off the cursor and change to white
INCR_C
INCR_D
JMP .buf_loop
HLT

# Disabled IRQ handlers simply return without doing anything
.noirq
RETI

.data0 "Initializing...\0"
