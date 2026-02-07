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

:test_gt_lt                      # void test_gt_lt()
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
LDI_BL 18                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  signed char i8ten
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char i8ten
INCR_D                           # Load base address of i8negten at offset 2 into B
INCR_D                           # Load base address of i8negten at offset 2 into B
MOV_DH_BH                        # Load base address of i8negten at offset 2 into B
MOV_DL_BL                        # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -10                       # Load constant value, inverted 10
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char i8negten
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
MOV_DH_BH                        # Load base address of i8one at offset 3 into B
MOV_DL_BL                        # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  signed char i8one
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char i8one
INCR4_D                          # Load base address of i8negone at offset 4 into B
MOV_DH_BH                        # Load base address of i8negone at offset 4 into B
MOV_DL_BL                        # Load base address of i8negone at offset 4 into B
DECR4_D                          # Load base address of i8negone at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL -1                        # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  signed char i8negone
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char u8ten
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char u8ten
INCR4_D                          # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
MOV_DH_BH                        # Load base address of u8one at offset 6 into B
MOV_DL_BL                        # Load base address of u8one at offset 6 into B
DECR4_D                          # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char u8one
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char u8one
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 10                         # Constant assignment 10 for  signed short i16ten
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short i16ten
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short i16ten
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short i16ten
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short i16ten
INCR8_D                          # Load base address of i16negten at offset 9 into B
INCR_D                           # Load base address of i16negten at offset 9 into B
MOV_DH_BH                        # Load base address of i16negten at offset 9 into B
MOV_DL_BL                        # Load base address of i16negten at offset 9 into B
DECR8_D                          # Load base address of i16negten at offset 9 into B
DECR_D                           # Load base address of i16negten at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -10                        # Load constant value, inverted 10
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short i16negten
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short i16negten
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short i16negten
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short i16negten
ALUOP_PUSH %A%+%AL%              # Load base address of i16one at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16one at offset 11 into B
MOV_DH_BH                        # Load base address of i16one at offset 11 into B
MOV_DL_BL                        # Load base address of i16one at offset 11 into B
LDI_A 11                         # Load base address of i16one at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16one at offset 11 into B
POP_AH                           # Load base address of i16one at offset 11 into B
POP_AL                           # Load base address of i16one at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 for  signed short i16one
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short i16one
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short i16one
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short i16one
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short i16one
ALUOP_PUSH %A%+%AL%              # Load base address of i16negone at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16negone at offset 13 into B
MOV_DH_BH                        # Load base address of i16negone at offset 13 into B
MOV_DL_BL                        # Load base address of i16negone at offset 13 into B
LDI_A 13                         # Load base address of i16negone at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16negone at offset 13 into B
POP_AH                           # Load base address of i16negone at offset 13 into B
POP_AL                           # Load base address of i16negone at offset 13 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A -1                         # Load constant value, inverted 1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  signed short i16negone
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  signed short i16negone
ALUOP_ADDR_B %A%+%AL%            # Store to  signed short i16negone
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  signed short i16negone
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 10                         # Constant assignment 10 for  unsigned short u16ten
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short u16ten
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short u16ten
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short u16ten
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short u16ten
ALUOP_PUSH %A%+%AL%              # Load base address of u16one at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16one at offset 17 into B
MOV_DH_BH                        # Load base address of u16one at offset 17 into B
MOV_DL_BL                        # Load base address of u16one at offset 17 into B
LDI_A 17                         # Load base address of u16one at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16one at offset 17 into B
POP_AH                           # Load base address of u16one at offset 17 into B
POP_AL                           # Load base address of u16one at offset 17 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # Constant assignment 1 for  unsigned short u16one
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short u16one
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short u16one
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short u16one
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short u16one
LDI_A .data_string_6             # "1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
MOV_DH_BH                        # Load base address of u8one at offset 6 into B
MOV_DL_BL                        # Load base address of u8one at offset 6 into B
DECR4_D                          # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_24           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_25            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_25
.binaryop_equal_24
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_25
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_7             # "10 < 1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8one at offset 6 into A
INCR_D                           # Load base address of u8one at offset 6 into A
INCR_D                           # Load base address of u8one at offset 6 into A
MOV_DH_AH                        # Load base address of u8one at offset 6 into A
MOV_DL_AL                        # Load base address of u8one at offset 6 into A
DECR4_D                          # Load base address of u8one at offset 6 into A
DECR_D                           # Load base address of u8one at offset 6 into A
DECR_D                           # Load base address of u8one at offset 6 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_28           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_29            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_29
.binaryop_equal_28
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_29
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_8             # "1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
INCR_D                           # Load base address of u8one at offset 6 into B
MOV_DH_BH                        # Load base address of u8one at offset 6 into B
MOV_DL_BL                        # Load base address of u8one at offset 6 into B
DECR4_D                          # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
DECR_D                           # Load base address of u8one at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_32           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_33            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_33
.binaryop_equal_32
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_33
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_9             # "10 > 1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8one at offset 6 into A
INCR_D                           # Load base address of u8one at offset 6 into A
INCR_D                           # Load base address of u8one at offset 6 into A
MOV_DH_AH                        # Load base address of u8one at offset 6 into A
MOV_DL_AL                        # Load base address of u8one at offset 6 into A
DECR4_D                          # Load base address of u8one at offset 6 into A
DECR_D                           # Load base address of u8one at offset 6 into A
DECR_D                           # Load base address of u8one at offset 6 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_36           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_37            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_37
.binaryop_equal_36
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_37
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_10            # "10 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >: Subtract to check E and O flags
JEQ .binaryop_equal_40           # BinaryOp >: check if equal
LDI_AL 0                         # BinaryOp >: assume true
JNO .binaryop_done_41            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >: overflow, so true
JMP .binaryop_done_41
.binaryop_equal_40
LDI_AL 0                         # BinaryOp >: operands equal: false
.binaryop_done_41
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_11            # "10 >= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >=: Subtract to check E and O flags
JEQ .binaryop_equal_44           # BinaryOp >=: check if equal
LDI_AL 0                         # BinaryOp >=: assume true
JNO .binaryop_done_45            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >=: overflow, so true
JMP .binaryop_done_45
.binaryop_equal_44
LDI_AL 1                         # BinaryOp >=: operands equal: true
.binaryop_done_45
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_12            # "10 < 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_48           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_49            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_49
.binaryop_equal_48
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_49
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_13            # "10 <= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into A
INCR_D                           # Load base address of u8ten at offset 5 into A
MOV_DH_AH                        # Load base address of u8ten at offset 5 into A
MOV_DL_AL                        # Load base address of u8ten at offset 5 into A
DECR4_D                          # Load base address of u8ten at offset 5 into A
DECR_D                           # Load base address of u8ten at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of u8ten at offset 5 into B
INCR_D                           # Load base address of u8ten at offset 5 into B
MOV_DH_BH                        # Load base address of u8ten at offset 5 into B
MOV_DL_BL                        # Load base address of u8ten at offset 5 into B
DECR4_D                          # Load base address of u8ten at offset 5 into B
DECR_D                           # Load base address of u8ten at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <=: Subtract to check E and O flags
JEQ .binaryop_equal_52           # BinaryOp <=: check if equal
LDI_AL 1                         # BinaryOp <=: assume true
JNO .binaryop_done_53            # BinaryOp <= unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <=: overflow, so false
JMP .binaryop_done_53
.binaryop_equal_52
LDI_AL 1                         # BinaryOp <=: operands equal: true
.binaryop_done_53
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_14            # "signed 1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
MOV_DH_BH                        # Load base address of i8one at offset 3 into B
MOV_DL_BL                        # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_58       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_59         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_56           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_57             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_57            # Signed BinaryOp <: Signs were different
.binaryop_equal_56
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_57
.binaryop_overflow_59
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_57
.binaryop_diffsigns_58
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_57            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_57
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_15            # "signed 10 < 1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8one at offset 3 into A
INCR_D                           # Load base address of i8one at offset 3 into A
INCR_D                           # Load base address of i8one at offset 3 into A
MOV_DH_AH                        # Load base address of i8one at offset 3 into A
MOV_DL_AL                        # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_62       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_63         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_60           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_61             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_61            # Signed BinaryOp <: Signs were different
.binaryop_equal_60
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_61
.binaryop_overflow_63
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_61
.binaryop_diffsigns_62
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_61            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_61
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_16            # "signed 1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
INCR_D                           # Load base address of i8one at offset 3 into B
MOV_DH_BH                        # Load base address of i8one at offset 3 into B
MOV_DL_BL                        # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
DECR_D                           # Load base address of i8one at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_66       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_67         # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_64           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_65             # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_65            # Signed BinaryOp >: Signs were different
.binaryop_equal_64
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_65
.binaryop_overflow_67
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_65
.binaryop_diffsigns_66
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_65            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_65
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_17            # "signed 10 > 1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8one at offset 3 into A
INCR_D                           # Load base address of i8one at offset 3 into A
INCR_D                           # Load base address of i8one at offset 3 into A
MOV_DH_AH                        # Load base address of i8one at offset 3 into A
MOV_DL_AL                        # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
DECR_D                           # Load base address of i8one at offset 3 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_70       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_71         # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_68           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_69             # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_69            # Signed BinaryOp >: Signs were different
.binaryop_equal_68
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_69
.binaryop_overflow_71
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_69
.binaryop_diffsigns_70
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_69            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_69
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_18            # "signed 10 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_74       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_75         # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_72           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_73             # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_73            # Signed BinaryOp >: Signs were different
.binaryop_equal_72
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_73
.binaryop_overflow_75
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_73
.binaryop_diffsigns_74
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_73            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_73
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_19            # "signed 10 >= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_78       # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >=: Subtract to check E and O flags
JO .binaryop_overflow_79         # Signed BinaryOp >=: If overflow, result will be true
JEQ .binaryop_equal_76           # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Compare signs
LDI_AL 0                         # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_77             # Signed BinaryOp >=: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_77            # Signed BinaryOp >=: Signs were different
.binaryop_equal_76
LDI_AL 1                         # Signed BinaryOp >=: true because equal
JMP .binaryop_done_77
.binaryop_overflow_79
LDI_AL 1                         # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_77
.binaryop_diffsigns_78
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >=: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >=: assume false
JNZ .binaryop_done_77            # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >=: flip to true
.binaryop_done_77
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_20            # "signed 10 < 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_82       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_83         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_80           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_81             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_81            # Signed BinaryOp <: Signs were different
.binaryop_equal_80
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_81
.binaryop_overflow_83
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_81
.binaryop_diffsigns_82
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_81            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_81
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_21            # "signed 10 <= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <=: Check if signs differ
JNZ .binaryop_diffsigns_86       # Signed BinaryOp <=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <=: Subtract to check E and O flags
JO .binaryop_overflow_87         # Signed BinaryOp <=: If overflow, result will be false
JEQ .binaryop_equal_84           # Signed BinaryOp <=: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <=: Compare signs
LDI_AL 1                         # Signed BinaryOp <=: Assume no sign change -> true
JZ .binaryop_done_85             # Signed BinaryOp <=: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <=: Signs were different -> false
JMP .binaryop_done_85            # Signed BinaryOp <=: Signs were different
.binaryop_equal_84
LDI_AL 1                         # Signed BinaryOp <=: true because equal
JMP .binaryop_done_85
.binaryop_overflow_87
LDI_AL 0                         # Signed BinaryOp <=: false because signed overflow
JMP .binaryop_done_85
.binaryop_diffsigns_86
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <=: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <=: assume true
JNZ .binaryop_done_85            # Signed BinaryOpn <=: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <=: flip to false
.binaryop_done_85
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_22            # "signed -1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i8negone at offset 4 into B
MOV_DH_BH                        # Load base address of i8negone at offset 4 into B
MOV_DL_BL                        # Load base address of i8negone at offset 4 into B
DECR4_D                          # Load base address of i8negone at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_90       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_91         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_88           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_89             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_89            # Signed BinaryOp <: Signs were different
.binaryop_equal_88
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_89
.binaryop_overflow_91
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_89
.binaryop_diffsigns_90
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_89            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_89
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_23            # "signed 10 < -1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i8negone at offset 4 into A
MOV_DH_AH                        # Load base address of i8negone at offset 4 into A
MOV_DL_AL                        # Load base address of i8negone at offset 4 into A
DECR4_D                          # Load base address of i8negone at offset 4 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_94       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_95         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_92           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_93             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_93            # Signed BinaryOp <: Signs were different
.binaryop_equal_92
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_93
.binaryop_overflow_95
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_93
.binaryop_diffsigns_94
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_93            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_93
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_24            # "signed -1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8ten at offset 1 into A
MOV_DH_AH                        # Load base address of i8ten at offset 1 into A
MOV_DL_AL                        # Load base address of i8ten at offset 1 into A
DECR_D                           # Load base address of i8ten at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i8negone at offset 4 into B
MOV_DH_BH                        # Load base address of i8negone at offset 4 into B
MOV_DL_BL                        # Load base address of i8negone at offset 4 into B
DECR4_D                          # Load base address of i8negone at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_98       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_99         # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_96           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_97             # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_97            # Signed BinaryOp >: Signs were different
.binaryop_equal_96
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_97
.binaryop_overflow_99
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_97
.binaryop_diffsigns_98
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_97            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_97
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_25            # "signed 10 > -1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i8negone at offset 4 into A
MOV_DH_AH                        # Load base address of i8negone at offset 4 into A
MOV_DL_AL                        # Load base address of i8negone at offset 4 into A
DECR4_D                          # Load base address of i8negone at offset 4 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8ten at offset 1 into B
MOV_DH_BH                        # Load base address of i8ten at offset 1 into B
MOV_DL_BL                        # Load base address of i8ten at offset 1 into B
DECR_D                           # Load base address of i8ten at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_102      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_103        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_100          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_101            # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_101           # Signed BinaryOp >: Signs were different
.binaryop_equal_100
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_101
.binaryop_overflow_103
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_101
.binaryop_diffsigns_102
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_101           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_101
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_26            # "signed -10 > -10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8negten at offset 2 into A
INCR_D                           # Load base address of i8negten at offset 2 into A
MOV_DH_AH                        # Load base address of i8negten at offset 2 into A
MOV_DL_AL                        # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8negten at offset 2 into B
INCR_D                           # Load base address of i8negten at offset 2 into B
MOV_DH_BH                        # Load base address of i8negten at offset 2 into B
MOV_DL_BL                        # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_106      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >: Subtract to check E and O flags
JO .binaryop_overflow_107        # Signed BinaryOp >: If overflow, result will be true
JEQ .binaryop_equal_104          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >: Compare signs
LDI_AL 0                         # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_105            # Signed BinaryOp >: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_105           # Signed BinaryOp >: Signs were different
.binaryop_equal_104
LDI_AL 0                         # Signed BinaryOp >: false because equal
JMP .binaryop_done_105
.binaryop_overflow_107
LDI_AL 1                         # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_105
.binaryop_diffsigns_106
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >: assume false
JNZ .binaryop_done_105           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >: flip to true
.binaryop_done_105
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_27            # "signed -10 >= -10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8negten at offset 2 into A
INCR_D                           # Load base address of i8negten at offset 2 into A
MOV_DH_AH                        # Load base address of i8negten at offset 2 into A
MOV_DL_AL                        # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8negten at offset 2 into B
INCR_D                           # Load base address of i8negten at offset 2 into B
MOV_DH_BH                        # Load base address of i8negten at offset 2 into B
MOV_DL_BL                        # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_110      # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >=: Subtract to check E and O flags
JO .binaryop_overflow_111        # Signed BinaryOp >=: If overflow, result will be true
JEQ .binaryop_equal_108          # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Compare signs
LDI_AL 0                         # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_109            # Signed BinaryOp >=: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_109           # Signed BinaryOp >=: Signs were different
.binaryop_equal_108
LDI_AL 1                         # Signed BinaryOp >=: true because equal
JMP .binaryop_done_109
.binaryop_overflow_111
LDI_AL 1                         # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_109
.binaryop_diffsigns_110
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >=: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >=: assume false
JNZ .binaryop_done_109           # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >=: flip to true
.binaryop_done_109
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_28            # "signed -10 < -10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8negten at offset 2 into A
INCR_D                           # Load base address of i8negten at offset 2 into A
MOV_DH_AH                        # Load base address of i8negten at offset 2 into A
MOV_DL_AL                        # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8negten at offset 2 into B
INCR_D                           # Load base address of i8negten at offset 2 into B
MOV_DH_BH                        # Load base address of i8negten at offset 2 into B
MOV_DL_BL                        # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_114      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_115        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_112          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_113            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_113           # Signed BinaryOp <: Signs were different
.binaryop_equal_112
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_113
.binaryop_overflow_115
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_113
.binaryop_diffsigns_114
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_113           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_113
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_29            # "signed -10 <= -10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  signed char expected
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i8negten at offset 2 into A
INCR_D                           # Load base address of i8negten at offset 2 into A
MOV_DH_AH                        # Load base address of i8negten at offset 2 into A
MOV_DL_AL                        # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
DECR_D                           # Load base address of i8negten at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i8negten at offset 2 into B
INCR_D                           # Load base address of i8negten at offset 2 into B
MOV_DH_BH                        # Load base address of i8negten at offset 2 into B
MOV_DL_BL                        # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
DECR_D                           # Load base address of i8negten at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <=: Check if signs differ
JNZ .binaryop_diffsigns_118      # Signed BinaryOp <=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <=: Subtract to check E and O flags
JO .binaryop_overflow_119        # Signed BinaryOp <=: If overflow, result will be false
JEQ .binaryop_equal_116          # Signed BinaryOp <=: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <=: Compare signs
LDI_AL 1                         # Signed BinaryOp <=: Assume no sign change -> true
JZ .binaryop_done_117            # Signed BinaryOp <=: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <=: Signs were different -> false
JMP .binaryop_done_117           # Signed BinaryOp <=: Signs were different
.binaryop_equal_116
LDI_AL 1                         # Signed BinaryOp <=: true because equal
JMP .binaryop_done_117
.binaryop_overflow_119
LDI_AL 0                         # Signed BinaryOp <=: false because signed overflow
JMP .binaryop_done_117
.binaryop_diffsigns_118
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <=: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <=: assume true
JNZ .binaryop_done_117           # Signed BinaryOpn <=: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <=: flip to false
.binaryop_done_117
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_30            # "16b 1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16one at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16one at offset 17 into B
MOV_DH_BH                        # Load base address of u16one at offset 17 into B
MOV_DL_BL                        # Load base address of u16one at offset 17 into B
LDI_A 17                         # Load base address of u16one at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16one at offset 17 into B
POP_AH                           # Load base address of u16one at offset 17 into B
POP_AL                           # Load base address of u16one at offset 17 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_120          # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_121           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_121
.binaryop_equal_120
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_121
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_31            # "16b 10 < 1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16one at offset 17 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16one at offset 17 into A
MOV_DH_AH                        # Load base address of u16one at offset 17 into A
MOV_DL_AL                        # Load base address of u16one at offset 17 into A
LDI_B 17                         # Load base address of u16one at offset 17 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16one at offset 17 into A
POP_BH                           # Load base address of u16one at offset 17 into A
POP_BL                           # Load base address of u16one at offset 17 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_124          # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_125           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_125
.binaryop_equal_124
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_125
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_32            # "16b 1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16one at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16one at offset 17 into B
MOV_DH_BH                        # Load base address of u16one at offset 17 into B
MOV_DL_BL                        # Load base address of u16one at offset 17 into B
LDI_A 17                         # Load base address of u16one at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16one at offset 17 into B
POP_AH                           # Load base address of u16one at offset 17 into B
POP_AL                           # Load base address of u16one at offset 17 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_128          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_129           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_129
.binaryop_equal_128
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_129
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_33            # "16b 10 > 1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16one at offset 17 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16one at offset 17 into A
MOV_DH_AH                        # Load base address of u16one at offset 17 into A
MOV_DL_AL                        # Load base address of u16one at offset 17 into A
LDI_B 17                         # Load base address of u16one at offset 17 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16one at offset 17 into A
POP_BH                           # Load base address of u16one at offset 17 into A
POP_BL                           # Load base address of u16one at offset 17 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_132          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_133           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_133
.binaryop_equal_132
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_133
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_34            # "16b 10 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_136          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_137           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_137
.binaryop_equal_136
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_137
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_35            # "16b 10 >= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >=: Check for equality
JEQ .binaryop_equal_140          # BinaryOp >=: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >=: Subtract to check O flag
LDI_A 0                          # BinaryOp >=: assume true
JNO .binaryop_done_141           # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >=: overflow, so true
JMP .binaryop_done_141
.binaryop_equal_140
LDI_A 1                          # BinaryOp >=: operands equal: true
.binaryop_done_141
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_36            # "16b 10 < 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_144          # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_145           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_145
.binaryop_equal_144
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_145
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_37            # "16b 10 <= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of u16ten at offset 15 into A
ALUOP_PUSH %B%+%BH%              # Load base address of u16ten at offset 15 into A
MOV_DH_AH                        # Load base address of u16ten at offset 15 into A
MOV_DL_AL                        # Load base address of u16ten at offset 15 into A
LDI_B 15                         # Load base address of u16ten at offset 15 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into A
POP_BH                           # Load base address of u16ten at offset 15 into A
POP_BL                           # Load base address of u16ten at offset 15 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of u16ten at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of u16ten at offset 15 into B
MOV_DH_BH                        # Load base address of u16ten at offset 15 into B
MOV_DL_BL                        # Load base address of u16ten at offset 15 into B
LDI_A 15                         # Load base address of u16ten at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of u16ten at offset 15 into B
POP_AH                           # Load base address of u16ten at offset 15 into B
POP_AL                           # Load base address of u16ten at offset 15 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <=: Check for equality
JEQ .binaryop_equal_148          # BinaryOp <=: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <=: Subtract to check O flag
LDI_A 1                          # BinaryOp <=: assume true
JNO .binaryop_done_149           # BinaryOp <= unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <=: overflow, so false
JMP .binaryop_done_149
.binaryop_equal_148
LDI_A 1                          # BinaryOp <=: operands equal: true
.binaryop_done_149
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_38            # "16b signed 1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of i16one at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16one at offset 11 into B
MOV_DH_BH                        # Load base address of i16one at offset 11 into B
MOV_DL_BL                        # Load base address of i16one at offset 11 into B
LDI_A 11                         # Load base address of i16one at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16one at offset 11 into B
POP_AH                           # Load base address of i16one at offset 11 into B
POP_AL                           # Load base address of i16one at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_154      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_155        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_152          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_153            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_153           # Signed BinaryOp <: Signs were different
.binaryop_equal_152
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_153
.binaryop_overflow_155
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_153
.binaryop_diffsigns_154
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_153           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_153
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_39            # "16b signed 10 < 1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of i16one at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of i16one at offset 11 into A
MOV_DH_AH                        # Load base address of i16one at offset 11 into A
MOV_DL_AL                        # Load base address of i16one at offset 11 into A
LDI_B 11                         # Load base address of i16one at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16one at offset 11 into A
POP_BH                           # Load base address of i16one at offset 11 into A
POP_BL                           # Load base address of i16one at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_158      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_159        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_156          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_157            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_157           # Signed BinaryOp <: Signs were different
.binaryop_equal_156
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_157
.binaryop_overflow_159
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_157
.binaryop_diffsigns_158
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_157           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_157
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_40            # "16b signed 1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of i16one at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16one at offset 11 into B
MOV_DH_BH                        # Load base address of i16one at offset 11 into B
MOV_DL_BL                        # Load base address of i16one at offset 11 into B
LDI_A 11                         # Load base address of i16one at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16one at offset 11 into B
POP_AH                           # Load base address of i16one at offset 11 into B
POP_AL                           # Load base address of i16one at offset 11 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_162      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_163        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_160          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_161            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_161           # Signed BinaryOp >: Signs were different
.binaryop_equal_160
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_161
.binaryop_overflow_163
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_161
.binaryop_diffsigns_162
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_161           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_161
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_41            # "16b signed 10 > 1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of i16one at offset 11 into A
ALUOP_PUSH %B%+%BH%              # Load base address of i16one at offset 11 into A
MOV_DH_AH                        # Load base address of i16one at offset 11 into A
MOV_DL_AL                        # Load base address of i16one at offset 11 into A
LDI_B 11                         # Load base address of i16one at offset 11 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16one at offset 11 into A
POP_BH                           # Load base address of i16one at offset 11 into A
POP_BL                           # Load base address of i16one at offset 11 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_166      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_167        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_164          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_165            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_165           # Signed BinaryOp >: Signs were different
.binaryop_equal_164
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_165
.binaryop_overflow_167
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_165
.binaryop_diffsigns_166
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_165           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_165
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_42            # "16b signed 10 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_170      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_171        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_168          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_169            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_169           # Signed BinaryOp >: Signs were different
.binaryop_equal_168
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_169
.binaryop_overflow_171
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_169
.binaryop_diffsigns_170
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_169           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_169
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_43            # "16b signed 10 >= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_174      # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_175        # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_172          # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_A 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_173            # Signed BinaryOp >=: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_173           # Signed BinaryOp >=: Signs were different
.binaryop_equal_172
LDI_A 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_173
.binaryop_overflow_175
LDI_A 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_173
.binaryop_diffsigns_174
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >=: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_173           # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_173
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_44            # "16b signed 10 < 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_178      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_179        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_176          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_177            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_177           # Signed BinaryOp <: Signs were different
.binaryop_equal_176
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_177
.binaryop_overflow_179
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_177
.binaryop_diffsigns_178
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_177           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_177
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_45            # "16b signed 10 <= 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <=: Check if signs differ
JNZ .binaryop_diffsigns_182      # Signed BinaryOp <=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <=: Subtract to check O flag
JO .binaryop_overflow_183        # Signed BinaryOp <=: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <=: check 16-bit equality
JEQ .binaryop_equal_180          # Signed BinaryOp <=: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <=: Compare signs
LDI_A 1                          # Signed BinaryOp <=: Assume no sign change -> true
JZ .binaryop_done_181            # Signed BinaryOp <=: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <=: Signs were different -> false
JMP .binaryop_done_181           # Signed BinaryOp <=: Signs were different
.binaryop_equal_180
LDI_A 1                          # Signed BinaryOp <=: true because equal
JMP .binaryop_done_181
.binaryop_overflow_183
LDI_A 0                          # Signed BinaryOp <=: false because signed overflow
JMP .binaryop_done_181
.binaryop_diffsigns_182
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <=: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <=: assume true
JNZ .binaryop_done_181           # Signed BinaryOpn <=: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <=: flip to false
.binaryop_done_181
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_46            # "16b signed -1 < 10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of i16negone at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16negone at offset 13 into B
MOV_DH_BH                        # Load base address of i16negone at offset 13 into B
MOV_DL_BL                        # Load base address of i16negone at offset 13 into B
LDI_A 13                         # Load base address of i16negone at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16negone at offset 13 into B
POP_AH                           # Load base address of i16negone at offset 13 into B
POP_AL                           # Load base address of i16negone at offset 13 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_186      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_187        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_184          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_185            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_185           # Signed BinaryOp <: Signs were different
.binaryop_equal_184
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_185
.binaryop_overflow_187
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_185
.binaryop_diffsigns_186
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_185           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_185
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_47            # "16b signed 10 < -1 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of i16negone at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of i16negone at offset 13 into A
MOV_DH_AH                        # Load base address of i16negone at offset 13 into A
MOV_DL_AL                        # Load base address of i16negone at offset 13 into A
LDI_B 13                         # Load base address of i16negone at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16negone at offset 13 into A
POP_BH                           # Load base address of i16negone at offset 13 into A
POP_BL                           # Load base address of i16negone at offset 13 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_190      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_191        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_188          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_189            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_189           # Signed BinaryOp <: Signs were different
.binaryop_equal_188
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_189
.binaryop_overflow_191
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_189
.binaryop_diffsigns_190
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_189           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_189
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_48            # "16b signed -1 > 10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
INCR_D                           # Load base address of i16ten at offset 7 into A
MOV_DH_AH                        # Load base address of i16ten at offset 7 into A
MOV_DL_AL                        # Load base address of i16ten at offset 7 into A
DECR4_D                          # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
DECR_D                           # Load base address of i16ten at offset 7 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of i16negone at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of i16negone at offset 13 into B
MOV_DH_BH                        # Load base address of i16negone at offset 13 into B
MOV_DL_BL                        # Load base address of i16negone at offset 13 into B
LDI_A 13                         # Load base address of i16negone at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16negone at offset 13 into B
POP_AH                           # Load base address of i16negone at offset 13 into B
POP_AL                           # Load base address of i16negone at offset 13 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_194      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_195        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_192          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_193            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_193           # Signed BinaryOp >: Signs were different
.binaryop_equal_192
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_193
.binaryop_overflow_195
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_193
.binaryop_diffsigns_194
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_193           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_193
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_49            # "16b signed 10 > -1 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
ALUOP_PUSH %B%+%BL%              # Load base address of i16negone at offset 13 into A
ALUOP_PUSH %B%+%BH%              # Load base address of i16negone at offset 13 into A
MOV_DH_AH                        # Load base address of i16negone at offset 13 into A
MOV_DL_AL                        # Load base address of i16negone at offset 13 into A
LDI_B 13                         # Load base address of i16negone at offset 13 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of i16negone at offset 13 into A
POP_BH                           # Load base address of i16negone at offset 13 into A
POP_BL                           # Load base address of i16negone at offset 13 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
INCR_D                           # Load base address of i16ten at offset 7 into B
MOV_DH_BH                        # Load base address of i16ten at offset 7 into B
MOV_DL_BL                        # Load base address of i16ten at offset 7 into B
DECR4_D                          # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
DECR_D                           # Load base address of i16ten at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_198      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_199        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_196          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_197            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_197           # Signed BinaryOp >: Signs were different
.binaryop_equal_196
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_197
.binaryop_overflow_199
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_197
.binaryop_diffsigns_198
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_197           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_197
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_50            # "16b signed -10 > -10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into A
INCR_D                           # Load base address of i16negten at offset 9 into A
MOV_DH_AH                        # Load base address of i16negten at offset 9 into A
MOV_DL_AL                        # Load base address of i16negten at offset 9 into A
DECR8_D                          # Load base address of i16negten at offset 9 into A
DECR_D                           # Load base address of i16negten at offset 9 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into B
INCR_D                           # Load base address of i16negten at offset 9 into B
MOV_DH_BH                        # Load base address of i16negten at offset 9 into B
MOV_DL_BL                        # Load base address of i16negten at offset 9 into B
DECR8_D                          # Load base address of i16negten at offset 9 into B
DECR_D                           # Load base address of i16negten at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_202      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_203        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_200          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_201            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_201           # Signed BinaryOp >: Signs were different
.binaryop_equal_200
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_201
.binaryop_overflow_203
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_201
.binaryop_diffsigns_202
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_201           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_201
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_51            # "16b signed -10 >= -10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into A
INCR_D                           # Load base address of i16negten at offset 9 into A
MOV_DH_AH                        # Load base address of i16negten at offset 9 into A
MOV_DL_AL                        # Load base address of i16negten at offset 9 into A
DECR8_D                          # Load base address of i16negten at offset 9 into A
DECR_D                           # Load base address of i16negten at offset 9 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into B
INCR_D                           # Load base address of i16negten at offset 9 into B
MOV_DH_BH                        # Load base address of i16negten at offset 9 into B
MOV_DL_BL                        # Load base address of i16negten at offset 9 into B
DECR8_D                          # Load base address of i16negten at offset 9 into B
DECR_D                           # Load base address of i16negten at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_206      # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_207        # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_204          # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_A 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_205            # Signed BinaryOp >=: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_205           # Signed BinaryOp >=: Signs were different
.binaryop_equal_204
LDI_A 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_205
.binaryop_overflow_207
LDI_A 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_205
.binaryop_diffsigns_206
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >=: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_205           # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_205
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_52            # "16b signed -10 < -10 (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 0                          # Constant assignment 0 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into A
INCR_D                           # Load base address of i16negten at offset 9 into A
MOV_DH_AH                        # Load base address of i16negten at offset 9 into A
MOV_DL_AL                        # Load base address of i16negten at offset 9 into A
DECR8_D                          # Load base address of i16negten at offset 9 into A
DECR_D                           # Load base address of i16negten at offset 9 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into B
INCR_D                           # Load base address of i16negten at offset 9 into B
MOV_DH_BH                        # Load base address of i16negten at offset 9 into B
MOV_DL_BL                        # Load base address of i16negten at offset 9 into B
DECR8_D                          # Load base address of i16negten at offset 9 into B
DECR_D                           # Load base address of i16negten at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_210      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_211        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_208          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_209            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_209           # Signed BinaryOp <: Signs were different
.binaryop_equal_208
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_209
.binaryop_overflow_211
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_209
.binaryop_diffsigns_210
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_209           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_209
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_A .data_string_53            # "16b signed -10 <= -10 (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1                          # Constant assignment 1 for  signed short expected
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BH%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into A
INCR_D                           # Load base address of i16negten at offset 9 into A
MOV_DH_AH                        # Load base address of i16negten at offset 9 into A
MOV_DL_AL                        # Load base address of i16negten at offset 9 into A
DECR8_D                          # Load base address of i16negten at offset 9 into A
DECR_D                           # Load base address of i16negten at offset 9 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of i16negten at offset 9 into B
INCR_D                           # Load base address of i16negten at offset 9 into B
MOV_DH_BH                        # Load base address of i16negten at offset 9 into B
MOV_DL_BL                        # Load base address of i16negten at offset 9 into B
DECR8_D                          # Load base address of i16negten at offset 9 into B
DECR_D                           # Load base address of i16negten at offset 9 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <=: Check if signs differ
JNZ .binaryop_diffsigns_214      # Signed BinaryOp <=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <=: Subtract to check O flag
JO .binaryop_overflow_215        # Signed BinaryOp <=: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <=: check 16-bit equality
JEQ .binaryop_equal_212          # Signed BinaryOp <=: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <=: Compare signs
LDI_A 1                          # Signed BinaryOp <=: Assume no sign change -> true
JZ .binaryop_done_213            # Signed BinaryOp <=: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <=: Signs were different -> false
JMP .binaryop_done_213           # Signed BinaryOp <=: Signs were different
.binaryop_equal_212
LDI_A 1                          # Signed BinaryOp <=: true because equal
JMP .binaryop_done_213
.binaryop_overflow_215
LDI_A 0                          # Signed BinaryOp <=: false because signed overflow
JMP .binaryop_done_213
.binaryop_diffsigns_214
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <=: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <=: assume true
JNZ .binaryop_done_213           # Signed BinaryOpn <=: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <=: flip to false
.binaryop_done_213
POP_BL                           # BinaryOp <=: Restore B after use for rhs
POP_BH                           # BinaryOp <=: Restore B after use for rhs
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
.test_gt_lt_return_23
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

