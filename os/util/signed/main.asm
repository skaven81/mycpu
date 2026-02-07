# vim: syntax=asm-mycpu

# Verify signed arithmetic
#  Argument 1 (+2/3): LHS argument
#  Argument 2 (+4/5): RHS argument

:signed

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_D $user_input_tokens+4      # D points at second argument pointer
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

## Load RHS argument, push to stack
LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%

## Load LHS argument into A
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags

## Pop RHS argument into B
POP_BH
POP_BL

## Invert A
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
CALL :signed_invert_a
JNO .no_sia_overflow
LDI_C .overflow
CALL :print
.no_sia_overflow
CALL :heap_push_A
LDI_C .si_str
CALL :printf
POP_AH
POP_AL

## Invert B
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
CALL :signed_invert_b
JNO .no_sib_overflow
LDI_C .overflow
CALL :print
.no_sib_overflow
CALL :heap_push_B
LDI_C .si_str
CALL :printf
POP_BH
POP_BL

## Addition
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
CALL :signed_add16_to_a         # result in A
JNO .no_add_overflow
LDI_C .overflow
CALL :print
.no_add_overflow
CALL :heap_push_A
POP_AH
POP_AL
CALL :heap_push_B
CALL :heap_push_A
LDI_C .add_str
CALL :printf

## A - B
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
CALL :my_signed_sub16_a_minus_b    # result in A
JNO .no_sub1_overflow
LDI_C .overflow
CALL :print
.no_sub1_overflow
CALL :heap_push_A
POP_AH
POP_AL
CALL :heap_push_B
CALL :heap_push_A
LDI_C .sub_str
CALL :printf

## B - A
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
CALL :my_signed_sub16_b_minus_a    # result in B
JNO .no_sub2_overflow
LDI_C .overflow
CALL :print
.no_sub2_overflow
CALL :heap_push_B
POP_AH
POP_AL
CALL :heap_push_A
CALL :heap_push_B
LDI_C .sub_str
CALL :printf

## Done
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: signed LHS RHS\n\0"
.add_str "%D + %D = %D\n\0"
.sub_str "%D - %D = %D\n\0"
.si_str "%D inverted\n\0"
.overflow "OVERFLOW!\n\0"

:my_signed_sub16_a_minus_b
ALUOP_AL %A-B%+%AL%+%BL%
JO .borrow1
ALUOP_AH %A-B_signed%+%AH%+%BH%
RET
.borrow1
ALUOP_AH %A-B-1_signed%+%AH%+%BH%
RET

:my_signed_sub16_b_minus_a
ALUOP_BL %B-A%+%AL%+%BL%
JO .borrow2
ALUOP_BH %B-A_signed%+%AH%+%BH%
RET
.borrow2
ALUOP_BH %B-A-1_signed%+%AH%+%BH%
RET
