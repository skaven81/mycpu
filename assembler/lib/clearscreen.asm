# vim: syntax=asm-mycpu

#######
# Fills the screen with a character stored in AH (usually 0x00)
# and a color setting stored in AL (usually 0x3f).
#
# Inputs:
#   AH: character to fill screen with
#   AL: color to fill screen with

:clear_screen

ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

LDI_B   0x0f00                  # 64x60 chars to clear
LDI_C   0x4000                  # framebuffer chars
LDI_D   0x5000                  # framebuffer color

.loop
ALUOP_ADDR_C %A%+%AH%           # store AH into RAM@C (char)
INCR_C
ALUOP_ADDR_D %A%+%AL%           # store AL into RAM@D (color)
INCR_D

ALUOP_BL    %B-1%+%BL%          # decrement BL
JNO .decr16_done                # if this didn't overflow BL, don't decrement BH
ALUOP_BH    %B-1%+%BH%          # decrement BH on overflow
.decr16_done
ALUOP_FLAGS %B%+%BL%
JNZ .loop                       # continue looping if BL is non-zero
ALUOP_FLAGS %B%+%BH%
JNZ .loop                       # continue looping if BH is non-zero

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH

RET