:test_if_else                    # void test_if_else()
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
INCR_D                           # Load base address of if_result1 at offset 1 into B
MOV_DH_BH                        # Load base address of if_result1 at offset 1 into B
MOV_DL_BL                        # Load base address of if_result1 at offset 1 into B
DECR_D                           # Load base address of if_result1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char if_result1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if_result1
LDI_A 1                          # Constant assignment 1 as int
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_217          # Condition was true
JMP .end_if_218                  # Done with false condition
.condition_true_217              # Condition was true
INCR_D                           # Load base address of if_result1 at offset 1 into B
MOV_DH_BH                        # Load base address of if_result1 at offset 1 into B
MOV_DL_BL                        # Load base address of if_result1 at offset 1 into B
DECR_D                           # Load base address of if_result1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char if_result1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if_result1
.end_if_218                      # End If
LDI_A .data_string_54            # "If statement (true)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of if_result1 at offset 1 into B
MOV_DH_BH                        # Load base address of if_result1 at offset 1 into B
MOV_DL_BL                        # Load base address of if_result1 at offset 1 into B
DECR_D                           # Load base address of if_result1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of if_result2 at offset 2 into B
INCR_D                           # Load base address of if_result2 at offset 2 into B
MOV_DH_BH                        # Load base address of if_result2 at offset 2 into B
MOV_DL_BL                        # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char if_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if_result2
LDI_A 0                          # Constant assignment 0 as int
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_219          # Condition was true
JMP .end_if_220                  # Done with false condition
.condition_true_219              # Condition was true
INCR_D                           # Load base address of if_result2 at offset 2 into B
INCR_D                           # Load base address of if_result2 at offset 2 into B
MOV_DH_BH                        # Load base address of if_result2 at offset 2 into B
MOV_DL_BL                        # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char if_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if_result2
.end_if_220                      # End If
LDI_A .data_string_55            # "If statement (false)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of if_result2 at offset 2 into B
INCR_D                           # Load base address of if_result2 at offset 2 into B
MOV_DH_BH                        # Load base address of if_result2 at offset 2 into B
MOV_DL_BL                        # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
DECR_D                           # Load base address of if_result2 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
MOV_DH_BH                        # Load base address of ifelse_result1 at offset 3 into B
MOV_DL_BL                        # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char ifelse_result1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result1
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
LDI_A 5                          # Constant assignment 5 as int
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_225      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_226        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_223          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_224            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_224           # Signed BinaryOp >: Signs were different
.binaryop_equal_223
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_224
.binaryop_overflow_226
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_224
.binaryop_diffsigns_225
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_224           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_224
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_221          # Condition was true
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
MOV_DH_BH                        # Load base address of ifelse_result1 at offset 3 into B
MOV_DL_BL                        # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char ifelse_result1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result1
JMP .end_if_222                  # Done with false condition
.condition_true_221              # Condition was true
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
MOV_DH_BH                        # Load base address of ifelse_result1 at offset 3 into B
MOV_DL_BL                        # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char ifelse_result1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result1
.end_if_222                      # End If
LDI_A .data_string_56            # "If-else (true path)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
INCR_D                           # Load base address of ifelse_result1 at offset 3 into B
MOV_DH_BH                        # Load base address of ifelse_result1 at offset 3 into B
MOV_DL_BL                        # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
DECR_D                           # Load base address of ifelse_result1 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of ifelse_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of ifelse_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of ifelse_result2 at offset 4 into B
DECR4_D                          # Load base address of ifelse_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char ifelse_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result2
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
LDI_A 3                          # Constant assignment 3 as int
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_231      # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_232        # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_229          # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_230            # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_230           # Signed BinaryOp >: Signs were different
.binaryop_equal_229
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_230
.binaryop_overflow_232
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_230
.binaryop_diffsigns_231
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_230           # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_230
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_227          # Condition was true
INCR4_D                          # Load base address of ifelse_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of ifelse_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of ifelse_result2 at offset 4 into B
DECR4_D                          # Load base address of ifelse_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char ifelse_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result2
JMP .end_if_228                  # Done with false condition
.condition_true_227              # Condition was true
INCR4_D                          # Load base address of ifelse_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of ifelse_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of ifelse_result2 at offset 4 into B
DECR4_D                          # Load base address of ifelse_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char ifelse_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ifelse_result2
.end_if_228                      # End If
LDI_A .data_string_57            # "If-else (false path)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of ifelse_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of ifelse_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of ifelse_result2 at offset 4 into B
DECR4_D                          # Load base address of ifelse_result2 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of nested_result at offset 5 into B
INCR_D                           # Load base address of nested_result at offset 5 into B
MOV_DH_BH                        # Load base address of nested_result at offset 5 into B
MOV_DL_BL                        # Load base address of nested_result at offset 5 into B
DECR4_D                          # Load base address of nested_result at offset 5 into B
DECR_D                           # Load base address of nested_result at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char nested_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char nested_result
LDI_A 1                          # Constant assignment 1 as int
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_233          # Condition was true
JMP .end_if_234                  # Done with false condition
.condition_true_233              # Condition was true
LDI_A 1                          # Constant assignment 1 as int
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_235          # Condition was true
JMP .end_if_236                  # Done with false condition
.condition_true_235              # Condition was true
INCR4_D                          # Load base address of nested_result at offset 5 into B
INCR_D                           # Load base address of nested_result at offset 5 into B
MOV_DH_BH                        # Load base address of nested_result at offset 5 into B
MOV_DL_BL                        # Load base address of nested_result at offset 5 into B
DECR4_D                          # Load base address of nested_result at offset 5 into B
DECR_D                           # Load base address of nested_result at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 99                        # Constant assignment 99 for  unsigned char nested_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char nested_result
.end_if_236                      # End If
.end_if_234                      # End If
LDI_A .data_string_58            # "Nested if"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 99                        # Constant assignment 99 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of nested_result at offset 5 into B
INCR_D                           # Load base address of nested_result at offset 5 into B
MOV_DH_BH                        # Load base address of nested_result at offset 5 into B
MOV_DL_BL                        # Load base address of nested_result at offset 5 into B
DECR4_D                          # Load base address of nested_result at offset 5 into B
DECR_D                           # Load base address of nested_result at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of big_val at offset 6 into B
INCR_D                           # Load base address of big_val at offset 6 into B
INCR_D                           # Load base address of big_val at offset 6 into B
MOV_DH_BH                        # Load base address of big_val at offset 6 into B
MOV_DL_BL                        # Load base address of big_val at offset 6 into B
DECR4_D                          # Load base address of big_val at offset 6 into B
DECR_D                           # Load base address of big_val at offset 6 into B
DECR_D                           # Load base address of big_val at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 256                        # Constant assignment 0x0100 for  unsigned short big_val
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short big_val
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short big_val
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short big_val
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short big_val
INCR8_D                          # Load base address of if16_result at offset 8 into B
MOV_DH_BH                        # Load base address of if16_result at offset 8 into B
MOV_DL_BL                        # Load base address of if16_result at offset 8 into B
DECR8_D                          # Load base address of if16_result at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char if16_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if16_result
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of big_val at offset 6 into B
INCR_D                           # Load base address of big_val at offset 6 into B
INCR_D                           # Load base address of big_val at offset 6 into B
MOV_DH_BH                        # Load base address of big_val at offset 6 into B
MOV_DL_BL                        # Load base address of big_val at offset 6 into B
DECR4_D                          # Load base address of big_val at offset 6 into B
DECR_D                           # Load base address of big_val at offset 6 into B
DECR_D                           # Load base address of big_val at offset 6 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_237          # Condition was true
JMP .end_if_238                  # Done with false condition
.condition_true_237              # Condition was true
INCR8_D                          # Load base address of if16_result at offset 8 into B
MOV_DH_BH                        # Load base address of if16_result at offset 8 into B
MOV_DL_BL                        # Load base address of if16_result at offset 8 into B
DECR8_D                          # Load base address of if16_result at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char if16_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char if16_result
.end_if_238                      # End If
LDI_A .data_string_59            # "If with 16-bit condition"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of if16_result at offset 8 into B
MOV_DH_BH                        # Load base address of if16_result at offset 8 into B
MOV_DL_BL                        # Load base address of if16_result at offset 8 into B
DECR8_D                          # Load base address of if16_result at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_if_else_return_216
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

