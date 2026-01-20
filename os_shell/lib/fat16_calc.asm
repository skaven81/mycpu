# vim: syntax=asm-mycpu

# FAT16 filesystem functions: calculation routines

####
# Convert a FAT16 cluster number to its LBA address. If a cluster number
# of zero is given, will return the LBA address of the root directory.
# To use:
#  1. Push the address word of a FAT16 filesystem handle
#  2. Push the cluster number word to be converted
#  3. Call the function
#  4. Pop the low word of LBA address
#  5. Pop the high word of the LBA address
:fat16_cluster_to_lba
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Formula is $DataRegionStart + ((N - 2) * $SectorsPerCluster
# $DataRegionStart is a 32-bit value at offset 0x53 in the filesystem handle
# $SectorsPerCluster is an 8-bit value at offset 0x3a in the filesystem handle
# N is a 16-bit value

CALL :heap_pop_C                # Pop the cluster number

# If the cluster number is zero, then we're actually asking for the root dir address
MOV_CH_BH
MOV_CL_BL
ALUOP_FLAGS %B%+%BH%
JNZ .regular_cluster
ALUOP_FLAGS %B%+%BL%
JZ .return_root_dir_sector
.regular_cluster
DECR_C                          # Subtract 2
DECR_C

# Fetch $SectorsPerCluster and push word to heap (multiplier)
CALL :heap_pop_B                # Pop the filesystem handle address into B
LDI_A 0x003a                    # Offset of $SectorsPerCluster
CALL :add16_to_a                # A has address of $SectorsPerCluster
LDA_A_DL                        # DL has $SectorsPerCluster
LDI_DH 0x00                     # Make D a full 16-bit number

CALL :heap_push_C               # Push (N-2) to heap (multiplicand)

# Multiply by (N-2)
CALL :heap_push_D               # Push $SectorsPerCluster (multiplier)
CALL :mul16                     # 32-bit result is on heap
CALL :heap_pop_D                # low word of result
CALL :heap_pop_C                # high word of result

# Fetch $DataRegionStart
LDI_A 0x0053                    # Offset of $DataRegionStart
CALL :add16_to_a                # A has address of $DataRegionStart (32 bit)
LDA_A_BH                        # High word of $DataRegionStart in B
ALUOP16O_A %ALU16_A+1%
LDA_A_BL
ALUOP16O_A %ALU16_A+1%

CALL :heap_push_C               # high word of multiplication result
CALL :heap_push_B               # high word of $DataRegionStart

LDA_A_BH                        # Low word of $DataRegionStart in B
ALUOP16O_A %ALU16_A+1%
LDA_A_BL

CALL :heap_push_D               # low word of multiplication result
CALL :heap_push_B               # low word of $DataRegionStart

CALL :add32
JMP .cluster_to_lba_done        # Return (result is already on the heap in correct order)

# If the cluster given was zero, just return the sector number of the root directory.
.return_root_dir_sector
CALL :heap_pop_B                # Pop the filesystem handle address into B
LDI_A 0x004f                    # Offset of $RootDirectoryRegionStart
CALL :add16_to_a                # A has address of $RootDirectoryRegionStart
LDA_A_CH
ALUOP16O_A %ALU16_A+1%
LDA_A_CL                        # C has high word of $RootDirectoryRegionStart
ALUOP16O_A %ALU16_A+1%
LDA_A_DH
ALUOP16O_A %ALU16_A+1%
LDA_A_DL                        # D has low word of $RootDirectoryRegionStart
ALUOP16O_A %ALU16_A+1%

CALL :heap_push_C               # high word
CALL :heap_push_D               # low word

# Return
.cluster_to_lba_done
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
# Convert a LBA address to a FAT16 cluster number. Note that
# a cluster can cover multiple LBA addresses. Also note that
# LBA addresses before $DataRegionStart will return invalid data.
# To use:
#  1. Push the address word of a FAT16 filesystem handle
#  2. Push the high word of the LBA address
#  3. Push the low word of the LBA address
#  4. Call the function
#  5. Pop the resulting cluster number
:fat16_lba_to_cluster
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Formula is (($LBA - $DataRegionStart)/$SectorsPerCluster)+2
# Note that $SectorsPerCluster may only be 1, 2, 4, 8, 16, 32, or 128. So
# we don't actually need to do proper division; we can just shift until
# $SectorsPerCluster is 1.

CALL :heap_pop_D                # Pop low word of LBA address
CALL :heap_pop_C                # Pop high word of LBA address

CALL :heap_pop_B                # Pop address of filesystem handle

# retrieve $DataRegionStart
LDI_A 0x0053                    # Offset of $DataRegionStart
CALL :add16_to_a                # A contains address of $DataRegionStart
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%             # Remember address of filesystem handle
LDA_A_BH
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # B contains high word of $DataRegionStart

# Push high words of $LBA and $DataRegionStart
CALL :heap_push_B               # high word of $DataRegionStart
CALL :heap_push_C               # high word of $LBA

# Push low words of $LBA and $DataRegionStart
ALUOP16O_A %ALU16_A+1%
LDA_A_BH
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # B contains low word of $DataRegionStart

CALL :heap_push_B               # low word of $DataRegionStart
CALL :heap_push_D               # low word of $LBA

CALL :sub32                     # Heap now has ($LBA - $DataRegionStart)

# retrieve $SectorsPerCluster
LDI_A 0x003a                    # Offset of $SectorsPerCluster
POP_BL
POP_BH                          # B has restored filesystem handle address
CALL :add16_to_a                # A contains address of $SectorsPerCluster
LDA_A_CL                        # CL = $SectorsPerCluster

# Pop stuff we'll be shifting into A and B
CALL :heap_pop_B                # low word of ($LBA - $DataRegionStart)
CALL :heap_pop_A                # high word of ($LBA - $DataRegionStart)

# Loop, shifting B and A and $SectorsPerCluster right until $SectorsPerCluster is 0x01
.lba_to_cluster_div_loop
ALUOP_PUSH %A%+%AL%
MOV_CL_AL                       # AL = $SectorsPerCluster
ALUOP_FLAGS %A-1%+%AL%          # If result is zero, then $SectorsPerCluster was 1
JZ .lba_to_cluster_div_done     # If not, shift AL right and store it back to CL
ALUOP_CL %A>>1%+%AL%
POP_AL                          # Restore processing number from stack

CALL :shift16_b_right           # Shift low word of result right
ALUOP_PUSH %B%+%BL%
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%     # Check if LSB of high word is set
JZ .lba_to_cluster_shift_nocarry
LDI_BL 0x80
ALUOP_AH %A|B%+%BL%+%AH%        # Set MSB of low word if so
.lba_to_cluster_shift_nocarry
POP_BL                          # Restore processing number from stack
CALL :shift16_a_right           # Shift high word of result right
JMP .lba_to_cluster_div_loop

.lba_to_cluster_div_done
POP_AL                          # Restore AL from stack; A should be 0 and B should contain our result

ALUOP16O_B %ALU16_B+1%
ALUOP16O_B %ALU16_B+1%                  # Add two to result

CALL :heap_push_B               # Push final result to heap

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
# Return the next cluster number, given a current cluster number, by
# reading the FAT and returning the value at the offset given by the
# cluster number.
#
# For reference, a "next cluster" has the following meanings:
#   * 0x0000 - free
#   * 0x0001 - not allowed
#   * 0x0002 - not allowed
#   * 0x0003-0xffef - next cluster number
#   * 0xfff7 - one or more bad sectors in this cluster
#   * 0xfff8-0xffff - end of file
# a cluster can cover multiple LBA addresses. Also note that
#
# To use:
#  1. Push the address word of a FAT16 filesystem handle
#  2. Push the word of the current cluster
#  3. Call the function
#  4. Pop the next cluster number
#
# Will return 0x0001 if there was an error reading the ATA device
:fat16_next_cluster
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                # Pop the cluster number and store on stack for later
PUSH_CL
PUSH_CH

# We need to know which sector within the FAT to load from disk.
#
# Formula is $FATRegionStart + (N / 2 * BytesPerSector)
# We assume BytesPerSector is 512, which means we need to
# divide N by 256 == shift right 8 places, which actually
# just means we want to add the high byte of the cluster number
# to $FATRegionStart to get the LBA address.
#
# The low byte of the cluster number * 2 tells us the offset
# within the sector to read

CALL :heap_pop_B                # Pop the filesystem handle address into B
LDI_A 0x005f                    # Offset of $ATAdeviceID
CALL :add16_to_a                # A has address of $ATAdeviceID
LDA_A_DL                        # DL has $ATAdeviceID

LDI_A 0x004b                    # Offset of $FATRegionStart
CALL :add16_to_a                # A has address of $ATAdeviceID
LDA_A_CH
ALUOP16O_A %ALU16_A+1%
LDA_A_CL                        # C has high word of $FATRegionStart

CALL :heap_push_C               # high word of $FATRegionStart

LDI_C 0x0000
CALL :heap_push_C               # high word of cluster number / 256

ALUOP16O_A %ALU16_A+1%
LDA_A_CH
ALUOP16O_A %ALU16_A+1%
LDA_A_CL                        # C has low word of $FATRegionStart

CALL :heap_push_C               # low word of $FATRegionStart

LDI_CH 0x00
POP_CL                          # Cluster number high byte in CL
CALL :heap_push_C               # low word of cluster number / 256

CALL :add32                     # LBA of FAT sector is on the heap
CALL :heap_pop_C                # low word of LBA
CALL :heap_pop_A                # high word of LBA

# Allocate an extended memory page at 0xe000
CALL :extmalloc                 # allocated page is on heap
CALL :extpage_e_push            # make that the active E page

# Read FAT sector into 0xe000
LDI_B 0xe000
CALL :heap_push_B               # address of memory segment

CALL :heap_push_A               # high LBA address
CALL :heap_push_C               # low LBA address
CALL :heap_push_DL              # ATA ID
CALL :ata_read_lba
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JNZ .next_cluster_ata_err

# Add 2x low byte of cluster to extended memory address
LDI_AH 0x00
POP_AL                          # Pop low byte of cluster number
CALL :shift16_a_left

LDI_B 0xe000
CALL :add16_to_b                # B contains address of cluster

# Read memory at that address and return it
LDA_B_AL
ALUOP16O_B %ALU16_B+1%
LDA_B_AH
CALL :heap_push_A
JMP .next_cluster_done

.next_cluster_ata_err
POP_TD                          # Pop low byte of cluster number and discard
LDI_C 0x0001                    # Return value 0x0001 = ATA error
CALL :heap_push_C

.next_cluster_done
CALL :extpage_e_pop             # restore previous E page; current page on heap
CALL :extfree                   # Free the extended memory page on heap
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET
