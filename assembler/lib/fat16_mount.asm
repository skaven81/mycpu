# vim: syntax=asm-mycpu

# FAT16 filesystem functions: mount/umount

####
# Mount a FAT16 filesystem from an ATA device.
# To use this function:
#  1. Push the high word of the filesystem start sector
#  2. Push the low word of the filesystem start sector
#  3. Push a byte for the ATA device ID (0/master or 1/slave)
#  4. Call :fat16_mount
#  5. Pop status byte from :ata_read command. If non-zero, stop.
#       0xff - extmalloc failed
#       0xfe - sector does not appear to be a FAT16 boot sector
#       other - ATA read error (copy of the ata error register)
#  6. Pop word containing memory address of filesystem handle
#       Use this address when calling other fat16_* functions
#  7. Unmount the filesystem by calling :fat16_unmount
#
# Data structure of the filesystem handle (128 bytes, malloc size 7):
#   Offset  Size  Type  Data
#   ---------------------------------------------
#   0x00    53    str   path of current directory, using / separators, up to four directories deep
#   0x36    2     cls   cluster number of current directory
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
#   0x5b    4     int   DataRegion size, in sectors
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
LD_CL %d_page%
PUSH_CL

# Pop arguments off the heap
CALL :heap_pop_CL               # ATA ID
CALL :heap_pop_B                # low word of start sector
CALL :heap_pop_A                # high word of start sector
ALUOP_PUSH %A%+%AL%             # Save the start sector, we'll need it if ATA read is successful

# Get a 4k memory page in extended memory for scratch
CALL :extmalloc
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%
JZ .mount_abort_1               # Fail if we're out of memory
ALUOP_ADDR %A%+%AL% %d_page%    # Our memory page is at 0xd000
POP_AL                          # restore AL, so A+B are the start sector again

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

# Looks like a FAT16 filesystem so far...allocate the RAM for the filesystem handle
LDI_AL 0x07                     # size 7 = 128 bytes
CALL :calloc                    # address in A

# 0x00: Path of current directory: set to '/'
LDI_CL '/'
STA_A_CL                        # memory is zeroed so this is already null terminated

# 0x38: 2B  Bytes per Sector
LDI_B 0x0038
CALL :add16_to_b
LD_CL 0xd00c
STA_B_CL
CALL :incr16_b
LD_CL 0xd00b
STA_B_CL

# 0x3a: 1B  Sectors per Cluster
LDI_B 0x003a
CALL :add16_to_b
LD_CL 0xd00d
STA_B_CL

# 0x3b: 2B  Reserved Sectors from start of volume
LDI_B 0x003b
CALL :add16_to_b
LD_CL 0xd00f
STA_B_CL
CALL :incr16_b
LD_CL 0xd00e
STA_B_CL

# 0x3d: 1B  Number of FAT copies
LDI_B 0x003d
CALL :add16_to_b
LD_CL 0xd010
STA_B_CL

# 0x3e: 2B  Number of possible root directory entries
LDI_B 0x003e
CALL :add16_to_b
LD_CL 0xd012
STA_B_CL
CALL :incr16_b
LD_CL 0xd011
STA_B_CL

# 0x40: 4B  Total number of sectors in filesystem
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
CALL :add16_to_b
LD_CL 0xd023
STA_B_CL
CALL :incr16_b
LD_CL 0xd022
STA_B_CL
CALL :incr16_b
LD_CL 0xd021
STA_B_CL
CALL :incr16_b
LD_CL 0xd020
STA_B_CL
JMP .total_sectors_continue

.use_small_sectors      # small number of sectors was nonzero, so use the small number
POP_AH
POP_AL
LDI_B 0x0042
CALL :add16_to_b
LD_CL 0xd014
STA_B_CL
CALL :incr16_b
LD_CL 0xd013
STA_B_CL

.total_sectors_continue

# 0x44: 1B  Media descriptor (This is the same value which must be in the low byte in the first entry of the FAT)
LDI_B 0x0044
CALL :add16_to_b
LD_CL 0xd015
STA_B_CL

# 0x45: 2B  Sectors per FAT
LDI_B 0x0045
CALL :add16_to_b
LD_CL 0xd017
STA_B_CL
CALL :incr16_b
LD_CL 0xd016
STA_B_CL

# 0x60: 9B  OEM ID
LDI_B 0x0060
CALL :add16_to_b
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
LDI_C 0xd003
ALUOP_PUSH %A%+%AL%
LDI_AL 7 # copy (7+1) bytes
CALL :memcpy # C->D
POP_AL

# 0x69: 12B Volume Label
LDI_B 0x0069
CALL :add16_to_b
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
LDI_C 0xd02b
ALUOP_PUSH %A%+%AL%
LDI_AL 10 # copy (10+1) bytes
CALL :memcpy # C->D
POP_AL

# 0x5f: 1B  ATA device ID (0=master/1=slave)
LDI_B 0x005f
CALL :add16_to_b
POP_CL                  # from push CL earlier
STA_B_CL

# 0x47: 4B  ReservedRegion start (LBA) = VolumeStart
LDI_B 0x0047
CALL :add16_to_b
POP_CL                  # from push AH earlier
STA_B_CL
CALL :incr16_b
POP_CL                  # from push AL earlier
STA_B_CL
CALL :incr16_b
POP_CL                  # from push BH earlier
STA_B_CL
CALL :incr16_b
POP_CL                  # from push BL earlier
STA_B_CL