:test_while                      # void test_while()
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
LDI_BL 6                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of count1 at offset 1 into B
MOV_DH_BH                        # Load base address of count1 at offset 1 into B
MOV_DL_BL                        # Load base address of count1 at offset 1 into B
DECR_D                           # Load base address of count1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char count1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count1
INCR_D                           # Load base address of sum1 at offset 2 into B
INCR_D                           # Load base address of sum1 at offset 2 into B
MOV_DH_BH                        # Load base address of sum1 at offset 2 into B
MOV_DL_BL                        # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sum1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum1
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_240                   # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of count1 at offset 1 into B
MOV_DH_BH                        # Load base address of count1 at offset 1 into B
MOV_DL_BL                        # Load base address of count1 at offset 1 into B
DECR_D                           # Load base address of count1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_245      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_246        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_243          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_244            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_244           # Signed BinaryOp <: Signs were different
.binaryop_equal_243
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_244
.binaryop_overflow_246
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_244
.binaryop_diffsigns_245
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_244           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_244
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_241              # Condition was true
JMP .while_end_242               # Condition was false, end loop
.while_true_241                  # Begin while loop body
INCR_D                           # Load base address of sum1 at offset 2 into B
INCR_D                           # Load base address of sum1 at offset 2 into B
MOV_DH_BH                        # Load base address of sum1 at offset 2 into B
MOV_DL_BL                        # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of count1 at offset 1 into A
MOV_DH_AH                        # Load base address of count1 at offset 1 into A
MOV_DL_AL                        # Load base address of count1 at offset 1 into A
DECR_D                           # Load base address of count1 at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum1 at offset 2 into B
INCR_D                           # Load base address of sum1 at offset 2 into B
MOV_DH_BH                        # Load base address of sum1 at offset 2 into B
MOV_DL_BL                        # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum1
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of count1 at offset 1 into B
MOV_DH_BH                        # Load base address of count1 at offset 1 into B
MOV_DL_BL                        # Load base address of count1 at offset 1 into B
DECR_D                           # Load base address of count1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of count1 at offset 1 into B
MOV_DH_BH                        # Load base address of count1 at offset 1 into B
MOV_DL_BL                        # Load base address of count1 at offset 1 into B
DECR_D                           # Load base address of count1 at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count1
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .while_top_240               # Next While loop
.while_end_242                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
LDI_A .data_string_60            # "While loop sum"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum1 at offset 2 into B
INCR_D                           # Load base address of sum1 at offset 2 into B
MOV_DH_BH                        # Load base address of sum1 at offset 2 into B
MOV_DL_BL                        # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
DECR_D                           # Load base address of sum1 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_61            # "While loop counter"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 5                         # Constant assignment 5 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of count1 at offset 1 into B
MOV_DH_BH                        # Load base address of count1 at offset 1 into B
MOV_DL_BL                        # Load base address of count1 at offset 1 into B
DECR_D                           # Load base address of count1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
MOV_DH_BH                        # Load base address of never_exec at offset 3 into B
MOV_DL_BL                        # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char never_exec
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char never_exec
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_247                   # While loop begin
LDI_A 0                          # Constant assignment 0 as int
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_248              # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_248              # Condition was true
JMP .while_end_249               # Condition was false, end loop
.while_true_248                  # Begin while loop body
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
MOV_DH_BH                        # Load base address of never_exec at offset 3 into B
MOV_DL_BL                        # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 99                        # Constant assignment 99 for  unsigned char never_exec
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char never_exec
JMP .while_top_247               # Next While loop
.while_end_249                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
LDI_A .data_string_62            # "While loop (never executes)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
INCR_D                           # Load base address of never_exec at offset 3 into B
MOV_DH_BH                        # Load base address of never_exec at offset 3 into B
MOV_DL_BL                        # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
DECR_D                           # Load base address of never_exec at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of outer2 at offset 4 into B
MOV_DH_BH                        # Load base address of outer2 at offset 4 into B
MOV_DL_BL                        # Load base address of outer2 at offset 4 into B
DECR4_D                          # Load base address of outer2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char outer2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char outer2
INCR4_D                          # Load base address of inner_sum at offset 5 into B
INCR_D                           # Load base address of inner_sum at offset 5 into B
MOV_DH_BH                        # Load base address of inner_sum at offset 5 into B
MOV_DL_BL                        # Load base address of inner_sum at offset 5 into B
DECR4_D                          # Load base address of inner_sum at offset 5 into B
DECR_D                           # Load base address of inner_sum at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char inner_sum
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char inner_sum
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_250                   # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of outer2 at offset 4 into B
MOV_DH_BH                        # Load base address of outer2 at offset 4 into B
MOV_DL_BL                        # Load base address of outer2 at offset 4 into B
DECR4_D                          # Load base address of outer2 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_255      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_256        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_253          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_254            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_254           # Signed BinaryOp <: Signs were different
.binaryop_equal_253
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_254
.binaryop_overflow_256
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_254
.binaryop_diffsigns_255
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_254           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_254
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_251              # Condition was true
JMP .while_end_252               # Condition was false, end loop
.while_true_251                  # Begin while loop body
INCR4_D                          # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
MOV_DH_BH                        # Load base address of inner2 at offset 6 into B
MOV_DL_BL                        # Load base address of inner2 at offset 6 into B
DECR4_D                          # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char inner2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char inner2
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_257                   # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
MOV_DH_BH                        # Load base address of inner2 at offset 6 into B
MOV_DL_BL                        # Load base address of inner2 at offset 6 into B
DECR4_D                          # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_262      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_263        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_260          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_261            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_261           # Signed BinaryOp <: Signs were different
.binaryop_equal_260
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_261
.binaryop_overflow_263
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_261
.binaryop_diffsigns_262
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_261           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_261
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_258              # Condition was true
JMP .while_end_259               # Condition was false, end loop
.while_true_258                  # Begin while loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of inner_sum at offset 5 into B
INCR_D                           # Load base address of inner_sum at offset 5 into B
MOV_DH_BH                        # Load base address of inner_sum at offset 5 into B
MOV_DL_BL                        # Load base address of inner_sum at offset 5 into B
DECR4_D                          # Load base address of inner_sum at offset 5 into B
DECR_D                           # Load base address of inner_sum at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of inner_sum at offset 5 into B
INCR_D                           # Load base address of inner_sum at offset 5 into B
MOV_DH_BH                        # Load base address of inner_sum at offset 5 into B
MOV_DL_BL                        # Load base address of inner_sum at offset 5 into B
DECR4_D                          # Load base address of inner_sum at offset 5 into B
DECR_D                           # Load base address of inner_sum at offset 5 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char inner_sum
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
MOV_DH_BH                        # Load base address of inner2 at offset 6 into B
MOV_DL_BL                        # Load base address of inner2 at offset 6 into B
DECR4_D                          # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
INCR_D                           # Load base address of inner2 at offset 6 into B
MOV_DH_BH                        # Load base address of inner2 at offset 6 into B
MOV_DL_BL                        # Load base address of inner2 at offset 6 into B
DECR4_D                          # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
DECR_D                           # Load base address of inner2 at offset 6 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char inner2
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .while_top_257               # Next While loop
.while_end_259                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of outer2 at offset 4 into B
MOV_DH_BH                        # Load base address of outer2 at offset 4 into B
MOV_DL_BL                        # Load base address of outer2 at offset 4 into B
DECR4_D                          # Load base address of outer2 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of outer2 at offset 4 into B
MOV_DH_BH                        # Load base address of outer2 at offset 4 into B
MOV_DL_BL                        # Load base address of outer2 at offset 4 into B
DECR4_D                          # Load base address of outer2 at offset 4 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char outer2
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .while_top_250               # Next While loop
.while_end_252                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
LDI_A .data_string_63            # "Nested while loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 6                         # Constant assignment 6 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of inner_sum at offset 5 into B
INCR_D                           # Load base address of inner_sum at offset 5 into B
MOV_DH_BH                        # Load base address of inner_sum at offset 5 into B
MOV_DL_BL                        # Load base address of inner_sum at offset 5 into B
DECR4_D                          # Load base address of inner_sum at offset 5 into B
DECR_D                           # Load base address of inner_sum at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_while_return_239
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

