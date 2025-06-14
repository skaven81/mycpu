# vim: syntax=asm-mycpu

###
# Parses the command in $user_input_tokens[0] and executes it.

:parse_and_run_command
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

LDI_B $user_input_tokens        # B now points at the first entry in the token array

LDA_B_CH                        # CH=hi byte of token[0] string pointer
CALL :incr16_b
LDA_B_CL                        # CL=lo byte of token[0] string pointer

# C is a pointer to the first token provided by the user (the command), with the
# rest of the tokens in the $user_input_tokens array being the arguments.
# We now search for a command matching the string in C.

# If the string is empty, the user just pressed enter so just exit
# without running a command.
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .cmd_return

# Loop through the list of built-in commands and find
# a matching one.  The function address is
# located in the two bytes after the string.
LDI_D .cmd_list
.check_builtin_cmd_loop
LDA_D_AL                        # load first char of command into AL
ALUOP_FLAGS %A%+%AL%            # check if null
JZ .try_files                   # if so, exit loop, we didn't find a match

PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
CALL :strcmp                    # AL will be zero if string in C (cmd)
POP_DL                          # matches string in D (item in list)
POP_DH
POP_CL
POP_CH
ALUOP_FLAGS %A%+%AL%
JZ .run_builtin_cmd
                                # no match, so fast-forward D to next
.check_cmd_ffd                  # command, or bail if we reach the end
LDA_D_AL
INCR_D
ALUOP_FLAGS %A%+%AL%
JNZ .check_cmd_ffd
                                # D points at the high byte of the label
INCR_D                          # D now points at the low byte of the label
INCR_D                          # D now points at the next command
JMP .check_builtin_cmd_loop     # loop to next builtin command

.try_files                      # Look for .ODY files matching the command
PUSH_CH
PEEK_DH
PUSH_CL
PEEK_DL                         # Make C and D point to same address, the command string
CALL :strupper                  # make uppercase; C and D point at terminating null
LDI_C .ody_suffix
CALL :strcpy                    # append .ODY suffix
ALUOP_ADDR_D %zero%             # write terminating null to D address
POP_CL                          # restore C pointer to beginning of string,
POP_CH                          # which is now uppercase, with .ODY extension

# C points at a string that is COMMAND.ODY - search for this first
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # A will be 0x00.. or 0x01.. if not found
ALUOP_FLAGS %A%+%AH%
JZ .try_sys_path
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .try_sys_path
JMP .found_ody

# command was not found in current dir, try {boot_drive}:/SYS/COMMAND.ODY
.try_sys_path
PUSH_CH
PUSH_CL
LD_CH $boot_fs_handle_ptr
LD_CL $boot_fs_handle_ptr+1
CALL :heap_push_C
CALL :fat16_handle_get_ataid    # 0 or 1 on heap
CALL :heap_pop_AL
POP_CL
POP_CH

CALL :heap_push_C               # still the COMMAND.ODY string
CALL :heap_push_AL              # the 0 or 1
LDI_C .sys_path_template
LDI_D .sys_path
CALL :sprintf                   # .sys_path now contains {0,1}:/SYS/COMMAND.ODY

LDI_D .sys_path
CALL :heap_push_D
CALL :fat16_pathfind
CALL :heap_pop_A                # A will be 0x00.. or 0x01.. if not found
ALUOP_FLAGS %A%+%AH%
JZ .tryfiles_failed_notfound
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .tryfiles_failed_notfound

# Binary is found, A contains the address of a copy
# of the directory entry (which needs to be freed)
.found_ody
                                # fs handle is already on heap
CALL :heap_push_A               # directory entry
CALL :run_ody
# free the directory entry
CALL :free
JMP .cmd_return

.tryfiles_failed_notfound
LDI_C .cmd_unknown_str
CALL :print
JMP .cmd_return

## Run the built-in command
.run_builtin_cmd                # It was a match for built-in, so fast-forward D to the label
LDA_D_AL
INCR_D
ALUOP_FLAGS %A%+%AL%
JNZ .run_builtin_cmd

LDA_D_AH                        # Load the label address high byte into AH
INCR_D
LDA_D_AL                        # Load the label address low byte into AL
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # copy the label address to D
CALL :heap_push_all
CALL_D
CALL :heap_pop_all

.cmd_return
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.cmd_list
.cmd_000 "0:\0"             :cmd_setdrive
.cmd_001 "1:\0"             :cmd_setdrive
.cmd_010 "cd\0"             :cmd_cd
.cmd_020 "clear\0"          :cmd_clear
.cmd_030 "dir\0"            :cmd_dir
.cmd_040 "help\0"           .print_help
.cmd_050 "mount\0"          :cmd_mount
.cmd_060 "peek\0"           :cmd_peek
.cmd_070 "poke\0"           :cmd_poke
.cmd_end 0x00

#####
# Help output, prints list of available commands
.print_help
LDI_C .cmd_help_header
CALL :print

LDI_C .cmd_list
.print_help_loop
LDA_C_AL                        # load first char of command into AL
ALUOP_FLAGS %A%+%AL%            # check if null
JZ .print_help_done             # if so, exit loop
CALL :print
LDI_AL ' '
CALL :putchar
CALL :putchar
.print_help_ff                  # fast-forward C to the next command
LDA_C_AL
INCR_C
ALUOP_FLAGS %A%+%AL%
JZ .print_help_next_loop
JMP .print_help_ff
.print_help_next_loop
INCR_C                          # C now at low byte of label
INCR_C                          # C now at next command
JMP .print_help_loop

.print_help_done
LDI_AL '\n'
CALL :putchar
LDI_C .cmd_help_header2
CALL :print
CALL :putchar
RET

.sys_path_template "%u:/SYS/%s\0"
# inline variable as this will be executed from RAM. Maximum length of
# .sys_path string is 1:/SYS/FILENAME.ODY (8+3 filename) which makes
# 20 characters, plus a trailing newline. We allocate 24 bytes just in case.
.sys_path "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.ody_suffix "\.ODY\0"
.cmd_unknown_str "Unrecognized command\n\0"
.cmd_failed_ataerr "ATA error looking for command: 0x%x\n\0"
.cmd_failed_nodrive "Drive not set, can't seek .ODYs\n\0"
.cmd_help_header "The following built-in commands are available:\n\0"
.cmd_help_header2 "Also, any .ODY files are executable by typing their name.\n\0"

