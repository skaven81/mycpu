# vim: syntax=asm-mycpu

# Handles the :0 and :1 shell commands to change drives

:cmd_setdrive

## Load and check drive selection
LDI_A $user_input_tokens        # Get pointer to command
LDA_A_CH                        # |
LDI_A $user_input_tokens+1      # |
LDA_A_CL                        # |
LDA_C_AL                        # Load first character of command into AL

LDI_BL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .setdrive_0
LDI_BL '1'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .setdrive_1

# If not 0: or 1: then jump to usage
JMP .usage

.setdrive_0
# Check if drive 0 is mounted
LDI_C $drive_0_fs_handle
LDA_C_AH        # AH=first char of filesystem handle=cwd
LDI_AL '0'
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNE .err_not_mounted
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
RET

.setdrive_1
# Check if drive 1 is mounted
LDI_C $drive_1_fs_handle
LDA_C_AH        # AH=first char of filesystem handle=cwd
LDI_AL '1'
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNE .err_not_mounted
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
RET

.err_not_mounted
CALL :heap_push_AL
LDI_C .not_mounted
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: 0: or 1:\n\0"
.not_mounted "Error: Drive %c is not mounted\n\0"
