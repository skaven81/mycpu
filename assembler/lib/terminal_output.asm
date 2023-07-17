# vim: syntax=asm-mycpu

# Terminal output functions

######
# Print a single character from AL at the current cursor location, then move
# the cursor one step to the right.
#
# This function also handles metacharacters, specifically:
#  0x08 backspace   cursor moves left one space, display updates to first null
#  0x7f delete      cursor stays in place, display  updates to first null
#  0x0d enter       cursor moves to next line, first column
#  0x0a newline     handled same as enter
#
# In all cases, if the next cursor location is beyond the display, the display
# is scrolled to accommodate.
#
# The metacharacter operations are only context aware to the right (to the
# first null) but will do nothing if it would cause the cursor to move beyond
# the display borders.  For example, putchar(BS) will happily delete the shell
# prompt and even wrap up to the previous line, dragging all the text in front
# of the cursor (up to the first null) along with it.  The calling program is
# responsible for not calling putchar with metachars that would end up
# violating the program's context (e.g. backspacing beyond the bounds of the
# input field).
#
# Inputs:
#  AL - character to print
:putchar
CALL :heap_push_all

LDI_BL 0x08                         # Backspace
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_backspace
LDI_BL 0x7f                         # Delete
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_delete
LDI_BL 0x0d                         # Enter
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_newline
LDI_BL 0x0a                         # Newline
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_newline
# if no matches above, this is a normal char to print
LD_DH $crsr_addr_chars              # address to write in D
LD_DL $crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%               # write the character
CALL .cursor_right_scroll
JMP .putchar_done

# Backspace
.putchar_backspace
LD_AH $crsr_row                 # load current row/col of cursor
LD_AL $crsr_col
CALL :cursor_left
LD_BH $crsr_row                 # load new row/col of cursor
LD_BL $crsr_col
ALUOP_FLAGS %AxB%+%AL%+%BL%     # col the same?
JEQ .putchar_done               # if cursor didn't move, do nothing
LD_CH $crsr_addr_chars
LD_CL $crsr_addr_chars+1        # cursor location in C
INCR_C                          # one step to right now in C
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1        # cursor location in D
CALL .term_strcpy               # copy everything from C (right of the cursor) to D (left one spot)
JMP .putchar_done

# Delete
.putchar_delete
LD_CH $crsr_addr_chars
LD_CL $crsr_addr_chars+1        # cursor location in C
INCR_C                          # one step to right now in C
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1        # cursor location in D
CALL .term_strcpy               # copy everything from C (right of the cursor) to D (left one spot)
JMP .putchar_done

# Newline
.putchar_newline
CALL .cursor_down_scroll
LD_AH $crsr_row                 # load current row of cursor
LDI_AL 0x00                     # set column to zero
CALL :cursor_goto_rowcol
JMP .putchar_done

# Exit putchar
.putchar_done
CALL :heap_pop_all
RET

######
# Terminal-aware strcpy.  Has the same semantics as strcpy, only the
# C and D addresses are expected to be in the character display range.
# Both the display *characters* and display *colors* are copied.
#
# Inputs:
#  C - source data (in the %display_chars% range)
#  D - destination (also in %display_chars% range)
#
# Unlike strcpy, the final null is copied when complete.
.term_strcpy
CALL :heap_push_all

MOV_CH_AH                   # Copy CH to AH
LDI_BL 0x10
ALUOP_AH %A|B%+%AH%+%BL%    # Bump CH up to the 0x5000 range
MOV_CL_AL                   # Copy CL to AL

MOV_DH_BH                   # Copy DH to BH
LDI_AL 0x10
ALUOP_BH %A|B%+%BH%+%AL%    # Bump DH up to the 0x5000 range
MOV_DL_BL                   # Copy DL to BL

.term_strcpy_loop
LDA_C_TD                    # load character from source into TD
STA_D_TD                    # write character from TD to dest
LDA_A_TD                    # load color from source into TD
STA_A_TD                    # write color from TD to dest

ALUOP_PUSH %A%+%AL%
LDA_C_AL
ALUOP_FLAGS %A%+%AL%        # check if curret char is null
POP_AL
JZ .term_strcpy_done        # we are done if the last copied char was null
INCR_C                      # move to next source char
INCR_D                      # move to next dest char
CALL :incr16_a              # move to next source color
CALL :incr16_b              # move to next dest color
JMP .term_strcpy_loop       # keep looping until we hit a null character
.term_strcpy_done
CALL :heap_pop_all
RET

