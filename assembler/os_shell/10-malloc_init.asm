# vim: syntax=asm-mycpu

:boot_malloc_init
LDI_A 0x6000
LDI_BL 79    # 80 segments = 10KiB
CALL :malloc_init
LDI_C .malloc_init_banner
LDI_A 0x8800-0x6000
CALL :heap_push_A
LDI_A 0x87ff
CALL :heap_push_AL
CALL :heap_push_AH
LDI_A 0x6000
CALL :heap_push_AL
CALL :heap_push_AH
CALL :printf

LDI_A 0x8800
LDI_BL 80    # 80 segments = 10KiB
CALL :new_malloc_init
LDI_C .new_malloc_banner
CALL :print
LDI_C .malloc_init_banner
LDI_A 0xb000-0x8800
CALL :heap_push_A
LDI_A 0xafff
CALL :heap_push_AL
CALL :heap_push_AH
LDI_A 0x8800
CALL :heap_push_AL
CALL :heap_push_AH
CALL :printf

# Initialize extended memory allocation
CALL :extmalloc_init
RET

.malloc_init_banner "Malloc range 0x%x%x-0x%x%x (%U bytes)\n\0"
.new_malloc_banner "New \0"
