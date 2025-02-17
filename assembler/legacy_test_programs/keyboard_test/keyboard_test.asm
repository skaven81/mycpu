# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a simple '>' prompt with
# blinking cursor, and prints characters as they are
# typed on the keyboard.
#
# The C register is used as a global var and stores the current
# cursor location.  The D register stores the same location but
# in the color region of the display memory.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  .irq1
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  .noirq
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

# The ATTiny takes ~75ms to initialize the keyboard.
# We sleep for >100ms to give it plenty of time.
LDI_A   0xffff
.kb_wait_loop
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
ALUOP_AL %A-1%+%AL%     # 4 clocks # 32 total
JNZ .kb_wait_loop
ALUOP_AH %A-1%+%AH%
JNZ .kb_wait_loop

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Track cursor position in regs C (char) and D (color)
LDI_C   %display_chars%
LDI_TD  '>'             # prompt character
STA_C_TD                # Write '>' to first byte
INCR_C                  # move cursor to the right
LDI_D   %display_color%+1
LDI_TD  %white%+%blink%+%cursor%
STA_D_TD                # enable blinking cursor


#######
# Main loop
#######
LD_TD  %kb_key%         # clear any pending KB interrupt
UMASKINT                # Enable KB interrupt
.main_loop
JMP .main_loop
HLT

#######
# IRQ handler
#######
.irq1
ALUOP_PUSH %A%+%AL%                     # we're going to use AL and BL to inspect the
ALUOP_PUSH %B%+%BL%                     # KB flags register

LD_AL %kb_keyflags%
LDI_BL %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .endirq1                            # Skip the rest of the IRQ handler if this
                                        # was a break event (nonzero)

LDI_TD  %white%                         # disable blinking cursor in current position
STA_D_TD
INCR_D                                  # move the color position to the right

LD_TD  %kb_key%                         # fetch the keystroke into TD
STA_C_TD                                # write TD to the current cursor position
INCR_C                                  # move char cursor to the right

LDI_TD  %white%+%blink%+%cursor%        # enable blinking cursor in next position
STA_D_TD
.endirq1
POP_BL                                  # restore registers we pushed at the
POP_AL                                  # beginning of the IRQ handler
RETI

# Disabled IRQ handlers simply return without doing anything
.noirq
RETI

.data0 "Waiting for KB controller...\0"
