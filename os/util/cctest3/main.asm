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

:test_switch                     # void test_switch()
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
INCR_D                           # Load base address of sw_val at offset 1 into B
MOV_DH_BH                        # Load base address of sw_val at offset 1 into B
MOV_DL_BL                        # Load base address of sw_val at offset 1 into B
DECR_D                           # Load base address of sw_val at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char sw_val
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_val
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sw_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sw_val at offset 1 into B
MOV_DH_BH                        # Load base address of sw_val at offset 1 into B
MOV_DL_BL                        # Load base address of sw_val at offset 1 into B
DECR_D                           # Load base address of sw_val at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_BL 1                         # case 1
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_25              # Jump if match
LDI_BL 2                         # case 2
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_26              # Jump if match
LDI_BL 3                         # case 3
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_27              # Jump if match
JMP .switch_case_28              # Jump to default case
.switch_case_25                  # Case 1 begin
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char sw_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result
JMP .switch_end_24               # Break out of loop/switch
.case_end_29                     # Case 1 end
.switch_case_26                  # Case 2 begin
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char sw_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result
JMP .switch_end_24               # Break out of loop/switch
.case_end_30                     # Case 2 end
.switch_case_27                  # Case 3 begin
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 30                        # Constant assignment 30 for  unsigned char sw_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result
JMP .switch_end_24               # Break out of loop/switch
.case_end_31                     # Case 3 end
.switch_case_28                  # Case default begin
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 99                        # Constant assignment 99 for  unsigned char sw_result
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result
JMP .switch_end_24               # Break out of loop/switch
.case_end_32                     # Case default end
.switch_end_24                   # End switch
LDI_A .data_string_6             # "Switch case 2"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 20                        # Constant assignment 20 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sw_result at offset 2 into B
INCR_D                           # Load base address of sw_result at offset 2 into B
MOV_DH_BH                        # Load base address of sw_result at offset 2 into B
MOV_DL_BL                        # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
DECR_D                           # Load base address of sw_result at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of sw_val2 at offset 3 into B
INCR_D                           # Load base address of sw_val2 at offset 3 into B
INCR_D                           # Load base address of sw_val2 at offset 3 into B
MOV_DH_BH                        # Load base address of sw_val2 at offset 3 into B
MOV_DL_BL                        # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 99                        # Constant assignment 99 for  unsigned char sw_val2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_val2
INCR4_D                          # Load base address of sw_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of sw_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of sw_result2 at offset 4 into B
DECR4_D                          # Load base address of sw_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sw_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result2
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sw_val2 at offset 3 into B
INCR_D                           # Load base address of sw_val2 at offset 3 into B
INCR_D                           # Load base address of sw_val2 at offset 3 into B
MOV_DH_BH                        # Load base address of sw_val2 at offset 3 into B
MOV_DL_BL                        # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
DECR_D                           # Load base address of sw_val2 at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_BL 1                         # case 1
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_34              # Jump if match
LDI_BL 2                         # case 2
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_35              # Jump if match
JMP .switch_case_36              # Jump to default case
.switch_case_34                  # Case 1 begin
INCR4_D                          # Load base address of sw_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of sw_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of sw_result2 at offset 4 into B
DECR4_D                          # Load base address of sw_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char sw_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result2
JMP .switch_end_33               # Break out of loop/switch
.case_end_37                     # Case 1 end
.switch_case_35                  # Case 2 begin
INCR4_D                          # Load base address of sw_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of sw_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of sw_result2 at offset 4 into B
DECR4_D                          # Load base address of sw_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char sw_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result2
JMP .switch_end_33               # Break out of loop/switch
.case_end_38                     # Case 2 end
.switch_case_36                  # Case default begin
INCR4_D                          # Load base address of sw_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of sw_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of sw_result2 at offset 4 into B
DECR4_D                          # Load base address of sw_result2 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 77                        # Constant assignment 77 for  unsigned char sw_result2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result2
JMP .switch_end_33               # Break out of loop/switch
.case_end_39                     # Case default end
.switch_end_33                   # End switch
LDI_A .data_string_7             # "Switch default"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 77                        # Constant assignment 77 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_result2 at offset 4 into B
MOV_DH_BH                        # Load base address of sw_result2 at offset 4 into B
MOV_DL_BL                        # Load base address of sw_result2 at offset 4 into B
DECR4_D                          # Load base address of sw_result2 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of sw_val3 at offset 5 into B
INCR_D                           # Load base address of sw_val3 at offset 5 into B
MOV_DH_BH                        # Load base address of sw_val3 at offset 5 into B
MOV_DL_BL                        # Load base address of sw_val3 at offset 5 into B
DECR4_D                          # Load base address of sw_val3 at offset 5 into B
DECR_D                           # Load base address of sw_val3 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char sw_val3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_val3
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sw_result3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_val3 at offset 5 into B
INCR_D                           # Load base address of sw_val3 at offset 5 into B
MOV_DH_BH                        # Load base address of sw_val3 at offset 5 into B
MOV_DL_BL                        # Load base address of sw_val3 at offset 5 into B
DECR4_D                          # Load base address of sw_val3 at offset 5 into B
DECR_D                           # Load base address of sw_val3 at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_BL 1                         # case 1
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_41              # Jump if match
LDI_BL 2                         # case 2
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_42              # Jump if match
LDI_BL 3                         # case 3
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JEQ .switch_case_43              # Jump if match
JMP .switch_end_40               # No cases matched, and no default, exit switch
.switch_case_41                  # Case 1 begin
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 10                        # Constant assignment 10 for  unsigned char sw_result3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result3
.case_end_44                     # Case 1 end
.switch_case_42                  # Case 2 begin
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 20                        # Constant assignment 20 for  unsigned char sw_result3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result3
JMP .switch_end_40               # Break out of loop/switch
.case_end_45                     # Case 2 end
.switch_case_43                  # Case 3 begin
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 30                        # Constant assignment 30 for  unsigned char sw_result3
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result3
JMP .switch_end_40               # Break out of loop/switch
.case_end_46                     # Case 3 end
.switch_end_40                   # End switch
LDI_A .data_string_8             # "Switch fall-through"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
INCR_D                           # Load base address of sw_result3 at offset 6 into B
MOV_DH_BH                        # Load base address of sw_result3 at offset 6 into B
MOV_DL_BL                        # Load base address of sw_result3 at offset 6 into B
DECR4_D                          # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
DECR_D                           # Load base address of sw_result3 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
MOV_DH_BH                        # Load base address of sw_val16 at offset 7 into B
MOV_DL_BL                        # Load base address of sw_val16 at offset 7 into B
DECR4_D                          # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 512                        # Constant assignment 0x0200 for  unsigned short sw_val16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short sw_val16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short sw_val16
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short sw_val16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short sw_val16
INCR8_D                          # Load base address of sw_result16 at offset 9 into B
INCR_D                           # Load base address of sw_result16 at offset 9 into B
MOV_DH_BH                        # Load base address of sw_result16 at offset 9 into B
MOV_DL_BL                        # Load base address of sw_result16 at offset 9 into B
DECR8_D                          # Load base address of sw_result16 at offset 9 into B
DECR_D                           # Load base address of sw_result16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char sw_result16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
INCR_D                           # Load base address of sw_val16 at offset 7 into B
MOV_DH_BH                        # Load base address of sw_val16 at offset 7 into B
MOV_DL_BL                        # Load base address of sw_val16 at offset 7 into B
DECR4_D                          # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
DECR_D                           # Load base address of sw_val16 at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_B 256                        # case 0x0100
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JNE .switch_case_false_51        # Go to next case if no match
ALUOP_FLAGS %A&B%+%AH%+%BH%      # Check condition
JNE .switch_case_false_51        # Go to next case if no match
JMP .switch_case_48              # Jump if match
.switch_case_false_51            # Jump here if condidtion did not match
LDI_B 512                        # case 0x0200
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JNE .switch_case_false_52        # Go to next case if no match
ALUOP_FLAGS %A&B%+%AH%+%BH%      # Check condition
JNE .switch_case_false_52        # Go to next case if no match
JMP .switch_case_49              # Jump if match
.switch_case_false_52            # Jump here if condidtion did not match
LDI_B 768                        # case 0x0300
ALUOP_FLAGS %A&B%+%AL%+%BL%      # Check condition
JNE .switch_case_false_53        # Go to next case if no match
ALUOP_FLAGS %A&B%+%AH%+%BH%      # Check condition
JNE .switch_case_false_53        # Go to next case if no match
JMP .switch_case_50              # Jump if match
.switch_case_false_53            # Jump here if condidtion did not match
JMP .switch_end_47               # No cases matched, and no default, exit switch
.switch_case_48                  # Case 0x0100 begin
INCR8_D                          # Load base address of sw_result16 at offset 9 into B
INCR_D                           # Load base address of sw_result16 at offset 9 into B
MOV_DH_BH                        # Load base address of sw_result16 at offset 9 into B
MOV_DL_BL                        # Load base address of sw_result16 at offset 9 into B
DECR8_D                          # Load base address of sw_result16 at offset 9 into B
DECR_D                           # Load base address of sw_result16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char sw_result16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result16
JMP .switch_end_47               # Break out of loop/switch
.case_end_54                     # Case 0x0100 end
.switch_case_49                  # Case 0x0200 begin
INCR8_D                          # Load base address of sw_result16 at offset 9 into B
INCR_D                           # Load base address of sw_result16 at offset 9 into B
MOV_DH_BH                        # Load base address of sw_result16 at offset 9 into B
MOV_DL_BL                        # Load base address of sw_result16 at offset 9 into B
DECR8_D                          # Load base address of sw_result16 at offset 9 into B
DECR_D                           # Load base address of sw_result16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char sw_result16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result16
JMP .switch_end_47               # Break out of loop/switch
.case_end_55                     # Case 0x0200 end
.switch_case_50                  # Case 0x0300 begin
INCR8_D                          # Load base address of sw_result16 at offset 9 into B
INCR_D                           # Load base address of sw_result16 at offset 9 into B
MOV_DH_BH                        # Load base address of sw_result16 at offset 9 into B
MOV_DL_BL                        # Load base address of sw_result16 at offset 9 into B
DECR8_D                          # Load base address of sw_result16 at offset 9 into B
DECR_D                           # Load base address of sw_result16 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for  unsigned char sw_result16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sw_result16
JMP .switch_end_47               # Break out of loop/switch
.case_end_56                     # Case 0x0300 end
.switch_end_47                   # End switch
LDI_A .data_string_9             # "Switch 16-bit value"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of sw_result16 at offset 9 into B
INCR_D                           # Load base address of sw_result16 at offset 9 into B
MOV_DH_BH                        # Load base address of sw_result16 at offset 9 into B
MOV_DL_BL                        # Load base address of sw_result16 at offset 9 into B
DECR8_D                          # Load base address of sw_result16 at offset 9 into B
DECR_D                           # Load base address of sw_result16 at offset 9 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_switch_return_23
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

