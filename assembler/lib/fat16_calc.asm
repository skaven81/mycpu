# vim: syntax=asm-mycpu

# FAT16 filesystem functions: calculation routines

####
# Convert a FAT16 cluster number to its LBA address
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
CALL :incr16_a
LDA_A_BL
CALL :incr16_a

CALL :heap_push_C               # high word of multiplication result
CALL :heap_push_B               # high word of $DataRegionStart

LDA_A_BH                        # Low word of $DataRegionStart in B
CALL :incr16_a
LDA_A_BL

CALL :heap_push_D               # low word of multiplication result
CALL :heap_push_B               # low word of $DataRegionStart

CALL :add32

# Return (result is already on the heap in correct order

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
# a cluster can cover multiple LBA addresses.
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
CALL :incr16_a
LDA_A_BL                        # B contains high word of $DataRegionStart

# Push high words of $LBA and $DataRegionStart
CALL :heap_push_B               # high word of $DataRegionStart
CALL :heap_push_C               # high word of $LBA

# Push low words of $LBA and $DataRegionStart
CALL :incr16_a
LDA_A_BH
CALL :incr16_a
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

CALL :incr16_b
CALL :incr16_b                  # Add two to result

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
