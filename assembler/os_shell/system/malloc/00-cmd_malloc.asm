# vim: syntax=asm-mycpu

# Allocate memory

:cmd_malloc

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
LDI_AL 'S'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'b'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'B'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .get_size
LDI_AL 'f'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_free
LDI_C .error_command
CALL :print
JMP .usage

# 's' or 'b' is in BH; check for next argument
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

##### User wants to allocate
# Size is in AL, seg/block is in BH
LDI_AH 's'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_malloc_segments
LDI_AH 'S'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_calloc_segments
LDI_AH 'b'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_malloc_blocks
LDI_AH 'B'
ALUOP_FLAGS %A&B%+%AH%+%BH%
JEQ .do_calloc_blocks
JMP .usage

.do_malloc_blocks
CALL :new_malloc_blocks
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .malloc_print
CALL :printf
RET

.do_calloc_blocks
CALL :new_calloc_blocks
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .calloc_print
CALL :printf
RET

.do_malloc_segments
CALL :new_malloc_segments
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .malloc_print
CALL :printf
RET

.do_calloc_segments
CALL :new_calloc_segments
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .calloc_print
CALL :printf
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
CALL :new_free
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .free_print
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage:\n  malloc [sS] size - malloc / calloc segments\n  malloc [bB] size - malloc / calloc blocks\n  malloc f addr - free memory\n\0"
.error_command "ERR: invalid subcommand provided, expecting one of [sSbBf]\n\0"
.malloc_print "Allocated memory at 0x%x%x\n\0"
.calloc_print "Allocated and cleared memory at 0x%x%x\n\0"
.free_print "Freed memory near 0x%x%x\n\0"
