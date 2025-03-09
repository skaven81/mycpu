# vim: syntax=asm-mycpu

:boot_kb_init
LDI_C .kb_init_banner
CALL :print
CALL :keyboard_init
LDI_C .ok
CALL :print
RET

.kb_init_banner "Keyboard init \0"
.ok "OK\n\0"
