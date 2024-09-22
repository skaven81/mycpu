# vim: syntax=asm-mycpu

# Convert a sector (LBA) address to a cluster number
#  Argument 1 (+2/3): filesystem handle address word
#  Argument 2 (+4/5): LBA address high word
#  Argument 3 (+6/7): LBA address low word

:cmd_sector_to_cluster

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_D $user_input_tokens+4      # D points at second argument pointer
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a third argument
LDI_D $user_input_tokens+6      # D points at third argument pointer
LDA_D_AH                        # put third arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

## Load and check filesystem handle address into D
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_DH %A%+%AH%               # Copy filesystem handle address to D for now
ALUOP_DL %A%+%AL%

## Load and check low LBA address into C
LDI_A $user_input_tokens+6      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+7      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_CH %A%+%AH%               # Copy low LBA address to C for now
ALUOP_CL %A%+%AL%

## Load and check high LBA address into B
PUSH_CH
PUSH_CL
LDI_A $user_input_tokens+4      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_BH %A%+%AH%               # Copy low LBA address to C for now
ALUOP_BL %A%+%AL%
POP_CL
POP_CH

CALL :heap_push_D               # Address of filesystem handle
CALL :heap_push_B               # high word of LBA address
CALL :heap_push_C               # low word of LBA address
CALL :fat16_lba_to_cluster      # cluster number on stack
CALL :heap_pop_D
CALL :heap_push_DL
CALL :heap_push_DH              # reorder for printing
LDI_C .resultstr
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

.helpstr "Usage: lba2cluster <fs handle addr> <lba 27:16> <lba 15:0>\n\0"
.bad_addr_str "Error: %s is not a valid 16-bit word. strtoi flags: 0x%x\n\0"
.resultstr "Cluster 0x%x%x\n\0"
