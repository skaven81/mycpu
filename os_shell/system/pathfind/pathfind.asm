# vim: syntax=asm-mycpu

:cmd_pathfind

# Ensure we have an argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

CALL :heap_push_A               # address of path string
CALL :fat16_pathfind
CALL :heap_pop_B                # directory entry (or error)

LDI_AL 0x01
ALUOP_FLAGS %A&B%+%BH%+%AL%     # Check high byte for error
JZ .retzero
JEQ .ataerr

# If here, entry was found, and B contains the address
# of the directory entry. The address of the filesystem handle
# is still on the heap.
CALL :fat16_handle_get_ataid    # ATA ID read from FS handle, ID on stack
LDI_C .found_preamble
CALL :printf

# Print the directory entry
CALL :heap_push_B
CALL :fat16_dirent_string       # get the stringified version of the dirent
CALL :heap_pop_C                # address of generated string in C
PUSH_CH
PUSH_CL
CALL :print                     # print the directory entry
POP_CL
POP_CH
LDI_AL '\n'
CALL :putchar                   # print a trailing newline
# Free the directory entry string
ALUOP_PUSH %B%+%BL%             # save the low byte of the directory entry
MOV_CH_AH
MOV_CL_AL
CALL :free                      # Free the directory entry string
# Free the directory entry
ALUOP_AH %B%+%BH%
POP_AL                          # from the push above
CALL :free                      # Free the directory entry
RET

# If here, either there was a syntax error with the path, or
# the path was not found.
.retzero
ALUOP_FLAGS %B%+%BL%
JZ .notfound

# If here, syntax error
LDI_C .syntax_err
CALL :print
RET

# If here, no error, but not found
.notfound
LDI_C .notfound_str
CALL :print
RET

# If here, an ATA error was raised,
# and BL contains the error
.ataerr
LDI_C .ataerr_str
CALL :heap_push_BL
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: pathfind PATH\n\0"
.found_preamble "Entry found on drive %u:\n\0"
.syntax_err "Error: unparseable path spec\n\0"
.notfound_str "File/dir not found\n\0"
.ataerr_str "ATA error: %x\n\0"
