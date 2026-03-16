CALL .__global_local_init__
JMP :main                        # Initialization complete, go to main function


:fail                            # void fail( char *name)
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
LDI_B .var_failed_tests          # Load base address of failed_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_failed_tests          # Load base address of failed_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short failed_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short failed_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short failed_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short failed_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "FAIL: "
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of name at offset -1 into A
MOV_DH_AH                        # Load base address of name at offset -1 into A
MOV_DL_AL                        # Load base address of name at offset -1 into A
INCR_D                           # Load base address of name at offset -1 into A
LDA_A_CH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_CL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in C
POP_AL                           # Restore A, pointer value in C
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.fail_return_1
LDI_BL 2                         # Bytes to free from local vars and parameters
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

:test_u8_vs_literal              # void test_u8_vs_literal()
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
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_5            # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_6             # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_6
.binaryop_equal_5
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_6
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_3            # Condition was true
JMP .end_if_4                    # Done with false condition
.condition_true_3                # Condition was true
LDI_A .data_string_2             # "u8: 0>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_4                        # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_11           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_12            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_12
.binaryop_equal_11
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_12
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_15         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_16            # Unary boolean NOT: done
.unarynot_wastrue_15
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_16
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_9            # Condition was true
JMP .end_if_10                   # Done with false condition
.condition_true_9                # Condition was true
LDI_A .data_string_3             # "u8: 1>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_10                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 127                       # Constant assignment 127 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_19           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_20            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_20
.binaryop_equal_19
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_20
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_23         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_24            # Unary boolean NOT: done
.unarynot_wastrue_23
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_24
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_17           # Condition was true
JMP .end_if_18                   # Done with false condition
.condition_true_17               # Condition was true
LDI_A .data_string_4             # "u8: 127>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_18                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 127                       # Constant assignment 127 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 128                        # Constant assignment 128 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_27           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_28            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_28
.binaryop_equal_27
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_28
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_31         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_32            # Unary boolean NOT: done
.unarynot_wastrue_31
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_32
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_25           # Condition was true
JMP .end_if_26                   # Done with false condition
.condition_true_25               # Condition was true
LDI_A .data_string_5             # "u8: 127<128 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_26                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_35           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_36            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_36
.binaryop_equal_35
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_36
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_39         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_40            # Unary boolean NOT: done
.unarynot_wastrue_39
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_40
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_33           # Condition was true
JMP .end_if_34                   # Done with false condition
.condition_true_33               # Condition was true
LDI_A .data_string_6             # "u8: 128>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_34                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_43           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_44            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_44
.binaryop_equal_43
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_44
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_47         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_48            # Unary boolean NOT: done
.unarynot_wastrue_47
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_48
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_41           # Condition was true
JMP .end_if_42                   # Done with false condition
.condition_true_41               # Condition was true
LDI_A .data_string_7             # "u8: 128>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_42                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 127                        # Constant assignment 127 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_51           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_52            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_52
.binaryop_equal_51
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_52
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_55         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_56            # Unary boolean NOT: done
.unarynot_wastrue_55
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_56
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_49           # Condition was true
JMP .end_if_50                   # Done with false condition
.condition_true_49               # Condition was true
LDI_A .data_string_8             # "u8: 128>127 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_50                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_59           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_60            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_60
.binaryop_equal_59
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_60
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_63         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_64            # Unary boolean NOT: done
.unarynot_wastrue_63
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_64
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_57           # Condition was true
JMP .end_if_58                   # Done with false condition
.condition_true_57               # Condition was true
LDI_A .data_string_9             # "u8: 200>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_58                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_67           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_68            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_68
.binaryop_equal_67
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_68
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_71         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_72            # Unary boolean NOT: done
.unarynot_wastrue_71
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_72
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_65           # Condition was true
JMP .end_if_66                   # Done with false condition
.condition_true_65               # Condition was true
LDI_A .data_string_10            # "u8: 200>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_66                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_75           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_76            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_76
.binaryop_equal_75
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_76
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_79         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_80            # Unary boolean NOT: done
.unarynot_wastrue_79
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_80
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_73           # Condition was true
JMP .end_if_74                   # Done with false condition
.condition_true_73               # Condition was true
LDI_A .data_string_11            # "u8: 255>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_74                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 254                        # Constant assignment 254 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_83           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_84            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_84
.binaryop_equal_83
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_84
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_87         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_88            # Unary boolean NOT: done
.unarynot_wastrue_87
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_88
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_81           # Condition was true
JMP .end_if_82                   # Done with false condition
.condition_true_81               # Condition was true
LDI_A .data_string_12            # "u8: 255>254 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_82                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 200                        # Constant assignment 200 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_91           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_92            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_92
.binaryop_equal_91
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_92
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_89           # Condition was true
JMP .end_if_90                   # Done with false condition
.condition_true_89               # Condition was true
LDI_A .data_string_13            # "u8: 200>200 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_90                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
LDI_B 200                        # Constant assignment 200 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >=: Subtract to check E and O flags
JEQ .binaryop_equal_97           # BinaryOp >=: check if equal
LDI_AL 0                         # BinaryOp >=: assume true
JNO .binaryop_done_98            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >=: overflow, so true
JMP .binaryop_done_98
.binaryop_equal_97
LDI_AL 1                         # BinaryOp >=: operands equal: true
.binaryop_done_98
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_101        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_102           # Unary boolean NOT: done
.unarynot_wastrue_101
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_102
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_95           # Condition was true
JMP .end_if_96                   # Done with false condition
.condition_true_95               # Condition was true
LDI_A .data_string_14            # "u8: 200>=200 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_96                       # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 255                        # Constant assignment 255 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_105          # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_106           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_106
.binaryop_equal_105
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_106
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_109        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_110           # Unary boolean NOT: done
.unarynot_wastrue_109
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_110
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_103          # Condition was true
JMP .end_if_104                  # Done with false condition
.condition_true_103              # Condition was true
LDI_A .data_string_15            # "u8: 200<255 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_104                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 200                        # Constant assignment 200 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_113          # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_114           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_114
.binaryop_equal_113
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_114
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_111          # Condition was true
JMP .end_if_112                  # Done with false condition
.condition_true_111              # Condition was true
LDI_A .data_string_16            # "u8: 255<200 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_112                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_119       # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_120
.binarybool_istrue_119
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_120
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_121        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_122           # Unary boolean NOT: done
.unarynot_wastrue_121
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_122
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_117          # Condition was true
JMP .end_if_118                  # Done with false condition
.condition_true_117              # Condition was true
LDI_A .data_string_17            # "u8: 200!=0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_118                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 200                        # Constant assignment 200 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_125      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_126
.binarybool_isfalse_125
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_126
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_127        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_128           # Unary boolean NOT: done
.unarynot_wastrue_127
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_128
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_123          # Condition was true
JMP .end_if_124                  # Done with false condition
.condition_true_123              # Condition was true
LDI_A .data_string_18            # "u8: 200==200 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_124                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_131       # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_132
.binarybool_istrue_131
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_132
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_133        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_134           # Unary boolean NOT: done
.unarynot_wastrue_133
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_134
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_129          # Condition was true
JMP .end_if_130                  # Done with false condition
.condition_true_129              # Condition was true
LDI_A .data_string_19            # "u8: 128!=0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_130                      # End If
.test_u8_vs_literal_return_2
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