:test_sizeof                     # void test_sizeof()
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
LDI_BL 26                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of sz_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of sz_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of sz_u8 at offset 1 into B
DECR_D                           # Load base address of sz_u8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # sizeof type  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_u8
LDI_A .data_string_10            # "sizeof(uint8_t)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sz_u8 at offset 1 into B
MOV_DH_BH                        # Load base address of sz_u8 at offset 1 into B
MOV_DL_BL                        # Load base address of sz_u8 at offset 1 into B
DECR_D                           # Load base address of sz_u8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of sz_u16 at offset 2 into B
INCR_D                           # Load base address of sz_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of sz_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of sz_u16 at offset 2 into B
DECR_D                           # Load base address of sz_u16 at offset 2 into B
DECR_D                           # Load base address of sz_u16 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 2                          # sizeof type  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_u16
LDI_A .data_string_11            # "sizeof(uint16_t)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sz_u16 at offset 2 into B
INCR_D                           # Load base address of sz_u16 at offset 2 into B
MOV_DH_BH                        # Load base address of sz_u16 at offset 2 into B
MOV_DL_BL                        # Load base address of sz_u16 at offset 2 into B
DECR_D                           # Load base address of sz_u16 at offset 2 into B
DECR_D                           # Load base address of sz_u16 at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of var_u8 at offset 3 into B
INCR_D                           # Load base address of var_u8 at offset 3 into B
INCR_D                           # Load base address of var_u8 at offset 3 into B
MOV_DH_BH                        # Load base address of var_u8 at offset 3 into B
MOV_DL_BL                        # Load base address of var_u8 at offset 3 into B
DECR_D                           # Load base address of var_u8 at offset 3 into B
DECR_D                           # Load base address of var_u8 at offset 3 into B
DECR_D                           # Load base address of var_u8 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char var_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char var_u8
INCR4_D                          # Load base address of sz_var at offset 4 into B
MOV_DH_BH                        # Load base address of sz_var at offset 4 into B
MOV_DL_BL                        # Load base address of sz_var at offset 4 into B
DECR4_D                          # Load base address of sz_var at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1                          # sizeof var  unsigned char var_u8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_var
LDI_A .data_string_12            # "sizeof(variable)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of sz_var at offset 4 into B
MOV_DH_BH                        # Load base address of sz_var at offset 4 into B
MOV_DL_BL                        # Load base address of sz_var at offset 4 into B
DECR4_D                          # Load base address of sz_var at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_arr at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_arr at offset 15 into B
MOV_DH_BH                        # Load base address of sz_arr at offset 15 into B
MOV_DL_BL                        # Load base address of sz_arr at offset 15 into B
LDI_A 15                         # Load base address of sz_arr at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_arr at offset 15 into B
POP_AH                           # Load base address of sz_arr at offset 15 into B
POP_AL                           # Load base address of sz_arr at offset 15 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 10                         # sizeof var  unsigned char arr_sz[]
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_arr
LDI_A .data_string_13            # "sizeof(array)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_arr at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_arr at offset 15 into B
MOV_DH_BH                        # Load base address of sz_arr at offset 15 into B
MOV_DL_BL                        # Load base address of sz_arr at offset 15 into B
LDI_A 15                         # Load base address of sz_arr at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_arr at offset 15 into B
POP_AH                           # Load base address of sz_arr at offset 15 into B
POP_AL                           # Load base address of sz_arr at offset 15 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_struct at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_struct at offset 18 into B
MOV_DH_BH                        # Load base address of sz_struct at offset 18 into B
MOV_DL_BL                        # Load base address of sz_struct at offset 18 into B
LDI_A 18                         # Load base address of sz_struct at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_struct at offset 18 into B
POP_AH                           # Load base address of sz_struct at offset 18 into B
POP_AL                           # Load base address of sz_struct at offset 18 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 2                          # sizeof var  struct Point pt_sz
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_struct
LDI_A .data_string_14            # "sizeof(struct Point)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_struct at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_struct at offset 18 into B
MOV_DH_BH                        # Load base address of sz_struct at offset 18 into B
MOV_DL_BL                        # Load base address of sz_struct at offset 18 into B
LDI_A 18                         # Load base address of sz_struct at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_struct at offset 18 into B
POP_AH                           # Load base address of sz_struct at offset 18 into B
POP_AL                           # Load base address of sz_struct at offset 18 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_rect at offset 23 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_rect at offset 23 into B
MOV_DH_BH                        # Load base address of sz_rect at offset 23 into B
MOV_DL_BL                        # Load base address of sz_rect at offset 23 into B
LDI_A 23                         # Load base address of sz_rect at offset 23 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_rect at offset 23 into B
POP_AH                           # Load base address of sz_rect at offset 23 into B
POP_AL                           # Load base address of sz_rect at offset 23 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4                          # sizeof var  struct Rect rect_sz
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_rect
LDI_A .data_string_15            # "sizeof(struct Rect)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 4                         # Constant assignment 4 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_rect at offset 23 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_rect at offset 23 into B
MOV_DH_BH                        # Load base address of sz_rect at offset 23 into B
MOV_DL_BL                        # Load base address of sz_rect at offset 23 into B
LDI_A 23                         # Load base address of sz_rect at offset 23 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_rect at offset 23 into B
POP_AH                           # Load base address of sz_rect at offset 23 into B
POP_AL                           # Load base address of sz_rect at offset 23 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_sz at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_sz at offset 24 into B
MOV_DH_BH                        # Load base address of ptr_sz at offset 24 into B
MOV_DL_BL                        # Load base address of ptr_sz at offset 24 into B
LDI_A 24                         # Load base address of ptr_sz at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_sz at offset 24 into B
POP_AH                           # Load base address of ptr_sz at offset 24 into B
POP_AL                           # Load base address of ptr_sz at offset 24 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for pointer  unsigned char *ptr_sz
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_sz
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_sz
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_sz
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_sz
ALUOP_PUSH %A%+%AL%              # Load base address of sz_ptr at offset 26 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_ptr at offset 26 into B
MOV_DH_BH                        # Load base address of sz_ptr at offset 26 into B
MOV_DL_BL                        # Load base address of sz_ptr at offset 26 into B
LDI_A 26                         # Load base address of sz_ptr at offset 26 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_ptr at offset 26 into B
POP_AH                           # Load base address of sz_ptr at offset 26 into B
POP_AL                           # Load base address of sz_ptr at offset 26 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 2                          # sizeof var  unsigned char *ptr_sz
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char sz_ptr
LDI_A .data_string_16            # "sizeof(pointer)"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of sz_ptr at offset 26 into B
ALUOP_PUSH %A%+%AH%              # Load base address of sz_ptr at offset 26 into B
MOV_DH_BH                        # Load base address of sz_ptr at offset 26 into B
MOV_DL_BL                        # Load base address of sz_ptr at offset 26 into B
LDI_A 26                         # Load base address of sz_ptr at offset 26 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of sz_ptr at offset 26 into B
POP_AH                           # Load base address of sz_ptr at offset 26 into B
POP_AL                           # Load base address of sz_ptr at offset 26 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_sizeof_return_57
LDI_BL 26                        # Bytes to free from local vars and parameters
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

