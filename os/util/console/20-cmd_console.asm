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
#  * send control chars properly so ctrl+c, backspace, etc. are sent properly
#  * still have a lot of random lockups, maybe related.
#
# 2026-08-22: the hand-rolled VT220 escape parser (.receive_vt220 and its
# .rx_vt220_* handlers) was replaced by feeding received bytes straight to
# the BIOS's own :putchar with $term_flags bit 1 (ANSI) set -- the BIOS now
# has a real CSI parser (TERMINAL_REFACTOR.md 2.2.3), so this tool no longer
# needs its own incomplete one (most of the TODOs above this note, plus a
# confirmed bug: the old 'D' cursor-left handler called :cursor_right).
# `console raw` still exists and now maps to leaving $term_flags at 0x00
# (no ANSI bit): ESC bytes print as literal glyphs instead of being
# interpreted, same intent as before. A bare LF (0x0a) is still dropped
# unconditionally in both modes -- most senders pair it with CR, and
# processing both would double-advance the line (CR moves to column 0,
# LF alone advances the row).

:cmd_console

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

VAR global word $console_vars
LDI_AL 1                # one block, 16 bytes
CALL :malloc_blocks     # A contains our memory address
ALUOP_ADDR %A%+%AH% $console_vars
ALUOP_ADDR %A%+%AL% $console_vars+1
# $console_vars[0] - raw mode
# $console_vars[1] - IRQ1 hi
# $console_vars[2] - IRQ1 lo
# $console_vars[3] - IRQ5 hi
# $console_vars[4] - IRQ5 lo
# $console_vars[5] - saved $term_flags (restored on exit)

# Get our first argument (argv[1])
LDI_BL 0x00                     # default to not raw mode
LDI_D .argv_buf+2               # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if first arg pointer is null
JZ .no_arg
LDI_C .raw_str                  # store ptr to 'raw' in C
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

# Save the current $term_flags at $console_vars[5], for restoration on exit.
LD_AL $term_flags
LD_CH $console_vars
LD_CL $console_vars+1
INCR_C
INCR_C
INCR_C
INCR_C
INCR_C
ALUOP_ADDR_C %A%+%AL%

# Print startup banner, and set $term_flags for this session: ANSI mode
# on (0x02) unless raw was requested (0x00) -- see the file header note.
ALUOP_FLAGS %B%+%BL%
JNZ .startup_raw
LDI_C .start_vt220
ST $term_flags 0x02
JMP .print_banner
.startup_raw
LDI_C .start_raw
ST $term_flags 0x00
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
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $term_flags   # restore $term_flags from $console_vars[5]
UMASKINT

.exit
# Free malloc'd memory, address was stored in $console_vars[0..1]
LD_DH $console_vars
LD_DL $console_vars+1
LDI_AL 0x00
CALL :free
.program_exit
LDI_A 0x0000
CALL :heap_push_A
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

### Takes a received character in AL and prints it via :putchar, which
### honors $term_flags as set at startup (ANSI mode, or raw/0x00) -- see
### the file header note. A bare LF (0x0a) is dropped unconditionally.
.receive_vt220
ALUOP_PUSH %B%+%BL%
LDI_BL '\n'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .exit_receive_vt220
CALL :putchar
.exit_receive_vt220
POP_BL
RET

.start_vt220 "Starting serial console in VT220 mode, press CTRL+ESC to exit\n\0"
.start_raw "Starting serial console in raw mode, press CTRL+ESC to exit\n\0"
.done "^ESC\nBreak, exiting\n\0"
.raw_str "raw\0"
.usage_str "Usage: console [raw]\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
