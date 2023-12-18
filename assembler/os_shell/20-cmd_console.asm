# vim: syntax=asm-mycpu

# Attaches to the serial device and behaves like a serial terminal.  Keyboard
# events are sent over serial and bytes from serial are printed to the screen.
#
# To start a serial getty, edit /lib/systemd/system/serial-getty@.service and
# set the baud rate.  Then:
#  * sudo systemctl daemon-reload
#  * sudo systemctl {start|stop} serial-getty@ttyUSB[01]

# TODO 2023-12-17
#  * cursor_goto_rowcol doesn't work, needs to be fixed (see clearscreen)
#  * send control chars properly so ctrl+c, backspace, etc. are sent properly
#  * load parameters and handle colors
#  * why does `ls` output not print in its entirety?
#  * still have a lot of random lockups, maybe related.

:cmd_console

VAR global word $console_vars
LDI_AL 0                # one block, 16 bytes
CALL :malloc            # A contains our memory address
ALUOP_ADDR %A%+%AH% $console_vars
ALUOP_ADDR %A%+%AL% $console_vars+1
# $console_vars[0] - IRQ1 hi
# $console_vars[1] - IRQ1 lo
# $console_vars[2] - IRQ5 hi
# $console_vars[3] - IRQ5 lo

# Save our previous interrupt vectors
LD_DH $console_vars
LD_DL $console_vars+1
LD_CL %IRQ1addr%
STA_D_CL                # store IRQ1 hi at $console_vars[0]
INCR_D
LD_CL %IRQ1addr%+1
STA_D_CL                # store IRQ1 lo at $console_vars[1]
INCR_D
LD_CL %IRQ5addr%
STA_D_CL                # store IRQ5 lo at $console_vars[2]
INCR_D
LD_CL %IRQ5addr%+1
STA_D_CL                # store IRQ5 lo at $console_vars[2]

# Set up interrupt handlers for keyboard and UART
MASKINT
ST16 %IRQ1addr% :kb_irq_buf
ST16 %IRQ5addr% :uart_irq_dr_buf
UMASKINT

# Print startup banner
LDI_C .start
CALL :print

#######
# Main loop
#######
.check_uart_buf
CALL :uart_bufsize              # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .check_kb_buf
.flush_uart_buf
CALL :uart_readbuf              # next char in AL
CALL .receive_vt220
JMP .check_uart_buf             # loop until UART buffer is empty

.check_kb_buf
CALL :kb_bufsize                # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .check_uart_buf              # loop back to top if KB buffer is empty
CALL :kb_readbuf                # char in AL, flags in AH

# check if break (key release), if so, loop to next character
LDI_BH %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .check_kb_buf

# check if null, if so, loop to next character
ALUOP_FLAGS %A%+%AL%
JZ .check_kb_buf

# check if char is ctrl+esc
LDI_BH 0x1b
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_ctrl_esc
LDI_BH %kb_keyflag_CTRL%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNE .not_ctrl_esc
JMP .break                      # Ctrl+ESC, so break out

.not_ctrl_esc
CALL .send_vt220
JMP .check_kb_buf               # done, go back to check buffers again

.break
# print break message
LDI_C .done
CALL :print

# Restore IRQ vectors
MASKINT
LD_DH $console_vars
LD_DL $console_vars+1
LDA_D_TD
ST_TD %IRQ1addr%        # restore IRQ1 hi from $console_vars[0]
INCR_D
LDA_D_TD
ST_TD %IRQ1addr%+1      # restore IRQ1 hi from $console_vars[1]
INCR_D
LDA_D_TD
ST_TD %IRQ5addr%        # restore IRQ5 hi from $console_vars[2]
INCR_D
LDA_D_TD
ST_TD %IRQ5addr%+1      # restore IRQ5 lo from $console_vars[3]
UMASKINT

RET

### Takes a keystroke (key=AL, flags=AH) and sends the appropriate
### VT220 sequence for that character
.send_vt220
ALUOP_PUSH %B%+%BL%
CALL :uart_sendchar
POP_BL
RET

### Takes a received character in AL, and prints the appropriate
### data to the screen, interpreting codes as necessary.
.receive_vt220
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Ignore \r (linefeed) chars
LDI_BL '\n'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .not_linefeed
JMP .exit_receive_vt220

# Is it an escape char?
.not_linefeed
LDI_BL 0x1b # esc
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .not_esc
# If esc, read another char
.receive_vt220_readbuf
CALL :uart_bufsize              # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .receive_vt220_readbuf
CALL :uart_readbuf              # next char in AL
LDI_BL '['
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .not_esc
# We have received esc-[ and so we now need to receive
# the rest of the escape sequence. the first parameter,
# if present, goes into CL. The second parameter, if present,
# goes into CH. The terminating code (a letter) ends up in AL.
.receive_vt220_readesc
CALL :uart_bufsize              # buffer size in AL
ALUOP_FLAGS %A%+%AL%
JZ .receive_vt220_readesc
CALL :uart_readbuf              # next char in AL

# See if the char terminates the sequence
LDI_BL 'A'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_up
LDI_BL 'B'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_down
LDI_BL 'C'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_right
LDI_BL 'D'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_left
LDI_BL 'E'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore cursor next line
LDI_BL 'F'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore cursor previous line
LDI_BL 'G'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore cursor horizontal absolute
LDI_BL 'H'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_goto
LDI_BL 'J'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_clear
LDI_BL 'K'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_erase_line
LDI_BL 'S'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore scroll up
LDI_BL 'T'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore scroll down
LDI_BL 'f'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_cursor_goto # similar behavior
LDI_BL 'm'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rx_vt220_setcolor
LDI_BL 'i'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore AUX port
LDI_BL 'n'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore device status report

# If it's a semicolon then toggle to second parameter
# TODO

# If it's not a terminating char, and it's numeric,
# collect the char into a parameter
# TODO
JMP .receive_vt220_readesc

# If it's none of these, then it's an invalid escape sequence, so print the
# char and move on.
JMP .not_esc

####
# VT220 ANSI code handlers
.rx_vt220_cursor_up
CALL :cursor_up
JMP .exit_receive_vt220

.rx_vt220_cursor_down
CALL :cursor_down
JMP .exit_receive_vt220

.rx_vt220_cursor_right
CALL :cursor_right
JMP .exit_receive_vt220

.rx_vt220_cursor_left
CALL :cursor_right
JMP .exit_receive_vt220

.rx_vt220_cursor_goto
# TODO
JMP .exit_receive_vt220

.rx_vt220_clear
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LDI_AH 0x00 # char to fill with
LDI_AL %white%
CALL :clear_screen
LDI_AL 0x00
#CALL :cursor_goto_rowcol
CALL :cursor_init
# TODO 0 (default) clears from cursor to end of screen
# TODO 1 clears from cursor to beginning of screen
# TODO 2 or 3 clears entire screen and moves cursor to 1,1
POP_AL
POP_AH
JMP .exit_receive_vt220

.rx_vt220_erase_line
# TODO 0 (default) clear from cursor to the end of the line
# TODO 1 clear from cursor to beginning of the line
# TODO 2 clear entire line
JMP .exit_receive_vt220

.rx_vt220_setcolor
# TODO
JMP .exit_receive_vt220

###
# if we received something that wasn't an escape sequence,
# print it and move on.
.not_esc
CALL :putchar
JMP .exit_receive_vt220

.exit_receive_vt220
POP_CL
POP_CH
POP_BL
RET

.start "Starting serial console, press CTRL+ESC to exit\n\0"
.done "^ESC\nBreak, exiting\n\0"
