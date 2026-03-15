CALL .__global_local_init__
JMP :main                        # Initialization complete, go to main function


:main                            # int main( int argc,  char **argv)
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
LDI_BL 22                        # Bytes to allocate for local vars
CALL :heap_advance_BL
LDI_B $frame_count               # Load base address of frame_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for extern unsigned short frame_count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short frame_count
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short frame_count
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short frame_count
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short frame_count
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for extern unsigned short total_frames_remaining
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for extern unsigned char frames_in_buffer
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char frames_in_buffer
LDI_B $playback_frame            # Load base address of playback_frame into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for extern unsigned short playback_frame
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short playback_frame
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short playback_frame
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short playback_frame
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short playback_frame
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of argc at offset -1 into B
MOV_DH_BH                        # Load base address of argc at offset -1 into B
MOV_DL_BL                        # Load base address of argc at offset -1 into B
INCR_D                           # Load base address of argc at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_6        # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_7          # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_4            # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_5              # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_5             # Signed BinaryOp <: Signs were different
.binaryop_equal_4
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_5
.binaryop_overflow_7
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_5
.binaryop_diffsigns_6
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_5             # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_5
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_2            # Condition was true
JMP .end_if_3                    # Done with false condition
.condition_true_2                # Condition was true
CALL .usage
# function returns nothing, not popping a return value
LDI_A 1                          # Constant assignment 1 as int
JMP .main_return_1
.end_if_3                        # End If
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of frames_fsh at offset 3 into A
INCR_D                           # Load base address of frames_fsh at offset 3 into A
INCR_D                           # Load base address of frames_fsh at offset 3 into A
MOV_DH_AH                        # Load base address of frames_fsh at offset 3 into A
MOV_DL_AL                        # Load base address of frames_fsh at offset 3 into A
DECR_D                           # Load base address of frames_fsh at offset 3 into A
DECR_D                           # Load base address of frames_fsh at offset 3 into A
DECR_D                           # Load base address of frames_fsh at offset 3 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of argv at offset -3 into A
DECR_D                           # Load base address of argv at offset -3 into A
DECR_D                           # Load base address of argv at offset -3 into A
MOV_DH_AH                        # Load base address of argv at offset -3 into A
MOV_DL_AL                        # Load base address of argv at offset -3 into A
INCR_D                           # Load base address of argv at offset -3 into A
INCR_D                           # Load base address of argv at offset -3 into A
INCR_D                           # Load base address of argv at offset -3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
ALUOP16O_B %ALU16_A+B%           # Add array offset in A to address reg B, element size 2
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_8               # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_9
.pathfind_err_8
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_9
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *frames_dirent
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *frames_dirent
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *frames_dirent
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *frames_dirent
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0x00 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_AL %A%+%AH%                # BinaryOp >> 8 positions
LDI_AH 0x00                      # BinaryOp >> 8 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_12       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_12       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_13
.binarybool_isfalse_12
LDI_A 0                          # BinaryOp == was false
.binarybool_done_13
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_10           # Condition was true
JMP .end_if_11                   # Done with false condition
.condition_true_10               # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "Error: directory not found\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_A 1                          # Constant assignment 1 as int
JMP .main_return_1
.end_if_11                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1                          # Constant assignment 0x01 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_AL %A%+%AH%                # BinaryOp >> 8 positions
LDI_AH 0x00                      # BinaryOp >> 8 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_16       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_16       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_17
.binarybool_isfalse_16
LDI_A 0                          # BinaryOp == was false
.binarybool_done_17
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_14           # Condition was true
JMP .end_if_15                   # Done with false condition
.condition_true_14               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *frames_dirent to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "ATA error from pathfind: 0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
LDI_A 1                          # Constant assignment 1 as int
JMP .main_return_1
.end_if_15                       # End If
INCR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
INCR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DH_BH                        # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DL_BL                        # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member start_cluster offset to address in A
LDI_B 26                         # Add struct member start_cluster offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member start_cluster offset to address in A
POP_BH                           # Add struct member start_cluster offset to address in A
POP_BL                           # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
ALUOP_PUSH %B%+%BH%              # StructRef member value: Save B
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
ALUOP_AH %B%+%BH%                # Transfer value
ALUOP_AL %B%+%BL%                # Transfer value
POP_BH                           # StructRef member value: Restore B
POP_BL                           # StructRef member value: Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short frames_dir_starting_cluster
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short frames_dir_starting_cluster
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short frames_dir_starting_cluster
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short frames_dir_starting_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
INCR4_D                          # Load base address of starting_clusters at offset 5 into B
INCR_D                           # Load base address of starting_clusters at offset 5 into B
MOV_DH_BH                        # Load base address of starting_clusters at offset 5 into B
MOV_DL_BL                        # Load base address of starting_clusters at offset 5 into B
DECR4_D                          # Load base address of starting_clusters at offset 5 into B
DECR_D                           # Load base address of starting_clusters at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 7                          # Constant assignment 7 as int
LDI_A 2048                       # Constant assignment 2048 as int
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
# Cast  int const (virtual) to  unsigned char 
CALL :calloc_segments            # Allocate segments, size in AL, result in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *starting_clusters
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *starting_clusters
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *starting_clusters
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *starting_clusters
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
INCR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DH_BH                        # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DL_BL                        # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short dir_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
MOV_DH_BH                        # Load base address of frames_fsh at offset 3 into B
MOV_DL_BL                        # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
CALL :fat16_dirwalk_start
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirwalk_ctx *dirwalk_ctx
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirwalk_ctx *dirwalk_ctx
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirwalk_ctx *dirwalk_ctx
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirwalk_ctx *dirwalk_ctx
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0x00 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_AL %A%+%AH%                # BinaryOp >> 8 positions
LDI_AH 0x00                      # BinaryOp >> 8 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
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
JMP .end_if_19                   # Done with false condition
.condition_true_18               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirwalk_ctx *dirwalk_ctx to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
INCR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DH_BH                        # Load base address of frames_dir_starting_cluster at offset 9 into B
MOV_DL_BL                        # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR8_D                          # Load base address of frames_dir_starting_cluster at offset 9 into B
DECR_D                           # Load base address of frames_dir_starting_cluster at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short frames_dir_starting_cluster
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "ATA error reading cluster %X: 0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into B
INCR_D                           # Load base address of starting_clusters at offset 5 into B
MOV_DH_BH                        # Load base address of starting_clusters at offset 5 into B
MOV_DL_BL                        # Load base address of starting_clusters at offset 5 into B
DECR4_D                          # Load base address of starting_clusters at offset 5 into B
DECR_D                           # Load base address of starting_clusters at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
LDI_A 1                          # Constant assignment 1 as int
JMP .main_return_1
.end_if_19                       # End If
CALL :cursor_off
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_3             # "Loading frame metadata...\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_22                    # While loop begin
LDI_A 1                          # Constant assignment 1 as int
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_23               # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_23               # Condition was true
JMP .while_end_24                # Condition was false, end loop
.while_true_23                   # Begin while loop body
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirwalk_ctx *ctx (pointer)
CALL :fat16_dirwalk_next
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *frames_dirent
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *frames_dirent
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *frames_dirent
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *frames_dirent
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0x0000 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
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
JMP .while_end_24                # Break out of loop/switch
.end_if_26                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 16                         # Constant assignment 0x10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member attribute offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member attribute offset to address in A
LDI_B 11                         # Add struct member attribute offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member attribute offset to address in A
POP_BH                           # Add struct member attribute offset to address in A
POP_BL                           # Add struct member attribute offset to address in A
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member attribute offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member attribute offset to address in A
LDI_B 11                         # Add struct member attribute offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member attribute offset to address in A
POP_BH                           # Add struct member attribute offset to address in A
POP_BL                           # Add struct member attribute offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_29           # Condition was true
JMP .end_if_30                   # Done with false condition
.condition_true_29               # Condition was true
JMP .while_top_22                # Continue loop
.end_if_30                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0x00 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_AL %A%+%AH%                # BinaryOp >> 8 positions
LDI_AH 0x00                      # BinaryOp >> 8 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_33       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_33       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_34
.binarybool_isfalse_33
LDI_A 0                          # BinaryOp == was false
.binarybool_done_34
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_31           # Condition was true
JMP .end_if_32                   # Done with false condition
.condition_true_31               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *frames_dirent to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "ATA error reading directory entry: 0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirwalk_ctx *ctx (pointer)
CALL :fat16_dirwalk_end
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into B
INCR_D                           # Load base address of starting_clusters at offset 5 into B
MOV_DH_BH                        # Load base address of starting_clusters at offset 5 into B
MOV_DL_BL                        # Load base address of starting_clusters at offset 5 into B
DECR4_D                          # Load base address of starting_clusters at offset 5 into B
DECR_D                           # Load base address of starting_clusters at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
LDI_A 1                          # Constant assignment 1 as int
JMP .main_return_1
.end_if_32                       # End If
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
CALL :fat16_dirent_filename
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *frame_filename
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *frame_filename
ALUOP_ADDR_B %A%+%AL%            # Store to  char *frame_filename
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *frame_filename
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL '0'                       # Constant assignment '0' for  char strtoi_buf_element (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 'x'                       # Constant assignment 'x' for  char strtoi_buf_element (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of frame_filename at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of frame_filename at offset 11 into A
MOV_DH_AH                        # Load base address of frame_filename at offset 11 into A
MOV_DL_AL                        # Load base address of frame_filename at offset 11 into A
LDI_B 11                         # Load base address of frame_filename at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into A
POP_BH                           # Load base address of frame_filename at offset 11 into A
POP_BL                           # Load base address of frame_filename at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 3                          # Constant assignment 3 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of frame_filename at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of frame_filename at offset 11 into A
MOV_DH_AH                        # Load base address of frame_filename at offset 11 into A
MOV_DL_AL                        # Load base address of frame_filename at offset 11 into A
LDI_B 11                         # Load base address of frame_filename at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into A
POP_BH                           # Load base address of frame_filename at offset 11 into A
POP_BL                           # Load base address of frame_filename at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 4                          # Constant assignment 4 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of frame_filename at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of frame_filename at offset 11 into A
MOV_DH_AH                        # Load base address of frame_filename at offset 11 into A
MOV_DL_AL                        # Load base address of frame_filename at offset 11 into A
LDI_B 11                         # Load base address of frame_filename at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into A
POP_BH                           # Load base address of frame_filename at offset 11 into A
POP_BL                           # Load base address of frame_filename at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 2                          # Constant assignment 2 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 5                          # Constant assignment 5 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of frame_filename at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of frame_filename at offset 11 into A
MOV_DH_AH                        # Load base address of frame_filename at offset 11 into A
MOV_DL_AL                        # Load base address of frame_filename at offset 11 into A
LDI_B 11                         # Load base address of frame_filename at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into A
POP_BH                           # Load base address of frame_filename at offset 11 into A
POP_BL                           # Load base address of frame_filename at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 3                          # Constant assignment 3 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 6                          # Constant assignment 6 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  char strtoi_buf_element (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  char strtoi_buf_element (virtual)
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_flags at offset 22 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_flags at offset 22 into A
MOV_DH_AH                        # Load base address of strtoi_flags at offset 22 into A
MOV_DL_AL                        # Load base address of strtoi_flags at offset 22 into A
LDI_B 22                         # Load base address of strtoi_flags at offset 22 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_flags at offset 22 into A
POP_BH                           # Load base address of strtoi_flags at offset 22 into A
POP_BL                           # Load base address of strtoi_flags at offset 22 into A
CALL :heap_push_A                # Stage flags ptr on heap
ALUOP_PUSH %B%+%BL%              # Load base address of strtoi_buf at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of strtoi_buf at offset 13 into A
MOV_DH_AH                        # Load base address of strtoi_buf at offset 13 into A
MOV_DL_AL                        # Load base address of strtoi_buf at offset 13 into A
LDI_B 13                         # Load base address of strtoi_buf at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_buf at offset 13 into A
POP_BH                           # Load base address of strtoi_buf at offset 13 into A
POP_BL                           # Load base address of strtoi_buf at offset 13 into A
CALL :heap_push_A                # Stage str ptr on heap
PUSH_CH                          # Save C before strtoi
PUSH_CL                          # Save C before strtoi
CALL :heap_pop_C                 # Load str ptr into C
CALL :strtoi
ALUOP_PUSH %A%+%AH%              # Save strtoi result hi
ALUOP_PUSH %A%+%AL%              # Save strtoi result lo
POP_CL                           # Restore C after strtoi
POP_CH                           # Restore C after strtoi
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop flags ptr into D
ALUOP_ADDR_D %B%+%BL%            # Write flags byte to *flags
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
POP_AL                           # Pop strtoi result lo
POP_AH                           # Pop strtoi result hi
# Cast  signed short strtoi (virtual) to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short frame_no
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short frame_no
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of strtoi_flags at offset 22 into B
ALUOP_PUSH %A%+%AH%              # Load base address of strtoi_flags at offset 22 into B
MOV_DH_BH                        # Load base address of strtoi_flags at offset 22 into B
MOV_DL_BL                        # Load base address of strtoi_flags at offset 22 into B
LDI_A 22                         # Load base address of strtoi_flags at offset 22 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_flags at offset 22 into B
POP_AH                           # Load base address of strtoi_flags at offset 22 into B
POP_AL                           # Load base address of strtoi_flags at offset 22 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_35           # Condition was true
JMP .end_if_36                   # Done with false condition
.condition_true_35               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of strtoi_flags at offset 22 into B
ALUOP_PUSH %A%+%AH%              # Load base address of strtoi_flags at offset 22 into B
MOV_DH_BH                        # Load base address of strtoi_flags at offset 22 into B
MOV_DL_BL                        # Load base address of strtoi_flags at offset 22 into B
LDI_A 22                         # Load base address of strtoi_flags at offset 22 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of strtoi_flags at offset 22 into B
POP_AH                           # Load base address of strtoi_flags at offset 22 into B
POP_AL                           # Load base address of strtoi_flags at offset 22 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char strtoi_flags
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *frame_filename
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_5             # "\nBad frame file %s: 0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
JMP .while_top_22                # Continue loop
.end_if_36                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 2048                       # Constant assignment 2048 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_41       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_42         # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_39           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_40             # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_40            # Signed BinaryOp >: Signs were different
.binaryop_equal_39
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_40
.binaryop_overflow_42
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_40
.binaryop_diffsigns_41
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_40            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_40
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_37           # Condition was true
JMP .end_if_38                   # Done with false condition
.condition_true_37               # Condition was true
LDI_A 2048                       # Constant assignment 2048 as int
CALL :heap_push_A                # Push parameter  int const (virtual)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *frame_filename
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_6             # "\nBad frame file %s: larger than %U\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
JMP .while_top_22                # Continue loop
.end_if_38                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_45       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_45       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_46
.binarybool_isfalse_45
LDI_A 0                          # BinaryOp == was false
.binarybool_done_46
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_43           # Condition was true
JMP .end_if_44                   # Done with false condition
.condition_true_43               # Condition was true
LDI_B .var_frame_load_dirent     # Load base address of frame_load_dirent into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY4_C_D                      # Copy bytes 4-7 from C to D
MEMCPY4_C_D                      # Copy bytes 8-11 from C to D
MEMCPY4_C_D                      # Copy bytes 12-15 from C to D
MEMCPY4_C_D                      # Copy bytes 16-19 from C to D
MEMCPY4_C_D                      # Copy bytes 20-23 from C to D
MEMCPY4_C_D                      # Copy bytes 24-27 from C to D
MEMCPY4_C_D                      # Copy bytes 28-31 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_B $frame_segments            # Load base address of frame_segments into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for extern unsigned char frame_segments
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 7                         # Constant assignment 7 for extern unsigned char frame_segments
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member file_size offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member file_size offset to address in A
LDI_B 28                         # Add struct member file_size offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member file_size offset to address in A
POP_BH                           # Add struct member file_size offset to address in A
POP_BL                           # Add struct member file_size offset to address in A
ALUOP_PUSH %B%+%BL%              # Add struct member lo offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member lo offset to address in A
LDI_B 2                          # Add struct member lo offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member lo offset to address in A
POP_BH                           # Add struct member lo offset to address in A
POP_BL                           # Add struct member lo offset to address in A
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member file_size offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member file_size offset to address in A
LDI_B 28                         # Add struct member file_size offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member file_size offset to address in A
POP_BH                           # Add struct member file_size offset to address in A
POP_BL                           # Add struct member file_size offset to address in A
ALUOP_PUSH %B%+%BL%              # Add struct member lo offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member lo offset to address in A
LDI_B 2                          # Add struct member lo offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member lo offset to address in A
POP_BH                           # Add struct member lo offset to address in A
POP_BL                           # Add struct member lo offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
ALUOP_PUSH %B%+%BH%              # StructRef member value: Save B
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
ALUOP_AH %B%+%BH%                # Transfer value
ALUOP_AL %B%+%BL%                # Transfer value
POP_BH                           # StructRef member value: Restore B
POP_BL                           # StructRef member value: Restore B
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
CALL :shift16_a_right            # BinaryOp >> 7 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
# Cast  unsigned short lo to  unsigned char 
ALUOP_AL %A-B%+%AL%+%BL%         # BinaryOp - 1 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char frame_segments
.end_if_44                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short frame_no
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member start_cluster offset to address in A
LDI_B 26                         # Add struct member start_cluster offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member start_cluster offset to address in A
POP_BH                           # Add struct member start_cluster offset to address in A
POP_BL                           # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
ALUOP_PUSH %B%+%BH%              # StructRef member value: Save B
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
ALUOP_AH %B%+%BH%                # Transfer value
ALUOP_AL %B%+%BL%                # Transfer value
POP_BH                           # StructRef member value: Restore B
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_A                # Push parameter  unsigned short start_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *frame_filename
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_7             # "%s at cluster 0x%X -> frame #%U    \r"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of frame_filename at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_filename at offset 11 into B
MOV_DH_BH                        # Load base address of frame_filename at offset 11 into B
MOV_DL_BL                        # Load base address of frame_filename at offset 11 into B
LDI_A 11                         # Load base address of frame_filename at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_filename at offset 11 into B
POP_AH                           # Load base address of frame_filename at offset 11 into B
POP_AL                           # Load base address of frame_filename at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into B
INCR_D                           # Load base address of starting_clusters at offset 5 into B
MOV_DH_BH                        # Load base address of starting_clusters at offset 5 into B
MOV_DL_BL                        # Load base address of starting_clusters at offset 5 into B
DECR4_D                          # Load base address of starting_clusters at offset 5 into B
DECR_D                           # Load base address of starting_clusters at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of frame_no at offset 20 into A
ALUOP_PUSH %B%+%BH%              # Load base address of frame_no at offset 20 into A
MOV_DH_AH                        # Load base address of frame_no at offset 20 into A
MOV_DL_AL                        # Load base address of frame_no at offset 20 into A
LDI_B 20                         # Load base address of frame_no at offset 20 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into A
POP_BH                           # Load base address of frame_no at offset 20 into A
POP_BL                           # Load base address of frame_no at offset 20 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
ALUOP16O_A %ALU16_A+B%           # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_dirent at offset 1 into B
MOV_DH_BH                        # Load base address of frames_dirent at offset 1 into B
MOV_DL_BL                        # Load base address of frames_dirent at offset 1 into B
DECR_D                           # Load base address of frames_dirent at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member start_cluster offset to address in A
LDI_B 26                         # Add struct member start_cluster offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member start_cluster offset to address in A
POP_BH                           # Add struct member start_cluster offset to address in A
POP_BL                           # Add struct member start_cluster offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
ALUOP_PUSH %B%+%BH%              # StructRef member value: Save B
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
ALUOP_AH %B%+%BH%                # Transfer value
ALUOP_AL %B%+%BL%                # Transfer value
POP_BH                           # StructRef member value: Restore B
POP_BL                           # StructRef member value: Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short starting_clusters_element (virtual)
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short starting_clusters_element (virtual)
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short starting_clusters_element (virtual)
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short starting_clusters_element (virtual)
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frame_count               # Load base address of frame_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B $frame_count               # Load base address of frame_count into B
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short frame_count
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short frame_count
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short frame_count
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short frame_count
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .while_top_22                # Next While loop
.while_end_24                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_8             # "\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
INCR_D                           # Load base address of dirwalk_ctx at offset 7 into B
MOV_DH_BH                        # Load base address of dirwalk_ctx at offset 7 into B
MOV_DL_BL                        # Load base address of dirwalk_ctx at offset 7 into B
DECR4_D                          # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
DECR_D                           # Load base address of dirwalk_ctx at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirwalk_ctx *ctx (pointer)
CALL :fat16_dirwalk_end
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frame_count               # Load base address of frame_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter extern unsigned short frame_count
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_9             # "Loaded metadata for %U frames\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL .reserve_extmem_pages
# function returns nothing, not popping a return value
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frame_count               # Load base address of frame_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short frame_no
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short frame_no
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short frame_no
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for extern unsigned char frames_in_buffer
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char frames_in_buffer
LDI_B $ring_write_page           # Load base address of ring_write_page into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 0x05 for extern unsigned char ring_write_page
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char ring_write_page
LDI_B $ring_read_page            # Load base address of ring_read_page into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 6                         # Constant assignment 0x06 for extern unsigned char ring_read_page
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char ring_read_page
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_47                    # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <: Save A for generating rhs
LDI_A 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
# Cast  unsigned char  to  unsigned char 
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A $frames_in_buffer          # Load base address of frames_in_buffer into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_FLAGS %A-B%+%AL%+%BL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_50           # BinaryOp <: check if equal
LDI_BL 1                         # BinaryOp <: assume true
JNO .binaryop_done_51            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_BL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_51
.binaryop_equal_50
LDI_BL 0                         # BinaryOp <: operands equal: false
.binaryop_done_51
POP_AL                           # BinaryOp <: Restore A after use for rhs
POP_AH                           # BinaryOp <: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_56       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_57         # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_54           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_55             # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_55            # Signed BinaryOp >: Signs were different
.binaryop_equal_54
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_55
.binaryop_overflow_57
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_55
.binaryop_diffsigns_56
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_55            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_55
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_58       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_58       # Binary boolean format check, jump if true
JMP .binarybool_done_59          # Binary boolean format check: done
.binarybool_wastrue_58
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_59
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_48               # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_48               # Condition was true
JMP .while_end_49                # Condition was false, end loop
.while_true_48                   # Begin while loop body
LDI_B .var_frame_load_dirent     # Load base address of frame_load_dirent into B
ALUOP_PUSH %A%+%AL%              # Add struct member start_cluster offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member start_cluster offset to address in B
LDI_A 26                         # Add struct member start_cluster offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member start_cluster offset to address in B
POP_AH                           # Add struct member start_cluster offset to address in B
POP_AL                           # Add struct member start_cluster offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into A
INCR_D                           # Load base address of starting_clusters at offset 5 into A
MOV_DH_AH                        # Load base address of starting_clusters at offset 5 into A
MOV_DL_AL                        # Load base address of starting_clusters at offset 5 into A
DECR4_D                          # Load base address of starting_clusters at offset 5 into A
DECR_D                           # Load base address of starting_clusters at offset 5 into A
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
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
ALUOP16O_B %ALU16_A+B%           # Add array offset in A to address reg B, element size 2
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short start_cluster
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short start_cluster
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short start_cluster
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short start_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
MOV_DH_BH                        # Load base address of frames_fsh at offset 3 into B
MOV_DL_BL                        # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *fsh (pointer)
LDI_A .var_frame_load_dirent     # Load base address of frame_load_dirent into A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
CALL .load_frame_from_dirent
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short frame_no
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short frame_no
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # UnaryOp p--: decrement 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p--: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p--: Save B before generating lvalue
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
POP_BL                           # UnaryOp p--: Restore B, return rvalue in A
POP_BH                           # UnaryOp p--: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char ring_write_page
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short frame_no
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_10            # "Loaded frame data for frame %U into page 0x%x\r"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .while_top_47                # Next While loop
.while_end_49                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_8             # "\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_11            # "Starting playback...\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
CALL :start_frame_isr
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_60                    # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_65       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_66         # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_63           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_64             # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_64            # Signed BinaryOp >: Signs were different
.binaryop_equal_63
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_64
.binaryop_overflow_66
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_64
.binaryop_diffsigns_65
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_64            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_64
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_61               # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_61               # Condition was true
JMP .while_end_62                # Condition was false, end loop
.while_true_61                   # Begin while loop body
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_67                    # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
LDI_B 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
# Cast  unsigned char  to  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >=: Subtract to check E and O flags
JEQ .binaryop_equal_70           # BinaryOp >=: check if equal
LDI_AL 0                         # BinaryOp >=: assume true
JNO .binaryop_done_71            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >=: overflow, so true
JMP .binaryop_done_71
.binaryop_equal_70
LDI_AL 1                         # BinaryOp >=: operands equal: true
.binaryop_done_71
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_68               # Condition was true
JMP .while_end_69                # Condition was false, end loop
.while_true_68                   # Begin while loop body
JMP .while_top_67                # Next While loop
.while_end_69                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char ring_write_page
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_read_page            # Load base address of ring_read_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char ring_read_page
LDI_A 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char frames_in_buffer
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frame_count               # Load base address of frame_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter extern unsigned short frame_count
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $playback_frame            # Load base address of playback_frame into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter extern unsigned short playback_frame
PUSH_CH                          # Save C before sprintf
PUSH_CL                          # Save C before sprintf
LDI_C .data_string_12            # "Frame(%U/%U) Buf(%u/%u) R/W page(0x%x/0x%x)"
LDI_A 20160                      # Constant assignment 0x4ec0 as int
# Cast  int const (virtual) to  void 
CALL :heap_push_A                # Stage dest on heap
PUSH_DH                          # Save D before sprintf
PUSH_DL                          # Save D before sprintf
CALL :heap_pop_D                 # Load dest into D
CALL :sprintf
POP_DL                           # Restore D after sprintf
POP_DH                           # Restore D after sprintf
POP_CL                           # Restore C after sprintf
POP_CH                           # Restore C after sprintf
LDI_B .var_frame_load_dirent     # Load base address of frame_load_dirent into B
ALUOP_PUSH %A%+%AL%              # Add struct member start_cluster offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member start_cluster offset to address in B
LDI_A 26                         # Add struct member start_cluster offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member start_cluster offset to address in B
POP_AH                           # Add struct member start_cluster offset to address in B
POP_AL                           # Add struct member start_cluster offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into A
INCR_D                           # Load base address of starting_clusters at offset 5 into A
MOV_DH_AH                        # Load base address of starting_clusters at offset 5 into A
MOV_DL_AL                        # Load base address of starting_clusters at offset 5 into A
DECR4_D                          # Load base address of starting_clusters at offset 5 into A
DECR_D                           # Load base address of starting_clusters at offset 5 into A
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
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
ALUOP16O_B %ALU16_A+B%           # Add array offset in A to address reg B, element size 2
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short start_cluster
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short start_cluster
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short start_cluster
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short start_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
INCR_D                           # Load base address of frames_fsh at offset 3 into B
MOV_DH_BH                        # Load base address of frames_fsh at offset 3 into B
MOV_DL_BL                        # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
DECR_D                           # Load base address of frames_fsh at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *fsh (pointer)
LDI_A .var_frame_load_dirent     # Load base address of frame_load_dirent into A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
CALL .load_frame_from_dirent
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %A%+%AL%              # Load base address of frame_no at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of frame_no at offset 20 into B
MOV_DH_BH                        # Load base address of frame_no at offset 20 into B
MOV_DL_BL                        # Load base address of frame_no at offset 20 into B
LDI_A 20                         # Load base address of frame_no at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of frame_no at offset 20 into B
POP_AH                           # Load base address of frame_no at offset 20 into B
POP_AL                           # Load base address of frame_no at offset 20 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short frame_no
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short frame_no
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short frame_no
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # UnaryOp p--: decrement 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p--: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p--: Save B before generating lvalue
LDI_B $total_frames_remaining    # Load base address of total_frames_remaining into B
ALUOP_ADDR_B %A%+%AH%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned short total_frames_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to extern unsigned short total_frames_remaining
POP_BL                           # UnaryOp p--: Restore B, return rvalue in A
POP_BH                           # UnaryOp p--: Restore B, return rvalue in A
JMP .while_top_60                # Next While loop
.while_end_62                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_74                    # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
# Cast  int const (virtual) to  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_77           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_78            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_78
.binaryop_equal_77
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_78
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_75               # Condition was true
JMP .while_end_76                # Condition was false, end loop
.while_true_75                   # Begin while loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char ring_write_page
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_read_page            # Load base address of ring_read_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char ring_read_page
LDI_A 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
CALL :heap_push_AL               # Push parameter  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter extern unsigned char frames_in_buffer
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frame_count               # Load base address of frame_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter extern unsigned short frame_count
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $playback_frame            # Load base address of playback_frame into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter extern unsigned short playback_frame
PUSH_CH                          # Save C before sprintf
PUSH_CL                          # Save C before sprintf
LDI_C .data_string_12            # "Frame(%U/%U) Buf(%u/%u) R/W page(0x%x/0x%x)"
LDI_A 20160                      # Constant assignment 0x4ec0 as int
# Cast  int const (virtual) to  void 
CALL :heap_push_A                # Stage dest on heap
PUSH_DH                          # Save D before sprintf
PUSH_DL                          # Save D before sprintf
CALL :heap_pop_D                 # Load dest into D
CALL :sprintf
POP_DL                           # Restore D after sprintf
POP_DH                           # Restore D after sprintf
POP_CL                           # Restore C after sprintf
POP_CH                           # Restore C after sprintf
JMP .while_top_74                # Next While loop
.while_end_76                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
CALL :stop_frame_isr
# function returns nothing, not popping a return value
CALL .free_extmem_pages
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # Save A before clear_screen
ALUOP_PUSH %A%+%AL%              # Save A before clear_screen
LDI_A 0                          # Constant assignment 0x00 as int
ALUOP_AH %A%+%AL%                # Copy character to AH
LDI_A 63                         # Constant assignment 0x3f as int
CALL :clear_screen
POP_AL                           # Restore A after clear_screen
POP_AH                           # Restore A after clear_screen
CALL :cursor_init
# function returns nothing, not popping a return value
CALL :cursor_on
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of starting_clusters at offset 5 into B
INCR_D                           # Load base address of starting_clusters at offset 5 into B
MOV_DH_BH                        # Load base address of starting_clusters at offset 5 into B
MOV_DL_BL                        # Load base address of starting_clusters at offset 5 into B
DECR4_D                          # Load base address of starting_clusters at offset 5 into B
DECR_D                           # Load base address of starting_clusters at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
LDI_A 0                          # Constant assignment 0 as int
JMP .main_return_1
.main_return_1
LDI_BL 26                        # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
CALL :heap_push_A                # Return value
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.reserve_extmem_pages            # static void reserve_extmem_pages()
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
LDI_BL 1                         # Bytes to allocate for local vars
CALL :heap_advance_BL
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_13            # "Reserving extended memory pages...\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
.for_condition_82                # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_87           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_88            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_88
.binaryop_equal_87
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_88
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_84            # Condition was true
JMP .for_end_86                  # Condition was false, end loop
.for_cond_true_84                # Begin for loop body
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
LDI_A .var_reserved_pages        # Load base address of reserved_pages into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i at offset 1 into A
MOV_DH_AH                        # Load base address of i at offset 1 into A
MOV_DL_AL                        # Load base address of i at offset 1 into A
DECR_D                           # Load base address of i at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL :extmalloc                  # Allocate extended memory page
CALL :heap_pop_AL                # Pop page number into AL
LDI_AH 0x00                      # Clear AH (byte return)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char reserved_pages_element (virtual)
.for_increment_83                # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_82            # Next for loop iteration
.for_end_86                      # End for loop
.reserve_extmem_pages_return_81
LDI_BL 1                         # Bytes to free from local vars and parameters
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

