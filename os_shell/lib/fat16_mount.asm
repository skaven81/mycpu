# vim: syntax=asm-mycpu

# FAT16 filesystem functions: mount/umount

####
# Mount a FAT16 filesystem from an ATA device.
# To use this function:
#  1. Push address of a 128-byte memory region (malloc size 7) that has been zero'd
#  2. Push the high word of the filesystem start sector (usually 0)
#  3. Push the low word of the filesystem start sector (usually 0)
#  4. Push a byte for the ATA device ID (0/master or 1/slave)
#  5. Call :fat16_mount
#  6. Pop status byte from :ata_read command. If non-zero, stop.
#       0xfd - extmalloc failed
#       0xfe - sector does not appear to be a FAT16 boot sector
#       0xff - drive is not attached (ATA read error)
#       other - ATA read error (copy of the ata error register)
#  7. Unmount the filesystem by calling :fat16_unmount
#
# Data structure of the filesystem handle (128 bytes, malloc size 7):
#   Offset  Size  Type  Data
#   ---------------------------------------------
#   0x00    53    str   path of current directory, using / separators, up to four directories deep, null terminated
#   0x36    2     cls   cluster number of current directory, will be zero if the root directory
#   0x38    2     int   Bytes per Sector
#   0x3a    1     int   Sectors per Cluster
#   0x3b    2     int   Reserved Sectors from start of volume
#   0x3d    1     int   Number of FAT copies
#   0x3e    2     int   Number of possible root directory entries
#   0x40    4     int   Total number of sectors in filesystem
#   0x44    1     int   Media descriptor (This is the same value which must be in the low byte in the first entry of the FAT)
#   0x45    2     int   Sectors per FAT
#   0x47    4     lba   ReservedRegion start
#   0x4b    4     lba   FATRegion start
#   0x4f    4     lba   RootDirectoryRegion start
#   0x53    4     lba   DataRegion start
#   0x57    2     int   FATRegion size, in sectors
#   0x59    2     int   RootDirectoryRegion size, in sectors
#   0x5b    4     int   DataRegion size, in sectors (not implemented)
#   0x5f    1     int   ATA device ID (0=master/1=slave)
#   0x60    9     str   OEM ID
#   0x69    12    str   Volume Label
#   0x7b    5           Unused / future
:fat16_mount
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH

# Pop arguments off the heap, except for the target memory address
CALL :heap_pop_CL               # ATA ID
CALL :heap_pop_B                # low word of start sector
CALL :heap_pop_A                # high word of start sector
ALUOP_PUSH %A%+%AL%             # Save the start sector, we'll need it if ATA read is successful

# Get a 4k memory page in extended memory for scratch
CALL :extmalloc
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%
JZ .mount_abort_1               # Fail if we're out of memory
CALL :heap_push_AL
CALL :extpage_d_push            # Make D page use the allocated page
POP_AL                          # restore AL, so A+B are the start sector again

# Reset the device before attempting to mount; this helps
# for SD card swaps to ensure mounting works.
CALL :heap_push_CL              # drive ID
CALL :ata_reset
ALUOP_PUSH %A%+%AL%
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%
POP_AL
JNZ .mount_abort_4

# Save our starting sector number for later
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
# Save our ATA ID for later
PUSH_CL

# Read the requested sector into extended memory
LDI_D 0xd000
CALL :heap_push_D               # memory address
CALL :heap_push_A               # high word of LBA
CALL :heap_push_B               # low word of LBA
CALL :heap_push_CL              # drive ID
CALL :ata_read_lba
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%
JNZ .mount_abort_2

# Verify that this appears to be a FAT16 file system
LD_AL 0xd1fe                    # signature byte 1, should be 0x55
LDI_BL 0x55
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .mount_abort_3
LD_AL 0xd1ff                    # signature byte 2, should be 0xaa
LDI_BL 0xaa
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .mount_abort_3
ST 0xd03b 0x00                  # put a null terminator after the (supposedly) 'FAT16' filesystem type
LDI_C .str_fat16
LDI_D 0xd036
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JNZ .mount_abort_3

# Looks like a FAT16 filesystem so far...line up the RAM for the filesystem handle
CALL :heap_pop_A                # address in A

#### 0x00: Path of current directory: set to '/'
# Since the memory we write into is expected to be zero'd, this is naturally
# null-terminated by just writing the first byte.
LDI_CL '/'
STA_A_CL