# 0x4b: 4B  FATRegion start (LBA) = ReservedRegion + ReservedSectors
### TODO: add32 ReservedRegion + ReservedSectors
LDI_B 0x0047            # ReservedRegion start
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :incr16_b

CALL :heap_push_C       # push high word of ReservedRegion

LDI_C 0x0000
CALL :heap_push_C       # push high word of ReservedSectors

LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C       # push low word of ReservedRegion

LDI_B 0x003b            # Reserved Sectors
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C       # push low word of ReservedSectors

CALL :add32

CALL :heap_pop_C        # low word of result
LDI_B 0x004d            # low word of FAT Region start
CALL :add16_to_b
STA_B_CH
CALL :incr16_b
STA_B_CL

CALL :heap_pop_C        # high word of result
LDI_B 0x004b            # high word of FAT Region start
CALL :add16_to_b
STA_B_CH
CALL :incr16_b
STA_B_CL

# 0x4f: 4B  RootDirectoryRegion start (LBA) = FATRegion + (NumberOfFATs * SectorsPerFAT)
### TODO: mul 8x16
### TODO: add32

# 0x53: 4B  DataRegion start (LBA) = RootDirectoryRegion + ((RootEntriesCount * 32) / BytesPerSector)
### TODO: shift16 RootEntriesCount << 5
### TODO: div16 / 0x200 (can be done with shifting)
### TODO: add32

# 0x57: 2B  FATRegion size (in sectors) = NumberOfFATs * SectorsPerFAT
### TODO: mul 8x16

# 0x59: 2B  RootDirectoryRegion size (in sectors) = (RootEntiesCount * 32) / BytesPerSector (Remember to round up, if there is a remainder)
### TODO: If RootEntriesCount == BytesPerSector, then == 32 sectors, don't need division
### TODO: shift16 RootEntriesCount << 5
### TODO: div16 / BytesPerSector, round up

# 0x5b: 4B  DataRegion size (in sectors) = TotalNumberOfSectors - (ReservedRegion_Size + FATRegion_Size + RootDirectoryRegion_Size)
### TODO: sub32
### TODO: add32

# 0x36: 2B  cluster number of current directory (== RootDirectoryRegion start, as cluster number)
### TODO: lba2cluster

# Done, prepare to return
CALL :heap_push_A               # push address of filesystem handle to heap
LDI_CL 0x00
CALL :heap_push_CL              # push OK status byte to heap
JMP .mount_done

# abort vector if extmalloc failed
.mount_abort_1
POP_AL
LDI_AL 0xff
CALL :heap_push_AL
JMP .mount_done

# abort vector if ATA read failed
.mount_abort_2
POP_TD                          # eject the saved sector address and ATA ID from the stack
POP_TD
POP_TD
POP_TD
POP_TD
CALL :heap_push_AL              # put the ATA error on the heap
LD_AL %d_page%                  # free our extended memory allocation
CALL :heap_push_AL
CALL :extfree
JMP .mount_done

# abort vector if it doesn't look like a FAT16 filesystem
.mount_abort_3
POP_TD                          # eject the saved sector address and ATA ID from the stack
POP_TD
POP_TD
POP_TD
POP_TD
LDI_AL 0xfe
CALL :heap_push_AL              # put the "not FAT16 filesystem" error on the heap
LD_AL %d_page%                  # free our extended memory allocation
CALL :heap_push_AL
CALL :extfree
JMP .mount_done

.mount_done
POP_CL
ST_CL %d_page%
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
CALL :add16_to_b
CALL :heap_push_B
LDI_B 0x0069                # Volume ID
CALL :add16_to_b
CALL :heap_push_B
LDI_C .str_1
CALL :printf

# Line 2
LDI_B 0x0044                # Media descriptor
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x004a                # Last byte of ReservedRegion start
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_B 0x005f                # ATA ID
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL

LDI_C .str_2
CALL :printf

# Line 3
LDI_B 0x003a                # sectors per cluster
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x0038                # bytes per sector
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_C .str_3
CALL :printf

# Line 4
LDI_B 0x0043                # Total sectors in filesystem (LSB)
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_4
CALL :printf

# Line 5
LDI_B 0x003e                # root directory entries
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_B 0x003d                # num FAT copies
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL

LDI_B 0x0045                # sectors per FAT
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_C .str_5
CALL :printf

# Line 6
LDI_B 0x003b                # reserved sectors at start
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_C .str_6
CALL :printf

# Line 7
LDI_B 0x0057                # FAT region size
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_B 0x004e                # FATRegion start (LSB)
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_7
CALL :printf

# Line 8
LDI_B 0x0059                # Root dir region size
CALL :add16_to_b
LDA_B_CH
CALL :incr16_b
LDA_B_CL
CALL :heap_push_C

LDI_B 0x0052                # Root dir start (LSB)
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_C .str_8
CALL :printf

# Line 9
LDI_B 0x005e                # Data space size (LSB)
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # MSB byte

LDI_B 0x0056                # Data space start (LSB)
CALL :add16_to_b
LDA_B_CL
CALL :heap_push_CL          # LSB byte
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 1
CALL :decr16_b
LDA_B_CL
CALL :heap_push_CL          # byte 2
CALL :decr16_b
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
.str_9 "Data space start: 0x%x%x%x%x +0x%x%x%x%x\n\0"
