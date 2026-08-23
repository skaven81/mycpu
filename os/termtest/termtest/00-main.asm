# vim: syntax=asm-mycpu

# termtest - ROM regression suite for the BIOS terminal subsystem (see
# /TERMINAL_REFACTOR.md). Runs a battery of self-checking test suites
# against the ROM's own :print/:putchar/:cursor_*/:ansi_*/:readline
# directly, and reports PASS/FAIL/RESULT lines over the UART.
#
# Some suites below cover functionality that was cut during the Phase 2
# ROM-budget gate (256-color SGR, ANSI save/restore, readline insert vs
# overwrite mode); the readline history suite tested nothing but cut
# functionality and was dropped entirely. See each affected suite file's
# header for what changed and why.
#
# On exit, chains back to /SYS/SERRUN.ODY (if present) so a PC-side driver
# can push the next build without a human re-typing "serrun" each time.

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

# --- hand control back to serrun for the next iteration, if present ---
CALL .chain_to_serrun

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

######
# Looks up /SYS/SERRUN.ODY and, if found, sets the BIOS IPC block so the
# exec loop launches it next instead of falling back to SYSTEM.ODY. Always
# returns normally either way -- the caller's own exit path is unaffected.
.chain_to_serrun
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

LDI_C .serrun_path
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                 # A = dirent ptr, or an error code
ALUOP_FLAGS %A%+%AH%
JZ .chain_done                   # not found / syntax error -- give up
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .chain_done                  # ATA error -- give up

CALL :heap_pop_C                 # C = fsh_ptr (still on heap from pathfind)
ALUOP_ADDR %A%+%AH% $exec_dirent_ptr
ALUOP_ADDR %A%+%AL% $exec_dirent_ptr+1
ST_CH $exec_fsh_ptr
ST_CL $exec_fsh_ptr+1

.chain_done
POP_AL
POP_AH
POP_CL
POP_CH
RET

.serrun_path "/SYS/SERRUN.ODY\0"
.suite_smoke_name "smoke\0"
.smoke_test_name "harness_alive\0"