:test_cast                       # void test_cast()
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
INCR_D                           # Load base address of val8 at offset 1 into B
MOV_DH_BH                        # Load base address of val8 at offset 1 into B
MOV_DL_BL                        # Load base address of val8 at offset 1 into B
DECR_D                           # Load base address of val8 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 200                       # Constant assignment 200 for  unsigned char val8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char val8
INCR_D                           # Load base address of val16_from8 at offset 2 into B
INCR_D                           # Load base address of val16_from8 at offset 2 into B
MOV_DH_BH                        # Load base address of val16_from8 at offset 2 into B
MOV_DL_BL                        # Load base address of val16_from8 at offset 2 into B
DECR_D                           # Load base address of val16_from8 at offset 2 into B
DECR_D                           # Load base address of val16_from8 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of val8 at offset 1 into B
MOV_DH_BH                        # Load base address of val8 at offset 1 into B
MOV_DL_BL                        # Load base address of val8 at offset 1 into B
DECR_D                           # Load base address of val8 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
# Cast  unsigned char val8 to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short val16_from8
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short val16_from8
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short val16_from8
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short val16_from8
LDI_A .data_string_17            # "Cast uint8_t to uint16_t"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 200                        # Constant assignment 200 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of val16_from8 at offset 2 into B
INCR_D                           # Load base address of val16_from8 at offset 2 into B
MOV_DH_BH                        # Load base address of val16_from8 at offset 2 into B
MOV_DL_BL                        # Load base address of val16_from8 at offset 2 into B
DECR_D                           # Load base address of val16_from8 at offset 2 into B
DECR_D                           # Load base address of val16_from8 at offset 2 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of val16b at offset 4 into B
MOV_DH_BH                        # Load base address of val16b at offset 4 into B
MOV_DL_BL                        # Load base address of val16b at offset 4 into B
DECR4_D                          # Load base address of val16b at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4660                       # Constant assignment 0x1234 for  unsigned short val16b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short val16b
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short val16b
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short val16b
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short val16b
INCR4_D                          # Load base address of val8_from16 at offset 6 into B
INCR_D                           # Load base address of val8_from16 at offset 6 into B
INCR_D                           # Load base address of val8_from16 at offset 6 into B
MOV_DH_BH                        # Load base address of val8_from16 at offset 6 into B
MOV_DL_BL                        # Load base address of val8_from16 at offset 6 into B
DECR4_D                          # Load base address of val8_from16 at offset 6 into B
DECR_D                           # Load base address of val8_from16 at offset 6 into B
DECR_D                           # Load base address of val8_from16 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of val16b at offset 4 into B
MOV_DH_BH                        # Load base address of val16b at offset 4 into B
MOV_DL_BL                        # Load base address of val16b at offset 4 into B
DECR4_D                          # Load base address of val16b at offset 4 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
# Cast  unsigned short val16b to  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char val8_from16
LDI_A .data_string_18            # "Cast uint16_t to uint8_t"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 52                        # Constant assignment 0x34 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of val8_from16 at offset 6 into B
INCR_D                           # Load base address of val8_from16 at offset 6 into B
INCR_D                           # Load base address of val8_from16 at offset 6 into B
MOV_DH_BH                        # Load base address of val8_from16 at offset 6 into B
MOV_DL_BL                        # Load base address of val8_from16 at offset 6 into B
DECR4_D                          # Load base address of val8_from16 at offset 6 into B
DECR_D                           # Load base address of val8_from16 at offset 6 into B
DECR_D                           # Load base address of val8_from16 at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of val_for_ptr at offset 7 into B
INCR_D                           # Load base address of val_for_ptr at offset 7 into B
INCR_D                           # Load base address of val_for_ptr at offset 7 into B
INCR_D                           # Load base address of val_for_ptr at offset 7 into B
MOV_DH_BH                        # Load base address of val_for_ptr at offset 7 into B
MOV_DL_BL                        # Load base address of val_for_ptr at offset 7 into B
DECR4_D                          # Load base address of val_for_ptr at offset 7 into B
DECR_D                           # Load base address of val_for_ptr at offset 7 into B
DECR_D                           # Load base address of val_for_ptr at offset 7 into B
DECR_D                           # Load base address of val_for_ptr at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 42                        # Constant assignment 42 for  unsigned char val_for_ptr
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char val_for_ptr
INCR8_D                          # Load base address of ptr_from_cast at offset 8 into B
MOV_DH_BH                        # Load base address of ptr_from_cast at offset 8 into B
MOV_DL_BL                        # Load base address of ptr_from_cast at offset 8 into B
DECR8_D                          # Load base address of ptr_from_cast at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR4_D                          # Load base address of val_for_ptr at offset 7 into A
INCR_D                           # Load base address of val_for_ptr at offset 7 into A
INCR_D                           # Load base address of val_for_ptr at offset 7 into A
INCR_D                           # Load base address of val_for_ptr at offset 7 into A
MOV_DH_AH                        # Load base address of val_for_ptr at offset 7 into A
MOV_DL_AL                        # Load base address of val_for_ptr at offset 7 into A
DECR4_D                          # Load base address of val_for_ptr at offset 7 into A
DECR_D                           # Load base address of val_for_ptr at offset 7 into A
DECR_D                           # Load base address of val_for_ptr at offset 7 into A
DECR_D                           # Load base address of val_for_ptr at offset 7 into A
# Cast  unsigned char *ptr_to_val_for_ptr (virtual) to  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_from_cast
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_from_cast
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_from_cast
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_from_cast
LDI_A .data_string_19            # "Cast to pointer"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR8_D                          # Load base address of ptr_from_cast at offset 8 into A
MOV_DH_AH                        # Load base address of ptr_from_cast at offset 8 into A
MOV_DL_AL                        # Load base address of ptr_from_cast at offset 8 into A
DECR8_D                          # Load base address of ptr_from_cast at offset 8 into A
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
.test_cast_return_58
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
JMP .add_u8_return_59
.add_u8_return_59
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
JMP .add_u16_return_60
.add_u16_return_60
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
JMP .mixed_params_return_61
.mixed_params_return_61
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
.modify_by_ptr_return_62
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
.modify_point_return_63
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
.for_condition_65                # For loop condition check
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
JEQ .binaryop_equal_70           # BinaryOp <: check if equal
LDI_AL 1                         # BinaryOp <: assume true
JNO .binaryop_done_71            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_AL 0                         # BinaryOp <: overflow, so false
JMP .binaryop_done_71
.binaryop_equal_70
LDI_AL 0                         # BinaryOp <: operands equal: false
.binaryop_done_71
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_67            # Condition was true
JMP .for_end_69                  # Condition was false, end loop
.for_cond_true_67                # Begin for loop body
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
.for_increment_66                # Begin for loop increment
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
JMP .for_condition_65            # Next for loop iteration
.for_end_69                      # End for loop
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of sum_result at offset 1 into B
MOV_DH_BH                        # Load base address of sum_result at offset 1 into B
MOV_DL_BL                        # Load base address of sum_result at offset 1 into B
DECR_D                           # Load base address of sum_result at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
JMP .sum_array_return_64
.sum_array_return_64
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
.void_function_return_74
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
JMP .func_with_locals_return_75
.func_with_locals_return_75
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
JMP .func_with_static_return_76
.func_with_static_return_76
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

