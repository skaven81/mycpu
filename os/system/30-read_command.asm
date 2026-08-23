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

# Allocate memory for storing the user's input (1 segment = 128 bytes)
LDI_AL 1
CALL :calloc_segments            # A = input buffer address
# Write input buffer address to :shell_input_ptr
LDI_C :shell_input_ptr
ALUOP_ADDR_C %A%+%AH%           # write hi byte
INCR_C
ALUOP_ADDR_C %A%+%AL%           # write lo byte

# Read a line of input directly into the buffer (:readline edits the
# caller-supplied buffer in place -- no marks, no separate copy step).
# Accept both keyboard and UART so the shell is drivable remotely over
# serial (the whole point of the serrun workflow) as well as locally.
# :readline itself echoes the trailing newline, so no manual putchar here.
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                # C = input buffer address
LDI_AL 128                       # maxlen incl. null terminator (1 segment)
LDI_AH 0x07                      # bit0 echo, bit1 keyboard, bit2 UART
CALL :readline                   # AL=length (0=blank Enter or Ctrl+C), AH=status

# Allocate argv pointer array (4 blocks = 64 bytes = up to 31 args + null)
# TODO: add overflow detection after strsplit -- if argc > 31, print a
# warning and truncate to avoid writing past the end of the argv array.
ALUOP_PUSH %A%+%AL%              # save readline's returned length across calloc_blocks
LDI_AL 4
CALL :calloc_blocks              # A = argv array address
# Write argv array address to :shell_argv_ptr
LDI_C :shell_argv_ptr
ALUOP_ADDR_C %A%+%AH%           # write hi byte
INCR_C
ALUOP_ADDR_C %A%+%AL%           # write lo byte
POP_AL                           # restore readline's returned length

# If length == 0 (blank Enter or Ctrl+C), the user didn't enter any
# input at all and we return with argc=0.
ALUOP_FLAGS %A%+%AL%
JNE .process_input

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
# Set up for strsplit: C = source (input buffer), D = dest (argv array)
LDI_C :shell_argv_ptr
LDA_C_AH
INCR_C
LDA_C_AL                         # A = argv array address
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                # D = argv array address

LDI_C :shell_input_ptr
LDA_C_AH
INCR_C
LDA_C_AL                         # A = input buffer address
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                # C = input buffer start (source)

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
