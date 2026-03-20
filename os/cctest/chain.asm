# vim: syntax=asm-mycpu
# :exec_chain - set BIOS IPC block to chain execution to another ODY file
#
# Called from C: extern void exec_chain(char *path);
# C caller pushes path pointer (word) to heap before CALL.
# Side effect: sets $exec_dirent_ptr and $exec_fsh_ptr if pathfind succeeds.
# If pathfind fails, IPC block is unchanged (BIOS falls back to SYSTEM.ODY).
# Callee-save: preserves all registers (A, C used internally).

:exec_chain
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Pop path pointer from heap (pushed by C caller)
CALL :heap_pop_C           # C = path string pointer

# Call fat16_pathfind: push path, call, pop result
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A           # A = dirent ptr (or error: AH==0x00 or AH==0x01)

# On error, pathfind pushed only 1 item (already popped). Jump without 2nd pop.
ALUOP_FLAGS %A%+%AH%
JZ .exec_chain_done        # AH == 0x00: not found
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .exec_chain_done       # AH == 0x01: ATA error

# Success: store dirent ptr from A, pop fsh_ptr into C, store fsh_ptr
# C register cannot appear in ALUOP instructions; use ST_CH/ST_CL to store C to memory
CALL :heap_pop_C           # C = fsh_ptr
ALUOP_ADDR %A%+%AH% $exec_dirent_ptr
ALUOP_ADDR %A%+%AL% $exec_dirent_ptr+1
ST_CH $exec_fsh_ptr
ST_CL $exec_fsh_ptr+1
# exec_argc and exec_argv_ptr remain 0x00/0x0000 (no args)

.exec_chain_done
POP_CL
POP_CH
POP_AL
POP_AH
RET