.free_extmem_pages               # static void free_extmem_pages()
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
LDI_BL 1                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
.for_condition_92                # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 250                        # Constant assignment 250 as int
# Cast  int const (virtual) to  unsigned char 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_97           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_98            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_98
.binaryop_equal_97
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_98
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_94            # Condition was true
JMP .for_end_96                  # Condition was false, end loop
.for_cond_true_94                # Begin for loop body
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
LDI_B .var_reserved_pages        # Load base address of reserved_pages into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push page number for extfree
CALL :extfree                    # Free extended memory page
.for_increment_93                # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_92            # Next for loop iteration
.for_end_96                      # End for loop
.free_extmem_pages_return_91
LDI_BL 1                         # Bytes to free from local vars and parameters
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

.load_frame_from_dirent          # static void load_frame_from_dirent( struct fat16_dirent *dirent,  struct fs_handle *fsh)
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
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B $ring_write_page           # Load base address of ring_write_page into B
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char ring_write_page
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_104      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_105
.binarybool_isfalse_104
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_105
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_102          # Condition was true
JMP .end_if_103                  # Done with false condition
.condition_true_102              # Condition was true
LDI_B $ring_write_page           # Load base address of ring_write_page into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 6                         # Constant assignment 0x06 for extern unsigned char ring_write_page
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char ring_write_page
.end_if_103                      # End If
LDI_B 49664                      # Constant assignment 0xc200 as int
# Cast  int const (virtual) to  unsigned char 
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $ring_write_page           # Load base address of ring_write_page into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char const_deref (virtual)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of fsh at offset -3 into B
DECR_D                           # Load base address of fsh at offset -3 into B
DECR_D                           # Load base address of fsh at offset -3 into B
MOV_DH_BH                        # Load base address of fsh at offset -3 into B
MOV_DL_BL                        # Load base address of fsh at offset -3 into B
INCR_D                           # Load base address of fsh at offset -3 into B
INCR_D                           # Load base address of fsh at offset -3 into B
INCR_D                           # Load base address of fsh at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
LDI_B .var_load_frame_from_dirent_d_window # Load base address of d_window into B
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
DECR_D                           # Load base address of dirent at offset -1 into B
MOV_DH_BH                        # Load base address of dirent at offset -1 into B
MOV_DL_BL                        # Load base address of dirent at offset -1 into B
INCR_D                           # Load base address of dirent at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
LDI_B .var_load_frame_from_dirent_null_ptr # Load base address of null_ptr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_readfile_ctx *state (pointer)
CALL :fat16_readfile
CALL :heap_pop_AL
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B $frames_in_buffer          # Load base address of frames_in_buffer into B
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char frames_in_buffer
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
.load_frame_from_dirent_return_101
LDI_BL 4                         # Bytes to free from local vars and parameters
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

