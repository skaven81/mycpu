# vim: syntax=asm-mycpu

# Returns the next FAT16 cluster, given a cluster number
#  Argument 1 (+2/3): filesystem handle address word
#  Argument 2 (+4/5): cluster number

:cmd_next_cluster

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

LDI_D .argv_buf+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_D .argv_buf+4      # D points at second argument pointer
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

## Load and check filesystem handle address into D
LDI_A .argv_buf+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A .argv_buf+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_DH %A%+%AH%               # Copy filesystem handle address to D for now
ALUOP_DL %A%+%AL%

## Load and check cluster number into C
LDI_A .argv_buf+4      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A .argv_buf+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_CH %A%+%AH%               # Copy low LBA address to C for now
ALUOP_CL %A%+%AL%

CALL :heap_push_D               # Address of filesystem handle
CALL :heap_push_C               # cluster number
CALL :fat16_next_cluster        # Cluster on stack
CALL :heap_pop_C                # Result in C

CALL :heap_push_CL
CALL :heap_push_CH              # reverse the order on heap for printing
LDI_C .resultstr
CALL :printf
JMP .program_exit

.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
JMP .program_exit

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.helpstr "Usage: next_cluster <fs handle addr> <cluster number>\n\0"
.bad_addr_str "Error: %s is not a valid 16-bit word. strtoi flags: 0x%x\n\0"
.resultstr "Cluster 0x%x%x\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