:test_functions                  # void test_functions()
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
INCR_D                           # Load base address of func_result1 at offset 1 into B
MOV_DH_BH                        # Load base address of func_result1 at offset 1 into B
MOV_DL_BL                        # Load base address of func_result1 at offset 1 into B
DECR_D                           # Load base address of func_result1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char b_param
CALL :heap_push_AL               # Push parameter  unsigned char b_param
LDI_AL 10                        # Constant assignment 10 for  unsigned char a_param
CALL :heap_push_AL               # Push parameter  unsigned char a_param
CALL :add_u8
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char func_result1
LDI_A .data_string_20            # "Function call 8-bit"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of func_result1 at offset 1 into B
MOV_DH_BH                        # Load base address of func_result1 at offset 1 into B
MOV_DL_BL                        # Load base address of func_result1 at offset 1 into B
DECR_D                           # Load base address of func_result1 at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of func_result2 at offset 2 into B
INCR_D                           # Load base address of func_result2 at offset 2 into B
MOV_DH_BH                        # Load base address of func_result2 at offset 2 into B
MOV_DL_BL                        # Load base address of func_result2 at offset 2 into B
DECR_D                           # Load base address of func_result2 at offset 2 into B
DECR_D                           # Load base address of func_result2 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 2000                       # Constant assignment 2000 for  unsigned short b16_param
CALL :heap_push_A                # Push parameter  unsigned short b16_param
LDI_A 1000                       # Constant assignment 1000 for  unsigned short a16_param
CALL :heap_push_A                # Push parameter  unsigned short a16_param
CALL :add_u16
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short func_result2
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short func_result2
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short func_result2
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short func_result2
LDI_A .data_string_21            # "Function call 16-bit"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 3000                       # Constant assignment 3000 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of func_result2 at offset 2 into B
INCR_D                           # Load base address of func_result2 at offset 2 into B
MOV_DH_BH                        # Load base address of func_result2 at offset 2 into B
MOV_DL_BL                        # Load base address of func_result2 at offset 2 into B
DECR_D                           # Load base address of func_result2 at offset 2 into B
DECR_D                           # Load base address of func_result2 at offset 2 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of func_result3 at offset 4 into B
MOV_DH_BH                        # Load base address of func_result3 at offset 4 into B
MOV_DL_BL                        # Load base address of func_result3 at offset 4 into B
DECR4_D                          # Load base address of func_result3 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 1000                       # Constant assignment 1000 for  unsigned short word_param
CALL :heap_push_A                # Push parameter  unsigned short word_param
LDI_AL 50                        # Constant assignment 50 for  unsigned char byte_param
CALL :heap_push_AL               # Push parameter  unsigned char byte_param
CALL :mixed_params
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short func_result3
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short func_result3
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short func_result3
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short func_result3
LDI_A .data_string_22            # "Function mixed params"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 1050                       # Constant assignment 1050 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of func_result3 at offset 4 into B
MOV_DH_BH                        # Load base address of func_result3 at offset 4 into B
MOV_DL_BL                        # Load base address of func_result3 at offset 4 into B
DECR4_D                          # Load base address of func_result3 at offset 4 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of mod_val at offset 6 into B
INCR_D                           # Load base address of mod_val at offset 6 into B
INCR_D                           # Load base address of mod_val at offset 6 into B
MOV_DH_BH                        # Load base address of mod_val at offset 6 into B
MOV_DL_BL                        # Load base address of mod_val at offset 6 into B
DECR4_D                          # Load base address of mod_val at offset 6 into B
DECR_D                           # Load base address of mod_val at offset 6 into B
DECR_D                           # Load base address of mod_val at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 15                        # Constant assignment 15 for  unsigned char mod_val
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char mod_val
INCR4_D                          # Load base address of mod_val at offset 6 into A
INCR_D                           # Load base address of mod_val at offset 6 into A
INCR_D                           # Load base address of mod_val at offset 6 into A
MOV_DH_AH                        # Load base address of mod_val at offset 6 into A
MOV_DL_AL                        # Load base address of mod_val at offset 6 into A
DECR4_D                          # Load base address of mod_val at offset 6 into A
DECR_D                           # Load base address of mod_val at offset 6 into A
DECR_D                           # Load base address of mod_val at offset 6 into A
CALL :heap_push_A                # Push parameter  unsigned char *ptr_param (pointer)
CALL :modify_by_ptr
# function returns nothing, not popping a return value
LDI_A .data_string_23            # "Function pointer param"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 25                        # Constant assignment 25 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of mod_val at offset 6 into B
INCR_D                           # Load base address of mod_val at offset 6 into B
INCR_D                           # Load base address of mod_val at offset 6 into B
MOV_DH_BH                        # Load base address of mod_val at offset 6 into B
MOV_DL_BL                        # Load base address of mod_val at offset 6 into B
DECR4_D                          # Load base address of mod_val at offset 6 into B
DECR_D                           # Load base address of mod_val at offset 6 into B
DECR_D                           # Load base address of mod_val at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
MOV_DH_BH                        # Load base address of pt_func at offset 7 into B
MOV_DL_BL                        # Load base address of pt_func at offset 7 into B
DECR4_D                          # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char x
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char x
INCR4_D                          # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
INCR_D                           # Load base address of pt_func at offset 7 into B
MOV_DH_BH                        # Load base address of pt_func at offset 7 into B
MOV_DL_BL                        # Load base address of pt_func at offset 7 into B
DECR4_D                          # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
DECR_D                           # Load base address of pt_func at offset 7 into B
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
INCR4_D                          # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
MOV_DH_AH                        # Load base address of pt_func at offset 7 into A
MOV_DL_AL                        # Load base address of pt_func at offset 7 into A
DECR4_D                          # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
CALL :heap_push_A                # Push parameter  struct Point *pt_param (pointer)
CALL :modify_point
# function returns nothing, not popping a return value
LDI_A .data_string_24            # "Function struct param .x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 11                        # Constant assignment 11 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR4_D                          # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
MOV_DH_AH                        # Load base address of pt_func at offset 7 into A
MOV_DL_AL                        # Load base address of pt_func at offset 7 into A
DECR4_D                          # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_25            # "Function struct param .y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 21                        # Constant assignment 21 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
INCR4_D                          # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
INCR_D                           # Load base address of pt_func at offset 7 into A
MOV_DH_AH                        # Load base address of pt_func at offset 7 into A
MOV_DL_AL                        # Load base address of pt_func at offset 7 into A
DECR4_D                          # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
DECR_D                           # Load base address of pt_func at offset 7 into A
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
INCR8_D                          # Load base address of test_arr at offset 9 into B
INCR_D                           # Load base address of test_arr at offset 9 into B
MOV_DH_BH                        # Load base address of test_arr at offset 9 into B
MOV_DL_BL                        # Load base address of test_arr at offset 9 into B
DECR8_D                          # Load base address of test_arr at offset 9 into B
DECR_D                           # Load base address of test_arr at offset 9 into B
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
ALUOP_PUSH %A%+%AL%              # Load base address of arr_sum at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of arr_sum at offset 14 into B
MOV_DH_BH                        # Load base address of arr_sum at offset 14 into B
MOV_DL_BL                        # Load base address of arr_sum at offset 14 into B
LDI_A 14                         # Load base address of arr_sum at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of arr_sum at offset 14 into B
POP_AH                           # Load base address of arr_sum at offset 14 into B
POP_AL                           # Load base address of arr_sum at offset 14 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for  unsigned char len
CALL :heap_push_AL               # Push parameter  unsigned char len
INCR8_D                          # Load base address of test_arr at offset 9 into A
INCR_D                           # Load base address of test_arr at offset 9 into A
MOV_DH_AH                        # Load base address of test_arr at offset 9 into A
MOV_DL_AL                        # Load base address of test_arr at offset 9 into A
DECR8_D                          # Load base address of test_arr at offset 9 into A
DECR_D                           # Load base address of test_arr at offset 9 into A
CALL :heap_push_A                # Push parameter  unsigned char *arr_param (pointer)
CALL :sum_array
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char arr_sum
LDI_A .data_string_26            # "Function array param"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 15                        # Constant assignment 15 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of arr_sum at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of arr_sum at offset 14 into B
MOV_DH_BH                        # Load base address of arr_sum at offset 14 into B
MOV_DL_BL                        # Load base address of arr_sum at offset 14 into B
LDI_A 14                         # Load base address of arr_sum at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of arr_sum at offset 14 into B
POP_AH                           # Load base address of arr_sum at offset 14 into B
POP_AL                           # Load base address of arr_sum at offset 14 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_B .var_g_byte                # Load base address of g_byte into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char g_byte
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char g_byte
CALL :void_function
# function returns nothing, not popping a return value
LDI_A .data_string_27            # "Void function"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 123                       # Constant assignment 123 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_byte                # Load base address of g_byte into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of locals_result at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of locals_result at offset 15 into B
MOV_DH_BH                        # Load base address of locals_result at offset 15 into B
MOV_DL_BL                        # Load base address of locals_result at offset 15 into B
LDI_A 15                         # Load base address of locals_result at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of locals_result at offset 15 into B
POP_AH                           # Load base address of locals_result at offset 15 into B
POP_AL                           # Load base address of locals_result at offset 15 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char param2
CALL :heap_push_AL               # Push parameter  unsigned char param2
LDI_AL 5                         # Constant assignment 5 for  unsigned char param1
CALL :heap_push_AL               # Push parameter  unsigned char param1
CALL :func_with_locals
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char locals_result
LDI_A .data_string_28            # "Function with locals"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of locals_result at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of locals_result at offset 15 into B
MOV_DH_BH                        # Load base address of locals_result at offset 15 into B
MOV_DL_BL                        # Load base address of locals_result at offset 15 into B
LDI_A 15                         # Load base address of locals_result at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of locals_result at offset 15 into B
POP_AH                           # Load base address of locals_result at offset 15 into B
POP_AL                           # Load base address of locals_result at offset 15 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of static1 at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static1 at offset 16 into B
MOV_DH_BH                        # Load base address of static1 at offset 16 into B
MOV_DL_BL                        # Load base address of static1 at offset 16 into B
LDI_A 16                         # Load base address of static1 at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static1 at offset 16 into B
POP_AH                           # Load base address of static1 at offset 16 into B
POP_AL                           # Load base address of static1 at offset 16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL :func_with_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char static1
ALUOP_PUSH %A%+%AL%              # Load base address of static2 at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static2 at offset 17 into B
MOV_DH_BH                        # Load base address of static2 at offset 17 into B
MOV_DL_BL                        # Load base address of static2 at offset 17 into B
LDI_A 17                         # Load base address of static2 at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static2 at offset 17 into B
POP_AH                           # Load base address of static2 at offset 17 into B
POP_AL                           # Load base address of static2 at offset 17 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL :func_with_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char static2
ALUOP_PUSH %A%+%AL%              # Load base address of static3 at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static3 at offset 18 into B
MOV_DH_BH                        # Load base address of static3 at offset 18 into B
MOV_DL_BL                        # Load base address of static3 at offset 18 into B
LDI_A 18                         # Load base address of static3 at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static3 at offset 18 into B
POP_AH                           # Load base address of static3 at offset 18 into B
POP_AL                           # Load base address of static3 at offset 18 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL :func_with_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char static3
LDI_A .data_string_29            # "Static local call 1"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of static1 at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static1 at offset 16 into B
MOV_DH_BH                        # Load base address of static1 at offset 16 into B
MOV_DL_BL                        # Load base address of static1 at offset 16 into B
LDI_A 16                         # Load base address of static1 at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static1 at offset 16 into B
POP_AH                           # Load base address of static1 at offset 16 into B
POP_AL                           # Load base address of static1 at offset 16 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_30            # "Static local call 2"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of static2 at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static2 at offset 17 into B
MOV_DH_BH                        # Load base address of static2 at offset 17 into B
MOV_DL_BL                        # Load base address of static2 at offset 17 into B
LDI_A 17                         # Load base address of static2 at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static2 at offset 17 into B
POP_AH                           # Load base address of static2 at offset 17 into B
POP_AL                           # Load base address of static2 at offset 17 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_31            # "Static local call 3"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 3                         # Constant assignment 3 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of static3 at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of static3 at offset 18 into B
MOV_DH_BH                        # Load base address of static3 at offset 18 into B
MOV_DL_BL                        # Load base address of static3 at offset 18 into B
LDI_A 18                         # Load base address of static3 at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of static3 at offset 18 into B
POP_AH                           # Load base address of static3 at offset 18 into B
POP_AL                           # Load base address of static3 at offset 18 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_functions_return_77
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

