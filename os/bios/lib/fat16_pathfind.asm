# vim: syntax=asm-mycpu

# Utility function that allows seeking a file or directory given a path.
#
# Supported formats:
#    FILENAME.EXT - look for the file/dir in the current directory
#    DIR/DIR/FILENAME.EXT - look for the file/dir, starting from the current directory.
#                           Any component may be `.` (current dir) or `..` (parent dir).
#                           `..` at root stays at root (does not go out-of-bounds).
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
#  5. If it wasn't an error, call :free on the returned memory (2 blocks = 32 bytes)
#
# Algorithm used:
#   1. if first chars of path are '0:' or '1:', set the working drive to that,
#      otherwise set the working drive to $current_fs_handle. Discard the 0: or 1:
#   2. if the first char of the remaining path is '/', set the working cluster
#      to the root directory cluster. Otherwise set the working cluster to the
#      current directory cluster.  Discard the '/'
#   3. Split the remaining path string on '/' chars
#   4. while there are path tokens:
#      4.1. if this is the last token: jump to step 5
#      4.2. if token is empty (double-slash): skip
#      4.3. if token is "." (single dot): skip (stay in same directory)
#      4.4. if token is ".." at root (cluster==0): skip (already at root)
#      4.5. otherwise search working dir/cluster for token, as directory
#      4.6. if not found, abort and return 0x0000
#      4.7. set working dir/cluster to found cluster
#      NOTE: if no tokens remain (bare "/", ".", ".." from root, etc.), synthesize
#            a directory entry for the current cluster and return it directly.
#   5. search working dir for last token, as file or dir
#   6. if not found, abort and return 0x0000
#   7. return malloc'd copy of directory entry (2 blocks = 32 bytes)

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

####
# Get target filesystem handle into D
                                    # input=>C=>path
CALL :fat16_get_fs_handle_from_path # C now points at start of path
CALL :heap_pop_A                    # A = filesystem handle (or 0x00.. if syntax error)
ALUOP_FLAGS %A%+%AH%
JZ .fat16_pathfind_syntax_error
ALUOP_DH %A%+%AH%                   # copy filesystem handle into D
ALUOP_DL %A%+%AL%

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
LDI_AL 2                            # 2 blocks, 32 bytes, enough for 16 substrings
CALL :malloc_blocks                 # allocated address in A
ALUOP_PUSH %A%+%AH%                 # save for later
ALUOP_PUSH %A%+%AL%
PUSH_DH
PUSH_DL
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = token array
LDI_AH '/'                          # split character
LDI_AL 1                            # substring alloc 1 block (16 bytes)
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

# If we have reached the end of the list of tokens without a match,
# then there was no match. A contains the pointer to the current token
# string, so check if it's null.  Just checking the high byte is sufficient
# since we'll never have a token string get malloc'd into 0x00...memory
ALUOP_FLAGS %A%+%AH%
JNZ .token_addr_is_valid
CALL :heap_pop_word                 # pop the name (null)
CALL :heap_pop_B                    # pop the cluster back into B
CALL :heap_pop_D                    # pop the filesystem handle back into D
JMP .fat16_pathfind_synthesize

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

# Check for "." and ".." tokens (must compare bytes, not strings,
# because the assembler treats "." as a label prefix)
VAR global word $pathfind_token_addr
# A still holds the token address from above (heap_push_A at line 122)
# Save token address for later use
ALUOP_ADDR %A%+%AH% $pathfind_token_addr
ALUOP_ADDR %A%+%AL% $pathfind_token_addr+1
# Read first two bytes of token using D temporarily
PUSH_DH
PUSH_DL
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = token address
LDA_D_AH                            # AH = token[0]
INCR_D
LDA_D_AL                            # AL = token[1]
POP_DL
POP_DH
# Check if token[0] == '.' (0x2e)
LDI_BL 0x2e
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNE .pathfind_normal_token           # not a dot, process normally
# token[0] == '.', check token[1]
ALUOP_FLAGS %A%+%AL%
JZ .pathfind_skip_token              # token[1] == 0x00, token is "." -> skip
# token[1] != 0x00, check if token[1] == '.'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .pathfind_normal_token           # token[1] != '.', not ".." -> normal
# token[0..1] == "..", check token[2]
PUSH_DH
PUSH_DL
LD_DH $pathfind_token_addr
LD_DL $pathfind_token_addr+1
INCR_D
INCR_D                               # D = &token[2]
LDA_D_AL                             # AL = token[2]
POP_DL
POP_DH
ALUOP_FLAGS %A%+%AL%
JNZ .pathfind_normal_token           # token[2] != 0x00, not ".." -> normal
# Token is ".." -- check if at root (cluster B == 0x0000)
ALUOP_FLAGS %B%+%BH%
JNZ .pathfind_normal_token           # BH != 0, not at root -> let dir_find handle it
ALUOP_FLAGS %B%+%BL%
JNZ .pathfind_normal_token           # BL != 0, not at root -> let dir_find handle it
# At root, ".." -> skip (stay at root)