:test_do_while                   # void test_do_while()
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
LDI_BL 3                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of count3 at offset 1 into B
MOV_DH_BH                        # Load base address of count3 at offset 1 into B
MOV_DL_BL                        # Load base address of count3 at offset 1 into B
DECR_D                           # Load base address of count3 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char count3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count3
INCR_D                           # Load base address of sum3 at offset 2 into B
INCR_D                           # Load base address of sum3 at offset 2 into B
MOV_DH_BH                        # Load base address of sum3 at offset 2 into B
MOV_DL_BL                        # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sum3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum3
ALUOP_PUSH %A%+%AH%              # Preserve A for dowhile loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for dowhile loop condition
.dowhile_top_265                 # DoWhile loop begin
INCR_D                           # Load base address of sum3 at offset 2 into B
INCR_D                           # Load base address of sum3 at offset 2 into B
MOV_DH_BH                        # Load base address of sum3 at offset 2 into B
MOV_DL_BL                        # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of count3 at offset 1 into A
MOV_DH_AH                        # Load base address of count3 at offset 1 into A
MOV_DL_AL                        # Load base address of count3 at offset 1 into A
DECR_D                           # Load base address of count3 at offset 1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum3 at offset 2 into B
INCR_D                           # Load base address of sum3 at offset 2 into B
MOV_DH_BH                        # Load base address of sum3 at offset 2 into B
MOV_DL_BL                        # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of count3 at offset 1 into B
MOV_DH_BH                        # Load base address of count3 at offset 1 into B
MOV_DL_BL                        # Load base address of count3 at offset 1 into B
DECR_D                           # Load base address of count3 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of count3 at offset 1 into B
MOV_DH_BH                        # Load base address of count3 at offset 1 into B
MOV_DL_BL                        # Load base address of count3 at offset 1 into B
DECR_D                           # Load base address of count3 at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count3
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
.dowhile_condition_266           # DoWhile condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of count3 at offset 1 into B
MOV_DH_BH                        # Load base address of count3 at offset 1 into B
MOV_DL_BL                        # Load base address of count3 at offset 1 into B
DECR_D                           # Load base address of count3 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_270      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_271        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_268          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_269            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_269           # Signed BinaryOp <: Signs were different
.binaryop_equal_268
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_269
.binaryop_overflow_271
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_269
.binaryop_diffsigns_270
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_269           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_269
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check dowhile condition
JNZ .dowhile_top_265             # Condition was true
.dowhile_end_267                 # Condition was false, end loop
POP_AL                           # Restore A from dowhile loop condition
POP_AH                           # Restore A from dowhile loop condition
LDI_A .data_string_64            # "Do-while loop sum"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum3 at offset 2 into B
INCR_D                           # Load base address of sum3 at offset 2 into B
MOV_DH_BH                        # Load base address of sum3 at offset 2 into B
MOV_DL_BL                        # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
DECR_D                           # Load base address of sum3 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
MOV_DH_BH                        # Load base address of once at offset 3 into B
MOV_DL_BL                        # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char once
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char once
ALUOP_PUSH %A%+%AH%              # Preserve A for dowhile loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for dowhile loop condition
.dowhile_top_272                 # DoWhile loop begin
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
MOV_DH_BH                        # Load base address of once at offset 3 into B
MOV_DL_BL                        # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char once
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char once
.dowhile_condition_273           # DoWhile condition
LDI_A 0                          # Constant assignment 0 as int
ALUOP_FLAGS %A%+%AL%             # Check dowhile condition
JNZ .dowhile_top_272             # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check dowhile condition
JNZ .dowhile_top_272             # Condition was true
.dowhile_end_274                 # Condition was false, end loop
POP_AL                           # Restore A from dowhile loop condition
POP_AH                           # Restore A from dowhile loop condition
LDI_A .data_string_65            # "Do-while executes once"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
INCR_D                           # Load base address of once at offset 3 into B
MOV_DH_BH                        # Load base address of once at offset 3 into B
MOV_DL_BL                        # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
DECR_D                           # Load base address of once at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_do_while_return_264
LDI_BL 3                         # Bytes to free from local vars and parameters
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

