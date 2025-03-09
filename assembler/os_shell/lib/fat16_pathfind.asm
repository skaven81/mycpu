# vim: syntax=asm-mycpu

# Utility function that allows seeking a file or directory given a path.
#
# Supported formats:
#    FILENAME.EXT - look for the file/dir in the current directory
#    DIR/DIR/FILENAME.EXT - look for the file/dir, starting from the current directory.
#                           The first DIR may be `.` or `..` if not in the root directory.
#    /DIR/DIR/FILENAME.EXT - look for the file/dir starting at the root directory
#    0:/DIR/DIR/FILENAME.EXT - look for the file/dir on the specified drive
#
# The last token is allowed to be a file or dir; the
# previous tokens must all be directories.
#
# To use:
#  1. Push the address of a string containing the path to find
#  2. Call the function
#  3. Pop the address word of a directory entry. If the high byte is:
#     * 0x00 - no ATA error, but the file/dir was not found.  The reason is in the low byte:
#       * 0x00 - everything was fine, but the requested file/dir was not found
#       * 0x01 - the provided path had a syntax error
#     * 0x01 - ATA error, and the low byte is the ATA status byte
#  4. If it wasn't an error, pop the address of the filesystem handle
#  5. If it wasn't an error, free the returned memory (size 1, 32 bytes)
#
# Algorithm used:
#   1. if first chars of path are '0:' or '1:', set the working drive to that,
#      otherwise set the working drive to $current_fs_handle. Discard the 0: or 1:
#   2. if the first char of the remaining path is '/', set the working cluster
#      to the root directory cluster. Otherwise set the working cluster to the
#      current directory cluster.  Discard the '/'
#   3. Split the remaining path string on '/' chars
#   4. while next token != null (loop until last token but don't process last token)
#      4.1. search working dir/cluster for token, as directory
#      4.2. if not found, abort and return 0x0000
#      4.3. set working dir/cluster to found cluster
#   5. search working dir for last token, as file or dir
#   6. if not foun, abort and return 0x0000
#   7. allocate 32 byte memory segment
#   8. copy directory entry of matching file/dir to new memory
#   9. return address of directory entry

.debug_targetfs "Target filesystem handle: 0x%x%x\n\0"
.debug_start_cluster "Starting cluster number: 0x%x%x\n\0"
.debug_search_string "Search: [%s]\n\0"
.debug_input "Input: [%s]\n\0"
.debug_loop "fs 0x%x%x clus 0x%x%x search [%s]\n\0"
.debug_ret "pathfind return 0x%x%x\n\0"
.debug_dirfind "dirfind return 0x%x%x\n\0"

:fat16_pathfind
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                    # C = path
#### DEBUG
CALL :heap_push_C
PUSH_CH
PUSH_CL
LDI_C .debug_input
CALL :printf
POP_CL
POP_CH
#### DEBUG

####
# Get target filesystem handle into D
                                    # input=>C=>path
CALL :fat16_get_fs_handle_from_path # C now points at start of path
CALL :heap_pop_A                    # A = filesystem handle (or 0x00.. if syntax error)
ALUOP_FLAGS %A%+%AH%
JZ .fat16_pathfind_syntax_error
ALUOP_DH %A%+%AH%                   # copy filesystem handle into D
ALUOP_DL %A%+%AL%
#### DEBUG
CALL :heap_push_DL
CALL :heap_push_DH
PUSH_CH
PUSH_CL
LDI_C .debug_targetfs
CALL :printf
POP_CL
POP_CH
#### DEBUG

####
# Get starting cluster number into B
LDA_C_AL                            # load first character of the path into AL
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AL%+%BL%         # check if first char is '/'
JEQ .fat16_pathfind_startroot
# if here, use the current directory as the starting cluster. The current
# cluster is in the filesystem handle
CALL :heap_push_D                   # filesystem handle
CALL :fat16_get_current_directory_cluster
CALL :heap_pop_B
JMP .fat16_pathfind_splitpath
# if here, use the root directory as the starting cluster. The root directory
# is indicated as cluster 0.
.fat16_pathfind_startroot
LDI_B 0x0000
INCR_C                              # move to the first char after the first /

####
# Split up the path into parts using '/' as a separator.
# Store the address of the resulting array in C
.fat16_pathfind_splitpath
#### DEBUG
CALL :heap_push_BL
CALL :heap_push_BH
PUSH_CH
PUSH_CL
LDI_C .debug_start_cluster
CALL :printf
POP_CL
POP_CH

CALL :heap_push_C
PUSH_CH
PUSH_CL
LDI_C .debug_search_string
CALL :printf
POP_CL
POP_CH
#### DEBUG

LDI_AL 1                            # size 1, 32 bytes, enough for 16 substrings
CALL :malloc                        # allocated address in A
ALUOP_PUSH %A%+%AH%                 # save for later
ALUOP_PUSH %A%+%AL%
PUSH_DH
PUSH_DL
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = token array
LDI_AH '/'                          # split character
LDI_AL 0x00                         # substring alloc size 0 (16 bytes)
                                    # C already points at the string to split
CALL :strsplit
POP_DL
POP_DH                              # restore D = filesystem handle
POP_CL
POP_CH                              # restore C = token array (from push A above)

PUSH_CH                             # save token array for freeing later
PUSH_CL

####
# Current state:
#  A = scratch
#  B = starting directory cluster
#  C = path token array
#  D = filesystem handle
####

