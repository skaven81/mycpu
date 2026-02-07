# vim: syntax=asm-mycpu

:boot_kb_init
LDI_C .kb_init_banner
CALL :print
CALL :keyboard_init
LDI_C .ok_str
CALL :print
RET

.kb_init_banner "Keyboard init \0"
.ok_str "OK\n\0"
