# vim: syntax=asm-mycpu

# termtest serial test harness.
#
# Every test suite reports over the UART only, keeping the report protocol
# machine-parseable regardless of whatever's on screen. Wire protocol, one
# line per event:
#   TT START <suite>\n
#   PASS <test>\n
#   FAIL <test> exp=XX got=XX\n
#   TT RESULT <pass>/<total>\n
#
# An agent drives this with `odyctl expect 'TT RESULT' --timeout N` then
# `odyctl read` to pull the transcript.

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

######
# Sends a byte over the UART formatted as two hex digits (e.g. "3f").
#
# Inputs:
#  AL - byte to format and send
:ser_puthex8
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
CALL :heap_push_AL
LDI_C .hex8_fmt
LDI_D .hex_scratch
CALL :sprintf
LDI_C .hex_scratch
CALL :ser_puts
POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
RET

######
# Sends a word over the UART formatted as four hex digits (e.g. "4a3f").
#
# Inputs:
#  A - word to format and send
:ser_puthex16
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
CALL :heap_push_A
LDI_C .hex16_fmt
LDI_D .hex_scratch
CALL :sprintf
LDI_C .hex_scratch
CALL :ser_puts
POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
RET

######
# Starts a new test suite: prints "TT START <name>\n" and resets the
# pass/total counters to zero.
#
# Inputs:
#  C - address of suite name string
:tt_suite
PUSH_CH
PUSH_CL
LDI_C .tt_suite_prefix
CALL :ser_puts
POP_CL
POP_CH
CALL :ser_puts
LDI_C .tt_newline
CALL :ser_puts
ST .tt_pass_count 0x00
ST .tt_total_count 0x00
RET

######
# Records a passing test: prints "PASS <name>\n" and bumps both counters.
#
# Inputs:
#  C - address of test name string
:tt_pass
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

PUSH_CH
PUSH_CL
LDI_C .tt_pass_prefix
CALL :ser_puts
POP_CL
POP_CH
CALL :ser_puts
LDI_C .tt_newline
CALL :ser_puts

LD_AL .tt_pass_count
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .tt_pass_count

LD_AL .tt_total_count
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .tt_total_count

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
RET

######
# Records a failing test: prints "FAIL <name> exp=XX got=XX\n" and bumps
# the total counter only.
#
# Inputs:
#  C - address of test name string
#  AH - expected byte value
#  AL - actual (got) byte value
:tt_fail
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

ALUOP_ADDR %A%+%AH% .tt_fail_exp_val
ALUOP_ADDR %A%+%AL% .tt_fail_got_val

PUSH_CH
PUSH_CL
LDI_C .tt_fail_prefix
CALL :ser_puts
POP_CL
POP_CH
CALL :ser_puts

LDI_C .tt_fail_exp_str
CALL :ser_puts
LD_AL .tt_fail_exp_val
CALL :ser_puthex8

LDI_C .tt_fail_got_str
CALL :ser_puts
LD_AL .tt_fail_got_val
CALL :ser_puthex8

LDI_C .tt_newline
CALL :ser_puts

LD_AL .tt_total_count
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .tt_total_count

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
RET

######
# Prints "TT RESULT <pass>/<total>\n" using the current suite's counters.
:tt_result
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

LDI_C .tt_result_prefix
CALL :ser_puts

LD_AL .tt_total_count
CALL :heap_push_AL
LD_AL .tt_pass_count
CALL :heap_push_AL
LDI_C .tt_result_fmt
LDI_D .hex_scratch
CALL :sprintf
LDI_C .hex_scratch
CALL :ser_puts

LDI_C .tt_newline
CALL :ser_puts

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
RET

######
# Compares two bytes and records the result: :tt_pass if equal, :tt_fail
# (same AH/AL) if not. Shared by every test suite's assertion points.
#
# Inputs:
#  C - address of test name string
#  AH - expected byte value
#  AL - actual (got) byte value
:tt_assert_eq
ALUOP_PUSH %B%+%BL%
ALUOP_BL %A%+%AH%            # BL = expected (the ALU's A-port only takes
                              # AH/AL and its B-port only BH/BL, so AH and
                              # AL can't be compared directly -- copy one
                              # of them into a B-register first)
ALUOP_FLAGS %AxB%+%AL%+%BL%
POP_BL
JEQ .tt_assert_pass
CALL :tt_fail
RET
.tt_assert_pass
CALL :tt_pass
RET

######
# Injects synthetic keystrokes into the keyboard ring buffer, exactly as
# :kb_irq_buf would from a real keypress. Lets tests drive :readline
# without a physical keyboard. Must not race a real keystroke, so the
# write-pointer update is masked.
#
# Inputs:
#  C - pointer to AL pairs of (flags, char) bytes
#  AL - number of pairs to inject (0 = no-op)
:kb_inject
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

ALUOP_FLAGS %A%+%AL%
JZ .kb_inject_done

ALUOP_BL %A%+%AL%                # BL = pair count (loop counter)
MASKINT
LD_AH $kb_buf_ptr_write
LD_AL $kb_buf_ptr_write+1

.kb_inject_loop
LDA_C_BH                         # BH = flags byte at [C]
ALUOP_ADDR_A %B%+%BH%            # write flags to buffer write location [A]
ALUOP_AL %A+1%+%AL%              # advance write pointer low byte (wraps)
INCR_C
LDA_C_BH                         # BH = char byte at [C]
ALUOP_ADDR_A %B%+%BH%            # write char to buffer write location [A]
ALUOP_AL %A+1%+%AL%
INCR_C
ALUOP_BL %B-1%+%BL%
JNZ .kb_inject_loop

ALUOP_ADDR %A%+%AL% $kb_buf_ptr_write+1  # persist new low byte
UMASKINT

.kb_inject_done
POP_BL
POP_BH
POP_AL
POP_AH
POP_CL
POP_CH
RET

.hex8_fmt "%x\0"
.hex16_fmt "%X\0"
.hex_scratch "\0\0\0\0\0\0\0\0"
.tt_suite_prefix "TT START \0"
.tt_pass_prefix "PASS \0"
.tt_fail_prefix "FAIL \0"
.tt_fail_exp_str " exp=0x\0"
.tt_fail_got_str " got=0x\0"
.tt_fail_exp_val "\0"
.tt_fail_got_val "\0"
.tt_result_prefix "TT RESULT \0"
.tt_result_fmt "%u/%u\0"
.tt_newline "\n\0"
.tt_pass_count "\0"
.tt_total_count "\0"
