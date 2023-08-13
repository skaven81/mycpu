# vim: syntax=asm-mycpu

#######
# Fills the screen with a character stored in AH (usually 0x00)
# and a color setting stored in AL (usually 0x3f).
#
# Inputs:
#   AH: character to fill screen with
#   AL: color to fill screen with

:clear_screen
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AL%             # save color byte for later

LDI_C %display_chars%
LDI_AL 29                       # 30 128 byte segments -> 60 lines
CALL :memfill_segments

PEEK_AH                         # Put the color char into AH
LDI_C %display_color%
LDI_AL 29                       # 30 128 byte segments -> 60 lines
CALL :memfill_segments

POP_AL
POP_CL
POP_CH

RET

