# vim: syntax=asm-mycpu

# Terminal input functions

######
# Collect input from the user from the current cursor position.
# Input ends when the user presses the enter key, at which point
# the cursor is moved to the first column of the next line (scrolling
# if necessary).
#
# When input is complete, cursor mark 0 will denote the beginning
# of the input, and cursor mark 1 will denote the end. Since this
# is just display data, there is no null termination.
#
# If the user presses ctrl+c at any time, ^C is printed over the
# current cursor position, and mark 1 will be moved over mark 0
# before returning, so the result will be an zero-length string.
#
# TODO: If the user presses the up or down arrow keys, the list of
# marks is consulted so previous inputs can be retrieved.
#
# Inputs:
#  none
# Outputs:
#  cursor marks 0 and 1 will be set to mark the user's input

:input
CALL :heap_push_all

MASKINT
LD_CH %IRQ1addr%
LD_CL %IRQ1addr%+1
PUSH_CH                         # save the current IRQ1 vector
PUSH_CL
LD_TD  %kb_key%                 # clear any pending KB interrupt
ST16 %IRQ1addr%  :kb_irq_buf    # use buffered keyboard input
UMASKINT

# Store our current cursor position at mark 0 and mark 1
LDI_AL 0
CALL :cursor_save_mark
LDI_AL 1
CALL :cursor_save_mark

###
# Start collecting input
.input_loop
CALL :kb_bufsize                # bufsize into AL
ALUOP_FLAGS %A%+%AL%
JZ .input_loop                  # go back to polling if buffer is empty
CALL :kb_readbuf                # buffered keyflags into AH and keystroke into AL

###
# If a break event, do nothing
LDI_BH %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .input_loop

###
# If a meta-keypress (e.g. ctrl or shift with no other key pressed)
# then AL will be null, so don't record that keystroke.
ALUOP_FLAGS %A%+%AL%
JZ .input_loop

###
# If a ctrl+c, abort input
LDI_BH %kb_keyflag_CTRL%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JZ .input_not_ctrlc
LDI_BL 'c'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_ctrlc
LDI_AL '^'                      # it's a ctrl+c
CALL :putchar
LDI_AL 'C'
CALL :putchar                   # print ^C at current cursor location
LDI_AL 0
CALL :cursor_get_mark           # fetch mark 0 into A
LDI_BL 1
CALL :cursor_save_mark_offset   # save mark at that same location
JMP .input_done

###
# If any other altered key (other than shift) then ignore it.
.input_not_ctrlc
LDI_BH %kb_keyflag_CTRL%+%kb_keyflag_ALT%+%kb_keyflag_FUNCTION%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .input_loop

###
# If insert key, toggle insert / overwrite mode
LDI_BL 0x0f
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_insert
LD_AH $input_flags
LDI_BH 0x01
ALUOP_ADDR %AxB%+%AH%+%BH% $input_flags
JMP .input_loop

###
# If home key, move cursor to beginning of string
.input_not_insert
LDI_BL 0x02
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_home
LDI_AL 0
CALL :cursor_get_mark
CALL :cursor_goto_addr
JMP .input_loop

###
# If end key, move cursor to end of string
.input_not_home
LDI_BL 0x1e
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_end
LDI_AL 1
CALL :cursor_get_mark
CALL :cursor_goto_addr
JMP .input_loop

###
# Backspace?
.input_not_end
LDI_BL 0x08
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_backspace
# check if cursor is at mark 0.  If so, do nothing.
LDI_AL 0
CALL :cursor_get_mark                   # mark 0 offset in A
LD16_B $crsr_addr_chars                 # cursor location in B
ALUOP_PUSH %A%+%AH%
LDI_AH 0x0f
ALUOP_BH %A&B%+%AH%+%BH%                # B now contains just the offset
POP_AH
CALL :sub16_b_minus_a                   # if cursor is to the right of the
ALUOP_FLAGS %B%+%BH%                    # mark 0, then B will be nonzero;
JNZ .do_backspace                       # if cursor is at mark 0 then B will
ALUOP_FLAGS %B%+%BL%                    # be zero.
JNZ .do_backspace
JMP .input_loop                         # if zero, then do nothing

.do_backspace
CALL :cursor_left
LDI_AL 1
CALL :cursor_get_mark                   # mark 1 offset in A
LDI_BH 0x40
ALUOP_BH %A+B%+%AH%+%BH%                # hi byte of mark 1 char addr in BH
ALUOP_BL %A%+%AL%                       # lo byte of mark 1 char addr in BL
LD16_A $crsr_addr_chars                 # cursor location in A
CALL :decr16_a                          # setup for loop entry
.do_backspace_loop
CALL :incr16_a
CALL :incr16_a
LDA_A_CL
CALL :decr16_a
STA_A_CL                                # copy char to the right, to the left
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNZ .do_backspace_loop
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNZ .do_backspace_loop
CALL :cursor_mark_left
JMP .input_loop

