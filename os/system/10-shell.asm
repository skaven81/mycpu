# vim: syntax=asm-mycpu

###
# :shell_main -- entry point for the SYSTEM.ODY shell
#
# Called by the BIOS exec loop with argc/argv on the heap.
# We discard them since the shell manages its own command-line parsing.
# The BIOS exec loop will free the original argv strings/array after we RET.
#
# Loops internally for built-in commands. Returns to BIOS exec loop
# (with return code 0x0000 on heap) when an external ODY is requested
# via the IPC block ($exec_dirent_ptr != 0x0000).
###
:shell_main
CALL :argv_init                 # pop and discard BIOS-provided argc/argv from heap

.command_loop
CALL :print_prompt
CALL :read_command              # sets :shell_argc, :shell_argv_ptr, :shell_input_ptr

# If argc == 0, user just pressed enter -- free buffers and loop
LDI_C :shell_argc
LDA_C_AL                        # AL = argc
ALUOP_FLAGS %A%+%AL%
JNZ .do_parse
JMP .free_and_loop

.do_parse
CALL :parse_and_run_command

# Check if an external ODY was requested ($exec_dirent_ptr != 0x0000)
LD_AH $exec_dirent_ptr
LD_AL $exec_dirent_ptr+1
ALUOP_FLAGS %A%+%AH%
JNZ .launch_ody
ALUOP_FLAGS %A%+%AL%
JNZ .launch_ody

# Built-in command ran: free all argv strings, argv array, and input buf
.free_and_loop
# Load argv array base address from :shell_argv_ptr
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL                        # A = argv array base address
ALUOP_FLAGS %A%+%AH%
JNZ .have_argv_ptr
ALUOP_FLAGS %A%+%AL%
JZ .free_input                  # argv_ptr is 0x0000, skip to input free

.have_argv_ptr
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv array base address

# Walk argv array: free each non-null string pointer
.free_argv_loop
LDA_C_AH                        # AH = hi byte of string ptr
INCR_C
LDA_C_AL                        # AL = lo byte of string ptr
INCR_C                           # C now points past this (hi, lo) pair
ALUOP_FLAGS %A%+%AH%
JNZ .free_argv_continue
ALUOP_FLAGS %A%+%AL%
JZ .free_argv_done               # null ptr = end of argv array
.free_argv_continue
CALL :free                       # free string at A; C preserved by :free
JMP .free_argv_loop
.free_argv_done

# Free the argv array itself
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL                        # A = argv array address
CALL :free

.free_input
# Free the raw input string
LDI_C :shell_input_ptr
LDA_C_AH
INCR_C
LDA_C_AL                        # A = input buffer address
CALL :free

JMP .command_loop

.launch_ody
# External ODY requested via IPC block.
# BIOS exec loop owns the argv array and strings (already copied
# to $exec_argv_ptr by parse_and_run_command). Only free input string.
LDI_C :shell_input_ptr
LDA_C_AH
INCR_C
LDA_C_AL                        # A = input buffer address
CALL :free

# Push return code 0x0000 and return to BIOS exec loop
LDI_A 0x0000
CALL :heap_push_A
RET

###
# Static local variables for SYSTEM.ODY shell.
# Declared as global ":" labels because they are accessed from multiple
# SYSTEM.ODY source files (30-read_command.asm, 40-parse_command.asm,
# 900-cmd_*.asm).
###
:shell_argc         "\0"                           # byte: argc from last read_command
:shell_argv_ptr     "\0\0"                         # word: malloc'd argv array address
:shell_input_ptr    "\0\0"                         # word: malloc'd raw input string address
:shell_ody_lookup   "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"  # 40 bytes: "COMMAND.ODY" scratch (max 31-char argv[0] + ".ODY\0")
