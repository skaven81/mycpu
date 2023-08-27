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

LDI_AL 0x00
LDI_BL 0x40
LDI_C .color_print5
.hex_loop
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .hex_loop_done
CALL :heap_push_AL
CALL :heap_push_AL
CALL :printf
ALUOP_AL %A+1%+%AL%
JMP .hex_loop
.hex_loop_done
LDI_C .color_print6
CALL :print

# Turn color rendering off
ST $term_color_enabled 0x00

RET

.color_print1 "@00@@00 @01@@01 @02@@02 @03@@03 @04@@04 @05@@05 @06@@06 @07@@07@r\n\0"
.color_print2 "@10@@10 @11@@11 @12@@12 @13@@13 @14@@14 @15@@15 @16@@16 @17@@17@r\n\0"
.color_print3 "@20@@20 @21@@21 @22@@22 @23@@23 @24@@24 @25@@25 @26@@26 @27@@27@r\n\0"
.color_print4 "@30@@30 @31@@31 @32@@32 @33@@33 @34@@34 @35@@35 @36@@36 @37@@37@r\n\0"
.color_print5 "@x%x@@x%x\0"
.color_print6 "@r\n\0"
