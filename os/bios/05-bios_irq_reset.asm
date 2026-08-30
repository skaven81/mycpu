# vim: syntax=asm-mycpu

# :bios_irq_reset - (re)establish the BIOS default interrupt subsystem:
#   * the eight IRQ vectors (IRQ0-7)
#   * the programmable timer, via :ptmr_init -- per-timer handlers reset to
#     the no-op, all three timers idle
#   * the DS1511Y watchdog timer, via :timer_set_idle
#
# Called once from the boot preamble and again at the top of every BIOS
# exec-loop iteration, so a program that installs its own IRQ vectors or
# ptmr handlers and then exits (or crashes) without restoring them cannot
# carry that state into the next program.
#
# Deliberately does NOT touch the keyboard/UART receive rings: those are
# flushed once at cold boot (see the boot preamble) but left alone between
# programs, so a user's type-ahead survives the brief gap while one program
# exits and the next starts.
#
# The caller MUST hold interrupts masked across this call -- the vectors are
# transiently inconsistent mid-routine, and this routine does not unmask. It
# calls only ordinary (heap-free) subroutines; it is not itself callable
# from an ISR.
:bios_irq_reset
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_irq_buf
ST16    %IRQ2addr%  :ptmr_isr_std
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_irq_dr_buf
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq
CALL :ptmr_init
CALL :timer_set_idle
RET

# Inert target for unused interrupts
.noirq

RETI


