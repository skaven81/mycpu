# vim: syntax=asm-mycpu

# Cursor movement functions

VAR global byte $crsr_row
VAR global byte $crsr_col
VAR global word $crsr_addr_chars
VAR global word $crsr_addr_color
VAR global byte $crsr_on
VAR global 64 $crsr_marks

VAR global byte $input_flags
# msb 7
#     6
#     5
#     4
#     3
#     2
#     1
# lsb 0 insert (set) overwrite (clear)

:cursor_init
# Initialize the global variables; cursor is set to 0,0 (top left corner) with
# the cursor showing (on)
ST $crsr_row 0
ST $crsr_col 0
ST $crsr_on 1
ST16 $crsr_addr_chars %display_chars%
ST16 $crsr_addr_color %display_color%
ST $input_flags 0x01

# Initialize the cursor marks, ensuring all marks have the top bit set to
# mark them as undefined
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
LDI_C $crsr_marks
LDI_AL 64
.cursor_init_loop
ALUOP_ADDR_C %negone%
INCR_C
ALUOP_AL %A-1%+%AL%
JNZ .cursor_init_loop
POP_CL
POP_CH
POP_AL
RET

######
# Saves the current cursor location in a cursor mark.  Each mark
# is a 12-bit absolute offset.  The top bit of the mark
# are used as an active flag
#  0x80 - mark is undefined if set, defined if clear
#  0x40 - unused
#  0x20 - unused
#  0x10 - unused
#
# Inputs:
#  AL - mark to save (0..31)
:cursor_save_mark
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LDI_B $crsr_marks                   # B points to 0th mark
ALUOP_AL %A<<1%+%AL%                # multiply AL by two (each mark is two bytes)
ALUOP_AH %zero%
CALL :add16_to_b                    # B points to ALth mark
ALUOP_PUSH %B%+%BL%
LD_AL $crsr_addr_chars              # AL contains high byte of char address
LDI_BL 0x0f                         # mask to clear the high bits so we just get the offset
ALUOP_AL %A&B%+%AL%+%BL%            # AL high byte is ready to save
POP_BL
ALUOP_ADDR_B %A%+%AL%               # save AL to high byte of mark
CALL :incr16_b                      # move to low byte of mark
LD_AL $crsr_addr_chars+1            # AL contains low byte of char address
ALUOP_ADDR_B %A%+%AL%               # save AL to low byte of mark
POP_AL
POP_AH
POP_BL
POP_BH
RET

######
# Saves the given offset as a mark
#
# Inputs:
#  A - 12-bit offset (top 4 bits are ignored)
#  BL - mark ID (0..31)
:cursor_save_mark_offset
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_AL %B%+%BL%                   # mark ID into AL
LDI_B $crsr_marks                   # B points to 0th mark
ALUOP_AL %A<<1%+%AL%                # multiply AL by two (each mark is two bytes)
ALUOP_AH %zero%
CALL :add16_to_b                    # B points to ALth mark
POP_AL
POP_AH                              # A now contains offset or addr
ALUOP_PUSH %B%+%BH%
LDI_BH 0x0f                         # mask to clear high bits of offset
ALUOP_AH %A&B%+%AH%+%BH%            # offset is now just 12 bits
POP_BH
ALUOP_ADDR_B %A%+%AH%               # save high byte of offset
CALL :incr16_b                      # move to low byte of mark
ALUOP_ADDR_B %A%+%AL%               # save low byte of offset
POP_BL
POP_BH
RET

######
# Saves the given row/col as a mark
#
# Inputs:
#  AH - row (0..59)
#  AL - col (0..63)
#  BL - mark ID (0..31)
:cursor_save_mark_rowcol
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_AL %B%+%BL%                   # mark ID into AL
LDI_B $crsr_marks                   # B points to 0th mark
ALUOP_AL %A<<1%+%AL%                # multiply AL by two (each mark is two bytes)
ALUOP_AH %zero%
CALL :add16_to_b                    # B points to ALth mark
POP_AL
POP_AH                              # A now contains row/col
CALL :cursor_conv_rowcol            # A now contains offset
ALUOP_PUSH %B%+%BH%
LDI_BH 0x0f                         # mask to clear high bits of offset
ALUOP_AH %A&B%+%AH%+%BH%            # offset is now just 12 bits
POP_BH
ALUOP_ADDR_B %A%+%AH%               # save high byte of offset
CALL :incr16_b                      # move to low byte of mark
ALUOP_ADDR_B %A%+%AL%               # save low byte of offset
POP_BL
POP_BH
RET

