# vim: syntax=asm-mycpu

:cmd_clockspeed
CALL :sys_clock_speed
LDI_C .clockspeed
CALL :heap_push_A
CALL :printf
RET

.clockspeed "Current clockspeed is %UkHz\n\0"
