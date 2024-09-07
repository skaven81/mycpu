# vim: syntax=asm-mycpu

:cmd_extmalloc

CALL :extmalloc
LDI_C .ret
CALL :printf

RET

.ret "Allocated page 0x%x\n\0"
