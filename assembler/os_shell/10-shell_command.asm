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
# save the byte just after mark 1
CALL :incr16_a                  # A now points to byte after mark 1
LDA_A_CL                        # load byte into CL
PUSH_CL                         # save byte for later
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%             # save location for later
# put a null just after mark 1 (so we can use mark 0 addr as a string pointer)
ALUOP_ADDR_A %zero%             # write null to address in A

# pass the string to the tokenizer - pointers to tokens end up on the heap

# put the saved byte back
POP_AL
POP_AH
POP_CL
STA_A_CL

# pop the first token from the heap
# compare to list of known commands
# call command handler (args are on the heap)
CALL :heap_pop_all
RET

