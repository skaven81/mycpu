# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a simple '>' prompt with
# blinking cursor, and prints characters as they are
# typed on the keyboard.

# Install IRQ handlers.  The IRQ0 (keyboard) handler
# starts off with a "wait for initialization" handler,
# which we swap out for proper keyboard handling once
# the keyboard controller is initialized.
ST16    %IRQ0addr%  .irq0_init
ST16    %IRQ1addr%  .noirq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  .noirq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Enable interrupts
UMASKINT

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Track cursor position in regs C (char) and D (color)
LDI_C   %display_chars%
LDI_TD  '>'     # prompt character
STA_C_TD        # Write '>' to first byte
INCR_C          # move cursor to the right
LDI_D   %display_color%+1
LDI_TD  %white%+%blink%+%cursor%
STA_D_TD        # enable blinking cursor

###
# Main loop
###
.main_loop
JMP .main_loop

#######
# IRQ handlers
#######

# When the KB controller first comes out of reset, it takes a few
# seconds to initialize and become responsive to commands.  When
# it has finished initializing, it triggers an interrupt.  This
# handler captures that interrupt, clears it, configues the keyboard
# controller how we like, and then installs the actual interrupt
# handler.
.irq0_init
# Clear the startup interrupt
STS     %kb_kbctrl% %kb_kbctrl_INTCLEAR%
# Set up the keyboard - interrupt on key make events,
# and clear interrupts on reads to %kb_key%
STS     %kb_config% %kb_config_INTMAKE%+%kb_config_INTCLR_READ%
# Configure the real keyboard handler
ST16    %IRQ0addr%  .irq0
RETI

# Keyboard event handler
.irq0
LDS_TD  %kb_key%        # fetch the key into TD
STA_C_TD                # write TD to the current cursor position
INCR_C                  # move char cursor to the right
LDI_TD  %white%
STA_D_TD                # disable blinking cursor in current position
INCR_D
LDI_TD  %white%+%blink%+%cursor%
STA_D_TD                # enable blinking cursor in new position
RETI

# Disabled IRQ handlers simply return
# without doing anything
.noirq
RETI

