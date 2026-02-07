# vim: syntax=asm-mycpu

# Function for loading a file from a FAT16 filesystem into memory.
# The file must be less than 64KiB in size; the high word of the
# file size will be ignored. In the future a different file reader
# will need to be written that can do incremental or partial loading
# of a larger file into (for example) extended memory. This one assumes
# a contiguous and fully available memory block to copy the file
# contents into, hence the 64KiB limit, as there's no way to directly
# address more than 64KiB of contiguous memory.  In fact, the Odyssey
# only has 20KiB of contiguous main memory, and can only address 8KiB
# of extended memory in a contiguous block by using both the D and E
# pages.  So a 16-bit file size is all that is necessary for this function.
#
# Files are loaded by sectors; the file size will be shifted right 9
# positions, plus one, to determine the number of sectors that will
# be read. This means that you must allocate memory in 512-byte chunks
# or else this function will write outside of allocated memory.

# Works by providing a directory entry handle, and a byte indicating the
# maximum number of 512-byte sectors to load, and a target address to write.
# The sector count is to allow truncated reads (usually for just reading
# the first sector of a file so its header can be examined; use zero
# to load the entire file).

# Typical usage:
#  * Push filesystem handle address (word)
#  * Push target address (word) to write the file into
#  * Push max sectors (0 to read entire file)
#  * Push directory entry handle (word)
#  * Call function
#  * Pop status byte, 0x00 = success, >0 is an ATA error
:fat16_readfile
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

######
# Extra state memory so we don't have to do so much
# stack juggling to get through this algorithm.
VAR global dword $fat16_readfile_lba
VAR global word $fat16_readfile_current_cluster
VAR global word $fat16_readfile_fs_handle
VAR global word $fat16_readfile_next_write_address
VAR global byte $fat16_readfile_total_sectors_remaining
VAR global byte $fat16_readfile_sectors_remaining_in_cluster
VAR global byte $fat16_readfile_sectors_per_cluster
VAR global byte $fat16_readfile_device_id

######
# Pop directory entry and get our current/starting cluster, store in D
######
CALL :heap_pop_A                # directory entry address in A
CALL :heap_push_A
CALL :fat16_dirent_cluster
CALL :heap_pop_D                # starting cluster in D
ST_DH $fat16_readfile_current_cluster
ST_DL $fat16_readfile_current_cluster+1

######
# Calculate the number of sectors to read. Start by retrieving the file size (the
# low word) and convert it to a number of sectors.  Then pop the max sectors byte
# and replace the file size derived count if nonzero.
######
CALL :heap_push_A               # push directory entry address
CALL :fat16_dirent_filesize
CALL :heap_pop_B                # low word of file size in B
CALL :heap_pop_word             # discard high word of file size
ALUOP_BH %B>>1%+%BH%            # BH contains number of sectors (bottom 9
ALUOP_BH %B+1%+%BH%             # bits discarded, plus one)
CALL :heap_pop_AL               # max sectors in AL
ALUOP_FLAGS %A%+%AL%
JZ .keep_filesize_sectors       # If max sectors=0, sector count in BH is OK
ALUOP_BH %A%+%AL%               # Else, use max_sectors count
.keep_filesize_sectors          # Sectors to load is now in BH
ALUOP_ADDR %B%+%BH% $fat16_readfile_total_sectors_remaining

######
# Pop target address into C and $fat16_readfile_next_write_address
######
CALL :heap_pop_C
ST_CH $fat16_readfile_next_write_address
ST_CL $fat16_readfile_next_write_address+1

######
# Pop filesystem handle and get sectors per cluster and device ID;
# store in $fat16_readfile_fs_handle and $fat16_readfile_sectors_per_cluster
######
CALL :heap_pop_A                # filesystem handle addr in A
ALUOP_ADDR %A%+%AH% $fat16_readfile_fs_handle
ALUOP_ADDR %A%+%AL% $fat16_readfile_fs_handle+1
LDI_B 0x003a                    # sectors per cluster offset
ALUOP16O_A %ALU16_A+B%                # A now points to sectors_per_cluster byte
LDA_A_BL                        # Load byte into BL
ALUOP_ADDR %B%+%BL% $fat16_readfile_sectors_per_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_sectors_remaining_in_cluster
LD_AH $fat16_readfile_fs_handle
LD_AL $fat16_readfile_fs_handle+1
LDI_B 0x005f                    # device ID offset
ALUOP16O_A %ALU16_A+B%                # A now points to sectors_per_cluster byte
LDA_A_BL                        # Load byte into BL
ALUOP_ADDR %B%+%BL% $fat16_readfile_device_id

######
# Begin cluster read loop
######
.cluster_read_loop
# Since we started a new cluster, reset the
# number of sectors per cluster counter
LD_DL $fat16_readfile_sectors_per_cluster
ST_DL $fat16_readfile_sectors_remaining_in_cluster

