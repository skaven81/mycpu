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
# First byte of $current_drive string is '0' or '1' or \0 (not mounted)
LD_AL $current_drive
ALUOP_FLAGS %A%+%AL%
JZ .nodir_prompt

# Load the address of the active filesystem handle into D
LDI_BL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .load_drive_1
.load_drive_0
LD_CH $drive_0_fs_handle
LD_CL $drive_0_fs_handle+1
JMP .load_drive_done
.load_drive_1
LD_CH $drive_1_fs_handle
LD_CL $drive_1_fs_handle+1
.load_drive_done

# If the filesystem handle is uninitialized, then use the "nodir" prompt
LDA_C_AL        # first byte will be '/' if initialized
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .nodir_prompt

# We have an active drive and that drive has an active handle
CALL :heap_push_C       # addr of filehandle == CWD string
LD_AL $current_drive
CALL :heap_push_AL      # current drive char '0' or '1'
LDI_C .prompt
CALL :printf
JMP .prompt_done

.nodir_prompt
LDI_AL '>'
CALL :putchar
LDI_AL ' '
CALL :putchar

.prompt_done
POP_DL
POP_DH
POP_BL
POP_AL
RET

.prompt "%c:%s> \0"
