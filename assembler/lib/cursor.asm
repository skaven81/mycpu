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
PUSH_DH                         # ST16 overwrites D register
PUSH_DL                         # ST16 overwrites D register
ST $crsr_row 0
ST $crsr_col 0
ST $crsr_on 1
ST16 $crsr_addr_chars %display_chars%
ST16 $crsr_addr_color %display_color%
POP_DL
POP_DH
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
LD_AL $crsr_on              # Load the cursor flag into AL
ALUOP_FLAGS %A%+%AL%        # Check if AL is 0 or non-zero
JZ .cs_off
ALUOP_ADDR_D %AH%+%A_setcursor% # set the cursor bit in AH and store at $crsr_addr_color
JMP .cs_done
.cs_off
ALUOP_ADDR_D %AH%+%A_clrcursor% # clear the cursor bit in AH and store at $crsr_addr_color
.cs_done
POP_AH
POP_AL
POP_DH
POP_DL
RET

:cursor_offset
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
ALUOP_AH %AH%+%A>>1%        # shift AH right one position
JNO .co_one                 # if this did not result in a carry out, skip next steps
LDI_BL 0b01000000           # mask used to set the 7th bit
ALUOP_AL %AL%+%BL%+%A|B%    # set the 7th bit in AL
.co_one
ALUOP_AH %AH%+%A>>1%        # shift AH right one position
JNO .co_two                 # if this did not result in a carry out, skip next steps
LDI_BL 0b10000000           # mask used to set 8th bit
ALUOP_AL %AL%+%BL%+%A|B%    # set the 8th bit in AL
.co_two
POP_BL
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

# First we need to turn off the cursor at the current cursor location
LD_DH $crsr_addr_color
LD_DL $crsr_addr_color+1                        # D reg has the current cursor address in color space
LDA_D_AH                                        # Load RAM@D into AH - current color flags for cursor
ALUOP_ADDR_D %AH%+%A_clrcursor%                 # Clear the cursor bit from that byte and store it back

# Get our row argument back
PEEK_AH

# Store the new row and column into our global vars
ALUOP_ADDR %A%+%AL% $crsr_col
ALUOP_ADDR %A%+%AH% $crsr_row

# turn row,col into an offset
CALL :cursor_offset         # convert the col,row to an offset in A

# add %display_chars% to the offset and store in $crsr_addr_chars
LD_BH $crsr_addr_chars      # put the char base addr in B
LD_BL $crsr_addr_chars+1    # put the char base addr in B
ALUOP_ADDR %A+B%+%AL%+%BL% $crsr_addr_chars+1 # add the offset to BL and store in global var
JNO .cg_one                 # skip BH increment if no overflow
ALUOP_BH %B+1%+%BH%         # increment BH on overflow
.cg_one
ALUOP_ADDR %A+B%+%AH%+%BH% $crsr_addr_chars  # add the offset to BH and store in global var

# add %display_color% to the offset and store in $crsr_addr_color
LD_BH $crsr_addr_color      # put the char base addr in B
LD_BL $crsr_addr_color+1    # put the char base addr in B
ALUOP_ADDR %A+B%+%AL%+%BL% $crsr_addr_color+1 # add the offset to BL and store in global var
JNO .cg_one                 # skip BH increment if no overflow
ALUOP_BH %B+1%+%BH%         # increment BH on overflow
.cg_one
ALUOP_ADDR %A+B%+%AH%+%BH% $crsr_addr_color  # add the offset to BH and store in global var

# Set or clear the cursor bit at the new location
CALL :cursor_display_sync

POP_AH
POP_AL
POP_BH
POP_BL
POP_DH
POP_DL
RET

