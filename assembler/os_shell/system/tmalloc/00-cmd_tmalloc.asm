# vim: syntax=asm-mycpu

# Tests the next-gen malloc functions

:cmd_tmalloc

# Load and check first argument, 's' or 'b' allocation size
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check range
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
LDA_C_BH                        # Load first char of first argument into BH
ALUOP_FLAGS %B%+%BH%
LDI_AL 's'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'b'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'i'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'f'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_free
JMP .usage

# 's' or 'b' or 'i' is in BH; check for next argument
.get_size
LDA_D_AH                        # put high byte of second arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of second arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check size
LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .usage

##### User wants to init or allocate
# Size is in AL, seg/block is in BH
LDI_AH 's'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_segments
LDI_AH 'b'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_blocks
LDI_AH 'i'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_init
JMP .usage

.do_init
ALUOP_BL %A%+%AL%               # Copy size to BL
LDI_A 0x6000                    # fixed base address
CALL :heap_push_BL
LDI_C .entry_init
CALL :printf
CALL :trace_begin
CALL :new_malloc_init
CALL :trace_end
RET

.do_blocks
CALL :heap_push_AL
LDI_C .entry_blk
CALL :printf
CALL :trace_begin
CALL :new_malloc_blocks
CALL :trace_end
RET

.do_segments
CALL :heap_push_AL
LDI_C .entry_seg
CALL :printf
CALL :trace_begin
CALL :new_malloc_segments
CALL :trace_end
RET


##### User wants to free()
# 'f' is in BH, check for next argument
.do_free
LDA_D_AH                        # put high byte of second arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of second arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check address
LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .usage

# Address is in A
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .entry_free
CALL :printf
CALL :trace_begin
CALL :new_free
CALL :trace_end
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: tmalloc {i[nit],s[eg],b[lock],f[ree]} size|addr\n\0"
.entry_init "Calling :new_malloc_init(0x6000, 0x%x)\n\0"
.entry_blk "Calling :new_malloc_blocks(0x%x)\n\0"
.entry_seg "Calling :new_malloc_segments(0x%x)\n\0"
.entry_free "Calling :new_free(0x%x%x\n\0"

