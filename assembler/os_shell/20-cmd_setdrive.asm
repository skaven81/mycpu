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
LDI_AL '0'
ALUOP_ADDR %A%+%AL% $current_drive
RET

.setdrive_1
LDI_AL '1'
ALUOP_ADDR %A%+%AL% $current_drive
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: 0: or 1:\n\0"
