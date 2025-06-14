# vim: syntax=asm-mycpu

# 1. Push the filesystem handle
# 2. Push the directory entry
# 3. Call run_ody

VAR global word $shell_ody_fh

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
CALL :heap_pop_B                # filesystem handle
ALUOP_ADDR %B%+%BH% $shell_ody_fh # save filesystem handl
ALUOP_ADDR %B%+%BL% $shell_ody_fh+1

# Load the first sector of the binary into a temporary memory segment
LDI_AL 4                        # allocate 4 segments, 512 bytes
CALL :malloc_segments           # address in A
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
ALUOP_PUSH %B%+%BL%
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_BL
JNE .allocate_ody_memory
LDI_C .ody_err1
CALL :print
JMP .run_ody_done

# Allocate the proper memory segment for the binary based
# on the flag byte settings
.allocate_ody_memory
ALUOP_PUSH %A%+%AL%
MOV_CH_AH
MOV_CL_AL
CALL :free                      # free the temporary memory segment
POP_AL

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
CALL :extpage_d_push
CALL :extmalloc
CALL :extpage_e_push
LDI_C 0xd000
CALL .load_and_run
CALL :extpage_e_pop
CALL :extfree
CALL :extpage_d_pop
CALL :extfree
JMP .run_ody_done

.extmalloc_e
# We don't care about the file size, just allocate one extended
# memory page, assign to E, and return 0xe000
# TODO: test for filesize >4K and abort
CALL :extmalloc
CALL :extpage_e_push
LDI_C 0xe000
CALL .load_and_run
CALL :extpage_e_pop
CALL :extfree
JMP .run_ody_done

.extmalloc_d
# We don't care about the file size, just allocate one extended
# memory page, assign to D, and return 0xd000
# TODO: test for filesize >4K and abort
CALL :extmalloc
CALL :extpage_d_push
LDI_C 0xd000
CALL .load_and_run
CALL :extpage_d_pop
CALL :extfree
JMP .run_ody_done

.malloc_main
# Round the file size up to the nearest 512 bytes
CALL :heap_push_D               # directory entry
CALL :fat16_dirent_filesize
CALL :heap_pop_A                # low word of file size
CALL :heap_pop_word             # high word of file size (ignored)

# Our goal is to take the 16-bit filesize and convert it to a malloc
# number that is rounded up to the nearest 512 bytes.
#
# Rounding to the nearest 512 bytes means clearing the lowest 9 bits
# (which rounds _down_ to the nearest 512 bytes), so we then need to
# add 0x0200 to the result to round up. Observe that this means we
# completely ignore the bottom 8 bits.  So the "add" step is really
# to just add 0x02 to the high byte, and set the low byte to zero.
# We can simplify the addition so that we only need to add 0x01 to the
# high byte, by shifting it right first, then adding 1, then shifting
# left.
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
# Shift right seven positions to get the number of segments we need to malloc
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right

ALUOP_BL %A%+%AL%               # save malloc size for freeing
CALL :malloc_segments
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

LD_AH $shell_ody_fh
LD_AL $shell_ody_fh+1
CALL :heap_push_A               # filesystem handle on heap
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
