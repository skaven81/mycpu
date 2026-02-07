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
ST $term_print_raw 0x00         # interpret control chars as cursor movement
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
CALL :boot_malloc_init

# Set up the timer in a known state
CALL :timer_set_idle

# Test extended RAM
CALL :boot_extram_test

# ATA init
CALL :boot_ata_init

# KB init
CALL :boot_kb_init

# UART init
CALL :boot_uart_init

# Print system status
CALL :boot_print_status

# Mount drives
CALL :boot_mount_drives

# OS Loader sequence
CALL :boot_system_ody

# Inert target for unused interrupts
.noirq
RETI

.hello_banner "Odyssey OS v1.0\n\n\0"