:set_globals                     # void set_globals()
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
.set_globals_return_78
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:test_globals                    # void test_globals()
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
CALL :set_globals
# function returns nothing, not popping a return value
LDI_A .data_string_32            # "Global byte read"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 42                        # Constant assignment 42 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_byte                # Load base address of g_byte into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_33            # "Global word read"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 4660                       # Constant assignment 0x1234 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_word                # Load base address of g_word into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_34            # "Global signed byte read"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL -5                        # Load constant value, inverted 5
CALL :heap_push_AL               # Push parameter  signed char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_signed_byte         # Load base address of g_signed_byte into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  signed char actual
CALL :assert_equal_i8
# function returns nothing, not popping a return value
LDI_A .data_string_35            # "Global signed word read"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A -1000                      # Load constant value, inverted 1000
CALL :heap_push_A                # Push parameter  signed short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_signed_word         # Load base address of g_signed_word into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  signed short actual
CALL :assert_equal_i16
# function returns nothing, not popping a return value
LDI_B .var_g_byte                # Load base address of g_byte into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 99                        # Constant assignment 99 for  unsigned char g_byte
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char g_byte
LDI_A .data_string_36            # "Global byte write"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 99                        # Constant assignment 99 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_byte                # Load base address of g_byte into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_B .var_g_word                # Load base address of g_word into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 43981                      # Constant assignment 0xABCD for  unsigned short g_word
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short g_word
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short g_word
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short g_word
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short g_word
LDI_A .data_string_37            # "Global word write"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 43981                      # Constant assignment 0xABCD for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_word                # Load base address of g_word into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_equal_u16
# function returns nothing, not popping a return value
LDI_A .data_string_38            # "Global array [0]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
LDI_B .var_g_byte_array          # Load base address of g_byte_array into B
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
LDI_A .data_string_39            # "Global array [4]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 5                         # Constant assignment 5 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
LDI_B .var_g_byte_array          # Load base address of g_byte_array into B
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
LDI_A .data_string_40            # "Global word array [1]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_A 200                        # Constant assignment 200 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
LDI_B .var_g_word_array          # Load base address of g_word_array into B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 1                          # Constant assignment 1 as int
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
LDI_A .data_string_41            # "Global struct .x"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
LDI_A .var_g_point               # Load base address of g_point into A
ALUOP_PUSH %B%+%BL%              # StructRef member value: Save B
LDA_A_BL                         # Dereferenced load
ALUOP_AL %B%+%BL%                # Transfer value
POP_BL                           # StructRef member value: Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_42            # "Global struct .y"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 20                        # Constant assignment 20 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
LDI_A .var_g_point               # Load base address of g_point into A
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
.test_globals_return_79
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:test_scopes                     # void test_scopes()
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
INCR_D                           # Load base address of outer_var at offset 1 into B
MOV_DH_BH                        # Load base address of outer_var at offset 1 into B
MOV_DL_BL                        # Load base address of outer_var at offset 1 into B
DECR_D                           # Load base address of outer_var at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char outer_var
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char outer_var
INCR_D                           # Load base address of inner_var at offset 2 into B
INCR_D                           # Load base address of inner_var at offset 2 into B
MOV_DH_BH                        # Load base address of inner_var at offset 2 into B
MOV_DL_BL                        # Load base address of inner_var at offset 2 into B
DECR_D                           # Load base address of inner_var at offset 2 into B
DECR_D                           # Load base address of inner_var at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char inner_var
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char inner_var
INCR_D                           # Load base address of outer_var at offset 1 into B
MOV_DH_BH                        # Load base address of outer_var at offset 1 into B
MOV_DL_BL                        # Load base address of outer_var at offset 1 into B
DECR_D                           # Load base address of outer_var at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of inner_var at offset 2 into A
INCR_D                           # Load base address of inner_var at offset 2 into A
MOV_DH_AH                        # Load base address of inner_var at offset 2 into A
MOV_DL_AL                        # Load base address of inner_var at offset 2 into A
DECR_D                           # Load base address of inner_var at offset 2 into A
DECR_D                           # Load base address of inner_var at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of outer_var at offset 1 into B
MOV_DH_BH                        # Load base address of outer_var at offset 1 into B
MOV_DL_BL                        # Load base address of outer_var at offset 1 into B
DECR_D                           # Load base address of outer_var at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char outer_var
LDI_A .data_string_43            # "Scoped variable access"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of outer_var at offset 1 into B
MOV_DH_BH                        # Load base address of outer_var at offset 1 into B
MOV_DL_BL                        # Load base address of outer_var at offset 1 into B
DECR_D                           # Load base address of outer_var at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
MOV_DH_BH                        # Load base address of scope_sum at offset 3 into B
MOV_DL_BL                        # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char scope_sum
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char scope_sum
INCR4_D                          # Load base address of level1 at offset 4 into B
MOV_DH_BH                        # Load base address of level1 at offset 4 into B
MOV_DL_BL                        # Load base address of level1 at offset 4 into B
DECR4_D                          # Load base address of level1 at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for  unsigned char level1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char level1
INCR4_D                          # Load base address of level2 at offset 5 into B
INCR_D                           # Load base address of level2 at offset 5 into B
MOV_DH_BH                        # Load base address of level2 at offset 5 into B
MOV_DL_BL                        # Load base address of level2 at offset 5 into B
DECR4_D                          # Load base address of level2 at offset 5 into B
DECR_D                           # Load base address of level2 at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char level2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char level2
INCR4_D                          # Load base address of level3 at offset 6 into B
INCR_D                           # Load base address of level3 at offset 6 into B
INCR_D                           # Load base address of level3 at offset 6 into B
MOV_DH_BH                        # Load base address of level3 at offset 6 into B
MOV_DL_BL                        # Load base address of level3 at offset 6 into B
DECR4_D                          # Load base address of level3 at offset 6 into B
DECR_D                           # Load base address of level3 at offset 6 into B
DECR_D                           # Load base address of level3 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 15                        # Constant assignment 15 for  unsigned char level3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char level3
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
MOV_DH_BH                        # Load base address of scope_sum at offset 3 into B
MOV_DL_BL                        # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of level3 at offset 6 into A
INCR_D                           # Load base address of level3 at offset 6 into A
INCR_D                           # Load base address of level3 at offset 6 into A
MOV_DH_AH                        # Load base address of level3 at offset 6 into A
MOV_DL_AL                        # Load base address of level3 at offset 6 into A
DECR4_D                          # Load base address of level3 at offset 6 into A
DECR_D                           # Load base address of level3 at offset 6 into A
DECR_D                           # Load base address of level3 at offset 6 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of level2 at offset 5 into A
INCR_D                           # Load base address of level2 at offset 5 into A
MOV_DH_AH                        # Load base address of level2 at offset 5 into A
MOV_DL_AL                        # Load base address of level2 at offset 5 into A
DECR4_D                          # Load base address of level2 at offset 5 into A
DECR_D                           # Load base address of level2 at offset 5 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of level1 at offset 4 into B
MOV_DH_BH                        # Load base address of level1 at offset 4 into B
MOV_DL_BL                        # Load base address of level1 at offset 4 into B
DECR4_D                          # Load base address of level1 at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char scope_sum
LDI_A .data_string_44            # "Nested scopes"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
INCR_D                           # Load base address of scope_sum at offset 3 into B
MOV_DH_BH                        # Load base address of scope_sum at offset 3 into B
MOV_DL_BL                        # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
DECR_D                           # Load base address of scope_sum at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_scopes_return_80
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

:test_comma_operator             # void test_comma_operator()
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
INCR_D                           # Load base address of comma_a at offset 1 into B
MOV_DH_BH                        # Load base address of comma_a at offset 1 into B
MOV_DL_BL                        # Load base address of comma_a at offset 1 into B
DECR_D                           # Load base address of comma_a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char comma_a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_a
INCR_D                           # Load base address of comma_b at offset 2 into B
INCR_D                           # Load base address of comma_b at offset 2 into B
MOV_DH_BH                        # Load base address of comma_b at offset 2 into B
MOV_DL_BL                        # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char comma_b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_b
INCR_D                           # Load base address of comma_result at offset 3 into B
INCR_D                           # Load base address of comma_result at offset 3 into B
INCR_D                           # Load base address of comma_result at offset 3 into B
MOV_DH_BH                        # Load base address of comma_result at offset 3 into B
MOV_DL_BL                        # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of comma_a at offset 1 into B
MOV_DH_BH                        # Load base address of comma_a at offset 1 into B
MOV_DL_BL                        # Load base address of comma_a at offset 1 into B
DECR_D                           # Load base address of comma_a at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char comma_a
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_a
INCR_D                           # Load base address of comma_b at offset 2 into B
INCR_D                           # Load base address of comma_b at offset 2 into B
MOV_DH_BH                        # Load base address of comma_b at offset 2 into B
MOV_DL_BL                        # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char comma_b
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_b
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR_D                           # Load base address of comma_b at offset 2 into A
INCR_D                           # Load base address of comma_b at offset 2 into A
MOV_DH_AH                        # Load base address of comma_b at offset 2 into A
MOV_DL_AL                        # Load base address of comma_b at offset 2 into A
DECR_D                           # Load base address of comma_b at offset 2 into A
DECR_D                           # Load base address of comma_b at offset 2 into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of comma_a at offset 1 into B
MOV_DH_BH                        # Load base address of comma_a at offset 1 into B
MOV_DL_BL                        # Load base address of comma_a at offset 1 into B
DECR_D                           # Load base address of comma_a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_result
LDI_A .data_string_45            # "Comma operator side effect 1"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of comma_a at offset 1 into B
MOV_DH_BH                        # Load base address of comma_a at offset 1 into B
MOV_DL_BL                        # Load base address of comma_a at offset 1 into B
DECR_D                           # Load base address of comma_a at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_46            # "Comma operator side effect 2"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 20                        # Constant assignment 20 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of comma_b at offset 2 into B
INCR_D                           # Load base address of comma_b at offset 2 into B
MOV_DH_BH                        # Load base address of comma_b at offset 2 into B
MOV_DL_BL                        # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
DECR_D                           # Load base address of comma_b at offset 2 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_47            # "Comma operator result"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 30                        # Constant assignment 30 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of comma_result at offset 3 into B
INCR_D                           # Load base address of comma_result at offset 3 into B
INCR_D                           # Load base address of comma_result at offset 3 into B
MOV_DH_BH                        # Load base address of comma_result at offset 3 into B
MOV_DL_BL                        # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
DECR_D                           # Load base address of comma_result at offset 3 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
MOV_DH_BH                        # Load base address of comma_count at offset 6 into B
MOV_DL_BL                        # Load base address of comma_count at offset 6 into B
DECR4_D                          # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char comma_count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_count
INCR4_D                          # Load base address of comma_i at offset 4 into B
MOV_DH_BH                        # Load base address of comma_i at offset 4 into B
MOV_DL_BL                        # Load base address of comma_i at offset 4 into B
DECR4_D                          # Load base address of comma_i at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char comma_i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_i
INCR4_D                          # Load base address of comma_j at offset 5 into B
INCR_D                           # Load base address of comma_j at offset 5 into B
MOV_DH_BH                        # Load base address of comma_j at offset 5 into B
MOV_DL_BL                        # Load base address of comma_j at offset 5 into B
DECR4_D                          # Load base address of comma_j at offset 5 into B
DECR_D                           # Load base address of comma_j at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char comma_j
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_j
.for_condition_82                # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_i at offset 4 into B
MOV_DH_BH                        # Load base address of comma_i at offset 4 into B
MOV_DL_BL                        # Load base address of comma_i at offset 4 into B
DECR4_D                          # Load base address of comma_i at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_89       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_90         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_87           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_88             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_88            # Signed BinaryOp <: Signs were different
.binaryop_equal_87
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_88
.binaryop_overflow_90
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_88
.binaryop_diffsigns_89
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_88            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_88
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JNZ .for_cond_true_84            # Condition was true
JMP .for_end_86                  # Condition was false, end loop
.for_cond_true_84                # Begin for loop body
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
MOV_DH_BH                        # Load base address of comma_count at offset 6 into B
MOV_DL_BL                        # Load base address of comma_count at offset 6 into B
DECR4_D                          # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
MOV_DH_BH                        # Load base address of comma_count at offset 6 into B
MOV_DL_BL                        # Load base address of comma_count at offset 6 into B
DECR4_D                          # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_count
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
.for_increment_83                # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_i at offset 4 into B
MOV_DH_BH                        # Load base address of comma_i at offset 4 into B
MOV_DL_BL                        # Load base address of comma_i at offset 4 into B
DECR4_D                          # Load base address of comma_i at offset 4 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of comma_i at offset 4 into B
MOV_DH_BH                        # Load base address of comma_i at offset 4 into B
MOV_DL_BL                        # Load base address of comma_i at offset 4 into B
DECR4_D                          # Load base address of comma_i at offset 4 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_j at offset 5 into B
INCR_D                           # Load base address of comma_j at offset 5 into B
MOV_DH_BH                        # Load base address of comma_j at offset 5 into B
MOV_DL_BL                        # Load base address of comma_j at offset 5 into B
DECR4_D                          # Load base address of comma_j at offset 5 into B
DECR_D                           # Load base address of comma_j at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of comma_j at offset 5 into B
INCR_D                           # Load base address of comma_j at offset 5 into B
MOV_DH_BH                        # Load base address of comma_j at offset 5 into B
MOV_DL_BL                        # Load base address of comma_j at offset 5 into B
DECR4_D                          # Load base address of comma_j at offset 5 into B
DECR_D                           # Load base address of comma_j at offset 5 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char comma_j
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_82            # Next for loop iteration
.for_end_86                      # End for loop
LDI_A .data_string_48            # "Comma in for loop"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 3                         # Constant assignment 3 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
INCR_D                           # Load base address of comma_count at offset 6 into B
MOV_DH_BH                        # Load base address of comma_count at offset 6 into B
MOV_DL_BL                        # Load base address of comma_count at offset 6 into B
DECR4_D                          # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
DECR_D                           # Load base address of comma_count at offset 6 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_49            # "Comma in for increment"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 3                         # Constant assignment 3 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of comma_j at offset 5 into B
INCR_D                           # Load base address of comma_j at offset 5 into B
MOV_DH_BH                        # Load base address of comma_j at offset 5 into B
MOV_DL_BL                        # Load base address of comma_j at offset 5 into B
DECR4_D                          # Load base address of comma_j at offset 5 into B
DECR_D                           # Load base address of comma_j at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_comma_operator_return_81
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

