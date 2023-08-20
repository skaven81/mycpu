# vim: syntax=asm-mycpu

# Poke a byte

:cmd_poke

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check address
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

# Store address on stack for now
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

# Load and check byte
LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_byte

ALUOP_DL %A%+%AL%               # Put byte to write into DL
POP_AL
POP_AH                          # Address popped back into A

LDA_A_DH                        # get current byte into DH
STA_A_DL                        # replace with DL
CALL :heap_push_DL
CALL :heap_push_DH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .updated_str
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
RET

.abort_bad_byte
POP_TD                          # Discard saved address
POP_TD
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_byte_str
CALL :printf
RET


.helpstr "Usage: poke <addr> <byte>\n\0"
.bad_addr_str "Error: %s is not a valid address. strtoi flags: 0x%x\n\0"
.bad_byte_str "Error: %s is not a valid byte specifier. strtoi flags: 0x%x\n\0"
.updated_str "0x%x%x: was 0x%x now 0x%x\n\0"
