# vim: syntax=asm-mycpu

# Passes the first 

:cmd_strtoi

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte into AH
INCR_D
LDA_D_AL                        # put low byte into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

.process_loop
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # Copy argument str pointer to C
CALL :strtoi                    # convert to integer in A, flags in BL

CALL :heap_push_BL              # flags
CALL :heap_push_A
CALL :heap_push_A
CALL :heap_push_AL
CALL :heap_push_AH
CALL :heap_push_C
LDI_C .printstr
CALL :printf

# move to next argument
LDA_D_AH                        # put high byte into AH
INCR_D
LDA_D_AL                        # put low byte into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JNZ .process_loop
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: strtoi <number> [<number>...]\nWhere <number> can be:\n* 0x[0-9a-f]{1,4} (hexadecimal)\n* [0-9]{1,5} (unsigned decimal)\n* -[0-9]{1,5} (signed decimal)\n\0"
.printstr "Your input: [%s]\n  -> hex[%x%x] unsigned[%U] signed[%D] with flags [%x]\n\0"