######
# Moves the given mark up/down/left/right by one character/row
#
# Inputs:
#  AL - mark ID (0..31)
:cursor_mark_left
ALUOP_PUSH %A%+%AH%
LDI_AH -1
CALL :cursor_mark_move
POP_AH
RET

:cursor_mark_right
ALUOP_PUSH %A%+%AH%
LDI_AH 1
CALL :cursor_mark_move
POP_AH
RET

:cursor_mark_up
ALUOP_PUSH %A%+%AH%
LDI_AH -64
CALL :cursor_mark_move
POP_AH
RET

:cursor_mark_down
ALUOP_PUSH %A%+%AH%
LDI_AH 64
CALL :cursor_mark_move
POP_AH
RET

######
# Moves the given mark by a given offset.  If the move
# takes the mark out of the screen boundary (mark offset
# less than zero or greater than 0x0eff) then the mark
# is disabled.  If the selected mark is already disabled,
# it remains disabled and is unchanged.
#
# Inputs:
#  AH - offset amount (-128..127)
#  AL - mark ID (0..31)
:cursor_mark_move
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%                 # ensure offset is on top of stack
CALL :cursor_get_mark               # load the requested mark into AH+AL
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%         # check high bit of mark data
JZ .cmm_valid_mark
POP_AH                              # if this mark is already disabled, just abort
POP_AL
JMP .cmm_done

.cmm_valid_mark                     # this is currently a valid mark
POP_BL                              # offset (from AH) popped into BL
ALUOP_PUSH %A%+%AH%
LDI_AH 0x80                         # mask to see if BL is negative
ALUOP_FLAGS %A&B%+%AH%+%BL%
JZ .cmm_pos
LDI_BH 0xff                         # If BL was negative, extend negation into BH
JMP .cmm_posnegdone
.cmm_pos
LDI_BH 0x00                         # If BL was positive, extend zeros into BH
.cmm_posnegdone
POP_AH
CALL :add16_to_a                    # A contains new offset
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%         # check if offset is negative
JNZ .cmm_out_of_bounds
LDI_BH 0x0e
ALUOP_FLAGS %B-A%+%AH%+%BH%         # if 0x0e - top byte of new offset overflows, then new offset was > 0x0eff
JO .cmm_out_of_bounds
POP_BL                              # offset in A is in bounds; BL contains mark ID
CALL :cursor_save_mark_offset
JMP .cmm_done

.cmm_out_of_bounds
POP_AL                              # AL contains mark ID
CALL :cursor_clear_mark

.cmm_done
POP_BH
POP_BL
POP_AH
POP_AL
RET


######
# Clears the given mark, by zeroing out both bytes of the mark
#
# Inputs:
#  AL - mark to clear (0..31)
:cursor_clear_mark
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LDI_B $crsr_marks                   # B points to 0th mark
ALUOP_AL %A<<1%+%AL%                # multiply AL by two (each mark is two bytes)
ALUOP_AH %zero%
CALL :add16_to_b                    # B points to ALth mark
ALUOP_ADDR_B %negone%               # undefined value
CALL :incr16_b                      # move to low byte of mark
ALUOP_ADDR_B %negone%               # undefined value
POP_AL
POP_AH
POP_BL
POP_BH
RET

######
# Returns the selected mark in A.  If the mark is undefined, then
# AH will have its high bit set.
#
# Inputs:
#  AL - mark to retrieve (0..31)
# Outputs:
#  A[11..0] - mark offset value
#  A[15] - set if mark is undefined
:cursor_get_mark
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LDI_B $crsr_marks                   # B points to 0th mark
ALUOP_AL %A<<1%+%AL%                # multiply AL by two (each mark is two bytes)
ALUOP_AH %zero%
CALL :add16_to_b                    # B points to ALth mark
LDA_B_AH                            # fetch high byte
CALL :incr16_b
LDA_B_AL                            # fetch low byte
POP_BL
POP_BH
RET

