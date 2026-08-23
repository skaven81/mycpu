# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_irq_buf
ST16    %IRQ2addr%  :ptmr_isr_std
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_irq_dr_buf
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Initialize the programmable timer. The :ptmr_isr has its
# own handler addresses that need to be set before we
# unmask interrupts.
CALL :ptmr_init

# Initialize the heap - this is needed for most commands to work (including :print)
CALL :heap_init

# Initialize terminal output/ANSI state. VAR globals are NOT zeroed at ODY
# load (they overlay whatever the previous program left there), so this
# explicit init is load-bearing -- a stray nonzero $ansi_state on first
# boot corrupts the very first :print call (found during Phase 1 hardware
# checkpointing, see terminal_ansi.asm).
ST $term_flags 0x00             # fast path: no raw/ANSI/edge-behavior bits
ST $term_render_color 0x00      # start out in reset mode (no color writes)
ST $term_current_color %white%  # ensure color byte has a sane starting value
CALL :ansi_reset

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

