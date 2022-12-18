# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a blinking cursor, which can be moved
# around the screen using the arrow keys on the keyboard.

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

# Clear any pending KB interrupts
CALL :timer_clear_irq

# Setup our own keyboard handler
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

.irq1_right
LDI_BL   0x1a           # right arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_left
LD_AH   $crsr_row
LD_AL   $crsr_col
ALUOP_AL %A+1%+%AL%     # +1 to column
LDI_BL  63
ALUOP_AL %A&B%+%AL%+%BL% # mask value to 0-63
JMP .irq1_refresh

.irq1_left
LDI_BL   0x1b           # left arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_up
LD_AH   $crsr_row
LD_AL   $crsr_col
ALUOP_AL %A-1%+%AL%     # -1 to column
LDI_BL  63
ALUOP_AL %A&B%+%AL%+%BL% # mask value to 0-63
JMP .irq1_refresh

.irq1_up
LDI_BL   0x18           # up arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_down
LD_AH   $crsr_row
LD_AL   $crsr_col
ALUOP_AH %A-1%+%AH%     # -1 to row
JNO .irq1_refresh       # test if AH(row) overflowed on subtract
LDI_AH 59               # loop row to 59 after 0
JMP .irq1_refresh

.irq1_down
LDI_BL   0x19           # down arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_done
LD_AH   $crsr_row
LD_AL   $crsr_col
ALUOP_AH %A+1%+%AH%     # +1 to row
LDI_BH  60
ALUOP_FLAGS %A&B%+%AH%+%BH% # test if AH(row)==60
JNE .irq1_refresh
LDI_AH 0                # loop row to zero after 59
JMP .irq1_refresh

.irq1_refresh
# blank out the current char location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x00
STA_D_TD
# move the cursor to row AH, col AL
CALL :cursor_goto
# write a happy face to the new location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x02
STA_D_TD

.irq1_done
RETI

.noirq
RETI
