# vim: syntax=asm-mycpu

# BIOS Exec Loop
#
# This file implements the main OS execution loop.  It replaces the old
# single-shot SYSTEM.ODY loader with a full exec loop that:
#
#   1. Reads and clears the IPC block
#   2. Validates the IPC dirent pointer (must be in malloc range 0x60xx-0xAFxx)
#   3. If valid: use that dirent/fsh to load and run the requested program
#   4. If invalid: find and run /SYSTEM.ODY (fallback)
#   5. After the program returns: clean up memory and repeat
#
# Programs communicate with the exec loop by writing to the $exec_* IPC
# block global variables before exiting.  The BIOS always pushes argc and
# argv to the heap before executing any ODY binary.
#
# See os/README-bios-exec.md for the full program interface specification.

###
# IPC block - written by programs just before they exit, read and cleared
# by the BIOS exec loop at the top of every iteration.
###
VAR global word $exec_dirent_ptr    # malloc'd dirent for next program; 0x0000 = no request
VAR global word $exec_fsh_ptr       # fs_handle ptr for next program
VAR global byte $exec_argc          # argc for next program
VAR global word $exec_argv_ptr      # malloc'd argv array; 0x0000 = no args

###
# Exec loop locals - written by BIOS before CALL_D, must survive across
# CALL_D since all registers are clobbered by the executed program.
###
VAR global word $exec_loop_program_ptr  # malloc'd program binary (freed after exec)
VAR global word $exec_loop_entry_ptr    # entry point address for CALL_D
VAR global byte $exec_loop_argc         # argc to push and count for argv free
VAR global word $exec_loop_argv_ptr     # argv array address (freed after exec)
VAR global byte $exec_loop_flags        # ODY flags byte for post-exec cleanup dispatch
VAR global word $exec_loop_fsh_ptr      # fsh_ptr saved across load phases
VAR global word $exec_loop_saved_fsh_ptr  # saved $current_fs_handle_ptr before fallback search

###
# :boot_system_ody
#
# Entry point called once from the boot sequence (00-main.asm).
# Initializes the IPC block and enters the exec loop.  Never returns.
###
:boot_system_ody
# Initialize IPC block to known-zero state
ST $exec_dirent_ptr   0x00
ST $exec_dirent_ptr+1 0x00
ST $exec_fsh_ptr   0x00
ST $exec_fsh_ptr+1 0x00
ST $exec_argc 0x00
ST $exec_argv_ptr   0x00
ST $exec_argv_ptr+1 0x00

###
# Main exec loop - jump target for every loop iteration
###
:exec_loop_top
# Reset the heap to a clean slate before anything else this iteration
CALL :heap_init

# Read and clear the IPC dirent pointer
LD_AH $exec_dirent_ptr
LD_AL $exec_dirent_ptr+1
ST $exec_dirent_ptr   0x00
ST $exec_dirent_ptr+1 0x00

# Validate the IPC dirent pointer: valid malloc range is 0x6000-0xBEFF,
# meaning AH must be in 0x60..0xBE.
# Check 1: AH < 0x60 -> fallback (O=1 means underflow = AH too small)
LDI_BH 0x60
ALUOP_FLAGS %A-B%+%AH%+%BH%
JO .exec_loop_fallback
# Check 2: AH > 0xBE -> fallback (O=1 means underflow = 0xBE - AH < 0)
LDI_BH 0xBE
ALUOP_FLAGS %B-A%+%BH%+%AH%
JO .exec_loop_fallback

# IPC dirent pointer is valid.  Load remaining IPC fields.
# Save dirent ptr (currently in A) to D for use during load
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # D = dirent_ptr

# Load, clear, and save IPC fsh_ptr -> C
LD_AH $exec_fsh_ptr
LD_AL $exec_fsh_ptr+1
ST $exec_fsh_ptr   0x00
ST $exec_fsh_ptr+1 0x00
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = fsh_ptr

