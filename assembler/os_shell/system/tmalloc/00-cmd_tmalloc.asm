# vim: syntax=asm-mycpu

# Tests the next-gen malloc functions

:cmd_tmalloc

# Check first argument so we know what subcommand to run
LD_CH $user_input_tokens+2
LD_CL $user_input_tokens+3      # pointer to second token string in C
MOV_CH_AL                       # high byte of pointer into AL
ALUOP_FLAGS %A%+%AL%            # check if zero
JZ .usage                       # no first argument if zero, so usage

# Jump to the next command phase based on first character of first argument
LDA_C_BH                        # BH contains the first character of the first argument
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
LDI_C .error_command
CALL :print
JMP .usage

# 's' or 'b' or 'i' is in BH; check for next argument
.get_size
LD_CH $user_input_tokens+4      # Pointer to second argument in C
LD_CL $user_input_tokens+5
MOV_CH_AL                       # high byte of pointer into AL
ALUOP_FLAGS %A%+%AL%            # check if zer
JZ .usage                       # no second argumen tif zero, so usage

# Load and check size
CALL :strtoi8                   # Convert to number from string pointer in C into in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .usage

##### User wants to init or allocate
# Size is in AL, seg/block is in BH
LDI_AH 's'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_segments
LDI_AH 'b'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_blocks
LDI_AH 'i'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_init
JMP .usage

.do_init
ALUOP_BL %A%+%AL%               # Copy size to BL so we can see it in :trace
LDI_A 0x6000                    # fixed base address in A
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
LD_CH $user_input_tokens+4      # Pointer to second argument in C
LD_CL $user_input_tokens+5
MOV_CH_AL                       # high byte of pointer into AL
ALUOP_FLAGS %A%+%AL%            # check if zer
JZ .usage                       # no second argument if zero, so usage

# Load and check address
CALL :strtoi                    # Convert to number from string pointer in C into in AH+AL, BL has flags
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
.error_command "ERR: invalid subcommand provided\n\0"
.entry_init "Calling :new_malloc_init(0x6000, 0x%x)\n\0"
.entry_blk "Calling :new_malloc_blocks(0x%x)\n\0"
.entry_seg "Calling :new_malloc_segments(0x%x)\n\0"
.entry_free "Calling :new_free(0x%x%x)\n\0"

