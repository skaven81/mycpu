CALL .__global_local_init__
JMP :main                        # Initialization complete, go to main function


:pass                            # void pass()
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
LDI_B .var_total                 # Load base address of total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total                 # Load base address of total into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
.pass_return_1
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:fail_test                       # void fail_test( char *name)
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
LDI_B .var_total                 # Load base address of total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total                 # Load base address of total into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_fail                  # Load base address of fail into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_fail                  # Load base address of fail into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short fail
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short fail
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short fail
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short fail
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "FAIL ["
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
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "]\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.fail_test_return_2
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

:assert_u8                       # void assert_u8( unsigned char actual,  unsigned char expected,  char *name)
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
LDI_B .var_total                 # Load base address of total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total                 # Load base address of total into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total
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
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_fail                  # Load base address of fail into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_fail                  # Load base address of fail into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short fail
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short fail
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short fail
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short fail
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "FAIL ["
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR_D                           # Load base address of name at offset -3 into A
DECR_D                           # Load base address of name at offset -3 into A
DECR_D                           # Load base address of name at offset -3 into A
MOV_DH_AH                        # Load base address of name at offset -3 into A
MOV_DL_AL                        # Load base address of name at offset -3 into A
INCR_D                           # Load base address of name at offset -3 into A
INCR_D                           # Load base address of name at offset -3 into A
INCR_D                           # Load base address of name at offset -3 into A
LDA_A_CH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_CL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in C
POP_AL                           # Restore A, pointer value in C
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
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
LDI_C .data_string_2             # "] exp=0x%x got=0x%x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_5                        # End If
.assert_u8_return_3
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

:assert_u16                      # void assert_u16( unsigned short actual,  unsigned short expected,  char *name)
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
LDI_B .var_total                 # Load base address of total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_total                 # Load base address of total into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total
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
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_fail                  # Load base address of fail into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_fail                  # Load base address of fail into B
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short fail
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short fail
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short fail
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short fail
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "FAIL ["
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
DECR4_D                          # Load base address of name at offset -5 into A
DECR_D                           # Load base address of name at offset -5 into A
MOV_DH_AH                        # Load base address of name at offset -5 into A
MOV_DL_AL                        # Load base address of name at offset -5 into A
INCR4_D                          # Load base address of name at offset -5 into A
INCR_D                           # Load base address of name at offset -5 into A
LDA_A_CH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_CL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in C
POP_AL                           # Restore A, pointer value in C
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
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
LDI_C .data_string_3             # "] exp=0x%X got=0x%X\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_10                       # End If
.assert_u16_return_8
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

