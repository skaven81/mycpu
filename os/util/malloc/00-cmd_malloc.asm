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
LDI_AL 'l'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_stats
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
CALL :malloc_blocks
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .malloc_print
CALL :printf
RET

.do_calloc_blocks
CALL :calloc_blocks
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .calloc_print
CALL :printf
RET

.do_malloc_segments
CALL :malloc_segments
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .malloc_print
CALL :printf
RET

.do_calloc_segments
CALL :calloc_segments
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
CALL :free
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .free_print
CALL :printf
RET

##### User wants to get memory usage stats
# First stats line, malloc address range
.do_stats
LD_AH $malloc_range_start
LD_AL $malloc_range_start+1     # starting address in A
LDI_BH 0x00
LD_BL $malloc_segments          # number of segments in B
CALL :shift16_b_left            # Shift left seven times to get total bytes
CALL :shift16_b_left
CALL :shift16_b_left
CALL :shift16_b_left
CALL :shift16_b_left
CALL :shift16_b_left
CALL :shift16_b_left
ALUOP16O_B %ALU16_B-1%                  # subtract 1 to get the last byte in the range
ALUOP16O_B %ALU16_A+B%                # add total bytes to start address to get end address
CALL :heap_push_BL
CALL :heap_push_BH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .stats_1
CALL :printf

# Second stats line, total, free and used blocks

# Count up the free and used memory blocks
LD_BL $malloc_segments          # Get the allocated number of segments into BL
LDI_BH 0x00                     # Clear BH so we can shift all of B
CALL :shift16_b_left            # Shift left three times to get the number of
CALL :shift16_b_left            # | blocks, which is also the number of ledger
CALL :shift16_b_left            # | bytes we will be examining
CALL :extpage_d_push_zero       # get the zero page set in D page
LDI_C 0xd000                    # start at the beginning of the ledger
LDI_D 0x0000                    # We'll count used blocks in D
.count_loop
LDA_C_AL                        # load the ledger byte into AL
ALUOP_FLAGS %A%+%AL%
JZ .free_byte
INCR_D                          # count used block
.free_byte
INCR_C                          # move to next ledger byte
ALUOP16O_B %ALU16_B-1%                  # decrement counter
ALUOP_FLAGS %B%+%BH%
JNZ .count_loop
ALUOP_FLAGS %B%+%BL%
JNZ .count_loop
# D now contains count of allocated blocks
CALL :heap_push_D               # push to heap for printf

MOV_DH_BH                       # move to B for doing math
MOV_DL_BL

LD_AL $malloc_segments          # Get the allocated number of segments into BL
LDI_AH 0x00                     # Clear BH so we can shift all of B
CALL :shift16_a_left            # Shift left three times to get the total number of blocks
CALL :shift16_a_left
CALL :shift16_a_left

ALUOP16O_A %ALU16_A-B%           # A~free_blocks = total_blocks - allocated_blocks
CALL :heap_push_A
ALUOP16O_A %ALU16_A+B%                # A~total_blocks = free_blocks + allocated_blocks
CALL :heap_push_A

LDI_C .stats_2
CALL :printf

# Remaining stats lines: list allocated ranges
LD_BL $malloc_segments          # Get the allocated number of segments into BL
LDI_BH 0x00                     # Clear BH so we can shift all of B
CALL :shift16_b_left            # Shift left three times to get the number of
CALL :shift16_b_left            # | blocks, which is also the number of ledger
CALL :shift16_b_left            # | bytes we will be examining
LDI_C 0xd000                    # start at the beginning of the ledger
DECR_C                          # prepare for going into loop
.list_loop
INCR_C                          # move to next ledger byte
LDA_C_AL                        # load the ledger byte into AL
ALUOP_FLAGS %A%+%AL%
JZ .list_ignore
ALUOP_FLAGS %A+1%+%AL%
JO .list_ignore

ALUOP_PUSH %B%+%BL%
LDI_BL 0xf0
ALUOP_BL %A&B%+%AL%+%BL%                # BL will be 0xf0 if ledger byte was 0xfn
LDI_AH 0xf0
ALUOP_FLAGS %A&B%+%AH%+%BL%             # equal bit will be set if this was a block allocation
POP_BL
JEQ .block_alloc

.seg_alloc
LDI_AH 0x00
CALL :shift16_a_left
CALL :shift16_a_left
CALL :shift16_a_left
CALL :heap_push_A
JMP .push_addr

.block_alloc
ALUOP_PUSH %B%+%BL%
LDI_BL 0x0f
ALUOP_AL %A&B%+%AL%+%BL%
LDI_AH 0x00
CALL :heap_push_A
POP_BL

.push_addr
MOV_CH_AH
MOV_CL_AL
CALL :malloc_ledger_to_addr     # A contains real address of the memory
CALL :heap_push_AL
CALL :heap_push_AH
PUSH_CH
PUSH_CL
LDI_C .stats_3
CALL :printf
POP_CL
POP_CH

.list_ignore
ALUOP16O_B %ALU16_B-1%                  # decrement counter
ALUOP_FLAGS %B%+%BH%
JNZ .list_loop
ALUOP_FLAGS %B%+%BL%
JNZ .list_loop

CALL :extpage_d_pop
CALL :heap_pop_byte             # discard the zero page value
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage:\n  malloc [sS] size - malloc / calloc segments\n  malloc [bB] size - malloc / calloc blocks\n  malloc f addr - free memory\n  malloc l - list allocations and memory stats\n\0"
.error_command "ERR: invalid subcommand provided, expecting one of [sSbBf]\n\0"
.malloc_print "Allocated memory at 0x%x%x\n\0"
.calloc_print "Allocated and cleared memory at 0x%x%x\n\0"
.free_print "Freed memory near 0x%x%x\n\0"
.stats_1 "Malloc range 0x%x%x-0x%x%x\n\0"
.stats_2 "%U total allocatable 16-byte blocks, %U free, %U allocated\n\0"
.stats_3 "0x%x%x %U blocks\n\0"
