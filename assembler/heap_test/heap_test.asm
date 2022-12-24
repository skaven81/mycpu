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

LDI_AL 't'
CALL :heap_push_AL
LDI_AL ' '
CALL :heap_push_AL
LDI_AL 'L'
CALL :heap_push_AL
LDI_AL 'A'
CALL :heap_push_AL

LDI_D %display_chars%
CALL .print_heap_al

LDI_AL '!'
CALL :heap_push_AL
LDI_AL 't'
CALL :heap_push_AL
LDI_AL 's'
CALL :heap_push_AL
LDI_AL 'e'
CALL :heap_push_AL

CALL .print_heap_al

LDI_AL 'l'
LDI_AH 'l'
CALL :heap_push_A
LDI_AL 'e'
LDI_AH 'H'
CALL :heap_push_A

LDI_D %display_chars%+64
CALL .print_heap_a

LDI_BL 'w'
LDI_BH ' '
CALL :heap_push_B
LDI_BL ','
LDI_BH 'o'
CALL :heap_push_B

CALL .print_heap_b

LDI_BL 'd'
CALL :heap_push_BL
LDI_BL 'l'
CALL :heap_push_BL
LDI_BL 'r'
CALL :heap_push_BL
LDI_BL 'o'
CALL :heap_push_BL

CALL .print_heap_bl

LDI_AL '1'
LDI_AH '2'
LDI_BL '3'
LDI_BH '4'
LDI_CL '5'
LDI_CH '6'
LDI_DL '7'
LDI_DH '8'

CALL :heap_push_all

LDI_AL 'a'
LDI_AH 'b'
LDI_BL 'c'
LDI_BH 'd'
LDI_CL 'e'
LDI_CH 'f'
LDI_DL 'g'
LDI_DH 'h'

ALUOP_ADDR %A%+%AL% %display_chars%+128
ALUOP_ADDR %A%+%AH% %display_chars%+129
ALUOP_ADDR %B%+%BL% %display_chars%+130
ALUOP_ADDR %B%+%BH% %display_chars%+131
ST_CL               %display_chars%+132
ST_CH               %display_chars%+133
ST_DL               %display_chars%+134
ST_DH               %display_chars%+135

CALL :heap_pop_all

ALUOP_ADDR %A%+%AL% %display_chars%+192
ALUOP_ADDR %A%+%AH% %display_chars%+193
ALUOP_ADDR %B%+%BL% %display_chars%+194
ALUOP_ADDR %B%+%BH% %display_chars%+195
ST_CL               %display_chars%+196
ST_CH               %display_chars%+197
ST_DL               %display_chars%+198
ST_DH               %display_chars%+199

HLT

.print_heap_al
CALL :heap_pop_AL
ALUOP_ADDR_D %A%+%AL%
INCR_D
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

.print_heap_a
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

.print_heap_bl
CALL :heap_pop_BL
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :heap_pop_BL
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :heap_pop_BL
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :heap_pop_BL
ALUOP_ADDR_D %B%+%BL%
INCR_D
RET

.print_heap_b
CALL :heap_pop_B
ALUOP_ADDR_D %B%+%BH%
INCR_D
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :heap_pop_B
ALUOP_ADDR_D %B%+%BH%
INCR_D
ALUOP_ADDR_D %B%+%BL%
INCR_D
RET


.noirq
RETI
