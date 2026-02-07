LDI_B .var_g_byte                # Load base address of g_byte into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char g_byte
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char g_byte
LDI_B .var_g_word                # Load base address of g_word into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4660                       # Constant assignment 0x1234 for  unsigned short g_word
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short g_word
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short g_word
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short g_word
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short g_word
LDI_B .var_g_signed_byte         # Load base address of g_signed_byte into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -5                        # Load constant value, inverted 5
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char g_signed_byte
LDI_B .var_g_signed_word         # Load base address of g_signed_word into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1000                      # Load constant value, inverted 1000
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short g_signed_word
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short g_signed_word
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short g_signed_word
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short g_signed_word
LDI_B .var_g_byte_array          # Load base address of g_byte_array into B
LDI_A .data_bytes_0              # [1, 2, 3, 4, 5]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY_C_D                       # Copy byte 4 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_B .var_g_word_array          # Load base address of g_word_array into B
LDI_A .data_bytes_1              # [100, 200, 300]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY_C_D                       # Copy byte 4 from C to D
MEMCPY_C_D                       # Copy byte 5 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_B .var_g_point               # Load base address of g_point into B
LDI_A .data_bytes_2              # [10, 20]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY_C_D                       # Copy byte 0 from C to D
MEMCPY_C_D                       # Copy byte 1 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
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
CALL .local_static_init_1
JMP :main                        # Initialization complete, go to main function


:report_failure                  # void report_failure( char *test_name)
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
LDI_C .data_string_0             # "FAIL: "
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of test_name at offset -1 into A
MOV_DH_AH                        # Load base address of test_name at offset -1 into A
MOV_DL_AL                        # Load base address of test_name at offset -1 into A
INCR_D                           # Load base address of test_name at offset -1 into A
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
.report_failure_return_2
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

:assert_equal_u8                 # void assert_equal_u8( unsigned char actual,  unsigned char expected,  char *test_name)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of expected at offset -1 into A
MOV_DH_AH                        # Load base address of expected at offset -1 into A
MOV_DL_AL                        # Load base address of expected at offset -1 into A
INCR_D                           # Load base address of expected at offset -1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of actual at offset 0 into B
MOV_DL_BL                        # Load base address of actual at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_6         # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_7
.binarybool_istrue_6
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_7
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_4            # Condition was true
JMP .end_if_5                    # Done with false condition
.condition_true_4                # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of test_name at offset -3 into B
DECR_D                           # Load base address of test_name at offset -3 into B
DECR_D                           # Load base address of test_name at offset -3 into B
MOV_DH_BH                        # Load base address of test_name at offset -3 into B
MOV_DL_BL                        # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
CALL :report_failure
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of actual at offset 0 into B
MOV_DL_BL                        # Load base address of actual at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of expected at offset -1 into B
MOV_DH_BH                        # Load base address of expected at offset -1 into B
MOV_DL_BL                        # Load base address of expected at offset -1 into B
INCR_D                           # Load base address of expected at offset -1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char expected
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "  Expected: 0x%x, Got: 0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_5                        # End If
.assert_equal_u8_return_3
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

:assert_equal_u16                # void assert_equal_u16( unsigned short actual,  unsigned short expected,  char *test_name)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of expected at offset -3 into A
DECR_D                           # Load base address of expected at offset -3 into A
DECR_D                           # Load base address of expected at offset -3 into A
MOV_DH_AH                        # Load base address of expected at offset -3 into A
MOV_DL_AL                        # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of actual at offset -1 into B
MOV_DH_BH                        # Load base address of actual at offset -1 into B
MOV_DL_BL                        # Load base address of actual at offset -1 into B
INCR_D                           # Load base address of actual at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_11        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_11        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_12
.binarybool_istrue_11
LDI_A 1                          # BinaryOp != was true
.binarybool_done_12
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_9            # Condition was true
JMP .end_if_10                   # Done with false condition
.condition_true_9                # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR4_D                          # Load base address of test_name at offset -5 into B
DECR_D                           # Load base address of test_name at offset -5 into B
MOV_DH_BH                        # Load base address of test_name at offset -5 into B
MOV_DL_BL                        # Load base address of test_name at offset -5 into B
INCR4_D                          # Load base address of test_name at offset -5 into B
INCR_D                           # Load base address of test_name at offset -5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
CALL :report_failure
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of actual at offset -1 into B
MOV_DH_BH                        # Load base address of actual at offset -1 into B
MOV_DL_BL                        # Load base address of actual at offset -1 into B
INCR_D                           # Load base address of actual at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of expected at offset -3 into B
DECR_D                           # Load base address of expected at offset -3 into B
DECR_D                           # Load base address of expected at offset -3 into B
MOV_DH_BH                        # Load base address of expected at offset -3 into B
MOV_DL_BL                        # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short expected
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_3             # "  Expected: 0x%X, Got: 0x%X\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_10                       # End If
.assert_equal_u16_return_8
LDI_BL 6                         # Bytes to free from local vars and parameters
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

:assert_equal_i8                 # void assert_equal_i8( signed char actual,  signed char expected,  char *test_name)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of expected at offset -1 into A
MOV_DH_AH                        # Load base address of expected at offset -1 into A
MOV_DL_AL                        # Load base address of expected at offset -1 into A
INCR_D                           # Load base address of expected at offset -1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of actual at offset 0 into B
MOV_DL_BL                        # Load base address of actual at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_16        # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_17
.binarybool_istrue_16
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_17
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_14           # Condition was true
JMP .end_if_15                   # Done with false condition
.condition_true_14               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of test_name at offset -3 into B
DECR_D                           # Load base address of test_name at offset -3 into B
DECR_D                           # Load base address of test_name at offset -3 into B
MOV_DH_BH                        # Load base address of test_name at offset -3 into B
MOV_DL_BL                        # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
INCR_D                           # Load base address of test_name at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
CALL :report_failure
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of actual at offset 0 into B
MOV_DL_BL                        # Load base address of actual at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  signed char actual
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of expected at offset -1 into B
MOV_DH_BH                        # Load base address of expected at offset -1 into B
MOV_DL_BL                        # Load base address of expected at offset -1 into B
INCR_D                           # Load base address of expected at offset -1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  signed char expected
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "  Expected: %d, Got: %d\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_15                       # End If
.assert_equal_i8_return_13
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

:assert_equal_i16                # void assert_equal_i16( signed short actual,  signed short expected,  char *test_name)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of expected at offset -3 into A
DECR_D                           # Load base address of expected at offset -3 into A
DECR_D                           # Load base address of expected at offset -3 into A
MOV_DH_AH                        # Load base address of expected at offset -3 into A
MOV_DL_AL                        # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
INCR_D                           # Load base address of expected at offset -3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of actual at offset -1 into B
MOV_DH_BH                        # Load base address of actual at offset -1 into B
MOV_DL_BL                        # Load base address of actual at offset -1 into B
INCR_D                           # Load base address of actual at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_21        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_21        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_22
.binarybool_istrue_21
LDI_A 1                          # BinaryOp != was true
.binarybool_done_22
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_19           # Condition was true
JMP .end_if_20                   # Done with false condition
.condition_true_19               # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR4_D                          # Load base address of test_name at offset -5 into B
DECR_D                           # Load base address of test_name at offset -5 into B
MOV_DH_BH                        # Load base address of test_name at offset -5 into B
MOV_DL_BL                        # Load base address of test_name at offset -5 into B
INCR4_D                          # Load base address of test_name at offset -5 into B
INCR_D                           # Load base address of test_name at offset -5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
CALL :report_failure
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of actual at offset -1 into B
MOV_DH_BH                        # Load base address of actual at offset -1 into B
MOV_DL_BL                        # Load base address of actual at offset -1 into B
INCR_D                           # Load base address of actual at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  signed short actual
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of expected at offset -3 into B
DECR_D                           # Load base address of expected at offset -3 into B
DECR_D                           # Load base address of expected at offset -3 into B
MOV_DH_BH                        # Load base address of expected at offset -3 into B
MOV_DL_BL                        # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
INCR_D                           # Load base address of expected at offset -3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  signed short expected
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_5             # "  Expected: %D, Got: %D\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_20                       # End If
.assert_equal_i16_return_18
LDI_BL 6                         # Bytes to free from local vars and parameters
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

:test_arithmetic                 # void test_arithmetic()
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
LDI_BL 21                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of a_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of a_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of a_u8 at offset 1 into B
DECR_D                           # Load base address of a_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char a_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char a_u8
INCR_D                           # Load base address of b_u8 at offset 2 into B
INCR_D                           # Load base address of b_u8 at offset 2 into B
MOV_DH_BH                        # Load base address of b_u8 at offset 2 into B
MOV_DL_BL                        # Load base address of b_u8 at offset 2 into B
DECR_D                           # Load base address of b_u8 at offset 2 into B
DECR_D                           # Load base address of b_u8 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char b_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char b_u8
INCR_D                           # Load base address of sum_u8 at offset 3 into B
INCR_D                           # Load base address of sum_u8 at offset 3 into B
INCR_D                           # Load base address of sum_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of b_u8 at offset 2 into A
INCR_D                           # Load base address of b_u8 at offset 2 into A
MOV_DH_AH                        # Load base address of b_u8 at offset 2 into A
MOV_DL_AL                        # Load base address of b_u8 at offset 2 into A
DECR_D                           # Load base address of b_u8 at offset 2 into A
DECR_D                           # Load base address of b_u8 at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of a_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of a_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of a_u8 at offset 1 into B
DECR_D                           # Load base address of a_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum_u8
LDI_A .data_string_6             # "8-bit addition"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_u8 at offset 3 into B
INCR_D                           # Load base address of sum_u8 at offset 3 into B
INCR_D                           # Load base address of sum_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
DECR_D                           # Load base address of sum_u8 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of a_u16 at offset 4 into B
MOV_DH_BH                        # Load base address of a_u16 at offset 4 into B
MOV_DL_BL                        # Load base address of a_u16 at offset 4 into B
DECR4_D                          # Load base address of a_u16 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1000                       # Constant assignment 1000 for  unsigned short a_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a_u16
INCR4_D                          # Load base address of b_u16 at offset 6 into B
INCR_D                           # Load base address of b_u16 at offset 6 into B
INCR_D                           # Load base address of b_u16 at offset 6 into B
MOV_DH_BH                        # Load base address of b_u16 at offset 6 into B
MOV_DL_BL                        # Load base address of b_u16 at offset 6 into B
DECR4_D                          # Load base address of b_u16 at offset 6 into B
DECR_D                           # Load base address of b_u16 at offset 6 into B
DECR_D                           # Load base address of b_u16 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 2000                       # Constant assignment 2000 for  unsigned short b_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short b_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short b_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short b_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short b_u16
INCR8_D                          # Load base address of sum_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of sum_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of sum_u16 at offset 8 into B
DECR8_D                          # Load base address of sum_u16 at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of b_u16 at offset 6 into A
INCR_D                           # Load base address of b_u16 at offset 6 into A
INCR_D                           # Load base address of b_u16 at offset 6 into A
MOV_DH_AH                        # Load base address of b_u16 at offset 6 into A
MOV_DL_AL                        # Load base address of b_u16 at offset 6 into A
DECR4_D                          # Load base address of b_u16 at offset 6 into A
DECR_D                           # Load base address of b_u16 at offset 6 into A
DECR_D                           # Load base address of b_u16 at offset 6 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of a_u16 at offset 4 into B
MOV_DH_BH                        # Load base address of a_u16 at offset 4 into B
MOV_DL_BL                        # Load base address of a_u16 at offset 4 into B
DECR4_D                          # Load base address of a_u16 at offset 4 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sum_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sum_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sum_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sum_u16
LDI_A .data_string_7             # "16-bit addition"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 3000                       # Constant assignment 3000 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of sum_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of sum_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of sum_u16 at offset 8 into B
DECR8_D                          # Load base address of sum_u16 at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of diff_u8 at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of diff_u8 at offset 10 into B
MOV_DH_BH                        # Load base address of diff_u8 at offset 10 into B
MOV_DL_BL                        # Load base address of diff_u8 at offset 10 into B
LDI_A 10                         # Load base address of diff_u8 at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of diff_u8 at offset 10 into B
POP_AH                           # Load base address of diff_u8 at offset 10 into B
POP_AL                           # Load base address of diff_u8 at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_BL 15                        # Constant assignment 15 for  unsigned char diff_u8
LDI_AL 50                        # Constant assignment 50 for  unsigned char diff_u8
ALUOP_AL %A-B%+%AL%+%BL%         # BinaryOp - 1 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char diff_u8
LDI_A .data_string_8             # "8-bit subtraction"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 35                        # Constant assignment 35 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of diff_u8 at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of diff_u8 at offset 10 into B
MOV_DH_BH                        # Load base address of diff_u8 at offset 10 into B
MOV_DL_BL                        # Load base address of diff_u8 at offset 10 into B
LDI_A 10                         # Load base address of diff_u8 at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of diff_u8 at offset 10 into B
POP_AH                           # Load base address of diff_u8 at offset 10 into B
POP_AL                           # Load base address of diff_u8 at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of diff_u16 at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of diff_u16 at offset 11 into B
MOV_DH_BH                        # Load base address of diff_u16 at offset 11 into B
MOV_DL_BL                        # Load base address of diff_u16 at offset 11 into B
LDI_A 11                         # Load base address of diff_u16 at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of diff_u16 at offset 11 into B
POP_AH                           # Load base address of diff_u16 at offset 11 into B
POP_AL                           # Load base address of diff_u16 at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 1234                       # Constant assignment 1234 for  unsigned short diff_u16
LDI_A 5000                       # Constant assignment 5000 for  unsigned short diff_u16
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short diff_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short diff_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short diff_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short diff_u16
LDI_A .data_string_9             # "16-bit subtraction"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 3766                       # Constant assignment 3766 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of diff_u16 at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of diff_u16 at offset 11 into B
MOV_DH_BH                        # Load base address of diff_u16 at offset 11 into B
MOV_DL_BL                        # Load base address of diff_u16 at offset 11 into B
LDI_A 11                         # Load base address of diff_u16 at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of diff_u16 at offset 11 into B
POP_AH                           # Load base address of diff_u16 at offset 11 into B
POP_AL                           # Load base address of diff_u16 at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of s1 at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s1 at offset 13 into B
MOV_DH_BH                        # Load base address of s1 at offset 13 into B
MOV_DL_BL                        # Load base address of s1 at offset 13 into B
LDI_A 13                         # Load base address of s1 at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s1 at offset 13 into B
POP_AH                           # Load base address of s1 at offset 13 into B
POP_AL                           # Load base address of s1 at offset 13 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -10                       # Load constant value, inverted 10
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char s1
ALUOP_PUSH %A%+%AL%              # Load base address of s2 at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s2 at offset 14 into B
MOV_DH_BH                        # Load base address of s2 at offset 14 into B
MOV_DL_BL                        # Load base address of s2 at offset 14 into B
LDI_A 14                         # Load base address of s2 at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s2 at offset 14 into B
POP_AH                           # Load base address of s2 at offset 14 into B
POP_AL                           # Load base address of s2 at offset 14 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for  signed char s2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char s2
ALUOP_PUSH %A%+%AL%              # Load base address of s_sum at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s_sum at offset 15 into B
MOV_DH_BH                        # Load base address of s_sum at offset 15 into B
MOV_DL_BL                        # Load base address of s_sum at offset 15 into B
LDI_A 15                         # Load base address of s_sum at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s_sum at offset 15 into B
POP_AH                           # Load base address of s_sum at offset 15 into B
POP_AL                           # Load base address of s_sum at offset 15 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of s2 at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of s2 at offset 14 into A
MOV_DH_AH                        # Load base address of s2 at offset 14 into A
MOV_DL_AL                        # Load base address of s2 at offset 14 into A
LDI_B 14                         # Load base address of s2 at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s2 at offset 14 into A
POP_BH                           # Load base address of s2 at offset 14 into A
POP_BL                           # Load base address of s2 at offset 14 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of s1 at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s1 at offset 13 into B
MOV_DH_BH                        # Load base address of s1 at offset 13 into B
MOV_DL_BL                        # Load base address of s1 at offset 13 into B
LDI_A 13                         # Load base address of s1 at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s1 at offset 13 into B
POP_AH                           # Load base address of s1 at offset 13 into B
POP_AL                           # Load base address of s1 at offset 13 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char s_sum
LDI_A .data_string_10            # "Signed 8-bit addition"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL -5                        # Load constant value, inverted 5
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of s_sum at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s_sum at offset 15 into B
MOV_DH_BH                        # Load base address of s_sum at offset 15 into B
MOV_DL_BL                        # Load base address of s_sum at offset 15 into B
LDI_A 15                         # Load base address of s_sum at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s_sum at offset 15 into B
POP_AH                           # Load base address of s_sum at offset 15 into B
POP_AL                           # Load base address of s_sum at offset 15 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of s3 at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s3 at offset 16 into B
MOV_DH_BH                        # Load base address of s3 at offset 16 into B
MOV_DL_BL                        # Load base address of s3 at offset 16 into B
LDI_A 16                         # Load base address of s3 at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s3 at offset 16 into B
POP_AH                           # Load base address of s3 at offset 16 into B
POP_AL                           # Load base address of s3 at offset 16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1000                      # Load constant value, inverted 1000
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short s3
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short s3
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short s3
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short s3
ALUOP_PUSH %A%+%AL%              # Load base address of s4 at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s4 at offset 18 into B
MOV_DH_BH                        # Load base address of s4 at offset 18 into B
MOV_DL_BL                        # Load base address of s4 at offset 18 into B
LDI_A 18                         # Load base address of s4 at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s4 at offset 18 into B
POP_AH                           # Load base address of s4 at offset 18 into B
POP_AL                           # Load base address of s4 at offset 18 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 500                        # Constant assignment 500 for  signed short s4
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short s4
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short s4
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short s4
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short s4
ALUOP_PUSH %A%+%AL%              # Load base address of s_diff at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s_diff at offset 20 into B
MOV_DH_BH                        # Load base address of s_diff at offset 20 into B
MOV_DL_BL                        # Load base address of s_diff at offset 20 into B
LDI_A 20                         # Load base address of s_diff at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s_diff at offset 20 into B
POP_AH                           # Load base address of s_diff at offset 20 into B
POP_AL                           # Load base address of s_diff at offset 20 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of s4 at offset 18 into A
ALUOP_PUSH %B%+%BH%              # Load base address of s4 at offset 18 into A
MOV_DH_AH                        # Load base address of s4 at offset 18 into A
MOV_DL_AL                        # Load base address of s4 at offset 18 into A
LDI_B 18                         # Load base address of s4 at offset 18 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s4 at offset 18 into A
POP_BH                           # Load base address of s4 at offset 18 into A
POP_BL                           # Load base address of s4 at offset 18 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of s3 at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s3 at offset 16 into B
MOV_DH_BH                        # Load base address of s3 at offset 16 into B
MOV_DL_BL                        # Load base address of s3 at offset 16 into B
LDI_A 16                         # Load base address of s3 at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s3 at offset 16 into B
POP_AH                           # Load base address of s3 at offset 16 into B
POP_AL                           # Load base address of s3 at offset 16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short s_diff
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short s_diff
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short s_diff
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short s_diff
LDI_A .data_string_11            # "Signed 16-bit subtraction"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A -1500                      # Load constant value, inverted 1500
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of s_diff at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of s_diff at offset 20 into B
MOV_DH_BH                        # Load base address of s_diff at offset 20 into B
MOV_DL_BL                        # Load base address of s_diff at offset 20 into B
LDI_A 20                         # Load base address of s_diff at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of s_diff at offset 20 into B
POP_AH                           # Load base address of s_diff at offset 20 into B
POP_AL                           # Load base address of s_diff at offset 20 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
.test_arithmetic_return_23
LDI_BL 21                        # Bytes to free from local vars and parameters
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