:test_strings                    # void test_strings()
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
INCR_D                           # Load base address of str1 at offset 1 into B
MOV_DH_BH                        # Load base address of str1 at offset 1 into B
MOV_DL_BL                        # Load base address of str1 at offset 1 into B
DECR_D                           # Load base address of str1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A .data_string_50            # "Hello"
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *str1
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *str1
ALUOP_ADDR_B %A%+%AL%            # Store to  char *str1
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *str1
LDI_A .data_string_51            # "String literal [0]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 'H'                       # Constant assignment 'H' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of str1 at offset 1 into A
MOV_DH_AH                        # Load base address of str1 at offset 1 into A
MOV_DL_AL                        # Load base address of str1 at offset 1 into A
DECR_D                           # Load base address of str1 at offset 1 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_52            # "String literal [1]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 'e'                       # Constant assignment 'e' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of str1 at offset 1 into A
MOV_DH_AH                        # Load base address of str1 at offset 1 into A
MOV_DL_AL                        # Load base address of str1 at offset 1 into A
DECR_D                           # Load base address of str1 at offset 1 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_53            # "String literal [4]"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 'o'                       # Constant assignment 'o' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of str1 at offset 1 into A
MOV_DH_AH                        # Load base address of str1 at offset 1 into A
MOV_DL_AL                        # Load base address of str1 at offset 1 into A
DECR_D                           # Load base address of str1 at offset 1 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
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
LDI_A .data_string_54            # "String null terminator"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 0                         # Constant assignment 0 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of str1 at offset 1 into A
MOV_DH_AH                        # Load base address of str1 at offset 1 into A
MOV_DL_AL                        # Load base address of str1 at offset 1 into A
DECR_D                           # Load base address of str1 at offset 1 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
LDI_A 5                          # Constant assignment 5 as int
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
MOV_DH_BH                        # Load base address of str2 at offset 3 into B
MOV_DL_BL                        # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A .data_string_55            # "Test"
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  char *str2
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  char *str2
ALUOP_ADDR_B %A%+%AL%            # Store to  char *str2
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  char *str2
INCR4_D                          # Load base address of str_match at offset 5 into B
INCR_D                           # Load base address of str_match at offset 5 into B
MOV_DH_BH                        # Load base address of str_match at offset 5 into B
MOV_DL_BL                        # Load base address of str_match at offset 5 into B
DECR4_D                          # Load base address of str_match at offset 5 into B
DECR_D                           # Load base address of str_match at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char str_match
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char str_match
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp !=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp !=: Save A for generating rhs
LDI_AL 't'                       # Constant assignment 't' as char
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
MOV_DH_BH                        # Load base address of str2 at offset 3 into B
MOV_DL_BL                        # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 3                          # Constant assignment 3 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
LDA_A_BL                         # Dereferenced load
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_94        # BinaryOp != is true
LDI_BL 0                         # BinaryOp != was false
JMP .binarybool_done_95
.binarybool_istrue_94
LDI_BL 1                         # BinaryOp != was true
.binarybool_done_95
POP_AL                           # BinaryOp !=: Restore A after use for rhs
POP_AH                           # BinaryOp !=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp !=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp !=: Save A for generating rhs
LDI_AL 's'                       # Constant assignment 's' as char
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
MOV_DH_BH                        # Load base address of str2 at offset 3 into B
MOV_DL_BL                        # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 2                          # Constant assignment 2 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
LDA_A_BL                         # Dereferenced load
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_96        # BinaryOp != is true
LDI_BL 0                         # BinaryOp != was false
JMP .binarybool_done_97
.binarybool_istrue_96
LDI_BL 1                         # BinaryOp != was true
.binarybool_done_97
POP_AL                           # BinaryOp !=: Restore A after use for rhs
POP_AH                           # BinaryOp !=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp !=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp !=: Save A for generating rhs
LDI_AL 'e'                       # Constant assignment 'e' as char
ALUOP_PUSH %A%+%AH%              # ArrayRef A backup
ALUOP_PUSH %A%+%AL%              # ArrayRef A backup
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
INCR_D                           # Load base address of str2 at offset 3 into B
MOV_DH_BH                        # Load base address of str2 at offset 3 into B
MOV_DL_BL                        # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
DECR_D                           # Load base address of str2 at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_PUSH %A%+%AH%              # ArrayRef Save base address in A
ALUOP_PUSH %A%+%AL%              # ArrayRef Save base address in A
LDI_B 1                          # Constant assignment 1 as int
POP_AL                           # ArrayRef Restore base address in A
POP_AH                           # ArrayRef Restore base address in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in B to address reg A, element size 1
LDA_A_BL                         # Dereferenced load
POP_AL                           # ArrayRef Restore A
POP_AH                           # ArrayRef Restore A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_98        # BinaryOp != is true
LDI_BL 0                         # BinaryOp != was false
JMP .binarybool_done_99
.binarybool_istrue_98
LDI_BL 1                         # BinaryOp != was true
.binarybool_done_99
POP_AL                           # BinaryOp !=: Restore A after use for rhs
POP_AH                           # BinaryOp !=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_BL 'T'                       # Constant assignment 'T' as char
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR_D                           # Load base address of str2 at offset 3 into A
INCR_D                           # Load base address of str2 at offset 3 into A
INCR_D                           # Load base address of str2 at offset 3 into A
MOV_DH_AH                        # Load base address of str2 at offset 3 into A
MOV_DL_AL                        # Load base address of str2 at offset 3 into A
DECR_D                           # Load base address of str2 at offset 3 into A
DECR_D                           # Load base address of str2 at offset 3 into A
DECR_D                           # Load base address of str2 at offset 3 into A
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
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_100       # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_101
.binarybool_istrue_100
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_101
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_102      # Binary boolean format check, jump if true
JMP .binarybool_done_103         # Binary boolean format check: done
.binarybool_wastrue_102
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_103
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_104      # Binary boolean format check, jump if true
JMP .binarybool_done_105         # Binary boolean format check: done
.binarybool_wastrue_104
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_105
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP_AL %A|B%+%AL%+%BL%         # BinaryOp || 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_106      # Binary boolean format check, jump if true
JMP .binarybool_done_107         # Binary boolean format check: done
.binarybool_wastrue_106
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_107
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_92           # Condition was true
JMP .end_if_93                   # Done with false condition
.condition_true_92               # Condition was true
INCR4_D                          # Load base address of str_match at offset 5 into B
INCR_D                           # Load base address of str_match at offset 5 into B
MOV_DH_BH                        # Load base address of str_match at offset 5 into B
MOV_DL_BL                        # Load base address of str_match at offset 5 into B
DECR4_D                          # Load base address of str_match at offset 5 into B
DECR_D                           # Load base address of str_match at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char str_match
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char str_match
.end_if_93                       # End If
LDI_A .data_string_56            # "String literal content"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 1                         # Constant assignment 1 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of str_match at offset 5 into B
INCR_D                           # Load base address of str_match at offset 5 into B
MOV_DH_BH                        # Load base address of str_match at offset 5 into B
MOV_DL_BL                        # Load base address of str_match at offset 5 into B
DECR4_D                          # Load base address of str_match at offset 5 into B
DECR_D                           # Load base address of str_match at offset 5 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_strings_return_91
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

