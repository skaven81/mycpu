# vim: syntax=asm-mycpu

# Minimal serial output helper for termdemo's PERF lines. Deliberately just
# :ser_puts -- termdemo has no TT harness (that's termtest's job), so none
# of testlib.asm's PASS/FAIL/tt_* machinery is needed here.

######
# Sends a null-terminated string over the UART, one byte per :uart_sendchar.
#
# Inputs:
#  C - address of string to send
:ser_puts
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
.ser_puts_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .ser_puts_done
CALL :uart_sendchar
INCR_C
JMP .ser_puts_loop
.ser_puts_done
POP_CL
POP_CH
POP_AL
RET
