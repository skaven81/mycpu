# vim: syntax=asm-mycpu

###
# :parse_and_run_command -- parses argv[0] and executes the command
#
# Reads the command name from :shell_argv_ptr (via :shell_get_argv_n),
# checks built-in commands, then searches for a matching .ODY file.
#
# For built-in commands: dispatches via CALL_D, returns normally.
# For external ODY files: sets IPC block ($exec_dirent_ptr, $exec_fsh_ptr,
# $exec_argc, $exec_argv_ptr) and returns; the shell loop detects the
# non-zero $exec_dirent_ptr and returns to the BIOS exec loop.
###

:parse_and_run_command
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Get argv[0] (command name) into C
LDI_AL 0
CALL :shell_get_argv_n          # A = argv[0] string address
ALUOP_FLAGS %A%+%AH%
JNZ .have_cmd
ALUOP_FLAGS %A%+%AL%
JZ .cmd_return                  # null ptr = no command (defensive)
.have_cmd
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv[0] string (command name, lowercase)

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
# Copy argv[0] to :shell_ody_lookup and uppercase it for FAT16 lookup.
# The original argv[0] string is preserved lowercase (POSIX convention).
LDI_D :shell_ody_lookup         # D = scratch buffer for uppercase name
CALL :strcpy                    # copy argv[0] (C) to :shell_ody_lookup (D)
ALUOP_ADDR_D %zero%             # null-terminate (strcpy doesn't copy the null)
# Uppercase the copy in-place
LDI_C :shell_ody_lookup
LDI_D :shell_ody_lookup
CALL :strupper                  # C,D now point at null terminator
# Append .ODY suffix (D points at null = where to append)
LDI_C .ody_suffix
CALL :strcpy                    # append ".ODY" to uppercase name
ALUOP_ADDR_D %zero%             # null-terminate (strcpy doesn't copy the null)

# :shell_ody_lookup now contains "COMMAND.ODY" - search current dir first
LDI_C :shell_ody_lookup
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
LD_CH $boot_fs_handle_ptr
LD_CL $boot_fs_handle_ptr+1
CALL :heap_push_C
CALL :fat16_handle_get_ataid    # pushes drive id (0 or 1) to heap
CALL :heap_pop_AL               # AL = drive id (0 or 1)

LDI_C :shell_ody_lookup
CALL :heap_push_C               # push %s arg (COMMAND.ODY string)
CALL :heap_push_AL              # push %u arg (drive number)
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

# Binary is found. A = dirent_ptr, fsh_ptr still on heap from pathfind.
.found_ody
CALL :heap_pop_C                # C = fsh_ptr (was still on heap from pathfind)

# Set IPC block for BIOS exec loop
ALUOP_ADDR %A%+%AH% $exec_dirent_ptr
ALUOP_ADDR %A%+%AL% $exec_dirent_ptr+1
ST_CH $exec_fsh_ptr
ST_CL $exec_fsh_ptr+1

# Copy :shell_argc to $exec_argc
LDI_C :shell_argc
LDA_C_AL
ALUOP_ADDR %A%+%AL% $exec_argc

# Copy :shell_argv_ptr to $exec_argv_ptr
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL
ALUOP_ADDR %A%+%AH% $exec_argv_ptr
ALUOP_ADDR %A%+%AL% $exec_argv_ptr+1

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
.cmd_080 "ascii\0"         :cmd_ascii
.cmd_090 "clock\0"         :cmd_clock
.cmd_100 "colors\0"        :cmd_colors
.cmd_110 "hexdump\0"       :cmd_hexdump
.cmd_120 "setserial\0"     :cmd_setserial
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

###
# :shell_get_argv_n -- get a pointer to argv[n]
#
# Reads the argv pointer array from :shell_argv_ptr and returns
# the pointer at index n.
#
# Input:
#   AL = index n (0-based)
#
# Output:
#   A = argv[n] string address (0x0000 if beyond end of array)
#
# Saves/restores: BL, C
# Clobbers: A (output)
###
:shell_get_argv_n
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

ALUOP_BL %A%+%AL%               # BL = index n

# Load argv array base address from :shell_argv_ptr into C
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv array base address

# Advance C by 2*BL positions (skip BL (hi,lo) pairs)
ALUOP_FLAGS %B%+%BL%
JZ .get_argv_n_read              # index=0, no advance needed
.get_argv_n_advance
INCR_C
INCR_C                           # skip one (hi,lo) pair
ALUOP_BL %B-1%+%BL%             # BL--
ALUOP_FLAGS %B%+%BL%
JNZ .get_argv_n_advance

.get_argv_n_read
# Read (hi, lo) pair from C into A
LDA_C_AH                        # AH = hi byte of string pointer
INCR_C
LDA_C_AL                        # AL = lo byte of string pointer

POP_CL
POP_CH
POP_BL
RET

.sys_path_template "%u:/SYS/%s\0"
# inline variable as this will be executed from RAM. Maximum length of
# .sys_path string is 1:/SYS/FILENAME.ODY (8+3 filename) which makes
# 20 characters, plus a trailing newline. We allocate 24 bytes just in case.
.sys_path "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.ody_suffix "\.ODY\0"
.cmd_unknown_str "Unrecognized command\n\0"
.cmd_help_header "The following built-in commands are available:\n\0"
.cmd_help_header2 "Also, any .ODY files are executable by typing their name.\n\0"
