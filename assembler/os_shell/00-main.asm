# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_clear_dr
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00
LDI_AL  %white%
CALL :clear_screen

# Initialize the cursor so we can start printing to the screen
CALL :cursor_init
CALL :cursor_display_sync

# Print our OS intro banner and newline
LDI_C .hello_banner
CALL :print

# Print blank line
LDI_AL '\n'
CALL :putchar

# Initialize heap
LDI_C .heap_init_banner
CALL :print
CALL :heap_init
LDI_C .ok
CALL :print

# Initialize keyboard
LDI_C .kb_init_banner
CALL :print
CALL :keyboard_init
LDI_C .ok
CALL :print

# Initialize UART
LDI_C .uart_init_banner
CALL :print
CALL :uart_init_9600_8n1
# Unmask interrupts and flush any ready data
UMASKINT
# Pause 0.5s for serial to flush
LDI_AH 0x00 # bcd seconds
LDI_AL 0x50 # bcd subseconds
CALL :sleep
MASKINT
LDI_C .ok
CALL :print

# Print the current date and time
LDI_C .clock_banner
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

# Print blank line
LDI_AL '\n'
CALL :putchar

#######
# Main loop
#######
.main
CALL :shell_command
JMP .main

# Inert target for unused interrupts
.noirq
RETI

.ok "OK\n\0"
.hello_banner "PKCPU OS v0.1\n\0"
.heap_init_banner "Heap init \0"
.kb_init_banner "Keyboard init \0"
.uart_init_banner "UART init 9600,8n1 \0"
.clock_banner "Current clock %B%B-%B-%B %B:%B:%B\n\0" # YYYY-MM-DD HH:MM:SS