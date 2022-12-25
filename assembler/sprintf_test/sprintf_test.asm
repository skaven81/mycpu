# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

CALL :heap_init

LDI_C .fmt1
LDI_D %display_chars%
LDI_AL 0xef
CALL :heap_push_AL
LDI_AL 0xbe
CALL :heap_push_AL
LDI_AL 0x34
CALL :heap_push_AL
LDI_AL 0x12
CALL :heap_push_AL

CALL :sprintf

LDI_C .fmt2
LDI_D %display_chars%+128
LDI_A .substr
CALL :heap_push_A

CALL :sprintf

LDI_C .fmt3
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL
LDI_D %display_chars%+256
CALL :sprintf

LDI_C .fmt4
LDI_AL '$'
CALL :heap_push_AL
LDI_AL '#'
CALL :heap_push_AL
LDI_AL '@'
CALL :heap_push_AL
LDI_AL '!'
CALL :heap_push_AL
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL

LDI_D %display_chars%+384
CALL :sprintf


HLT

.fmt1 "Percent:[%%] hex:[0x%X%x 0x%X%x] error:[%$]\0"
.fmt2 "An error %y and a substring [%s]\0"
.substr "Hello, world!\0"
.fmt3 "BCD HH:MM %B:%B or in binary %2:%2\0"
.fmt4 "BCD-short HH:MM %b:%b   Raw chars [%c%c%c%c]\0"

.noirq
RETI
