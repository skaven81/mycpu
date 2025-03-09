# vim: syntax=asm-mycpu

:boot_mount_drives
# Allocate memory for drive 0 and 1 filesystem handles.
# These are pointers, they contain a memory address, not
# the filesystem handles themselves.
VAR global 128 $drive_0_fs_handle
LDI_C $drive_0_fs_handle
LDI_AH 0x00     # byte to fill
LDI_AL 127      # bytes to fill, minus one
CALL :memfill
LDI_A $drive_0_fs_handle
CALL :heap_push_AL
CALL :heap_push_AH
LDI_AL '0'
CALL :heap_push_AL
LDI_C .mount_filehandle
CALL :printf

VAR global 128 $drive_1_fs_handle
LDI_C $drive_1_fs_handle
LDI_AH 0x00     # byte to fill
LDI_AL 127      # bytes to fill, minus one
CALL :memfill
LDI_A $drive_1_fs_handle
CALL :heap_push_AL
CALL :heap_push_AH
LDI_AL '1'
CALL :heap_push_AL
LDI_C .mount_filehandle
CALL :printf

# Global var for storing our current active drive, a pointer
# to either $drive_0_fs_handle or $drive_1_fs_handle.
# Will be null if no drive is selected
VAR global word $current_fs_handle_ptr
ST $current_fs_handle_ptr   0x00
ST $current_fs_handle_ptr+1 0x00

# Global var for storing the filesystem handle that we booted from
VAR global word $boot_fs_handle_ptr
ST $boot_fs_handle_ptr   0x00
ST $boot_fs_handle_ptr+1 0x00

# Global vars used by shell so commands can parse command line args
VAR global word $user_input_buf
VAR global 32 $user_input_tokens # store up to 16 tokens

# Print blank line
LDI_AL '\n'
CALL :putchar

# Attempt to mount drives
LDI_C $drive_1_fs_handle
CALL :heap_push_C
LDI_C $drive_0_fs_handle
CALL :heap_push_C

LDI_AH 0x00                     # AH = current drive we're working on
.mount_drives_loop
CALL :heap_push_AH
LDI_C .mount_0_str
CALL :printf
CALL :heap_pop_B                # Load filesystem handle address into B
CALL :heap_push_B               # address of filesystem handle
LDI_C 0x0000
CALL :heap_push_C               # high word of filesystem start sector (0x0000)
CALL :heap_push_C               # low word of filesystem start sector (0x0000)
CALL :heap_push_AH              # ATA device ID (AH)
CALL :fat16_mount
CALL :heap_pop_AL               # status byte
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xff = drive not attached
JZ .mount_drives_ok             # 0x00 = success, move on
LDI_C .mount_1_str              # otherwise, print our failure header
CALL :print
JEQ .mount_failed_not_attached
LDI_BL 0xfd
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xfd = extmalloc failed
JEQ .mount_failed_extmalloc
LDI_BL 0xfe
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xfe = Not a FAT16 filesystem
JEQ .mount_failed_notfat16
JMP .mount_failed_ataerror      # other = ATA error

# Failure conditions when mounting
.mount_failed_not_attached
LDI_C .mount_2_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_extmalloc
LDI_C .mount_3_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_notfat16
LDI_C .mount_4_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_ataerror
LDI_C .mount_5_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_drives_ok
LDI_C .ok
CALL :print
JMP .mount_drives_loop_end

.mount_drives_loop_end
ALUOP_AH %A+1%+%AH%
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .mount_drives_done
JMP .mount_drives_loop
.mount_drives_done
RET

.ok "OK\n\0"
.mount_filehandle "Filesystem handle address for drive %c: 0x%x%x\n\0"
.mount_0_str "Mounting drive %u...\0"
.mount_1_str "FAILED: \0"
.mount_2_str "Drive 0 not responding (code 0x%x)\n\0"
.mount_3_str "Extmalloc failed (code 0x%x)\n\0"
.mount_4_str "Not a FAT16 filesystem (code 0x%x)\n\0"
.mount_5_str "ATA error (code 0x%x)\n\0"

