# vim: syntax=asm-mycpu

:boot_ata_init
LDI_BL 0                                # primary master
CALL :heap_push_BL
CALL :ata_identify_string               # ID string is on top of heap
CALL :heap_pop_A                        # save string address so we can free it
CALL :heap_push_A
LDI_BL 0                                # primary master
CALL :heap_push_BL
LDI_C .ata_banner
CALL :printf
LDI_BL 3                                # free 64 bytes, A still contains addr
CALL :free

LDI_BL 1                                # primary slave
CALL :heap_push_BL
CALL :ata_identify_string               # ID string is on top of heap
CALL :heap_pop_A                        # save string address so we can free it
CALL :heap_push_A
LDI_BL 1                                # primary master
CALL :heap_push_BL
LDI_C .ata_banner
CALL :printf
LDI_BL 3                                # free 64 bytes, A still contains addr
CALL :free
RET

.ata_banner "ATA%u: %s\n\0"
