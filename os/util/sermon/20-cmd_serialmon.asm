# vim: syntax=asm-mycpu

# Monitor the serial interface in a tight loop

:cmd_serialmon
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
CALL :heap_push_AL # put DTR value on heap

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
CALL :heap_push_AL # put DSR value on heap

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
CALL :heap_push_AL # put RTS value on heap

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
CALL :heap_push_AL # put CTS value on heap

LDI_C .out_str
CALL :printf

RET

.out_str "/CTS(i):%c /RTS(o):%c /DSR(i):%c /DTR(o):%c\n\0"