:test_for                        # void test_for()
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
LDI_BL 10                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of sum_for at offset 1 into B
MOV_DH_BH                        # Load base address of sum_for at offset 1 into B
MOV_DL_BL                        # Load base address of sum_for at offset 1 into B
DECR_D                           # Load base address of sum_for at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sum_for
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum_for
INCR_D                           # Load base address of i at offset 2 into B
INCR_D                           # Load base address of i at offset 2 into B
MOV_DH_BH                        # Load base address of i at offset 2 into B
MOV_DL_BL                        # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
.for_condition_276               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 2 into B
INCR_D                           # Load base address of i at offset 2 into B
MOV_DH_BH                        # Load base address of i at offset 2 into B
MOV_DL_BL                        # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_283      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_284        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_281          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_282            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_282           # Signed BinaryOp <: Signs were different
.binaryop_equal_281
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_282
.binaryop_overflow_284
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_282
.binaryop_diffsigns_283
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_282           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_282
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_278           # Condition was true
JMP .for_end_280                 # Condition was false, end loop
.for_cond_true_278               # Begin for loop body
INCR_D                           # Load base address of sum_for at offset 1 into B
MOV_DH_BH                        # Load base address of sum_for at offset 1 into B
MOV_DL_BL                        # Load base address of sum_for at offset 1 into B
DECR_D                           # Load base address of sum_for at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of i at offset 2 into A
INCR_D                           # Load base address of i at offset 2 into A
MOV_DH_AH                        # Load base address of i at offset 2 into A
MOV_DL_AL                        # Load base address of i at offset 2 into A
DECR_D                           # Load base address of i at offset 2 into A
DECR_D                           # Load base address of i at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_for at offset 1 into B
MOV_DH_BH                        # Load base address of sum_for at offset 1 into B
MOV_DL_BL                        # Load base address of sum_for at offset 1 into B
DECR_D                           # Load base address of sum_for at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum_for
.for_increment_277               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 2 into B
INCR_D                           # Load base address of i at offset 2 into B
MOV_DH_BH                        # Load base address of i at offset 2 into B
MOV_DL_BL                        # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of i at offset 2 into B
INCR_D                           # Load base address of i at offset 2 into B
MOV_DH_BH                        # Load base address of i at offset 2 into B
MOV_DL_BL                        # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
DECR_D                           # Load base address of i at offset 2 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_276           # Next for loop iteration
.for_end_280                     # End for loop
LDI_A .data_string_66            # "For loop sum"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_for at offset 1 into B
MOV_DH_BH                        # Load base address of sum_for at offset 1 into B
MOV_DL_BL                        # Load base address of sum_for at offset 1 into B
DECR_D                           # Load base address of sum_for at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_for16 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short sum_for16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sum_for16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sum_for16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sum_for16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sum_for16
INCR4_D                          # Load base address of j at offset 5 into B
INCR_D                           # Load base address of j at offset 5 into B
MOV_DH_BH                        # Load base address of j at offset 5 into B
MOV_DL_BL                        # Load base address of j at offset 5 into B
DECR4_D                          # Load base address of j at offset 5 into B
DECR_D                           # Load base address of j at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short j
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short j
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short j
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short j
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short j
.for_condition_285               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of j at offset 5 into B
INCR_D                           # Load base address of j at offset 5 into B
MOV_DH_BH                        # Load base address of j at offset 5 into B
MOV_DL_BL                        # Load base address of j at offset 5 into B
DECR4_D                          # Load base address of j at offset 5 into B
DECR_D                           # Load base address of j at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_292      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_293        # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_290          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_A 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_291            # Signed BinaryOp <: Assume signs were the same
LDI_A 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_291           # Signed BinaryOp <: Signs were different
.binaryop_equal_290
LDI_A 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_291
.binaryop_overflow_293
LDI_A 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_291
.binaryop_diffsigns_292
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp <: Check sign of left operand
LDI_A 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_291           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_A 0                          # Signed BinaryOp <: flip to false
.binaryop_done_291
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
JNZ .for_cond_sub_true_288       # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check for condition
JNZ .for_cond_sub_true_288       # Condition was true
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JMP .for_end_289                 # Condition was false, end loop
.for_cond_sub_true_288
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
.for_cond_true_287               # Begin for loop body
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_for16 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of j at offset 5 into A
INCR_D                           # Load base address of j at offset 5 into A
MOV_DH_AH                        # Load base address of j at offset 5 into A
MOV_DL_AL                        # Load base address of j at offset 5 into A
DECR4_D                          # Load base address of j at offset 5 into A
DECR_D                           # Load base address of j at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_for16 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
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
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sum_for16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sum_for16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sum_for16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sum_for16
.for_increment_286               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of j at offset 5 into B
INCR_D                           # Load base address of j at offset 5 into B
MOV_DH_BH                        # Load base address of j at offset 5 into B
MOV_DL_BL                        # Load base address of j at offset 5 into B
DECR4_D                          # Load base address of j at offset 5 into B
DECR_D                           # Load base address of j at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of j at offset 5 into B
INCR_D                           # Load base address of j at offset 5 into B
MOV_DH_BH                        # Load base address of j at offset 5 into B
MOV_DL_BL                        # Load base address of j at offset 5 into B
DECR4_D                          # Load base address of j at offset 5 into B
DECR_D                           # Load base address of j at offset 5 into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short j
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short j
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short j
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short j
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_285           # Next for loop iteration
.for_end_289                     # End for loop
LDI_A .data_string_67            # "For loop 16-bit sum"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 3                          # Constant assignment 3 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
INCR_D                           # Load base address of sum_for16 at offset 3 into B
MOV_DH_BH                        # Load base address of sum_for16 at offset 3 into B
MOV_DL_BL                        # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
DECR_D                           # Load base address of sum_for16 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
MOV_DH_BH                        # Load base address of k at offset 7 into B
MOV_DL_BL                        # Load base address of k at offset 7 into B
DECR4_D                          # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char k
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char k
.for_condition_294               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 10                         # Constant assignment 10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
MOV_DH_BH                        # Load base address of k at offset 7 into B
MOV_DL_BL                        # Load base address of k at offset 7 into B
DECR4_D                          # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_301      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_302        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_299          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_300            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_300           # Signed BinaryOp <: Signs were different
.binaryop_equal_299
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_300
.binaryop_overflow_302
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_300
.binaryop_diffsigns_301
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_300           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_300
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_296           # Condition was true
JMP .for_end_298                 # Condition was false, end loop
.for_cond_true_296               # Begin for loop body
.for_increment_295               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
MOV_DH_BH                        # Load base address of k at offset 7 into B
MOV_DL_BL                        # Load base address of k at offset 7 into B
DECR4_D                          # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
MOV_DH_BH                        # Load base address of k at offset 7 into B
MOV_DL_BL                        # Load base address of k at offset 7 into B
DECR4_D                          # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char k
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_294           # Next for loop iteration
.for_end_298                     # End for loop
LDI_A .data_string_68            # "For loop empty body"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
INCR_D                           # Load base address of k at offset 7 into B
MOV_DH_BH                        # Load base address of k at offset 7 into B
MOV_DL_BL                        # Load base address of k at offset 7 into B
DECR4_D                          # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
DECR_D                           # Load base address of k at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR8_D                          # Load base address of nested_for_sum at offset 8 into B
MOV_DH_BH                        # Load base address of nested_for_sum at offset 8 into B
MOV_DL_BL                        # Load base address of nested_for_sum at offset 8 into B
DECR8_D                          # Load base address of nested_for_sum at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char nested_for_sum
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char nested_for_sum
INCR8_D                          # Load base address of m at offset 9 into B
INCR_D                           # Load base address of m at offset 9 into B
MOV_DH_BH                        # Load base address of m at offset 9 into B
MOV_DL_BL                        # Load base address of m at offset 9 into B
DECR8_D                          # Load base address of m at offset 9 into B
DECR_D                           # Load base address of m at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char m
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char m
.for_condition_303               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of m at offset 9 into B
INCR_D                           # Load base address of m at offset 9 into B
MOV_DH_BH                        # Load base address of m at offset 9 into B
MOV_DL_BL                        # Load base address of m at offset 9 into B
DECR8_D                          # Load base address of m at offset 9 into B
DECR_D                           # Load base address of m at offset 9 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_310      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_311        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_308          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_309            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_309           # Signed BinaryOp <: Signs were different
.binaryop_equal_308
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_309
.binaryop_overflow_311
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_309
.binaryop_diffsigns_310
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_309           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_309
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_305           # Condition was true
JMP .for_end_307                 # Condition was false, end loop
.for_cond_true_305               # Begin for loop body
ALUOP_PUSH %A%+%AL%              # Load base address of n at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of n at offset 10 into B
MOV_DH_BH                        # Load base address of n at offset 10 into B
MOV_DL_BL                        # Load base address of n at offset 10 into B
LDI_A 10                         # Load base address of n at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of n at offset 10 into B
POP_AH                           # Load base address of n at offset 10 into B
POP_AL                           # Load base address of n at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char n
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char n
.for_condition_312               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of n at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of n at offset 10 into B
MOV_DH_BH                        # Load base address of n at offset 10 into B
MOV_DL_BL                        # Load base address of n at offset 10 into B
LDI_A 10                         # Load base address of n at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of n at offset 10 into B
POP_AH                           # Load base address of n at offset 10 into B
POP_AL                           # Load base address of n at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_319      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_320        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_317          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_318            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_318           # Signed BinaryOp <: Signs were different
.binaryop_equal_317
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_318
.binaryop_overflow_320
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_318
.binaryop_diffsigns_319
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_318           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_318
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_314           # Condition was true
JMP .for_end_316                 # Condition was false, end loop
.for_cond_true_314               # Begin for loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of nested_for_sum at offset 8 into B
MOV_DH_BH                        # Load base address of nested_for_sum at offset 8 into B
MOV_DL_BL                        # Load base address of nested_for_sum at offset 8 into B
DECR8_D                          # Load base address of nested_for_sum at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR8_D                          # Load base address of nested_for_sum at offset 8 into B
MOV_DH_BH                        # Load base address of nested_for_sum at offset 8 into B
MOV_DL_BL                        # Load base address of nested_for_sum at offset 8 into B
DECR8_D                          # Load base address of nested_for_sum at offset 8 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char nested_for_sum
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
.for_increment_313               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of n at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of n at offset 10 into B
MOV_DH_BH                        # Load base address of n at offset 10 into B
MOV_DL_BL                        # Load base address of n at offset 10 into B
LDI_A 10                         # Load base address of n at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of n at offset 10 into B
POP_AH                           # Load base address of n at offset 10 into B
POP_AL                           # Load base address of n at offset 10 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %A%+%AL%              # Load base address of n at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of n at offset 10 into B
MOV_DH_BH                        # Load base address of n at offset 10 into B
MOV_DL_BL                        # Load base address of n at offset 10 into B
LDI_A 10                         # Load base address of n at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of n at offset 10 into B
POP_AH                           # Load base address of n at offset 10 into B
POP_AL                           # Load base address of n at offset 10 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char n
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_312           # Next for loop iteration
.for_end_316                     # End for loop
.for_increment_304               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of m at offset 9 into B
INCR_D                           # Load base address of m at offset 9 into B
MOV_DH_BH                        # Load base address of m at offset 9 into B
MOV_DL_BL                        # Load base address of m at offset 9 into B
DECR8_D                          # Load base address of m at offset 9 into B
DECR_D                           # Load base address of m at offset 9 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR8_D                          # Load base address of m at offset 9 into B
INCR_D                           # Load base address of m at offset 9 into B
MOV_DH_BH                        # Load base address of m at offset 9 into B
MOV_DL_BL                        # Load base address of m at offset 9 into B
DECR8_D                          # Load base address of m at offset 9 into B
DECR_D                           # Load base address of m at offset 9 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char m
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_303           # Next for loop iteration
.for_end_307                     # End for loop
LDI_A .data_string_69            # "Nested for loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 6                         # Constant assignment 6 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of nested_for_sum at offset 8 into B
MOV_DH_BH                        # Load base address of nested_for_sum at offset 8 into B
MOV_DL_BL                        # Load base address of nested_for_sum at offset 8 into B
DECR8_D                          # Load base address of nested_for_sum at offset 8 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_for_return_275
LDI_BL 10                        # Bytes to free from local vars and parameters
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