# Load, clear, and save IPC argc -> BH, then to local
LD_BH $exec_argc
ST $exec_argc 0x00
ALUOP_ADDR %B%+%BH% $exec_loop_argc

# Load, clear, and save IPC argv_ptr -> exec_loop local
LD_AH $exec_argv_ptr
LD_AL $exec_argv_ptr+1
ST $exec_argv_ptr   0x00
ST $exec_argv_ptr+1 0x00
ALUOP_ADDR %A%+%AH% $exec_loop_argv_ptr
ALUOP_ADDR %A%+%AL% $exec_loop_argv_ptr+1

# D = dirent_ptr, C = fsh_ptr; proceed to load
JMP .exec_load_binary

###
# Fallback: IPC dirent pointer is invalid.  Find and run /SYSTEM.ODY.
###
.exec_loop_fallback

# Save $current_fs_handle_ptr so we can restore the user's drive selection
# after the fallback search overwrites it.  0x0000 means "not yet set" (cold boot).
LD_AH $current_fs_handle_ptr
LD_AL $current_fs_handle_ptr+1
ALUOP_ADDR %A%+%AH% $exec_loop_saved_fsh_ptr
ALUOP_ADDR %A%+%AL% $exec_loop_saved_fsh_ptr+1

# No argv for SYSTEM.ODY fallback
ST $exec_loop_argc 0x00
ST $exec_loop_argv_ptr   0x00
ST $exec_loop_argv_ptr+1 0x00

# If $boot_fs_handle_ptr is nonzero we already know which drive to use
LD_AH $boot_fs_handle_ptr
LD_AL $boot_fs_handle_ptr+1
ALUOP_FLAGS %A%+%AH%
JNZ .exec_search_known_drive    # AH != 0x00 -> boot drive is known

# First boot: search drive 0
.exec_search_drive_0

LDI_C $drive_0_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
LDI_C .sys_ody_path
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # A = dirent ptr, or 0x00xx/0x01xx on error

# Check for error: E flag set if AH == 0x01 (ATA error)
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .exec_search_drive_1
# Check for not found: Z flag set if AH == 0x00
ALUOP_FLAGS %A%+%AH%
JZ .exec_search_drive_1

# Found on drive 0; pop fs_handle ptr
CALL :heap_pop_C                # C = fsh_ptr
# Record the boot drive for subsequent iterations
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1
JMP .exec_fallback_found

# Drive 0 failed; try drive 1
.exec_search_drive_1

LDI_C $drive_1_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
LDI_C .sys_ody_path
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # A = dirent ptr, or 0x00xx/0x01xx on error

LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .exec_sys_not_found
ALUOP_FLAGS %A%+%AH%
JZ .exec_sys_not_found

# Found on drive 1; pop fs_handle ptr
CALL :heap_pop_C                # C = fsh_ptr
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1
JMP .exec_fallback_found

# Boot drive is already known; search it directly
.exec_search_known_drive

LD_AH $boot_fs_handle_ptr
LD_AL $boot_fs_handle_ptr+1
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
LDI_C .sys_ody_path
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # A = dirent ptr, or 0x00xx/0x01xx on error

LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .exec_sys_not_found
ALUOP_FLAGS %A%+%AH%
JZ .exec_sys_not_found

CALL :heap_pop_C                # C = fsh_ptr
JMP .exec_fallback_found

# Fallback pathfind succeeded; A = dirent ptr, C = fsh_ptr
.exec_fallback_found
# Save dirent ptr to D for use during load
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # D = dirent_ptr
# Ensure current fs handle matches the drive we found the file on
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
# Restore user's drive selection if one was set before the fallback search.
# Valid fs_handle addresses are 0xC8xx-0xCAxx (global arrays region), so a
# saved high byte of 0x00 means the pointer was uninitialized (cold boot).
LD_AH $exec_loop_saved_fsh_ptr
LD_AL $exec_loop_saved_fsh_ptr+1
ALUOP_FLAGS %A%+%AH%
JZ .exec_keep_boot_drive        # high byte 0x00 = cold boot, keep boot drive
ALUOP_ADDR %A%+%AH% $current_fs_handle_ptr
ALUOP_ADDR %A%+%AL% $current_fs_handle_ptr+1
.exec_keep_boot_drive