:test_dirwalk                    # void test_dirwalk()
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
INCR_D                           # Load base address of h at offset 1 into B
MOV_DH_BH                        # Load base address of h at offset 1 into B
MOV_DL_BL                        # Load base address of h at offset 1 into B
DECR_D                           # Load base address of h at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A $drive_0_fs_handle         # Load base address of drive_0_fs_handle into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fs_handle *h
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fs_handle *h
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fs_handle *h
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fs_handle *h
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
MOV_DH_BH                        # Load base address of ctx at offset 3 into B
MOV_DL_BL                        # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short dir_cluster
CALL :heap_push_A                # Push parameter  unsigned short dir_cluster
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of h at offset 1 into B
MOV_DH_BH                        # Load base address of h at offset 1 into B
MOV_DL_BL                        # Load base address of h at offset 1 into B
DECR_D                           # Load base address of h at offset 1 into B
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
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirwalk_ctx *ctx
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirwalk_ctx *ctx
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirwalk_ctx *ctx
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirwalk_ctx *ctx
INCR4_D                          # Load base address of ctx_addr at offset 5 into B
INCR_D                           # Load base address of ctx_addr at offset 5 into B
MOV_DH_BH                        # Load base address of ctx_addr at offset 5 into B
MOV_DL_BL                        # Load base address of ctx_addr at offset 5 into B
DECR4_D                          # Load base address of ctx_addr at offset 5 into B
DECR_D                           # Load base address of ctx_addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
MOV_DH_BH                        # Load base address of ctx at offset 3 into B
MOV_DL_BL                        # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirwalk_ctx *ctx to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short ctx_addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short ctx_addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short ctx_addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short ctx_addr
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of ctx_addr at offset 5 into B
INCR_D                           # Load base address of ctx_addr at offset 5 into B
MOV_DH_BH                        # Load base address of ctx_addr at offset 5 into B
MOV_DL_BL                        # Load base address of ctx_addr at offset 5 into B
DECR4_D                          # Load base address of ctx_addr at offset 5 into B
DECR_D                           # Load base address of ctx_addr at offset 5 into B
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
LDI_A .data_string_4             # "dirwalk_start"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .test_dirwalk_return_13
.end_if_15                       # End If
CALL :pass
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
MOV_DH_BH                        # Load base address of count at offset 7 into B
MOV_DL_BL                        # Load base address of count at offset 7 into B
DECR4_D                          # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for  unsigned char count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count
ALUOP_PUSH %A%+%AH%              # Preserve A for while loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for while loop condition
.while_top_18                    # While loop begin
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 20                         # Constant assignment 20 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
MOV_DH_BH                        # Load base address of count at offset 7 into B
MOV_DL_BL                        # Load base address of count at offset 7 into B
DECR4_D                          # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_23       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp <: Subtract to check E and O flags
JO .binaryop_overflow_24         # Signed BinaryOp <: If overflow, result will be false
JEQ .binaryop_equal_21           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp <: Compare signs
LDI_AL 1                         # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_22             # Signed BinaryOp <: Assume signs were the same
LDI_AL 0                         # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_22            # Signed BinaryOp <: Signs were different
.binaryop_equal_21
LDI_AL 0                         # Signed BinaryOp <: false because equal
JMP .binaryop_done_22
.binaryop_overflow_24
LDI_AL 0                         # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_22
.binaryop_diffsigns_23
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp <: Check sign of left operand
LDI_AL 1                         # Signed BinaryOp <: assume true
JNZ .binaryop_done_22            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_AL 0                         # Signed BinaryOp <: flip to false
.binaryop_done_22
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check while condition
JNZ .while_true_19               # Condition was true
JMP .while_end_20                # Condition was false, end loop
.while_true_19                   # Begin while loop body
INCR8_D                          # Load base address of entry at offset 8 into B
MOV_DH_BH                        # Load base address of entry at offset 8 into B
MOV_DL_BL                        # Load base address of entry at offset 8 into B
DECR8_D                          # Load base address of entry at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
MOV_DH_BH                        # Load base address of ctx at offset 3 into B
MOV_DL_BL                        # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
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
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_PUSH %A%+%AL%              # Load base address of addr at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of addr at offset 10 into B
MOV_DH_BH                        # Load base address of addr at offset 10 into B
MOV_DL_BL                        # Load base address of addr at offset 10 into B
LDI_A 10                         # Load base address of addr at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of addr at offset 10 into B
POP_AH                           # Load base address of addr at offset 10 into B
POP_AL                           # Load base address of addr at offset 10 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR8_D                          # Load base address of entry at offset 8 into B
MOV_DH_BH                        # Load base address of entry at offset 8 into B
MOV_DL_BL                        # Load base address of entry at offset 8 into B
DECR8_D                          # Load base address of entry at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 8                          # Constant assignment 8 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of addr at offset 10 into B
ALUOP_PUSH %A%+%AH%              # Load base address of addr at offset 10 into B
MOV_DH_BH                        # Load base address of addr at offset 10 into B
MOV_DL_BL                        # Load base address of addr at offset 10 into B
LDI_A 10                         # Load base address of addr at offset 10 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of addr at offset 10 into B
POP_AH                           # Load base address of addr at offset 10 into B
POP_AL                           # Load base address of addr at offset 10 into B
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
JMP .while_end_20                # Break out of loop/switch
.end_if_26                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 16                         # Constant assignment 0x10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR8_D                          # Load base address of entry at offset 8 into B
MOV_DH_BH                        # Load base address of entry at offset 8 into B
MOV_DL_BL                        # Load base address of entry at offset 8 into B
DECR8_D                          # Load base address of entry at offset 8 into B
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
INCR8_D                          # Load base address of entry at offset 8 into B
MOV_DH_BH                        # Load base address of entry at offset 8 into B
MOV_DL_BL                        # Load base address of entry at offset 8 into B
DECR8_D                          # Load base address of entry at offset 8 into B
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
.end_if_30                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
MOV_DH_BH                        # Load base address of count at offset 7 into B
MOV_DL_BL                        # Load base address of count at offset 7 into B
DECR4_D                          # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
INCR4_D                          # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
MOV_DH_BH                        # Load base address of count at offset 7 into B
MOV_DL_BL                        # Load base address of count at offset 7 into B
DECR4_D                          # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char count
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .while_top_18                # Next While loop
.while_end_20                    # End while loop
POP_AL                           # Restore A from while loop condition
POP_AH                           # Restore A from while loop condition
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
INCR_D                           # Load base address of ctx at offset 3 into B
MOV_DH_BH                        # Load base address of ctx at offset 3 into B
MOV_DL_BL                        # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
DECR_D                           # Load base address of ctx at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirwalk_ctx *ctx (pointer)
CALL :fat16_dirwalk_end
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
INCR_D                           # Load base address of count at offset 7 into B
MOV_DH_BH                        # Load base address of count at offset 7 into B
MOV_DL_BL                        # Load base address of count at offset 7 into B
DECR4_D                          # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
DECR_D                           # Load base address of count at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_35       # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP_FLAGS %B-A_signed%+%BL%+%AL% # Signed BinaryOp >=: Subtract to check E and O flags
JO .binaryop_overflow_36         # Signed BinaryOp >=: If overflow, result will be true
JEQ .binaryop_equal_33           # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP_AL %B-A_signed%+%BL%+%AL%  # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL% # Signed BinaryOp >=: Compare signs
LDI_AL 0                         # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_34             # Signed BinaryOp >=: Assume signs were the same
LDI_AL 1                         # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_34            # Signed BinaryOp >=: Signs were different
.binaryop_equal_33
LDI_AL 1                         # Signed BinaryOp >=: true because equal
JMP .binaryop_done_34
.binaryop_overflow_36
LDI_AL 1                         # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_34
.binaryop_diffsigns_35
ALUOP_FLAGS %Amsb%+%AL%          # Signed BinaryOp >=: Check sign of left operand
LDI_AL 0                         # Signed BinaryOp >=: assume false
JNZ .binaryop_done_34            # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_AL 1                         # Signed BinaryOp >=: flip to true
.binaryop_done_34
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_31           # Condition was true
LDI_A .data_string_5             # "dirwalk count>=2"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_32                   # Done with false condition
.condition_true_31               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
.end_if_32                       # End If
.test_dirwalk_return_13
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

