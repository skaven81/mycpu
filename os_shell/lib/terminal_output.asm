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
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

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
# Simple putchar that doesn't do anything special with control chars
:putchar_direct
PUSH_DH
PUSH_DL
LD_DH $crsr_addr_chars              # address to write in D
LD_DL $crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%               # write the character
CALL .cursor_right_scroll
POP_DL
POP_DH
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
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

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
ALUOP16O_A %ALU16_A+1%              # move to next source color
ALUOP16O_B %ALU16_B+1%              # move to next dest color
JMP .term_strcpy_loop       # keep looping until we hit a null character
.term_strcpy_done
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
# If $term_print_raw is zero, then the :putchar routine is used to print characters,
# which makes control characters like \n work as expected. If $term_print_raw is non-zero,
# then characters are printed using :putchar_direct, which ignores control characters.
#
# The $term_color_enabled var determines if color processing is done.  If $term_color_enabled
# is zero, the color codes are just printed out without processing.  If $term_color_enabled
# is non-zero, then the color codes are processed.
#
# The color code is translated to a hexadecimal number that is written to the
# color half of the frame buffer. Once encountered, a color remains active until
# a reset code is encountered, at which point characters are printed without
# updating the color buffer.
#
# Color codes are:
#   @@ - a literal `@`
#   @[shade][color] - shade is 0-3 (0 will be black), color is 0-7
#      0: black
#      1: blue
#      2: green
#      3: cyan
#      4: red
#      5: magenta
#      6: yellow
#      7: white
#   @x[hex] - use literal hex value (00-ff) in the color byte
#   @b/@B - blink off/on, only toggles the bit in $term_current_color, does not set $term_render_color
#   @c/@C - cursor off/on, only toggles the bit in $term_current_color, does not set $term_render_color
#   @r - reset: stop updating colors
#
# The color byte is arranged like so:
#   0x03 blue   xx xx xx 11
#   0x0c green  xx xx 11 xx
#   0x30 red    xx 11 xx xx
#   0x40 cursor x1 xx xx xx
#   0x80 blink  1x xx xx xx
#
# So in the [shade][color] model, the [color] is octal. For example, magenta
# is 5 or 0b101, or red=1, green=0, blue=1.  The [shade] then acts as a
# multiplier, so for shade 1 you get 0b010001, for shade 2 it's 0b100010, and
# for shade 3 you get 0b110011.
#
# Inputs:
#  C - address of string to print
VAR global byte $term_color_enabled  # 0=ignore @-codes
VAR global byte $term_render_color   # 0=don't write $term_current_color to color memory
VAR global byte $term_current_color  # color code to write if $term_render_color is non-zero
VAR global byte $term_print_raw      # 0=interpret control chars
VAR global 5 $term_hexbyte_buf
:print
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
LD_AL $term_color_enabled
ALUOP_FLAGS %A%+%AL%
JZ .print_loop_nocolor              # if color is not enabled, use standard print method since it's faster

# color print loop
.print_loop_color
LDA_C_AL                        # load next char into AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done                  # Done if null

LDI_BL '@'
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is char a '@'?
JNE .print_it
INCR_C                          # We have a '@' so move to next char
LDA_C_AL                        # Get the next char into AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done                  # If null, we are done
ALUOP_FLAGS %A&B%+%AL%+%BL%     # If AL is '@', EQ bit is set
JEQ .print_it                   # If '@', print an '@' and move on
LDI_BL 'r'                      # Check for color reset code
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_reset_color
LDI_BL 'x'                      # Check for hex color code
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_set_hex_color
LDI_BL 'b'                      # Check for clear blink
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_clear_blink
LDI_BL 'B'                      # Check for set blink
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_set_blink
LDI_BL 'c'                      # Check for clear cursor
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_clear_cursor
LDI_BL 'C'                      # Check for set cursor
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .print_set_cursor

# @[shade][color]
LDI_BL '0'
ALUOP_FLAGS %A-B%+%AL%+%BL%     # if AL is char <'0' this will overflow
JO .print_it                    # in which case just print it and move on
LDI_BL '3'
ALUOP_FLAGS %B-A%+%AL%+%BL%     # if AL is char >'3' this will overflow
JO .print_it                    # in which case just print it and move on
LDI_BL '0'
ALUOP_PUSH %A-B%+%AL%+%BL%      # get numeric value for shade and put it onto the stack
INCR_C                          # move to color number
LDA_C_AL                        # put color number into AL
LDI_BL '0'
ALUOP_FLAGS %A-B%+%AL%+%BL%     # if AL is char <'0' this will overflow
JO .print_it                    # in which case just print it and move on
LDI_BL '7'
ALUOP_FLAGS %B-A%+%AL%+%BL%     # if AL is char >'7' this will overflow
JO .print_it                    # in which case just print it and move on
LDI_BL '0'
ALUOP_AL %A-B%+%AL%+%BL%        # get numeric value for color into AL
POP_BL                          # shade value into BL
INCR_C                          # move to next printable char

ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
LD_AH $term_current_color       # clear current color (except for blink and cursor bits)
LDI_BL 0xc0                     # |
ALUOP_AH %A&B%+%AH%+%BL%        # AH contains the new color byte, AL is the 3-bit color code
POP_BL