:test_bitwise                    # void test_bitwise()
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
LDI_BL 9                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of and_result_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of and_result_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of and_result_u8 at offset 1 into B
DECR_D                           # Load base address of and_result_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_BL 15                        # Constant assignment 0x0F for  unsigned char and_result_u8
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char and_result_u8
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char and_result_u8
LDI_A .data_string_12            # "8-bit AND"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 15                        # Constant assignment 0x0F for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of and_result_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of and_result_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of and_result_u8 at offset 1 into B
DECR_D                           # Load base address of and_result_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of and_result_u16 at offset 2 into B
INCR_D                           # Load base address of and_result_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of and_result_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of and_result_u16 at offset 2 into B
DECR_D                           # Load base address of and_result_u16 at offset 2 into B
DECR_D                           # Load base address of and_result_u16 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 4080                       # Constant assignment 0x0FF0 for  unsigned short and_result_u16
LDI_A 61680                      # Constant assignment 0xF0F0 for  unsigned short and_result_u16
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short and_result_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short and_result_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short and_result_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short and_result_u16
LDI_A .data_string_13            # "16-bit AND"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 240                        # Constant assignment 0x00F0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of and_result_u16 at offset 2 into B
INCR_D                           # Load base address of and_result_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of and_result_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of and_result_u16 at offset 2 into B
DECR_D                           # Load base address of and_result_u16 at offset 2 into B
DECR_D                           # Load base address of and_result_u16 at offset 2 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of or_result_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of or_result_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of or_result_u8 at offset 4 into B
DECR4_D                          # Load base address of or_result_u8 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp |: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp |: Save B for generating rhs
LDI_BL 15                        # Constant assignment 0x0F for  unsigned char or_result_u8
LDI_AL 240                       # Constant assignment 0xF0 for  unsigned char or_result_u8
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp | 1 byte
POP_BL                           # BinaryOp |: Restore B after use for rhs
POP_BH                           # BinaryOp |: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char or_result_u8
LDI_A .data_string_14            # "8-bit OR"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of or_result_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of or_result_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of or_result_u8 at offset 4 into B
DECR4_D                          # Load base address of or_result_u8 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of or_result_u16 at offset 5 into B
INCR_D                           # Load base address of or_result_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of or_result_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of or_result_u16 at offset 5 into B
DECR4_D                          # Load base address of or_result_u16 at offset 5 into B
DECR_D                           # Load base address of or_result_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp |: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp |: Save B for generating rhs
LDI_B 15                         # Constant assignment 0x000F for  unsigned short or_result_u16
LDI_A 61440                      # Constant assignment 0xF000 for  unsigned short or_result_u16
ALUOP16_A %A|B%+%AL%+%BL% %A|B%+%AH%+%BH% # BinaryOp | 2 byte
POP_BL                           # BinaryOp |: Restore B after use for rhs
POP_BH                           # BinaryOp |: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short or_result_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short or_result_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short or_result_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short or_result_u16
LDI_A .data_string_15            # "16-bit OR"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 61455                      # Constant assignment 0xF00F for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of or_result_u16 at offset 5 into B
INCR_D                           # Load base address of or_result_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of or_result_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of or_result_u16 at offset 5 into B
DECR4_D                          # Load base address of or_result_u16 at offset 5 into B
DECR_D                           # Load base address of or_result_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of xor_result_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of xor_result_u8 at offset 7 into B
DECR4_D                          # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ^: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ^: Save B for generating rhs
LDI_BL 85                        # Constant assignment 0x55 for  unsigned char xor_result_u8
LDI_AL 170                       # Constant assignment 0xAA for  unsigned char xor_result_u8
ALUOP_AL %AxB%+%AL%+%BL%         # BinaryOp ^ 1 byte
POP_BL                           # BinaryOp ^: Restore B after use for rhs
POP_BH                           # BinaryOp ^: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char xor_result_u8
LDI_A .data_string_16            # "8-bit XOR"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
INCR_D                           # Load base address of xor_result_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of xor_result_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of xor_result_u8 at offset 7 into B
DECR4_D                          # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
DECR_D                           # Load base address of xor_result_u8 at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of xor_result_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of xor_result_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of xor_result_u16 at offset 8 into B
DECR8_D                          # Load base address of xor_result_u16 at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ^: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ^: Save B for generating rhs
LDI_B 21845                      # Constant assignment 0x5555 for  unsigned short xor_result_u16
LDI_A 43690                      # Constant assignment 0xAAAA for  unsigned short xor_result_u16
ALUOP16_A %AxB%+%AL%+%BL% %AxB%+%AH%+%BH% # BinaryOp ^ 2 byte
POP_BL                           # BinaryOp ^: Restore B after use for rhs
POP_BH                           # BinaryOp ^: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short xor_result_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short xor_result_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short xor_result_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short xor_result_u16
LDI_A .data_string_17            # "16-bit XOR"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 65535                      # Constant assignment 0xFFFF for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of xor_result_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of xor_result_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of xor_result_u16 at offset 8 into B
DECR8_D                          # Load base address of xor_result_u16 at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
.test_bitwise_return_24
LDI_BL 9                         # Bytes to free from local vars and parameters
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

:test_shifts                     # void test_shifts()
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
LDI_BL 7                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of lshift_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of lshift_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of lshift_u8 at offset 1 into B
DECR_D                           # Load base address of lshift_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_BL 3                         # Constant assignment 3 for  unsigned char lshift_u8
LDI_AL 1                         # Constant assignment 1 for  unsigned char lshift_u8
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char lshift_u8
LDI_A .data_string_18            # "8-bit left shift by 3"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 8                         # Constant assignment 8 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of lshift_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of lshift_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of lshift_u8 at offset 1 into B
DECR_D                           # Load base address of lshift_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of lshift_u16 at offset 2 into B
INCR_D                           # Load base address of lshift_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of lshift_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of lshift_u16 at offset 2 into B
DECR_D                           # Load base address of lshift_u16 at offset 2 into B
DECR_D                           # Load base address of lshift_u16 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 for  unsigned short lshift_u16
LDI_A 1                          # Constant assignment 1 for  unsigned short lshift_u16
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 8 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short lshift_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short lshift_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short lshift_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short lshift_u16
LDI_A .data_string_19            # "16-bit left shift by 8"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 256                        # Constant assignment 256 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of lshift_u16 at offset 2 into B
INCR_D                           # Load base address of lshift_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of lshift_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of lshift_u16 at offset 2 into B
DECR_D                           # Load base address of lshift_u16 at offset 2 into B
DECR_D                           # Load base address of lshift_u16 at offset 2 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of rshift_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of rshift_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of rshift_u8 at offset 4 into B
DECR4_D                          # Load base address of rshift_u8 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 2                         # Constant assignment 2 for  unsigned char rshift_u8
LDI_AL 64                        # Constant assignment 64 for  unsigned char rshift_u8
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 2 positions
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 2 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char rshift_u8
LDI_A .data_string_20            # "8-bit right shift by 2"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 16                        # Constant assignment 16 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of rshift_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of rshift_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of rshift_u8 at offset 4 into B
DECR4_D                          # Load base address of rshift_u8 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of rshift_u16 at offset 5 into B
INCR_D                           # Load base address of rshift_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of rshift_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of rshift_u16 at offset 5 into B
DECR4_D                          # Load base address of rshift_u16 at offset 5 into B
DECR_D                           # Load base address of rshift_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 4                          # Constant assignment 4 for  unsigned short rshift_u16
LDI_A 1024                       # Constant assignment 1024 for  unsigned short rshift_u16
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short rshift_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short rshift_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short rshift_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short rshift_u16
LDI_A .data_string_21            # "16-bit right shift by 4"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 64                         # Constant assignment 64 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of rshift_u16 at offset 5 into B
INCR_D                           # Load base address of rshift_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of rshift_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of rshift_u16 at offset 5 into B
DECR4_D                          # Load base address of rshift_u16 at offset 5 into B
DECR_D                           # Load base address of rshift_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
MOV_DH_BH                        # Load base address of multi_shift at offset 7 into B
MOV_DL_BL                        # Load base address of multi_shift at offset 7 into B
DECR4_D                          # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for  unsigned char multi_shift
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_BL 2                         # Constant assignment 2 for  unsigned char multi_shift
LDI_AL 8                         # Constant assignment 8 for  unsigned char multi_shift
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 2 positions
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 2 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 1 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char multi_shift
LDI_A .data_string_22            # "Multiple shifts"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 16                        # Constant assignment 16 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
INCR_D                           # Load base address of multi_shift at offset 7 into B
MOV_DH_BH                        # Load base address of multi_shift at offset 7 into B
MOV_DL_BL                        # Load base address of multi_shift at offset 7 into B
DECR4_D                          # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
DECR_D                           # Load base address of multi_shift at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_shifts_return_25
LDI_BL 7                         # Bytes to free from local vars and parameters
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