######
# Moves all the marks up one row - used when scrolling the terminal.
# When a mark goes negative (scrolls off top of screen) then its high
# bit gets set, which invalidates it.
:cursor_scroll_marks
CALL :heap_push_all
LDI_D $crsr_marks                   # track address of mark in D
LDI_BL 32                           # we will update 32 marks, but we decrement and check at the beginning of the loop
.cscroll_loop
LDA_D_AH                            # load upper byte of mark into AH
INCR_D
LDA_D_AL                            # load lower byte of mark into AL
DECR_D                              # put pointer back to known location at first byte of this mark
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%         # check MSB of high byte
JNZ .cscroll_2                      # Don't bother modifying this mark if it's disabled
LDI_BH 0xf0
ALUOP_CH %A&B%+%AH%+%BH%            # save the mark's flags in CH
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%            # wipe the flags in AH
CALL :cursor_conv_addr              # A is now split AH=row, AL=col
ALUOP_AH %A-1%+%AH%                 # decrement row by one
JO .cscroll_3                       # If the row overflowed, don't bother converting back to offset
CALL :cursor_conv_rowcol            # A now contains the offset again
MOV_CH_BH                           # grab our flags from CH
ALUOP_AH %A|B%+%AH%+%BH%            # set flags again
.cscroll_3
ALUOP_ADDR_D %A%+%AH%               # write upper byte back
INCR_D
ALUOP_ADDR_D %A%+%AL%               # write lower byte back
DECR_D                              # move D pointer back to known location
.cscroll_2
INCR_D                              # move D pointer to next mark
INCR_D
ALUOP_BL %B-1%+%BL%
JNZ .cscroll_loop                   # we are done if BL==0 after decrementing
CALL :heap_pop_all
RET

######
# Shifts all mark IDs right by one position, discarding the last
# mark.  The 0th mark is set as disabled.
:cursor_shift_marks
PUSH_DH
PUSH_DL
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AL%
LDI_D $crsr_marks+64                # right mark in D
LDI_C $crsr_marks+62                # left mark in C
LDI_AL 62                           # we will move 62 bytes
.cshift_loop
DECR_D
DECR_C
LDA_C_TD
STA_D_TD                            # move the left mark to the right
ALUOP_AL %A-1%+%AL%
JNZ .cshift_loop
ALUOP_ADDR_C %negone%               # clear the 0th mark
INCR_C
ALUOP_ADDR_C %negone%
POP_AL
POP_CL
POP_CH
POP_DL
POP_DH
RET

######
# Transcribes the characters between two marks into a string
# at the address in D
#
# Inputs:
#  AL - left mark (0..31)
#  BL - right mark (0..31)
#  D - address of string
:cursor_mark_getstring
CALL :heap_push_all

ALUOP_CL %A%+%AL%                   # save left mark ID in CL

# get right mark character address into C
ALUOP_AL %B%+%BL%
CALL :cursor_get_mark               # A now has right mark offset
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%         # Check if mark is defined
JNZ .cmg_finish
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%            # mask top four bits of AH
LDI_BH 0x40
ALUOP_CH %A+B%+%AH%+%BH%            # CH now has top byte of char address of right mark
ALUOP_PUSH %A%+%AL%                 # top of stack has lower byte of char address of right mark
MOV_CL_AL                           # put left mark back into AL
POP_CL                              # CL now has lower byte of char address of right mark

# get left mark character address into A
CALL :cursor_get_mark               # A now has left mark offset
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%         # Check if mark is defined
JNZ .cmg_finish
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%            # mask top four bits of AH
LDI_BH 0x40
ALUOP_AH %A+B%+%AH%+%BH%            # AH now has top byte of char address of left mark

# get right mark character address into B
MOV_CH_BH
MOV_CL_BL

# get number of chars to transcribe into B
CALL :sub16_b_minus_a               # B now contains num chars to transcribe
ALUOP_PUSH %A%+%AH%
LDI_AH 0x80
ALUOP_FLAGS %A&B%+%AH%+%BH%
POP_AH
JNZ .cmg_finish                     # if negative, do nothing

# Transcribe the characters
.cmg_loop
ALUOP_FLAGS %B%+%BL%
JNZ .cmg_continue
ALUOP_FLAGS %B%+%BH%
JNZ .cmg_continue
JMP .cmg_finish                     # If the counter in B is now zero, exit the loop
.cmg_continue
LDA_A_TD                            # get character at A (left mark)
STA_D_TD                            # write it to string at D
CALL :incr16_a
INCR_D                              # move right
CALL :decr16_b                      # count this char
JMP .cmg_loop

.cmg_finish
ALUOP_ADDR_D %zero%                 # write terminating null at D
CALL :heap_pop_all
RET


# Turns the cursor flag on or off, then jumps to :cursor_display_sync
:cursor_off
ST $crsr_on 0
JMP :cursor_display_sync

:cursor_on
ST $crsr_on 1
JMP :cursor_display_sync

# Updates the %display_color% memory at the current cursor
# location, based on the cursor flag
:cursor_display_sync
PUSH_DL
PUSH_DH
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
LD_DH $crsr_addr_color
LD_DL $crsr_addr_color+1    # address of our cursor in the color space in D
LDA_D_AH                    # Load the color data at the cursor into AH
LD_AL $crsr_on              # Load the cursor flag into AL
ALUOP_FLAGS %A%+%AL%        # Check if AL is 0 or non-zero
JZ .cs_off
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A|B%+%AH%+%BL% # set the cursor bit in AH and store it back at $crsr_addr_color
POP_BL
JMP .cs_done
.cs_off
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A&~B%+%AH%+%BL% # clear the cursor bit in AH and store it back at $crsr_addr_color
POP_BL
.cs_done
POP_AH
POP_AL
POP_DH
POP_DL
RET