.pathfind_skip_token
# Discard the 3 heap values (name, cluster, fs_handle) and loop
CALL :heap_pop_word                  # pop the name
CALL :heap_pop_word                  # pop the cluster
CALL :heap_pop_word                  # pop the filesystem handle
JMP .fat16_pathfind_loop

.pathfind_normal_token
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
# Entry is already parsed to BE by dir_find; read cluster directly at offset 0x1A
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%                # save entry pointer for free
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%             # A = entry + 0x1A
LDA_A_BH                           # BH = cluster high byte (BE)
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                           # BL = cluster low byte
POP_AL
POP_AH                             # A = entry pointer restored
CALL :free                          # free the directory entry
# B = cluster number (correct byte order)
JMP .fat16_pathfind_loop
.next_token_null2
# next token is null, so the entry we found must be what
# we were looking for, so return it.
CALL :heap_push_D                   # since we're returning a directory entry, also push the filesystem handle
CALL :heap_push_A                   # return the directory entry, don't free it
JMP .fat16_pathfind_done

# All tokens consumed; B = target cluster, D = filesystem handle.
# Synthesize a 32-byte directory entry with attribute=0x10 (dir)
# and start_cluster=B, then return it like a normal match.
.fat16_pathfind_synthesize
# Save cluster to global (B needed for ALUOP16O_A below)
ALUOP_ADDR %B%+%BH% $pathfind_token_addr
ALUOP_ADDR %B%+%BL% $pathfind_token_addr+1
# Allocate 32 zeroed bytes (2 blocks)
LDI_AL 2
CALL :calloc_blocks                 # A = zeroed 32-byte entry
ALUOP_FLAGS %A%+%AH%
JZ .fat16_pathfind_notfound         # malloc failed
# Save entry base address on stack for return
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
# Write attribute = 0x10 (directory) at offset 0x0B
LDI_B 0x000b
ALUOP16O_A %ALU16_A+B%             # A = entry + 0x0B
LDI_BL 0x10
ALUOP_ADDR_A %B%+%BL%              # [entry+0x0B] = 0x10
# Restore entry base for cluster write
POP_AL
POP_AH
ALUOP_PUSH %A%+%AH%                # re-save for return
ALUOP_PUSH %A%+%AL%
# Write start_cluster at offset 0x1A (big-endian)
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%             # A = entry + 0x1A
LD_BH $pathfind_token_addr          # cluster high byte
ALUOP_ADDR_A %B%+%BH%              # [entry+0x1A] = cluster_hi
ALUOP16O_A %ALU16_A+1%             # A = entry + 0x1B
LD_BL $pathfind_token_addr+1        # cluster low byte
ALUOP_ADDR_A %B%+%BL%              # [entry+0x1B] = cluster_lo
# Restore entry base for heap push
POP_AL
POP_AH
# Return: push fs_handle and entry (same as normal success path)
CALL :heap_push_D                   # filesystem handle
CALL :heap_push_A                   # synthesized directory entry
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
CALL :free
JMP .pathfind_token_free_loop
.pathfind_token_free_loop_done
# free the main array
POP_AH                              # restore base address from above
POP_AL
CALL :free

.fat16_pathfind_final
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