######
# Uses the cursor library's cursor right movement function.  If the cursor
# didn't actually move (which means it's at the limit of the display)
# then scroll the display, move the cursor up, then run the cursor action
# again.
.cursor_right_scroll
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
LD_AH $crsr_row                 # load current row/col of cursor
LD_AL $crsr_col
CALL :cursor_right
LD_BH $crsr_row                 # load new row/col of cursor
LD_BL $crsr_col
ALUOP_FLAGS %AxB%+%AL%+%BL%     # col the same?
JNE .crs_done
CALL :term_scroll               # cursor didn't move, so we need to scroll
CALL :cursor_up                 # move the cursor up with the display
CALL :cursor_right              # and then retry the right movement
.crs_done
POP_BH
POP_BL
POP_AH
POP_AL
RET

######
# Uses the cursor library's cursor down movement function.  If the cursor
# didn't actually move (which means it's at the limit of the display)
# then scroll the display, leaving the cursor at the correct place on the display.
.cursor_down_scroll
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
LD_AH $crsr_row                 # load current row/col of cursor
LD_AL $crsr_col
CALL :cursor_down
LD_BH $crsr_row                 # load new row/col of cursor
LD_BL $crsr_col
ALUOP_FLAGS %AxB%+%AH%+%BH%     # row the same?
JNE .cds_done
LD_AH $crsr_on                  # save our cursor on/off state
CALL :cursor_off                # turn off the cursor before scrolling
CALL :term_scroll               # cursor didn't move, so we need to scroll
ALUOP_FLAGS %A%+%AH%
JZ .cds_done                    # if cursor was off before, we're done
CALL :cursor_on                 # otherwise, turn the cursor back on

# cursor stayed in place on the display, which for a downward movement
# is correct, so no need to do any more cursor movement.
.cds_done
POP_BH
POP_BL
POP_AH
POP_AL
RET

######
# Print a null-terminated string found at the memory address in C (CH+CL) at
# the current cursor location. The cursor will be placed at the end of the
# string.  If at any point, the cursor wraps beyond the bottom of the display,
# scroll the display. Any newlines will be processed as expected.  The terminating
# null is not printed.
#
# Inputs:
#  C - address of string to print
#
# TODO - add something similar to ANSI escape code sequence support.  If a known
# escape string, say `#xx` where xx is hex, then instead of printing those
# characters, instead the "current color" is updated and written to color space
# as characters are printed.  A special code, say #!, would cause "painting" to stop,
# keeping whatever existing color data is there unchanged.
:print
ALUOP_PUSH %A%+%AL%
.print_loop
LDA_C_AL                        # load next char into AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done                  # Done if null
CALL :putchar                   # print it
INCR_C                          # Move to next character
JMP .print_loop
.print_done
POP_AL
RET

######
# Same as print, but accepts a format string and a set of data values on the
# heap.  Works exactly like sprintf except that there is no "destination"
# string; the "destination" is the current cursor location, and wrapping/scrolling
# behavior works the same as putchar and print.
#
# Inputs:
#  C - address of format string to print
#  heap - parameters for the format string
VAR global 128 $printf_buf
:printf
PUSH_DH
PUSH_DL
PUSH_CH
PUSH_CL
LDI_D $printf_buf       # sprintf output to temporary buffer
CALL :sprintf           # format the string from C into temporary buffer, using params from heap
LDI_C $printf_buf       # C now points to the temporary buffer
CALL :print             # print it
POP_CL
POP_CH
POP_DL
POP_DH
RET

######
# Scroll the display up one line.  This does not do any cursor
# manipulation, it only scrolls the contents of the terminal.
:term_scroll
CALL :heap_push_all

# Scroll the characters first
LDI_C %display_chars%+64    # beginning of second line
LDI_D %display_chars%       # beginning of first line
LDI_A 64*59                 # 59 lines to move up
.char_loop
LDA_C_BL                    # Load char from second line
ALUOP_ADDR_D %B%+%BL%       # Put char into first line
INCR_C
INCR_D
CALL :decr16_a
ALUOP_FLAGS %A%+%AL%
JNZ .char_loop
ALUOP_FLAGS %A%+%AH%
JNZ .char_loop

# Write 64 nulls to the last line
LDI_AL 64
LDI_BL 0x00
.char_blank_loop
ALUOP_ADDR_D %B%+%BL%
INCR_D
ALUOP_AL %A-1%+%AL%
JNZ .char_blank_loop

# Now scroll the colors
LDI_C %display_color%+64    # beginning of second line
LDI_D %display_color%       # beginning of first line
LDI_A 64*59                 # 59 lines to move up
.color_loop
LDA_C_BL                    # Load color from second line
ALUOP_ADDR_D %B%+%BL%       # Put color into first line
INCR_C
INCR_D
CALL :decr16_a
ALUOP_FLAGS %A%+%AL%
JNZ .color_loop
ALUOP_FLAGS %A%+%AH%
JNZ .color_loop

# And finally scroll our marks
CALL :cursor_scroll_marks

CALL :heap_pop_all
RET


