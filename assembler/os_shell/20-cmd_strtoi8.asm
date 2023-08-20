# vim: syntax=asm-mycpu

# Passes the first 

:cmd_strtoi8

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
CALL :strtoi8                   # convert to integer in AL, flags in BL

CALL :heap_push_BL              # flags
CALL :heap_push_AL
CALL :heap_push_AL
CALL :heap_push_AL
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

.helpstr "Usage: strtoi <number> [<number>...]\nWhere <number> can be:\n* 0x[0-9a-f]{1,2} (hexadecimal)\n* [0-9]{1,3} (unsigned decimal)\n* -[0-9]{1,3} (signed decimal)\n\0"
.printstr "Your input: [%s]\n  -> hex[%x] unsigned[%u] signed[%d] with flags [%x]\n\0"
