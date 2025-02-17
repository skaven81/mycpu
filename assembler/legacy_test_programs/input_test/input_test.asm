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

# Initialize all the things
CALL :keyboard_init
CALL :heap_init
CALL :cursor_init
CALL :cursor_display_sync

VAR global 128 $input_buffer
VAR global byte $input_count
ST $input_count 0
ST $input_buffer 0

# Go into a loop of printing the prompt, collecting input, and doing things in response
.loop
LDI_C .prompt_fmt       # Print the prompt
LD_AL $input_flags
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .insert_on
LDI_AL 'O'
JMP .do_prompt_printf
.insert_on
LDI_AL 'I'
.do_prompt_printf
CALL :heap_push_AL
LD_AL $input_count
CALL :heap_push_AL
CALL :printf

LDI_AL 128              # only allow up to 128 chars of input
CALL :input
LDI_AL 0x0d             # enter
CALL :putchar           # wrap cursor to next line

LDI_AL 1
CALL :cursor_get_mark
CALL :cursor_conv_addr
CALL :heap_push_AL
CALL :heap_push_AH
LDI_AL 0
CALL :cursor_get_mark
CALL :cursor_conv_addr
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .response0
CALL :printf

LDI_AL 0
LDI_BL 1
LDI_D $input_buffer
CALL :cursor_mark_getstring

LDI_C .response1
LDI_A $input_buffer
CALL :heap_push_A
CALL :printf

LD_AL $input_count
ALUOP_ADDR %A+1%+%AL% $input_count
JMP .loop

.noirq
RETI

.prompt_fmt "%u %c> \0"
.response0  "mark 0 row %u col %u / mark 1 row %u col %u\n\0"
.response1  "Your input: [%s]\n\0"