:test_comparisons                # void test_comparisons()
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
LDI_BL 9                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of eq_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of eq_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of eq_u8 at offset 1 into B
DECR_D                           # Load base address of eq_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_BL 42                        # Constant assignment 42 for  unsigned char eq_u8
LDI_AL 42                        # Constant assignment 42 for  unsigned char eq_u8
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_27       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_28
.binarybool_isfalse_27
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_28
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char eq_u8
LDI_A .data_string_23            # "8-bit equality true"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of eq_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of eq_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of eq_u8 at offset 1 into B
DECR_D                           # Load base address of eq_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of neq_u8 at offset 2 into B
INCR_D                           # Load base address of neq_u8 at offset 2 into B
MOV_DH_BH                        # Load base address of neq_u8 at offset 2 into B
MOV_DL_BL                        # Load base address of neq_u8 at offset 2 into B
DECR_D                           # Load base address of neq_u8 at offset 2 into B
DECR_D                           # Load base address of neq_u8 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_BL 43                        # Constant assignment 43 for  unsigned char neq_u8
LDI_AL 42                        # Constant assignment 42 for  unsigned char neq_u8
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_29       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_30
.binarybool_isfalse_29
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_30
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char neq_u8
LDI_A .data_string_24            # "8-bit equality false"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of neq_u8 at offset 2 into B
INCR_D                           # Load base address of neq_u8 at offset 2 into B
MOV_DH_BH                        # Load base address of neq_u8 at offset 2 into B
MOV_DL_BL                        # Load base address of neq_u8 at offset 2 into B
DECR_D                           # Load base address of neq_u8 at offset 2 into B
DECR_D                           # Load base address of neq_u8 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of eq_u16 at offset 3 into B
INCR_D                           # Load base address of eq_u16 at offset 3 into B
INCR_D                           # Load base address of eq_u16 at offset 3 into B
MOV_DH_BH                        # Load base address of eq_u16 at offset 3 into B
MOV_DL_BL                        # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1234                       # Constant assignment 1234 for  unsigned short eq_u16
LDI_A 1234                       # Constant assignment 1234 for  unsigned short eq_u16
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_31       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_31       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_32
.binarybool_isfalse_31
LDI_A 0                          # BinaryOp == was false
.binarybool_done_32
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short eq_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short eq_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short eq_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short eq_u16
LDI_A .data_string_25            # "16-bit equality true"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of eq_u16 at offset 3 into B
INCR_D                           # Load base address of eq_u16 at offset 3 into B
INCR_D                           # Load base address of eq_u16 at offset 3 into B
MOV_DH_BH                        # Load base address of eq_u16 at offset 3 into B
MOV_DL_BL                        # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
DECR_D                           # Load base address of eq_u16 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of neq_u16 at offset 5 into B
INCR_D                           # Load base address of neq_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of neq_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of neq_u16 at offset 5 into B
DECR4_D                          # Load base address of neq_u16 at offset 5 into B
DECR_D                           # Load base address of neq_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1235                       # Constant assignment 1235 for  unsigned short neq_u16
LDI_A 1234                       # Constant assignment 1234 for  unsigned short neq_u16
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
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short neq_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short neq_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short neq_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short neq_u16
LDI_A .data_string_26            # "16-bit equality false"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of neq_u16 at offset 5 into B
INCR_D                           # Load base address of neq_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of neq_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of neq_u16 at offset 5 into B
DECR4_D                          # Load base address of neq_u16 at offset 5 into B
DECR_D                           # Load base address of neq_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of ineq_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of ineq_u8 at offset 7 into B
DECR4_D                          # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_BL 20                        # Constant assignment 20 for  unsigned char ineq_u8
LDI_AL 10                        # Constant assignment 10 for  unsigned char ineq_u8
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_35        # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_36
.binarybool_istrue_35
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_36
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ineq_u8
LDI_A .data_string_27            # "8-bit inequality true"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
INCR_D                           # Load base address of ineq_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of ineq_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of ineq_u8 at offset 7 into B
DECR4_D                          # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
DECR_D                           # Load base address of ineq_u8 at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of ineq_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of ineq_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of ineq_u16 at offset 8 into B
DECR8_D                          # Load base address of ineq_u16 at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 1000                       # Constant assignment 1000 for  unsigned short ineq_u16
LDI_A 999                        # Constant assignment 999 for  unsigned short ineq_u16
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_37        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_37        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_38
.binarybool_istrue_37
LDI_A 1                          # BinaryOp != was true
.binarybool_done_38
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short ineq_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short ineq_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short ineq_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short ineq_u16
LDI_A .data_string_28            # "16-bit inequality true"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of ineq_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of ineq_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of ineq_u16 at offset 8 into B
DECR8_D                          # Load base address of ineq_u16 at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
.test_comparisons_return_26
LDI_BL 9                         # Bytes to free from local vars and parameters
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

:test_boolean                    # void test_boolean()
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
LDI_BL 5                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of and_tt at offset 1 into B
MOV_DH_BH                        # Load base address of and_tt at offset 1 into B
MOV_DL_BL                        # Load base address of and_tt at offset 1 into B
DECR_D                           # Load base address of and_tt at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for  unsigned char and_tt
LDI_AL 1                         # Constant assignment 1 for  unsigned char and_tt
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp && 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_40       # Binary boolean format check, jump if true
JMP .binarybool_done_41          # Binary boolean format check: done
.binarybool_wastrue_40
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_41
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char and_tt
LDI_A .data_string_29            # "Logical AND (true && true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of and_tt at offset 1 into B
MOV_DH_BH                        # Load base address of and_tt at offset 1 into B
MOV_DL_BL                        # Load base address of and_tt at offset 1 into B
DECR_D                           # Load base address of and_tt at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of and_tf at offset 2 into B
INCR_D                           # Load base address of and_tf at offset 2 into B
MOV_DH_BH                        # Load base address of and_tf at offset 2 into B
MOV_DL_BL                        # Load base address of and_tf at offset 2 into B
DECR_D                           # Load base address of and_tf at offset 2 into B
DECR_D                           # Load base address of and_tf at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
LDI_BL 0                         # Constant assignment 0 for  unsigned char and_tf
LDI_AL 1                         # Constant assignment 1 for  unsigned char and_tf
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp && 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_42       # Binary boolean format check, jump if true
JMP .binarybool_done_43          # Binary boolean format check: done
.binarybool_wastrue_42
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_43
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char and_tf
LDI_A .data_string_30            # "Logical AND (true && false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of and_tf at offset 2 into B
INCR_D                           # Load base address of and_tf at offset 2 into B
MOV_DH_BH                        # Load base address of and_tf at offset 2 into B
MOV_DL_BL                        # Load base address of and_tf at offset 2 into B
DECR_D                           # Load base address of and_tf at offset 2 into B
DECR_D                           # Load base address of and_tf at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of or_ff at offset 3 into B
INCR_D                           # Load base address of or_ff at offset 3 into B
INCR_D                           # Load base address of or_ff at offset 3 into B
MOV_DH_BH                        # Load base address of or_ff at offset 3 into B
MOV_DL_BL                        # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
LDI_BL 0                         # Constant assignment 0 for  unsigned char or_ff
LDI_AL 0                         # Constant assignment 0 for  unsigned char or_ff
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_44       # Binary boolean format check, jump if true
JMP .binarybool_done_45          # Binary boolean format check: done
.binarybool_wastrue_44
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_45
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char or_ff
LDI_A .data_string_31            # "Logical OR (false || false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of or_ff at offset 3 into B
INCR_D                           # Load base address of or_ff at offset 3 into B
INCR_D                           # Load base address of or_ff at offset 3 into B
MOV_DH_BH                        # Load base address of or_ff at offset 3 into B
MOV_DL_BL                        # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
DECR_D                           # Load base address of or_ff at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of or_tf at offset 4 into B
MOV_DH_BH                        # Load base address of or_tf at offset 4 into B
MOV_DL_BL                        # Load base address of or_tf at offset 4 into B
DECR4_D                          # Load base address of or_tf at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for  unsigned char or_tf
LDI_AL 0                         # Constant assignment 0 for  unsigned char or_tf
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_46       # Binary boolean format check, jump if true
JMP .binarybool_done_47          # Binary boolean format check: done
.binarybool_wastrue_46
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_47
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char or_tf
LDI_A .data_string_32            # "Logical OR (false || true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of or_tf at offset 4 into B
MOV_DH_BH                        # Load base address of or_tf at offset 4 into B
MOV_DL_BL                        # Load base address of or_tf at offset 4 into B
DECR4_D                          # Load base address of or_tf at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of complex_bool at offset 5 into B
INCR_D                           # Load base address of complex_bool at offset 5 into B
MOV_DH_BH                        # Load base address of complex_bool at offset 5 into B
MOV_DL_BL                        # Load base address of complex_bool at offset 5 into B
DECR4_D                          # Load base address of complex_bool at offset 5 into B
DECR_D                           # Load base address of complex_bool at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp !=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp !=: Save A for generating rhs
LDI_AL 0                         # Constant assignment 0 for  unsigned char complex_bool
LDI_BL 0                         # Constant assignment 0 for  unsigned char complex_bool
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_48        # BinaryOp != is true
LDI_BL 0                         # BinaryOp != was false
JMP .binarybool_done_49
.binarybool_istrue_48
LDI_BL 1                         # BinaryOp != was true
.binarybool_done_49
POP_AL                           # BinaryOp !=: Restore A after use for rhs
POP_AH                           # BinaryOp !=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp ==: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp ==: Save A for generating rhs
LDI_AL 10                        # Constant assignment 10 for  unsigned char complex_bool
LDI_BL 10                        # Constant assignment 10 for  unsigned char complex_bool
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_50       # BinaryOp == is false
LDI_BL 1                         # BinaryOp == was true
JMP .binarybool_done_51
.binarybool_isfalse_50
LDI_BL 0                         # BinaryOp == was false
.binarybool_done_51
POP_AL                           # BinaryOp ==: Restore A after use for rhs
POP_AH                           # BinaryOp ==: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_BL 3                         # Constant assignment 3 for  unsigned char complex_bool
LDI_AL 5                         # Constant assignment 5 for  unsigned char complex_bool
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_52           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_53            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_53
.binaryop_equal_52
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_53
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp && 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_56       # Binary boolean format check, jump if true
JMP .binarybool_done_57          # Binary boolean format check: done
.binarybool_wastrue_56
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_57
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_58       # Binary boolean format check, jump if true
JMP .binarybool_done_59          # Binary boolean format check: done
.binarybool_wastrue_58
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_59
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char complex_bool
LDI_A .data_string_33            # "Complex boolean expression"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of complex_bool at offset 5 into B
INCR_D                           # Load base address of complex_bool at offset 5 into B
MOV_DH_BH                        # Load base address of complex_bool at offset 5 into B
MOV_DL_BL                        # Load base address of complex_bool at offset 5 into B
DECR4_D                          # Load base address of complex_bool at offset 5 into B
DECR_D                           # Load base address of complex_bool at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_boolean_return_39
LDI_BL 5                         # Bytes to free from local vars and parameters
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

:test_unary                      # void test_unary()
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
LDI_BL 12                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of neg_i8 at offset 1 into B
MOV_DH_BH                        # Load base address of neg_i8 at offset 1 into B
MOV_DL_BL                        # Load base address of neg_i8 at offset 1 into B
DECR_D                           # Load base address of neg_i8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  signed char neg_i8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char neg_i8
INCR_D                           # Load base address of negated_i8 at offset 2 into B
INCR_D                           # Load base address of negated_i8 at offset 2 into B
MOV_DH_BH                        # Load base address of negated_i8 at offset 2 into B
MOV_DL_BL                        # Load base address of negated_i8 at offset 2 into B
DECR_D                           # Load base address of negated_i8 at offset 2 into B
DECR_D                           # Load base address of negated_i8 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of neg_i8 at offset 1 into B
MOV_DH_BH                        # Load base address of neg_i8 at offset 1 into B
MOV_DL_BL                        # Load base address of neg_i8 at offset 1 into B
DECR_D                           # Load base address of neg_i8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %-A_signed%+%AL%        # Unary negation
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char negated_i8
LDI_A .data_string_34            # "8-bit unary negation"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL -10                       # Load constant value, inverted 10
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of negated_i8 at offset 2 into B
INCR_D                           # Load base address of negated_i8 at offset 2 into B
MOV_DH_BH                        # Load base address of negated_i8 at offset 2 into B
MOV_DL_BL                        # Load base address of negated_i8 at offset 2 into B
DECR_D                           # Load base address of negated_i8 at offset 2 into B
DECR_D                           # Load base address of negated_i8 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of neg_i16 at offset 3 into B
INCR_D                           # Load base address of neg_i16 at offset 3 into B
INCR_D                           # Load base address of neg_i16 at offset 3 into B
MOV_DH_BH                        # Load base address of neg_i16 at offset 3 into B
MOV_DL_BL                        # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1000                       # Constant assignment 1000 for  signed short neg_i16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short neg_i16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short neg_i16
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short neg_i16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short neg_i16
INCR4_D                          # Load base address of negated_i16 at offset 5 into B
INCR_D                           # Load base address of negated_i16 at offset 5 into B
MOV_DH_BH                        # Load base address of negated_i16 at offset 5 into B
MOV_DL_BL                        # Load base address of negated_i16 at offset 5 into B
DECR4_D                          # Load base address of negated_i16 at offset 5 into B
DECR_D                           # Load base address of negated_i16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of neg_i16 at offset 3 into B
INCR_D                           # Load base address of neg_i16 at offset 3 into B
INCR_D                           # Load base address of neg_i16 at offset 3 into B
MOV_DH_BH                        # Load base address of neg_i16 at offset 3 into B
MOV_DL_BL                        # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
DECR_D                           # Load base address of neg_i16 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :signed_invert_a            # Unary negation
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short negated_i16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short negated_i16
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short negated_i16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short negated_i16
LDI_A .data_string_35            # "16-bit unary negation"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A -1000                      # Load constant value, inverted 1000
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of negated_i16 at offset 5 into B
INCR_D                           # Load base address of negated_i16 at offset 5 into B
MOV_DH_BH                        # Load base address of negated_i16 at offset 5 into B
MOV_DL_BL                        # Load base address of negated_i16 at offset 5 into B
DECR4_D                          # Load base address of negated_i16 at offset 5 into B
DECR_D                           # Load base address of negated_i16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of not_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of not_u8 at offset 7 into B
DECR4_D                          # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 15                        # Constant assignment 0x0F for  unsigned char not_u8
ALUOP_AL %~A%+%AL%               # Unary bitwise NOT
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char not_u8
LDI_A .data_string_36            # "8-bit bitwise NOT"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 240                       # Constant assignment 0xF0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
INCR_D                           # Load base address of not_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of not_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of not_u8 at offset 7 into B
DECR4_D                          # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
DECR_D                           # Load base address of not_u8 at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of not_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of not_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of not_u16 at offset 8 into B
DECR8_D                          # Load base address of not_u16 at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 255                        # Constant assignment 0x00FF for  unsigned short not_u16
ALUOP_AL %~A%+%AL%               # Unary bitwise NOT
ALUOP_AH %~A%+%AH%               # Unary bitwise NOT
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short not_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short not_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short not_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short not_u16
LDI_A .data_string_37            # "16-bit bitwise NOT"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 65280                      # Constant assignment 0xFF00 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of not_u16 at offset 8 into B
MOV_DH_BH                        # Load base address of not_u16 at offset 8 into B
MOV_DL_BL                        # Load base address of not_u16 at offset 8 into B
DECR8_D                          # Load base address of not_u16 at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of lnot_t at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of lnot_t at offset 10 into B
MOV_DH_BH                        # Load base address of lnot_t at offset 10 into B
MOV_DL_BL                        # Load base address of lnot_t at offset 10 into B
LDI_A 10                         # Load base address of lnot_t at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of lnot_t at offset 10 into B
POP_AH                           # Load base address of lnot_t at offset 10 into B
POP_AL                           # Load base address of lnot_t at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char lnot_t
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_61         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_62            # Unary boolean NOT: done
.unarynot_wastrue_61
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_62
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char lnot_t
LDI_A .data_string_38            # "Logical NOT (true to false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of lnot_t at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of lnot_t at offset 10 into B
MOV_DH_BH                        # Load base address of lnot_t at offset 10 into B
MOV_DL_BL                        # Load base address of lnot_t at offset 10 into B
LDI_A 10                         # Load base address of lnot_t at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of lnot_t at offset 10 into B
POP_AH                           # Load base address of lnot_t at offset 10 into B
POP_AL                           # Load base address of lnot_t at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of lnot_f at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of lnot_f at offset 11 into B
MOV_DH_BH                        # Load base address of lnot_f at offset 11 into B
MOV_DL_BL                        # Load base address of lnot_f at offset 11 into B
LDI_A 11                         # Load base address of lnot_f at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of lnot_f at offset 11 into B
POP_AH                           # Load base address of lnot_f at offset 11 into B
POP_AL                           # Load base address of lnot_f at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char lnot_f
ALUOP_FLAGS %A%+%AL%             # Unary boolean NOT
JNZ .unarynot_wastrue_63         # Unary boolean NOT, jump if true
LDI_AL 1                         # Unary boolan NOT, is false: return true
JMP .unarynot_done_64            # Unary boolean NOT: done
.unarynot_wastrue_63
LDI_AL 0                         # Unary boolan NOT, is true: return false
.unarynot_done_64
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char lnot_f
LDI_A .data_string_39            # "Logical NOT (false to true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of lnot_f at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of lnot_f at offset 11 into B
MOV_DH_BH                        # Load base address of lnot_f at offset 11 into B
MOV_DL_BL                        # Load base address of lnot_f at offset 11 into B
LDI_A 11                         # Load base address of lnot_f at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of lnot_f at offset 11 into B
POP_AH                           # Load base address of lnot_f at offset 11 into B
POP_AL                           # Load base address of lnot_f at offset 11 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of plus_u8 at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of plus_u8 at offset 12 into B
MOV_DH_BH                        # Load base address of plus_u8 at offset 12 into B
MOV_DL_BL                        # Load base address of plus_u8 at offset 12 into B
LDI_A 12                         # Load base address of plus_u8 at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of plus_u8 at offset 12 into B
POP_AH                           # Load base address of plus_u8 at offset 12 into B
POP_AL                           # Load base address of plus_u8 at offset 12 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char plus_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char plus_u8
LDI_A .data_string_40            # "Unary plus"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of plus_u8 at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of plus_u8 at offset 12 into B
MOV_DH_BH                        # Load base address of plus_u8 at offset 12 into B
MOV_DL_BL                        # Load base address of plus_u8 at offset 12 into B
LDI_A 12                         # Load base address of plus_u8 at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of plus_u8 at offset 12 into B
POP_AH                           # Load base address of plus_u8 at offset 12 into B
POP_AL                           # Load base address of plus_u8 at offset 12 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_unary_return_60
LDI_BL 12                        # Bytes to free from local vars and parameters
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

