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

# Initialize the heap - this is needed for most commands to work (including :print)
CALL :heap_init

# Initialize color system, we start without processing color data
ST $term_color_enabled 0x00
ST $term_render_color 0x00      # once $term_color_enabled comes on, start out in reset mode
ST $term_current_color %white%  # ensure color byte has a sane starting value
ST $term_hexbyte_buf 0x00       # fill the hexbyte buf with NULLs
ST $term_hexbyte_buf+1 0x00
ST $term_hexbyte_buf+2 0x00
ST $term_hexbyte_buf+3 0x00
ST $term_hexbyte_buf+4 0x00

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

# Initialize malloc space 0x6000 .. 0xafff
LDI_A 0x6000
LDI_BL 159   # 160 segments = 20KiB
CALL :malloc_init
LDI_C .malloc_init_banner
LDI_A 0xb000-0x6000
CALL :heap_push_A
LDI_A 0xafff
CALL :heap_push_AL
CALL :heap_push_AH
LDI_A 0x6000
CALL :heap_push_AL
CALL :heap_push_AH
CALL :printf

# Test extended RAM
CALL :cursor_off
LDI_BH 0x00                             # BH = page number
.extram_loop
ALUOP_ADDR %B%+%BH% %d_page%            # set D page address
ALUOP_ADDR %B%+%BH% 0xd000
ALUOP_ADDR %B%+%BH% 0xdfff
ALUOP_ADDR %B%+%BH% %e_page%            # set E page address
LD_AL 0xe000                            # read E page address
ALUOP_FLAGS %A&B%+%AL%+%BH%             # check if read == write
JNE .extram_error
LD_AL 0xefff
ALUOP_FLAGS %A&B%+%AL%+%BH%             # check if read == write
JNE .extram_error

# move cursor back to beginning of line
LD_AH $crsr_row
LD_AL 0
CALL :cursor_goto_rowcol

# KB tested = (page address + 1) * 4
ALUOP_AL %B%+%BH%
LDI_AH 0x00
CALL :incr16_a
CALL :shift16_a_left
CALL :shift16_a_left

CALL :heap_push_A                       # push KB amount
LDI_C .memtest_str
CALL :printf                            # print the KB tested

ALUOP_BH %B+1%+%BH%                     # increment page
JNO .extram_loop
LDI_AL '\n'
CALL :putchar
CALL :cursor_on
JMP .kb_init

.extram_error
CALL :cursor_on
LDI_C .memtest_error_str
CALL :print
HLT

# Initialize keyboard
.kb_init
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

# Print the current CPU clock
CALL :sys_clock_speed
LDI_C .clockspeed_banner
CALL :heap_push_A
CALL :printf

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
.hello_banner "Odyssey OS v0.1\n\0"
.malloc_init_banner "Malloc range 0x%x%x-0x%x%x (%U bytes)\n\0"
.memtest_str "Extended memory %UK OK\0"
.memtest_error_str "\nFAILED extended memory test\n\0"
.kb_init_banner "Keyboard init \0"
.uart_init_banner "UART init 9600,8n1 \0"
.clockspeed_banner "Current CPU frequency %UkHz\n\0"
.clock_banner "Current clock %B%B-%B-%B %B:%B:%B\n\0" # YYYY-MM-DD HH:MM:SS