.shade_set_loop                 # start adding bits to AH
ALUOP_FLAGS %B%+%BL%            # If shade value (counter) is zero we are done
JZ .write_shade
ALUOP_PUSH %B%+%BL%             # remember current shade value on stack
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%     # Check if blue bit is set
JZ .shade_check_green           # If not, move to check green
LDI_BL 0x01
ALUOP_AH %A+B%+%AH%+%BL%        # Increment blue field
.shade_check_green
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%     # Check if green bit is set
JZ .shade_check_red
LDI_BL 0x04
ALUOP_AH %A+B%+%AH%+%BL%        # Increment green field
.shade_check_red
LDI_BL 0x04
ALUOP_FLAGS %A&B%+%AL%+%BL%     # Check if red bit is set
JZ .shade_loop_next
LDI_BL 0x10
ALUOP_AH %A+B%+%AH%+%BL%        # Increment red field
.shade_loop_next
POP_BL                          # Get shade value back into BL
ALUOP_BL %B-1%+%BL%             # decrement it
JMP .shade_set_loop

.write_shade
ALUOP_ADDR %A%+%AH% $term_current_color
POP_AH
ST $term_render_color 0x01
JMP .print_loop_color

# @C Handle set cursor
.print_set_cursor
INCR_C                          # move to next char
LD_AL $term_current_color       # Get current color byte
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR %A|B%+%AL%+%BL% $term_current_color
POP_BL
JMP .print_loop_color

# @c Handle clear cursor
.print_clear_cursor
INCR_C                          # move to next char
LD_AL $term_current_color       # Get current color byte
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR %A&~B%+%AL%+%BL% $term_current_color
POP_BL
JMP .print_loop_color

# @B Handle set blink
.print_set_blink
INCR_C                          # move to next char
LD_AL $term_current_color       # Get current color byte
ALUOP_ADDR %A_setblink% $term_current_color
JMP .print_loop_color

# @b Handle clear blink
.print_clear_blink
INCR_C                          # move to next char
LD_AL $term_current_color       # Get current color byte
ALUOP_ADDR %A_clrblink% $term_current_color
JMP .print_loop_color

# @x Handle hex color byte
.print_set_hex_color
ST $term_render_color 0x01      # Enable color rendering
ST $term_hexbyte_buf '0'        # Add 0x prefix to hexbyte buf
ST $term_hexbyte_buf+1 'x'
INCR_C                          # Move to first char after the x
LDA_C_AL                        # get the first char
ALUOP_ADDR %A%+%AL% $term_hexbyte_buf+2
INCR_C
LDA_C_AL                        # get the second char
ALUOP_ADDR %A%+%AL% $term_hexbyte_buf+3
ALUOP_AL %zero%                 # write the trailing null
ALUOP_ADDR %A%+%AL% $term_hexbyte_buf+4
INCR_C                          # move to char after the color code
PUSH_CH                         # Convert hex to 8-bit num in AL, flags in BL
PUSH_CL                         # |
LDI_C $term_hexbyte_buf         # |
CALL :strtoi8                   # |
POP_CL                          # |
POP_CH                          # |
ALUOP_ADDR %A%+%AL% $term_current_color # write the converted byte. We don't care if conversion failed, as that just ends up as zero (black)
JMP .print_loop_color

# @r Handle color reset
.print_reset_color
ST $term_render_color 0x00
INCR_C
JMP .print_loop_color

# Print a regular character
.print_it
ALUOP_PUSH %A%+%AL%
LD_AL $term_print_raw
ALUOP_FLAGS %A%+%AL%
POP_AL
JZ .print_it_putchar
CALL :putchar_direct            # print the char in AL in direct mode
JMP .print_it_putchar_done
.print_it_putchar
CALL :putchar                   # print the char in AL
.print_it_putchar_done
INCR_C                          # Move to next character
LD_BL $term_render_color        # Check if we have color to add
ALUOP_FLAGS %B%+%BL%
JZ .print_loop_color            # If not, we are done.

PUSH_CH                         # Save C
PUSH_CL                         # |
LD_CH $crsr_addr_color          # Get the color address into C
LD_CL $crsr_addr_color+1        # |
DECR_C                          # putchar moved this to the right, so this moves us back to the left
LD_BL $term_current_color       # Load current color into BL
ALUOP_ADDR_C %B%+%BL%           # Write color
POP_CL                          # Restore C
POP_CH                          # |
JMP .print_loop_color

# no-color print loop avoids a lot of unnecessary code
.print_loop_nocolor
LDA_C_AL                        # load next char into AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done                  # Done if null

ALUOP_PUSH %A%+%AL%
LD_AL $term_print_raw
ALUOP_FLAGS %A%+%AL%
POP_AL
JZ .nocolor_print_putchar
CALL :putchar_direct            # print it in direct mode
.nocolor_print_putchar
CALL :putchar                   # print it
.nocolor_print_putchar_done
INCR_C                          # Move to next character
JMP .print_loop_nocolor

.print_done
POP_BL
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
LDI_AL 28                   # 29 128-byte segments -> 58 lines
CALL :memcpy_segments
LDI_AL 3                    # 4 16-byte blocks -> 1 line
CALL :memcpy_blocks

# Write 64 nulls to the last line
LDI_C %display_chars%+3776  # C to the beginning of the last line
LDI_AH 0x00                 # byte to fill
LDI_AL 3                    # 4 16-byte blocks -> 1 line
CALL :memfill_blocks

# Now scroll the colors
LDI_C %display_color%+64    # beginning of second line
LDI_D %display_color%       # beginning of first line
LDI_AL 28                   # 29 128-byte segments -> 58 lines
CALL :memcpy_segments
LDI_AL 3                    # 4 16-byte blocks -> 1 line
CALL :memcpy_blocks

# Write 64 "white, no blink, no cursor" bytes to the last line
LDI_C %display_color%+3776
LDI_AH %white%              # byte to fill
LDI_AL 3                    # 4 16-byte blocks -> 1 line
CALL :memfill_blocks

# And finally scroll our marks
CALL :cursor_scroll_marks
CALL :heap_pop_all
RET


