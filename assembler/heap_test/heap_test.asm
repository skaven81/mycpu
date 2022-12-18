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

LDI_AL 'a'
CALL :heap_push_AL
LDI_AL 'b'
CALL :heap_push_AL
LDI_AL 'c'
CALL :heap_push_AL

LDI_D %display_chars%
CALL .print_heap

LDI_AL 'd'
CALL :heap_push_AL
LDI_AL 'e'
CALL :heap_push_AL
LDI_AL 'f'
CALL :heap_push_AL

LDI_D %display_chars%+64
CALL .print_heap

LDI_AL 'o'
LDI_AH 'l'
CALL :heap_push_A
LDI_AL 'e'
LDI_AH 'H'
CALL :heap_push_A

LDI_D %display_chars%+128
CALL .print_heap_words

HLT


.print_heap
CALL :heap_pop_AL
ALUOP_ADDR_D %A%+%AL%
INCR_D
CALL :heap_pop_AL
ALUOP_ADDR_D %A%+%AL%
INCR_D
CALL :heap_pop_AL
ALUOP_ADDR_D %A%+%AL%
INCR_D
RET

.print_heap_words
CALL :heap_pop_A
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D
CALL :heap_pop_A
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D
RET

.noirq
RETI
