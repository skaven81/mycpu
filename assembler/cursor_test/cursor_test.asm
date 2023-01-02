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

# blank out the current char location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x00
STA_D_TD

# load keystroke into AL
LD_AL   %kb_key%

.irq1_right
LDI_BL   0x1a           # right arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_left
CALL :cursor_right
JMP .irq1_done

.irq1_left
LDI_BL   0x1b           # left arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_up
CALL :cursor_left
JMP .irq1_done

.irq1_up
LDI_BL   0x18           # up arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_down
CALL :cursor_up
JMP .irq1_done

.irq1_down
LDI_BL   0x19           # down arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_done
CALL :cursor_down
JMP .irq1_done

.irq1_done
# write a happy face to the new location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x02
STA_D_TD
RETI

.noirq
RETI
