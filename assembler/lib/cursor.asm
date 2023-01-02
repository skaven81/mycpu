# vim: syntax=asm-mycpu

# Cursor movement functions

VAR global byte $crsr_row
VAR global byte $crsr_col
VAR global word $crsr_addr_chars
VAR global word $crsr_addr_color
VAR global byte $crsr_on

:cursor_init
# Initialize the global variables; cursor is set to 0,0 (top left corner) with
# the cursor showing (on)
ST $crsr_row 0
ST $crsr_col 0
ST $crsr_on 1
ST16 $crsr_addr_chars %display_chars%
ST16 $crsr_addr_color %display_color%
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
ALUOP_ADDR_D %AH%+%A_setcursor% # set the cursor bit in AH and store it back at $crsr_addr_color
JMP .cs_done
.cs_off
ALUOP_ADDR_D %AH%+%A_clrcursor% # clear the cursor bit in AH and store it back at $crsr_addr_color
.cs_done
POP_AH
POP_AL
POP_DH
POP_DL
RET

:cursor_conv_rowcol
# Given a column,row coordinate, returns a 12-bit value representing the
# offset in memory from the base of %display_chars% or %display_color%
#
# Inputs:
#  AL - col (0-63)
#  AH - row (0-59)
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
#  AL - col (0-63)
#  AH - row (0-59)
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
CALL :heap_push_all

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
CALL :cursor_conv_addr      # get row:col from address
CALL :cursor_goto           # sync the cursor to the new location

.cmr_done
CALL :heap_pop_all
RET


:cursor_goto
# Moves the cursor to an absolute col,row position
#
# Inputs:
#  AL - col (0-63)
#  AH - row (0-59)
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
ALUOP_ADDR_D %AH%+%A_clrcursor%     # Clear the cursor bit from that byte and store it back

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