:test_inc_dec                    # void test_inc_dec()
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
LDI_BL 12                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of pre_inc_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of pre_inc_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of pre_inc_u8 at offset 1 into B
DECR_D                           # Load base address of pre_inc_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char pre_inc_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_inc_u8
INCR_D                           # Load base address of pre_inc_result at offset 2 into B
INCR_D                           # Load base address of pre_inc_result at offset 2 into B
MOV_DH_BH                        # Load base address of pre_inc_result at offset 2 into B
MOV_DL_BL                        # Load base address of pre_inc_result at offset 2 into B
DECR_D                           # Load base address of pre_inc_result at offset 2 into B
DECR_D                           # Load base address of pre_inc_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of pre_inc_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of pre_inc_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of pre_inc_u8 at offset 1 into B
DECR_D                           # Load base address of pre_inc_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp ++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp ++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp ++: Save B before generating lvalue
INCR_D                           # Load base address of pre_inc_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of pre_inc_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of pre_inc_u8 at offset 1 into B
DECR_D                           # Load base address of pre_inc_u8 at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_inc_u8
POP_BL                           # UnaryOp ++: Restore B, return rvalue in A
POP_BH                           # UnaryOp ++: Restore B, return rvalue in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_inc_result
LDI_A .data_string_41            # "Pre-increment value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 11                        # Constant assignment 11 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of pre_inc_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of pre_inc_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of pre_inc_u8 at offset 1 into B
DECR_D                           # Load base address of pre_inc_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_42            # "Pre-increment return"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 11                        # Constant assignment 11 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of pre_inc_result at offset 2 into B
INCR_D                           # Load base address of pre_inc_result at offset 2 into B
MOV_DH_BH                        # Load base address of pre_inc_result at offset 2 into B
MOV_DL_BL                        # Load base address of pre_inc_result at offset 2 into B
DECR_D                           # Load base address of pre_inc_result at offset 2 into B
DECR_D                           # Load base address of pre_inc_result at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of post_inc_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char post_inc_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_inc_u8
INCR4_D                          # Load base address of post_inc_result at offset 4 into B
MOV_DH_BH                        # Load base address of post_inc_result at offset 4 into B
MOV_DL_BL                        # Load base address of post_inc_result at offset 4 into B
DECR4_D                          # Load base address of post_inc_result at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of post_inc_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_PUSH %A%+%AL%              # UnaryOp p++: preserve previous value before incrementing
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of post_inc_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_inc_u8
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
POP_AL                           # UnaryOp p++: restore original value for return
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_inc_result
LDI_A .data_string_43            # "Post-increment value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 11                        # Constant assignment 11 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
INCR_D                           # Load base address of post_inc_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of post_inc_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
DECR_D                           # Load base address of post_inc_u8 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_44            # "Post-increment return"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of post_inc_result at offset 4 into B
MOV_DH_BH                        # Load base address of post_inc_result at offset 4 into B
MOV_DL_BL                        # Load base address of post_inc_result at offset 4 into B
DECR4_D                          # Load base address of post_inc_result at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
INCR_D                           # Load base address of pre_dec_u8 at offset 5 into B
MOV_DH_BH                        # Load base address of pre_dec_u8 at offset 5 into B
MOV_DL_BL                        # Load base address of pre_dec_u8 at offset 5 into B
DECR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
DECR_D                           # Load base address of pre_dec_u8 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char pre_dec_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_dec_u8
INCR4_D                          # Load base address of pre_dec_result at offset 6 into B
INCR_D                           # Load base address of pre_dec_result at offset 6 into B
INCR_D                           # Load base address of pre_dec_result at offset 6 into B
MOV_DH_BH                        # Load base address of pre_dec_result at offset 6 into B
MOV_DL_BL                        # Load base address of pre_dec_result at offset 6 into B
DECR4_D                          # Load base address of pre_dec_result at offset 6 into B
DECR_D                           # Load base address of pre_dec_result at offset 6 into B
DECR_D                           # Load base address of pre_dec_result at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
INCR_D                           # Load base address of pre_dec_u8 at offset 5 into B
MOV_DH_BH                        # Load base address of pre_dec_u8 at offset 5 into B
MOV_DL_BL                        # Load base address of pre_dec_u8 at offset 5 into B
DECR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
DECR_D                           # Load base address of pre_dec_u8 at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A-1%+%AL%              # UnaryOp --: decrement 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp --: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp --: Save B before generating lvalue
INCR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
INCR_D                           # Load base address of pre_dec_u8 at offset 5 into B
MOV_DH_BH                        # Load base address of pre_dec_u8 at offset 5 into B
MOV_DL_BL                        # Load base address of pre_dec_u8 at offset 5 into B
DECR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
DECR_D                           # Load base address of pre_dec_u8 at offset 5 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_dec_u8
POP_BL                           # UnaryOp --: Restore B, return rvalue in A
POP_BH                           # UnaryOp --: Restore B, return rvalue in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char pre_dec_result
LDI_A .data_string_45            # "Pre-decrement value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 9                         # Constant assignment 9 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
INCR_D                           # Load base address of pre_dec_u8 at offset 5 into B
MOV_DH_BH                        # Load base address of pre_dec_u8 at offset 5 into B
MOV_DL_BL                        # Load base address of pre_dec_u8 at offset 5 into B
DECR4_D                          # Load base address of pre_dec_u8 at offset 5 into B
DECR_D                           # Load base address of pre_dec_u8 at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_46            # "Pre-decrement return"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 9                         # Constant assignment 9 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of pre_dec_result at offset 6 into B
INCR_D                           # Load base address of pre_dec_result at offset 6 into B
INCR_D                           # Load base address of pre_dec_result at offset 6 into B
MOV_DH_BH                        # Load base address of pre_dec_result at offset 6 into B
MOV_DL_BL                        # Load base address of pre_dec_result at offset 6 into B
DECR4_D                          # Load base address of pre_dec_result at offset 6 into B
DECR_D                           # Load base address of pre_dec_result at offset 6 into B
DECR_D                           # Load base address of pre_dec_result at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of post_dec_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of post_dec_u8 at offset 7 into B
DECR4_D                          # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char post_dec_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_dec_u8
INCR8_D                          # Load base address of post_dec_result at offset 8 into B
MOV_DH_BH                        # Load base address of post_dec_result at offset 8 into B
MOV_DL_BL                        # Load base address of post_dec_result at offset 8 into B
DECR8_D                          # Load base address of post_dec_result at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of post_dec_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of post_dec_u8 at offset 7 into B
DECR4_D                          # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_PUSH %A%+%AL%              # UnaryOp p--: preserve previous value before decrementing
ALUOP_AL %A-1%+%AL%              # UnaryOp p--: decrement 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p--: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p--: Save B before generating lvalue
INCR4_D                          # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of post_dec_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of post_dec_u8 at offset 7 into B
DECR4_D                          # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_dec_u8
POP_BL                           # UnaryOp p--: Restore B, return rvalue in A
POP_BH                           # UnaryOp p--: Restore B, return rvalue in A
POP_AL                           # UnaryOp p--: restore original value for return
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char post_dec_result
LDI_A .data_string_47            # "Post-decrement value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 9                         # Constant assignment 9 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
INCR_D                           # Load base address of post_dec_u8 at offset 7 into B
MOV_DH_BH                        # Load base address of post_dec_u8 at offset 7 into B
MOV_DL_BL                        # Load base address of post_dec_u8 at offset 7 into B
DECR4_D                          # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
DECR_D                           # Load base address of post_dec_u8 at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_48            # "Post-decrement return"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of post_dec_result at offset 8 into B
MOV_DH_BH                        # Load base address of post_dec_result at offset 8 into B
MOV_DL_BL                        # Load base address of post_dec_result at offset 8 into B
DECR8_D                          # Load base address of post_dec_result at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
INCR_D                           # Load base address of pre_inc_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of pre_inc_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of pre_inc_u16 at offset 9 into B
DECR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
DECR_D                           # Load base address of pre_inc_u16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1000                       # Constant assignment 1000 for  unsigned short pre_inc_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short pre_inc_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short pre_inc_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_u16
ALUOP_PUSH %A%+%AL%              # Load base address of pre_inc_result_u16 at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of pre_inc_result_u16 at offset 11 into B
MOV_DH_BH                        # Load base address of pre_inc_result_u16 at offset 11 into B
MOV_DL_BL                        # Load base address of pre_inc_result_u16 at offset 11 into B
LDI_A 11                         # Load base address of pre_inc_result_u16 at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pre_inc_result_u16 at offset 11 into B
POP_AH                           # Load base address of pre_inc_result_u16 at offset 11 into B
POP_AL                           # Load base address of pre_inc_result_u16 at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
INCR_D                           # Load base address of pre_inc_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of pre_inc_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of pre_inc_u16 at offset 9 into B
DECR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
DECR_D                           # Load base address of pre_inc_u16 at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp ++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp ++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp ++: Save B before generating lvalue
INCR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
INCR_D                           # Load base address of pre_inc_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of pre_inc_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of pre_inc_u16 at offset 9 into B
DECR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
DECR_D                           # Load base address of pre_inc_u16 at offset 9 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short pre_inc_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short pre_inc_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_u16
POP_BL                           # UnaryOp ++: Restore B, return rvalue in A
POP_BH                           # UnaryOp ++: Restore B, return rvalue in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short pre_inc_result_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_result_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short pre_inc_result_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short pre_inc_result_u16
LDI_A .data_string_49            # "Pre-increment 16-bit value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1001                       # Constant assignment 1001 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
INCR_D                           # Load base address of pre_inc_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of pre_inc_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of pre_inc_u16 at offset 9 into B
DECR8_D                          # Load base address of pre_inc_u16 at offset 9 into B
DECR_D                           # Load base address of pre_inc_u16 at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_50            # "Pre-increment 16-bit return"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1001                       # Constant assignment 1001 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of pre_inc_result_u16 at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of pre_inc_result_u16 at offset 11 into B
MOV_DH_BH                        # Load base address of pre_inc_result_u16 at offset 11 into B
MOV_DL_BL                        # Load base address of pre_inc_result_u16 at offset 11 into B
LDI_A 11                         # Load base address of pre_inc_result_u16 at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pre_inc_result_u16 at offset 11 into B
POP_AH                           # Load base address of pre_inc_result_u16 at offset 11 into B
POP_AL                           # Load base address of pre_inc_result_u16 at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
.test_inc_dec_return_65
LDI_BL 12                        # Bytes to free from local vars and parameters
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

