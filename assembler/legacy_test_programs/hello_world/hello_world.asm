# vim: syntax=asm-mycpu

NOP

.top

LDI_AH  '*'     # char to clear screen with
LDI_AL  0x3f    # white, no blink, no cursor
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

LDI_AH  '-'     # char to clear screen with
LDI_AL  0x3f    # white, no blink, no cursor
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

LDI_AH  ' '     # char to clear screen with
LDI_AL  0x3f    # white, no blink, no cursor
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

LDI_AH  '-'     # char to clear screen with
LDI_AL  0x3f    # white, no blink, no cursor
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

JMP .top

.pause
LDI_AH  0x00
LDI_AL  0x00
.nop_loop
NOP
NOP
NOP
NOP
ALUOP_AL %A+1%+%AL%
JNO .nop_loop
ALUOP_AH %A+1%+%AH%
JNO .nop_loop
RET

.hw "Hello, World!\0"