:cursor_conv_rowcol
# Given a row,col coordinate, returns a 12-bit value representing the
# offset in memory from the base of %display_chars% or %display_color%
#
# Inputs:
#  AH - row (0-59)
#  AL - col (0-63)
#
# Outputs:
#  A = 12 bit absolute offset
ALUOP_PUSH %B%+%BL%
LDI_BL 0b00000001           # mask to get the LSB
ALUOP_FLAGS %A&B%+%AH%+%BL% # check if LSB is set
JZ .co_one
LDI_BL 0b01000000           # mask used to set the 7th bit
ALUOP_AL %AL%+%BL%+%A|B%    # set the 7th bit in AL
.co_one
LDI_BL 0b00000010           # mask to get the LSB-1
ALUOP_FLAGS %A&B%+%AH%+%BL% # check if LSB-1 is set
JZ .co_two
LDI_BL 0b10000000           # mask used to set the 8th bit
ALUOP_AL %AL%+%BL%+%A|B%    # set the 8th bit in AL
.co_two
ALUOP_AH %AH%+%A>>1%        # shift AH right one position
ALUOP_AH %AH%+%A>>1%        # shift AH right one position
POP_BL
RET

:cursor_conv_addr
# Given an address within the chars or colors memory range in A,
# returns the corresponding row/col in AH and AL.
#
# Inputs:
#  A - Address within the colors or chars ranges
#
# Oputputs:
#  AH - row (0-59)
#  AL - col (0-63)
ALUOP_PUSH %B%+%BH%

# Mask out the top nybble of AH to return a 12-bit offset
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%

# If the MSB of AL is 1, shift AH left with Cin, otherwise without
LDI_BH 0x80
ALUOP_FLAGS %A&B%+%AL%+%BH%
JZ .cca_nocin1
ALUOP_AH %A<<1%+%AH%+%Cin%
JMP .cca_2ndbit
.cca_nocin1
ALUOP_AH %A<<1%+%AH%

# Now do the same for the second bit of AL
.cca_2ndbit
LDI_BH 0x40
ALUOP_FLAGS %A&B%+%AL%+%BH%
JZ .cca_nocin2
ALUOP_AH %A<<1%+%AH%+%Cin%
JMP .cca_doneshifting
.cca_nocin2
ALUOP_AH %A<<1%+%AH%

# Mask out the top two bits of AL
.cca_doneshifting
LDI_BH 0x3f
ALUOP_AL %A&B%+%AL%+%BH%

# AH now contains the row, and AL now contains the column
POP_BH
RET

######
# Single-step cursor movement.
# No inputs or outputs.
######

# Moves the cursor left one column (wraps if necessary)
:cursor_left
ALUOP_PUSH %A%+%AL%
LDI_AL -1
CALL .cursor_move_real
POP_AL
RET
# Moves the cursor right one column (wraps if necessary)
:cursor_right
ALUOP_PUSH %A%+%AL%
LDI_AL 1
CALL .cursor_move_real
POP_AL
RET
# Moves the cursor up one row
:cursor_up
ALUOP_PUSH %A%+%AL%
LDI_AL -64
CALL .cursor_move_real
POP_AL
RET
# Moves the cursor down one row
:cursor_down
ALUOP_PUSH %A%+%AL%
LDI_AL 64
CALL .cursor_move_real
POP_AL
RET

######
# The actual function that moves the cursor. Allows the cursor to move within
# the 0x4000-0x4eff range and does nothing if the cursor would go out of bounds.
#
# Inputs:
#  AL - cursor movement amount, in absolute address steps
.cursor_move_real
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

# AL is our movement amount, but it's an 8-bit value, so extend into
# AH if it's negative
LDI_AH 0x00
LDI_BL 0x80
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .cmr_1                   # if AL was positive, continue.
LDI_AH 0xff                 # otherwise, ensure A is negative
.cmr_1
LD16_B $crsr_addr_chars
CALL :add16_to_b            # B now contains the new cursor addr
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%           # save new cursor addr in C

# if the cursor moves, will the new addr be < %display_chars% ??
LDI_A %display_chars%
CALL :sub16_b_minus_a       # B now contains the delta, >= 0 if greater than %display_chars% and OK, but < 0 if out of range.
LDI_AL 0x80
ALUOP_FLAGS %A&B%+%AL%+%BH% # so if B is negative (MSB is set)
JNZ .cmr_done               # don't move the cursor

