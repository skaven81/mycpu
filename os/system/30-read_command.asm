# vim: syntax=asm-mycpu

###
# Reads a command from the user.  When the user presses enter,
# the command is split on whitespace and assigned to
#  $user_input_buf - pointer to full input string
#  $user_input_token - array of pointers to input tokens
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

# Allocate memory for storing the user's input
LDI_AL 1                        # 1 segment (128 bytes)
CALL :calloc_segments           # for storing the user's empty input
ALUOP_ADDR %A%+%AH% $user_input_buf
ALUOP_ADDR %A%+%AL% $user_input_buf+1

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

                                # if equal, user didn't type anything, just hit enter
ALUOP_ADDR %zero% $user_input_tokens    # ensure $user_input_tokens has cleared
ALUOP_ADDR %zero% $user_input_tokens+1  # pointer in first position
JMP .read_command_done

.process_input
LD_DH $user_input_buf
LD_DL $user_input_buf+1         # copy memory address of buffer to D
LDI_AL 0                        # left mark = 0
LDI_BL 1                        # right mark = 1
CALL :cursor_mark_getstring     # D now points at a null-terminated copy of the user's input

PUSH_DH                         # copy D to C
PUSH_DL                         # |
POP_CL                          # |
POP_CH                          # C now points at our input string
LDI_D $user_input_tokens        # D now points at our token array
LDI_AH ' '                      # split on spaces
LDI_AL 2                        # allocate 2 blocks (32 bytes) for each token
CALL :strsplit                  # AH=num tokens, D=null-terminated array of tokens
#DEBUG CALL .print_deconstructed_command

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


######
# troubleshooting function that prints out the user's
# input and memory addresses of the involved strings
#.print_deconstructed_command
#CALL :heap_push_all
#
#LDI_A $user_input_buf           # User input buffer (malloc'd) address into D
#LDA_A_DH                        # |
#ALUOP16O_A %ALU16_A+1%          # |
#LDA_A_DL                        # |
#
#CALL :heap_push_D               # Print the input string
#CALL :heap_push_DL              # |
#CALL :heap_push_DH              # |
#LDI_C .deconstructed_1          # |
#CALL :printf                    # |
#
#LDI_D $user_input_tokens
#.print_decon_token_loop
#LDA_D_AH                        # token string ptr hi in AH
#INCR_D
#LDA_D_AL                        # token string ptr lo in AL
#INCR_D
#ALUOP_FLAGS %A%+%AH%
#JNZ .print_decon_continue
#ALUOP_FLAGS %A%+%AL%
#JNZ .print_decon_continue
#JMP .print_decon_done
#
#.print_decon_continue
#CALL :heap_push_A
#CALL :heap_push_AL
#CALL :heap_push_AH
#LDI_C .deconstructed_2
#CALL :printf
#JMP .print_decon_token_loop
#
#.print_decon_done
#CALL :heap_pop_all
#RET
#
#.deconstructed_1 "Input 0x%x%x: [%s]\n\0"
#.deconstructed_2 "Token 0x%x%x: [%s]\n\0"