:test_s8_vs_literal              # void test_s8_vs_literal()
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
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  signed char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_140      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_141        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_138          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_AL 0                         # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_139            # Signed BinaryOp >: result non-negative, return default
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_139           # Signed BinaryOp >: Signs were different
.binaryop_equal_138
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_139
.binaryop_overflow_141
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_139
.binaryop_diffsigns_140
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_139           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_139
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_136          # Condition was true
JMP .end_if_137                  # Done with false condition
.condition_true_136              # Condition was true
LDI_A .data_string_20            # "s8: 0>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_137                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  signed char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_146      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_147        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_144          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_AL 0                         # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_145            # Signed BinaryOp >: result non-negative, return default
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_145           # Signed BinaryOp >: Signs were different
.binaryop_equal_144
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_145
.binaryop_overflow_147
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_145
.binaryop_diffsigns_146
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_145           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_145
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_148        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_149           # Unary boolean NOT: done
.unarynot_wastrue_148
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_149
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_142          # Condition was true
JMP .end_if_143                  # Done with false condition
.condition_true_142              # Condition was true
LDI_A .data_string_21            # "s8: 1>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_143                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 127                       # Constant assignment 127 for  signed char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_154      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_155        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_152          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_AL 0                         # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_153            # Signed BinaryOp >: result non-negative, return default
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_153           # Signed BinaryOp >: Signs were different
.binaryop_equal_152
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_153
.binaryop_overflow_155
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_153
.binaryop_diffsigns_154
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_153           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_153
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_156        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_157           # Unary boolean NOT: done
.unarynot_wastrue_156
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_157
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_150          # Condition was true
JMP .end_if_151                  # Done with false condition
.condition_true_150              # Condition was true
LDI_A .data_string_22            # "s8: 127>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_151                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_162      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_163        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_160          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_AL 0                         # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_161            # Signed BinaryOp >: result non-negative, return default
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_161           # Signed BinaryOp >: Signs were different
.binaryop_equal_160
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_161
.binaryop_overflow_163
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_161
.binaryop_diffsigns_162
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_161           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_161
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_158          # Condition was true
JMP .end_if_159                  # Done with false condition
.condition_true_158              # Condition was true
LDI_A .data_string_23            # "s8: -1>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_159                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -128                      # Load constant value, inverted 128
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_168      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_169        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_166          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_AL 0                         # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_167            # Signed BinaryOp >: result non-negative, return default
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_167           # Signed BinaryOp >: Signs were different
.binaryop_equal_166
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_167
.binaryop_overflow_169
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_167
.binaryop_diffsigns_168
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_167           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_167
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_164          # Condition was true
JMP .end_if_165                  # Done with false condition
.condition_true_164              # Condition was true
LDI_A .data_string_24            # "s8: -128>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_165                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 10                         # Constant assignment 10 as int
CALL :signed_invert_b            # Unary negation
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb%+%AL%          # Sign extend AL: check sign bit
LDI_AH 0x00                      # Sign extend AL: assume sign bit not set
JZ .sign_extend_172              # Sign extend AL: don't overwrite AH if sign bit was not set
LDI_AH 0xff                      # Sign extend AL: sign bit was set
.sign_extend_172                 # Sign extend AL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_176      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_177        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_174          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_175            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_175           # Signed BinaryOp >: Signs were different
.binaryop_equal_174
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_175
.binaryop_overflow_177
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_175
.binaryop_diffsigns_176
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_175           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_175
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_178        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_179           # Unary boolean NOT: done
.unarynot_wastrue_178
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_179
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_170          # Condition was true
JMP .end_if_171                  # Done with false condition
.condition_true_170              # Condition was true
LDI_A .data_string_25            # "s8: -1>-10 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_171                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -10                       # Load constant value, inverted 10
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
CALL :signed_invert_b            # Unary negation
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb%+%AL%          # Sign extend AL: check sign bit
LDI_AH 0x00                      # Sign extend AL: assume sign bit not set
JZ .sign_extend_182              # Sign extend AL: don't overwrite AH if sign bit was not set
LDI_AH 0xff                      # Sign extend AL: sign bit was set
.sign_extend_182                 # Sign extend AL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_186      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_187        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_184          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_185            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_185           # Signed BinaryOp >: Signs were different
.binaryop_equal_184
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_185
.binaryop_overflow_187
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_185
.binaryop_diffsigns_186
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_185           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_185
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_180          # Condition was true
JMP .end_if_181                  # Done with false condition
.condition_true_180              # Condition was true
LDI_A .data_string_26            # "s8: -10>-1 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_181                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -128                      # Load constant value, inverted 128
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_192      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_193        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_190          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of result (negative means B<A)
LDI_AL 1                         # Signed BinaryOp <: result non-negative: B>=A -> true
JZ .binaryop_done_191            # Signed BinaryOp <: result non-negative, return default
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_191           # Signed BinaryOp <: Signs were different
.binaryop_equal_190
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_191
.binaryop_overflow_193
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_191
.binaryop_diffsigns_192
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_191           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_191
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_194        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_195           # Unary boolean NOT: done
.unarynot_wastrue_194
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_195
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_188          # Condition was true
JMP .end_if_189                  # Done with false condition
.condition_true_188              # Condition was true
LDI_A .data_string_27            # "s8: -128<0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_189                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_200      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_201        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_198          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of result (negative means B<A)
LDI_AL 1                         # Signed BinaryOp <: result non-negative: B>=A -> true
JZ .binaryop_done_199            # Signed BinaryOp <: result non-negative, return default
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_199           # Signed BinaryOp <: Signs were different
.binaryop_equal_198
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_199
.binaryop_overflow_201
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_199
.binaryop_diffsigns_200
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_199           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_199
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_202        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_203           # Unary boolean NOT: done
.unarynot_wastrue_202
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_203
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_196          # Condition was true
JMP .end_if_197                  # Done with false condition
.condition_true_196              # Condition was true
LDI_A .data_string_28            # "s8: -1<0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_197                      # End If
.test_s8_vs_literal_return_135
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

