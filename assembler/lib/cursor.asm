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
CALL :cursor_offset

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

