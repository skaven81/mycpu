# vim: syntax=asm-mycpu

NOP

# Displays the hello world screen alternating between
# '*' and '-' in normal operation.  When an interrupt
# occurs, the screen is cleared and "IRQ active" displays.

# Install IRQ handlers
ST16    %IRQ0addr%  .irq0
ST16    %IRQ1addr%  .noirq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  .noirq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Enable interrupts
UMASKINT

###
# Main loop
###
.top

LDI_AH  '*'     # char to clear screen with
LDI_AL  %white%+%blink%
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

LDI_AH  '-'     # char to clear screen with
LDI_AL  %cyan%+%blink%
CALL :clear_screen

LDI_C   .hw
LDI_D   0x4000+1882 # 30 rows down, 58 chars over
CALL :strcpy

CALL .pause

JMP .top

###
# IRQ handler
###
.irq0
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
LDI_AH  ' '     # char to clear the screen with
LDI_AL  %magenta%+%cursor%
CALL :clear_screen
LDI_C   .irqtxt
LDI_D   0x4000+1880 # 30 rows down, 56 chars over
CALL :strcpy
POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
# Disabled IRQ handlers simply return
# without doing anything
.noirq
RETI

###
# Pause function runs 64k iterations of
# the loop, for a total of ~1.7M clocks
###
.pause
LDI_AH  0x00
LDI_AL  0x00
.nop_loop
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
NOP                     # 2 clocks
ALUOP_AL %A+1%+%AL%     # 4 clocks
JNO .nop_loop           # 5 clocks if jumping (4 otherwise)
ALUOP_AH %A+1%+%AH%     # 4 clocks
JNO .nop_loop           # 5 clocks if jumping (4 otherwise)
RET

.hw     "Hello, World!\0"
.irqtxt "Interrupt active\0"
