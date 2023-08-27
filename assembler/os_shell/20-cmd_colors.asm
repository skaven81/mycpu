# vim: syntax=asm-mycpu

# Figure out a way for and :printf to print colors.  Probably via a global var
# that sets the current color for :putchar then add some kind of escape code
# for printf that can change that value as a string is printed.  But also have
# an override that puts the terminal into "monochrome" mode, which will be
# able to print faster because the color page doesn't have to be touched.

:cmd_colors

# Turn color rendering on
ST $term_color_enabled 0x01

LDI_C .color_print1
CALL :print
LDI_C .color_print2
CALL :print
LDI_C .color_print3
CALL :print
LDI_C .color_print4
CALL :print
LDI_C .color_print5
CALL :print
LDI_C .color_print7
CALL :print

LDI_BL 0x1f
LDI_AL %blue%
.hexloop
LDI_C .color_print8
CALL :heap_push_AL
CALL :heap_push_AL
CALL :printf
ALUOP_AL %A+1%+%AL%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .hexloop

# Turn color rendering off
ST $term_color_enabled 0x00

RET

.color_print1 "Print text in @34bright red@r reset @16dark yellow@r reset\n\0"
.color_print2 "@00black @04red @02green @06yellow @01blue @05magenta @03cyan @07white\n\0"
.color_print3 "@10black @14red @12green @16yellow @11blue @15magenta @13cyan @17white\n\0"
.color_print4 "@20black @24red @22green @26yellow @21blue @25magenta @23cyan @27white\n\0"
.color_print5 "@30black @34red @32green @36yellow @31blue @35magenta @33cyan @37white\n\0"
.color_print7 "@Ccursor@c no-cursor @Bblink@b no-blink@r reset\n\0"
.color_print8 "@x%xPrinted in color 0x%x@r\n\0"