:test_u16_vs_literal             # void test_u16_vs_literal()
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
LDI_BL 2                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_207          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_208           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_208
.binaryop_equal_207
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_208
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_205          # Condition was true
JMP .end_if_206                  # Done with false condition
.condition_true_205              # Condition was true
LDI_A .data_string_29            # "u16: 0>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_206                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_213          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_214           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_214
.binaryop_equal_213
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_214
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_217        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_217        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_218           # Unary boolean NOT: done
.unarynot_wastrue_217
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_218
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_211          # Condition was true
JMP .end_if_212                  # Done with false condition
.condition_true_211              # Condition was true
LDI_A .data_string_30            # "u16: 1>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_212                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 32768                      # Constant assignment 32768 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_221          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_222           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_222
.binaryop_equal_221
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_222
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_225        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_225        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_226           # Unary boolean NOT: done
.unarynot_wastrue_225
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_226
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_219          # Condition was true
JMP .end_if_220                  # Done with false condition
.condition_true_219              # Condition was true
LDI_A .data_string_31            # "u16: 32768>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_220                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 32768                      # Constant assignment 32768 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_229          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_230           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_230
.binaryop_equal_229
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_230
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_233        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_233        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_234           # Unary boolean NOT: done
.unarynot_wastrue_233
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_234
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_227          # Condition was true
JMP .end_if_228                  # Done with false condition
.condition_true_227              # Condition was true
LDI_A .data_string_32            # "u16: 32768>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_228                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 65535                      # Constant assignment 65535 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_237          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_238           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_238
.binaryop_equal_237
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_238
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_241        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_241        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_242           # Unary boolean NOT: done
.unarynot_wastrue_241
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_242
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_235          # Condition was true
JMP .end_if_236                  # Done with false condition
.condition_true_235              # Condition was true
LDI_A .data_string_33            # "u16: 65535>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_236                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 65535                      # Constant assignment 65535 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 60000                      # Constant assignment 60000 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_245          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_246           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_246
.binaryop_equal_245
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_246
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_249        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_249        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_250           # Unary boolean NOT: done
.unarynot_wastrue_249
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_250
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_243          # Condition was true
JMP .end_if_244                  # Done with false condition
.condition_true_243              # Condition was true
LDI_A .data_string_34            # "u16: 65535>60000 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_244                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 60000                      # Constant assignment 60000 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 65535                      # Constant assignment 65535 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_253          # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_254           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_254
.binaryop_equal_253
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_254
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_257        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_257        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_258           # Unary boolean NOT: done
.unarynot_wastrue_257
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_258
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_251          # Condition was true
JMP .end_if_252                  # Done with false condition
.condition_true_251              # Condition was true
LDI_A .data_string_35            # "u16: 60000<65535 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_252                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 60000                      # Constant assignment 60000 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 65535                      # Constant assignment 65535 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_261          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_262           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_262
.binaryop_equal_261
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_262
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_259          # Condition was true
JMP .end_if_260                  # Done with false condition
.condition_true_259              # Condition was true
LDI_A .data_string_36            # "u16: 60000>65535 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_260                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 32768                      # Constant assignment 32768 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 32767                      # Constant assignment 32767 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_267          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_268           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_268
.binaryop_equal_267
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_268
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_271        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_271        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_272           # Unary boolean NOT: done
.unarynot_wastrue_271
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_272
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_265          # Condition was true
JMP .end_if_266                  # Done with false condition
.condition_true_265              # Condition was true
LDI_A .data_string_37            # "u16: 32768>32767 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_266                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 60000                      # Constant assignment 60000 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_275       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_275       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_276
.binarybool_istrue_275
LDI_A 1                          # BinaryOp != was true
.binarybool_done_276
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_277        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_277        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_278           # Unary boolean NOT: done
.unarynot_wastrue_277
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_278
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_273          # Condition was true
JMP .end_if_274                  # Done with false condition
.condition_true_273              # Condition was true
LDI_A .data_string_38            # "u16: 60000!=0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_274                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 60000                      # Constant assignment 60000 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 60000                      # Constant assignment 60000 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_281      # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_281      # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_282
.binarybool_isfalse_281
LDI_A 0                          # BinaryOp == was false
.binarybool_done_282
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_283        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_283        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_284           # Unary boolean NOT: done
.unarynot_wastrue_283
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_284
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_279          # Condition was true
JMP .end_if_280                  # Done with false condition
.condition_true_279              # Condition was true
LDI_A .data_string_39            # "u16: 60000==60000 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_280                      # End If
.test_u16_vs_literal_return_204
LDI_BL 2                         # Bytes to free from local vars and parameters
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