# Fall through to load path: D = dirent_ptr, C = fsh_ptr

###
# Common load path: two-step load with extended memory support.
# Inputs: D = dirent_ptr (malloc'd), C = fsh_ptr
# exec_loop_argc and exec_loop_argv_ptr must already be set.
#
# Step 1: Save fsh_ptr and load first sector into temp buffer
# Step 2: Inspect ODY signature, get flags byte
# Step 3: Free temp buffer, allocate memory based on flags
# Step 4: Load full file, localize, execute
###
.exec_load_binary

# Save fsh_ptr to global (C gets overwritten by temp buffer allocation)
ST_CH $exec_loop_fsh_ptr
ST_CL $exec_loop_fsh_ptr+1

# Allocate temp buffer (4 segments = 512 bytes) for first sector
LDI_AL 4
CALL :malloc_segments           # A = temp buffer address
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = temp buffer address

# Read first sector into temp buffer
# fat16_readfile params: fsh, target, n_sectors, dirent, state
LD_AH $exec_loop_fsh_ptr
LD_AL $exec_loop_fsh_ptr+1
CALL :heap_push_A               # filesystem handle
CALL :heap_push_C               # target memory address (temp buffer)
LDI_A 0x0001
CALL :heap_push_A               # n_sectors = 1
CALL :heap_push_D               # directory entry
LDI_A 0x0000
CALL :heap_push_A               # state = NULL
CALL :fat16_readfile
CALL :heap_pop_AL               # status: 0x00 = success
ALUOP_FLAGS %A%+%AL%
JNZ .exec_ata_error

# Inspect ODY signature and get flags byte
# C still = temp buffer address (callee-save)
CALL :heap_push_C
CALL :fat16_inspect_ody
CALL :heap_pop_AL               # flags byte; 0xFF = not valid ODY
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%    # E=1 if AL == 0xFF
JEQ .exec_not_ody

# Free temp buffer; save flags on hardware stack first
# C still = temp buffer address (callee-save)
ALUOP_PUSH %A%+%AL%             # save flags byte
MOV_CH_AH
MOV_CL_AL
CALL :free                      # free temp buffer (address in A)
POP_AL                          # restore flags byte

# Mask to lower 2 bits and save for post-exec cleanup dispatch
LDI_BL 0x03
ALUOP_AL %A&B%+%AL%+%BL%        # AL = flags & 0x03
ALUOP_ADDR %A%+%AL% $exec_loop_flags

# Dispatch on memory allocation type
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if AL == 0x03
JEQ .exec_alloc_de
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if AL == 0x02
JEQ .exec_alloc_e
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if AL == 0x01
JEQ .exec_alloc_d
# Default: 0x00 = main RAM
JMP .exec_alloc_main

###
# Memory allocation paths
# D = dirent_ptr (preserved from entry, callee-save through all calls above)
###

# Extended memory: D-page + E-page windows, target = 0xD000
.exec_alloc_de
CALL :extmalloc
CALL :extpage_d_push
CALL :extmalloc
CALL :extpage_e_push
LDI_C 0xd000
ST $exec_loop_program_ptr 0x00
ST $exec_loop_program_ptr+1 0x00
JMP .exec_load_full

# Extended memory: E-page window, target = 0xE000
.exec_alloc_e
CALL :extmalloc
CALL :extpage_e_push
LDI_C 0xe000
ST $exec_loop_program_ptr 0x00
ST $exec_loop_program_ptr+1 0x00
JMP .exec_load_full

