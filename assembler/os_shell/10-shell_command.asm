# vim: syntax=asm-mycpu

# Primary shell loop. Prints a prompt, reads a command, tokenizes the string, pops
# the first token, checks if it is a known command, then calls that command with
# the remaining tokens on the heap.

:shell_command
CALL :heap_push_all
LDI_AL '>'
CALL :putchar
LDI_AL ' '
CALL :putchar

# Read input from the user; result will be in cursor marks 0 and 1
CALL :input
# input doesn't wrap to the next line, so do that now
LDI_AL '\n'
CALL :putchar

# Check if mark 1 == mark 0. If so, the user didn't enter
# any input at all and we return without doing anything.
LDI_AL 0
CALL :cursor_get_mark           # offset of mark 0 in A
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%               # offset of mark 0 now in B
LDI_AL 1
CALL :cursor_get_mark           # offset of mark 1 in A
ALUOP_FLAGS %A&B%+%AL%+%BL%     # AL==BL?
JNE .process_input              # if unequal, OK to proceed
ALUOP_FLAGS %A&B%+%AH%+%BH%     # AH==BH?
JNE .process_input              # if unequal, OK to proceed
CALL :heap_pop_all
RET                             # if equal, return without doing anything

.process_input
VAR global word $user_input_buf
VAR global 32 $user_input_tokens # store up to 16 tokens
LDI_AL 7                        # allocate 8 blocks (1 segment, 128 bytes)
CALL :malloc                    # for storing the user's input
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # copy memory address to D
ALUOP_ADDR %A%+%AH% $user_input_buf     # Save our user input buffer
ALUOP_ADDR %A%+%AL% $user_input_buf+1   # address so we can free it later
LDI_AL 0                        # left mark = 0
LDI_BL 1                        # right mark = 1
CALL :cursor_mark_getstring     # D now points at a null-terminated copy of the user's input

CALL :heap_push_D
LDI_C .outstr1
CALL :printf

PUSH_DH                         # copy D to C
PUSH_DL                         # |
POP_CL                          # |
POP_CH                          # C now points at our input string
LDI_D $user_input_tokens        # D now points at our token array
LDI_AH ' '                      # split on spaces
LDI_AL 1                        # allocate 2 blocks (32 bytes) for each token
CALL :strsplit

CALL :heap_push_AH
LDI_C .outstr2
CALL :printf

LDI_BH 0                        # output token counter

.print_token_loop
LDA_D_AH
INCR_D
LDA_D_AL                        # this token's pointer now in A
INCR_D
ALUOP_FLAGS %A%+%AH%
JNZ .print_token_loop_continue
ALUOP_FLAGS %A%+%AL%
JNZ .print_token_loop_continue
JMP .print_token_loop_done

.print_token_loop_continue
CALL :heap_push_A
CALL :heap_push_AL
CALL :heap_push_AH
CALL :heap_push_BH
LDI_C .outstr3
CALL :printf
LDI_BL 1
CALL :free                      # A = current token pointer, BL=size, so we can free now
ALUOP_BH %B+1%+%BH%             # increment token count
JMP .print_token_loop

.print_token_loop_done
LD16_A $user_input_buf
LDI_BL 7
CALL :free                      # Free the memory where we stored user input

CALL :heap_pop_all
RET

.outstr1 "Your input: [%s]\n\0"
.outstr2 "Split into %u tokens\n\0"
.outstr3 "Token %u at 0x%x%x: [%s]\n\0"