:test_dir_find                   # void test_dir_find()
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
INCR_D                           # Load base address of h at offset 1 into B
MOV_DH_BH                        # Load base address of h at offset 1 into B
MOV_DL_BL                        # Load base address of h at offset 1 into B
DECR_D                           # Load base address of h at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A $drive_0_fs_handle         # Load base address of drive_0_fs_handle into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fs_handle *h
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fs_handle *h
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fs_handle *h
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fs_handle *h
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
MOV_DH_BH                        # Load base address of found at offset 3 into B
MOV_DL_BL                        # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of h at offset 1 into B
MOV_DH_BH                        # Load base address of h at offset 1 into B
MOV_DL_BL                        # Load base address of h at offset 1 into B
DECR_D                           # Load base address of h at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
LDI_A 0                          # Constant assignment 0 for  unsigned short cluster
CALL :heap_push_A                # Push parameter  unsigned short cluster
LDI_A .data_string_6             # "SYS"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 0                         # Constant assignment 0x00 for  unsigned char filter_out
CALL :heap_push_AL               # Push parameter  unsigned char filter_out
LDI_AL 255                       # Constant assignment 0xff for  unsigned char filter_in
CALL :heap_push_AL               # Push parameter  unsigned char filter_in
CALL :fat16_dir_find
CALL :heap_pop_A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *found
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *found
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *found
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *found
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
MOV_DH_BH                        # Load base address of found at offset 3 into B
MOV_DL_BL                        # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *found to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_42       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_43         # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_40           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_B 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_41             # Signed BinaryOp <: Assume signs were the same
LDI_B 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_41            # Signed BinaryOp <: Signs were different
.binaryop_equal_40
LDI_B 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_41
.binaryop_overflow_43
LDI_B 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_41
.binaryop_diffsigns_42
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp <: Check sign of left operand
LDI_B 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_41            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_B 0                          # Signed BinaryOp <: flip to false
.binaryop_done_41
POP_AL                           # BinaryOp <: Restore A after use for rhs
POP_AH                           # BinaryOp <: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_44       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_44       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_45
.binarybool_isfalse_44
LDI_A 0                          # BinaryOp == was false
.binarybool_done_45
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16_A %A|B%+%AL%+%BL% %A|B%+%AH%+%BH% # BinaryOp || 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_46       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_46       # Binary boolean format check, jump if true
JMP .binarybool_done_47          # Binary boolean format check: done
.binarybool_wastrue_46
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_47
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_38           # Condition was true
JMP .end_if_39                   # Done with false condition
.condition_true_38               # Condition was true
LDI_A .data_string_7             # "dir_find SYS found"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .test_dir_find_return_37
.end_if_39                       # End If
CALL :pass
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
MOV_DH_BH                        # Load base address of attr at offset 7 into B
MOV_DL_BL                        # Load base address of attr at offset 7 into B
DECR4_D                          # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
MOV_DH_BH                        # Load base address of found at offset 3 into B
MOV_DL_BL                        # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
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
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char attr
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 16                         # Constant assignment 0x10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
MOV_DH_BH                        # Load base address of attr at offset 7 into B
MOV_DL_BL                        # Load base address of attr at offset 7 into B
DECR4_D                          # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_48           # Condition was true
LDI_A .data_string_8             # "dir_find SYS is dir"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_49                   # Done with false condition
.condition_true_48               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
.end_if_49                       # End If
INCR8_D                          # Load base address of cluster at offset 8 into B
MOV_DH_BH                        # Load base address of cluster at offset 8 into B
MOV_DL_BL                        # Load base address of cluster at offset 8 into B
DECR8_D                          # Load base address of cluster at offset 8 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
MOV_DH_BH                        # Load base address of found at offset 3 into B
MOV_DL_BL                        # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
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
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short cluster
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short cluster
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short cluster
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short cluster
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR8_D                          # Load base address of cluster at offset 8 into B
MOV_DH_BH                        # Load base address of cluster at offset 8 into B
MOV_DL_BL                        # Load base address of cluster at offset 8 into B
DECR8_D                          # Load base address of cluster at offset 8 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Check if signs differ
JNZ .binaryop_diffsigns_54       # Signed BinaryOp >: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sB-A%      # Signed BinaryOp >: Subtract to check O flag
JO .binaryop_overflow_55         # Signed BinaryOp >: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >: check 16-bit equality
JEQ .binaryop_equal_52           # Signed BinaryOp >: If equal, we know if true/false now
ALUOP16O_A %ALU16_sB-A%          # Signed BinaryOp >: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >: Compare signs
LDI_A 0                          # Signed BinaryOp >: Assume no sign change -> false
JZ .binaryop_done_53             # Signed BinaryOp >: Assume signs were the same
LDI_A 1                          # Signed BinaryOp >: Signs were different -> true
JMP .binaryop_done_53            # Signed BinaryOp >: Signs were different
.binaryop_equal_52
LDI_A 0                          # Signed BinaryOp >: false because equal
JMP .binaryop_done_53
.binaryop_overflow_55
LDI_A 1                          # Signed BinaryOp >: true because signed overflow
JMP .binaryop_done_53
.binaryop_diffsigns_54
ALUOP_FLAGS %Amsb%+%AH%          # Signed BinaryOp >: Check sign of left operand
LDI_A 0                          # Signed BinaryOp >: assume false
JNZ .binaryop_done_53            # Signed BinaryOpn >: if left side sign bit is set, return false
LDI_A 1                          # Signed BinaryOp >: flip to true
.binaryop_done_53
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_50           # Condition was true
LDI_A .data_string_9             # "dir_find SYS cluster>0"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_51                   # Done with false condition
.condition_true_50               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
.end_if_51                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
INCR_D                           # Load base address of found at offset 3 into B
MOV_DH_BH                        # Load base address of found at offset 3 into B
MOV_DL_BL                        # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
DECR_D                           # Load base address of found at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.test_dir_find_return_37
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