#### 0x38: 2B  Bytes per Sector
LDI_B 0x0038
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd00c
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd00b
STA_B_CL

#### 0x3a: 1B  Sectors per Cluster
LDI_B 0x003a
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd00d
STA_B_CL

#### 0x3b: 2B  Reserved Sectors from start of volume
LDI_B 0x003b
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd00f
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd00e
STA_B_CL

#### 0x3d: 1B  Number of FAT copies
LDI_B 0x003d
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd010
STA_B_CL

#### 0x3e: 2B  Number of possible root directory entries
LDI_B 0x003e
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd012
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd011
STA_B_CL

#### 0x40: 4B  Total number of sectors in filesystem
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
LD_AH 0xd014            # small number of sectors
LD_AL 0xd013
ALUOP_FLAGS %A%+%AH%
JNZ .use_small_sectors
ALUOP_FLAGS %A%+%AL%
JNZ .use_small_sectors

.use_large_sectors      # small number of sectors was zero, so use the large number
POP_AH
POP_AL
LDI_B 0x0040
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd023
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd022
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd021
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd020
STA_B_CL
JMP .total_sectors_continue

.use_small_sectors      # small number of sectors was nonzero, so use the small number
POP_AH
POP_AL
LDI_B 0x0040
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR_B %zero%
LDI_B 0x0041
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR_B %zero%
LDI_B 0x0042
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd014
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd013
STA_B_CL

.total_sectors_continue

#### 0x44: 1B  Media descriptor (This is the same value which must be in the low byte in the first entry of the FAT)
.media_descriptor
LDI_B 0x0044
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd015
STA_B_CL

#### 0x45: 2B  Sectors per FAT
.sectors_per_fat
LDI_B 0x0045
ALUOP16O_B %ALU16_A+B%
LD_CL 0xd017
STA_B_CL
ALUOP16O_B %ALU16_B+1%
LD_CL 0xd016
STA_B_CL

#### 0x60: 9B  OEM ID
.oem_id
LDI_B 0x0060
ALUOP16O_B %ALU16_A+B%
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
LDI_C 0xd003
ALUOP_PUSH %A%+%AL%
LDI_AL 7 # copy (7+1) bytes
CALL :memcpy # C->D
POP_AL

#### 0x69: 12B Volume Label
.volume_label
LDI_B 0x0069
ALUOP16O_B %ALU16_A+B%
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
LDI_C 0xd02b
ALUOP_PUSH %A%+%AL%
LDI_AL 10 # copy (10+1) bytes
CALL :memcpy # C->D
POP_AL

#### 0x5f: 1B  ATA device ID (0=master/1=slave)
.device_id
LDI_B 0x005f
ALUOP16O_B %ALU16_A+B%
POP_CL                  # from push CL earlier
STA_B_CL

#### 0x47: 4B  ReservedRegion start (LBA) = VolumeStart
.reserved_region_start
LDI_B 0x0047
ALUOP16O_B %ALU16_A+B%
POP_CL                  # from push AH earlier
STA_B_CL
ALUOP16O_B %ALU16_B+1%
POP_CL                  # from push AL earlier
STA_B_CL
ALUOP16O_B %ALU16_B+1%
POP_CL                  # from push BH earlier
STA_B_CL
ALUOP16O_B %ALU16_B+1%
POP_CL                  # from push BL earlier
STA_B_CL

#### 0x4b: 4B  FATRegion start (LBA) = ReservedRegion + ReservedSectors
.fat_region_start
LDI_B 0x0047            # ReservedRegion start
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
ALUOP16O_B %ALU16_B+1%

CALL :heap_push_C       # push high word of ReservedRegion

LDI_C 0x0000
CALL :heap_push_C       # push high word of ReservedSectors

LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C       # push low word of ReservedRegion

LDI_B 0x003b            # Reserved Sectors
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C       # push low word of ReservedSectors

CALL :add32

CALL :heap_pop_C        # low word of result
LDI_B 0x004d            # low word of FAT Region start
ALUOP16O_B %ALU16_A+B%
STA_B_CH
ALUOP16O_B %ALU16_B+1%
STA_B_CL

CALL :heap_pop_C        # high word of result
LDI_B 0x004b            # high word of FAT Region start
ALUOP16O_B %ALU16_A+B%
STA_B_CH
ALUOP16O_B %ALU16_B+1%
STA_B_CL

