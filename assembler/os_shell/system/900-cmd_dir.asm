# vim: syntax=asm-mycpu

# List the directory entries of the current directory

:cmd_dir

# Get current drive and a pointer to its filesystem handle
LD_AH $current_fs_handle_ptr
LD_AL $current_fs_handle_ptr+1  # A = filesystem handle
ALUOP_FLAGS %A%+%AH%
JNZ .current_fs_handle_valid
ALUOP_FLAGS %A%+%AL%
JNZ .current_fs_handle_valid
JMP .abort_not_mounted          # if the current filesystem was null, result will be zero
.current_fs_handle_valid

# Retrieve directory cluster number and push it to heap
CALL :heap_push_A
CALL :fat16_get_current_directory_cluster
CALL :heap_pop_C                # C = current directory cluster

# Push the current directory cluster
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
ALUOP_PUSH %A%+%AL%             # save AL temporarily
LDI_AL 0b00001000               # volume attribute
ALUOP_FLAGS %A&B%+%AL%+%BL%     # check if volume attr is set
POP_AL
JNZ .printdir_next_entry        # skip this entry if it's the volume ID

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
