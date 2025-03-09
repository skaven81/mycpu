# vim: syntax=asm-mycpu

:boot_system_ody
# Set 0 as current drive
LDI_C $drive_0_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1

# Check for SYSTEM.ODY on that drive
LDI_C .os_bin_filename
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # pointer to dirent if success, or 0x00.. or 0x01.. if error
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .try_drive_1
ALUOP_FLAGS %A%+%AH%
JZ .try_drive_1
JMP .found_system_ody

.try_drive_1
# Set 1 as current drive
LDI_C $drive_1_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1

# Check for SYSTEM.ODY on that drive
LDI_C .os_bin_filename
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # pointer to dirent if success, or 0x00.. or 0x01.. if error
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .seekos_failed_notfound
ALUOP_FLAGS %A%+%AH%
JZ .seekos_failed_notfound
JMP .found_system_ody

# Binary is found, A contains the address of a copy of the directory entry
# (which needs to be freed), and the heap has the filesystem handle where it
# was found (which should match $current_fs_handle_ptr and $boot_fs_handle_ptr)
.found_system_ody
CALL :heap_pop_word             # discard the filesystem handle

CALL :heap_push_AL              # print boot status
CALL :heap_push_AH
LDI_C .mount_seekos_2
CALL :printf

###
# Allocate a proper memory segment for the binary
###

# Round the file size up to the nearest 512 bytes
ALUOP_DH %A%+%AH%               # copy dirent to D for safekeeping
ALUOP_DL %A%+%AL%
CALL :heap_push_D               # directory entry
CALL :fat16_dirent_filesize
CALL :heap_pop_A                # low word of file size
CALL :heap_pop_word             # high word of file size (ignored)

CALL :heap_push_AL              # push filesize for printf later
CALL :heap_push_AH

# Our goal is to take the 16-bit filesize and convert it to a malloc
# number that is rounded up to the nearest 512 bytes.
#
# Rounding to the nearest 512 bytes means clearing the lowest 9 bits (which
# rounds _down_ to the nearest 512 bytes), so we then need to add 0x0200 to the
# result to round up. Observe that this means we completely ignore the bottom 8
# bits.  So the "add" step is really to just add 0x02 to the high byte, and set
# the low byte to zero.  We can simplify the addition so that we only need to
# add 0x01 to the high byte, by shifting it right first, then adding 1, then
# shifting left.
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
# Shift right four positions (divide by 16) to get the number of blocks we need to malloc
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
# But this is the actual number of blocks; malloc expects that number, minus one.
ALUOP_AL %A-1%+%AL%
CALL :heap_push_AL              # push block count for printf later
CALL :malloc
CALL :heap_push_AL              # push malloc address for printf
CALL :heap_push_AH
LDI_C .ody_malloc
CALL :printf
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # copy address to C

# Load the ODY into RAM
LD_BH $boot_fs_handle_ptr
LD_BL $boot_fs_handle_ptr+1
CALL :heap_push_B               # filesystem handle
CALL :heap_push_C               # target memory address
LDI_AL 0                        # load all sectors
CALL :heap_push_AL
CALL :heap_push_D               # directory entry
CALL :fat16_readfile
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JZ .localize_ody                # success, proceed to localize the file
CALL :heap_push_AL              # error, print ATA error
LDI_C .mount_seekos_5
CALL :printf
JMP .boot_halt

.localize_ody
# Free the directory handle, we no longer need it
MOV_DH_AH
MOV_DL_AL
LDI_B 1                         # 32 bytes to free
CALL :free

# Localize the ODY memory addresses
CALL :heap_push_C               # address of binary
CALL :fat16_localize_ody
CALL :heap_pop_D                # first byte of program
CALL_D                          # execute the program - this should never return

# Error! We should not have exited the shell
.boot_halt
CALL :heap_push_AL
LDI_C .boot_halt_str
CALL :printf
HLT

# Failure condition when seeking the OS binary
.seekos_failed_notfound
LDI_C .sys_not_found
CALL :print
HLT

.mount_seekos_2 "Found: directory entry at 0x%x%x, executing..\n\0"
.mount_seekos_5 "ATA error loading system binary: 0x%x\n\0"
.os_bin_filename "/SYSTEM.ODY\0"
.sys_not_found "SYSTEM.ODY not found. System halted.\n\0"
.boot_halt_str "System process exited. Status byte 0x%x\nSystem halted.\n\0"
.ody_malloc "SYSTEM.ODY loaded at 0x%x%x size %u from filesize 0x%x%x\n\0"
