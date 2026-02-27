# vim: syntax=asm-mycpu

# Tests the rand math function

:cmd_rand

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

# Check for a first argument (argv[1])
LDI_D .argv_buf+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check range
LDI_A .argv_buf+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A .argv_buf+3      # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_range

# Range is in AL; abort if it's zero
ALUOP_FLAGS %A%+%AL%
JZ .abort_bad_range

# Save AL (range) momentarily while we check on count
ALUOP_PUSH %A%+%AL%

# Count is 1 by default
LDI_BH 0x01

# Check for a second argument
LDA_D_AH                        # put high byte of second arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of second arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .no_load_count               # if null, don't load the argument

# Load and check count
LDI_A .argv_buf+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A .argv_buf+5      # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_count
ALUOP_BH %A%+%AL%               # Put count into BH

.no_load_count
POP_AL                          # get range back into AL

.rand_loop
# Get a random number, ends up on the heap
CALL :rand8

# dividend (rand number) is already on the heap
CALL :heap_push_AL              # Put divisor (range) on the heap

# Divide
CALL :div8

# div8 leaves the quotient and remainder on the heap.
# Pop and discard the quotient first, we don't need it
CALL :heap_pop_byte
# The remainder is on the heap now
LDI_C .result
CALL :printf

# Decrement count, if not zero do it again
ALUOP_BH %B-1%+%BH%
JNZ .rand_loop

JMP .program_exit

.abort_bad_count
POP_TD
.abort_bad_range
.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.helpstr "Usage: rand <range> [count:1] (1<=range<=255)\n\0"
.result "%u\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

