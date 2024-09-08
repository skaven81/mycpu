# vim: syntax=asm-mycpu

# Tests the mount command

:cmd_mount

LDI_C 0x0000
CALL :heap_push_C           # high word of LBA
CALL :heap_push_C           # low word of LBA
CALL :heap_push_CL          # ATA ID (0/master)
CALL :fat16_mount

CALL :heap_pop_AL           # status byte
ALUOP_FLAGS %A%+%AL%
JNZ .mount_error

CALL :heap_pop_A            # address of filesystem handle
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .str_success
CALL :printf

CALL :heap_push_A           # address of fliesystem handle
CALL :fat16_print

RET

.mount_error
CALL :heap_push_AL
LDI_C .str_err
CALL :printf
RET


.str_err "Error mounting filesystem: 0x%x\n\0"
.str_success "Filesystem mounted. 128-byte filesystem handle at 0x%x%x\n\n\0"
