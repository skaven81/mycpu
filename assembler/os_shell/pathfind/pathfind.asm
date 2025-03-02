# vim: syntax=asm-mycpu

:cmd_pathfind

# Ensure we have an argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

CALL :heap_push_A               # address of path string
CALL :fat16_pathfind
CALL :heap_pop_D                # directory entry (or error)
CALL :heap_push_DL
CALL :heap_push_DH
LDI_C .result
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: pathfind PATH\n\0"
.result "Result: 0x%x%x\n\0"