# $fat16_readfile_lba := fat16_cluster_to_lba($fat16_readfile_fs_handle, $fat16_readfile_current_cluster)
LD_DH $fat16_readfile_fs_handle
LD_DL $fat16_readfile_fs_handle+1
CALL :heap_push_D               # Push fs handle to heap
LD_DH $fat16_readfile_current_cluster
LD_DL $fat16_readfile_current_cluster+1
CALL :heap_push_D               # push cluster number to heap
CALL :fat16_cluster_to_lba      # 28-bit LBA address on heap
CALL :heap_pop_D                # low word of LBA address in D
ST_DL $fat16_readfile_lba+3
ST_DH $fat16_readfile_lba+2
CALL :heap_pop_D                # high word of LBA address in D
ST_DL $fat16_readfile_lba+1
ST_DH $fat16_readfile_lba+0

######
# Begin sector read loop
.sector_read_loop
LD_BH $fat16_readfile_total_sectors_remaining
ALUOP_FLAGS %B%+%BH%
JZ .cluster_read_done_noerrors  # if we've exhausted all the sectors in the file, we are done.

LD_BH $fat16_readfile_sectors_remaining_in_cluster
ALUOP_FLAGS %B%+%BH%
JZ .end_sector_read_loop        # if done with sectors in this cluster, break out of sector loop so we move to next cluster

# ata_read_lba(next_write_addr, $fat16_readfile_lba)
LD_CH $fat16_readfile_next_write_address
LD_CL $fat16_readfile_next_write_address+1
CALL :heap_push_C               # destination memory address
LD_DH $fat16_readfile_lba+0
LD_DL $fat16_readfile_lba+1
CALL :heap_push_D               # high word of LBA address
LD_DH $fat16_readfile_lba+2
LD_DL $fat16_readfile_lba+3
CALL :heap_push_D               # low word of LBA address
LD_DL $fat16_readfile_device_id
CALL :heap_push_DL              # device ID
CALL :ata_read_lba
CALL :heap_pop_AL               # status byte in AL
ALUOP_FLAGS %A%+%AL%
JNZ .abort_ata_error

# next_write_addr += 512
LD_AH $fat16_readfile_next_write_address
LD_AL $fat16_readfile_next_write_address+1
LDI_B 512
ALUOP16O_A %ALU16_A+B%
ALUOP_ADDR %A%+%AH% $fat16_readfile_next_write_address
ALUOP_ADDR %A%+%AL% $fat16_readfile_next_write_address+1

# total remaining_sectors--
LD_AL $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %A-1%+%AL% $fat16_readfile_total_sectors_remaining

# sect_per_cluster--
LD_AL $fat16_readfile_sectors_remaining_in_cluster
ALUOP_ADDR %A-1%+%AL% $fat16_readfile_sectors_remaining_in_cluster

# $fat16_readfile_lba++
LD_DH $fat16_readfile_lba+0
LD_DL $fat16_readfile_lba+1
CALL :heap_push_D               # high word of LBA
LD_DH $fat16_readfile_lba+2
LD_DL $fat16_readfile_lba+3
CALL :heap_push_D               # low word of LBA
CALL :incr32                    # incremented number on heap
CALL :heap_pop_D                # low word of result
ST_DL $fat16_readfile_lba+3
ST_DH $fat16_readfile_lba+2
CALL :heap_pop_D                # high word of result
ST_DL $fat16_readfile_lba+1
ST_DH $fat16_readfile_lba+0

JMP .sector_read_loop
# End sector read loop
######

.end_sector_read_loop
# if total_remaining_sectors = 0, we are done
LD_BH $fat16_readfile_total_sectors_remaining
ALUOP_FLAGS %B%+%BH%
JZ .cluster_read_done_noerrors  # Done if remaining sectors is zero

# if not done, we need to load our next cluster
# $fat16_readfile_current_cluster := fat16_next_cluster($fat16_readfile_fs_handle, $fat16_readfile_current_cluster)
LD_DH $fat16_readfile_fs_handle
LD_DL $fat16_readfile_fs_handle+1
CALL :heap_push_D               # push filesystem handle
LD_DH $fat16_readfile_current_cluster
LD_DL $fat16_readfile_current_cluster+1
CALL :heap_push_D               # push current cluster
CALL :fat16_next_cluster        # next cluster on heap
CALL :heap_pop_D
ST_DL $fat16_readfile_current_cluster+1
ST_DH $fat16_readfile_current_cluster

# Loop to read sectors from next cluster
JMP .cluster_read_loop

# If no errors, return 0x00 status byte
.cluster_read_done_noerrors
LDI_AL 0x00
CALL :heap_push_AL
.cluster_read_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.abort_ata_error
CALL :heap_push_AL
JMP .cluster_read_done

