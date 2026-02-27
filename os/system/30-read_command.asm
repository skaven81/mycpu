# vim: syntax=asm-mycpu

###
# :read_command -- reads a command from the user and tokenizes it
#
# Allocates memory for the raw input string and the argv pointer array,
# then splits the input on spaces.
#
# Outputs (stored in static local vars):
#   :shell_argc      -- byte: number of tokens (0 if user pressed enter)
#   :shell_argv_ptr  -- word: address of malloc'd argv pointer array
#   :shell_input_ptr -- word: address of malloc'd raw input string
#
# The argv array contains (hi_ptr, lo_ptr) pairs, null-terminated (0x0000).
# Each pointer points to a malloc'd null-terminated token string.
# argv[0] = command name (lowercase, as typed by user).
###
:read_command
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Read input from the user; result will be in cursor marks 0 and 1
CALL :input
# input doesn't wrap to the next line, so do that now
LDI_AL '\n'
CALL :putchar

# Allocate memory for storing the user's input (1 segment = 128 bytes)
LDI_AL 1
CALL :calloc_segments            # A = input buffer address
# Write input buffer address to :shell_input_ptr
LDI_C :shell_input_ptr
ALUOP_ADDR_C %A%+%AH%           # write hi byte
INCR_C
ALUOP_ADDR_C %A%+%AL%           # write lo byte

# Allocate argv pointer array (4 blocks = 64 bytes = up to 31 args + null)
# TODO: add overflow detection after strsplit -- if argc > 31, print a
# warning and truncate to avoid writing past the end of the argv array.
LDI_AL 4
CALL :calloc_blocks              # A = argv array address
# Write argv array address to :shell_argv_ptr
LDI_C :shell_argv_ptr
ALUOP_ADDR_C %A%+%AH%           # write hi byte
INCR_C
ALUOP_ADDR_C %A%+%AL%           # write lo byte

# Check if mark 1 == mark 0. If so, the user didn't enter
# any input at all and we return with argc=0.
LDI_AL 0
CALL :cursor_get_mark            # offset of mark 0 in A
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%               # offset of mark 0 now in B
LDI_AL 1
CALL :cursor_get_mark            # offset of mark 1 in A
ALUOP_FLAGS %A&B%+%AL%+%BL%     # AL==BL?
JNE .process_input               # if unequal, OK to proceed
ALUOP_FLAGS %A&B%+%AH%+%BH%     # AH==BH?
JNE .process_input               # if unequal, OK to proceed

# Empty input: set argc=0 and write null pair to argv array start
LDI_C :shell_argc
ALUOP_ADDR_C %zero%              # :shell_argc = 0
# Write null pair (0x00, 0x00) to start of argv array
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL                         # A = argv array address
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                # C = argv array start
ALUOP_ADDR_C %zero%              # write hi byte of null ptr
INCR_C
ALUOP_ADDR_C %zero%              # write lo byte of null ptr
JMP .read_command_done

.process_input
# Load input buffer address into D for cursor_mark_getstring
LDI_C :shell_input_ptr
LDA_C_AH
INCR_C
LDA_C_AL                         # A = input buffer address
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                # D = input buffer address
LDI_AL 0                         # left mark = 0
LDI_BL 1                         # right mark = 1
CALL :cursor_mark_getstring      # copies display chars to buffer at D
                                  # D restored to input buffer start by heap_pop_all

# Set up for strsplit: C = source (input buffer), D = dest (argv array)
# D currently = input buffer start (restored by cursor_mark_getstring)
# Push D, load argv array into D via C, then pop input buffer into C
PUSH_DH
PUSH_DL
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL                         # A = argv array address
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                # D = argv array address
POP_CL
POP_CH                            # C = input buffer start

LDI_AH ' '                       # split on spaces
LDI_AL 2                          # allocate 2 blocks (32 bytes) for each token
CALL :strsplit                    # AH = token count; array written to D

# Save token count to :shell_argc
LDI_C :shell_argc
ALUOP_ADDR_C %A%+%AH%            # :shell_argc = token count

.read_command_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET
