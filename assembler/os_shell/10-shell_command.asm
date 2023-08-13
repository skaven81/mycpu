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

PUSH_DH                         # copy D to C
PUSH_DL                         # |
POP_CL                          # |
POP_CH                          # C now points at our input string
LDI_D $user_input_tokens        # D now points at our token array
LDI_AH ' '                      # split on spaces
LDI_AL 1                        # allocate 2 blocks (32 bytes) for each token
CALL :strsplit                  # AH=num tokens, D=null-terminated array of tokens
CALL .print_deconstructed_command


LDI_B $user_input_tokens        # B now points at the first entry in the token array

LDA_B_CH                        # CH=hi byte of token[0] string pointer
CALL :incr16_b
LDA_B_CL                        # CL=lo byte of token[0] string pointer
CALL :incr16_b                  # B now points at the second entry in the token array

# C is the first token provided by the user (the command), with the
# rest of the tokens in the $user_input_tokens array being the arguments.
# We now search for a command matching the string in C.
CALL :heap_push_all             # save registers in case called command mangles them

.check_cmd_clear
LDI_D .cmd_clear
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JNZ .check_cmd_clockspeed
CALL :cmd_clear
JMP .next_command

.check_cmd_clockspeed
LDI_D .cmd_clockspeed
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JNZ .unknown_command
CALL :cmd_clockspeed
JMP .next_command

.unknown_command
CALL :heap_push_C
LDI_C .cmd_unknown
CALL :printf

.next_command
CALL :heap_pop_all              # restore registers after running command

####
# Free the memory we allocated above
####
LDI_C $user_input_tokens        # Load token array pointer into C
.free_tokens_loop               # and begin freeing RAM until we find a null
LDA_C_AH                        # string ptr hi into AH
INCR_C
LDA_C_AL                        # string ptr lo into AL
INCR_C
ALUOP_FLAGS %A%+%AH%
JNZ .free_tokens_continue
ALUOP_FLAGS %A%+%AL%
JNZ .free_tokens_continue
JMP .free_tokens_done           # If both AH and AL are zero, we are done freeing
.free_tokens_continue
LDI_BL 1                        # free 2 blocks, 32 bytes
CALL :free
JMP .free_tokens_loop
.free_tokens_done

LD16_A $user_input_buf          # Free the memory where we stored user input
LDI_BL 7                        # |
CALL :free                      # |

CALL :heap_pop_all
RET

.cmd_clear "clear\0"
.cmd_clockspeed "clockspeed\0"
.cmd_unknown "Unrecognized command: [%s]\n\0"

######
# troubleshooting function that prints out the user's
# input and memory addresses of the involved strings
.print_deconstructed_command
CALL :heap_push_all

LDI_A $user_input_buf           # User input buffer (malloc'd) address into D
LDA_A_DH                        # |
CALL :incr16_a                  # |
LDA_A_DL                        # |

CALL :heap_push_D               # Print the input string
CALL :heap_push_DL              # |
CALL :heap_push_DH              # |
LDI_C .deconstructed_1          # |
CALL :printf                    # |

LDI_D $user_input_tokens
.print_decon_token_loop
LDA_D_AH                        # token string ptr hi in AH
INCR_D
LDA_D_AL                        # token string ptr lo in AL
INCR_D
ALUOP_FLAGS %A%+%AH%
JNZ .print_decon_continue
ALUOP_FLAGS %A%+%AL%
JNZ .print_decon_continue
JMP .print_decon_done

.print_decon_continue
CALL :heap_push_A
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .deconstructed_2
CALL :printf
JMP .print_decon_token_loop

.print_decon_done
CALL :heap_pop_all
RET

.deconstructed_1 "Input 0x%x%x: [%s]\n\0"
.deconstructed_2 "Token 0x%x%x: [%s]\n\0"
