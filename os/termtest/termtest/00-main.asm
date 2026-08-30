# vim: syntax=asm-mycpu

# termtest - ROM regression suite for the BIOS terminal subsystem. Runs a
# battery of self-checking test suites against the ROM's own
# :print/:putchar/:cursor_*/:ansi_*/:readline directly, and reports
# PASS/FAIL/RESULT lines over the UART.
#
# 256-color / truecolor SGR is deliberately not implemented (the SGR suite
# locks in its silent-discard behavior; ESC[<v>p is the native replacement,
# covered in the ansi suite). Readline has no insert-vs-overwrite mode
# (:readline always inserts) and no history, so neither is tested. See each
# affected suite file's header for details.
#
# On exit: clears the screen, prints a one-line grand-total summary of the
# pass count to the display, and returns to the shell normally. It does not
# chain into another program.

:main
CALL :argv_init                  # AL=argc, C=argv base; unused, but must
                                  # consume the BIOS's argc/argv per the ABI

# VAR globals are NOT guaranteed zero at load: this ODY's VAR pool overlays
# whatever the previously-run program (the shell, serrun, or a prior
# termtest run) left behind. Force deterministic state before anything
# touches the ANSI parser -- otherwise the first :print can see a stray
# nonzero $ansi_state and flush garbage from an uninitialized seq buffer.
CALL :ansi_reset

# --- smoke test: prove the harness itself works end to end ---
LDI_C .suite_smoke_name
CALL :tt_suite

LDI_C .smoke_test_name
CALL :tt_pass

CALL :tt_result

# --- ROM terminal subsystem test suites ---
CALL :tests_cursor_run
CALL :tests_output_run
CALL :tests_ansi_run
CALL :tests_sgr_run
CALL :tests_readline_run

# --- clear the screen and print the cross-suite grand total ---
LDI_AH 0x00                      # fill char
LDI_AL 0x3f                      # white-on-black
CALL :clear_screen
LDI_AH 0x00                      # row 0
LDI_AL 0x00                      # col 0
CALL :cursor_goto_rowcol

LDI_C .complete_prefix
CALL :print
CALL :tt_grand_result            # writes "<pass>/<total>" to the display
LDI_C .complete_suffix
CALL :print

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.suite_smoke_name "smoke\0"
.smoke_test_name "harness_alive\0"
.complete_prefix "termtest complete: \0"
.complete_suffix " tests passed\n\0"