:test_s16_vs_literal             # void test_s16_vs_literal()
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
LDI_BL 2                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  signed short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_290      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_291        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_288          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_289            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_289           # Signed BinaryOp >: Signs were different
.binaryop_equal_288
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_289
.binaryop_overflow_291
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_289
.binaryop_diffsigns_290
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_289           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_289
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_286          # Condition was true
JMP .end_if_287                  # Done with false condition
.condition_true_286              # Condition was true
LDI_A .data_string_40            # "s16: 0>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_287                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 for  signed short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_296      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_297        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_294          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_295            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_295           # Signed BinaryOp >: Signs were different
.binaryop_equal_294
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_295
.binaryop_overflow_297
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_295
.binaryop_diffsigns_296
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_295           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_295
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_298        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_298        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_299           # Unary boolean NOT: done
.unarynot_wastrue_298
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_299
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_292          # Condition was true
JMP .end_if_293                  # Done with false condition
.condition_true_292              # Condition was true
LDI_A .data_string_41            # "s16: 1>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_293                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1                         # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_304      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_305        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_302          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_303            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_303           # Signed BinaryOp >: Signs were different
.binaryop_equal_302
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_303
.binaryop_overflow_305
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_303
.binaryop_diffsigns_304
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_303           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_303
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_300          # Condition was true
JMP .end_if_301                  # Done with false condition
.condition_true_300              # Condition was true
LDI_A .data_string_42            # "s16: -1>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_301                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -32768                     # Load constant value, inverted 32768
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_310      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_311        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_308          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_309            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_309           # Signed BinaryOp >: Signs were different
.binaryop_equal_308
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_309
.binaryop_overflow_311
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_309
.binaryop_diffsigns_310
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_309           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_309
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_306          # Condition was true
JMP .end_if_307                  # Done with false condition
.condition_true_306              # Condition was true
LDI_A .data_string_43            # "s16: -32768>0 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_307                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1                         # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 100                        # Constant assignment 100 as int
CALL :signed_invert_b            # Unary negation
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_316      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_317        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_314          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_315            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_315           # Signed BinaryOp >: Signs were different
.binaryop_equal_314
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_315
.binaryop_overflow_317
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_315
.binaryop_diffsigns_316
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_315           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_315
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_318        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_318        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_319           # Unary boolean NOT: done
.unarynot_wastrue_318
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_319
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_312          # Condition was true
JMP .end_if_313                  # Done with false condition
.condition_true_312              # Condition was true
LDI_A .data_string_44            # "s16: -1>-100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_313                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -100                       # Load constant value, inverted 100
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
CALL :signed_invert_b            # Unary negation
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_324      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_325        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_322          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_323            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_323           # Signed BinaryOp >: Signs were different
.binaryop_equal_322
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_323
.binaryop_overflow_325
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_323
.binaryop_diffsigns_324
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_323           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_323
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_320          # Condition was true
JMP .end_if_321                  # Done with false condition
.condition_true_320              # Condition was true
LDI_A .data_string_45            # "s16: -100>-1 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_321                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1                         # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_330      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_331        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_328          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of result (negative means B<A)
LDI_A 1                          # Signed BinaryOp <: result non-negative: B>=A -> true
JZ .binaryop_done_329            # Signed BinaryOp <: result non-negative, return default
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_329           # Signed BinaryOp <: Signs were different
.binaryop_equal_328
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_329
.binaryop_overflow_331
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_329
.binaryop_diffsigns_330
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_329           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_329
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_332        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_332        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_333           # Unary boolean NOT: done
.unarynot_wastrue_332
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_333
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_326          # Condition was true
JMP .end_if_327                  # Done with false condition
.condition_true_326              # Condition was true
LDI_A .data_string_46            # "s16: -1<0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_327                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 32767                      # Constant assignment 32767 for  signed short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short a
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_338      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_339        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_336          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_337            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_337           # Signed BinaryOp >: Signs were different
.binaryop_equal_336
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_337
.binaryop_overflow_339
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_337
.binaryop_diffsigns_338
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_337           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_337
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_340        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_340        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_341           # Unary boolean NOT: done
.unarynot_wastrue_340
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_341
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_334          # Condition was true
JMP .end_if_335                  # Done with false condition
.condition_true_334              # Condition was true
LDI_A .data_string_47            # "s16: 32767>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_335                      # End If
.test_s16_vs_literal_return_285
LDI_BL 2                         # Bytes to free from local vars and parameters
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

