# vim: syntax=asm-mycpu

:boot_uart_init
# Initialize UART
LDI_C .uart_init_banner
CALL :print
CALL :uart_init_9600_8n1
# Unmask interrupts and flush any ready data
UMASKINT
# Pause 0.5s for serial to flush
LDI_AH 0x00 # bcd seconds
CALL :heap_push_AH
LDI_AH 0x50 # bcd subseconds
CALL :heap_push_AL
CALL :sleep # sleep for 0.5 sec
MASKINT
LDI_C .ok
CALL :print
RET

.uart_init_banner "UART init 9600,8n1 \0"
.ok "OK\n\0"