:test_address_calculation        # void test_address_calculation()
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
LDI_BL 30                        # Bytes to allocate for local vars
CALL :heap_advance_BL
INCR_D                           # Load base address of local_small1 at offset 1 into B
MOV_DH_BH                        # Load base address of local_small1 at offset 1 into B
MOV_DL_BL                        # Load base address of local_small1 at offset 1 into B
DECR_D                           # Load base address of local_small1 at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char local_small1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local_small1
INCR_D                           # Load base address of local_small2 at offset 2 into B
INCR_D                           # Load base address of local_small2 at offset 2 into B
MOV_DH_BH                        # Load base address of local_small2 at offset 2 into B
MOV_DL_BL                        # Load base address of local_small2 at offset 2 into B
DECR_D                           # Load base address of local_small2 at offset 2 into B
DECR_D                           # Load base address of local_small2 at offset 2 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char local_small2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local_small2
INCR_D                           # Load base address of local_small3 at offset 3 into B
INCR_D                           # Load base address of local_small3 at offset 3 into B
INCR_D                           # Load base address of local_small3 at offset 3 into B
MOV_DH_BH                        # Load base address of local_small3 at offset 3 into B
MOV_DL_BL                        # Load base address of local_small3 at offset 3 into B
DECR_D                           # Load base address of local_small3 at offset 3 into B
DECR_D                           # Load base address of local_small3 at offset 3 into B
DECR_D                           # Load base address of local_small3 at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for  unsigned char local_small3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char local_small3
INCR4_D                          # Load base address of ptr_small at offset 4 into B
MOV_DH_BH                        # Load base address of ptr_small at offset 4 into B
MOV_DL_BL                        # Load base address of ptr_small at offset 4 into B
DECR4_D                          # Load base address of ptr_small at offset 4 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of local_small2 at offset 2 into A
INCR_D                           # Load base address of local_small2 at offset 2 into A
MOV_DH_AH                        # Load base address of local_small2 at offset 2 into A
MOV_DL_AL                        # Load base address of local_small2 at offset 2 into A
DECR_D                           # Load base address of local_small2 at offset 2 into A
DECR_D                           # Load base address of local_small2 at offset 2 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_small
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_small
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_small
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_small
LDI_A .data_string_57            # "Small offset address"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 2                         # Constant assignment 2 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
INCR4_D                          # Load base address of ptr_small at offset 4 into A
MOV_DH_AH                        # Load base address of ptr_small at offset 4 into A
MOV_DL_AL                        # Load base address of ptr_small at offset 4 into A
DECR4_D                          # Load base address of ptr_small at offset 4 into A
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
INCR4_D                          # Load base address of large_off1 at offset 6 into B
INCR_D                           # Load base address of large_off1 at offset 6 into B
INCR_D                           # Load base address of large_off1 at offset 6 into B
MOV_DH_BH                        # Load base address of large_off1 at offset 6 into B
MOV_DL_BL                        # Load base address of large_off1 at offset 6 into B
DECR4_D                          # Load base address of large_off1 at offset 6 into B
DECR_D                           # Load base address of large_off1 at offset 6 into B
DECR_D                           # Load base address of large_off1 at offset 6 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for  unsigned char large_off1
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off1
INCR4_D                          # Load base address of large_off2 at offset 7 into B
INCR_D                           # Load base address of large_off2 at offset 7 into B
INCR_D                           # Load base address of large_off2 at offset 7 into B
INCR_D                           # Load base address of large_off2 at offset 7 into B
MOV_DH_BH                        # Load base address of large_off2 at offset 7 into B
MOV_DL_BL                        # Load base address of large_off2 at offset 7 into B
DECR4_D                          # Load base address of large_off2 at offset 7 into B
DECR_D                           # Load base address of large_off2 at offset 7 into B
DECR_D                           # Load base address of large_off2 at offset 7 into B
DECR_D                           # Load base address of large_off2 at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for  unsigned char large_off2
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off2
INCR8_D                          # Load base address of large_off3 at offset 8 into B
MOV_DH_BH                        # Load base address of large_off3 at offset 8 into B
MOV_DL_BL                        # Load base address of large_off3 at offset 8 into B
DECR8_D                          # Load base address of large_off3 at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for  unsigned char large_off3
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off3
INCR8_D                          # Load base address of large_off4 at offset 9 into B
INCR_D                           # Load base address of large_off4 at offset 9 into B
MOV_DH_BH                        # Load base address of large_off4 at offset 9 into B
MOV_DL_BL                        # Load base address of large_off4 at offset 9 into B
DECR8_D                          # Load base address of large_off4 at offset 9 into B
DECR_D                           # Load base address of large_off4 at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 4                         # Constant assignment 4 for  unsigned char large_off4
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off4
ALUOP_PUSH %A%+%AL%              # Load base address of large_off5 at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off5 at offset 10 into B
MOV_DH_BH                        # Load base address of large_off5 at offset 10 into B
MOV_DL_BL                        # Load base address of large_off5 at offset 10 into B
LDI_A 10                         # Load base address of large_off5 at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off5 at offset 10 into B
POP_AH                           # Load base address of large_off5 at offset 10 into B
POP_AL                           # Load base address of large_off5 at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for  unsigned char large_off5
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off5
ALUOP_PUSH %A%+%AL%              # Load base address of large_off6 at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off6 at offset 11 into B
MOV_DH_BH                        # Load base address of large_off6 at offset 11 into B
MOV_DL_BL                        # Load base address of large_off6 at offset 11 into B
LDI_A 11                         # Load base address of large_off6 at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off6 at offset 11 into B
POP_AH                           # Load base address of large_off6 at offset 11 into B
POP_AL                           # Load base address of large_off6 at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 6                         # Constant assignment 6 for  unsigned char large_off6
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off6
ALUOP_PUSH %A%+%AL%              # Load base address of large_off7 at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off7 at offset 12 into B
MOV_DH_BH                        # Load base address of large_off7 at offset 12 into B
MOV_DL_BL                        # Load base address of large_off7 at offset 12 into B
LDI_A 12                         # Load base address of large_off7 at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off7 at offset 12 into B
POP_AH                           # Load base address of large_off7 at offset 12 into B
POP_AL                           # Load base address of large_off7 at offset 12 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 7                         # Constant assignment 7 for  unsigned char large_off7
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off7
ALUOP_PUSH %A%+%AL%              # Load base address of large_off8 at offset 13 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off8 at offset 13 into B
MOV_DH_BH                        # Load base address of large_off8 at offset 13 into B
MOV_DL_BL                        # Load base address of large_off8 at offset 13 into B
LDI_A 13                         # Load base address of large_off8 at offset 13 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off8 at offset 13 into B
POP_AH                           # Load base address of large_off8 at offset 13 into B
POP_AL                           # Load base address of large_off8 at offset 13 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 8                         # Constant assignment 8 for  unsigned char large_off8
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off8
ALUOP_PUSH %A%+%AL%              # Load base address of large_off9 at offset 14 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off9 at offset 14 into B
MOV_DH_BH                        # Load base address of large_off9 at offset 14 into B
MOV_DL_BL                        # Load base address of large_off9 at offset 14 into B
LDI_A 14                         # Load base address of large_off9 at offset 14 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off9 at offset 14 into B
POP_AH                           # Load base address of large_off9 at offset 14 into B
POP_AL                           # Load base address of large_off9 at offset 14 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 9                         # Constant assignment 9 for  unsigned char large_off9
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off9
ALUOP_PUSH %A%+%AL%              # Load base address of large_off10 at offset 15 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off10 at offset 15 into B
MOV_DH_BH                        # Load base address of large_off10 at offset 15 into B
MOV_DL_BL                        # Load base address of large_off10 at offset 15 into B
LDI_A 15                         # Load base address of large_off10 at offset 15 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off10 at offset 15 into B
POP_AH                           # Load base address of large_off10 at offset 15 into B
POP_AL                           # Load base address of large_off10 at offset 15 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char large_off10
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off10
ALUOP_PUSH %A%+%AL%              # Load base address of large_off11 at offset 16 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off11 at offset 16 into B
MOV_DH_BH                        # Load base address of large_off11 at offset 16 into B
MOV_DL_BL                        # Load base address of large_off11 at offset 16 into B
LDI_A 16                         # Load base address of large_off11 at offset 16 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off11 at offset 16 into B
POP_AH                           # Load base address of large_off11 at offset 16 into B
POP_AL                           # Load base address of large_off11 at offset 16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 11                        # Constant assignment 11 for  unsigned char large_off11
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off11
ALUOP_PUSH %A%+%AL%              # Load base address of large_off12 at offset 17 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off12 at offset 17 into B
MOV_DH_BH                        # Load base address of large_off12 at offset 17 into B
MOV_DL_BL                        # Load base address of large_off12 at offset 17 into B
LDI_A 17                         # Load base address of large_off12 at offset 17 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off12 at offset 17 into B
POP_AH                           # Load base address of large_off12 at offset 17 into B
POP_AL                           # Load base address of large_off12 at offset 17 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 12                        # Constant assignment 12 for  unsigned char large_off12
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off12
ALUOP_PUSH %A%+%AL%              # Load base address of large_off13 at offset 18 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off13 at offset 18 into B
MOV_DH_BH                        # Load base address of large_off13 at offset 18 into B
MOV_DL_BL                        # Load base address of large_off13 at offset 18 into B
LDI_A 18                         # Load base address of large_off13 at offset 18 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off13 at offset 18 into B
POP_AH                           # Load base address of large_off13 at offset 18 into B
POP_AL                           # Load base address of large_off13 at offset 18 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 13                        # Constant assignment 13 for  unsigned char large_off13
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off13
ALUOP_PUSH %A%+%AL%              # Load base address of large_off14 at offset 19 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off14 at offset 19 into B
MOV_DH_BH                        # Load base address of large_off14 at offset 19 into B
MOV_DL_BL                        # Load base address of large_off14 at offset 19 into B
LDI_A 19                         # Load base address of large_off14 at offset 19 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off14 at offset 19 into B
POP_AH                           # Load base address of large_off14 at offset 19 into B
POP_AL                           # Load base address of large_off14 at offset 19 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 14                        # Constant assignment 14 for  unsigned char large_off14
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off14
ALUOP_PUSH %A%+%AL%              # Load base address of large_off15 at offset 20 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off15 at offset 20 into B
MOV_DH_BH                        # Load base address of large_off15 at offset 20 into B
MOV_DL_BL                        # Load base address of large_off15 at offset 20 into B
LDI_A 20                         # Load base address of large_off15 at offset 20 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off15 at offset 20 into B
POP_AH                           # Load base address of large_off15 at offset 20 into B
POP_AL                           # Load base address of large_off15 at offset 20 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 15                        # Constant assignment 15 for  unsigned char large_off15
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off15
ALUOP_PUSH %A%+%AL%              # Load base address of large_off16 at offset 21 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off16 at offset 21 into B
MOV_DH_BH                        # Load base address of large_off16 at offset 21 into B
MOV_DL_BL                        # Load base address of large_off16 at offset 21 into B
LDI_A 21                         # Load base address of large_off16 at offset 21 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off16 at offset 21 into B
POP_AH                           # Load base address of large_off16 at offset 21 into B
POP_AL                           # Load base address of large_off16 at offset 21 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 16                        # Constant assignment 16 for  unsigned char large_off16
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off16
ALUOP_PUSH %A%+%AL%              # Load base address of large_off17 at offset 22 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off17 at offset 22 into B
MOV_DH_BH                        # Load base address of large_off17 at offset 22 into B
MOV_DL_BL                        # Load base address of large_off17 at offset 22 into B
LDI_A 22                         # Load base address of large_off17 at offset 22 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off17 at offset 22 into B
POP_AH                           # Load base address of large_off17 at offset 22 into B
POP_AL                           # Load base address of large_off17 at offset 22 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 17                        # Constant assignment 17 for  unsigned char large_off17
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off17
ALUOP_PUSH %A%+%AL%              # Load base address of large_off18 at offset 23 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off18 at offset 23 into B
MOV_DH_BH                        # Load base address of large_off18 at offset 23 into B
MOV_DL_BL                        # Load base address of large_off18 at offset 23 into B
LDI_A 23                         # Load base address of large_off18 at offset 23 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off18 at offset 23 into B
POP_AH                           # Load base address of large_off18 at offset 23 into B
POP_AL                           # Load base address of large_off18 at offset 23 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 18                        # Constant assignment 18 for  unsigned char large_off18
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off18
ALUOP_PUSH %A%+%AL%              # Load base address of large_off19 at offset 24 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off19 at offset 24 into B
MOV_DH_BH                        # Load base address of large_off19 at offset 24 into B
MOV_DL_BL                        # Load base address of large_off19 at offset 24 into B
LDI_A 24                         # Load base address of large_off19 at offset 24 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off19 at offset 24 into B
POP_AH                           # Load base address of large_off19 at offset 24 into B
POP_AL                           # Load base address of large_off19 at offset 24 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 19                        # Constant assignment 19 for  unsigned char large_off19
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off19
ALUOP_PUSH %A%+%AL%              # Load base address of large_off20 at offset 25 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off20 at offset 25 into B
MOV_DH_BH                        # Load base address of large_off20 at offset 25 into B
MOV_DL_BL                        # Load base address of large_off20 at offset 25 into B
LDI_A 25                         # Load base address of large_off20 at offset 25 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off20 at offset 25 into B
POP_AH                           # Load base address of large_off20 at offset 25 into B
POP_AL                           # Load base address of large_off20 at offset 25 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 20                        # Constant assignment 20 for  unsigned char large_off20
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off20
ALUOP_PUSH %A%+%AL%              # Load base address of large_off21 at offset 26 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off21 at offset 26 into B
MOV_DH_BH                        # Load base address of large_off21 at offset 26 into B
MOV_DL_BL                        # Load base address of large_off21 at offset 26 into B
LDI_A 26                         # Load base address of large_off21 at offset 26 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off21 at offset 26 into B
POP_AH                           # Load base address of large_off21 at offset 26 into B
POP_AL                           # Load base address of large_off21 at offset 26 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 21                        # Constant assignment 21 for  unsigned char large_off21
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off21
ALUOP_PUSH %A%+%AL%              # Load base address of large_off22 at offset 27 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off22 at offset 27 into B
MOV_DH_BH                        # Load base address of large_off22 at offset 27 into B
MOV_DL_BL                        # Load base address of large_off22 at offset 27 into B
LDI_A 27                         # Load base address of large_off22 at offset 27 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off22 at offset 27 into B
POP_AH                           # Load base address of large_off22 at offset 27 into B
POP_AL                           # Load base address of large_off22 at offset 27 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 22                        # Constant assignment 22 for  unsigned char large_off22
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off22
ALUOP_PUSH %A%+%AL%              # Load base address of large_off23 at offset 28 into B
ALUOP_PUSH %A%+%AH%              # Load base address of large_off23 at offset 28 into B
MOV_DH_BH                        # Load base address of large_off23 at offset 28 into B
MOV_DL_BL                        # Load base address of large_off23 at offset 28 into B
LDI_A 28                         # Load base address of large_off23 at offset 28 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off23 at offset 28 into B
POP_AH                           # Load base address of large_off23 at offset 28 into B
POP_AL                           # Load base address of large_off23 at offset 28 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 23                        # Constant assignment 23 for  unsigned char large_off23
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char large_off23
ALUOP_PUSH %A%+%AL%              # Load base address of ptr_large at offset 29 into B
ALUOP_PUSH %A%+%AH%              # Load base address of ptr_large at offset 29 into B
MOV_DH_BH                        # Load base address of ptr_large at offset 29 into B
MOV_DL_BL                        # Load base address of ptr_large at offset 29 into B
LDI_A 29                         # Load base address of ptr_large at offset 29 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_large at offset 29 into B
POP_AH                           # Load base address of ptr_large at offset 29 into B
POP_AL                           # Load base address of ptr_large at offset 29 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Load base address of large_off23 at offset 28 into A
ALUOP_PUSH %B%+%BH%              # Load base address of large_off23 at offset 28 into A
MOV_DH_AH                        # Load base address of large_off23 at offset 28 into A
MOV_DL_AL                        # Load base address of large_off23 at offset 28 into A
LDI_B 28                         # Load base address of large_off23 at offset 28 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of large_off23 at offset 28 into A
POP_BH                           # Load base address of large_off23 at offset 28 into A
POP_BL                           # Load base address of large_off23 at offset 28 into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *ptr_large
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_large
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *ptr_large
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *ptr_large
LDI_A .data_string_58            # "Large offset address"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 23                        # Constant assignment 23 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %B%+%BL%              # UnaryOp *: Save B before generating expr value
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of ptr_large at offset 29 into A
ALUOP_PUSH %B%+%BH%              # Load base address of ptr_large at offset 29 into A
MOV_DH_AH                        # Load base address of ptr_large at offset 29 into A
MOV_DL_AL                        # Load base address of ptr_large at offset 29 into A
LDI_B 29                         # Load base address of ptr_large at offset 29 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of ptr_large at offset 29 into A
POP_BH                           # Load base address of ptr_large at offset 29 into A
POP_BL                           # Load base address of ptr_large at offset 29 into A
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
.test_address_calculation_return_108
LDI_BL 30                        # Bytes to free from local vars and parameters
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
LDI_C .data_string_59            # "=== Compiler Test Suite ===\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_switch
# function returns nothing, not popping a return value
CALL :test_sizeof
# function returns nothing, not popping a return value
CALL :test_cast
# function returns nothing, not popping a return value
CALL :test_functions
# function returns nothing, not popping a return value
CALL :test_globals
# function returns nothing, not popping a return value
CALL :test_scopes
# function returns nothing, not popping a return value
CALL :test_comma_operator
# function returns nothing, not popping a return value
CALL :test_strings
# function returns nothing, not popping a return value
CALL :test_address_calculation
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_60            # "=== Test Results ===\n"
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
LDI_C .data_string_61            # "Total tests: %U\n"
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
LDI_C .data_string_62            # "Failed tests: %U\n"
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
JNE .binarybool_isfalse_112      # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_112      # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_113
.binarybool_isfalse_112
LDI_A 0                          # BinaryOp == was false
.binarybool_done_113
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_110          # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_63            # "\n*** SOME TESTS FAILED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
JMP .end_if_111                  # Done with false condition
.condition_true_110              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_64            # "\n*** ALL TESTS PASSED ***\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_111                      # End If
.main_return_109
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
.data_string_6 "Switch case 2\0"
.data_string_7 "Switch default\0"
.data_string_8 "Switch fall-through\0"
.data_string_9 "Switch 16-bit value\0"
.data_string_10 "sizeof(uint8_t)\0"
.data_string_11 "sizeof(uint16_t)\0"
.data_string_12 "sizeof(variable)\0"
.data_string_13 "sizeof(array)\0"
.data_string_14 "sizeof(struct Point)\0"
.data_string_15 "sizeof(struct Rect)\0"
.data_string_16 "sizeof(pointer)\0"
.data_string_17 "Cast uint8_t to uint16_t\0"
.data_string_18 "Cast uint16_t to uint8_t\0"
.data_string_19 "Cast to pointer\0"
.data_string_20 "Function call 8-bit\0"
.data_string_21 "Function call 16-bit\0"
.data_string_22 "Function mixed params\0"
.data_string_23 "Function pointer param\0"
.data_string_24 "Function struct param .x\0"
.data_string_25 "Function struct param .y\0"
.data_string_26 "Function array param\0"
.data_string_27 "Void function\0"
.data_string_28 "Function with locals\0"
.data_string_29 "Static local call 1\0"
.data_string_30 "Static local call 2\0"
.data_string_31 "Static local call 3\0"
.data_string_32 "Global byte read\0"
.data_string_33 "Global word read\0"
.data_string_34 "Global signed byte read\0"
.data_string_35 "Global signed word read\0"
.data_string_36 "Global byte write\0"
.data_string_37 "Global word write\0"
.data_string_38 "Global array [0]\0"
.data_string_39 "Global array [4]\0"
.data_string_40 "Global word array [1]\0"
.data_string_41 "Global struct .x\0"
.data_string_42 "Global struct .y\0"
.data_string_43 "Scoped variable access\0"
.data_string_44 "Nested scopes\0"
.data_string_45 "Comma operator side effect 1\0"
.data_string_46 "Comma operator side effect 2\0"
.data_string_47 "Comma operator result\0"
.data_string_48 "Comma in for loop\0"
.data_string_49 "Comma in for increment\0"
.data_string_50 "Hello\0"
.data_string_51 "String literal [0]\0"
.data_string_52 "String literal [1]\0"
.data_string_53 "String literal [4]\0"
.data_string_54 "String null terminator\0"
.data_string_55 "Test\0"
.data_string_56 "String literal content\0"
.data_string_57 "Small offset address\0"
.data_string_58 "Large offset address\0"
.data_string_59 "=== Compiler Test Suite ===\n\0"
.data_string_60 "=== Test Results ===\n\0"
.data_string_61 "Total tests: %U\n\0"
.data_string_62 "Failed tests: %U\n\0"
.data_string_63 "\n*** SOME TESTS FAILED ***\n\0"
.data_string_64 "\n*** ALL TESTS PASSED ***\n\0"
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
