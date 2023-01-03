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

# Set up buffered keyboard input
MASKINT
LD_CH %IRQ1addr%
LD_CL %IRQ1addr%+1
PUSH_CH                         # save the current IRQ1 vector
PUSH_CL
LD_TD  %kb_key%                 # clear any pending KB interrupt
ST16 %IRQ1addr%  :kb_irq_buf    # use buffered keyboard input
UMASKINT

# Start collecting input
.input_loop
CALL :kb_bufsize                # bufsize into AL
ALUOP_FLAGS %A%+%AL%
JZ .input_loop                  # go back to polling if buffer is empty
CALL :kb_readbuf                # buffered keyflags into AH and keystroke into AL

# If a break event, do nothing
LDI_BH %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .input_loop

# If a null event, do nothing
ALUOP_FLAGS %A%+%AL%
JZ .input_loop

# If up arrow, move the cursor
LDI_BH 0x18
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_up_arrow
CALL :cursor_up
JMP .input_loop

# If down arrow, move the cursor
.not_up_arrow
LDI_BH 0x19
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_down_arrow
CALL :cursor_down
JMP .input_loop

# If left arrow, move the cursor
.not_down_arrow
LDI_BH 0x1b
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_left_arrow
CALL :cursor_left
JMP .input_loop

# If right arrow, move the cursor
.not_left_arrow
LDI_BH 0x1a
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_right_arrow
CALL :cursor_right
JMP .input_loop

# If 'c', printf the clock
.not_right_arrow
LDI_BH 'C'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_char_c
LDI_C .fmt
LD_AL %tmr_clk_sec%
CALL :heap_push_AL
LD_AL %tmr_clk_min%
CALL :heap_push_AL
LD_AL %tmr_clk_hr%
CALL :heap_push_AL
LD_AL %tmr_clk_date%
CALL :heap_push_AL
LD_AL %tmr_clk_month%
LDI_BL %tmr_clk_month_mask%
ALUOP_AL %A&B%+%AL%+%BL%
CALL :heap_push_AL
LD_AL %tmr_clk_year%
CALL :heap_push_AL
LD_AL %tmr_clk_century%
CALL :heap_push_AL
CALL :printf
JMP .input_loop

.not_char_c
LDI_BH 'S'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .not_char_s
LDI_C .fmt
CALL :print
JMP .input_loop

# If nothing matched, just print the char
.not_char_s
CALL :putchar
JMP .input_loop

.noirq
RETI

.fmt "yyyy-mm-dd HH:MM:SS %B%B-%B-%B %B:%B:%B\n\0"
