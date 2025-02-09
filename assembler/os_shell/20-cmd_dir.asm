# vim: syntax=asm-mycpu

# List the directory entries of the current directory

:cmd_dir

# Get current drive and a pointer to its filesystem handle
LD_AL $current_drive
LDI_BL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .abort_not_mounted           # if the current drive was null, zero flag will be set
JNE .use_drive_1                # if result wasn't zero but they weren't the same, must be '1'
LDI_C $drive_0_fs_handle
JMP .fs_handle_addr_in_c
.use_drive_1
LDI_C $drive_1_fs_handle
.fs_handle_addr_in_c
LDA_C_AH
INCR_C
LDA_C_AL                        # filesystem handle address in A
ALUOP_CH %A%+%AH%               # copy to C
ALUOP_CL %A%+%AL%               # copy to C

# Check to make sure filesystem is mounted
LDI_BL '/'
LDA_C_AL                        # first byte of filesystem handle in AL
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is '/'? If not, not mounted
JNE .abort_not_mounted

# Retrieve directory cluster number and push it to heap
MOV_CH_AH                       # filesystem handle address in A
MOV_CL_AL
LDI_B 0x0036                    # Offset 0x36 = current directory cluster
CALL :add16_to_b                # B=address of current directory cluster
LDA_B_CH
CALL :incr16_b
LDA_B_CL                        # C = current directory cluster
CALL :heap_push_C

# Push the filesystem handle address
CALL :heap_push_A

# Begin the directory walking process
CALL :fat16_dirwalk_start

# First directory entry address is on heap; high byte will be 0x00 if
# there was an error; the error code is in the low byte.

## Loop until a call to :fat16_dirwalk_next returns an error, or
## we reach the last directory entry
.printdir_loop
CALL :heap_pop_A                # Pop next directory entry off the heap
ALUOP_FLAGS %A%+%AH%
JZ .abort_ata_error             # stop looping if we got an error

## The first byte indicates directory entry type:
##  0x00 - stop, no more directory entries
##  0xe5 - skip, free entry
##  anything else - valid directory entry
LDA_A_BL                        # fetch the first character of the entry
ALUOP_PUSH %A%+%AL%
LDI_AL 0xe5
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JEQ .printdir_next_entry        # if 0xe5, don't print, move to next
JZ .dir_done                    # if 0x00, stop processing

CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_attribute    # attribute byte on heap
CALL :heap_pop_BL               # attribute byte in BL
ALUOP_PUSH %A%+%AL%
LDI_AL 0x08                     # fourth bit = volume
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JNZ .printdir_next_entry        # skip if it's the volume label entry

CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_string       # otherwise, load the dirent and print it
CALL :heap_pop_C                # address of rendered string
MOV_CH_AH                       # Put address of dirent string into A
MOV_CL_AL
CALL :print
LDI_BL 0x02                     # size 2 (48 bytes)
CALL :free                      # free the string allocated by dirent
LDI_AL '\n'
CALL :putchar                   # print the newline after the directory entry

.printdir_next_entry
CALL :fat16_dirwalk_next
JMP .printdir_loop

.dir_done
CALL :fat16_dirwalk_end         # free memory
RET

.abort_ata_error
LDI_C .bad_read_str
CALL :heap_push_AL
CALL :printf
RET

.abort_not_mounted
LDI_C .not_mounted_str
CALL :print
RET

.not_mounted_str "Error: filesystem is not mounted\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
