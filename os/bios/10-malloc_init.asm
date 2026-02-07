# vim: syntax=asm-mycpu

:boot_malloc_init
# Initialize extended memory allocation
CALL :extmalloc_init

# Initialize main memory allocation
LDI_A 0x6000
LDI_BL 160   # 160 128 byte segments = 20KiB
CALL :malloc_init
LDI_C .malloc_init_banner
LDI_A 0xb000-0x6000
CALL :heap_push_A
LDI_A 0xafff
CALL :heap_push_AL
CALL :heap_push_AH
LDI_A 0x6000
CALL :heap_push_AL
CALL :heap_push_AH
CALL :printf
RET

.malloc_init_banner "Malloc range 0x%x%x-0x%x%x (%U bytes)\n\0"
.new_malloc_banner "New \0"
