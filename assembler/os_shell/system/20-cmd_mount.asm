# vim: syntax=asm-mycpu

# Mount the drive (0 or 1) given in the first argument

:cmd_mount

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage                       # abort with usage message if null

LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_drive

# Check if drive number is valid
ALUOP_FLAGS %A%+%AH%
JNZ .abort_bad_drive
LDI_D $drive_0_fs_handle
ALUOP_FLAGS %A%+%AL%
JZ .drive_num_ok

LDI_D $drive_1_fs_handle
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .abort_bad_drive

# If we make it here, D contains the memory
# address of the pointer to the filesystem handle
.drive_num_ok

# Mount the filesystem

# Get the actual memory address from D
LDA_D_BH
INCR_D
LDA_D_BL
CALL :heap_push_B           # address to store fs handle

LDI_C 0x0000
CALL :heap_push_C           # high word of LBA (0)
CALL :heap_push_C           # low word of LBA (0)
CALL :heap_push_AL          # ATA ID (from command line argument)

CALL :fat16_mount

CALL :heap_pop_AL           # status byte
ALUOP_FLAGS %A%+%AL%
JNZ .mount_error

CALL :heap_push_BL
CALL :heap_push_BH
LDI_C .str_success
CALL :printf

CALL :heap_push_B           # address of fliesystem handle
CALL :fat16_print

RET

.mount_error
LDI_BL 0xfe
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .mount_error_fs_error
LDI_BL 0xfd
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .mount_error_extmalloc_error

.mount_error_ata_error
CALL :heap_push_AL
LDI_C .str_ata_err
CALL :printf
RET

.mount_error_fs_error
LDI_C .str_fs_error
CALL :print
RET

.mount_error_extmalloc_error
LDI_C .str_extmalloc_error
CALL :print
RET


.abort_bad_drive
CALL :heap_push_C
LDI_C .bad_drive_str
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: mount {0,1}\n\0"
.bad_drive_str "Error: %s is not a valid drive number, must be 0 or 1.\n\0"
.str_ata_err "Error mounting: ATA error 0x%x\n\0"
.str_fs_error "Error mounting: LBA 0 does not contain a FAT16 filesystem\n\0"
.str_extmalloc_error "Error mounting: Unable to allocate extended memory\n\0"
.str_success "Filesystem mounted. 128-byte filesystem handle at 0x%x%x\n\n\0"
