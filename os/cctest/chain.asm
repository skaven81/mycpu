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

# Storage for cctest_enter/leave_root
VAR global 54 $cctest_saved_path
VAR global word $cctest_saved_cluster

# :cctest_enter_root - save CWD state and reset to filesystem root
#
# Saves both drive_0_fs_handle.path[54] and .current_dir_cluster to
# static storage, then resets both fields to root state (cluster=0,
# path="/").  Must be paired with :cctest_leave_root.
#
# drive_0_fs_handle layout (from fat16_util.h):
#   offset 0  (0x00): path[54]   (current directory path string)
#   offset 54 (0x36): current_dir_cluster (uint16_t, big-endian)
#
# Note: assembler $var+N offset syntax requires a decimal N, not hex.
# 0x36 = 54 decimal, 0x37 = 55 decimal.
#
# Called from C: extern void cctest_enter_root();
# No heap args or return value.
# Callee-save: preserves A, C, D.
:cctest_enter_root
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Save current_dir_cluster (2 bytes at drive_0_fs_handle+54/55)
LD_AH $drive_0_fs_handle+54
LD_AL $drive_0_fs_handle+55
ALUOP_ADDR %A%+%AH% $cctest_saved_cluster
ALUOP_ADDR %A%+%AL% $cctest_saved_cluster+1

# Save path[54] (at drive_0_fs_handle+0) into $cctest_saved_path
# 54 = 13*4 + 2; MEMCPY4_C_D auto-increments both C and D
LDI_C $drive_0_fs_handle
LDI_D $cctest_saved_path
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY_C_D
MEMCPY_C_D

# Reset current_dir_cluster to 0x0000
ST $drive_0_fs_handle+54 0x00
ST $drive_0_fs_handle+55 0x00

# Reset path to "/" (byte 0 = '/', byte 1 = null)
LDI_AL '/'
ALUOP_ADDR %A%+%AL% $drive_0_fs_handle
ST $drive_0_fs_handle+1 0x00

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
RET

# :cctest_leave_root - restore CWD state saved by :cctest_enter_root
#
# Restores drive_0_fs_handle.path[54] and .current_dir_cluster from
# the static storage filled by :cctest_enter_root.
#
# Called from C: extern void cctest_leave_root();
# No heap args or return value.
# Callee-save: preserves A, C, D.
:cctest_leave_root
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Restore current_dir_cluster
LD_AH $cctest_saved_cluster
LD_AL $cctest_saved_cluster+1
ALUOP_ADDR %A%+%AH% $drive_0_fs_handle+54
ALUOP_ADDR %A%+%AL% $drive_0_fs_handle+55

# Restore path[54] from $cctest_saved_path -> $drive_0_fs_handle+0
LDI_C $cctest_saved_path
LDI_D $drive_0_fs_handle
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY4_C_D
MEMCPY_C_D
MEMCPY_C_D

POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
POP_AH
RET
