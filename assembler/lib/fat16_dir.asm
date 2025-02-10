# vim: syntax=asm-mycpu

# Function set for walking a FAT16 directory.
#
# Usage:
#
#  1. Push the cluster number of the directory to enumerate (or 0 for the root dir)
#  2. Push the address of a filesystem handle
#  3. CALL :fat16_dirwalk_start
#  4. Pop the address of a 32-byte directory entry (it's up to caller to examine
#     the entry to see if it's valid, or the last directory entry)
#     - If address is 0x00nn, there was an error (nn will be the ATA error byte)
#  5. Use functions from fat16_dirent.asm to manipulate the directory entry
#  6. CALL :fat16_dirwalk_next
#     - Same return semantics as :fat16_dirwalk_start
#  7. CALL :fat16_dirwalk_end to free the allocated memory
#
# Note: these functions are not recursive-safe due to the use of global vars
# to store the directory entry data.

VAR global word $dirwalk_current_fs_handle
VAR global dword $dirwalk_next_sector_lba
VAR global word $dirwalk_current_sector_data
VAR global byte $dirwalk_current_dir_idx
VAR global byte $dirwalk_num_sectors_remaining

:fat16_dirwalk_start
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Allocate 512 bytes of memory and store address in $dirwalk_current_sector_data
LDI_AL 31                           # malloc size 31=512 bytes
CALL :malloc                        # address in A
ALUOP_ADDR %A%+%AH% $dirwalk_current_sector_data
ALUOP_ADDR %A%+%AL% $dirwalk_current_sector_data+1

# Pop filesystem handle address and store in $dirwalk_current_fs_handle
CALL :heap_pop_A
LDI_C $dirwalk_current_fs_handle
ALUOP_ADDR_C %A%+%AH%
INCR_C
ALUOP_ADDR_C %A%+%AL%
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # Save filesystem handle address in D for later

# Pop the cluster number of the directory into A
CALL :heap_pop_A
# and save a copy of it in C for later
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%

# If cluster number is zero, we're enumerating the root directory,
# otherwise it's a sub-directory.
ALUOP_FLAGS %A%+%AH%
JNZ .dirwalk_start_subdir
ALUOP_FLAGS %A%+%AL%
JNZ .dirwalk_start_subdir

# If here, cluster=0, so set the starting LBA as the root dir LBA,
# and the max sectors based on the number of root directory entries.
LDI_C $dirwalk_current_fs_handle    # put address of FS handle into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
LDI_B 0x004f                        # 0x4f = RootDirectoryRegionStart
CALL :add16_to_b                    # B = LBA of RootDirectoryRegionStart
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%                   # C = source address
LDI_D $dirwalk_next_sector_lba   # D = dest address
LDI_AL 3                            # copy four bytes
CALL :memcpy                        # $dirwalk_next_sector_lba contains LBA addr of root dir

LDI_B 0x0060                        # 0x59 = num root dir sectors; we only use the low byte so 0x60
CALL :add16_to_b                    # B = addr of # root entries word
LDA_B_AL                            # A = num root dir sectors (we assume <= 255)
ALUOP_ADDR %A%+%AL% $dirwalk_num_sectors_remaining

JMP .dirwalk_start_lba_done

# If here, cluster>0, so set the starting LBA as the LBA of the cluster,
# and the max sectors based on the number of sectors per cluster
.dirwalk_start_subdir
CALL :heap_push_D                   # filesystem handle
CALL :heap_push_A                   # cluster number
CALL :fat16_cluster_to_lba
CALL :heap_pop_B                    # B=low word of LBA
CALL :heap_pop_A                    # A=high word of LBA
LDI_D $dirwalk_next_sector_lba   # Write LBA to $dirwalk_next_sector_lba
ALUOP_ADDR_D %A%+%AH%               # |
INCR_D                              # |
ALUOP_ADDR_D %A%+%AL%               # |
INCR_D                              # |
ALUOP_ADDR_D %B%+%BH%               # |
INCR_D                              # |
ALUOP_ADDR_D %B%+%BL%               # |

LDI_C $dirwalk_current_fs_handle    # put address of FS handle into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
LDI_B 0x003a                        # 0x3a = Sectors per cluster
CALL :add16_to_b                    # B = addr of sectors per cluster
LDA_B_AL                            # AL = num sectors
ALUOP_ADDR %A%+%AL% $dirwalk_num_sectors_remaining

.dirwalk_start_lba_done
# We now have:
#  $dirwalk_current_sector_data (word) set to a 512-byte memory region
#  $dirwalk_current_fs_handle (word) set to active fs handle
#  $dirwalk_next_sector_lba (dword) set to first LBA of directory
#  $dirwalk_num_sectors_remaining (byte) set to max number of sectors we should read

# We now need to read the first sector of the directory and initialize
# $dirwalk_current_dir_idx to zero. This also increments
# $dirwalk_next_sector_lba to prepare for the next ATA read.
CALL .dirwalk_read_next_sector
CALL :heap_pop_AL                   # ATA read status byte
ALUOP_FLAGS %A%+%AL%
JZ .dirwalk_start_success

