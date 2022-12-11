# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a blinking cursor, which can be moved
# around the screen using the arrow keys on the keyboard.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  .noirq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  .noirq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0xff     # char to clear screen with
LDI_AL  %red%
CALL :clear_screen

# Initialize the keyboard
CALL :keyboard_init

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Initialize the cursor at 0,0
CALL :cursor_init
CALL :cursor_display_sync

# Setup the keyboard handler
LD_TD  %kb_key%         # clear any pending KB interrupt
ST16    %IRQ1addr%  .irq1_kb
UMASKINT

#######
# Main loop
#######
.main_loop
JMP .main_loop
HLT

#######
# IRQ1 handler (keyboard)
#######
.irq1_kb
LD_AL   %kb_keyflags%   # clear interrupt
LDI_BL  %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .irq1_done          # we only care about make events
LD_AL   %kb_key%
LD_AH   $crsr_row
LD_AL   $crsr_col

.irq1_right
LDI_BL   0x1a           # right arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_left
ALUOP_AL %A+1%+%AL%     # +1 to column
ALUOP_AL %A&B%+%AL%+%BL% # mask value to 0-63
JMP .irq1_refresh

.irq1_left
LDI_BL   0x1b           # left arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_up
ALUOP_AL %A-1%+%AL%     # -1 to column
ALUOP_AL %A&B%+%AL%+%BL% # mask value to 0-63

.irq1_up
LDI_BL   0x18           # up arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_down
ALUOP_AH %A+1%+%AH%     # +1 to row
ALUOP_FLAGS %A&B%+%AH%+%BH% # test if AH(row)==60
JNE .irq1_refresh
LDI_AH 0                # loop row to zero after 59
JMP .irq1_refresh

.irq1_down
LDI_BL   0x18           # up arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_done
ALUOP_AH %A-1%+%AH%     # -1 to row
ALUOP_FLAGS %A%+%AH%    # test if AH(row) overflowed on subtract
JNO .irq1_refresh
LDI_AH 59               # loop row to 59 after 0
JMP .irq1_refresh

.irq1_refresh
CALL :cursor_goto

.irq1_done
RETI

# Disabled IRQ handlers simply return without doing anything
.noirq
RETI