:test_u8_vs_u8                   # void test_u8_vs_u8()
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
LDI_BL 2                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 100                       # Constant assignment 100 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_345          # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_346           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_346
.binaryop_equal_345
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_346
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_349        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_350           # Unary boolean NOT: done
.unarynot_wastrue_349
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_350
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_343          # Condition was true
JMP .end_if_344                  # Done with false condition
.condition_true_343              # Condition was true
LDI_A .data_string_48            # "u8 vs u8: 200>100 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_344                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_353          # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_354           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_354
.binaryop_equal_353
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_354
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_351          # Condition was true
JMP .end_if_352                  # Done with false condition
.condition_true_351              # Condition was true
LDI_A .data_string_49            # "u8 vs u8: 200>200 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_352                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 127                       # Constant assignment 127 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_359          # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_360           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_360
.binaryop_equal_359
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_360
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_363        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_364           # Unary boolean NOT: done
.unarynot_wastrue_363
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_364
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_357          # Condition was true
JMP .end_if_358                  # Done with false condition
.condition_true_357              # Condition was true
LDI_A .data_string_50            # "u8 vs u8: 128>127 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_358                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_367          # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_368           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_368
.binaryop_equal_367
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_368
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_371        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_372           # Unary boolean NOT: done
.unarynot_wastrue_371
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_372
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_365          # Condition was true
JMP .end_if_366                  # Done with false condition
.condition_true_365              # Condition was true
LDI_A .data_string_51            # "u8 vs u8: 255>0 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_366                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_375          # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_376           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_376
.binaryop_equal_375
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_376
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_379        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_380           # Unary boolean NOT: done
.unarynot_wastrue_379
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_380
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_373          # Condition was true
JMP .end_if_374                  # Done with false condition
.condition_true_373              # Condition was true
LDI_A .data_string_52            # "u8 vs u8: 0<255 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_374                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_383          # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_384           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_384
.binaryop_equal_383
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_384
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_387        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_388           # Unary boolean NOT: done
.unarynot_wastrue_387
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_388
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_381          # Condition was true
JMP .end_if_382                  # Done with false condition
.condition_true_381              # Condition was true
LDI_A .data_string_53            # "u8 vs u8: 200>128 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_382                      # End If
.test_u8_vs_u8_return_342
LDI_BL 2                         # Bytes to free from local vars and parameters
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