:test_readfile                   # void test_readfile()
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
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of found_h at offset 1 into A
MOV_DH_AH                        # Load base address of found_h at offset 1 into A
MOV_DL_AL                        # Load base address of found_h at offset 1 into A
DECR_D                           # Load base address of found_h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_10            # "/SYSTEM.ODY"
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_57              # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_58
.pathfind_err_57
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_58
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ||: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Check if signs differ
JNZ .binaryop_diffsigns_63       # Signed BinaryOp <: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp <: Subtract to check O flag
JO .binaryop_overflow_64         # Signed BinaryOp <: If overflow, result will be false
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp <: check 16-bit equality
JEQ .binaryop_equal_61           # Signed BinaryOp <: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp <: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp <: Compare signs
LDI_B 1                          # Signed BinaryOp <: Assume no sign change -> true
JZ .binaryop_done_62             # Signed BinaryOp <: Assume signs were the same
LDI_B 0                          # Signed BinaryOp <: Signs were different -> false
JMP .binaryop_done_62            # Signed BinaryOp <: Signs were different
.binaryop_equal_61
LDI_B 0                          # Signed BinaryOp <: false because equal
JMP .binaryop_done_62
.binaryop_overflow_64
LDI_B 0                          # Signed BinaryOp <: false because signed overflow
JMP .binaryop_done_62
.binaryop_diffsigns_63
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp <: Check sign of left operand
LDI_B 1                          # Signed BinaryOp <: assume true
JNZ .binaryop_done_62            # Signed BinaryOpn <: if left side sign bit is set, return true
LDI_B 0                          # Signed BinaryOp <: flip to false
.binaryop_done_62
POP_AL                           # BinaryOp <: Restore A after use for rhs
POP_AH                           # BinaryOp <: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_65       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_65       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_66
.binarybool_isfalse_65
LDI_A 0                          # BinaryOp == was false
.binarybool_done_66
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16_A %A|B%+%AL%+%BL% %A|B%+%AH%+%BH% # BinaryOp || 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_67       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_67       # Binary boolean format check, jump if true
JMP .binarybool_done_68          # Binary boolean format check: done
.binarybool_wastrue_67
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_68
POP_BL                           # BinaryOp ||: Restore B after use for rhs
POP_BH                           # BinaryOp ||: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_59           # Condition was true
JMP .end_if_60                   # Done with false condition
.condition_true_59               # Condition was true
LDI_A .data_string_11            # "readfile pathfind"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .test_readfile_return_56
.end_if_60                       # End If
CALL :pass
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 4                          # Constant assignment 4 as int
CALL :malloc_segments            # Allocate segments, size in AL, result in A
# Cast  void *malloc_segments (virtual) to  void 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  void *buf
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  void *buf
ALUOP_ADDR_B %A%+%AL%            # Store to  void *buf
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  void *buf
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_71       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_71       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_72
.binarybool_isfalse_71
LDI_A 0                          # BinaryOp == was false
.binarybool_done_72
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_69           # Condition was true
JMP .end_if_70                   # Done with false condition
.condition_true_69               # Condition was true
LDI_A .data_string_12            # "readfile malloc"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
JMP .test_readfile_return_56
.end_if_70                       # End If
CALL :pass
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  void *buf to  unsigned short 
CALL :heap_push_A                # Push parameter  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found_h at offset 1 into B
MOV_DH_BH                        # Load base address of found_h at offset 1 into B
MOV_DL_BL                        # Load base address of found_h at offset 1 into B
DECR_D                           # Load base address of found_h at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fs_handle *found_h to  unsigned short 
CALL :heap_push_A                # Push parameter  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
CALL :heap_push_A                # Push parameter  unsigned short 
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_13            # "  entry=%X cluster=%X h=%X buf=%X\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
INCR8_D                          # Load base address of no_state at offset 9 into B
INCR_D                           # Load base address of no_state at offset 9 into B
MOV_DH_BH                        # Load base address of no_state at offset 9 into B
MOV_DL_BL                        # Load base address of no_state at offset 9 into B
DECR8_D                          # Load base address of no_state at offset 9 into B
DECR_D                           # Load base address of no_state at offset 9 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for pointer  struct fat16_readfile_ctx *no_state
# Cast  int const (virtual) to  struct fat16_readfile_ctx 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_readfile_ctx *no_state
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_readfile_ctx *no_state
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_readfile_ctx *no_state
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_readfile_ctx *no_state
ALUOP_PUSH %A%+%AL%              # Load base address of status at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of status at offset 11 into B
MOV_DH_BH                        # Load base address of status at offset 11 into B
MOV_DL_BL                        # Load base address of status at offset 11 into B
LDI_A 11                         # Load base address of status at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of status at offset 11 into B
POP_AH                           # Load base address of status at offset 11 into B
POP_AL                           # Load base address of status at offset 11 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of found_h at offset 1 into B
MOV_DH_BH                        # Load base address of found_h at offset 1 into B
MOV_DL_BL                        # Load base address of found_h at offset 1 into B
DECR_D                           # Load base address of found_h at offset 1 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fs_handle *h (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  void *dest (pointer)
LDI_A 1                          # Constant assignment 1 for  unsigned short n_sectors
CALL :heap_push_A                # Push parameter  unsigned short n_sectors
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :heap_push_A                # Push parameter  struct fat16_dirent *dirent (pointer)
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR8_D                          # Load base address of no_state at offset 9 into B
INCR_D                           # Load base address of no_state at offset 9 into B
MOV_DH_BH                        # Load base address of no_state at offset 9 into B
MOV_DL_BL                        # Load base address of no_state at offset 9 into B
DECR8_D                          # Load base address of no_state at offset 9 into B
DECR_D                           # Load base address of no_state at offset 9 into B
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
LDI_A .data_string_14            # "readfile status"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 0                         # Constant assignment 0x00 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
ALUOP_PUSH %A%+%AL%              # Load base address of status at offset 11 into B
ALUOP_PUSH %A%+%AH%              # Load base address of status at offset 11 into B
MOV_DH_BH                        # Load base address of status at offset 11 into B
MOV_DL_BL                        # Load base address of status at offset 11 into B
LDI_A 11                         # Load base address of status at offset 11 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of status at offset 11 into B
POP_AH                           # Load base address of status at offset 11 into B
POP_AL                           # Load base address of status at offset 11 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %A%+%AL%              # Load base address of p at offset 12 into B
ALUOP_PUSH %A%+%AH%              # Load base address of p at offset 12 into B
MOV_DH_BH                        # Load base address of p at offset 12 into B
MOV_DL_BL                        # Load base address of p at offset 12 into B
LDI_A 12                         # Load base address of p at offset 12 into B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into B
POP_AH                           # Load base address of p at offset 12 into B
POP_AL                           # Load base address of p at offset 12 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  void *buf to  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned char *p
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned char *p
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char *p
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned char *p
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char p_element (virtual)
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char p_element (virtual)
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char p_element (virtual)
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_15            # "  buf[0..2]=%x %x %x\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
LDI_A .data_string_16            # "ODY magic O"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 'O'                       # Constant assignment 'O' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :assert_u8
# function returns nothing, not popping a return value
LDI_A .data_string_17            # "ODY magic D"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 'D'                       # Constant assignment 'D' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :assert_u8
# function returns nothing, not popping a return value
LDI_A .data_string_18            # "ODY magic Y"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 'Y'                       # Constant assignment 'Y' for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
ALUOP_PUSH %B%+%BL%              # Load base address of p at offset 12 into A
ALUOP_PUSH %B%+%BH%              # Load base address of p at offset 12 into A
MOV_DH_AH                        # Load base address of p at offset 12 into A
MOV_DL_AL                        # Load base address of p at offset 12 into A
LDI_B 12                         # Load base address of p at offset 12 into A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Load base address of p at offset 12 into A
POP_BH                           # Load base address of p at offset 12 into A
POP_BL                           # Load base address of p at offset 12 into A
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_u8
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR4_D                          # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
INCR_D                           # Load base address of buf at offset 7 into B
MOV_DH_BH                        # Load base address of buf at offset 7 into B
MOV_DL_BL                        # Load base address of buf at offset 7 into B
DECR4_D                          # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
DECR_D                           # Load base address of buf at offset 7 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.test_readfile_return_56
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