:test_break_continue             # void test_break_continue()
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
INCR_D                           # Load base address of break_count at offset 1 into B
MOV_DH_BH                        # Load base address of break_count at offset 1 into B
MOV_DL_BL                        # Load base address of break_count at offset 1 into B
DECR_D                           # Load base address of break_count at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char break_count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char break_count
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_322                   # While loop begin
LDI_A 1                          # Constant assignment 1 as int
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_323              # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check while condition
JNZ .while_true_323              # Condition was true
JMP .while_end_324               # Condition was false, end loop
.while_true_323                  # Begin while loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of break_count at offset 1 into B
MOV_DH_BH                        # Load base address of break_count at offset 1 into B
MOV_DL_BL                        # Load base address of break_count at offset 1 into B
DECR_D                           # Load base address of break_count at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of break_count at offset 1 into B
MOV_DH_BH                        # Load base address of break_count at offset 1 into B
MOV_DL_BL                        # Load base address of break_count at offset 1 into B
DECR_D                           # Load base address of break_count at offset 1 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char break_count
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of break_count at offset 1 into B
MOV_DH_BH                        # Load base address of break_count at offset 1 into B
MOV_DL_BL                        # Load base address of break_count at offset 1 into B
DECR_D                           # Load base address of break_count at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_327      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_328
.binarybool_isfalse_327
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_328
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_325          # Condition was true
JMP .end_if_326                  # Done with false condition
.condition_true_325              # Condition was true
JMP .while_end_324               # Break out of loop/switch
.end_if_326                      # End If
JMP .while_top_322               # Next While loop
.while_end_324                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
LDI_A .data_string_70            # "Break in while loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 3                         # Constant assignment 3 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of break_count at offset 1 into B
MOV_DH_BH                        # Load base address of break_count at offset 1 into B
MOV_DL_BL                        # Load base address of break_count at offset 1 into B
DECR_D                           # Load base address of break_count at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of cont_sum at offset 2 into B
INCR_D                           # Load base address of cont_sum at offset 2 into B
MOV_DH_BH                        # Load base address of cont_sum at offset 2 into B
MOV_DL_BL                        # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char cont_sum
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_sum
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
MOV_DH_BH                        # Load base address of cont_i at offset 3 into B
MOV_DL_BL                        # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char cont_i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_i
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_329                   # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
MOV_DH_BH                        # Load base address of cont_i at offset 3 into B
MOV_DL_BL                        # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_334      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_335        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_332          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_333            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_333           # Signed BinaryOp <: Signs were different
.binaryop_equal_332
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_333
.binaryop_overflow_335
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_333
.binaryop_diffsigns_334
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_333           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_333
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_330              # Condition was true
JMP .while_end_331               # Condition was false, end loop
.while_true_330                  # Begin while loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
MOV_DH_BH                        # Load base address of cont_i at offset 3 into B
MOV_DL_BL                        # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
MOV_DH_BH                        # Load base address of cont_i at offset 3 into B
MOV_DL_BL                        # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
INCR_D                           # Load base address of cont_i at offset 3 into B
MOV_DH_BH                        # Load base address of cont_i at offset 3 into B
MOV_DL_BL                        # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
DECR_D                           # Load base address of cont_i at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_338      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_339
.binarybool_isfalse_338
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_339
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_336          # Condition was true
JMP .end_if_337                  # Done with false condition
.condition_true_336              # Condition was true
JMP .while_top_329               # Continue loop
.end_if_337                      # End If
INCR_D                           # Load base address of cont_sum at offset 2 into B
INCR_D                           # Load base address of cont_sum at offset 2 into B
MOV_DH_BH                        # Load base address of cont_sum at offset 2 into B
MOV_DL_BL                        # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of cont_i at offset 3 into A
INCR_D                           # Load base address of cont_i at offset 3 into A
INCR_D                           # Load base address of cont_i at offset 3 into A
MOV_DH_AH                        # Load base address of cont_i at offset 3 into A
MOV_DL_AL                        # Load base address of cont_i at offset 3 into A
DECR_D                           # Load base address of cont_i at offset 3 into A
DECR_D                           # Load base address of cont_i at offset 3 into A
DECR_D                           # Load base address of cont_i at offset 3 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of cont_sum at offset 2 into B
INCR_D                           # Load base address of cont_sum at offset 2 into B
MOV_DH_BH                        # Load base address of cont_sum at offset 2 into B
MOV_DL_BL                        # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_sum
JMP .while_top_329               # Next While loop
.while_end_331                   # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
LDI_A .data_string_71            # "Continue in while loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 12                        # Constant assignment 12 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of cont_sum at offset 2 into B
INCR_D                           # Load base address of cont_sum at offset 2 into B
MOV_DH_BH                        # Load base address of cont_sum at offset 2 into B
MOV_DL_BL                        # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
DECR_D                           # Load base address of cont_sum at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of break_for at offset 4 into B
MOV_DH_BH                        # Load base address of break_for at offset 4 into B
MOV_DL_BL                        # Load base address of break_for at offset 4 into B
DECR4_D                          # Load base address of break_for at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char break_for
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char break_for
INCR4_D                          # Load base address of bf_i at offset 5 into B
INCR_D                           # Load base address of bf_i at offset 5 into B
MOV_DH_BH                        # Load base address of bf_i at offset 5 into B
MOV_DL_BL                        # Load base address of bf_i at offset 5 into B
DECR4_D                          # Load base address of bf_i at offset 5 into B
DECR_D                           # Load base address of bf_i at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char bf_i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char bf_i
.for_condition_340               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 10                         # Constant assignment 10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of bf_i at offset 5 into B
INCR_D                           # Load base address of bf_i at offset 5 into B
MOV_DH_BH                        # Load base address of bf_i at offset 5 into B
MOV_DL_BL                        # Load base address of bf_i at offset 5 into B
DECR4_D                          # Load base address of bf_i at offset 5 into B
DECR_D                           # Load base address of bf_i at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_347      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_348        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_345          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_346            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_346           # Signed BinaryOp <: Signs were different
.binaryop_equal_345
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_346
.binaryop_overflow_348
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_346
.binaryop_diffsigns_347
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_346           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_346
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_342           # Condition was true
JMP .for_end_344                 # Condition was false, end loop
.for_cond_true_342               # Begin for loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of break_for at offset 4 into B
MOV_DH_BH                        # Load base address of break_for at offset 4 into B
MOV_DL_BL                        # Load base address of break_for at offset 4 into B
DECR4_D                          # Load base address of break_for at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of break_for at offset 4 into B
MOV_DH_BH                        # Load base address of break_for at offset 4 into B
MOV_DL_BL                        # Load base address of break_for at offset 4 into B
DECR4_D                          # Load base address of break_for at offset 4 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char break_for
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 4                          # Constant assignment 4 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of bf_i at offset 5 into B
INCR_D                           # Load base address of bf_i at offset 5 into B
MOV_DH_BH                        # Load base address of bf_i at offset 5 into B
MOV_DL_BL                        # Load base address of bf_i at offset 5 into B
DECR4_D                          # Load base address of bf_i at offset 5 into B
DECR_D                           # Load base address of bf_i at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_351      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_352
.binarybool_isfalse_351
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_352
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_349          # Condition was true
JMP .end_if_350                  # Done with false condition
.condition_true_349              # Condition was true
JMP .for_end_344                 # Break out of loop/switch
.end_if_350                      # End If
.for_increment_341               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of bf_i at offset 5 into B
INCR_D                           # Load base address of bf_i at offset 5 into B
MOV_DH_BH                        # Load base address of bf_i at offset 5 into B
MOV_DL_BL                        # Load base address of bf_i at offset 5 into B
DECR4_D                          # Load base address of bf_i at offset 5 into B
DECR_D                           # Load base address of bf_i at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of bf_i at offset 5 into B
INCR_D                           # Load base address of bf_i at offset 5 into B
MOV_DH_BH                        # Load base address of bf_i at offset 5 into B
MOV_DL_BL                        # Load base address of bf_i at offset 5 into B
DECR4_D                          # Load base address of bf_i at offset 5 into B
DECR_D                           # Load base address of bf_i at offset 5 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char bf_i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_340           # Next for loop iteration
.for_end_344                     # End for loop
LDI_A .data_string_72            # "Break in for loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 5                         # Constant assignment 5 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of break_for at offset 4 into B
MOV_DH_BH                        # Load base address of break_for at offset 4 into B
MOV_DL_BL                        # Load base address of break_for at offset 4 into B
DECR4_D                          # Load base address of break_for at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
MOV_DH_BH                        # Load base address of cont_for_sum at offset 6 into B
MOV_DL_BL                        # Load base address of cont_for_sum at offset 6 into B
DECR4_D                          # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char cont_for_sum
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_for_sum
INCR4_D                          # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
MOV_DH_BH                        # Load base address of cf_i at offset 7 into B
MOV_DL_BL                        # Load base address of cf_i at offset 7 into B
DECR4_D                          # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char cf_i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cf_i
.for_condition_353               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
MOV_DH_BH                        # Load base address of cf_i at offset 7 into B
MOV_DL_BL                        # Load base address of cf_i at offset 7 into B
DECR4_D                          # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_360      # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_361        # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_358          # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_359            # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_359           # Signed BinaryOp <: Signs were different
.binaryop_equal_358
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_359
.binaryop_overflow_361
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_359
.binaryop_diffsigns_360
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_359           # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_359
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_355           # Condition was true
JMP .for_end_357                 # Condition was false, end loop
.for_cond_true_355               # Begin for loop body
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
MOV_DH_BH                        # Load base address of cf_i at offset 7 into B
MOV_DL_BL                        # Load base address of cf_i at offset 7 into B
DECR4_D                          # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_364      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_365
.binarybool_isfalse_364
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_365
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_362          # Condition was true
JMP .end_if_363                  # Done with false condition
.condition_true_362              # Condition was true
JMP .for_increment_354           # Continue loop
.end_if_363                      # End If
INCR4_D                          # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
MOV_DH_BH                        # Load base address of cont_for_sum at offset 6 into B
MOV_DL_BL                        # Load base address of cont_for_sum at offset 6 into B
DECR4_D                          # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of cf_i at offset 7 into A
INCR_D                           # Load base address of cf_i at offset 7 into A
INCR_D                           # Load base address of cf_i at offset 7 into A
INCR_D                           # Load base address of cf_i at offset 7 into A
MOV_DH_AH                        # Load base address of cf_i at offset 7 into A
MOV_DL_AL                        # Load base address of cf_i at offset 7 into A
DECR4_D                          # Load base address of cf_i at offset 7 into A
DECR_D                           # Load base address of cf_i at offset 7 into A
DECR_D                           # Load base address of cf_i at offset 7 into A
DECR_D                           # Load base address of cf_i at offset 7 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
MOV_DH_BH                        # Load base address of cont_for_sum at offset 6 into B
MOV_DL_BL                        # Load base address of cont_for_sum at offset 6 into B
DECR4_D                          # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cont_for_sum
.for_increment_354               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
MOV_DH_BH                        # Load base address of cf_i at offset 7 into B
MOV_DL_BL                        # Load base address of cf_i at offset 7 into B
DECR4_D                          # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
INCR_D                           # Load base address of cf_i at offset 7 into B
MOV_DH_BH                        # Load base address of cf_i at offset 7 into B
MOV_DL_BL                        # Load base address of cf_i at offset 7 into B
DECR4_D                          # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
DECR_D                           # Load base address of cf_i at offset 7 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char cf_i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_353           # Next for loop iteration
.for_end_357                     # End for loop
LDI_A .data_string_73            # "Continue in for loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 8                         # Constant assignment 8 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
INCR_D                           # Load base address of cont_for_sum at offset 6 into B
MOV_DH_BH                        # Load base address of cont_for_sum at offset 6 into B
MOV_DL_BL                        # Load base address of cont_for_sum at offset 6 into B
DECR4_D                          # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
DECR_D                           # Load base address of cont_for_sum at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_break_continue_return_321
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