.fat16_pathfind_loop
CALL :heap_push_D                   # filesystem handle
CALL :heap_push_B                   # cluster(dir) to search
LDA_C_AH                            # load address of next token into A
INCR_C
LDA_C_AL
INCR_C
CALL :heap_push_A                   # name to search for in fat16_dir_find below

#### DEBUG
CALL :heap_push_A   # name
CALL :heap_push_BL  # cluster
CALL :heap_push_BH  # cluster
CALL :heap_push_DL  # fs handle
CALL :heap_push_DH  # fs handle
PUSH_CH
PUSH_CL
LDI_C .debug_loop
CALL :printf
POP_CL
POP_CH
#### DEBUG

# If we have reached the end of the list of tokens without a match,
# then there was no match. A contains the pointer to the current token
# string, so check if it's null.  Just checking the high byte is sufficient
# since we'll never have a token string get malloc'd into 0x00...memory
ALUOP_FLAGS %A%+%AH%
JNZ .token_addr_is_valid
CALL :heap_pop_word                 # pop the name
CALL :heap_pop_word                 # pop the cluster
CALL :heap_pop_word                 # pop the filesystem handle
JMP .fat16_pathfind_notfound

# If search string is empty, there may be something like a double-slash
# in the path, so just skip this token and move on.
.token_addr_is_valid
ALUOP_PUSH %B%+%BL%
LDA_A_BL                            # load first char of token into BL
ALUOP_FLAGS %B%+%BL%
POP_BL
JNZ .token_is_not_null
# If we are here, then the search token is null.  We need to discard the
# three items on the heap and loop back to the top.
CALL :heap_pop_word                 # pop the name
CALL :heap_pop_word                 # pop the cluster
CALL :heap_pop_word                 # pop the filesystem handle
JMP .fat16_pathfind_loop

# If next token = null, this is the last token and so we are looking
# for a directory or file. Otherwise, we are only looking for a directory
.token_is_not_null
LDA_C_AH
ALUOP_FLAGS %A%+%AH%                # malloc addresses start at 0x6000
JZ .next_token_null1                # so this is sufficient
LDI_AL 0x08                         # filter OUT = volume labels
CALL :heap_push_AL
LDI_AL 0x10                         # filter IN = directories
CALL :heap_push_AL
JMP .do_dir_find
.next_token_null1
LDI_AL 0x08                         # filter OUT = volume labels
CALL :heap_push_AL
LDI_AL 0xff                         # filter IN = everything
CALL :heap_push_AL
.do_dir_find
CALL :fat16_dir_find
CALL :heap_pop_A                    # A = address of matching directory entry, or error

##### DEBUG
CALL :heap_push_AL
CALL :heap_push_AH
PUSH_CH
PUSH_CL
LDI_C .debug_dirfind
CALL :printf
POP_CL
POP_CH
##### DEBUG

ALUOP_PUSH %B%+%BL%
LDI_BL 0x02                         # high byte = 0x02 = ATA error
ALUOP_FLAGS %A&B%+%AH%+%BL%
POP_BL
JEQ .fat16_pathfind_ata_error
ALUOP_FLAGS %A%+%AH%
JZ .fat16_pathfind_notfound

# If we are here, A contains a memory address of a directory entry
# that matches the token we were looking for.  If the next token
# is null, then we are done and this is what we want to return. If
# the next token is not null, then extract the cluster number of the
# directory entry and continue the loop.
ALUOP_PUSH %A%+%AH%
LDA_C_AH
ALUOP_FLAGS %A%+%AH%                # malloc addresses start at 0x6000
POP_AH                              # so this is sufficient
JZ .next_token_null2
# next token is not null, so extract directory cluster
CALL :heap_push_A                   # directory entry
CALL :fat16_dirent_cluster          # cluster number on heap
LDI_BL 1                            # size 1, 32 bytes
CALL :free                          # free the directory entry
CALL :heap_pop_B                    # update current cluster
JMP .fat16_pathfind_loop
.next_token_null2
# next token is null, so the entry we found must be what
# we were looking for, so return it.
CALL :heap_push_D                   # since we're returning a directory entry, also push the filesystem handle
CALL :heap_push_A                   # return the directory entry, don't free it
JMP .fat16_pathfind_done

.fat16_pathfind_syntax_error
LDI_C 0x0001
CALL :heap_push_C
JMP .fat16_pathfind_final

.fat16_pathfind_ata_error
LDI_AH 0x01                         # AL still contains the ATA error
CALL :heap_push_A
JMP .fat16_pathfind_done

.fat16_pathfind_notfound
LDI_C 0x0000
CALL :heap_push_C
JMP .fat16_pathfind_done

.fat16_pathfind_done
# clear the malloc'd memory
POP_DL
POP_DH                              # D = token array
PUSH_DL
PUSH_DH                             # Save for the final free
.pathfind_token_free_loop
LDA_D_AH
INCR_D
LDA_D_AL
INCR_D
ALUOP_FLAGS %A%+%AH%
JZ .pathfind_token_free_loop_done
LDI_BL 0                            # size 0 = 16 bytes
CALL :free
JMP .pathfind_token_free_loop
.pathfind_token_free_loop_done
# free the main array
POP_AH                              # restore base address from above
POP_AL
LDI_BL 1                            # size 1, 32 bytes
CALL :free

.fat16_pathfind_final
##### DEBUG
CALL :heap_pop_D
CALL :heap_push_DL
CALL :heap_push_DH
LDI_C .debug_ret
CALL :printf
CALL :heap_push_D
##### DEBUG

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