# Extended memory: D-page window, target = 0xD000
.exec_alloc_d
CALL :extmalloc
CALL :extpage_d_push
LDI_C 0xd000
ST $exec_loop_program_ptr 0x00
ST $exec_loop_program_ptr+1 0x00
JMP .exec_load_full

# Main RAM allocation: compute file size, malloc, target = allocated address
.exec_alloc_main
# Get file size low word from dirent at offset 0x1E (big-endian word)
MOV_DH_AH
MOV_DL_AL                       # A = dirent_ptr (D is not modified)
LDI_B 0x001e
ALUOP16O_A %ALU16_A+B%          # A = dirent_ptr + 0x1E
LDA_A_BH                        # BH = filesize high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = filesize low byte
ALUOP_AH %B%+%BH%
ALUOP_AL %B%+%BL%               # A = low word of file size

# Round up to nearest 512 bytes then divide by 128 to get segment count.
# Technique: shift AH right, add 1, shift left (rounds AH up to even), zero AL,
# then shift entire 16-bit value right 7 times (divide by 128).
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
CALL :shift16_a_right           # /2
CALL :shift16_a_right           # /4
CALL :shift16_a_right           # /8
CALL :shift16_a_right           # /16
CALL :shift16_a_right           # /32
CALL :shift16_a_right           # /64
CALL :shift16_a_right           # /128 -> AL = segment count

CALL :malloc_segments           # A = program buffer address
ALUOP_ADDR %A%+%AH% $exec_loop_program_ptr
ALUOP_ADDR %A%+%AL% $exec_loop_program_ptr+1
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = target address
# Fall through to .exec_load_full

###
# Load the full ODY binary, localize, and execute.
# Inputs: C = target memory address, D = dirent_ptr (still preserved)
# $exec_loop_fsh_ptr = filesystem handle
# $exec_loop_program_ptr = program address (or 0x0000 for ext memory)
# $exec_loop_flags = ODY flags byte for cleanup dispatch
# $exec_loop_argc and $exec_loop_argv_ptr = arguments for the program
###
.exec_load_full
# Read the entire binary into the allocated buffer
LD_AH $exec_loop_fsh_ptr
LD_AL $exec_loop_fsh_ptr+1
CALL :heap_push_A               # filesystem handle
CALL :heap_push_C               # target memory address
LDI_A 0x0000
CALL :heap_push_A               # n_sectors = 0 (full file)
CALL :heap_push_D               # directory entry
CALL :heap_push_A               # state = NULL (A still 0x0000)
CALL :fat16_readfile
CALL :heap_pop_AL               # status: 0x00 = success
ALUOP_FLAGS %A%+%AL%
JNZ .exec_ata_error

# Localize the ODY binary
# C still = target address (callee-save)
CALL :heap_push_C
CALL :fat16_localize_ody
CALL :heap_pop_A                # A = entry point address

# Save entry point to exec loop local (survives across CALL_D)
ALUOP_ADDR %A%+%AH% $exec_loop_entry_ptr
ALUOP_ADDR %A%+%AL% $exec_loop_entry_ptr+1

# Free the dirent; no longer needed after file is loaded
# D still = dirent_ptr (callee-save)
MOV_DH_AH
MOV_DL_AL
CALL :free                      # free dirent (address in A)

###
# Execute the program
###

# Push argv and argc to heap for the program.
# Push argv first (word), then argc (word) so argc is on top (popped first).
LD_AH $exec_loop_argv_ptr
LD_AL $exec_loop_argv_ptr+1
CALL :heap_push_A               # push argv pointer (word)
LDI_AH 0x00
LD_AL $exec_loop_argc
CALL :heap_push_A               # push argc as 16-bit zero-extended word

# Load entry point into D and execute via CALL_D
LD_AH $exec_loop_entry_ptr
LD_AL $exec_loop_entry_ptr+1
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%
CALL_D

