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

.loop
CALL :sys_clock_speed
CALL :heap_push_A
LDI_C .fmt1
LDI_D %display_chars%
CALL :sprintf
JMP .loop

HLT

.fmt1 "Current clock speed: %UkHz\0"

.noirq
RETI
