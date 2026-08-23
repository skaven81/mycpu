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

# History disabled by default (same VAR-not-zeroed hazard as above -- a
# stray nonzero $rl_history_buf would make the very first :readline call
# anywhere treat garbage RAM as a history ring). SYSTEM.ODY's shell is the
# only consumer that ever sets this nonzero, and only around its own
# command-line :readline call (see read_command.asm). The backing storage
# itself is reserved further below, once malloc/extmalloc are up.
ST $rl_history_buf 0x00
ST $rl_history_buf+1 0x00

# Clear the screen
LDI_AH  0x00
LDI_AL  %white%
CALL :clear_screen

# Initialize the cursor, but keep it OFF through the whole non-interactive
# boot sequence (cursor_init defaults it on) -- boot mixes :print/:printf
# calls with bare :putchar('\n') calls throughout, and :print only clears
# its OWN previous mark, not one stranded by an intervening bare putchar
# (see :print's header). With the cursor off, every one of those sync
# calls is a no-op, so nothing accumulates. :readline's poll loop turns
# it back on the moment the shell's first prompt actually starts reading
# input -- no explicit "turn it on" step is needed here.
CALL :cursor_init
ST $crsr_on 0x00

# Print our OS intro banner and newline
LDI_C .hello_banner
CALL :print

# Print blank line
LDI_AL '\n'
CALL :putchar

# Initialize malloc space 0x6000 .. 0xafff
CALL :boot_malloc_init

# Reserve one whole extended-memory page (32 entries x 128 bytes = 4096
# bytes, all of it) as the permanent backing store for SYSTEM.ODY's
# command history ring. This has to live here, at boot, and NOT in the
# shell -- SYSTEM.ODY is a fresh ODY load on every re-entry (every time
# an external program exits back to the shell), so anything the shell
# itself allocates or initializes is gone/reset on the very next prompt.
# An extended-memory page reservation is BIOS-resident state instead
# (:extmalloc's ledger lives in a VAR, untouched by the ODY loader), so
# it's the one thing that actually survives across shell re-entries.
# $rl_history_page names the page; $rl_history_buf (left at 0 above)
# is still the enable/disable switch the shell flips per-call -- see
# terminal_input.asm's history header and read_command.asm.
#
# $rl_history_page==0 below means :extmalloc found extended memory
# already full (astronomically unlikely this early in boot, but page 0
# doubles as scratch space other BIOS internals use, per extmalloc.asm's
# header -- so capacity/entry_sz are left at 0 rather than risk pointing
# a live history ring at it). read_command.asm checks $rl_history_page
# before ever setting $rl_history_buf nonzero, so a 0 here just means
# history silently never turns on, not a corrupted zero page.
CALL :extmalloc                 # page number pushed to heap (0 = ext mem full)
CALL :heap_pop_AL
ALUOP_ADDR %A%+%AL% $rl_history_page
ALUOP_FLAGS %A%+%AL%
JZ .no_history_page
ST $rl_history_capacity 32
ST $rl_history_entry_sz 128
.no_history_page
ST $rl_history_count 0
ST $rl_history_write_idx 0

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