:test_u8_vs_s8                   # void test_u8_vs_s8()
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
LDI_BL 2                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 100                       # Constant assignment 100 for  signed char b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP_FLAGS %Bmsb%+%BL%          # Sign extend BL: check sign bit
LDI_BH 0x00                      # Sign extend BL: assume sign bit not set
JZ .sign_extend_392              # Sign extend BL: don't overwrite BH if sign bit was not set
LDI_BH 0xff                      # Sign extend BL: sign bit was set
.sign_extend_392                 # Sign extend BL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_396      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_397        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_394          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_395            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_395           # Signed BinaryOp >: Signs were different
.binaryop_equal_394
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_395
.binaryop_overflow_397
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_395
.binaryop_diffsigns_396
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_395           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_395
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_398        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_399           # Unary boolean NOT: done
.unarynot_wastrue_398
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_399
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_390          # Condition was true
JMP .end_if_391                  # Done with false condition
.condition_true_390              # Condition was true
LDI_A .data_string_54            # "u8 vs s8: 200>s8(100) should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_391                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP_FLAGS %Bmsb%+%BL%          # Sign extend BL: check sign bit
LDI_BH 0x00                      # Sign extend BL: assume sign bit not set
JZ .sign_extend_402              # Sign extend BL: don't overwrite BH if sign bit was not set
LDI_BH 0xff                      # Sign extend BL: sign bit was set
.sign_extend_402                 # Sign extend BL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_406      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_407        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_404          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_405            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_405           # Signed BinaryOp >: Signs were different
.binaryop_equal_404
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_405
.binaryop_overflow_407
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_405
.binaryop_diffsigns_406
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_405           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_405
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_408        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_409           # Unary boolean NOT: done
.unarynot_wastrue_408
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_409
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_400          # Condition was true
JMP .end_if_401                  # Done with false condition
.condition_true_400              # Condition was true
LDI_A .data_string_55            # "u8 vs s8: 200>s8(-1) should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_401                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP_FLAGS %Bmsb%+%BL%          # Sign extend BL: check sign bit
LDI_BH 0x00                      # Sign extend BL: assume sign bit not set
JZ .sign_extend_412              # Sign extend BL: don't overwrite BH if sign bit was not set
LDI_BH 0xff                      # Sign extend BL: sign bit was set
.sign_extend_412                 # Sign extend BL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_416      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_417        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_414          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_415            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_415           # Signed BinaryOp >: Signs were different
.binaryop_equal_414
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_415
.binaryop_overflow_417
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_415
.binaryop_diffsigns_416
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_415           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_415
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_418        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_419           # Unary boolean NOT: done
.unarynot_wastrue_418
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_419
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_410          # Condition was true
JMP .end_if_411                  # Done with false condition
.condition_true_410              # Condition was true
LDI_A .data_string_56            # "u8 vs s8: 0>s8(-1) should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_411                      # End If
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 128 for  unsigned char a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a
INCR_D                           # Load base address of b at offset 2 into B
INCR_D                           # Load base address of b at offset 2 into B
MOV_DH_BH                        # Load base address of b at offset 2 into B
MOV_DL_BL                        # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
DECR_D                           # Load base address of b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char b
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b at offset 2 into A
INCR_D                           # Load base address of b at offset 2 into A
MOV_DH_AH                        # Load base address of b at offset 2 into A
MOV_DL_AL                        # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
DECR_D                           # Load base address of b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a at offset 1 into B
MOV_DH_BH                        # Load base address of a at offset 1 into B
MOV_DL_BL                        # Load base address of a at offset 1 into B
DECR_D                           # Load base address of a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP_FLAGS %Bmsb%+%BL%          # Sign extend BL: check sign bit
LDI_BH 0x00                      # Sign extend BL: assume sign bit not set
JZ .sign_extend_422              # Sign extend BL: don't overwrite BH if sign bit was not set
LDI_BH 0xff                      # Sign extend BL: sign bit was set
.sign_extend_422                 # Sign extend BL
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_426      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_427        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_424          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Compute B-A to determine ordering
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of result (negative means B<A)
LDI_A 0                          # Signed BinaryOp >: result non-negative: B>=A -> false
JZ .binaryop_done_425            # Signed BinaryOp >: result non-negative, return default
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_425           # Signed BinaryOp >: Signs were different
.binaryop_equal_424
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_425
.binaryop_overflow_427
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_425
.binaryop_diffsigns_426
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_425           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_425
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_428        # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_429           # Unary boolean NOT: done
.unarynot_wastrue_428
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_429
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_420          # Condition was true
JMP .end_if_421                  # Done with false condition
.condition_true_420              # Condition was true
LDI_A .data_string_57            # "u8 vs s8: 128>s8(-1) should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_421                      # End If
.test_u8_vs_s8_return_389
LDI_BL 2                         # Bytes to free from local vars and parameters
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