:test_assignment                 # void test_assignment()
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
LDI_BL 11                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of assign_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of assign_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of assign_u8 at offset 1 into B
DECR_D                           # Load base address of assign_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 55                        # Constant assignment 55 for  unsigned char assign_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char assign_u8
LDI_A .data_string_51            # "Simple 8-bit assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 55                        # Constant assignment 55 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of assign_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of assign_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of assign_u8 at offset 1 into B
DECR_D                           # Load base address of assign_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of assign_u16 at offset 2 into B
INCR_D                           # Load base address of assign_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of assign_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of assign_u16 at offset 2 into B
DECR_D                           # Load base address of assign_u16 at offset 2 into B
DECR_D                           # Load base address of assign_u16 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 9999                       # Constant assignment 9999 for  unsigned short assign_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short assign_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short assign_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short assign_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short assign_u16
LDI_A .data_string_52            # "Simple 16-bit assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 9999                       # Constant assignment 9999 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of assign_u16 at offset 2 into B
INCR_D                           # Load base address of assign_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of assign_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of assign_u16 at offset 2 into B
DECR_D                           # Load base address of assign_u16 at offset 2 into B
DECR_D                           # Load base address of assign_u16 at offset 2 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of add_assign_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of add_assign_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of add_assign_u8 at offset 4 into B
DECR4_D                          # Load base address of add_assign_u8 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char add_assign_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char add_assign_u8
INCR4_D                          # Load base address of add_assign_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of add_assign_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of add_assign_u8 at offset 4 into B
DECR4_D                          # Load base address of add_assign_u8 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 5                         # Constant assignment 5 for  unsigned char add_assign_u8
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of add_assign_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of add_assign_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of add_assign_u8 at offset 4 into B
DECR4_D                          # Load base address of add_assign_u8 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char add_assign_u8
LDI_A .data_string_53            # "8-bit += assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 15                        # Constant assignment 15 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of add_assign_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of add_assign_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of add_assign_u8 at offset 4 into B
DECR4_D                          # Load base address of add_assign_u8 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
INCR_D                           # Load base address of sub_assign_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of sub_assign_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of sub_assign_u16 at offset 5 into B
DECR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
DECR_D                           # Load base address of sub_assign_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1000                       # Constant assignment 1000 for  unsigned short sub_assign_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sub_assign_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sub_assign_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sub_assign_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sub_assign_u16
INCR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
INCR_D                           # Load base address of sub_assign_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of sub_assign_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of sub_assign_u16 at offset 5 into B
DECR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
DECR_D                           # Load base address of sub_assign_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 250                        # Constant assignment 250 for  unsigned short sub_assign_u16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
INCR_D                           # Load base address of sub_assign_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of sub_assign_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of sub_assign_u16 at offset 5 into B
DECR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
DECR_D                           # Load base address of sub_assign_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sub_assign_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sub_assign_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sub_assign_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sub_assign_u16
LDI_A .data_string_54            # "16-bit -= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 750                        # Constant assignment 750 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
INCR_D                           # Load base address of sub_assign_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of sub_assign_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of sub_assign_u16 at offset 5 into B
DECR4_D                          # Load base address of sub_assign_u16 at offset 5 into B
DECR_D                           # Load base address of sub_assign_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
MOV_DH_BH                        # Load base address of lshift_assign at offset 7 into B
MOV_DL_BL                        # Load base address of lshift_assign at offset 7 into B
DECR4_D                          # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char lshift_assign
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char lshift_assign
INCR4_D                          # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
MOV_DH_BH                        # Load base address of lshift_assign at offset 7 into B
MOV_DL_BL                        # Load base address of lshift_assign at offset 7 into B
DECR4_D                          # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_BL 3                         # Constant assignment 3 for  unsigned char lshift_assign
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
MOV_DH_BH                        # Load base address of lshift_assign at offset 7 into B
MOV_DL_BL                        # Load base address of lshift_assign at offset 7 into B
DECR4_D                          # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
ALUOP_AL %A<<1%+%AL%             # BinaryOp << 3 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char lshift_assign
LDI_A .data_string_55            # "<<= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 16                        # Constant assignment 16 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
INCR_D                           # Load base address of lshift_assign at offset 7 into B
MOV_DH_BH                        # Load base address of lshift_assign at offset 7 into B
MOV_DL_BL                        # Load base address of lshift_assign at offset 7 into B
DECR4_D                          # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
DECR_D                           # Load base address of lshift_assign at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of rshift_assign at offset 8 into B
MOV_DH_BH                        # Load base address of rshift_assign at offset 8 into B
MOV_DL_BL                        # Load base address of rshift_assign at offset 8 into B
DECR8_D                          # Load base address of rshift_assign at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 64                        # Constant assignment 64 for  unsigned char rshift_assign
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char rshift_assign
INCR8_D                          # Load base address of rshift_assign at offset 8 into B
MOV_DH_BH                        # Load base address of rshift_assign at offset 8 into B
MOV_DL_BL                        # Load base address of rshift_assign at offset 8 into B
DECR8_D                          # Load base address of rshift_assign at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 2                         # Constant assignment 2 for  unsigned char rshift_assign
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of rshift_assign at offset 8 into B
MOV_DH_BH                        # Load base address of rshift_assign at offset 8 into B
MOV_DL_BL                        # Load base address of rshift_assign at offset 8 into B
DECR8_D                          # Load base address of rshift_assign at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 2 positions
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 2 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char rshift_assign
LDI_A .data_string_56            # ">>= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 16                        # Constant assignment 16 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of rshift_assign at offset 8 into B
MOV_DH_BH                        # Load base address of rshift_assign at offset 8 into B
MOV_DL_BL                        # Load base address of rshift_assign at offset 8 into B
DECR8_D                          # Load base address of rshift_assign at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of and_assign at offset 9 into B
INCR_D                           # Load base address of and_assign at offset 9 into B
MOV_DH_BH                        # Load base address of and_assign at offset 9 into B
MOV_DL_BL                        # Load base address of and_assign at offset 9 into B
DECR8_D                          # Load base address of and_assign at offset 9 into B
DECR_D                           # Load base address of and_assign at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char and_assign
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char and_assign
INCR8_D                          # Load base address of and_assign at offset 9 into B
INCR_D                           # Load base address of and_assign at offset 9 into B
MOV_DH_BH                        # Load base address of and_assign at offset 9 into B
MOV_DL_BL                        # Load base address of and_assign at offset 9 into B
DECR8_D                          # Load base address of and_assign at offset 9 into B
DECR_D                           # Load base address of and_assign at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_BL 15                        # Constant assignment 0x0F for  unsigned char and_assign
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of and_assign at offset 9 into B
INCR_D                           # Load base address of and_assign at offset 9 into B
MOV_DH_BH                        # Load base address of and_assign at offset 9 into B
MOV_DL_BL                        # Load base address of and_assign at offset 9 into B
DECR8_D                          # Load base address of and_assign at offset 9 into B
DECR_D                           # Load base address of and_assign at offset 9 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char and_assign
LDI_A .data_string_57            # "&= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 15                        # Constant assignment 0x0F for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of and_assign at offset 9 into B
INCR_D                           # Load base address of and_assign at offset 9 into B
MOV_DH_BH                        # Load base address of and_assign at offset 9 into B
MOV_DL_BL                        # Load base address of and_assign at offset 9 into B
DECR8_D                          # Load base address of and_assign at offset 9 into B
DECR_D                           # Load base address of and_assign at offset 9 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of or_assign at offset 10 into B
MOV_DH_BH                        # Load base address of or_assign at offset 10 into B
MOV_DL_BL                        # Load base address of or_assign at offset 10 into B
LDI_A 10                         # Load base address of or_assign at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of or_assign at offset 10 into B
POP_AH                           # Load base address of or_assign at offset 10 into B
POP_AL                           # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 240                       # Constant assignment 0xF0 for  unsigned char or_assign
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char or_assign
ALUOP_PUSH %A%+%AL%              # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of or_assign at offset 10 into B
MOV_DH_BH                        # Load base address of or_assign at offset 10 into B
MOV_DL_BL                        # Load base address of or_assign at offset 10 into B
LDI_A 10                         # Load base address of or_assign at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of or_assign at offset 10 into B
POP_AH                           # Load base address of or_assign at offset 10 into B
POP_AL                           # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp |: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp |: Save B for generating rhs
LDI_BL 15                        # Constant assignment 0x0F for  unsigned char or_assign
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of or_assign at offset 10 into B
MOV_DH_BH                        # Load base address of or_assign at offset 10 into B
MOV_DL_BL                        # Load base address of or_assign at offset 10 into B
LDI_A 10                         # Load base address of or_assign at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of or_assign at offset 10 into B
POP_AH                           # Load base address of or_assign at offset 10 into B
POP_AL                           # Load base address of or_assign at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp | 1 byte
POP_BL                           # BinaryOp |: Restore B after use for rhs
POP_BH                           # BinaryOp |: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char or_assign
LDI_A .data_string_58            # "|= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of or_assign at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of or_assign at offset 10 into B
MOV_DH_BH                        # Load base address of or_assign at offset 10 into B
MOV_DL_BL                        # Load base address of or_assign at offset 10 into B
LDI_A 10                         # Load base address of or_assign at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of or_assign at offset 10 into B
POP_AH                           # Load base address of or_assign at offset 10 into B
POP_AL                           # Load base address of or_assign at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of xor_assign at offset 11 into B
MOV_DH_BH                        # Load base address of xor_assign at offset 11 into B
MOV_DL_BL                        # Load base address of xor_assign at offset 11 into B
LDI_A 11                         # Load base address of xor_assign at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of xor_assign at offset 11 into B
POP_AH                           # Load base address of xor_assign at offset 11 into B
POP_AL                           # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 170                       # Constant assignment 0xAA for  unsigned char xor_assign
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char xor_assign
ALUOP_PUSH %A%+%AL%              # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of xor_assign at offset 11 into B
MOV_DH_BH                        # Load base address of xor_assign at offset 11 into B
MOV_DL_BL                        # Load base address of xor_assign at offset 11 into B
LDI_A 11                         # Load base address of xor_assign at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of xor_assign at offset 11 into B
POP_AH                           # Load base address of xor_assign at offset 11 into B
POP_AL                           # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ^: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ^: Save B for generating rhs
LDI_BL 85                        # Constant assignment 0x55 for  unsigned char xor_assign
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of xor_assign at offset 11 into B
MOV_DH_BH                        # Load base address of xor_assign at offset 11 into B
MOV_DL_BL                        # Load base address of xor_assign at offset 11 into B
LDI_A 11                         # Load base address of xor_assign at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of xor_assign at offset 11 into B
POP_AH                           # Load base address of xor_assign at offset 11 into B
POP_AL                           # Load base address of xor_assign at offset 11 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %AxB%+%AL%+%BL%         # BinaryOp ^ 1 byte
POP_BL                           # BinaryOp ^: Restore B after use for rhs
POP_BH                           # BinaryOp ^: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char xor_assign
LDI_A .data_string_59            # "^= assignment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of xor_assign at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of xor_assign at offset 11 into B
MOV_DH_BH                        # Load base address of xor_assign at offset 11 into B
MOV_DL_BL                        # Load base address of xor_assign at offset 11 into B
LDI_A 11                         # Load base address of xor_assign at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of xor_assign at offset 11 into B
POP_AH                           # Load base address of xor_assign at offset 11 into B
POP_AL                           # Load base address of xor_assign at offset 11 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_assignment_return_66
LDI_BL 11                        # Bytes to free from local vars and parameters
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

:test_arrays                     # void test_arrays()
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
LDI_BL 36                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of arr_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of arr_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of arr_u8 at offset 1 into B
DECR_D                           # Load base address of arr_u8 at offset 1 into B
LDI_A .data_bytes_3              # [10, 20, 30, 40, 50]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY_C_D                       # Copy byte 4 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_A .data_string_60            # "Array access [0]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR_D                           # Load base address of arr_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of arr_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of arr_u8 at offset 1 into B
DECR_D                           # Load base address of arr_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_61            # "Array access [2]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR_D                           # Load base address of arr_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of arr_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of arr_u8 at offset 1 into B
DECR_D                           # Load base address of arr_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 2                          # Constant assignment 2 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_62            # "Array access [4]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 50                        # Constant assignment 50 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR_D                           # Load base address of arr_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of arr_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of arr_u8 at offset 1 into B
DECR_D                           # Load base address of arr_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 4                          # Constant assignment 4 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
INCR_D                           # Load base address of arr_u8 at offset 1 into A
MOV_DH_AH                        # Load base address of arr_u8 at offset 1 into A
MOV_DL_AL                        # Load base address of arr_u8 at offset 1 into A
DECR_D                           # Load base address of arr_u8 at offset 1 into A
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
LDI_AL 99                        # Constant assignment 99 for  unsigned char arr_u8_element (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char arr_u8_element (virtual)
LDI_A .data_string_63            # "Array modification"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 99                        # Constant assignment 99 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR_D                           # Load base address of arr_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of arr_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of arr_u8 at offset 1 into B
DECR_D                           # Load base address of arr_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
MOV_DH_BH                        # Load base address of arr_u16 at offset 6 into B
MOV_DL_BL                        # Load base address of arr_u16 at offset 6 into B
DECR4_D                          # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
LDI_A .data_bytes_4              # [100, 200, 300, 400]
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
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_A .data_string_64            # "16-bit array access [0]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 100                        # Constant assignment 100 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR4_D                          # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
MOV_DH_BH                        # Load base address of arr_u16 at offset 6 into B
MOV_DL_BL                        # Load base address of arr_u16 at offset 6 into B
DECR4_D                          # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 2
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_65            # "16-bit array access [3]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 400                        # Constant assignment 400 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
INCR4_D                          # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
INCR_D                           # Load base address of arr_u16 at offset 6 into B
MOV_DH_BH                        # Load base address of arr_u16 at offset 6 into B
MOV_DL_BL                        # Load base address of arr_u16 at offset 6 into B
DECR4_D                          # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
DECR_D                           # Load base address of arr_u16 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 3                          # Constant assignment 3 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 2
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 4                         # Constant assignment 4 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points at offset 14 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points at offset 14 into A
MOV_DH_AH                        # Load base address of points at offset 14 into A
MOV_DL_AL                        # Load base address of points at offset 14 into A
LDI_B 14                         # Load base address of points at offset 14 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into A
POP_BH                           # Load base address of points at offset 14 into A
POP_BL                           # Load base address of points at offset 14 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 6                         # Constant assignment 6 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
LDI_A .data_string_66            # "Struct array [0].x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Load base address of points at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of points at offset 14 into B
MOV_DH_BH                        # Load base address of points at offset 14 into B
MOV_DL_BL                        # Load base address of points at offset 14 into B
LDI_A 14                         # Load base address of points at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into B
POP_AH                           # Load base address of points at offset 14 into B
POP_AL                           # Load base address of points at offset 14 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 2
ALUOP_AH %B%+%BH%                # Copy address
ALUOP_AL %B%+%BL%                # Copy address
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_67            # "Struct array [1].y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 4                         # Constant assignment 4 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Load base address of points at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of points at offset 14 into B
MOV_DH_BH                        # Load base address of points at offset 14 into B
MOV_DL_BL                        # Load base address of points at offset 14 into B
LDI_A 14                         # Load base address of points at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into B
POP_AH                           # Load base address of points at offset 14 into B
POP_AL                           # Load base address of points at offset 14 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 2
ALUOP_AH %B%+%BH%                # Copy address
ALUOP_AL %B%+%BL%                # Copy address
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_68            # "Struct array [2].x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 5                         # Constant assignment 5 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Load base address of points at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of points at offset 14 into B
MOV_DH_BH                        # Load base address of points at offset 14 into B
MOV_DL_BL                        # Load base address of points at offset 14 into B
LDI_A 14                         # Load base address of points at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points at offset 14 into B
POP_AH                           # Load base address of points at offset 14 into B
POP_AL                           # Load base address of points at offset 14 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 2                          # Constant assignment 2 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 2
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 2
ALUOP_AH %B%+%BH%                # Copy address
ALUOP_AL %B%+%BL%                # Copy address
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of rects at offset 20 into A
ALUOP_PUSH %B%+%BH%              # Load base address of rects at offset 20 into A
MOV_DH_AH                        # Load base address of rects at offset 20 into A
MOV_DL_AL                        # Load base address of rects at offset 20 into A
LDI_B 20                         # Load base address of rects at offset 20 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into A
POP_BH                           # Load base address of rects at offset 20 into A
POP_BL                           # Load base address of rects at offset 20 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 4
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of rects at offset 20 into A
ALUOP_PUSH %B%+%BH%              # Load base address of rects at offset 20 into A
MOV_DH_AH                        # Load base address of rects at offset 20 into A
MOV_DL_AL                        # Load base address of rects at offset 20 into A
LDI_B 20                         # Load base address of rects at offset 20 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into A
POP_BH                           # Load base address of rects at offset 20 into A
POP_BL                           # Load base address of rects at offset 20 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 4
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member width offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member width offset to address in B
LDI_A 2                          # Add struct member width offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member width offset to address in B
POP_AH                           # Add struct member width offset to address in B
POP_AL                           # Add struct member width offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char width
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char width
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of rects at offset 20 into A
ALUOP_PUSH %B%+%BH%              # Load base address of rects at offset 20 into A
MOV_DH_AH                        # Load base address of rects at offset 20 into A
MOV_DL_AL                        # Load base address of rects at offset 20 into A
LDI_B 20                         # Load base address of rects at offset 20 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into A
POP_BH                           # Load base address of rects at offset 20 into A
POP_BL                           # Load base address of rects at offset 20 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 4
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 30                        # Constant assignment 30 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of rects at offset 20 into A
ALUOP_PUSH %B%+%BH%              # Load base address of rects at offset 20 into A
MOV_DH_AH                        # Load base address of rects at offset 20 into A
MOV_DL_AL                        # Load base address of rects at offset 20 into A
LDI_B 20                         # Load base address of rects at offset 20 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into A
POP_BH                           # Load base address of rects at offset 20 into A
POP_BL                           # Load base address of rects at offset 20 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 4
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 4
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %A%+%AL%              # Add struct member height offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member height offset to address in B
LDI_A 3                          # Add struct member height offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member height offset to address in B
POP_AH                           # Add struct member height offset to address in B
POP_AL                           # Add struct member height offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 40                        # Constant assignment 40 for  unsigned char height
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char height
LDI_A .data_string_69            # "Rect array [0].x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Load base address of rects at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of rects at offset 20 into B
MOV_DH_BH                        # Load base address of rects at offset 20 into B
MOV_DL_BL                        # Load base address of rects at offset 20 into B
LDI_A 20                         # Load base address of rects at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into B
POP_AH                           # Load base address of rects at offset 20 into B
POP_AL                           # Load base address of rects at offset 20 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 4
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 4
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 4
ALUOP_AH %B%+%BH%                # Copy address
ALUOP_AL %B%+%BL%                # Copy address
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_70            # "Rect array [1].height"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 40                        # Constant assignment 40 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Load base address of rects at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of rects at offset 20 into B
MOV_DH_BH                        # Load base address of rects at offset 20 into B
MOV_DL_BL                        # Load base address of rects at offset 20 into B
LDI_A 20                         # Load base address of rects at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of rects at offset 20 into B
POP_AH                           # Load base address of rects at offset 20 into B
POP_AL                           # Load base address of rects at offset 20 into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 4
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # Multiply array offset in A by element size 4
CALL :add16_to_b                 # Add array offset in A to address reg B, element size 4
ALUOP_AH %B%+%BH%                # Copy address
ALUOP_AL %B%+%BL%                # Copy address
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_PUSH %B%+%BL%              # Add struct member height offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member height offset to address in A
LDI_B 3                          # Add struct member height offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member height offset to address in A
POP_BH                           # Add struct member height offset to address in A
POP_BL                           # Add struct member height offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of matrix at offset 28 into B
ALUOP_PUSH %A%+%AH%              # Load base address of matrix at offset 28 into B
MOV_DH_BH                        # Load base address of matrix at offset 28 into B
MOV_DL_BL                        # Load base address of matrix at offset 28 into B
LDI_A 28                         # Load base address of matrix at offset 28 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of matrix at offset 28 into B
POP_AH                           # Load base address of matrix at offset 28 into B
POP_AL                           # Load base address of matrix at offset 28 into B
LDI_A .data_bytes_5              # [1, 2, 3, 4, 5, 6, 7, 8, 9]
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
MEMCPY_C_D                       # Copy byte 8 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_A .data_string_71            # "2D array [0][0]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of matrix at offset 28 into A
ALUOP_PUSH %B%+%BH%              # Load base address of matrix at offset 28 into A
MOV_DH_AH                        # Load base address of matrix at offset 28 into A
MOV_DL_AL                        # Load base address of matrix at offset 28 into A
LDI_B 28                         # Load base address of matrix at offset 28 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of matrix at offset 28 into A
POP_BH                           # Load base address of matrix at offset 28 into A
POP_BL                           # Load base address of matrix at offset 28 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 0                          # Constant assignment 0 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_72            # "2D array [1][1]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 5                         # Constant assignment 5 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of matrix at offset 28 into A
ALUOP_PUSH %B%+%BH%              # Load base address of matrix at offset 28 into A
MOV_DH_AH                        # Load base address of matrix at offset 28 into A
MOV_DL_AL                        # Load base address of matrix at offset 28 into A
LDI_B 28                         # Load base address of matrix at offset 28 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of matrix at offset 28 into A
POP_BH                           # Load base address of matrix at offset 28 into A
POP_BL                           # Load base address of matrix at offset 28 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_73            # "2D array [2][2]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 9                         # Constant assignment 9 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of matrix at offset 28 into A
ALUOP_PUSH %B%+%BH%              # Load base address of matrix at offset 28 into A
MOV_DH_AH                        # Load base address of matrix at offset 28 into A
MOV_DL_AL                        # Load base address of matrix at offset 28 into A
LDI_B 28                         # Load base address of matrix at offset 28 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of matrix at offset 28 into A
POP_BH                           # Load base address of matrix at offset 28 into A
POP_BL                           # Load base address of matrix at offset 28 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 2                          # Constant assignment 2 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_74            # "2D array [1][2]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 6                         # Constant assignment 6 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of matrix at offset 28 into A
ALUOP_PUSH %B%+%BH%              # Load base address of matrix at offset 28 into A
MOV_DH_AH                        # Load base address of matrix at offset 28 into A
MOV_DL_AL                        # Load base address of matrix at offset 28 into A
LDI_B 28                         # Load base address of matrix at offset 28 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of matrix at offset 28 into A
POP_BH                           # Load base address of matrix at offset 28 into A
POP_BL                           # Load base address of matrix at offset 28 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 3
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 2                          # Constant assignment 2 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_arrays_return_67
LDI_BL 36                        # Bytes to free from local vars and parameters
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

