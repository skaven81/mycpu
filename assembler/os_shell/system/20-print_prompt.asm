# vim: syntax=asm-mycpu

###
# Build up and print the prompt. Takes no arguments and returns nothing.
###
:print_prompt
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Check if we have a drive currently selected
CALL :fat16_get_current_drive_number
CALL :heap_pop_AL
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .nodir_prompt

# Load the address of the active filesystem handle into C
LD_CH $current_fs_handle
LD_CL $current_fs_handle+1

# If the filesystem handle is uninitialized, then use the "nodir" prompt
LDA_C_AL        # first byte will be '/' if initialized
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .nodir_prompt

# We have an active drive and that drive has an active handle
CALL :heap_push_C                    # addr of filehandle == CWD string
CALL :fat16_get_current_drive_number
CALL :heap_pop_AL                    # drive number in AL
LDI_BL 0x30                          # Add 0x30 to the drive number to get char '0' or '1',
ALUOP_AL %A+B%+%AL%+%BL%             # this is much less work than the %u printf routine
CALL :heap_push_AL
LDI_C .prompt
CALL :printf
JMP .prompt_done

.nodir_prompt
LDI_AL '>'
CALL :putchar
LDI_AL ' '
CALL :putchar

.prompt_done
POP_CL
POP_CH
POP_BL
POP_AL
RET

.prompt "%c:%s> \0"
