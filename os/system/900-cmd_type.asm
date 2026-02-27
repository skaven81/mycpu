CALL .__global_local_init__

:cmd_type                        # void cmd_type()
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_BL 8                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
MOV_DH_BH                        # Load base address of path at offset 3 into B
MOV_DL_BL                        # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 as int
CALL :shell_get_argv_n           # Get argv[n] string address into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *path
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *path
ALUOP_ADDR_B %A%+%AL%            # Store to  char *path
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *path
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
MOV_DH_BH                        # Load base address of path at offset 3 into B
MOV_DL_BL                        # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_4        # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_4        # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_5
.binarybool_isfalse_4
LDI_A 0                          # BinaryOp == was false
.binarybool_done_5
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_2            # Condition was true
JMP .end_if_3                    # Done with false condition
.condition_true_2                # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "Usage: type PATH\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .cmd_type_return_1
.end_if_3                        # End If
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of h at offset 5 into A
INCR_D                           # Load base address of h at offset 5 into A
MOV_DH_AH                        # Load base address of h at offset 5 into A
MOV_DL_AL                        # Load base address of h at offset 5 into A
DECR4_D                          # Load base address of h at offset 5 into A
DECR_D                           # Load base address of h at offset 5 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
INCR_D                           # Load base address of path at offset 3 into B
MOV_DH_BH                        # Load base address of path at offset 3 into B
MOV_DL_BL                        # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
DECR_D                           # Load base address of path at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_6               # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_7
.pathfind_err_6
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_7
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR_D                           # Load base address of entry_raw at offset 1 into B
MOV_DH_BH                        # Load base address of entry_raw at offset 1 into B
MOV_DL_BL                        # Load base address of entry_raw at offset 1 into B
DECR_D                           # Load base address of entry_raw at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short entry_raw
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short entry_raw
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short entry_raw
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short entry_raw
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of entry_raw at offset 1 into B
MOV_DH_BH                        # Load base address of entry_raw at offset 1 into B
MOV_DL_BL                        # Load base address of entry_raw at offset 1 into B
DECR_D                           # Load base address of entry_raw at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_10       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_10       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_11
.binarybool_isfalse_10
LDI_A 0                          # BinaryOp == was false
.binarybool_done_11
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_8            # Condition was true
JMP .end_if_9                    # Done with false condition
.condition_true_8                # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "File not found\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .cmd_type_return_1
.end_if_9                        # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of entry_raw at offset 1 into B
MOV_DH_BH                        # Load base address of entry_raw at offset 1 into B
MOV_DL_BL                        # Load base address of entry_raw at offset 1 into B
DECR_D                           # Load base address of entry_raw at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A%+%AH%                # BinaryOp >> 8 positions
LDI_AH 0x00                      # BinaryOp >> 8 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_16       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_17         # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_14           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_15             # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_15            # Signed BinaryOp <: Signs were different
.binaryop_equal_14
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_15
.binaryop_overflow_17
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_15
.binaryop_diffsigns_16
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_15            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_15
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_12           # Condition was true
JMP .end_if_13                   # Done with false condition
.condition_true_12               # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of entry_raw at offset 1 into B
MOV_DH_BH                        # Load base address of entry_raw at offset 1 into B
MOV_DL_BL                        # Load base address of entry_raw at offset 1 into B
DECR_D                           # Load base address of entry_raw at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_20       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_20       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_21
.binarybool_isfalse_20
LDI_A 0                          # BinaryOp == was false
.binarybool_done_21
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_18           # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00ff as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of entry_raw at offset 1 into B
MOV_DH_BH                        # Load base address of entry_raw at offset 1 into B
MOV_DL_BL                        # Load base address of entry_raw at offset 1 into B
DECR_D                           # Load base address of entry_raw at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
# Cast  unsigned short entry_raw to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "ATA error: %x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .end_if_19                   # Done with false condition
.condition_true_18               # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_3             # "Error: unparseable path spec\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_19                       # End If
JMP .cmd_type_return_1
.end_if_13                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 16                         # Constant assignment 0x10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
CALL :fat16_dirent_attribute
CALL :heap_pop_AL
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_22           # Condition was true
JMP .end_if_23                   # Done with false condition
.condition_true_22               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "Path is a directory, not a file\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .cmd_type_return_1
.end_if_23                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of h at offset 5 into B
INCR_D                           # Load base address of h at offset 5 into B
MOV_DH_BH                        # Load base address of h at offset 5 into B
MOV_DL_BL                        # Load base address of h at offset 5 into B
DECR4_D                          # Load base address of h at offset 5 into B
DECR_D                           # Load base address of h at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *entry (pointer)
CALL .print_file
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
INCR_D                           # Load base address of entry at offset 7 into B
MOV_DH_BH                        # Load base address of entry at offset 7 into B
MOV_DL_BL                        # Load base address of entry at offset 7 into B
DECR4_D                          # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
DECR_D                           # Load base address of entry at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.cmd_type_return_1
LDI_BL 8                         # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.print_file                      # static void print_file( struct fat16_dirent *entry,  struct fs_handle *h)
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_BL 14                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of size_lo at offset 3 into B
INCR_D                           # Load base address of size_lo at offset 3 into B
INCR_D                           # Load base address of size_lo at offset 3 into B
MOV_DH_BH                        # Load base address of size_lo at offset 3 into B
MOV_DL_BL                        # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of size_hi at offset 1 into A
MOV_DH_AH                        # Load base address of size_hi at offset 1 into A
MOV_DL_AL                        # Load base address of size_hi at offset 1 into A
DECR_D                           # Load base address of size_hi at offset 1 into A
CALL :heap_push_A                # Save size_hi output pointer on heap
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of entry at offset -1 into B
MOV_DH_BH                        # Load base address of entry at offset -1 into B
MOV_DL_BL                        # Load base address of entry at offset -1 into B
INCR_D                           # Load base address of entry at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push dirent address param
CALL :fat16_dirent_filesize
CALL :heap_pop_A                 # Pop lo word of file size (return value)
ALUOP_PUSH %A%+%AH%              # Save return value
ALUOP_PUSH %A%+%AL%              # Save return value
CALL :heap_pop_A                 # Pop hi word of file size
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop size_hi output pointer
ALUOP_ADDR_D %A%+%AH%            # Store hi byte at *size_hi
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store lo byte at *(size_hi+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short size_lo
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short size_lo
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short size_lo
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short size_lo
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 as int
CALL :calloc_blocks              # Allocate+zero blocks, size in AL, result in A
# Cast  void *calloc_blocks (virtual) to  struct fat16_readfile_ctx 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_readfile_ctx *ctx
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_readfile_ctx *ctx
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_readfile_ctx *ctx
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_readfile_ctx *ctx
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_27       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_27       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_28
.binarybool_isfalse_27
LDI_A 0                          # BinaryOp == was false
.binarybool_done_28
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_25           # Condition was true
JMP .end_if_26                   # Done with false condition
.condition_true_25               # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_5             # "Out of memory\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .print_file_return_24
.end_if_26                       # End If
INCR4_D                          # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
MOV_DH_BH                        # Load base address of page at offset 7 into B
MOV_DL_BL                        # Load base address of page at offset 7 into B
DECR4_D                          # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL :extmalloc                  # Allocate extended memory page
CALL :heap_pop_AL                # Pop page number into AL
LDI_AH 0x00                      # Clear AH (byte return)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char page
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
MOV_DH_BH                        # Load base address of page at offset 7 into B
MOV_DL_BL                        # Load base address of page at offset 7 into B
DECR4_D                          # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_31       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_32
.binarybool_isfalse_31
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_32
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_29           # Condition was true
JMP .end_if_30                   # Done with false condition
.condition_true_29               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_6             # "Out of ext memory\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .print_file_return_24
.end_if_30                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
MOV_DH_BH                        # Load base address of page at offset 7 into B
MOV_DL_BL                        # Load base address of page at offset 7 into B
DECR4_D                          # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push page number for extpage_d_push
CALL :extpage_d_push             # Map page into D-window
ALUOP_PUSH %A%+%AL%              # Load base address of d_buf at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of d_buf at offset 13 into B
MOV_DH_BH                        # Load base address of d_buf at offset 13 into B
MOV_DL_BL                        # Load base address of d_buf at offset 13 into B
LDI_A 13                         # Load base address of d_buf at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of d_buf at offset 13 into B
POP_AH                           # Load base address of d_buf at offset 13 into B
POP_AL                           # Load base address of d_buf at offset 13 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 53248                      # Constant assignment 0xD000 for pointer  char *d_buf
# Cast  int const (virtual) to  char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *d_buf
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *d_buf
ALUOP_ADDR_B %A%+%AL%            # Store to  char *d_buf
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *d_buf
INCR8_D                          # Load base address of remaining at offset 8 into B
MOV_DH_BH                        # Load base address of remaining at offset 8 into B
MOV_DL_BL                        # Load base address of remaining at offset 8 into B
DECR8_D                          # Load base address of remaining at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of size_lo at offset 3 into B
INCR_D                           # Load base address of size_lo at offset 3 into B
INCR_D                           # Load base address of size_lo at offset 3 into B
MOV_DH_BH                        # Load base address of size_lo at offset 3 into B
MOV_DL_BL                        # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
DECR_D                           # Load base address of size_lo at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short remaining
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short remaining
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_33                    # While loop begin
LDI_A 1                          # Constant assignment 1 as int
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_34               # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_34               # Condition was true
JMP .while_end_35                # Condition was false, end loop
.while_true_34                   # Begin while loop body
ALUOP_PUSH %A%+%AL%              # Load base address of status at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of status at offset 12 into B
MOV_DH_BH                        # Load base address of status at offset 12 into B
MOV_DL_BL                        # Load base address of status at offset 12 into B
LDI_A 12                         # Load base address of status at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of status at offset 12 into B
POP_AH                           # Load base address of status at offset 12 into B
POP_AL                           # Load base address of status at offset 12 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of h at offset -3 into B
DECR_D                           # Load base address of h at offset -3 into B
DECR_D                           # Load base address of h at offset -3 into B
MOV_DH_BH                        # Load base address of h at offset -3 into B
MOV_DL_BL                        # Load base address of h at offset -3 into B
INCR_D                           # Load base address of h at offset -3 into B
INCR_D                           # Load base address of h at offset -3 into B
INCR_D                           # Load base address of h at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of d_buf at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of d_buf at offset 13 into B
MOV_DH_BH                        # Load base address of d_buf at offset 13 into B
MOV_DL_BL                        # Load base address of d_buf at offset 13 into B
LDI_A 13                         # Load base address of d_buf at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of d_buf at offset 13 into B
POP_AH                           # Load base address of d_buf at offset 13 into B
POP_AL                           # Load base address of d_buf at offset 13 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  void *dest (pointer)
LDI_A 8                          # Constant assignment 8 for  unsigned short n_sectors
CALL :heap_push_A                # Push parameter  unsigned short n_sectors
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of entry at offset -1 into B
MOV_DH_BH                        # Load base address of entry at offset -1 into B
MOV_DL_BL                        # Load base address of entry at offset -1 into B
INCR_D                           # Load base address of entry at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_readfile_ctx *state (pointer)
CALL :fat16_readfile
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char status
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of status at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of status at offset 12 into B
MOV_DH_BH                        # Load base address of status at offset 12 into B
MOV_DL_BL                        # Load base address of status at offset 12 into B
LDI_A 12                         # Load base address of status at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of status at offset 12 into B
POP_AH                           # Load base address of status at offset 12 into B
POP_AL                           # Load base address of status at offset 12 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_38        # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_39
.binarybool_istrue_38
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_39
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_36           # Condition was true
JMP .end_if_37                   # Done with false condition
.condition_true_36               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of status at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of status at offset 12 into B
MOV_DH_BH                        # Load base address of status at offset 12 into B
MOV_DL_BL                        # Load base address of status at offset 12 into B
LDI_A 12                         # Load base address of status at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of status at offset 12 into B
POP_AH                           # Load base address of status at offset 12 into B
POP_AL                           # Load base address of status at offset 12 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char status
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "ATA error: %x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .while_end_35                # Break out of loop/switch
.end_if_37                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 4096                       # Constant assignment 4096 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of remaining at offset 8 into B
MOV_DH_BH                        # Load base address of remaining at offset 8 into B
MOV_DL_BL                        # Load base address of remaining at offset 8 into B
DECR8_D                          # Load base address of remaining at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_44       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_45         # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_42           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_43             # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_43            # Signed BinaryOp >: Signs were different
.binaryop_equal_42
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_43
.binaryop_overflow_45
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_43
.binaryop_diffsigns_44
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_43            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_43
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_40           # Condition was true
ALUOP_PUSH %A%+%AL%              # Load base address of to_print at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of to_print at offset 10 into B
MOV_DH_BH                        # Load base address of to_print at offset 10 into B
MOV_DL_BL                        # Load base address of to_print at offset 10 into B
LDI_A 10                         # Load base address of to_print at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of to_print at offset 10 into B
POP_AH                           # Load base address of to_print at offset 10 into B
POP_AL                           # Load base address of to_print at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of remaining at offset 8 into B
MOV_DH_BH                        # Load base address of remaining at offset 8 into B
MOV_DL_BL                        # Load base address of remaining at offset 8 into B
DECR8_D                          # Load base address of remaining at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short to_print
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short to_print
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short to_print
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short to_print
JMP .end_if_41                   # Done with false condition
.condition_true_40               # Condition was true
ALUOP_PUSH %A%+%AL%              # Load base address of to_print at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of to_print at offset 10 into B
MOV_DH_BH                        # Load base address of to_print at offset 10 into B
MOV_DL_BL                        # Load base address of to_print at offset 10 into B
LDI_A 10                         # Load base address of to_print at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of to_print at offset 10 into B
POP_AH                           # Load base address of to_print at offset 10 into B
POP_AL                           # Load base address of to_print at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4096                       # Constant assignment 4096 for  unsigned short to_print
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short to_print
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short to_print
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short to_print
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short to_print
.end_if_41                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of to_print at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of to_print at offset 10 into B
MOV_DH_BH                        # Load base address of to_print at offset 10 into B
MOV_DL_BL                        # Load base address of to_print at offset 10 into B
LDI_A 10                         # Load base address of to_print at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of to_print at offset 10 into B
POP_AH                           # Load base address of to_print at offset 10 into B
POP_AL                           # Load base address of to_print at offset 10 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short count
LDI_A 53248                      # Constant assignment 0xD000 for  unsigned short addr
CALL :heap_push_A                # Push parameter  unsigned short addr
CALL .print_bytes
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of remaining at offset 8 into B
MOV_DH_BH                        # Load base address of remaining at offset 8 into B
MOV_DL_BL                        # Load base address of remaining at offset 8 into B
DECR8_D                          # Load base address of remaining at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of to_print at offset 10 into A
ALUOP_PUSH %B%+%BH%              # Load base address of to_print at offset 10 into A
MOV_DH_AH                        # Load base address of to_print at offset 10 into A
MOV_DL_AL                        # Load base address of to_print at offset 10 into A
LDI_B 10                         # Load base address of to_print at offset 10 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of to_print at offset 10 into A
POP_BH                           # Load base address of to_print at offset 10 into A
POP_BL                           # Load base address of to_print at offset 10 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of remaining at offset 8 into B
MOV_DH_BH                        # Load base address of remaining at offset 8 into B
MOV_DL_BL                        # Load base address of remaining at offset 8 into B
DECR8_D                          # Load base address of remaining at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short remaining
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short remaining
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp ==: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp ==: Save A for generating rhs
LDI_A 0                          # Constant assignment 0 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR8_D                          # Load base address of remaining at offset 8 into A
MOV_DH_AH                        # Load base address of remaining at offset 8 into A
MOV_DL_AL                        # Load base address of remaining at offset 8 into A
DECR8_D                          # Load base address of remaining at offset 8 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_48       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_48       # BinaryOp == is false
LDI_B 1                          # BinaryOp == was true
JMP .binarybool_done_49
.binarybool_isfalse_48
LDI_B 0                          # BinaryOp == was false
.binarybool_done_49
POP_AL                           # BinaryOp ==: Restore A after use for rhs
POP_AH                           # BinaryOp ==: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 2                          # Constant assignment 0x02 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP16_A %A|B%+%AL%+%BL% %A|B%+%AH%+%BH% # BinaryOp || 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_50       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_50       # Binary boolean format check, jump if true
JMP .binarybool_done_51          # Binary boolean format check: done
.binarybool_wastrue_50
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_51
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_46           # Condition was true
JMP .end_if_47                   # Done with false condition
.condition_true_46               # Condition was true
JMP .while_end_35                # Break out of loop/switch
.end_if_47                       # End If
JMP .while_top_33                # Next While loop
.while_end_35                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
CALL :extpage_d_pop              # Restore previous D-window mapping
CALL :heap_pop_AL                # Pop restored page number into AL
LDI_AH 0x00                      # Clear AH (byte return)
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
INCR_D                           # Load base address of page at offset 7 into B
MOV_DH_BH                        # Load base address of page at offset 7 into B
MOV_DL_BL                        # Load base address of page at offset 7 into B
DECR4_D                          # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
DECR_D                           # Load base address of page at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push page number for extfree
CALL :extfree                    # Free extended memory page
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ctx at offset 5 into B
INCR_D                           # Load base address of ctx at offset 5 into B
MOV_DH_BH                        # Load base address of ctx at offset 5 into B
MOV_DL_BL                        # Load base address of ctx at offset 5 into B
DECR4_D                          # Load base address of ctx at offset 5 into B
DECR_D                           # Load base address of ctx at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.print_file_return_24
LDI_BL 18                        # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.print_bytes                     # static void print_bytes( unsigned short addr,  unsigned short count)
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_BL 4                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of p at offset 3 into B
INCR_D                           # Load base address of p at offset 3 into B
INCR_D                           # Load base address of p at offset 3 into B
MOV_DH_BH                        # Load base address of p at offset 3 into B
MOV_DL_BL                        # Load base address of p at offset 3 into B
DECR_D                           # Load base address of p at offset 3 into B
DECR_D                           # Load base address of p at offset 3 into B
DECR_D                           # Load base address of p at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of addr at offset -1 into B
MOV_DH_BH                        # Load base address of addr at offset -1 into B
MOV_DL_BL                        # Load base address of addr at offset -1 into B
INCR_D                           # Load base address of addr at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
# Cast  unsigned short addr to  char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *p
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *p
ALUOP_ADDR_B %A%+%AL%            # Store to  char *p
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *p
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short i
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short i
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short i
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short i
.for_condition_53                # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of count at offset -3 into A
DECR_D                           # Load base address of count at offset -3 into A
DECR_D                           # Load base address of count at offset -3 into A
MOV_DH_AH                        # Load base address of count at offset -3 into A
MOV_DL_AL                        # Load base address of count at offset -3 into A
INCR_D                           # Load base address of count at offset -3 into A
INCR_D                           # Load base address of count at offset -3 into A
INCR_D                           # Load base address of count at offset -3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_58           # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_59            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_59
.binaryop_equal_58
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_59
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
JNZ .for_cond_sub_true_56        # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check for condition
JNZ .for_cond_sub_true_56        # Condition was true
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JMP .for_end_57                  # Condition was false, end loop
.for_cond_sub_true_56
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
.for_cond_true_55                # Begin for loop body
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of p at offset 3 into A
INCR_D                           # Load base address of p at offset 3 into A
INCR_D                           # Load base address of p at offset 3 into A
MOV_DH_AH                        # Load base address of p at offset 3 into A
MOV_DL_AL                        # Load base address of p at offset 3 into A
DECR_D                           # Load base address of p at offset 3 into A
DECR_D                           # Load base address of p at offset 3 into A
DECR_D                           # Load base address of p at offset 3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :putchar                    # Print character in AL
.for_increment_54                # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short i
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short i
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short i
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_53            # Next for loop iteration
.for_end_57                      # End for loop
.print_bytes_return_52
LDI_BL 8                         # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.__global_local_init__
RET
.data_string_0 "Usage: type PATH\n\0"
.data_string_1 "File not found\n\0"
.data_string_2 "ATA error: %x\n\0"
.data_string_3 "Error: unparseable path spec\n\0"
.data_string_4 "Path is a directory, not a file\n\0"
.data_string_5 "Out of memory\n\0"
.data_string_6 "Out of ext memory\n\0"
