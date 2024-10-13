# vim: syntax=asm-mycpu

# List the directory entries of the root directory in the given
# filesystem handle
#  Argument 1 (+2/3): filesystem handle address word

:cmd_dir

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

## Load and check filesystem handle address into A
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

## Extract root directory LBA
LDI_B 0x004f                    # 0x4f = RootDirectoryRegion start
CALL :add16_to_b                # B now points at the 32-bit LBA of the rootdir

## Retrieve root directory sector
LD_CL %e_page%
PUSH_CL                         # save the current 0xe page
CALL :extmalloc                 # allocated page is on the heap
CALL :heap_pop_CL
ST_CL %e_page%                  # we will load the rootdir sector into 0xe000

LDI_C 0xe000
CALL :heap_push_C               # memory segment for the sector

LDA_B_CH                        # high byte of high LBA word
CALL :incr16_b
LDA_B_CL                        # low byte of high LBA word
CALL :incr16_b
CALL :heap_push_C
LDA_B_CH                        # high byte of low LBA word
CALL :incr16_b
LDA_B_CL                        # low byte of low LBA word
CALL :heap_push_C

LDI_B 0x005f                    # 0x5f = ATA device ID
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL              # ATA device ID

CALL :ata_read_lba
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JNZ .ata_bad_read               # abort on bad read

## Iterate through root directory in 32-byte segments. First byte indicates
## directory entry type:
##  0x00 - stop, no more directory entries
##  0xe5 - skip, free entry
##  anything else - valid directory entry
LDI_A 0xe020                    # second directory entry (first is the volume label)
.printdir_loop
CALL :heap_push_A               # address of directory entry

LDA_A_BL                        # fetch the first character of the entry
ALUOP_PUSH %A%+%AL%
LDI_AL 0xe5
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JEQ .printdir_next_entry        # if 0xe5, don't print, move to next
JZ .dir_done                    # if 0x00, stop processing
CALL :fat16_dirent_string       # otherwise, load the dirent and print it
CALL :heap_pop_C                # address of rendered string
CALL :print

ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
MOV_CH_AH                       # Put address of string in A
MOV_CL_AL
LDI_BL 0x02                     # size 2 (48 bytes)
CALL :free                      # free the string allocated by dirent
LDI_AL '\n'
CALL :putchar                   # print the newline after the directory entry
POP_AL
POP_AH

.printdir_next_entry
LDI_B 0x0020                    # increment pointer by 32
CALL :add16_to_a
JMP .printdir_loop

.dir_done
LD_CL %e_page%                  # free allocated e page
CALL :heap_push_CL
CALL :extfree
POP_CL                          # restore 0xe page
ST_CL %e_page%

RET

.ata_bad_read
LDI_C .bad_read_str
CALL :heap_push_AL
CALL :printf
JMP .dir_done

.usage
LDI_C .helpstr
CALL :print
RET

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
RET

.helpstr "Usage: dir <fs handle addr>\n\0"
.bad_addr_str "Error: %s is not a valid 16-bit word. strtoi flags: 0x%x\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