# if the cursor moves, will the new addr be >= %display_chars%+64x60?
MOV_CH_BH
MOV_CL_BL                   # new cursor addr in B
LDI_A %display_chars%+3839  # 64 col x 60 row, minus 1 to get to last valid addr
CALL :sub16_a_minus_b       # A now contains the delta, >= 0 if less than or equal to %display_chars%+3839 and OK, but < 0 if out of range.
LDI_BL 0x80
ALUOP_FLAGS %A&B%+%AH%+%BL% # if B is negative (MSB is set)
JNZ .cmr_done               # don't move the cursor

# cursor move is OK, so let's sync at the new position
MOV_CH_AH
MOV_CL_AL                   # new cursor addr in A
CALL :cursor_goto_addr      # sync the cursor to the new location

.cmr_done
POP_BH
POP_BL
POP_AH
POP_AL
POP_CL
POP_CH
RET

:cursor_goto_addr
# Moves the cursor to an absolute addr (or offset).
# The top four bits of the address are ignored.
#
# Inputs:
#  A - address/offset
PUSH_DL
PUSH_DH
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%

# First we need to turn off the cursor at the current cursor location.
LD_DH $crsr_addr_color
LD_DL $crsr_addr_color+1            # D reg has the current cursor address in color space
LDA_D_AH                            # Load RAM@D into AH - current color flags for cursor
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A&~B%+%AH%+%BL%       # Clear the cursor bit from that byte and store it back
POP_BL

# Get AH back from the stack
PEEK_AH

# Mask the top four bits of the offset
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%

# add %display_chars% to the offset and store in $crsr_addr_chars
LDI_B %display_chars%                   # put the char base addr in B
CALL :add16_to_b                        # B now contains the new cursor absolute address
ALUOP_ADDR %B%+%BH% $crsr_addr_chars    # store the new absolute address in RAM
ALUOP_ADDR %B%+%BL% $crsr_addr_chars+1

# add %display_color% to the offset and store in $crsr_addr_color
LDI_B %display_color%                   # put the color base addr in B
CALL :add16_to_b                        # B now contains the new cursor absolute address
ALUOP_ADDR %B%+%BH% $crsr_addr_color    # store the new absolute address in RAM
ALUOP_ADDR %B%+%BL% $crsr_addr_color+1

# turn offset into row,col in A
CALL :cursor_conv_addr

# Store the new row and column into our global vars
ALUOP_ADDR %A%+%AL% $crsr_col
ALUOP_ADDR %A%+%AH% $crsr_row

# Set or clear the cursor bit at the new location
CALL :cursor_display_sync

POP_AH
POP_AL
POP_BH
POP_BL
POP_DH
POP_DL
RET

:cursor_goto_rowcol
# Moves the cursor to an absolute col,row position
#
# Inputs:
#  AH - row (0-59)
#  AL - col (0-63)
PUSH_DL
PUSH_DH
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%

# First we need to turn off the cursor at the current cursor location.
LD_DH $crsr_addr_color
LD_DL $crsr_addr_color+1            # D reg has the current cursor address in color space
LDA_D_AH                            # Load RAM@D into AH - current color flags for cursor
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A&~B%+%AH%+%BL%       # Clear the cursor bit from that byte and store it back
POP_BL

# Get our row argument back off the stack
PEEK_AH

# Store the new row and column into our global vars
ALUOP_ADDR %A%+%AL% $crsr_col
ALUOP_ADDR %A%+%AH% $crsr_row

# turn row,col into an offset stored in A
CALL :cursor_conv_rowcol

# add %display_chars% to the offset and store in $crsr_addr_chars
LDI_B %display_chars%                   # put the char base addr in B
CALL :add16_to_b                        # B now contains the new cursor absolute address
ALUOP_ADDR %B%+%BH% $crsr_addr_chars    # store the new absolute address in RAM
ALUOP_ADDR %B%+%BL% $crsr_addr_chars+1

# add %display_color% to the offset and store in $crsr_addr_color
LDI_B %display_color%                   # put the color base addr in B
CALL :add16_to_b                        # B now contains the new cursor absolute address
ALUOP_ADDR %B%+%BH% $crsr_addr_color    # store the new absolute address in RAM
ALUOP_ADDR %B%+%BL% $crsr_addr_color+1

# Set or clear the cursor bit at the new location
CALL :cursor_display_sync

POP_AH
POP_AL
POP_BH
POP_BL
POP_DH
POP_DL
RET

