# vim: syntax=asm-mycpu

# termdemo - visual demos + throughput benchmark for the new terminal I/O
# library (see /TERMINAL_REFACTOR.md, Task 7). Split out from termtest as
# its own ODY: TERMTEST.ODY plus SERRUN.ODY (which stays resident during
# the serial transfer) already used nearly all of the ~24KiB RAM region
# they must share, and adding the demos/benchmark code pushed the combined
# size over budget and crashed the machine. See memory note
# feedback_serrun_transfer_ram_budget for the full story -- this is a RAM
# ceiling on any serrun-transferred ODY, separate from the ROM's own
# 16KiB budget.
#
# On exit, chains back to /SYS/SERRUN.ODY (if present), same as termtest.

:main
CALL :argv_init                  # AL=argc, C=argv base; unused, but must
                                  # consume the BIOS's argc/argv per the ABI

# VAR globals are NOT guaranteed zero at load (see feedback_var_globals_not_zeroed) --
# force deterministic ANSI-parser state before anything touches it.
CALL :t_ansi_reset

CALL :demos_run

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
#
# COPY of os/util/termtest/00-main.asm's .chain_to_serrun, kept in sync by
# hand (no include/import directive) -- a fix to the IPC hand-off logic in
# one copy must be re-applied to the other.
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
