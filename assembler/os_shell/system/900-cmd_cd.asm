# vim: syntax=asm-mycpu

# Change directories to the (exact) name given on the command line

:cmd_cd

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage                       # abort with usage message if null

##########################################################
#### TODO: replace most of this logic with :fat16_dir_find
##########################################################

# Get current drive and a pointer to its filesystem handle
LD_AH $current_fs_handle
LD_AL $current_fs_handle+1      # A = filesystem handle
ALUOP_FLAGS %A%+%AH%
JNZ .current_fs_handle_valid
ALUOP_FLAGS %A%+%AL%
JNZ .current_fs_handle_valid
JMP .abort_not_mounted          # if the current filesystem handle was null, abort
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
.readdir_loop
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
JEQ .readdir_next_entry         # if 0xe5, empty entry, skip
JZ .cd_done_nomatch             # if 0x00, we're out of directory entries and did not find a match

# Check that this is a directory entry
CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_attribute    # attribute byte on heap
CALL :heap_pop_BL               # attribute byte in BL
ALUOP_PUSH %A%+%AL%             # save AL temporarily
LDI_AL 0b00010000               # directory attribute
ALUOP_FLAGS %A&B%+%AL%+%BL%     # check if directory attr is set
POP_AL
JZ .readdir_next_entry          # skip this entry if it's not a directory

# Does this directory name match our command line argument?
LDI_B $user_input_tokens+2      # Get pointer to first cmdline arg into C
LDA_B_CH                        # |
LDI_B $user_input_tokens+3      # |
LDA_B_CL                        # C contains string (filename) we're trying to match

CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_filename     # address word of filename on heap
CALL :heap_pop_D                # D contains pointer to filename
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
MOV_DL_AL                       # Copy D to A because we need to free the
MOV_DH_AH                       #   memory when we're done comparing
LDI_BL 0                        # size 0 = 16 bytes
CALL :free                      # free the filename string
CALL :strcmp                    # Compare strings in C and D, result in AL
ALUOP_FLAGS %A%+%AL%            # is AL zero (strings matched)?
POP_AH
POP_AL
JZ .cd_done_match               # escape if we found a match

.readdir_next_entry
CALL :fat16_dirwalk_next
JMP .readdir_loop

.cd_done_match
# Get current drive and a pointer to its filesystem handle
# A currently contains a pointer to the matching directory entry.
# Start by pushing the new cluster number to the heap, then
# get the filename string.
CALL :heap_push_A               # Push directory entry pointer
CALL :fat16_dirent_cluster      # Cluster of directory on heap
CALL :heap_push_A               # Push directory entry pointer
CALL :fat16_dirent_filename     # address word of dirname on heap
CALL :heap_pop_C                # C = pointer to filename string

# If filename is "." then the dir doesn't change; if it's
# ".." then we are removing a directory from the CWD string,
# not appending one.
LDA_C_AH                        # First char of filename in AH
INCR_C
LDA_C_AL                        # Second char of filename in AL
DECR_C                          # Ensure C stays pointing at beginning of string
LDI_BL '.'
ALUOP_FLAGS %A&B%+%AH%+%BL%     # is first character '.'?
JNE .normal_cd
# If here, it's either '.' or '..'
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is second character '.'?
JNE .singledot_cd

####
# "double-dot" cd where we go up one directory. Strip the
# characters from the CWD string up to the first slash.
MOV_CH_AH                       # Copy filename string pointer to A
MOV_CL_AL
LDI_BL 0                        # size 0, 16 bytes
CALL :free                      # Free the memory
# load up the filesystem handle into D
LD_DH $current_fs_handle
LD_DL $current_fs_handle+1      # D = filesystem handle; first field is cwd
# loop to find the end of the CWD string
.doubledot_cd_loop
LDA_D_BL                        # character @ D => BL
ALUOP_FLAGS %B%+%BL%            # check if null
JZ .doubledot_cd_ready          # loop until we find a null
INCR_D
JMP .doubledot_cd_loop
# Overwrite final slash with NULL
.doubledot_cd_ready             # D points at first NULL in the directory entry
DECR_D                          # D points at last slash in the directory entry
ALUOP_ADDR_D %zero%             # write over last slash with NULL
LDI_BL '/'                      # we are looking for a slash in the loop below
# Loop backward erasing until we find slash
.doubledot_cd_erase_loop
DECR_D
LDA_D_AL                        # Get character @ D into AL
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is this a slash?
JEQ .cd_done_match_finish       # We are done if so
ALUOP_ADDR_D %zero%             # otherwise, overwrite this char
JMP .doubledot_cd_erase_loop    # and continue looping

####
# "single-dot" cd where we're staying in the same directory.
# Nothing changes, just return without doing anything. The new
# directory cluster on the heap is correct, just keep it there
# and return without modifying the CWD string.
.singledot_cd
JMP .cd_done_match_finish

####
# "normal" cd where we're going deeper into the tree
.normal_cd
LD_DH $current_fs_handle
LD_DL $current_fs_handle+1      # D = filesystem handle; first field is cwd
.normal_cd_loop
LDA_D_BL                        # character @ D => BL
ALUOP_FLAGS %B%+%BL%            # check if null
JZ .normal_cd_ready             # loop until we find a null
INCR_D
JMP .normal_cd_loop
.normal_cd_ready                # D points at first NULL in the directory entry
PUSH_CH                         # C points at filename string; save C for later
PUSH_CL                         # Save C for later
CALL :strcpy                    # copy filename to end of directory string
LDI_BL '/'                      # Append a slash to the dir name
ALUOP_ADDR_D %B%+%BL%
POP_AL
POP_AH                          # Restore filename string address into A
LDI_B 0                         # size 0, 16 bytes
CALL :free
JMP .cd_done_match_finish

####
# Generic completion routine; assumes that heap has the new directory
# cluster number on top.
.cd_done_match_finish
CALL :heap_pop_C                # C contains new directory cluster number
LD_AH $current_fs_handle
LD_AL $current_fs_handle+1      # A = filesystem handle
LDI_B 0x0036                    # offset 0x36 = cluster number
CALL :add16_to_a                # A = address of cluster number high byte
STA_A_CH                        # Save cluster number in filesystem handle
CALL :incr16_a                  # |
STA_A_CL                        # |
CALL :fat16_dirwalk_end         # free memory from the directory walk
RET 


.cd_done_nomatch
CALL :fat16_dirwalk_end         # free memory
LDI_C .notfound_str
CALL :print
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

.usage
LDI_C .helpstr
CALL :print
RET

.debug_str "Comparing c=[%s] to d=[%s]\n\0"
.helpstr "Usage: cd <directory>\n\0"
.not_mounted_str "Error: filesystem is not mounted\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
.notfound_str "Error: no such directory\n\0"