:test_strtoi_result              # void test_strtoi_result()
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
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of flags at offset 4 into A
MOV_DH_AH                        # Load base address of flags at offset 4 into A
MOV_DL_AL                        # Load base address of flags at offset 4 into A
DECR4_D                          # Load base address of flags at offset 4 into A
CALL :heap_push_A                # Stage flags ptr on heap
LDI_A .data_string_58            # "0x0000"
CALL :heap_push_A                # Stage str ptr on heap
PUSH_CH                          # Save C before strtoi
PUSH_CL                          # Save C before strtoi
CALL :heap_pop_C                 # Load str ptr into C
CALL :strtoi
POP_CL                           # Restore C after strtoi
POP_CH                           # Restore C after strtoi
ALUOP_PUSH %A%+%AH%              # Save strtoi result hi
ALUOP_PUSH %A%+%AL%              # Save strtoi result lo
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
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of flags at offset 4 into B
MOV_DH_BH                        # Load base address of flags at offset 4 into B
MOV_DL_BL                        # Load base address of flags at offset 4 into B
DECR4_D                          # Load base address of flags at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_431          # Condition was true
JMP .end_if_432                  # Done with false condition
.condition_true_431              # Condition was true
LDI_A .data_string_59            # "strtoi 0x0000: flags should be 0 (success)"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_432                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_435       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_435       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_436
.binarybool_istrue_435
LDI_A 1                          # BinaryOp != was true
.binarybool_done_436
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_433          # Condition was true
JMP .end_if_434                  # Done with false condition
.condition_true_433              # Condition was true
LDI_A .data_string_60            # "strtoi 0x0000: result should be 0"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_434                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 2048                       # Constant assignment 2048 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_439          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_440           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_440
.binaryop_equal_439
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_440
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_437          # Condition was true
JMP .end_if_438                  # Done with false condition
.condition_true_437              # Condition was true
LDI_A .data_string_61            # "strtoi 0x0000: 0 > 2048 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_438                      # End If
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of flags at offset 4 into A
MOV_DH_AH                        # Load base address of flags at offset 4 into A
MOV_DL_AL                        # Load base address of flags at offset 4 into A
DECR4_D                          # Load base address of flags at offset 4 into A
CALL :heap_push_A                # Stage flags ptr on heap
LDI_A .data_string_62            # "0x0800"
CALL :heap_push_A                # Stage str ptr on heap
PUSH_CH                          # Save C before strtoi
PUSH_CL                          # Save C before strtoi
CALL :heap_pop_C                 # Load str ptr into C
CALL :strtoi
POP_CL                           # Restore C after strtoi
POP_CH                           # Restore C after strtoi
ALUOP_PUSH %A%+%AH%              # Save strtoi result hi
ALUOP_PUSH %A%+%AL%              # Save strtoi result lo
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
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of flags at offset 4 into B
MOV_DH_BH                        # Load base address of flags at offset 4 into B
MOV_DL_BL                        # Load base address of flags at offset 4 into B
DECR4_D                          # Load base address of flags at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_443          # Condition was true
JMP .end_if_444                  # Done with false condition
.condition_true_443              # Condition was true
LDI_A .data_string_63            # "strtoi 0x0800: flags should be 0 (success)"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_444                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 2048                       # Constant assignment 2048 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_447       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_447       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_448
.binarybool_istrue_447
LDI_A 1                          # BinaryOp != was true
.binarybool_done_448
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_445          # Condition was true
JMP .end_if_446                  # Done with false condition
.condition_true_445              # Condition was true
LDI_A .data_string_64            # "strtoi 0x0800: result should be 2048"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_446                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 2048                       # Constant assignment 2048 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_451          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_452           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_452
.binaryop_equal_451
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_452
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_449          # Condition was true
JMP .end_if_450                  # Done with false condition
.condition_true_449              # Condition was true
LDI_A .data_string_65            # "strtoi 0x0800: 2048 > 2048 should be false"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_450                      # End If
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of flags at offset 4 into A
MOV_DH_AH                        # Load base address of flags at offset 4 into A
MOV_DL_AL                        # Load base address of flags at offset 4 into A
DECR4_D                          # Load base address of flags at offset 4 into A
CALL :heap_push_A                # Stage flags ptr on heap
LDI_A .data_string_66            # "0x0801"
CALL :heap_push_A                # Stage str ptr on heap
PUSH_CH                          # Save C before strtoi
PUSH_CL                          # Save C before strtoi
CALL :heap_pop_C                 # Load str ptr into C
CALL :strtoi
POP_CL                           # Restore C after strtoi
POP_CH                           # Restore C after strtoi
ALUOP_PUSH %A%+%AH%              # Save strtoi result hi
ALUOP_PUSH %A%+%AL%              # Save strtoi result lo
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
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of flags at offset 4 into B
MOV_DH_BH                        # Load base address of flags at offset 4 into B
MOV_DL_BL                        # Load base address of flags at offset 4 into B
DECR4_D                          # Load base address of flags at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_455          # Condition was true
JMP .end_if_456                  # Done with false condition
.condition_true_455              # Condition was true
LDI_A .data_string_67            # "strtoi 0x0801: flags should be 0 (success)"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_456                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 2049                       # Constant assignment 2049 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_459       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_459       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_460
.binarybool_istrue_459
LDI_A 1                          # BinaryOp != was true
.binarybool_done_460
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_457          # Condition was true
JMP .end_if_458                  # Done with false condition
.condition_true_457              # Condition was true
LDI_A .data_string_68            # "strtoi 0x0801: result should be 2049"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_458                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 2048                       # Constant assignment 2048 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of frame_no at offset 1 into B
MOV_DH_BH                        # Load base address of frame_no at offset 1 into B
MOV_DL_BL                        # Load base address of frame_no at offset 1 into B
DECR_D                           # Load base address of frame_no at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_463          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_464           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_464
.binaryop_equal_463
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_464
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_467        # Unary boolean NOT, jump if true
ALUOP_FLAGS %A%+%AH%             # Unary boolean NOT
JNZ .unarynot_wastrue_467        # Unary boolean NOT, jump if true
LDI_A 1                          # Unary boolan NOT, is false: return true
JMP .unarynot_done_468           # Unary boolean NOT: done
.unarynot_wastrue_467
LDI_A 0                          # Unary boolan NOT, is true: return false
.unarynot_done_468
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_461          # Condition was true
JMP .end_if_462                  # Done with false condition
.condition_true_461              # Condition was true
LDI_A .data_string_69            # "strtoi 0x0801: 2049 > 2048 should be true"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail
# function returns nothing, not popping a return value
.end_if_462                      # End If
.test_strtoi_result_return_430
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