:add_u8                          # unsigned char add_u8( unsigned char a_param,  unsigned char b_param)
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
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of b_param at offset -1 into A
MOV_DH_AH                        # Load base address of b_param at offset -1 into A
MOV_DL_AL                        # Load base address of b_param at offset -1 into A
INCR_D                           # Load base address of b_param at offset -1 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of a_param at offset 0 into B
MOV_DL_BL                        # Load base address of a_param at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
JMP .add_u8_return_366
.add_u8_return_366
LDI_BL 2                         # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
CALL :heap_push_AL               # Return value
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:add_u16                         # unsigned short add_u16( unsigned short a16_param,  unsigned short b16_param)
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
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of b16_param at offset -3 into A
DECR_D                           # Load base address of b16_param at offset -3 into A
DECR_D                           # Load base address of b16_param at offset -3 into A
MOV_DH_AH                        # Load base address of b16_param at offset -3 into A
MOV_DL_AL                        # Load base address of b16_param at offset -3 into A
INCR_D                           # Load base address of b16_param at offset -3 into A
INCR_D                           # Load base address of b16_param at offset -3 into A
INCR_D                           # Load base address of b16_param at offset -3 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of a16_param at offset -1 into B
MOV_DH_BH                        # Load base address of a16_param at offset -1 into B
MOV_DL_BL                        # Load base address of a16_param at offset -1 into B
INCR_D                           # Load base address of a16_param at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
JMP .add_u16_return_367
.add_u16_return_367
LDI_BL 4                         # Bytes to free from local vars and parameters
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

:mixed_params                    # unsigned short mixed_params( unsigned char byte_param,  unsigned short word_param)
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
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of word_param at offset -2 into A
DECR_D                           # Load base address of word_param at offset -2 into A
MOV_DH_AH                        # Load base address of word_param at offset -2 into A
MOV_DL_AL                        # Load base address of word_param at offset -2 into A
INCR_D                           # Load base address of word_param at offset -2 into A
INCR_D                           # Load base address of word_param at offset -2 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of byte_param at offset 0 into B
MOV_DL_BL                        # Load base address of byte_param at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
JMP .mixed_params_return_368
.mixed_params_return_368
LDI_BL 3                         # Bytes to free from local vars and parameters
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

:modify_by_ptr                   # void modify_by_ptr( unsigned char *ptr_param)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of ptr_param at offset -1 into A
MOV_DH_AH                        # Load base address of ptr_param at offset -1 into A
MOV_DL_AL                        # Load base address of ptr_param at offset -1 into A
INCR_D                           # Load base address of ptr_param at offset -1 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 10                        # Constant assignment 10 for  unsigned char ptr_param_deref (virtual)
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of ptr_param at offset -1 into A
MOV_DH_AH                        # Load base address of ptr_param at offset -1 into A
MOV_DL_AL                        # Load base address of ptr_param at offset -1 into A
INCR_D                           # Load base address of ptr_param at offset -1 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
LDA_B_AL                         # Dereferenced load
POP_BL                           # UnaryOp *: Restore B, dereferenced rvalue in A
POP_BH                           # UnaryOp *: Restore B, dereferenced rvalue in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char ptr_param_deref (virtual)
.modify_by_ptr_return_369
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

:modify_point                    # void modify_point( struct Point *pt_param)
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
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into A
MOV_DH_AH                        # Load base address of pt_param at offset -1 into A
MOV_DL_AL                        # Load base address of pt_param at offset -1 into A
INCR_D                           # Load base address of pt_param at offset -1 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for  unsigned char x
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into B
MOV_DH_BH                        # Load base address of pt_param at offset -1 into B
MOV_DL_BL                        # Load base address of pt_param at offset -1 into B
INCR_D                           # Load base address of pt_param at offset -1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into B
MOV_DH_BH                        # Load base address of pt_param at offset -1 into B
MOV_DL_BL                        # Load base address of pt_param at offset -1 into B
INCR_D                           # Load base address of pt_param at offset -1 into B
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
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into A
MOV_DH_AH                        # Load base address of pt_param at offset -1 into A
MOV_DL_AL                        # Load base address of pt_param at offset -1 into A
INCR_D                           # Load base address of pt_param at offset -1 into A
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
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for  unsigned char y
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into B
MOV_DH_BH                        # Load base address of pt_param at offset -1 into B
MOV_DL_BL                        # Load base address of pt_param at offset -1 into B
INCR_D                           # Load base address of pt_param at offset -1 into B
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
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of pt_param at offset -1 into B
MOV_DH_BH                        # Load base address of pt_param at offset -1 into B
MOV_DL_BL                        # Load base address of pt_param at offset -1 into B
INCR_D                           # Load base address of pt_param at offset -1 into B
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
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char y
.modify_point_return_370
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

