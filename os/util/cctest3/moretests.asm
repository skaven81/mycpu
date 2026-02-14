CALL .__global_local_init__

.incr_static                     # static unsigned char incr_static()
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
LDI_B .var_incr_static_sui       # Load base address of sui into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+1%+%AL%              # UnaryOp ++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp ++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp ++: Save B before generating lvalue
LDI_B .var_incr_static_sui       # Load base address of sui into B
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char sui
POP_BL                           # UnaryOp ++: Restore B, return rvalue in A
POP_BH                           # UnaryOp ++: Restore B, return rvalue in A
JMP .incr_static_return_1
.incr_static_return_1
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

:test_external_statics           # void test_external_statics()
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
CALL .incr_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL .incr_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
CALL .incr_static
CALL :heap_pop_AL
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char i
LDI_A .data_string_0             # "Local static init in other file"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 83                        # Constant assignment 83 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
INCR_D                           # Load base address of i at offset 1 into B
MOV_DH_BH                        # Load base address of i at offset 1 into B
MOV_DL_BL                        # Load base address of i at offset 1 into B
DECR_D                           # Load base address of i at offset 1 into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
LDI_A .data_string_1             # "Global init in other file"
CALL :heap_push_A                # Push parameter  char *test_name (pointer)
LDI_AL 10                        # Constant assignment 10 for  unsigned char expected
CALL :heap_push_AL               # Push parameter  unsigned char expected
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_g_otherfile           # Load base address of g_otherfile into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char actual
CALL :assert_equal_u8
# function returns nothing, not popping a return value
.test_external_statics_return_2
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

.__global_local_init__
LDI_B .var_g_otherfile           # Load base address of g_otherfile into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 10                        # Constant assignment 10 for  unsigned char g_otherfile
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to  unsigned char g_otherfile
LDI_B .var_incr_static_sui       # Load base address of sui into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 80                        # Constant assignment 80 for static unsigned char sui
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char sui
RET
.data_string_0 "Local static init in other file\0"
.data_string_1 "Global init in other file\0"
.var_g_otherfile "\0"
.var_incr_static_sui "\0"
