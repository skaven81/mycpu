# vim: syntax=asm-mycpu

# Cursor movement functions.
#
# Sync is split from movement: :cursor_left/right/up/down and
# :cursor_goto_* update position state ONLY -- they never touch the color
# framebuffer or the cursor glyph. Callers that need the cursor glyph
# visible at the new position must call :cursor_display_sync themselves.
# :cursor_on/:cursor_off are the exception: they are explicit visibility
# requests, so they still sync immediately.
#
# ESC[s / ESC[u save/restore are NOT implemented -- the terminal subsystem
# came in over the 16 KiB ROM budget, and dropping save/restore was one of
# the cuts made to fit.

VAR global byte $crsr_row
VAR global byte $crsr_col
VAR global byte $crsr_on
VAR global word $crsr_addr_chars
VAR global word $crsr_addr_color

######
# Resets cursor state to the top-left corner, cursor on, with the
# chars/color framebuffer pointers pointing at the start of the display.
# Does not touch the framebuffer itself -- call :cursor_display_sync after
# if the cursor glyph needs to appear.
:cursor_init
ST $crsr_row 0x00
ST $crsr_col 0x00
ST $crsr_on 0x01
ST16 $crsr_addr_chars %display_chars%
ST16 $crsr_addr_color %display_color%
RET

######
# Turns the cursor flag on or off, then jumps to :cursor_display_sync.
# Unlike goto/movement, these are explicit visibility requests, so they
# still sync immediately.
:cursor_off
ST $crsr_on 0x00
JMP :cursor_display_sync

:cursor_on
ST $crsr_on 0x01
JMP :cursor_display_sync

######
# Updates the color framebuffer at the current cursor location to set or
# clear the cursor bit, based on the cursor-on flag. This is the only
# place that touches the color framebuffer for cursor display -- movement
# and goto functions do not do this automatically, so callers that need
# the glyph visible at a new position must call this explicitly.
:cursor_display_sync
PUSH_DL
PUSH_DH
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
LD_DH $crsr_addr_color
LD_DL $crsr_addr_color+1
LDA_D_AH                    # Load the color data at the cursor into AH
LD_AL $crsr_on
ALUOP_FLAGS %A%+%AL%
JZ .cs_off
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A|B%+%AH%+%BL% # set the cursor bit and store it back
POP_BL
JMP .cs_done
.cs_off
ALUOP_PUSH %B%+%BL%
LDI_BL %cursor%
ALUOP_ADDR_D %A&~B%+%AH%+%BL% # clear the cursor bit and store it back
POP_BL
.cs_done
POP_AH
POP_AL
POP_DH
POP_DL
RET

######
# Given a row,col coordinate, returns a 12-bit value representing the
# offset in memory from the base of %display_chars% or %display_color%.
#
# Inputs:
#  AH - row (0-59)
#  AL - col (0-63)
# Outputs:
#  A = 12 bit absolute offset
:cursor_conv_rowcol
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

######
# Given an address within the chars or colors memory range in A, returns
# the corresponding row/col in AH and AL.
#
# Inputs:
#  A - Address within the colors or chars ranges
# Outputs:
#  AH - row (0-59)
#  AL - col (0-63)
:cursor_conv_addr
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
# Single-step cursor movement. Position state only -- no display sync.
# No inputs or outputs.
######

:cursor_left
ALUOP_PUSH %A%+%AL%
LDI_AL -1
CALL .cursor_move_real
POP_AL
RET

:cursor_right
ALUOP_PUSH %A%+%AL%
LDI_AL 1
CALL .cursor_move_real
POP_AL
RET

:cursor_up
ALUOP_PUSH %A%+%AL%
LDI_AL -64
CALL .cursor_move_real
POP_AL
RET

:cursor_down
ALUOP_PUSH %A%+%AL%
LDI_AL 64
CALL .cursor_move_real
POP_AL
RET

######
# The actual function that moves the cursor. Allows the cursor to move
# within the 0x4000-0x4eff range and does nothing if the cursor would go
# out of bounds.
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
ALUOP16O_B %ALU16_A+B%            # B now contains the new cursor addr
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%           # save new cursor addr in C

# if the cursor moves, will the new addr be < %display_chars% ??
LDI_A %display_chars%
ALUOP16O_B %ALU16_B-A%       # B now contains the delta, >= 0 if greater than %display_chars% and OK, but < 0 if out of range.
LDI_AL 0x80
ALUOP_FLAGS %A&B%+%AL%+%BH% # so if B is negative (MSB is set)
JNZ .cmr_done               # don't move the cursor

# if the cursor moves, will the new addr be >= %display_chars%+64x60?
MOV_CH_BH
MOV_CL_BL                   # new cursor addr in B
LDI_A %display_chars%+3839  # 64 col x 60 row, minus 1 to get to last valid addr
ALUOP16O_A %ALU16_A-B%       # A now contains the delta, >= 0 if less than or equal to %display_chars%+3839 and OK, but < 0 if out of range.
LDI_BL 0x80
ALUOP_FLAGS %A&B%+%AH%+%BL% # if B is negative (MSB is set)
JNZ .cmr_done               # don't move the cursor

# cursor move is OK, so let's move to the new position (position state
# only -- no display sync, unlike the original marks-based implementation)
MOV_CH_AH
MOV_CL_AL                   # new cursor addr in A
CALL :cursor_goto_addr

.cmr_done
POP_BH
POP_BL
POP_AH
POP_AL
POP_CL
POP_CH
RET

######
# Moves the cursor to an absolute addr (or offset). Position state only:
# updates crsr_row/col/addr_chars/addr_color. Does NOT touch the color
# framebuffer and does NOT sync the cursor glyph -- call
# :cursor_display_sync explicitly afterward if needed.
#
# Inputs:
#  A - address/offset (top four bits are ignored)
:cursor_goto_addr
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

# Mask the top four bits of the offset
LDI_BH 0x0f
ALUOP_AH %A&B%+%AH%+%BH%

# add %display_chars% to the offset and store in $crsr_addr_chars
LDI_B %display_chars%
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR %B%+%BH% $crsr_addr_chars
ALUOP_ADDR %B%+%BL% $crsr_addr_chars+1

# add %display_color% to the offset and store in $crsr_addr_color
LDI_B %display_color%
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR %B%+%BH% $crsr_addr_color
ALUOP_ADDR %B%+%BL% $crsr_addr_color+1

# turn offset into row,col in A (A still holds the masked offset -- the
# two blocks above only ever wrote to B)
CALL :cursor_conv_addr
ALUOP_ADDR %A%+%AL% $crsr_col
ALUOP_ADDR %A%+%AH% $crsr_row

POP_AL
POP_AH
POP_BL
POP_BH
RET

######
# Moves the cursor to an absolute row,col position. Position state only
# (see :cursor_goto_addr).
#
# :cursor_conv_rowcol and :cursor_conv_addr are exact inverses, so rather
# than duplicate :cursor_goto_addr's address-computation body here a
# second time, convert to an offset and tail-call it -- it derives
# row/col right back via :cursor_conv_addr, reproducing this call's own
# AH/AL exactly. This is a cold path (goto calls are rare relative to
# putchar), so the extra conversion round-trip costs nothing that matters.
#
# Inputs:
#  AH - row (0-59)
#  AL - col (0-63)
:cursor_goto_rowcol
CALL :cursor_conv_rowcol             # A = offset
JMP :cursor_goto_addr                # tail call: stores row/col + both
                                      # framebuffer addresses, then RETs