###
# If not backspace, left arrow?
.input_not_backspace
LDI_BL 0x1b
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_leftarrow
LDI_AL 0
CALL :cursor_get_mark                   # mark 0 offset in A
LD16_B $crsr_addr_chars                 # cursor location in B
ALUOP_PUSH %A%+%AH%
LDI_AH 0x0f
ALUOP_BH %A&B%+%AH%+%BH%                # B now contains just the offset
POP_AH
CALL :sub16_b_minus_a                   # if cursor is to the right of the
ALUOP_FLAGS %B%+%BH%                    # mark 0, then B will be nonzero;
JNZ .do_leftarrow                       # if cursor is at mark 0 then B will
ALUOP_FLAGS %B%+%BL%                    # be zero.
JNZ .do_leftarrow
JMP .input_loop                         # if zero, then do nothing
.do_leftarrow
CALL :cursor_left
JMP .input_loop

###
# If not left arrow, right arrow?
.input_not_leftarrow
LDI_BL 0x1a
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_rightarrow
LDI_AL 1
CALL :cursor_get_mark                   # mark 1 offset in A
LD16_B $crsr_addr_chars                 # cursor location in B
ALUOP_PUSH %A%+%AH%
LDI_AH 0x0f
ALUOP_BH %A&B%+%AH%+%BH%                # B now contains just the cursor offset
POP_AH
CALL :sub16_b_minus_a                   # if cursor is to the left of the
ALUOP_FLAGS %B%+%BH%                    # mark 1, then B will be nonzero;
JNZ .do_rightarrow                      # if cursor is at mark 0 then B will
ALUOP_FLAGS %B%+%BL%                    # be zero.
JNZ .do_rightarrow
JMP .input_loop
.do_rightarrow
CALL :cursor_right
JMP .input_loop

###
# Delete?
.input_not_rightarrow
LDI_BL 0x7f
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .input_not_delete
LDI_AL 1
CALL :cursor_get_mark                   # mark 1 offset in A
LDI_BH 0x40
ALUOP_BH %A+B%+%AH%+%BH%                # hi byte of mark 1 char addr in BH
ALUOP_BL %A%+%AL%                       # lo byte of mark 1 char addr in BL
LD16_A $crsr_addr_chars                 # cursor location in A

ALUOP_FLAGS %B-A%+%AL%+%BL%             # if cursor is ahead of mark 1
JO .input_loop                          # then do nothing

.delete_loop
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .delete_loop_continue
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .delete_loop_continue
JMP .delete_loop_done
.delete_loop_continue
CALL :incr16_a
LDA_A_CL                                # get far char
CALL :decr16_a                          # move left one
STA_A_CL                                # put near char
CALL :incr16_a                          # move right one
JMP .delete_loop

.delete_loop_done
ALUOP_ADDR_B %zero%                     # blank char at mark 1
LDI_AL 1
CALL :cursor_mark_left                  # move mark 1 left
JMP .input_loop

###
# Enter key?
.input_not_delete
LDI_BL 0x0d
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .input_done                 # we are done with input upon enter

###
# Newline?
LDI_BL 0x0a
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .input_done                 # we are done with input upon newline

###
# Ignore if non-alphanumeric-or-punctuation
.input_not_enter
LDI_BL ' '
ALUOP_FLAGS %A-B%+%AL%+%BL%
JO .input_loop                  # if B(space)>A(char), ignore it
LDI_BL '~'
ALUOP_FLAGS %B-A%+%AL%+%BL%
JO .input_loop                  # if B(~)<A(char), ignore it

###
# If none of these, then it was a normal
# character, so append/insert it and move on.
LD_AH $input_flags
LDI_BH 0x01
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .input_handle_insert
# overwrite mode
ALUOP_PUSH %A%+%AL%
LDI_AL 1
CALL :cursor_get_mark           # mark 1 in A
LDI_BH 0x40
ALUOP_AH %A|B%+%AH%+%BH%        # A = char addr of mark 1
LD16_B $crsr_addr_chars         # B = char addr of cursor
ALUOP_FLAGS %AxB%+%AL%+%BL%     # if A!=B, don't extend mark 1 right
JNE .overwrite_noextend
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .overwrite_noextend

POP_AL
CALL :putchar
LDI_AL 1
CALL :cursor_mark_right
JMP .input_loop

.overwrite_noextend
POP_AL
CALL :putchar
JMP .input_loop

# insert mode
.input_handle_insert
ALUOP_PUSH %A%+%AL%
LDI_AL 1
CALL :cursor_get_mark           # mark 1 in A
LDI_BH 0x40
ALUOP_AH %A|B%+%AH%+%BH%        # A = char addr of mark 1 4005
LD16_B $crsr_addr_chars         # B = char addr of cursor 4005
CALL :incr16_a                  # get A in position to start the loop 4006
.insert_copy_loop
CALL :decr16_a                  # 4005
LDA_A_CL                        # char @A into CL
CALL :incr16_a                  # move right 4006
STA_A_CL                        # CL into char @A
CALL :decr16_a                  # 4005
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .insert_copy_loop
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .insert_copy_loop
POP_AL
CALL :putchar
LDI_AL 1
CALL :cursor_mark_right
JMP .input_loop

.input_done

# Restore IRQ1 vector
MASKINT
POP_CL
POP_CH
ST_CH   %IRQ1addr%
ST_CL   %IRQ1addr%+1
UMASKINT

CALL :heap_pop_all
RET
