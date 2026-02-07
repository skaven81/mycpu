# vim: syntax=asm-mycpu

:cmd_type

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
CALL :heap_pop_B                # directory entry (or error) in B

LDI_AL 0x01
ALUOP_FLAGS %A&B%+%BH%+%AL%     # Check high byte for error
JZ .retzero
JEQ .ataerr

CALL :heap_push_B
CALL :fat16_dirent_attribute
CALL :heap_pop_AH
ALUOP_PUSH %B%+%BL%
LDI_BL 0x10                     # directory bit
ALUOP_FLAGS %A&B%+%AH%+%BL%
POP_BL
JNZ .notfile

# If we make it here, B contains the directory entry
# of the file we want to print. The filesystem handle
# is still on the heap.
# TODO use :fat16_streamfile to read the file one sector
# at a time, and print out the contents.

ALUOP_AH %B%+%BH%               # copy directory entry address to A
ALUOP_AL %B%+%BL%
CALL :free                      # and free that memory

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

# If here, a directory entry was found, but it was a directory,
# not a file.
.notfile
CALL :heap_pop_word             # discard filesystem handle address
LDI_C .notfile_str
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

.helpstr "Usage: type PATH\n\0"
.syntax_err "Error: unparseable path spec\n\0"
.notfound_str "File not found\n\0"
.notfile_str "Path is a directory, not a file\n\0"
.ataerr_str "ATA error: %x\n\0"
