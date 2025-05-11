# vim: syntax=asm-mycpu

#####
# Tracing functions for debug
#
# :trace - prints the caller address and register state
# :trace_{begin,end} - prefixes the message with BEGIN or END
# :trace_{0,1,2,3,4,5,6,7} - prefixes the message with DEBUG{0,1,2,3,...}
#####

.trace_str "{%X%X} A:%x%x B:%x%x C:%x%x D:%x%x pgD:%x pgE:%x\n\0"

VAR global word $trace_d_backup

:trace
# Push the D and E pages to the heap for printf
PUSH_DL
LD_DL %e_page%
CALL :heap_push_DL
LD_DL %d_page%
CALL :heap_push_DL
POP_DL
# Push the register state to the heap for printf
CALL :heap_push_DL
CALL :heap_push_DH
CALL :heap_push_CL
CALL :heap_push_CH
CALL :heap_push_BL
CALL :heap_push_BH
CALL :heap_push_AL
CALL :heap_push_AH

# We can't use the heap to preserve the value of D, so we
# use RAM instead.
ST_DH $trace_d_backup
ST_DL $trace_d_backup+1

# The address on the stack is where we were called from. We
# can pop that value off the stack (then push it back) to include
# the call address in the message.
POP_DH          # Get return address into D
PEEK_DL
PUSH_DH
DECR_D          # Subtract three to get the address of the call
DECR_D
DECR_D
CALL :heap_push_DL  # push address onto heap
CALL :heap_push_DH

# Restore D from backup
LD_DH $trace_d_backup
LD_DL $trace_d_backup+1

# Print the trace string
PUSH_CH
PUSH_CL
LDI_C .trace_str
CALL :printf
POP_CL
POP_CH
RET

.trace_begin_str "BEGIN \0"
:trace_begin
PUSH_CH
PUSH_CL
LDI_C .trace_begin_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_end_str "END \0"
:trace_end
PUSH_CH
PUSH_CL
LDI_C .trace_end_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_0_str "DEBUG0 \0"
:trace_0
PUSH_CH
PUSH_CL
LDI_C .trace_0_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_1_str "DEBUG1 \0"
:trace_1
PUSH_CH
PUSH_CL
LDI_C .trace_1_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_2_str "DEBUG2 \0"
:trace_2
PUSH_CH
PUSH_CL
LDI_C .trace_2_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_3_str "DEBUG3 \0"
:trace_3
PUSH_CH
PUSH_CL
LDI_C .trace_3_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_4_str "DEBUG4 \0"
:trace_4
PUSH_CH
PUSH_CL
LDI_C .trace_4_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_5_str "DEBUG5 \0"
:trace_5
PUSH_CH
PUSH_CL
LDI_C .trace_5_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_6_str "DEBUG6 \0"
:trace_6
PUSH_CH
PUSH_CL
LDI_C .trace_6_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

.trace_7_str "DEBUG7 \0"
:trace_7
PUSH_CH
PUSH_CL
LDI_C .trace_7_str
CALL :print
POP_CL
POP_CH
JMP :trace  # don't use CALL because that would obscure the caller address

