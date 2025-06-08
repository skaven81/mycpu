# vim: syntax=asm-mycpu

###
# Primary shell loop. Prints a prompt, reads a command, tokenizes the string, pops
# the first token, checks if it is a known command, then calls that command with
# the remaining tokens on the heap.
###
.command_loop
CALL :print_prompt
CALL :read_command              # sets up $user_input_buf and $user_input_tokens
CALL :parse_and_run_command     # parses $user_input_tokens[0] and executes the command
# Free the memory allocated in :read_command
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
CALL :free
JMP .free_tokens_loop
.free_tokens_done

LD16_A $user_input_buf          # Free the memory where we stored user input
CALL :free                      # |
JMP .command_loop