.usage                           # static void usage()
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
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_14            # "Usage: asciivid <directory>\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.usage_return_106
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
LDI_B .var_load_frame_from_dirent_d_window # Load base address of d_window into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 53248                      # Constant assignment 0xd000 for pointer static void *d_window
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static void *d_window
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static void *d_window
ALUOP_ADDR_B %A%+%AL%            # Store to static void *d_window
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static void *d_window
LDI_B .var_load_frame_from_dirent_null_ptr # Load base address of null_ptr into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0x0000 for pointer static void *null_ptr
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static void *null_ptr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static void *null_ptr
ALUOP_ADDR_B %A%+%AL%            # Store to static void *null_ptr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static void *null_ptr
RET
.data_string_0 "Error: directory not found\n\0"
.data_string_1 "ATA error from pathfind: 0x%x\n\0"
.data_string_2 "ATA error reading cluster %X: 0x%x\n\0"
.data_string_3 "Loading frame metadata...\n\0"
.data_string_4 "ATA error reading directory entry: 0x%x\n\0"
.data_string_5 "\nBad frame file %s: 0x%x\n\0"
.data_string_6 "\nBad frame file %s: larger than %U\n\0"
.data_string_7 "%s at cluster 0x%X -> frame #%U    \r\0"
.data_string_8 "\n\0"
.data_string_9 "Loaded metadata for %U frames\n\0"
.data_string_10 "Loaded frame data for frame %U into page 0x%x\r\0"
.data_string_11 "Starting playback...\n\0"
.data_string_12 "Frame(%U/%U) Buf(%u/%u) R/W page(0x%x/0x%x)\0"
.data_string_13 "Reserving extended memory pages...\n\0"
.data_string_14 "Usage: asciivid <directory>\n\0"
.var_frame_load_dirent "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.var_reserved_pages "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.var_load_frame_from_dirent_d_window "\0\0"
.var_load_frame_from_dirent_null_ptr "\0\0"