:main                            # void main()
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
LDI_C .data_string_70            # "=== cmptest: Comparison Operator Tests ===\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_u8_vs_literal
# function returns nothing, not popping a return value
CALL :test_s8_vs_literal
# function returns nothing, not popping a return value
CALL :test_u16_vs_literal
# function returns nothing, not popping a return value
CALL :test_s16_vs_literal
# function returns nothing, not popping a return value
CALL :test_u8_vs_u8
# function returns nothing, not popping a return value
CALL :test_u8_vs_s8
# function returns nothing, not popping a return value
CALL :test_strtoi_result
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_failed_tests          # Load base address of failed_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short failed_tests
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total_tests           # Load base address of total_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short total_tests
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_71            # "Total: %U  Failed: %U\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_failed_tests          # Load base address of failed_tests into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_472      # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_472      # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_473
.binarybool_isfalse_472
LDI_A 0                          # BinaryOp == was false
.binarybool_done_473
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_470          # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_72            # "SOME TESTS FAILED\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .end_if_471                  # Done with false condition
.condition_true_470              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_73            # "ALL TESTS PASSED\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_471                      # End If
.main_return_469
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
LDI_B .var_total_tests           # Load base address of total_tests into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short total_tests
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total_tests
LDI_B .var_failed_tests          # Load base address of failed_tests into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short failed_tests
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short failed_tests
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short failed_tests
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short failed_tests
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short failed_tests
RET
.data_string_0 "FAIL: \0"
.data_string_1 "\n\0"
.data_string_2 "u8: 0>0 should be false\0"
.data_string_3 "u8: 1>0 should be true\0"
.data_string_4 "u8: 127>100 should be true\0"
.data_string_5 "u8: 127<128 should be true\0"
.data_string_6 "u8: 128>0 should be true\0"
.data_string_7 "u8: 128>100 should be true\0"
.data_string_8 "u8: 128>127 should be true\0"
.data_string_9 "u8: 200>0 should be true\0"
.data_string_10 "u8: 200>100 should be true\0"
.data_string_11 "u8: 255>0 should be true\0"
.data_string_12 "u8: 255>254 should be true\0"
.data_string_13 "u8: 200>200 should be false\0"
.data_string_14 "u8: 200>=200 should be true\0"
.data_string_15 "u8: 200<255 should be true\0"
.data_string_16 "u8: 255<200 should be false\0"
.data_string_17 "u8: 200!=0 should be true\0"
.data_string_18 "u8: 200==200 should be true\0"
.data_string_19 "u8: 128!=0 should be true\0"
.data_string_20 "s8: 0>0 should be false\0"
.data_string_21 "s8: 1>0 should be true\0"
.data_string_22 "s8: 127>100 should be true\0"
.data_string_23 "s8: -1>0 should be false\0"
.data_string_24 "s8: -128>0 should be false\0"
.data_string_25 "s8: -1>-10 should be true\0"
.data_string_26 "s8: -10>-1 should be false\0"
.data_string_27 "s8: -128<0 should be true\0"
.data_string_28 "s8: -1<0 should be true\0"
.data_string_29 "u16: 0>0 should be false\0"
.data_string_30 "u16: 1>0 should be true\0"
.data_string_31 "u16: 32768>0 should be true\0"
.data_string_32 "u16: 32768>100 should be true\0"
.data_string_33 "u16: 65535>0 should be true\0"
.data_string_34 "u16: 65535>60000 should be true\0"
.data_string_35 "u16: 60000<65535 should be true\0"
.data_string_36 "u16: 60000>65535 should be false\0"
.data_string_37 "u16: 32768>32767 should be true\0"
.data_string_38 "u16: 60000!=0 should be true\0"
.data_string_39 "u16: 60000==60000 should be true\0"
.data_string_40 "s16: 0>0 should be false\0"
.data_string_41 "s16: 1>0 should be true\0"
.data_string_42 "s16: -1>0 should be false\0"
.data_string_43 "s16: -32768>0 should be false\0"
.data_string_44 "s16: -1>-100 should be true\0"
.data_string_45 "s16: -100>-1 should be false\0"
.data_string_46 "s16: -1<0 should be true\0"
.data_string_47 "s16: 32767>0 should be true\0"
.data_string_48 "u8 vs u8: 200>100 should be true\0"
.data_string_49 "u8 vs u8: 200>200 should be false\0"
.data_string_50 "u8 vs u8: 128>127 should be true\0"
.data_string_51 "u8 vs u8: 255>0 should be true\0"
.data_string_52 "u8 vs u8: 0<255 should be true\0"
.data_string_53 "u8 vs u8: 200>128 should be true\0"
.data_string_54 "u8 vs s8: 200>s8(100) should be true\0"
.data_string_55 "u8 vs s8: 200>s8(-1) should be true\0"
.data_string_56 "u8 vs s8: 0>s8(-1) should be true\0"
.data_string_57 "u8 vs s8: 128>s8(-1) should be true\0"
.data_string_58 "0x0000\0"
.data_string_59 "strtoi 0x0000: flags should be 0 (success)\0"
.data_string_60 "strtoi 0x0000: result should be 0\0"
.data_string_61 "strtoi 0x0000: 0 > 2048 should be false\0"
.data_string_62 "0x0800\0"
.data_string_63 "strtoi 0x0800: flags should be 0 (success)\0"
.data_string_64 "strtoi 0x0800: result should be 2048\0"
.data_string_65 "strtoi 0x0800: 2048 > 2048 should be false\0"
.data_string_66 "0x0801\0"
.data_string_67 "strtoi 0x0801: flags should be 0 (success)\0"
.data_string_68 "strtoi 0x0801: result should be 2049\0"
.data_string_69 "strtoi 0x0801: 2049 > 2048 should be true\0"
.data_string_70 "=== cmptest: Comparison Operator Tests ===\n\0"
.data_string_71 "Total: %U  Failed: %U\n\0"
.data_string_72 "SOME TESTS FAILED\n\0"
.data_string_73 "ALL TESTS PASSED\n\0"
.var_total_tests "\0\0"
.var_failed_tests "\0\0"
