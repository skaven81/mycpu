# vim: syntax=asm-mycpu

# termtest - userspace proving ground for the new terminal I/O library
# (see /TERMINAL_REFACTOR.md). Runs a battery of self-checking test suites
# and reports PASS/FAIL/RESULT lines over the UART; never uses the ROM's
# own :print/:putchar so the framebuffer stays available to the library
# under test.
#
# On exit, chains back to /SYS/SERRUN.ODY (if present) so a PC-side driver
# can push the next build without a human re-typing "serrun" each time.

:main
CALL :argv_init                  # AL=argc, C=argv base; unused, but must
                                  # consume the BIOS's argc/argv per the ABI

# --- smoke test: prove the harness itself works end to end ---
LDI_C .suite_smoke_name
CALL :tt_suite

LDI_C .smoke_test_name
CALL :tt_pass

CALL :tt_result

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
