# vim: syntax=asm-mycpu

# Interactive RTS/CTS test tool.
# Continuously prints live /CTS(in) /RTS(out) /DSR(in) /DTR(out) status.
# Press 'r' to toggle the RTS output bit in the MCR (does not touch
# DTR, ITEN, mode, REN, or MIEN bits -- XOR only affects bit 0).
# Press 'q' to quit back to the shell.
#
# Use this with the PC-side rts_cts_test.py script (or just a scope/DMM
# on DE9 pin 7) to confirm the Odyssey's RTS output actually toggles the
# physical pin, and to confirm the Odyssey correctly reads an externally
# driven CTS input (e.g. from the bench supply test).

:cmd_rtstest
LDI_C .banner_str
CALL :printf

.rtstest_loop

# --- read and print live status line ---
LD_SLOW_PUSH %uart_msr%
POP_AL
LDI_BL %uart_msr_CTS%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .no_cts
LDI_AL '1'
JMP .cts_done
.no_cts
LDI_AL '0'
.cts_done
CALL :heap_push_AL # /CTS(i)

LD_SLOW_PUSH %uart_mcr%
POP_AL
LDI_BL %uart_mcr_RTS%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .no_rts
LDI_AL '1'
JMP .rts_done
.no_rts
LDI_AL '0'
.rts_done
CALL :heap_push_AL # /RTS(o)

LD_SLOW_PUSH %uart_msr%
POP_AL
LDI_BL %uart_msr_DSR%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .no_dsr
LDI_AL '1'
JMP .dsr_done
.no_dsr
LDI_AL '0'
.dsr_done
CALL :heap_push_AL # /DSR(i)

LD_SLOW_PUSH %uart_mcr%
POP_AL
LDI_BL %uart_mcr_DTR%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .no_dtr
LDI_AL '1'
JMP .dtr_done
.no_dtr
LDI_AL '0'
.dtr_done
CALL :heap_push_AL # /DTR(o)

LDI_C .status_str
CALL :printf

# --- check for a keypress: 'r' toggles RTS, 'q' quits ---
CALL :kb_readbuf        # AL = char, 0x00 if buffer empty
ALUOP_FLAGS %A%+%AL%
JZ .rtstest_loop         # nothing pressed, keep looping

LDI_BL 'q'
ALUOP_FLAGS %A-B%+%AL%+%BL%
JZ .rtstest_quit

LDI_BL 'r'
ALUOP_FLAGS %A-B%+%AL%+%BL%
JNZ .rtstest_loop        # not 'r' either, ignore and keep looping

# --- toggle RTS bit (MCR bit 0) via read-modify-write ---
LD_SLOW_PUSH %uart_mcr%
POP_AL
LDI_BL %uart_mcr_RTS%
ALUOP_AL %AxB%+%AL%+%BL% # XOR bit 0 only; REN/DTR/etc untouched
ALUOP_PUSH %A%+%AL%
ST_SLOW_POP %uart_mcr%

JMP .rtstest_loop

.rtstest_quit
LDI_C .bye_str
CALL :printf
RET

.banner_str "RTS/CTS interactive test.  'r'=toggle RTS  'q'=quit\n\0"
.status_str "/DTR(0):%c /DSR(i):%c /RTS(o):%c /CTS(i):%c\r\0"
.bye_str    "\r\nExiting rtstest.\n\0"