:sum_array                       # unsigned char sum_array( unsigned char *arr_param,  unsigned char len)
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
INCR_D                           # Load base address of sum_result at offset 1 into B
MOV_DH_BH                        # Load base address of sum_result at offset 1 into B
MOV_DL_BL                        # Load base address of sum_result at offset 1 into B
DECR_D                           # Load base address of sum_result at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sum_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum_result
INCR_D                           # Load base address of idx at offset 2 into B
INCR_D                           # Load base address of idx at offset 2 into B
MOV_DH_BH                        # Load base address of idx at offset 2 into B
MOV_DL_BL                        # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char idx
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char idx
.for_condition_372               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
DECR_D                           # Load base address of len at offset -2 into A
DECR_D                           # Load base address of len at offset -2 into A
MOV_DH_AH                        # Load base address of len at offset -2 into A
MOV_DL_AL                        # Load base address of len at offset -2 into A
INCR_D                           # Load base address of len at offset -2 into A
INCR_D                           # Load base address of len at offset -2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of idx at offset 2 into B
INCR_D                           # Load base address of idx at offset 2 into B
MOV_DH_BH                        # Load base address of idx at offset 2 into B
MOV_DL_BL                        # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp <: Subtract to check E and O flags
JEQ .binaryop_equal_377          # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_378           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_378
.binaryop_equal_377
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_378
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_374           # Condition was true
JMP .for_end_376                 # Condition was false, end loop
.for_cond_true_374               # Begin for loop body
INCR_D                           # Load base address of sum_result at offset 1 into B
MOV_DH_BH                        # Load base address of sum_result at offset 1 into B
MOV_DL_BL                        # Load base address of sum_result at offset 1 into B
DECR_D                           # Load base address of sum_result at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
DECR_D                           # Load base address of arr_param at offset -1 into B
MOV_DH_BH                        # Load base address of arr_param at offset -1 into B
MOV_DL_BL                        # Load base address of arr_param at offset -1 into B
INCR_D                           # Load base address of arr_param at offset -1 into B
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
INCR_D                           # Load base address of idx at offset 2 into A
INCR_D                           # Load base address of idx at offset 2 into A
MOV_DH_AH                        # Load base address of idx at offset 2 into A
MOV_DL_AL                        # Load base address of idx at offset 2 into A
DECR_D                           # Load base address of idx at offset 2 into A
DECR_D                           # Load base address of idx at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
LDA_A_BL                         # Dereferenced load
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_result at offset 1 into B
MOV_DH_BH                        # Load base address of sum_result at offset 1 into B
MOV_DL_BL                        # Load base address of sum_result at offset 1 into B
DECR_D                           # Load base address of sum_result at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sum_result
.for_increment_373               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of idx at offset 2 into B
INCR_D                           # Load base address of idx at offset 2 into B
MOV_DH_BH                        # Load base address of idx at offset 2 into B
MOV_DL_BL                        # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR_D                           # Load base address of idx at offset 2 into B
INCR_D                           # Load base address of idx at offset 2 into B
MOV_DH_BH                        # Load base address of idx at offset 2 into B
MOV_DL_BL                        # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
DECR_D                           # Load base address of idx at offset 2 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char idx
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_372           # Next for loop iteration
.for_end_376                     # End for loop
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_result at offset 1 into B
MOV_DH_BH                        # Load base address of sum_result at offset 1 into B
MOV_DL_BL                        # Load base address of sum_result at offset 1 into B
DECR_D                           # Load base address of sum_result at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
JMP .sum_array_return_371
.sum_array_return_371
LDI_BL 5                         # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
CALL :heap_push_AL               # Return value
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:void_function                   # void void_function()
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
LDI_B .var_g_byte                # Load base address of g_byte into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 123                       # Constant assignment 123 for  unsigned char g_byte
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char g_byte
.void_function_return_381
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:func_with_locals                # unsigned char func_with_locals( unsigned char param1,  unsigned char param2)
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
LDI_BL 3                         # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of local1 at offset 1 into B
MOV_DH_BH                        # Load base address of local1 at offset 1 into B
MOV_DL_BL                        # Load base address of local1 at offset 1 into B
DECR_D                           # Load base address of local1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 5                         # Constant assignment 5 for  unsigned char local1
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
MOV_DH_BH                        # Load base address of param1 at offset 0 into B
MOV_DL_BL                        # Load base address of param1 at offset 0 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local1
INCR_D                           # Load base address of local2 at offset 2 into B
INCR_D                           # Load base address of local2 at offset 2 into B
MOV_DH_BH                        # Load base address of local2 at offset 2 into B
MOV_DL_BL                        # Load base address of local2 at offset 2 into B
DECR_D                           # Load base address of local2 at offset 2 into B
DECR_D                           # Load base address of local2 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 10                        # Constant assignment 10 for  unsigned char local2
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
DECR_D                           # Load base address of param2 at offset -1 into B
MOV_DH_BH                        # Load base address of param2 at offset -1 into B
MOV_DL_BL                        # Load base address of param2 at offset -1 into B
INCR_D                           # Load base address of param2 at offset -1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local2
INCR_D                           # Load base address of local3 at offset 3 into B
INCR_D                           # Load base address of local3 at offset 3 into B
INCR_D                           # Load base address of local3 at offset 3 into B
MOV_DH_BH                        # Load base address of local3 at offset 3 into B
MOV_DL_BL                        # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of local2 at offset 2 into A
INCR_D                           # Load base address of local2 at offset 2 into A
MOV_DH_AH                        # Load base address of local2 at offset 2 into A
MOV_DL_AL                        # Load base address of local2 at offset 2 into A
DECR_D                           # Load base address of local2 at offset 2 into A
DECR_D                           # Load base address of local2 at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of local1 at offset 1 into B
MOV_DH_BH                        # Load base address of local1 at offset 1 into B
MOV_DL_BL                        # Load base address of local1 at offset 1 into B
DECR_D                           # Load base address of local1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of local3 at offset 3 into B
INCR_D                           # Load base address of local3 at offset 3 into B
INCR_D                           # Load base address of local3 at offset 3 into B
MOV_DH_BH                        # Load base address of local3 at offset 3 into B
MOV_DL_BL                        # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
DECR_D                           # Load base address of local3 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
JMP .func_with_locals_return_382
.func_with_locals_return_382
LDI_BL 5                         # Bytes to free from local vars and parameters
CALL :heap_retreat_BL
CALL :heap_push_AL               # Return value
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:func_with_static                # unsigned char func_with_static()
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
LDI_B .var_func_with_static_static_counter # Load base address of static_counter into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_func_with_static_static_counter # Load base address of static_counter into B
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char static_counter
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_func_with_static_static_counter # Load base address of static_counter into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
JMP .func_with_static_return_383
.func_with_static_return_383
CALL :heap_push_AL               # Return value
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
LDI_C .data_string_74            # "=== Compiler Test Suite ===\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_gt_lt
# function returns nothing, not popping a return value
CALL :test_if_else
# function returns nothing, not popping a return value
CALL :test_while
# function returns nothing, not popping a return value
CALL :test_do_while
# function returns nothing, not popping a return value
CALL :test_for
# function returns nothing, not popping a return value
CALL :test_break_continue
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_75            # "=== Test Results ===\n"
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
LDI_C .data_string_76            # "Total tests: %U\n"
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
LDI_C .data_string_77            # "Failed tests: %U\n"
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
JNE .binarybool_isfalse_387      # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_387      # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_388
.binarybool_isfalse_387
LDI_A 0                          # BinaryOp == was false
.binarybool_done_388
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_385          # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_78            # "\n*** SOME TESTS FAILED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .end_if_386                  # Done with false condition
.condition_true_385              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_79            # "\n*** ALL TESTS PASSED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_386                      # End If
.main_return_384
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
LDI_B .var_func_with_static_static_counter # Load base address of static_counter into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char static_counter
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char static_counter
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
.data_string_6 "1 < 10 (true)\0"
.data_string_7 "10 < 1 (false)\0"
.data_string_8 "1 > 10 (false)\0"
.data_string_9 "10 > 1 (true)\0"
.data_string_10 "10 > 10 (false)\0"
.data_string_11 "10 >= 10 (true)\0"
.data_string_12 "10 < 10 (false)\0"
.data_string_13 "10 <= 10 (true)\0"
.data_string_14 "signed 1 < 10 (true)\0"
.data_string_15 "signed 10 < 1 (false)\0"
.data_string_16 "signed 1 > 10 (false)\0"
.data_string_17 "signed 10 > 1 (true)\0"
.data_string_18 "signed 10 > 10 (false)\0"
.data_string_19 "signed 10 >= 10 (true)\0"
.data_string_20 "signed 10 < 10 (false)\0"
.data_string_21 "signed 10 <= 10 (true)\0"
.data_string_22 "signed -1 < 10 (true)\0"
.data_string_23 "signed 10 < -1 (false)\0"
.data_string_24 "signed -1 > 10 (false)\0"
.data_string_25 "signed 10 > -1 (true)\0"
.data_string_26 "signed -10 > -10 (false)\0"
.data_string_27 "signed -10 >= -10 (true)\0"
.data_string_28 "signed -10 < -10 (false)\0"
.data_string_29 "signed -10 <= -10 (true)\0"
.data_string_30 "16b 1 < 10 (true)\0"
.data_string_31 "16b 10 < 1 (false)\0"
.data_string_32 "16b 1 > 10 (false)\0"
.data_string_33 "16b 10 > 1 (true)\0"
.data_string_34 "16b 10 > 10 (false)\0"
.data_string_35 "16b 10 >= 10 (true)\0"
.data_string_36 "16b 10 < 10 (false)\0"
.data_string_37 "16b 10 <= 10 (true)\0"
.data_string_38 "16b signed 1 < 10 (true)\0"
.data_string_39 "16b signed 10 < 1 (false)\0"
.data_string_40 "16b signed 1 > 10 (false)\0"
.data_string_41 "16b signed 10 > 1 (true)\0"
.data_string_42 "16b signed 10 > 10 (false)\0"
.data_string_43 "16b signed 10 >= 10 (true)\0"
.data_string_44 "16b signed 10 < 10 (false)\0"
.data_string_45 "16b signed 10 <= 10 (true)\0"
.data_string_46 "16b signed -1 < 10 (true)\0"
.data_string_47 "16b signed 10 < -1 (false)\0"
.data_string_48 "16b signed -1 > 10 (false)\0"
.data_string_49 "16b signed 10 > -1 (true)\0"
.data_string_50 "16b signed -10 > -10 (false)\0"
.data_string_51 "16b signed -10 >= -10 (true)\0"
.data_string_52 "16b signed -10 < -10 (false)\0"
.data_string_53 "16b signed -10 <= -10 (true)\0"
.data_string_54 "If statement (true)\0"
.data_string_55 "If statement (false)\0"
.data_string_56 "If-else (true path)\0"
.data_string_57 "If-else (false path)\0"
.data_string_58 "Nested if\0"
.data_string_59 "If with 16-bit condition\0"
.data_string_60 "While loop sum\0"
.data_string_61 "While loop counter\0"
.data_string_62 "While loop (never executes)\0"
.data_string_63 "Nested while loop\0"
.data_string_64 "Do-while loop sum\0"
.data_string_65 "Do-while executes once\0"
.data_string_66 "For loop sum\0"
.data_string_67 "For loop 16-bit sum\0"
.data_string_68 "For loop empty body\0"
.data_string_69 "Nested for loop\0"
.data_string_70 "Break in while loop\0"
.data_string_71 "Continue in while loop\0"
.data_string_72 "Break in for loop\0"
.data_string_73 "Continue in for loop\0"
.data_string_74 "=== Compiler Test Suite ===\n\0"
.data_string_75 "=== Test Results ===\n\0"
.data_string_76 "Total tests: %U\n\0"
.data_string_77 "Failed tests: %U\n\0"
.data_string_78 "\n*** SOME TESTS FAILED ***\n\0"
.data_string_79 "\n*** ALL TESTS PASSED ***\n\0"
.var_g_byte "\0"
.var_g_word "\0\0"
.var_g_signed_byte "\0"
.var_g_signed_word "\0\0"
.var_g_byte_array "\0\0\0\0\0"
.var_g_word_array "\0\0\0\0\0\0"
.var_g_point "\0\0"
.var_total_tests "\0\0"
.var_failed_tests "\0\0"
.var_func_with_static_static_counter "\0"