:test_pointers                   # void test_pointers()
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
INCR_D                           # Load base address of val_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of val_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of val_u8 at offset 1 into B
DECR_D                           # Load base address of val_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char val_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char val_u8
INCR_D                           # Load base address of ptr_u8 at offset 2 into B
INCR_D                           # Load base address of ptr_u8 at offset 2 into B
MOV_DH_BH                        # Load base address of ptr_u8 at offset 2 into B
MOV_DL_BL                        # Load base address of ptr_u8 at offset 2 into B
DECR_D                           # Load base address of ptr_u8 at offset 2 into B
DECR_D                           # Load base address of ptr_u8 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of val_u8 at offset 1 into A
MOV_DH_AH                        # Load base address of val_u8 at offset 1 into A
MOV_DL_AL                        # Load base address of val_u8 at offset 1 into A
DECR_D                           # Load base address of val_u8 at offset 1 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_u8
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_u8
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_u8
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_u8
INCR4_D                          # Load base address of deref_val_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of deref_val_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of deref_val_u8 at offset 4 into B
DECR4_D                          # Load base address of deref_val_u8 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of ptr_u8 at offset 2 into A
INCR_D                           # Load base address of ptr_u8 at offset 2 into A
MOV_DH_AH                        # Load base address of ptr_u8 at offset 2 into A
MOV_DL_AL                        # Load base address of ptr_u8 at offset 2 into A
DECR_D                           # Load base address of ptr_u8 at offset 2 into A
DECR_D                           # Load base address of ptr_u8 at offset 2 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AL                         # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char deref_val_u8
LDI_A .data_string_75            # "8-bit pointer dereference"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of deref_val_u8 at offset 4 into B
MOV_DH_BH                        # Load base address of deref_val_u8 at offset 4 into B
MOV_DL_BL                        # Load base address of deref_val_u8 at offset 4 into B
DECR4_D                          # Load base address of deref_val_u8 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of ptr_u8 at offset 2 into A
INCR_D                           # Load base address of ptr_u8 at offset 2 into A
MOV_DH_AH                        # Load base address of ptr_u8 at offset 2 into A
MOV_DL_AL                        # Load base address of ptr_u8 at offset 2 into A
DECR_D                           # Load base address of ptr_u8 at offset 2 into A
DECR_D                           # Load base address of ptr_u8 at offset 2 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 77                        # Constant assignment 77 for  unsigned char ptr_u8_deref (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ptr_u8_deref (virtual)
LDI_A .data_string_76            # "8-bit pointer modification"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 77                        # Constant assignment 77 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of val_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of val_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of val_u8 at offset 1 into B
DECR_D                           # Load base address of val_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of val_u16 at offset 5 into B
INCR_D                           # Load base address of val_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of val_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of val_u16 at offset 5 into B
DECR4_D                          # Load base address of val_u16 at offset 5 into B
DECR_D                           # Load base address of val_u16 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1234                       # Constant assignment 1234 for  unsigned short val_u16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short val_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short val_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short val_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short val_u16
INCR4_D                          # Load base address of ptr_u16 at offset 7 into B
INCR_D                           # Load base address of ptr_u16 at offset 7 into B
INCR_D                           # Load base address of ptr_u16 at offset 7 into B
INCR_D                           # Load base address of ptr_u16 at offset 7 into B
MOV_DH_BH                        # Load base address of ptr_u16 at offset 7 into B
MOV_DL_BL                        # Load base address of ptr_u16 at offset 7 into B
DECR4_D                          # Load base address of ptr_u16 at offset 7 into B
DECR_D                           # Load base address of ptr_u16 at offset 7 into B
DECR_D                           # Load base address of ptr_u16 at offset 7 into B
DECR_D                           # Load base address of ptr_u16 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of val_u16 at offset 5 into A
INCR_D                           # Load base address of val_u16 at offset 5 into A
MOV_DH_AH                        # Load base address of val_u16 at offset 5 into A
MOV_DL_AL                        # Load base address of val_u16 at offset 5 into A
DECR4_D                          # Load base address of val_u16 at offset 5 into A
DECR_D                           # Load base address of val_u16 at offset 5 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *ptr_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *ptr_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_u16
INCR8_D                          # Load base address of deref_val_u16 at offset 9 into B
INCR_D                           # Load base address of deref_val_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of deref_val_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of deref_val_u16 at offset 9 into B
DECR8_D                          # Load base address of deref_val_u16 at offset 9 into B
DECR_D                           # Load base address of deref_val_u16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
MOV_DH_AH                        # Load base address of ptr_u16 at offset 7 into A
MOV_DL_AL                        # Load base address of ptr_u16 at offset 7 into A
DECR4_D                          # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short deref_val_u16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short deref_val_u16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short deref_val_u16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short deref_val_u16
LDI_A .data_string_77            # "16-bit pointer dereference"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1234                       # Constant assignment 1234 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of deref_val_u16 at offset 9 into B
INCR_D                           # Load base address of deref_val_u16 at offset 9 into B
MOV_DH_BH                        # Load base address of deref_val_u16 at offset 9 into B
MOV_DL_BL                        # Load base address of deref_val_u16 at offset 9 into B
DECR8_D                          # Load base address of deref_val_u16 at offset 9 into B
DECR_D                           # Load base address of deref_val_u16 at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
INCR_D                           # Load base address of ptr_u16 at offset 7 into A
MOV_DH_AH                        # Load base address of ptr_u16 at offset 7 into A
MOV_DL_AL                        # Load base address of ptr_u16 at offset 7 into A
DECR4_D                          # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
DECR_D                           # Load base address of ptr_u16 at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 5678                       # Constant assignment 5678 for  unsigned short ptr_u16_deref (virtual)
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short ptr_u16_deref (virtual)
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short ptr_u16_deref (virtual)
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short ptr_u16_deref (virtual)
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short ptr_u16_deref (virtual)
LDI_A .data_string_78            # "16-bit pointer modification"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 5678                       # Constant assignment 5678 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of val_u16 at offset 5 into B
INCR_D                           # Load base address of val_u16 at offset 5 into B
MOV_DH_BH                        # Load base address of val_u16 at offset 5 into B
MOV_DL_BL                        # Load base address of val_u16 at offset 5 into B
DECR4_D                          # Load base address of val_u16 at offset 5 into B
DECR_D                           # Load base address of val_u16 at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of pt at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of pt at offset 11 into B
MOV_DH_BH                        # Load base address of pt at offset 11 into B
MOV_DL_BL                        # Load base address of pt at offset 11 into B
LDI_A 11                         # Load base address of pt at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt at offset 11 into B
POP_AH                           # Load base address of pt at offset 11 into B
POP_AL                           # Load base address of pt at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 100                       # Constant assignment 100 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AL%              # Load base address of pt at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of pt at offset 11 into B
MOV_DH_BH                        # Load base address of pt at offset 11 into B
MOV_DL_BL                        # Load base address of pt at offset 11 into B
LDI_A 11                         # Load base address of pt at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt at offset 11 into B
POP_AH                           # Load base address of pt at offset 11 into B
POP_AL                           # Load base address of pt at offset 11 into B
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_pt at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_pt at offset 13 into B
MOV_DH_BH                        # Load base address of ptr_pt at offset 13 into B
MOV_DL_BL                        # Load base address of ptr_pt at offset 13 into B
LDI_A 13                         # Load base address of ptr_pt at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_pt at offset 13 into B
POP_AH                           # Load base address of ptr_pt at offset 13 into B
POP_AL                           # Load base address of ptr_pt at offset 13 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Load base address of pt at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of pt at offset 11 into A
MOV_DH_AH                        # Load base address of pt at offset 11 into A
MOV_DL_AL                        # Load base address of pt at offset 11 into A
LDI_B 11                         # Load base address of pt at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt at offset 11 into A
POP_BH                           # Load base address of pt at offset 11 into A
POP_BL                           # Load base address of pt at offset 11 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct Point *ptr_pt
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct Point *ptr_pt
ALUOP_ADDR_B %A%+%AL%            # Store to  struct Point *ptr_pt
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct Point *ptr_pt
LDI_A .data_string_79            # "Struct pointer access ->x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 100                       # Constant assignment 100 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_pt at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_pt at offset 13 into B
MOV_DH_BH                        # Load base address of ptr_pt at offset 13 into B
MOV_DL_BL                        # Load base address of ptr_pt at offset 13 into B
LDI_A 13                         # Load base address of ptr_pt at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_pt at offset 13 into B
POP_AH                           # Load base address of ptr_pt at offset 13 into B
POP_AL                           # Load base address of ptr_pt at offset 13 into B
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_80            # "Struct pointer access ->y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 200                       # Constant assignment 200 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_pt at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_pt at offset 13 into B
MOV_DH_BH                        # Load base address of ptr_pt at offset 13 into B
MOV_DL_BL                        # Load base address of ptr_pt at offset 13 into B
LDI_A 13                         # Load base address of ptr_pt at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_pt at offset 13 into B
POP_AH                           # Load base address of ptr_pt at offset 13 into B
POP_AL                           # Load base address of ptr_pt at offset 13 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of ptr_pt at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of ptr_pt at offset 13 into A
MOV_DH_AH                        # Load base address of ptr_pt at offset 13 into A
MOV_DL_AL                        # Load base address of ptr_pt at offset 13 into A
LDI_B 13                         # Load base address of ptr_pt at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_pt at offset 13 into A
POP_BH                           # Load base address of ptr_pt at offset 13 into A
POP_BL                           # Load base address of ptr_pt at offset 13 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 111                       # Constant assignment 111 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of ptr_pt at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of ptr_pt at offset 13 into A
MOV_DH_AH                        # Load base address of ptr_pt at offset 13 into A
MOV_DL_AL                        # Load base address of ptr_pt at offset 13 into A
LDI_B 13                         # Load base address of ptr_pt at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_pt at offset 13 into A
POP_BH                           # Load base address of ptr_pt at offset 13 into A
POP_BL                           # Load base address of ptr_pt at offset 13 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 222                       # Constant assignment 222 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
LDI_A .data_string_81            # "Struct pointer modification ->x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 111                       # Constant assignment 111 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Load base address of pt at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of pt at offset 11 into A
MOV_DH_AH                        # Load base address of pt at offset 11 into A
MOV_DL_AL                        # Load base address of pt at offset 11 into A
LDI_B 11                         # Load base address of pt at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt at offset 11 into A
POP_BH                           # Load base address of pt at offset 11 into A
POP_BL                           # Load base address of pt at offset 11 into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_82            # "Struct pointer modification ->y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 222                       # Constant assignment 222 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Load base address of pt at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of pt at offset 11 into A
MOV_DH_AH                        # Load base address of pt at offset 11 into A
MOV_DL_AL                        # Load base address of pt at offset 11 into A
LDI_B 11                         # Load base address of pt at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt at offset 11 into A
POP_BH                           # Load base address of pt at offset 11 into A
POP_BL                           # Load base address of pt at offset 11 into A
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_pointers_return_68
LDI_BL 14                        # Bytes to free from local vars and parameters
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