# If we are here, there was an ATA read error, so we need
# to return 0x00nn to indicate an ATA error.
LDI_AL 0x00
CALL :heap_push_A
JMP .dirwalk_start_return

# If we are here, everything worked and we are ready to
# start enumerating directory entries
.dirwalk_start_success
LDI_C $dirwalk_current_sector_data  # Get address of sector data into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push address, as this is the first directory entry

.dirwalk_start_return
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


####
# .dirwalk_read_next_sector: reads the sector in $dirwalk_next_sector_lba
# Sets $dirwalk_current_dir_idx to zero.
# Decrements $dirwalk_num_sectors_remaining.
# Increments $dirwalk_next_sector_lba.
# Returns the ATA read status byte on the heap.
.dirwalk_read_next_sector
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Set offset to zero so we'll point at first directory entry
ALUOP_ADDR %zero% $dirwalk_current_dir_idx

# Decrement $dirwalk_num_sectors_remaining
LD_AL $dirwalk_num_sectors_remaining
ALUOP_ADDR %A-1%+%AL% $dirwalk_num_sectors_remaining

# Load next sector into $dirwalk_current_sector_data
LDI_C $dirwalk_current_sector_data  # put address of sector data into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push sector data address

LDI_C $dirwalk_next_sector_lba      # put LBA high word into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push LBA high word

INCR_C                              # put LBA low word into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push LBA low word

LDI_C $dirwalk_current_fs_handle    # put address of FS handle into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
LDI_B 0x005f                        # 0x5f = ATA device ID
CALL :add16_to_b                    # B = addr of device ID
LDA_B_AL                            # AL = device ID
CALL :heap_push_AL                  # Push device ID

CALL :ata_read_lba                  # Read 512 bytes; status byte is on top of heap

# Increment $dirwalk_next_sector_lba
LDI_C $dirwalk_next_sector_lba      # put LBA high word into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push LBA high word

INCR_C                              # put LBA low word into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
CALL :heap_push_A                   # Push LBA low word

CALL :incr32

CALL :heap_pop_A                    # Low word of result
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+3
ALUOP_ADDR %A%+%AH% $dirwalk_next_sector_lba+2
CALL :heap_pop_A                    # High word of result
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+1
ALUOP_ADDR %A%+%AH% $dirwalk_next_sector_lba

POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


# Returns the next directory entry, and loads the next sector
# if we run past the end of the current sector.
:fat16_dirwalk_next
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Increment $dirwalk_current_dir_idx
LD_AL $dirwalk_current_dir_idx
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $dirwalk_current_dir_idx

# If >=16, we need to load another sector
LDI_BL 15
ALUOP_FLAGS %B-A%+%BL%+%AL%         # overflow means >= 16
JNO .dirwalk_next_no_new_sector

# If we are here, $dirwalk_current_dir_idx is >= 16 and so
# we need to load the next sector. This also:
#   Sets $dirwalk_current_dir_idx to zero.
#   Decrements $dirwalk_num_sectors_remaining.
#   Increments $dirwalk_next_sector_lba.
CALL .dirwalk_read_next_sector
CALL :heap_pop_AL                   # ATA read status byte
ALUOP_FLAGS %A%+%AL%
JZ .dirwalk_next_no_new_sector      # safe to jump here because now idx=0

# If we are here, there was an ATA read error, so we need
# to return 0x00nn to indicate an ATA error.
LDI_AL 0x00
CALL :heap_push_A
JMP .dirwalk_next_return

.dirwalk_next_no_new_sector
# If we are here, $dirwalk_current_dir_idx is <= 15
# so all we need to do is return the offset into
# $dirwalk_current_sector_data
LDI_C $dirwalk_current_sector_data  # put address of sector data into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
LDI_BH 0x00
LD_BL $dirwalk_current_dir_idx      # current offset (incremented above) into BL
CALL :shift16_b_left                # multiply index by 32 (shift left 5)
CALL :shift16_b_left                # |
CALL :shift16_b_left                # |
CALL :shift16_b_left                # |
CALL :shift16_b_left                # |
CALL :add16_to_a                    # A now contains the memory address of the next dirent
CALL :heap_push_A

.dirwalk_next_return
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

# Frees the memory allocated in the _start function
:fat16_dirwalk_end
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

LDI_C $dirwalk_current_sector_data  # put address of sector data into A
LDA_C_AH                            # |
INCR_C                              # |
LDA_C_AL                            # |
LDI_BL 31                           # size 31=512 bytes
CALL :free                          # Free the memory

# Zero the sector data address for good measure
ALUOP_ADDR %zero% $dirwalk_current_sector_data
ALUOP_ADDR %zero% $dirwalk_current_sector_data+1

POP_CL
POP_CH
POP_BL
POP_AL
POP_AH
RET
