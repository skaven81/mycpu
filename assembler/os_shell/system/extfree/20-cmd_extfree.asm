# vim: syntax=asm-mycpu

:cmd_extfree

# Ensure we have an argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Convert the argument into an integer
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_page

# Free the page
CALL :heap_push_AL              # put page to free onto heap
CALL :extfree                   # free the page
RET

.abort_bad_page
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_page_str
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: extfree <page>\n\0"
.bad_page_str "Error: %s is not a valid page number. strtoi flags: 0x%x\n\0"