#### 0x4f: 4B  RootDirectoryRegion start (LBA) = FATRegion + (NumberOfFATs * SectorsPerFAT)
.rootdir_region_start
LDI_B 0x0045            # Sectors per FAT
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C       # multiplicand (Sectors per FAT)

LDI_B 0x003d            # Num FATs
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
LDI_CH 0x00
CALL :heap_push_C       # multiplier (Num FATs)

CALL :mul16
CALL :heap_pop_D        # low word of result (FATregion size); keep high word of result on heap

# store FAT region size
LDI_B 0x0057
ALUOP16O_B %ALU16_A+B%
STA_B_DH
ALUOP16O_B %ALU16_B+1%
STA_B_DL

# Add FAT region size to FAT region start
LDI_B 0x004b
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
ALUOP16O_B %ALU16_B+1%
CALL :heap_push_C       # high word of FAT Region start

CALL :heap_push_D       # low word of multiplication result

LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C       # low word of FAT Region start

CALL :add32
CALL :heap_pop_D
CALL :heap_pop_C        # RootDirRegion start in C+D

LDI_B 0x004f
ALUOP16O_B %ALU16_A+B%
STA_B_CH
ALUOP16O_B %ALU16_B+1%
STA_B_CL
ALUOP16O_B %ALU16_B+1%
STA_B_DH
ALUOP16O_B %ALU16_B+1%
STA_B_DL

#### 0x36: 2B  cluster number of current directory (0 since it's the root directory and the root
####           directory is not in the data region and thus has no cluster number
.current_dir_cluster
LDI_B 0x0036            # current directory cluster
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR_B %zero%
ALUOP16O_B %ALU16_B+1%
ALUOP_ADDR_B %zero%

#### 0x53: 4B  DataRegion start (LBA) = RootDirectoryRegion + ((RootEntriesCount * 32) / BytesPerSector)
.data_region_start
LDI_B 0x003e
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL                # num root entries in C
MOV_CH_BH
MOV_CL_BL
CALL :shift16_b_right   # we assume 512 byte sectors to avoid having to do division.
CALL :shift16_b_right   # root entries * 32 -> shift left five
CALL :shift16_b_right   # result / 512 -> shift right nine
CALL :shift16_b_right   # net is shift right four
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
# store root directory region size from D
LDI_B 0x0059
ALUOP16O_B %ALU16_A+B%
STA_B_DH
ALUOP16O_B %ALU16_B+1%
STA_B_DL
# fetch RootDir Region start
LDI_B 0x004f
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
ALUOP16O_B %ALU16_B+1%

CALL :heap_push_C       # high word of rootdir region start
LDI_C 0x0000
CALL :heap_push_C       # high word of rootdir region size

LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C       # low word of rootdir region start
CALL :heap_push_D       # low word of rootdir region size

CALL :add32

CALL :heap_pop_D        # low word of result
CALL :heap_pop_C        # high word of result

# store data region start
LDI_B 0x0053
ALUOP16O_B %ALU16_A+B%
STA_B_CH
ALUOP16O_B %ALU16_B+1%
STA_B_CL
ALUOP16O_B %ALU16_B+1%
STA_B_DH
ALUOP16O_B %ALU16_B+1%
STA_B_DL


# Done, prepare to return
LDI_CL 0x00
CALL :heap_push_CL              # push OK status byte to heap
CALL :extpage_d_pop             # Restore D page to previous value, old value is on heap
CALL :extfree                   # free the page on the heap
JMP .mount_done

# abort vector if extmalloc failed
.mount_abort_1
CALL :heap_pop_word             # discard memory address argument
POP_AL
LDI_AL 0xfd
CALL :heap_push_AL
JMP .mount_done

# abort vector if ATA read failed
.mount_abort_2
CALL :heap_pop_word             # discard memory address argument
POP_TD                          # eject the saved sector address and ATA ID from the stack
POP_TD
POP_TD
POP_TD
POP_TD
CALL :heap_push_AL              # put the ATA error on the heap
CALL :extpage_d_pop             # Restore D page to previous value, old value is on heap
CALL :extfree                   # Free that page
JMP .mount_done