:test_pathfind                   # void test_pathfind()
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
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of h at offset 1 into A
MOV_DH_AH                        # Load base address of h at offset 1 into A
MOV_DL_AL                        # Load base address of h at offset 1 into A
DECR_D                           # Load base address of h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_6             # "SYS"
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_74              # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_75
.pathfind_err_74
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_75
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_80       # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_81         # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_78           # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_B 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_79             # Signed BinaryOp >=: Assume signs were the same
LDI_B 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_79            # Signed BinaryOp >=: Signs were different
.binaryop_equal_78
LDI_B 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_79
.binaryop_overflow_81
LDI_B 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_79
.binaryop_diffsigns_80
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp >=: Check sign of left operand
LDI_B 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_79            # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_B 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_79
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_82        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_82        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_83
.binarybool_istrue_82
LDI_A 1                          # BinaryOp != was true
.binarybool_done_83
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_84       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_84       # Binary boolean format check, jump if true
JMP .binarybool_done_85          # Binary boolean format check: done
.binarybool_wastrue_84
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_85
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_76           # Condition was true
LDI_A .data_string_19            # "pathfind SYS"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_77                   # Done with false condition
.condition_true_76               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
INCR4_D                          # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
MOV_DH_BH                        # Load base address of attr at offset 7 into B
MOV_DL_BL                        # Load base address of attr at offset 7 into B
DECR4_D                          # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char attr
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 16                         # Constant assignment 0x10 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
INCR_D                           # Load base address of attr at offset 7 into B
MOV_DH_BH                        # Load base address of attr at offset 7 into B
MOV_DL_BL                        # Load base address of attr at offset 7 into B
DECR4_D                          # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
DECR_D                           # Load base address of attr at offset 7 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_86           # Condition was true
LDI_A .data_string_20            # "pathfind SYS is dir"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_87                   # Done with false condition
.condition_true_86               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
.end_if_87                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.end_if_77                       # End If
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of h at offset 1 into A
MOV_DH_AH                        # Load base address of h at offset 1 into A
MOV_DL_AL                        # Load base address of h at offset 1 into A
DECR_D                           # Load base address of h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_21            # "NOEXIST.TXT"
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_88              # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_89
.pathfind_err_88
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_89
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
LDI_A .data_string_22            # "pathfind NOEXIST"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_A 0                          # Constant assignment 0x0000 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_u16
# function returns nothing, not popping a return value
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of h at offset 1 into A
MOV_DH_AH                        # Load base address of h at offset 1 into A
MOV_DL_AL                        # Load base address of h at offset 1 into A
DECR_D                           # Load base address of h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_23            # "SYS/.."
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_90              # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_91
.pathfind_err_90
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_91
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_96       # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_97         # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_94           # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_B 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_95             # Signed BinaryOp >=: Assume signs were the same
LDI_B 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_95            # Signed BinaryOp >=: Signs were different
.binaryop_equal_94
LDI_B 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_95
.binaryop_overflow_97
LDI_B 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_95
.binaryop_diffsigns_96
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp >=: Check sign of left operand
LDI_B 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_95            # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_B 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_95
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_98        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_98        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_99
.binarybool_istrue_98
LDI_A 1                          # BinaryOp != was true
.binarybool_done_99
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_100      # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_100      # Binary boolean format check, jump if true
JMP .binarybool_done_101         # Binary boolean format check: done
.binarybool_wastrue_100
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_101
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_92           # Condition was true
LDI_A .data_string_24            # "pathfind SYS/.."
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_93                   # Done with false condition
.condition_true_92               # Condition was true
CALL :pass
# function returns nothing, not popping a return value
LDI_A .data_string_25            # "pathfind SYS/.. cluster==root"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_A 0                          # Constant assignment 0x0000 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.end_if_93                       # End If
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of h at offset 1 into A
MOV_DH_AH                        # Load base address of h at offset 1 into A
MOV_DL_AL                        # Load base address of h at offset 1 into A
DECR_D                           # Load base address of h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_26            # "SYS/../SYS"
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_102             # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_103
.pathfind_err_102
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_103
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_108      # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_109        # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_106          # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_B 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_107            # Signed BinaryOp >=: Assume signs were the same
LDI_B 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_107           # Signed BinaryOp >=: Signs were different
.binaryop_equal_106
LDI_B 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_107
.binaryop_overflow_109
LDI_B 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_107
.binaryop_diffsigns_108
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp >=: Check sign of left operand
LDI_B 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_107           # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_B 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_107
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_110       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_110       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_111
.binarybool_istrue_110
LDI_A 1                          # BinaryOp != was true
.binarybool_done_111
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_112      # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_112      # Binary boolean format check, jump if true
JMP .binarybool_done_113         # Binary boolean format check: done
.binarybool_wastrue_112
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_113
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_104          # Condition was true
LDI_A .data_string_27            # "pathfind SYS/../SYS"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_105                  # Done with false condition
.condition_true_104              # Condition was true
CALL :pass
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.end_if_105                      # End If
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
INCR_D                           # Load base address of h at offset 1 into A
MOV_DH_AH                        # Load base address of h at offset 1 into A
MOV_DL_AL                        # Load base address of h at offset 1 into A
DECR_D                           # Load base address of h at offset 1 into A
CALL :heap_push_A                # Save fs_handle_out pointer on heap
LDI_A .data_string_28            # "/"
CALL :heap_push_A                # Push path address param
CALL :fat16_pathfind
CALL :heap_pop_A                 # Pop pathfind result
ALUOP_PUSH %A%+%AH%              # Save result
ALUOP_PUSH %A%+%AL%              # Save result
ALUOP_FLAGS %A>>1%+%AH%          # Shift AH right: 0 if AH < 2 (error)
JZ .pathfind_err_114             # Jump to error path if AH < 0x02
CALL :heap_pop_A                 # Pop fs_handle address
PUSH_DH                          # Save frame pointer
PUSH_DL                          # Save frame pointer
CALL :heap_pop_D                 # Pop fs_handle_out pointer
ALUOP_ADDR_D %A%+%AH%            # Store fs_handle hi at *out
INCR_D
ALUOP_ADDR_D %A%+%AL%            # Store fs_handle lo at *(out+1)
POP_DL                           # Restore frame pointer
POP_DH                           # Restore frame pointer
JMP .pathfind_done_115
.pathfind_err_114
CALL :heap_pop_word              # Discard saved fs_handle_out pointer
.pathfind_done_115
POP_AL                           # Restore return value
POP_AH                           # Restore return value
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
ALUOP_ADDR_B %A%+%AL%            # Store to  struct fat16_dirent *entry
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  struct fat16_dirent *entry
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
# Cast  struct fat16_dirent *entry to  unsigned short 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short addr
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
LDI_A 64                         # Constant assignment 0x40 as int
ALUOP_PUSH %A%+%AH%              # BinaryOp >>: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >>: Save A for generating rhs
LDI_A 8                          # Constant assignment 8 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
INCR4_D                          # Load base address of addr at offset 5 into A
INCR_D                           # Load base address of addr at offset 5 into A
MOV_DH_AH                        # Load base address of addr at offset 5 into A
MOV_DL_AL                        # Load base address of addr at offset 5 into A
DECR4_D                          # Load base address of addr at offset 5 into A
DECR_D                           # Load base address of addr at offset 5 into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_BL %B%+%BH%                # BinaryOp >> 8 positions
LDI_BH 0x00                      # BinaryOp >> 8 positions
POP_AL                           # BinaryOp >>: Restore A after use for rhs
POP_AH                           # BinaryOp >>: Restore A after use for rhs
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Check if signs differ
JNZ .binaryop_diffsigns_120      # Signed BinaryOp >=: XOR of MSB == 0 if signs are the same, or nonzero if signs differ
ALUOP16O_FLAGS %ALU16_sA-B%      # Signed BinaryOp >=: Subtract to check O flag
JO .binaryop_overflow_121        # Signed BinaryOp >=: If overflow, result will be true
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Signed BinaryOp >=: check 16-bit equality
JEQ .binaryop_equal_118          # Signed BinaryOp >=: If equal, we know if true/false now
ALUOP16O_B %ALU16_sA-B%          # Signed BinaryOp >=: Subtract to check for sign change
ALUOP_FLAGS %Amsb^Bmsb%+%AH%+%BH% # Signed BinaryOp >=: Compare signs
LDI_B 0                          # Signed BinaryOp >=: Assume no sign change -> false
JZ .binaryop_done_119            # Signed BinaryOp >=: Assume signs were the same
LDI_B 1                          # Signed BinaryOp >=: Signs were different -> true
JMP .binaryop_done_119           # Signed BinaryOp >=: Signs were different
.binaryop_equal_118
LDI_B 1                          # Signed BinaryOp >=: true because equal
JMP .binaryop_done_119
.binaryop_overflow_121
LDI_B 1                          # Signed BinaryOp >=: true because signed overflow
JMP .binaryop_done_119
.binaryop_diffsigns_120
ALUOP_FLAGS %Bmsb%+%BH%          # Signed BinaryOp >=: Check sign of left operand
LDI_B 0                          # Signed BinaryOp >=: assume false
JNZ .binaryop_done_119           # Signed BinaryOpn >=: if left side sign bit is set, return false
LDI_B 1                          # Signed BinaryOp >=: flip to true
.binaryop_done_119
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR4_D                          # Load base address of addr at offset 5 into B
INCR_D                           # Load base address of addr at offset 5 into B
MOV_DH_BH                        # Load base address of addr at offset 5 into B
MOV_DL_BL                        # Load base address of addr at offset 5 into B
DECR4_D                          # Load base address of addr at offset 5 into B
DECR_D                           # Load base address of addr at offset 5 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_122       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_122       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_123
.binarybool_istrue_122
LDI_A 1                          # BinaryOp != was true
.binarybool_done_123
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_124      # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_124      # Binary boolean format check, jump if true
JMP .binarybool_done_125         # Binary boolean format check: done
.binarybool_wastrue_124
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_125
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_116          # Condition was true
LDI_A .data_string_29            # "pathfind /"
CALL :heap_push_A                # Push parameter  char *name (pointer)
CALL :fail_test
# function returns nothing, not popping a return value
JMP .end_if_117                  # Done with false condition
.condition_true_116              # Condition was true
CALL :pass
# function returns nothing, not popping a return value
LDI_A .data_string_30            # "pathfind / is dir"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_AL 16                        # Constant assignment 0x10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_BL 16                        # Constant assignment 0x10 for  unsigned char actual
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_u8
# function returns nothing, not popping a return value
LDI_A .data_string_31            # "pathfind / cluster==0"
CALL :heap_push_A                # Push parameter  char *name (pointer)
LDI_A 0                          # Constant assignment 0x0000 for  unsigned short expected
CALL :heap_push_A                # Push parameter  unsigned short expected
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
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
CALL :heap_push_A                # Push parameter  unsigned short actual
CALL :assert_u16
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load pointer
ALUOP_PUSH %B%+%BH%              # Save B while we load pointer
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
INCR_D                           # Load base address of entry at offset 3 into B
MOV_DH_BH                        # Load base address of entry at offset 3 into B
MOV_DL_BL                        # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
DECR_D                           # Load base address of entry at offset 3 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, pointer value in A
POP_BL                           # Restore B, pointer value in A
CALL :free                       # Free memory at address in A
.end_if_117                      # End If
.test_pathfind_return_73
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
LDI_C .data_string_32            # "=== cctest5: FAT16 refactor ===\n\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_33            # "[1] dirwalk\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_dirwalk
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_34            # "[2] dir_find\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_dir_find
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_35            # "[3] readfile\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_readfile
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_36            # "[4] pathfind\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
CALL :test_pathfind
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_fail                  # Load base address of fail into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short fail
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_total                 # Load base address of total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter  unsigned short total
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_37            # "\nRan %U, Failed %U\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.main_return_126
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
LDI_B .var_total                 # Load base address of total into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short total
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short total
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short total
LDI_B .var_fail                  # Load base address of fail into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for  unsigned short fail
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to  unsigned short fail
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to  unsigned short fail
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned short fail
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to  unsigned short fail
RET
.data_string_0 "FAIL [\0"
.data_string_1 "]\n\0"
.data_string_2 "] exp=0x%x got=0x%x\n\0"
.data_string_3 "] exp=0x%X got=0x%X\n\0"
.data_string_4 "dirwalk_start\0"
.data_string_5 "dirwalk count>=2\0"
.data_string_6 "SYS\0"
.data_string_7 "dir_find SYS found\0"
.data_string_8 "dir_find SYS is dir\0"
.data_string_9 "dir_find SYS cluster>0\0"
.data_string_10 "/SYSTEM.ODY\0"
.data_string_11 "readfile pathfind\0"
.data_string_12 "readfile malloc\0"
.data_string_13 "  entry=%X cluster=%X h=%X buf=%X\n\0"
.data_string_14 "readfile status\0"
.data_string_15 "  buf[0..2]=%x %x %x\n\0"
.data_string_16 "ODY magic O\0"
.data_string_17 "ODY magic D\0"
.data_string_18 "ODY magic Y\0"
.data_string_19 "pathfind SYS\0"
.data_string_20 "pathfind SYS is dir\0"
.data_string_21 "NOEXIST.TXT\0"
.data_string_22 "pathfind NOEXIST\0"
.data_string_23 "SYS/..\0"
.data_string_24 "pathfind SYS/..\0"
.data_string_25 "pathfind SYS/.. cluster==root\0"
.data_string_26 "SYS/../SYS\0"
.data_string_27 "pathfind SYS/../SYS\0"
.data_string_28 "/\0"
.data_string_29 "pathfind /\0"
.data_string_30 "pathfind / is dir\0"
.data_string_31 "pathfind / cluster==0\0"
.data_string_32 "=== cctest5: FAT16 refactor ===\n\n\0"
.data_string_33 "[1] dirwalk\n\0"
.data_string_34 "[2] dir_find\n\0"
.data_string_35 "[3] readfile\n\0"
.data_string_36 "[4] pathfind\n\0"
.data_string_37 "\nRan %U, Failed %U\n\0"
.var_total "\0\0"
.var_fail "\0\0"
