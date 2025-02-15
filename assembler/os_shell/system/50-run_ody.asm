# vim: syntax=asm-mycpu

# Runs the ODY referenced in the directory handle on the heap,
# which is assumed to be from the current drive filesystem handle.

:run_ody
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_D                # directory handle

# Get current drive and a pointer to its filesystem handle
CALL :fat16_get_current_fs_handle
CALL :heap_pop_B                # A = filesystem handle

# Load the first sector of the binary into a temporary memory segment
LDI_AL 31                       # allocate 512 bytes
CALL :malloc                    # address in A
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # save temp memory address for freeing later

CALL :heap_push_B               # filesystem handle
CALL :heap_push_C               # target memory address
LDI_AL 1                        # one sector to load
CALL :heap_push_AL
CALL :heap_push_D               # directory entry
CALL :fat16_readfile
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JZ .inspect_ody                 # success, proceed to inspect the file
CALL :heap_push_AL              # error, print ATA error
LDI_C .ata_err1
CALL :printf
JMP .run_ody_done

# Inspect the binary to make sure it's an ODY, and get the
# flags byte so we can allocate memory
.inspect_ody
CALL :heap_push_C               # temp memory address
CALL :fat16_inspect_ody
CALL :heap_pop_AL               # flag/status byte
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .allocate_ody_memory
LDI_C .ody_err1
CALL :print
JMP .run_ody_done

# Allocate the proper memory segment for the binary based
# on the flag byte settings
.allocate_ody_memory
LDI_BL 31                       # 512 bytes to free
MOV_CH_AH
MOV_CL_AL
CALL :free                      # free the temporary memory segment

                                # Flag byte is in AL
LDI_BL 0x03                     # lowest two bits are the memory allocation flag
ALUOP_AL %A&B%+%AL%+%BL%        # remove all the other bits
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_de
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_e
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_d
LDI_BL 0x00
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .malloc_main
JMP .run_ody_done               # should never happen but just in case

.extmalloc_de
# We don't care about the file size, just allocate two extended
# memory pages, assign them to D and E, and return 0xd000
# TODO: test for filesize >8K and abort
CALL :extmalloc
CALL :heap_pop_DH
ST_DH %d_page%
CALL :extmalloc
CALL :heap_pop_DL
ST_DL %e_page%
LDI_C 0xd000
CALL .load_and_run
CALL :heap_push_DL
CALL :extfree
CALL :heap_push_DH
CALL :extfree
JMP .run_ody_done

.extmalloc_e
# We don't care about the file size, just allocate one extended
# memory page, assign to E, and return 0xe000
# TODO: test for filesize >8K and abort
CALL :extmalloc
CALL :heap_pop_DL
ST_DL %e_page%
LDI_C 0xe000
CALL .load_and_run
CALL :heap_push_DL
CALL :extfree
JMP .run_ody_done

.extmalloc_d
# We don't care about the file size, just allocate one extended
# memory page, assign to D, and return 0xd000
# TODO: test for filesize >16K and abort
CALL :extmalloc
CALL :heap_pop_DL
ST_DL %d_page%
LDI_C 0xd000
CALL .load_and_run
CALL :heap_push_DL
CALL :extfree
JMP .run_ody_done

.malloc_main
# Round the file size up to the nearest 512 bytes
CALL :heap_push_D               # directory entry
CALL :fat16_dirent_filesize
CALL :heap_pop_A                # low word of file size
CALL :heap_pop_word             # high word of file size (ignored)
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
# Shift right four positions to get the number of
# blocks we need to malloc
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
ALUOP_BL %A%+%AL%               # save malloc size for freeing
CALL :malloc
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # copy address to C
CALL .load_and_run
CALL :free                      # A contains address, B contains size
JMP .run_ody_done

.run_ody_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


# Load the ODY into RAM and execute it.  The target address is in C,
# and the directory entry (for the file size) is in D
.load_and_run
CALL :heap_push_all

CALL :fat16_get_current_fs_handle # filesystem handle on heap
CALL :heap_push_C               # target memory address
LDI_AL 0                        # load all sectors
CALL :heap_push_AL
CALL :heap_push_D               # directory entry
CALL :fat16_readfile
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JZ .localize_ody                # success, proceed to localize the file
CALL :heap_push_AL              # error, print ATA error
LDI_C .ata_err2
CALL :printf
JMP .load_and_run_done

.localize_ody
# Localize the ODY memory addresses
CALL :heap_push_C               # address of binary
CALL :fat16_localize_ody
CALL :heap_pop_D                # first byte of program

CALL_D                          # execute the program - this should never return

.load_and_run_done
CALL :heap_pop_all
RET

.ata_err1 "ATA error loading first sector of binary: 0x%x\n\0"
.ata_err2 "ATA error loading binary: 0x%x\n\0"
.ody_err1 "Error: file does not look like an ODY executable\n\0"
