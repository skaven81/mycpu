# vim: syntax=asm-mycpu

NOP

MASKINT

LDI_AH  0x00    # char to clear screen with
LDI_AL  0x3f    # white, no blink, no cursor
CALL :clear_screen

LDI_C   0x4000
LDI_D   0x5000
LDI_AH  0x3f
LDI_BH  0x00
LDI_BL  0xdb

.loop
ALUOP_AH     %A-1%+%AH% # decr counter
JZ .done

ALUOP_ADDR_C %B%+%BL%   # store char
ALUOP_ADDR_D %B%+%BH%   # store color
ALUOP_BH     %B+1%+%BH% # incr color
INCR_C
INCR_D

JMP .loop

.done

UMASKINT

HLT
