# vim: syntax=asm-mycpu

NOP

# Clears the screen, initializes the UART, and prints characters
# as they are received.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_irq_dr_buf
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Initialize the UART
CALL :uart_init_9600_8n1

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Get the cursor ready to go
CALL :heap_init
CALL :cursor_init
CALL :cursor_display_sync

# Begin processing serial data
UMASKINT

#######
# Main loop
#######
.main_loop
CALL :uart_bufsize
ALUOP_FLAGS %A%+%AL%
JZ .main_loop
CALL :uart_readbuf
CALL :putchar
JMP .main_loop
HLT

# Disabled IRQ handlers simply return without doing anything
.noirq
RETI

