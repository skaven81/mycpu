# vim: syntax=asm-mycpu

NOP

# Clears the screen, initializes the UART, and prints characters as they are
# received over serial, and echos them back.  Characters received via the
# keyboard are sent over serial and echoed to the screen.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_clear_dr
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Initialize the UART
CALL :uart_init_115200_8n1

MASKINT

# Initialize all the things
CALL :keyboard_init
CALL :heap_init
CALL :cursor_init
CALL :cursor_display_sync

# Unmask interrupts to flush any read data
# while we clear the screen
UMASKINT

LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Begin reading characters
ST16    %IRQ1addr%  :kb_irq_buf
ST16    %IRQ5addr%  :uart_irq_dr_buf
UMASKINT

#######
# Main loop
#######
.check_uart_buf
CALL :uart_bufsize              # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .check_kb_buf
.flush_uart_buf
CALL :uart_readbuf              # next char in AL
CALL :putchar                   # print AL to cursor position
CALL .send_serial_char          # echo the character back to serial

CALL :uart_bufsize              # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JNZ .check_uart_buf             # loop until UART buffer is empty

.check_kb_buf
CALL :kb_bufsize                # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .check_uart_buf              # loop back to top if KB buffer is empty
.flush_kb_buf
CALL :kb_readbuf                # char in AL, flags in AH
LDI_BH %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BH%     # check if break
JNZ .check_kb_buf               # ignore keystroke if break
CALL :putchar                   # otherwise print it
LDI_BL %uart_usr_TC%
CALL .send_serial_char
JMP .check_kb_buf               # done, go back to check buffers again

# Disabled IRQ handlers simply return without doing anything
.noirq

.send_serial_char
ALUOP_ADDR %A%+%AL% %uart_tbr%  # put the char into the uart xmit buffer
.uart_xmit_loop
LD_AL %uart_usr%
ALUOP_FLAGS %A&B%+%AL%+%BL%     # See if transmission complete flag is set
JZ .uart_xmit_loop              # loop until byte has been sent
RET
