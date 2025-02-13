# vim: syntax=asm-mycpu

# Attaches to the serial device and behaves like a serial terminal.  Keyboard
# events are sent over serial and bytes from serial are printed to the screen.
#
# To start a serial getty, edit /lib/systemd/system/serial-getty@.service and
# set the baud rate.  Then:
#  * sudo systemctl daemon-reload
#  * sudo systemctl {start|stop} serial-getty@ttyUSB[01]
#
# Or, communicate with the Odyssey directly using a serial console like gtkterm.
# Configure the port /dev/ttyUSBx baud-n81, with no flow control.

# TODO 2024-01-07
#  * cursor_goto_rowcol doesn't work, needs to be fixed (see clearscreen)
#  * send control chars properly so ctrl+c, backspace, etc. are sent properly
#  * load parameters and handle colors and cursor movement commands
#  * still have a lot of random lockups, maybe related.
#  * @<color> codes terminal_output don't match ANSI colors, but maybe that's OK

:cmd_console

VAR global word $console_vars
LDI_AL 0                # one block, 16 bytes
CALL :malloc            # A contains our memory address
ALUOP_ADDR %A%+%AH% $console_vars
ALUOP_ADDR %A%+%AL% $console_vars+1
# $console_vars[0] - raw mode
# $console_vars[1] - IRQ1 hi
# $console_vars[2] - IRQ1 lo
# $console_vars[3] - IRQ5 hi
# $console_vars[4] - IRQ5 lo

# Get our first argument
LDI_BL 0x00                     # default to not raw mode
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if first arg pointer is null
JZ .no_arg
LDI_C .raw                      # store ptr to 'raw' in C
ALUOP_DH %A%+%AH%               # store ptr to first argument in D
ALUOP_DL %A%+%AL%
CALL :strcmp                    # result in AL
ALUOP_FLAGS %A%+%AL%            # check if zero (equal)
JNZ .usage
LDI_BL 0x01
.no_arg
LD_DH $console_vars
LD_DL $console_vars+1           # D at $console_vars[0]

ALUOP_ADDR_D %B%+%BL%           # Store raw mode flag at $console_vars[0]

# Print startup banner
ALUOP_FLAGS %B%+%BL%
JNZ .startup_raw
LDI_C .start_vt220
JMP .print_banner
.startup_raw
LDI_C .start_raw
.print_banner
CALL :print

# Save our previous interrupt vectors
INCR_D
LD_CL %IRQ1addr%
STA_D_CL                # store IRQ1 hi at $console_vars[1]
INCR_D
LD_CL %IRQ1addr%+1
STA_D_CL                # store IRQ1 lo at $console_vars[2]
INCR_D
LD_CL %IRQ5addr%
STA_D_CL                # store IRQ5 lo at $console_vars[3]
INCR_D
LD_CL %IRQ5addr%+1
STA_D_CL                # store IRQ5 lo at $console_vars[4]


# Set up interrupt handlers for keyboard and UART
MASKINT
ST16 %IRQ1addr% :kb_irq_buf
ST16 %IRQ5addr% :uart_irq_dr_buf
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
LDI_BH 0x1b                     # ESC
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_ctrl_esc
LDI_BH %kb_keyflag_CTRL%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JZ .not_ctrl_esc
JMP .break                      # Ctrl+ESC, so break out

.not_ctrl_esc
CALL .send_vt220
JMP .check_kb_buf               # done, go back to check buffers again

.break
# print break message
LDI_C .done
CALL :print

.restore
# Restore IRQ vectors
MASKINT
LD_DH $console_vars
LD_DL $console_vars+1   # D at $console_vars[0]
INCR_D                  # D at $console_vars[1]
LDA_D_TD
ST_TD %IRQ1addr%        # restore IRQ1 hi from $console_vars[1]
INCR_D
LDA_D_TD
ST_TD %IRQ1addr%+1      # restore IRQ1 hi from $console_vars[2]
INCR_D
LDA_D_TD
ST_TD %IRQ5addr%        # restore IRQ5 hi from $console_vars[3]
INCR_D
LDA_D_TD
ST_TD %IRQ5addr%+1      # restore IRQ5 lo from $console_vars[4]
UMASKINT

.exit
# Free malloc'd memory
LD_DH $console_vars
LD_DL $console_vars+1
LDI_AL 0x00
CALL :free
RET

.usage
LDI_C .usage_str
CALL :print
JMP .exit

### Takes a keystroke (key=AL, flags=AH) and sends the appropriate
### VT220 sequence for that character
.send_vt220
ALUOP_PUSH %B%+%BL%
CALL :uart_sendchar
POP_BL
RET

### Takes a received character in AL, and prints the appropriate
### data to the screen, interpreting codes as necessary.  If `raw`
### parameter was provided, skips the code interpretation
.receive_vt220
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Ignore \r (linefeed) chars
LDI_BL '\n'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .not_linefeed
JMP .exit_receive_vt220

# Check raw mode - jump straight
# to "print it" if in raw mode
.not_linefeed
LD_DH $console_vars
LD_DL $console_vars+1
LDA_D_BL # BL contains raw mode flag $console_vars[0]
ALUOP_FLAGS %B%+%BL%
JZ .vt220_mode                  # if raw mode == 0 (off), do VT220 handling
CALL :putchar                   # otherwise, just print the char
JMP .exit_receive_vt220         # and go back to the console handler loop

.vt220_mode
# Is it an escape char?
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
LDI_BL 'h'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore `CSI ? nnnn h` private sequence (xterm/VT220)
LDI_BL 'l'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220 # ignore `CSI ? nnnn l` private sequence (xterm/VT220)

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
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
RET

.start_vt220 "Starting serial console in VT220 mode, press CTRL+ESC to exit\n\0"
.start_raw "Starting serial console in raw mode, press CTRL+ESC to exit\n\0"
.done "^ESC\nBreak, exiting\n\0"
.raw "raw\0"
.usage_str "Usage: console [raw]\n\0"
