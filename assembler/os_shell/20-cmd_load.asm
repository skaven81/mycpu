# vim: syntax=asm-mycpu

# Load a file from disk into memory
#  Argument 1 (+2/3): filename (exact match)
#  Argument 2 (+4/5): address to write to

:cmd_load

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_D $user_input_tokens+4      # D points at second argument pointer
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check destination address format
LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

# Get current drive and a pointer to its filesystem handle
CALL :fat16_get_current_fs_handle
CALL :heap_pop_A                # A = filesystem handle
ALUOP_FLAGS %A%+%AH%
JZ .abort_not_mounted           # if the current drive was null, result will be zero

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
JZ .load_done_nomatch           # if 0x00, we're out of directory entries and did not find a match

# Check that this is not a directory or volume ID entry
CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_attribute    # attribute byte on heap
CALL :heap_pop_BL               # attribute byte in BL
ALUOP_PUSH %A%+%AL%             # save AL temporarily
LDI_AL 0b00011000               # directory and volume ID attributes
ALUOP_FLAGS %A&B%+%AL%+%BL%     # check if directory or volume ID attr is set
POP_AL
JNZ .readdir_next_entry         # skip this entry if it's not a file

# Does this file name match our command line argument?
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
JZ .load_done_match             # escape if we found a match

.readdir_next_entry
CALL :fat16_dirwalk_next
JMP .readdir_loop

.load_done_match
CALL :fat16_dirwalk_end         # free memory from the directory walk
# Get current drive and a pointer to its filesystem handle
# A currently contains a pointer to the matching directory entry.
# Start by pushing the file's cluster number to the heap.
CALL :heap_push_A               # Push directory entry pointer
CALL :fat16_dirent_cluster      # Cluster of directory on heap
CALL :heap_pop_D                # D = cluster number of file
LDI_C .debug_str1
CALL :heap_push_D
CALL :printf
RET 

.load_done_nomatch
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

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
RET

.bad_addr_str "Error: Dest addr %s is not a valid 16-bit word. strtoi flags: 0x%x\n\0"
.helpstr "Usage: load <filename> <dest-addr>\n\0"
.not_mounted_str "Error: filesystem is not mounted\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
.notfound_str "Error: no such file\n\0"
.debug_str1 "Loading from cluster 0x%x%x\n\0"