:test_pointer_arithmetic         # void test_pointer_arithmetic()
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
LDI_BL 33                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of bytes at offset 1 into B
MOV_DH_BH                        # Load base address of bytes at offset 1 into B
MOV_DL_BL                        # Load base address of bytes at offset 1 into B
DECR_D                           # Load base address of bytes at offset 1 into B
LDI_A .data_bytes_3              # [10, 20, 30, 40, 50]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY_C_D                       # Copy byte 4 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
INCR4_D                          # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
MOV_DH_BH                        # Load base address of ptr_bytes at offset 6 into B
MOV_DL_BL                        # Load base address of ptr_bytes at offset 6 into B
DECR4_D                          # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of bytes at offset 1 into A
MOV_DH_AH                        # Load base address of bytes at offset 1 into A
MOV_DL_AL                        # Load base address of bytes at offset 1 into A
DECR_D                           # Load base address of bytes at offset 1 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
INCR4_D                          # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
MOV_DH_BH                        # Load base address of ptr_bytes at offset 6 into B
MOV_DL_BL                        # Load base address of ptr_bytes at offset 6 into B
DECR4_D                          # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 for pointer  unsigned char *ptr_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
MOV_DH_BH                        # Load base address of ptr_bytes at offset 6 into B
MOV_DL_BL                        # Load base address of ptr_bytes at offset 6 into B
DECR4_D                          # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
LDI_A .data_string_83            # "Pointer + 2 (8-bit)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of ptr_bytes at offset 6 into A
INCR_D                           # Load base address of ptr_bytes at offset 6 into A
INCR_D                           # Load base address of ptr_bytes at offset 6 into A
MOV_DH_AH                        # Load base address of ptr_bytes at offset 6 into A
MOV_DL_AL                        # Load base address of ptr_bytes at offset 6 into A
DECR4_D                          # Load base address of ptr_bytes at offset 6 into A
DECR_D                           # Load base address of ptr_bytes at offset 6 into A
DECR_D                           # Load base address of ptr_bytes at offset 6 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AL                         # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
MOV_DH_BH                        # Load base address of ptr_bytes at offset 6 into B
MOV_DL_BL                        # Load base address of ptr_bytes at offset 6 into B
DECR4_D                          # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for pointer  unsigned char *ptr_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
INCR_D                           # Load base address of ptr_bytes at offset 6 into B
MOV_DH_BH                        # Load base address of ptr_bytes at offset 6 into B
MOV_DL_BL                        # Load base address of ptr_bytes at offset 6 into B
DECR4_D                          # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
DECR_D                           # Load base address of ptr_bytes at offset 6 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_bytes
LDI_A .data_string_84            # "Pointer - 1 (8-bit)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 20                        # Constant assignment 20 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of ptr_bytes at offset 6 into A
INCR_D                           # Load base address of ptr_bytes at offset 6 into A
INCR_D                           # Load base address of ptr_bytes at offset 6 into A
MOV_DH_AH                        # Load base address of ptr_bytes at offset 6 into A
MOV_DL_AL                        # Load base address of ptr_bytes at offset 6 into A
DECR4_D                          # Load base address of ptr_bytes at offset 6 into A
DECR_D                           # Load base address of ptr_bytes at offset 6 into A
DECR_D                           # Load base address of ptr_bytes at offset 6 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AL                         # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of words at offset 8 into B
MOV_DH_BH                        # Load base address of words at offset 8 into B
MOV_DL_BL                        # Load base address of words at offset 8 into B
DECR8_D                          # Load base address of words at offset 8 into B
LDI_A .data_bytes_4              # [100, 200, 300, 400]
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
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_words at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_words at offset 16 into B
MOV_DH_BH                        # Load base address of ptr_words at offset 16 into B
MOV_DL_BL                        # Load base address of ptr_words at offset 16 into B
LDI_A 16                         # Load base address of ptr_words at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_words at offset 16 into B
POP_AH                           # Load base address of ptr_words at offset 16 into B
POP_AL                           # Load base address of ptr_words at offset 16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR8_D                          # Load base address of words at offset 8 into A
MOV_DH_AH                        # Load base address of words at offset 8 into A
MOV_DL_AL                        # Load base address of words at offset 8 into A
DECR8_D                          # Load base address of words at offset 8 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *ptr_words
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_words
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *ptr_words
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_words
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_words at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_words at offset 16 into B
MOV_DH_BH                        # Load base address of ptr_words at offset 16 into B
MOV_DL_BL                        # Load base address of ptr_words at offset 16 into B
LDI_A 16                         # Load base address of ptr_words at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_words at offset 16 into B
POP_AH                           # Load base address of ptr_words at offset 16 into B
POP_AL                           # Load base address of ptr_words at offset 16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 for pointer  unsigned short *ptr_words
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_words at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_words at offset 16 into B
MOV_DH_BH                        # Load base address of ptr_words at offset 16 into B
MOV_DL_BL                        # Load base address of ptr_words at offset 16 into B
LDI_A 16                         # Load base address of ptr_words at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_words at offset 16 into B
POP_AH                           # Load base address of ptr_words at offset 16 into B
POP_AL                           # Load base address of ptr_words at offset 16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply operand in B by pointer unit size 2
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *ptr_words
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_words
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *ptr_words
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *ptr_words
LDI_A .data_string_85            # "Pointer + 2 (16-bit)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 300                        # Constant assignment 300 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of ptr_words at offset 16 into A
ALUOP_PUSH %B%+%BH%              # Load base address of ptr_words at offset 16 into A
MOV_DH_AH                        # Load base address of ptr_words at offset 16 into A
MOV_DL_AL                        # Load base address of ptr_words at offset 16 into A
LDI_B 16                         # Load base address of ptr_words at offset 16 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_words at offset 16 into A
POP_BH                           # Load base address of ptr_words at offset 16 into A
POP_BL                           # Load base address of ptr_words at offset 16 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points2 at offset 18 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points2 at offset 18 into A
MOV_DH_AH                        # Load base address of points2 at offset 18 into A
MOV_DL_AL                        # Load base address of points2 at offset 18 into A
LDI_B 18                         # Load base address of points2 at offset 18 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points2 at offset 18 into A
POP_BH                           # Load base address of points2 at offset 18 into A
POP_BL                           # Load base address of points2 at offset 18 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 0                          # Constant assignment 0 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points2 at offset 18 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points2 at offset 18 into A
MOV_DH_AH                        # Load base address of points2 at offset 18 into A
MOV_DL_AL                        # Load base address of points2 at offset 18 into A
LDI_B 18                         # Load base address of points2 at offset 18 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points2 at offset 18 into A
POP_BH                           # Load base address of points2 at offset 18 into A
POP_BL                           # Load base address of points2 at offset 18 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Load base address of points2 at offset 18 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points2 at offset 18 into A
MOV_DH_AH                        # Load base address of points2 at offset 18 into A
MOV_DL_AL                        # Load base address of points2 at offset 18 into A
LDI_B 18                         # Load base address of points2 at offset 18 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points2 at offset 18 into A
POP_BH                           # Load base address of points2 at offset 18 into A
POP_BL                           # Load base address of points2 at offset 18 into A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply array offset in B by element size 2
CALL :add16_to_a                 # Add array offset in B to address reg A, element size 2
ALUOP_BH %A%+%AH%                # Copy address
ALUOP_BL %A%+%AL%                # Copy address
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Load base address of points2 at offset 18 into A
ALUOP_PUSH %B%+%BH%              # Load base address of points2 at offset 18 into A
MOV_DH_AH                        # Load base address of points2 at offset 18 into A
MOV_DL_AL                        # Load base address of points2 at offset 18 into A
LDI_B 18                         # Load base address of points2 at offset 18 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of points2 at offset 18 into A
POP_BH                           # Load base address of points2 at offset 18 into A
POP_BL                           # Load base address of points2 at offset 18 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct Point *ptr_points
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
ALUOP_ADDR_B %A%+%AL%            # Store to  struct Point *ptr_points
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for pointer  struct Point *ptr_points
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply operand in B by pointer unit size 2
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct Point *ptr_points
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
ALUOP_ADDR_B %A%+%AL%            # Store to  struct Point *ptr_points
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
LDI_A .data_string_86            # "Pointer + 1 (struct size 3)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for pointer  struct Point *ptr_points
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP16O_B %B<<1%+%BL% %B<<1%+%BH%+%Cin% %B<<1%+%BH% # Multiply operand in B by pointer unit size 2
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct Point *ptr_points
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
ALUOP_ADDR_B %A%+%AL%            # Store to  struct Point *ptr_points
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct Point *ptr_points
LDI_A .data_string_87            # "Pointer + 2 (struct size 3)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 3                         # Constant assignment 3 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_points at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_points at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_points at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_points at offset 24 into B
LDI_A 24                         # Load base address of ptr_points at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_points at offset 24 into B
POP_AH                           # Load base address of ptr_points at offset 24 into B
POP_AL                           # Load base address of ptr_points at offset 24 into B
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of vals at offset 26 into B
ALUOP_PUSH %A%+%AH%              # Load base address of vals at offset 26 into B
MOV_DH_BH                        # Load base address of vals at offset 26 into B
MOV_DL_BL                        # Load base address of vals at offset 26 into B
LDI_A 26                         # Load base address of vals at offset 26 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of vals at offset 26 into B
POP_AH                           # Load base address of vals at offset 26 into B
POP_AL                           # Load base address of vals at offset 26 into B
LDI_A .data_bytes_6              # [111, 222, 333]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY4_C_D                      # Copy bytes 0-3 from C to D
MEMCPY_C_D                       # Copy byte 4 from C to D
MEMCPY_C_D                       # Copy byte 5 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
ALUOP_PUSH %A%+%AL%              # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p_inc at offset 32 into B
MOV_DH_BH                        # Load base address of p_inc at offset 32 into B
MOV_DL_BL                        # Load base address of p_inc at offset 32 into B
LDI_A 32                         # Load base address of p_inc at offset 32 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into B
POP_AH                           # Load base address of p_inc at offset 32 into B
POP_AL                           # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Load base address of vals at offset 26 into A
ALUOP_PUSH %B%+%BH%              # Load base address of vals at offset 26 into A
MOV_DH_AH                        # Load base address of vals at offset 26 into A
MOV_DL_AL                        # Load base address of vals at offset 26 into A
LDI_B 26                         # Load base address of vals at offset 26 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of vals at offset 26 into A
POP_BH                           # Load base address of vals at offset 26 into A
POP_BL                           # Load base address of vals at offset 26 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *p_inc
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *p_inc
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p_inc at offset 32 into B
MOV_DH_BH                        # Load base address of p_inc at offset 32 into B
MOV_DL_BL                        # Load base address of p_inc at offset 32 into B
LDI_A 32                         # Load base address of p_inc at offset 32 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into B
POP_AH                           # Load base address of p_inc at offset 32 into B
POP_AL                           # Load base address of p_inc at offset 32 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: preserve B before pointer arithmetic
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: preserve B before pointer arithmetic
LDI_B 2                          # UnaryOp p++: pointed-at type size for  unsigned short *p_inc
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # UnaryOp p++: move pointer by pointed-at type size for  unsigned short *p_inc
POP_BL                           # UnaryOp p++: Restore B after pointer arithmetic
POP_BH                           # UnaryOp p++: Restore B after pointer arithmetic
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %A%+%AL%              # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p_inc at offset 32 into B
MOV_DH_BH                        # Load base address of p_inc at offset 32 into B
MOV_DL_BL                        # Load base address of p_inc at offset 32 into B
LDI_A 32                         # Load base address of p_inc at offset 32 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into B
POP_AH                           # Load base address of p_inc at offset 32 into B
POP_AL                           # Load base address of p_inc at offset 32 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *p_inc
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *p_inc
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
LDI_A .data_string_88            # "Pointer increment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 222                        # Constant assignment 222 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p_inc at offset 32 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p_inc at offset 32 into A
MOV_DH_AH                        # Load base address of p_inc at offset 32 into A
MOV_DL_AL                        # Load base address of p_inc at offset 32 into A
LDI_B 32                         # Load base address of p_inc at offset 32 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into A
POP_BH                           # Load base address of p_inc at offset 32 into A
POP_BL                           # Load base address of p_inc at offset 32 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
ALUOP_PUSH %A%+%AL%              # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p_inc at offset 32 into B
MOV_DH_BH                        # Load base address of p_inc at offset 32 into B
MOV_DL_BL                        # Load base address of p_inc at offset 32 into B
LDI_A 32                         # Load base address of p_inc at offset 32 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into B
POP_AH                           # Load base address of p_inc at offset 32 into B
POP_AL                           # Load base address of p_inc at offset 32 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BH%              # UnaryOp p--: preserve B before pointer arithmetic
ALUOP_PUSH %B%+%BL%              # UnaryOp p--: preserve B before pointer arithmetic
LDI_B 2                          # UnaryOp p--: pointed-at type size for  unsigned short *p_inc
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # UnaryOp p--: move pointer by pointed-at type size for  unsigned short *p_inc
POP_BL                           # UnaryOp p--: Restore B after pointer arithmetic
POP_BH                           # UnaryOp p--: Restore B after pointer arithmetic
ALUOP_PUSH %B%+%BH%              # UnaryOp p--: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p--: Save B before generating lvalue
ALUOP_PUSH %A%+%AL%              # Load base address of p_inc at offset 32 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p_inc at offset 32 into B
MOV_DH_BH                        # Load base address of p_inc at offset 32 into B
MOV_DL_BL                        # Load base address of p_inc at offset 32 into B
LDI_A 32                         # Load base address of p_inc at offset 32 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into B
POP_AH                           # Load base address of p_inc at offset 32 into B
POP_AL                           # Load base address of p_inc at offset 32 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short *p_inc
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short *p_inc
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short *p_inc
POP_BL                           # UnaryOp p--: Restore B, return rvalue in A
POP_BH                           # UnaryOp p--: Restore B, return rvalue in A
LDI_A .data_string_89            # "Pointer decrement"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 111                        # Constant assignment 111 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p_inc at offset 32 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p_inc at offset 32 into A
MOV_DH_AH                        # Load base address of p_inc at offset 32 into A
MOV_DL_AL                        # Load base address of p_inc at offset 32 into A
LDI_B 32                         # Load base address of p_inc at offset 32 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p_inc at offset 32 into A
POP_BH                           # Load base address of p_inc at offset 32 into A
POP_BL                           # Load base address of p_inc at offset 32 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
.test_pointer_arithmetic_return_69
LDI_BL 33                        # Bytes to free from local vars and parameters
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

