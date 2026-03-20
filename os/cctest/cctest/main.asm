# vim: syntax=asm-mycpu
# CCTEST - C compiler test suite launcher
# Finds /CCTEST/CCTEST1.ODY and sets the BIOS IPC block to run it.
# After cctest1 returns, it chains to cctest2, ..., cctest9 -> SYSTEM.ODY.
#
# Usage: cd /CCTEST, then run cctest
# Inputs: argc (word) and argv (word) on heap (pushed by BIOS - discarded)
# Output: heap return code (0x0000 success, 0x0001 if CCTEST1.ODY not found)
# Side effects: sets $exec_dirent_ptr and $exec_fsh_ptr to run CCTEST1.ODY

:main
# Discard argc and argv pushed by BIOS (required by ABI even if unused)
CALL :heap_pop_A           # discard argc
CALL :heap_pop_A           # discard argv

# Find /CCTEST/CCTEST1.ODY
LDI_C .cctest1_path
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A           # A = dirent ptr (or error)

ALUOP_FLAGS %A%+%AH%
JZ .not_found              # AH == 0x00: not found
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .not_found             # AH == 0x01: ATA error

# Success: store dirent ptr from A, pop fsh_ptr into C, store fsh_ptr
# C cannot be used in ALUOP; use ST_CH/ST_CL to store C to memory variables
CALL :heap_pop_C           # C = fsh_ptr
ALUOP_ADDR %A%+%AH% $exec_dirent_ptr
ALUOP_ADDR %A%+%AL% $exec_dirent_ptr+1
ST_CH $exec_fsh_ptr
ST_CL $exec_fsh_ptr+1

LDI_C .launching_msg
CALL :print
LDI_A 0x0000
CALL :heap_push_A
RET

.not_found
LDI_C .not_found_msg
CALL :print
LDI_A 0x0001
CALL :heap_push_A
RET

.cctest1_path "/CCTEST/CCTEST1.ODY\0"
.launching_msg "Launching cctest suite...\n\0"
.not_found_msg "ERROR: /CCTEST/CCTEST1.ODY not found\n\0"