###
# Post-execution cleanup
###

# Pop return code pushed by the program before it returned (required by ABI)
CALL :heap_pop_A                # A = return code (currently ignored)

# Check heap resilience: $heap_ptr high byte must be >= 0xF0 (heap region starts at 0xF000)
LD_AH $heap_ptr
LDI_BH 0xF0
ALUOP_FLAGS %A-B%+%AH%+%BH%    # AH - 0xF0; O=1 if AH < 0xF0 (underflow)
JNO .exec_heap_ok

# Heap underflow: warn and reinitialize
LDI_C .exec_heap_warn_str
CALL :print
CALL :heap_init

.exec_heap_ok
# Dispatch cleanup based on ODY flags
LD_AL $exec_loop_flags
LDI_BL 0x03
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if flags == 0x03
JEQ .exec_cleanup_de
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if flags == 0x02
JEQ .exec_cleanup_e
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%     # E=1 if flags == 0x01
JEQ .exec_cleanup_d
# Default: 0x00 = main RAM; free the program buffer
LD_AH $exec_loop_program_ptr
LD_AL $exec_loop_program_ptr+1
CALL :free
JMP .exec_cleanup_argv

.exec_cleanup_de
CALL :extpage_e_pop
CALL :extfree
CALL :extpage_d_pop
CALL :extfree
JMP .exec_cleanup_argv

.exec_cleanup_e
CALL :extpage_e_pop
CALL :extfree
JMP .exec_cleanup_argv

.exec_cleanup_d
CALL :extpage_d_pop
CALL :extfree
# Fall through to .exec_cleanup_argv

.exec_cleanup_argv
# Free argv strings and array if argc > 0 and argv pointer is non-NULL
LD_AL $exec_loop_argc
ALUOP_FLAGS %A%+%AL%
JZ .exec_loop_next              # argc == 0: nothing to free

LD_AH $exec_loop_argv_ptr
LD_AL $exec_loop_argv_ptr+1
ALUOP_FLAGS %A%+%AH%
JZ .exec_loop_next              # argv ptr high byte == 0: NULL, skip

# Set up argv free loop: C = argv array base, BH = remaining string count
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv array base address
LD_BH $exec_loop_argc           # BH = argc (number of argv[i] strings to free)

.exec_free_argv_string_loop
ALUOP_FLAGS %B%+%BH%            # Z=1 if BH == 0 (no more strings)
JZ .exec_free_argv_array

# Load argv[i] pointer (big-endian word) from [C], then advance C
LDA_C_AH                        # AH = high byte of argv[i] pointer
INCR_C
LDA_C_AL                        # AL = low byte of argv[i] pointer
INCR_C                          # C now points to argv[i+1]
CALL :free                      # free the argv[i] string (address in A)

ALUOP_BH %B-1%+%BH%             # decrement remaining count
JMP .exec_free_argv_string_loop

.exec_free_argv_array
# Free the argv pointer array itself
LD_AH $exec_loop_argv_ptr
LD_AL $exec_loop_argv_ptr+1
CALL :free

.exec_loop_next
# Start the next iteration
JMP :exec_loop_top

###
# Error handlers - all are fatal (halt)
###

.exec_ata_error
CALL :heap_push_AL
LDI_C .exec_ata_err_str
CALL :printf
HLT

.exec_not_ody
LDI_C .exec_not_ody_str
CALL :print
HLT

.exec_sys_not_found
LDI_C .exec_sys_not_found_str
CALL :print
HLT

###
# String literals
###
.sys_ody_path "/SYSTEM.ODY\0"
.exec_ata_err_str "ATA error loading binary: 0x%x\n\0"
.exec_not_ody_str "Error: not a valid ODY executable\n\0"
.exec_sys_not_found_str "SYSTEM.ODY not found. System halted.\n\0"
.exec_heap_warn_str "WARNING: heap underflow after program exit, reinitializing\n\0"