:test_structs                    # void test_structs()
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
LDI_BL 13                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of pt1 at offset 1 into B
MOV_DH_BH                        # Load base address of pt1 at offset 1 into B
MOV_DL_BL                        # Load base address of pt1 at offset 1 into B
DECR_D                           # Load base address of pt1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 55                        # Constant assignment 55 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
INCR_D                           # Load base address of pt1 at offset 1 into B
MOV_DH_BH                        # Load base address of pt1 at offset 1 into B
MOV_DL_BL                        # Load base address of pt1 at offset 1 into B
DECR_D                           # Load base address of pt1 at offset 1 into B
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 66                        # Constant assignment 66 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
LDI_A .data_string_90            # "Struct member .x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 55                        # Constant assignment 55 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR_D                           # Load base address of pt1 at offset 1 into A
MOV_DH_AH                        # Load base address of pt1 at offset 1 into A
MOV_DL_AL                        # Load base address of pt1 at offset 1 into A
DECR_D                           # Load base address of pt1 at offset 1 into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_91            # "Struct member .y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 66                        # Constant assignment 66 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR_D                           # Load base address of pt1 at offset 1 into A
MOV_DH_AH                        # Load base address of pt1 at offset 1 into A
MOV_DL_AL                        # Load base address of pt1 at offset 1 into A
DECR_D                           # Load base address of pt1 at offset 1 into A
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of ws at offset 3 into B
INCR_D                           # Load base address of ws at offset 3 into B
INCR_D                           # Load base address of ws at offset 3 into B
MOV_DH_BH                        # Load base address of ws at offset 3 into B
MOV_DL_BL                        # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4660                       # Constant assignment 0x1234 for  unsigned short a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short a
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short a
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short a
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short a
INCR_D                           # Load base address of ws at offset 3 into B
INCR_D                           # Load base address of ws at offset 3 into B
INCR_D                           # Load base address of ws at offset 3 into B
MOV_DH_BH                        # Load base address of ws at offset 3 into B
MOV_DL_BL                        # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
DECR_D                           # Load base address of ws at offset 3 into B
ALUOP_PUSH %A%+%AL%              # Add struct member b offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member b offset to address in B
LDI_A 2                          # Add struct member b offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member b offset to address in B
POP_AH                           # Add struct member b offset to address in B
POP_AL                           # Add struct member b offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 22136                      # Constant assignment 0x5678 for  unsigned short b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short b
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short b
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short b
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short b
LDI_A .data_string_92            # "Struct 16-bit member .a"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 4660                       # Constant assignment 0x1234 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
INCR_D                           # Load base address of ws at offset 3 into A
INCR_D                           # Load base address of ws at offset 3 into A
INCR_D                           # Load base address of ws at offset 3 into A
MOV_DH_AH                        # Load base address of ws at offset 3 into A
MOV_DL_AL                        # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
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
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_93            # "Struct 16-bit member .b"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 22136                      # Constant assignment 0x5678 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
INCR_D                           # Load base address of ws at offset 3 into A
INCR_D                           # Load base address of ws at offset 3 into A
INCR_D                           # Load base address of ws at offset 3 into A
MOV_DH_AH                        # Load base address of ws at offset 3 into A
MOV_DL_AL                        # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
DECR_D                           # Load base address of ws at offset 3 into A
ALUOP_PUSH %B%+%BL%              # Add struct member b offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member b offset to address in A
LDI_B 2                          # Add struct member b offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member b offset to address in A
POP_BH                           # Add struct member b offset to address in A
POP_BL                           # Add struct member b offset to address in A
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
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
MOV_DH_BH                        # Load base address of cont at offset 7 into B
MOV_DL_BL                        # Load base address of cont at offset 7 into B
DECR4_D                          # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
INCR4_D                          # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
MOV_DH_BH                        # Load base address of cont at offset 7 into B
MOV_DL_BL                        # Load base address of cont at offset 7 into B
DECR4_D                          # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
INCR4_D                          # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
MOV_DH_BH                        # Load base address of cont at offset 7 into B
MOV_DL_BL                        # Load base address of cont at offset 7 into B
DECR4_D                          # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
ALUOP_PUSH %A%+%AL%              # Add struct member p2 offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member p2 offset to address in B
LDI_A 2                          # Add struct member p2 offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member p2 offset to address in B
POP_AH                           # Add struct member p2 offset to address in B
POP_AL                           # Add struct member p2 offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 30                        # Constant assignment 30 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
INCR4_D                          # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
MOV_DH_BH                        # Load base address of cont at offset 7 into B
MOV_DL_BL                        # Load base address of cont at offset 7 into B
DECR4_D                          # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
ALUOP_PUSH %A%+%AL%              # Add struct member p2 offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member p2 offset to address in B
LDI_A 2                          # Add struct member p2 offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member p2 offset to address in B
POP_AH                           # Add struct member p2 offset to address in B
POP_AL                           # Add struct member p2 offset to address in B
ALUOP_PUSH %A%+%AL%              # Add struct member y offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member y offset to address in B
LDI_A 1                          # Add struct member y offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in B
POP_AH                           # Add struct member y offset to address in B
POP_AL                           # Add struct member y offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 40                        # Constant assignment 40 for  unsigned char y
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
INCR4_D                          # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
INCR_D                           # Load base address of cont at offset 7 into B
MOV_DH_BH                        # Load base address of cont at offset 7 into B
MOV_DL_BL                        # Load base address of cont at offset 7 into B
DECR4_D                          # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
DECR_D                           # Load base address of cont at offset 7 into B
ALUOP_PUSH %A%+%AL%              # Add struct member flags offset to address in B
ALUOP_PUSH %A%+%AH%              # Add struct member flags offset to address in B
LDI_A 4                          # Add struct member flags offset to address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member flags offset to address in B
POP_AH                           # Add struct member flags offset to address in B
POP_AL                           # Add struct member flags offset to address in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char flags
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char flags
LDI_A .data_string_94            # "Nested struct .p1.x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR4_D                          # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
MOV_DH_AH                        # Load base address of cont at offset 7 into A
MOV_DL_AL                        # Load base address of cont at offset 7 into A
DECR4_D                          # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_95            # "Nested struct .p2.y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 40                        # Constant assignment 40 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR4_D                          # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
MOV_DH_AH                        # Load base address of cont at offset 7 into A
MOV_DL_AL                        # Load base address of cont at offset 7 into A
DECR4_D                          # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
ALUOP_PUSH %B%+%BL%              # Add struct member p2 offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member p2 offset to address in A
LDI_B 2                          # Add struct member p2 offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member p2 offset to address in A
POP_BH                           # Add struct member p2 offset to address in A
POP_BL                           # Add struct member p2 offset to address in A
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_96            # "Nested struct .flags"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 255                       # Constant assignment 0xFF for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR4_D                          # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
INCR_D                           # Load base address of cont at offset 7 into A
MOV_DH_AH                        # Load base address of cont at offset 7 into A
MOV_DL_AL                        # Load base address of cont at offset 7 into A
DECR4_D                          # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
DECR_D                           # Load base address of cont at offset 7 into A
ALUOP_PUSH %B%+%BL%              # Add struct member flags offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member flags offset to address in A
LDI_B 4                          # Add struct member flags offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member flags offset to address in A
POP_BH                           # Add struct member flags offset to address in A
POP_BL                           # Add struct member flags offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of pt2 at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of pt2 at offset 12 into B
MOV_DH_BH                        # Load base address of pt2 at offset 12 into B
MOV_DL_BL                        # Load base address of pt2 at offset 12 into B
LDI_A 12                         # Load base address of pt2 at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt2 at offset 12 into B
POP_AH                           # Load base address of pt2 at offset 12 into B
POP_AL                           # Load base address of pt2 at offset 12 into B
LDI_A .data_bytes_7              # [88, 99]
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
PUSH_CH                          # Save C register
PUSH_CL                          # Save C register
ALUOP_CH %A%+%AH%                # Copy source pointer to C
ALUOP_CL %A%+%AL%                # Copy source pointer to C
ALUOP_DH %B%+%BH%                # Set destination pointer in D
ALUOP_DL %B%+%BL%                # Set destination pointer in D
MEMCPY_C_D                       # Copy byte 0 from C to D
MEMCPY_C_D                       # Copy byte 1 from C to D
POP_CL                           # Restore C register
POP_CH                           # Restore C register
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
LDI_A .data_string_97            # "Struct init list .x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 88                        # Constant assignment 88 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Load base address of pt2 at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of pt2 at offset 12 into A
MOV_DH_AH                        # Load base address of pt2 at offset 12 into A
MOV_DL_AL                        # Load base address of pt2 at offset 12 into A
LDI_B 12                         # Load base address of pt2 at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt2 at offset 12 into A
POP_BH                           # Load base address of pt2 at offset 12 into A
POP_BL                           # Load base address of pt2 at offset 12 into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_98            # "Struct init list .y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 99                        # Constant assignment 99 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Load base address of pt2 at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of pt2 at offset 12 into A
MOV_DH_AH                        # Load base address of pt2 at offset 12 into A
MOV_DL_AL                        # Load base address of pt2 at offset 12 into A
LDI_B 12                         # Load base address of pt2 at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of pt2 at offset 12 into A
POP_BH                           # Load base address of pt2 at offset 12 into A
POP_BL                           # Load base address of pt2 at offset 12 into A
ALUOP_PUSH %B%+%BL%              # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BH%              # Add struct member y offset to address in A
LDI_B 1                          # Add struct member y offset to address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add struct member y offset to address in A
POP_BH                           # Add struct member y offset to address in A
POP_BL                           # Add struct member y offset to address in A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_structs_return_70
LDI_BL 13                        # Bytes to free from local vars and parameters
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
LDI_C .data_string_99            # "=== Compiler Test Suite ===\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_arithmetic
# function returns nothing, not popping a return value
CALL :test_bitwise
# function returns nothing, not popping a return value
CALL :test_shifts
# function returns nothing, not popping a return value
CALL :test_comparisons
# function returns nothing, not popping a return value
CALL :test_boolean
# function returns nothing, not popping a return value
CALL :test_unary
# function returns nothing, not popping a return value
CALL :test_inc_dec
# function returns nothing, not popping a return value
CALL :test_assignment
# function returns nothing, not popping a return value
CALL :test_arrays
# function returns nothing, not popping a return value
CALL :test_pointers
# function returns nothing, not popping a return value
CALL :test_pointer_arithmetic
# function returns nothing, not popping a return value
CALL :test_structs
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_100           # "=== Test Results ===\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
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
LDI_C .data_string_101           # "Total tests: %U\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
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
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_102           # "Failed tests: %U\n"
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
JNE .binarybool_isfalse_74       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_74       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_75
.binarybool_isfalse_74
LDI_A 0                          # BinaryOp == was false
.binarybool_done_75
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_72           # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_103           # "\n*** SOME TESTS FAILED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .end_if_73                   # Done with false condition
.condition_true_72               # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_104           # "\n*** ALL TESTS PASSED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_73                       # End If
.main_return_71
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.local_static_init_1
RET
.data_bytes_0 0x01 0x02 0x03 0x04 0x05
.data_bytes_1 0x00 0x64 0x00 0xc8 0x01 0x2c
.data_bytes_2 0x0a 0x14
.data_string_0 "FAIL: \0"
.data_string_1 "\n\0"
.data_string_2 "  Expected: 0x%x, Got: 0x%x\n\0"
.data_string_3 "  Expected: 0x%X, Got: 0x%X\n\0"
.data_string_4 "  Expected: %d, Got: %d\n\0"
.data_string_5 "  Expected: %D, Got: %D\n\0"
.data_string_6 "8-bit addition\0"
.data_string_7 "16-bit addition\0"
.data_string_8 "8-bit subtraction\0"
.data_string_9 "16-bit subtraction\0"
.data_string_10 "Signed 8-bit addition\0"
.data_string_11 "Signed 16-bit subtraction\0"
.data_string_12 "8-bit AND\0"
.data_string_13 "16-bit AND\0"
.data_string_14 "8-bit OR\0"
.data_string_15 "16-bit OR\0"
.data_string_16 "8-bit XOR\0"
.data_string_17 "16-bit XOR\0"
.data_string_18 "8-bit left shift by 3\0"
.data_string_19 "16-bit left shift by 8\0"
.data_string_20 "8-bit right shift by 2\0"
.data_string_21 "16-bit right shift by 4\0"
.data_string_22 "Multiple shifts\0"
.data_string_23 "8-bit equality true\0"
.data_string_24 "8-bit equality false\0"
.data_string_25 "16-bit equality true\0"
.data_string_26 "16-bit equality false\0"
.data_string_27 "8-bit inequality true\0"
.data_string_28 "16-bit inequality true\0"
.data_string_29 "Logical AND (true && true)\0"
.data_string_30 "Logical AND (true && false)\0"
.data_string_31 "Logical OR (false || false)\0"
.data_string_32 "Logical OR (false || true)\0"
.data_string_33 "Complex boolean expression\0"
.data_string_34 "8-bit unary negation\0"
.data_string_35 "16-bit unary negation\0"
.data_string_36 "8-bit bitwise NOT\0"
.data_string_37 "16-bit bitwise NOT\0"
.data_string_38 "Logical NOT (true to false)\0"
.data_string_39 "Logical NOT (false to true)\0"
.data_string_40 "Unary plus\0"
.data_string_41 "Pre-increment value\0"
.data_string_42 "Pre-increment return\0"
.data_string_43 "Post-increment value\0"
.data_string_44 "Post-increment return\0"
.data_string_45 "Pre-decrement value\0"
.data_string_46 "Pre-decrement return\0"
.data_string_47 "Post-decrement value\0"
.data_string_48 "Post-decrement return\0"
.data_string_49 "Pre-increment 16-bit value\0"
.data_string_50 "Pre-increment 16-bit return\0"
.data_string_51 "Simple 8-bit assignment\0"
.data_string_52 "Simple 16-bit assignment\0"
.data_string_53 "8-bit += assignment\0"
.data_string_54 "16-bit -= assignment\0"
.data_string_55 "<<= assignment\0"
.data_string_56 ">>= assignment\0"
.data_string_57 "&= assignment\0"
.data_string_58 "|= assignment\0"
.data_string_59 "^= assignment\0"
.data_bytes_3 0x0a 0x14 0x1e 0x28 0x32
.data_string_60 "Array access [0]\0"
.data_string_61 "Array access [2]\0"
.data_string_62 "Array access [4]\0"
.data_string_63 "Array modification\0"
.data_bytes_4 0x00 0x64 0x00 0xc8 0x01 0x2c 0x01 0x90
.data_string_64 "16-bit array access [0]\0"
.data_string_65 "16-bit array access [3]\0"
.data_string_66 "Struct array [0].x\0"
.data_string_67 "Struct array [1].y\0"
.data_string_68 "Struct array [2].x\0"
.data_string_69 "Rect array [0].x\0"
.data_string_70 "Rect array [1].height\0"
.data_bytes_5 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09
.data_string_71 "2D array [0][0]\0"
.data_string_72 "2D array [1][1]\0"
.data_string_73 "2D array [2][2]\0"
.data_string_74 "2D array [1][2]\0"
.data_string_75 "8-bit pointer dereference\0"
.data_string_76 "8-bit pointer modification\0"
.data_string_77 "16-bit pointer dereference\0"
.data_string_78 "16-bit pointer modification\0"
.data_string_79 "Struct pointer access ->x\0"
.data_string_80 "Struct pointer access ->y\0"
.data_string_81 "Struct pointer modification ->x\0"
.data_string_82 "Struct pointer modification ->y\0"
.data_string_83 "Pointer + 2 (8-bit)\0"
.data_string_84 "Pointer - 1 (8-bit)\0"
.data_string_85 "Pointer + 2 (16-bit)\0"
.data_string_86 "Pointer + 1 (struct size 3)\0"
.data_string_87 "Pointer + 2 (struct size 3)\0"
.data_bytes_6 0x00 0x6f 0x00 0xde 0x01 0x4d
.data_string_88 "Pointer increment\0"
.data_string_89 "Pointer decrement\0"
.data_string_90 "Struct member .x\0"
.data_string_91 "Struct member .y\0"
.data_string_92 "Struct 16-bit member .a\0"
.data_string_93 "Struct 16-bit member .b\0"
.data_string_94 "Nested struct .p1.x\0"
.data_string_95 "Nested struct .p2.y\0"
.data_string_96 "Nested struct .flags\0"
.data_bytes_7 0x58 0x63
.data_string_97 "Struct init list .x\0"
.data_string_98 "Struct init list .y\0"
.data_string_99 "=== Compiler Test Suite ===\n\0"
.data_string_100 "=== Test Results ===\n\0"
.data_string_101 "Total tests: %U\n\0"
.data_string_102 "Failed tests: %U\n\0"
.data_string_103 "\n*** SOME TESTS FAILED ***\n\0"
.data_string_104 "\n*** ALL TESTS PASSED ***\n\0"
.var_g_byte "\0"
.var_g_word "\0\0"
.var_g_signed_byte "\0"
.var_g_signed_word "\0\0"
.var_g_byte_array "\0\0\0\0\0"
.var_g_word_array "\0\0\0\0\0\0"
.var_g_point "\0\0"
.var_total_tests "\0\0"
.var_failed_tests "\0\0"