# abort vector if it doesn't look like a FAT16 filesystem
.mount_abort_3
CALL :heap_pop_word             # discard memory address argument
POP_TD                          # eject the saved sector address and ATA ID from the stack
POP_TD
POP_TD
POP_TD
POP_TD
LDI_AL 0xfe
CALL :heap_push_AL              # put the "not FAT16 filesystem" error on the heap
CALL :extpage_d_pop             # Restore D page to previous value, old value is on heap
CALL :extfree
JMP .mount_done

# abort vector if the drive reset failed
.mount_abort_4
CALL :heap_pop_word             # discard memory address argument
CALL :heap_push_AL              # Push non-zero status byte onto heap
CALL :extpage_d_pop             # Restore D page to previous value, old value is on heap
CALL :extfree                   # free the page on the heap
JMP .mount_done

.mount_done
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.str_fat16 "FAT16\0"

####
# Retrieve the ATA ID from a filesystem handle
#  1. Push the address of the handle
#  2. Call the function
#  3. Pop a byte that contains 0x0 or 0x1 (or garbage if the handle is corrupt)
:fat16_handle_get_ataid
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
CALL :heap_pop_B
LDI_A 0x005f
ALUOP16O_B %ALU16_A+B%
LDA_B_AL
CALL :heap_push_AL
POP_AL
POP_AH
POP_BL
POP_BH
RET

####
# Print a human-readable FAT16 filesystem descriptor
#  1. Push the address of the descriptor onto the heap
#  2. Call the function
:fat16_print
PUSH_CH
PUSH_CL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_A            # file descriptor base address in A

# Line 1
LDI_B 0x0060                # OEM ID
ALUOP16O_B %ALU16_A+B%
CALL :heap_push_B
LDI_B 0x0069                # Volume ID
ALUOP16O_B %ALU16_A+B%
CALL :heap_push_B
LDI_C .str_1
CALL :printf

# Line 2
LDI_B 0x0044                # Media descriptor
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x004a                # Last byte of ReservedRegion start
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL          # LSB byte
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 1
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 2
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_B 0x005f                # ATA ID
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL

LDI_C .str_2
CALL :printf

# Line 3
LDI_B 0x003a                # sectors per cluster
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x0038                # bytes per sector
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_C .str_3
CALL :printf

# Line 4
LDI_B 0x0043                # Total sectors in filesystem (LSB)
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL          # LSB byte
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 1
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 2
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_4
CALL :printf

# Line 5
LDI_B 0x003e                # root directory entries
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_B 0x003d                # num FAT copies
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x0045                # sectors per FAT
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_C .str_5
CALL :printf

# Line 6
LDI_B 0x003b                # reserved sectors at start
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_C .str_6
CALL :printf

# Line 7
LDI_B 0x0057                # FAT region size
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_B 0x004e                # FATRegion start (LSB)
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL          # LSB byte
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 1
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 2
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_7
CALL :printf

# Line 8
LDI_B 0x0059                # Root dir region size
ALUOP16O_B %ALU16_A+B%
LDA_B_CH
ALUOP16O_B %ALU16_B+1%
LDA_B_CL
CALL :heap_push_C

LDI_B 0x0052                # Root dir start (LSB)
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL          # LSB byte
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 1
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 2
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_8
CALL :printf

# Line 9
LDI_B 0x0056                # Data space start (LSB)
ALUOP16O_B %ALU16_A+B%
LDA_B_CL
CALL :heap_push_CL          # LSB byte
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 1
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # byte 2
ALUOP16O_B %ALU16_B-1%
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_9
CALL :printf

POP_BL
POP_BH
POP_AL
POP_AH
POP_CL
POP_CH
RET

.str_1 "FAT16 filesystem %s formatted by %s\n\0"
.str_2 "Mounted from ATA device %u at LBA 0x%x%x%x%x, media type 0x%x\n\0"
.str_3 "Bytes per sector: %U, Sectors per cluster: %u\n\0"
.str_4 "Total sectors in filesystem: 0x%x%x%x%x\n\0"
.str_5 "%U sectors per FAT, %u FAT copies, %U root directory entries\n\0"
.str_6 "Reserved sectors at start: %U\n\0"
.str_7 "FAT region start: 0x%x%x%x%x +%U sectors\n\0"
.str_8 "Root dir start:   0x%x%x%x%x +%U sectors\n\0"
.str_9 "Data space start: 0x%x%x%x%x\n\0"
