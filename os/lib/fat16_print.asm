# vim: syntax=asm-mycpu

#####
# fat16_print - print a human-readable FAT16 filesystem descriptor
#
# Evicted from the BIOS ROM (was the tail of os/bios/lib/fat16_mount.asm)
# because its only consumer was os/system/900-cmd_mount.asm. Symlink this
# file (and fat16_print.h) into any ODY build directory that needs it; it
# calls only BIOS-resident functions (:heap_pop_A, :heap_push_B,
# :heap_push_C, :heap_push_CL, :printf), so it links fine wherever it is
# compiled in.
#####

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
