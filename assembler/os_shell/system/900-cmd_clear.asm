# vim: syntax=asm-mycpu

:cmd_clear
LDI_AH  0x00
LDI_AL  %white%
CALL :clear_screen
CALL :cursor_init       # easy way to move the cursor back to 0,0 and clear all marks
RET
