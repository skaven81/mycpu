# vim: syntax=asm-mycpu

# Primitive memory allocator: malloc() and free().  Uses a first-fit approach.
#
# Terminology:
#  * range: the area of RAM set aside for the memory allocator
#  * segment: 128 bytes, the smallest unit of range
#  * block: 16 bytes, the smallest unit of allocation (1/8 of a segment)
#  * ledger: bytes at the beginning of the range indicating free/allocated status
#
# Begin by initializing the range that will be used by the allocator by calling malloc_init.
# Initialization happens in 128-byte segments.  Up to 256 segments (32KiB) may be allocated
# into the memory manager (though in practice the range will likely be somewhere around
# 20KiB).
#
# The beginning of the range is used for the ledger. Each bit in the ledger represents
# a 16-byte block. So each 128-byte allocated segment is represented by one byte (16 x 8 = 128)
# The ledger begins at the beginning of the range, so the blocks used by the ledger are marked
# as "used" during initialization.
#
# So we initialize by noting:
#   * address of the beginning of the range (ex. 0x6000)
#   * number of 128-byte segments to allocate (ex. 0x40 (64) -> 8KiB allocation / 512 blocks)
#
# With this, we know how many bytes we need for the ledger (it's the same as the number of
# 128-byte segments we allocated, in this case 0x40 (64).  The actual memory allocations start
# immediately after the ledger.
#
# In our example, the ledger is initialized like so:
#
# |0x6000  |0x6001  |0x6002  |0x6003  |0x6004  |...|0x603f  |0x6040  |
# |11110000|00000000|00000000|00000000|00000000|...|00000000|????????|
#  |--|-allocation-for-ledger-4-bits                       | \
#  `------ledger-64-bytes----------------------------------'  `-first allocatable byte
#
# So in our example, we have a base address of 0x6000, 64 bytes (0x40) of ledger, and
# the allocatable memory runs from 0x6040 -> 0x7fff (8127 bytes).
#
# Bits in the ledger indicate whether the 16-byte block is allocated (1) or free (0).
#
# The address represented by any given bit in the ledger is computed by:
#
#  addr_of_ledger + (full_bytes<<7) + (zero_idx_bit_pos<<4)
#
# This works out like so:
#
# |block|ledger|bit_pos|   block   |note
# |index|index |       |           |
# | 0000|  0   |  0    |0x6000-600f|beginning of range, first block of ledger
# | 0001|  0   |  1    |0x6010-601f|ledger
# | 0002|  0   |  2    |0x6020-602f|ledger
# | 0003|  0   |  3    |0x6020-602f|ledger
# | 0004|  0   |  4    |0x6040-604f|first block of allocatable RAM
# | 0005|  0   |  5    |0x6050-605f|allocatable RAM
# | 0006|  0   |  6    |0x6060-606f|allocatable RAM
# | 0007|  0   |  7    |0x6070-607f|allocatable RAM
# | 0008|  1   |  0    |0x6080-608f|allocatable RAM
# | 0009|  1   |  1    |0x6090-609f|allocatable RAM
# | 000a|  1   |  2    |0x60a0-60af|allocatable RAM
# | 000b|  1   |  3    |0x60b0-60bf|allocatable RAM
# | 000c|  1   |  4    |0x60c0-60cf|allocatable RAM
# | 000d|  1   |  5    |0x60d0-60df|allocatable RAM
# | 000e|  1   |  6    |0x60e0-60ef|allocatable RAM
# | 000f|  1   |  7    |0x60f0-60ff|allocatable RAM
# | 01f0| 3e   |  0    |0x7f00-7f0f|allocatable RAM
# | 01f1| 3e   |  1    |0x7f10-7f1f|allocatable RAM
# | 01f2| 3e   |  2    |0x7f20-7f2f|allocatable RAM
# | 01f3| 3e   |  3    |0x7f30-7f3f|allocatable RAM
# | 01f4| 3e   |  4    |0x7f40-7f4f|allocatable RAM
# | 01f5| 3e   |  5    |0x7f50-7f5f|allocatable RAM
# | 01f6| 3e   |  6    |0x7f60-7f6f|allocatable RAM
# | 01f7| 3e   |  7    |0x7f70-7f7f|allocatable RAM
# | 01f8| 3f   |  0    |0x7f80-7f8f|allocatable RAM
# | 01f9| 3f   |  1    |0x7f90-7f9f|allocatable RAM
# | 01fa| 3f   |  2    |0x7fa0-7faf|allocatable RAM
# | 01fb| 3f   |  3    |0x7fb0-7fbf|allocatable RAM
# | 01fc| 3f   |  4    |0x7fc0-7fcf|allocatable RAM
# | 01fd| 3f   |  5    |0x7fd0-7fdf|allocatable RAM
# | 01fe| 3f   |  6    |0x7fe0-7fef|allocatable RAM
# | 01ff| 3f   |  7    |0x7ff0-7fff|allocatable RAM
#
# bit_pos is the number of right-shifts to get the mask to the right bit.
#   0 = 0b1000 0000
#   1 = 0b0100 0000
#   2 = 0b0010 0000
#   3 = 0b0001 0000
#   4 = 0b0000 1000
#   5 = 0b0000 0100
#   6 = 0b0000 0010
#   7 = 0b0000 0001
#
# Allocating memory uses the first-fit algorithm because it's easy to implement. A new
# malloc request simply walks through the ledger looking for the first 0 (unallocated)
# bit.  It then starts counting until it locates enough contiguous 0's to fit the
# request.  The address of the beginning of the sequence is returned and the ledger
# sets the bits for the allocation to indicate they are now in use.
#
# A faster first-fit can be done with allocations of multiples of 8 blocks (64 bytes)
# as the allocator only has to look for full bytes of 0's in the ledger, not probe
# the number of individual bits that are set.
#
# Freeing memory requires both the address being freed, and the number of 16-byte
# blocks to free.  All the function does is reset the bits representing the address
# and its length.

#######
# malloc_init - Initializes a range of RAM to be used for dynamic allocations
#
# Inputs:
#  A:  address of the beginning of the range
#  BL: number of 128 byte segments to allocate. Max is 254, which allocates just under 32KiB.
#      But there is only ~20KiB of free RAM in main memory so in practical terms, 158 is
#      likely the largest value that should be used.
#
# Output:
#  none
:malloc_init
# Save initialization values in global vars
VAR global word $malloc_range_start
VAR global byte $malloc_segments
ALUOP_ADDR %A%+%AH% $malloc_range_start
ALUOP_ADDR %A%+%AL% $malloc_range_start+1
ALUOP_ADDR %B%+%BL% $malloc_segments

# Write NULs to the ledger bytes - one byte for each segment we allocated
.ledger_null_loop
ALUOP_ADDR_A %zero%
ALUOP16O_A %ALU16_A+1%
ALUOP_BL %B-1%+%BL%
JNZ .ledger_null_loop

# The ledger uses up RAM in the allocated space, so we have to mark those blocks as used.
LD_BL $malloc_segments              # Restore BL to the number of 128-byte segments

# BL is the number of _bytes_ that the ledger uses.  This has to be
# divided by 16 to get the number of _bits_ that need to be set in
# the ledger to represent the ledger itself.
LDI_AL 0x0f                         # We need to see if there are set bits in the lower nybble
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .no_init_incr                    # if no bits set in lower nybble we can evenly divide the ledger bytes by 16
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B+1%+%BL%
JMP .do_mark_used
.no_init_incr
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
.do_mark_used                       # BL contains number of blocks to mark used
LD16_A $malloc_range_start          # Restore A to beginning of range
CALL .mark_used                     # Mark these blocks as used

RET

#######
# ledger_to_addr - takes a ledger address and bit mask, and returns the
# real address of that value.
#
# Example:
#  A: 0x6004, BL: 0b0010 0000 (with range starting at 0x6000)
#     0x6004 - 0x6000 = 0x004 (number of segments)
#     0x004 << 3 = 0x020 (block aligned offset)
#     Each left-shift of mask, add 0x01 (one block) to offset
#     0b0010 0000 << 1 = 0b0100 0000 ==> 0x021
#     0b0100 0000 << 1 = 0b1000 0000 ==> 0x022 and stop
#     0x022 << 4 = 0x220 (segment aligned offset)
#     0x220+0x6000 = 0x6220 (real address of ledger bit)
#
#  A: 0x603f, BL: 0b0000 0100 (with range starting at 0x6000)
#     0x603f - 0x6000 = 0x03f (number of segments)
#     0x03f << 3 = 0x1f8 (block aligned offset)
#     Each left-shift of mask, add 0x01 (one block) to offset
#     0b0000 0100 << 1 = 0b0000 1000 ==> 0x1f9
#     0b0000 1000 << 1 = 0b0001 0000 ==> 0x1fa
#     0b0001 0000 << 1 = 0b0010 0000 ==> 0x1fb
#     0b0010 0000 << 1 = 0b0100 0000 ==> 0x1fc
#     0b0100 0000 << 1 = 0b1000 0000 ==> 0x1fd and stop
#     0x1fd << 4 = 0x1fd0 (segment aligned offset)
#     0x1fd0+0x6000 = 0x7fd0 (real address of ledger bit)
#
# Input:
#  A: memory address inside the ledger
#  BL: bit mask of the byte inside the ledger
#
# Output:
#  A: real address
.ledger_to_addr
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD16_B $malloc_range_start
CALL :sub16_a_minus_b                       # A = number of segments
CALL :shift16_a_left
CALL :shift16_a_left
CALL :shift16_a_left                        # A = block aligned offset
POP_BL                                      # BL = position mask
.ledger_to_addr_shift_loop
ALUOP_BL %B<<1%+%BL%                        # shift mask left
JO .ledger_to_addr_done_shifting            # if the shift resulted in a carryout, we are done
ALUOP16O_A %ALU16_A+1%                              # add a block to the offset
JMP .ledger_to_addr_shift_loop
.ledger_to_addr_done_shifting
CALL :shift16_a_left
CALL :shift16_a_left
CALL :shift16_a_left
CALL :shift16_a_left                        # A = segment aligned offset
LD16_B $malloc_range_start
ALUOP16O_A %ALU16_A+B%                            # A = real address
POP_BH
RET

#######
# addr_to_ledger - takes a memory address and returns the ledger address
# and bit mask of that address.  Addresses are rounded down to the nearest block.
#
# Example:
#  A: 0x7f00 (with range starting at 0x6000)
#     0x7f00 - 0x6000 = 0x1f00 (offset)
#     0x1f00 >> 4 = 0x1f0 (block index)
#     Store last three bits (0)
#     0x1f0 >> 3 = 0x3e (ledger index)
#     last three bits=0 -> 0b10000000 mask
#
#  A: 0x7f10 (with range starting at 0x6000)
#     0x7f10 - 0x6000 = 0x1f10 (offset)
#     0x1f10 >> 4 = 0x1f1 (block index)
#     Store last three bits (1)
#     0x1f1 >> 3 = 0x3e (ledger index)
#     last three bits=1 -> 0b01000000 mask
#
#  A: 0x7fd0 (with range starting at 0x6000)
#     0x7fd0 - 0x6000 = 0x1fd0 (offset)
#     0x1fd0 >> 4 = 0x1fd (block index)
#     Store last three bits (5)
#     0x1fd >> 3 = 0x3f (ledger index)
#     last three bits=5 -> 0b00000100
##
# Inputs:
#  A: memory address, generally an address returned by malloc.
#     Last four bits will be discarded.
#
# Outputs:
#  A: memory address of the ledger byte of this block
#  BL: bit position in the byte, as a mask
.addr_to_ledger
ALUOP_PUSH %B%+%BH%
PUSH_CL

# Subtract ledger addr from memory address, to get an offset
LD16_B $malloc_range_start          # B contains the address of the ledger
CALL :sub16_a_minus_b               # A is now the offset from the base address

# Shift the offset right four bits to get the block index (the bit of the
# the ledger representing this address)
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right

# Save the lowest three bits: this tells us the position
# in the ledger byte of the bit we want
ALUOP_PUSH %B%+%BL%
LDI_BL 0x07
ALUOP_CL %A&B%+%AL%+%BL%            # CL contains the bit_pos
POP_BL

# Shift the offset right three bits to get ledger index
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right

# Add the ledger index to the range base address
ALUOP16O_A %ALU16_A+B%                    # Add base addr (B) to ledger idx (A) and store in A
ALUOP_PUSH %A%+%AL%                 # Save AL since we mangle it below

# Construct a mask in BL from the bit_pos value in CL
LDI_BL 0x80
MOV_CL_AL
.map_shift_loop
ALUOP_FLAGS %A%+%AL%
JZ .map_shift_loop_done             # Done looping if AL (bit_pos) is zero
ALUOP_BL %B>>1%+%BL%                # shift BL right one
ALUOP_AL %A-1%+%AL%                 # decrement AL (bit_pos)
JMP .map_shift_loop
.map_shift_loop_done

POP_AL
POP_CL
POP_BH
RET

#######
# malloc - Allocate a block of RAM and return its address
#
# Inputs:
#  AL: Size of desired allocation, 16*(AL+1) (0 = 16 bytes, 1 = 32 bytes, ... 255 = 4096 bytes)
#     Values >= 7 (>= 128 bytes) will be shifted right three places and incremented to
#     obtain the number of contiguous ledger bytes (segments) to locate.  Values
#     <= 6 will be incremented to find the number of contiguous bits in
#     a nybble to locate.
#
# Output:
#  A:  Memory address of allocated memory (will be zero if allocation failed)
:malloc
CALL :heap_push_all
LDI_BL 0x07
ALUOP_FLAGS %A-B%+%AL%+%BL%                 # if AL-7 causes an overflow, then AL is <=6, use nybble allocator
JO .malloc_blocks

# otherwise, AL is >= 7 and we use segment-based allocation for 8/16/24/32/.../256 blocks
.malloc_segments
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%                        # Shift AL right three bits to get the number of segments minus one
ALUOP_BL %A+1%+%AL%                         # BL is now the number of full ledger bytes we need to find
LD_CH $malloc_range_start
LD_CL $malloc_range_start+1                 # C tracks our position in the ledger
MOV_CH_AH
MOV_CL_AL
LD_BH $malloc_segments
ALUOP_AL %A+B%+%AL%+%BH%
JNO .malloc_segments_1
ALUOP_AH %A+1%+%AH%
.malloc_segments_1                          # A now contains the address of the first data byte (after the ledger)

ALUOP_DH %A%+%AH%                           # D now contains the first invalid address in the ledger.
ALUOP_DL %A%+%AL%                           # If our hunt for contiguous NULL runs lands us at this
                                            # address, we abort with an invalid malloc.

ALUOP_PUSH %B%+%BL%                         # Save our target segment count to the stack

.malloc_segments_loop
ALUOP_PUSH %B%+%BL%
MOV_CH_AH
MOV_CL_AL
MOV_DH_BH
MOV_DL_BL
ALUOP_FLAGS %AxB%+%AL%+%BL%
POP_BL                                      # ensure we don't destroy target segment counter
JNE .malloc_segments_loop_2
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .malloc_segments_loop_2
POP_TD                                      # If we get here, C (ledger pointer) and D (first invalid ledger addr)
JMP .malloc_invalid                         # are equal, so return 0, no allocation done.

.malloc_segments_loop_2
LDA_C_AL                                    # Load ledger byte into BH
ALUOP_FLAGS %A%+%AL%                        # is the byte null?
JNZ .malloc_segments_loop_notnull
ALUOP_BL %B-1%+%BL%                         # yes, so decrement our null segment count
INCR_C                                      # and move to the next ledger byte.  If our null
JZ .malloc_segments_loop_done               # segment count goes to zero, break out of the loop.
JMP .malloc_segments_loop                   # otherwise, continue looping to check for the next null byte

.malloc_segments_loop_notnull               # found a non-null byte, so
PEEK_BL                                     # BL = reset target segment count back to original value
INCR_C                                      # move to next ledger byte
JMP .malloc_segments_loop                   # try again for a null byte

.malloc_segments_loop_done                  # success! our target segment counter is now zero. We now need to roll
                                            # back to find the ledger address where the run of null bytes started.
MOV_CH_AH
MOV_CL_AL                                   # A = current ledger pointer
PEEK_BL                                     # BL = number of null bytes we found
ALUOP_AL %A-B%+%AL%-%BL%                    # subtract A-BL to get addr of first null byte
JNO .malloc_segments_loop_3
ALUOP_AH %A-1%+%AH%
.malloc_segments_loop_3
LDI_BL 0x80
CALL .ledger_to_addr                        # A = real address
POP_BL                                      # BL = number of segments
ALUOP_BL %B<<1%+%BL%
ALUOP_BL %B<<1%+%BL%
ALUOP_BL %B<<1%+%BL%                        # BL = number of blocks
CALL .mark_used
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%                         # Save return value to stack
CALL :heap_pop_all                          # Restore registers
POP_AH
POP_AL                                      # Put return value back into A
RET

########
# block-based allocation for 1, 2, 3 ... 7 blocks
########
.malloc_blocks
ALUOP_BL %A+1%+%AL%                         # BL is now the number of contiguous ledger bits we need to find

LD_CH $malloc_range_start
LD_CL $malloc_range_start+1                 # C tracks our position in the ledger
MOV_CH_AH
MOV_CL_AL
LD_BH $malloc_segments
ALUOP_AL %A+B%+%AL%+%BH%
JNO .malloc_blocks_1
ALUOP_AH %A+1%+%AH%
.malloc_blocks_1                            # A now contains the address of the first data byte (after the ledger)
ALUOP_DH %A%+%AH%                           # D now contains the first invalid address after the ledger.
ALUOP_DL %A%+%AL%                           # If our hunt for free blocks encounters this address, we abort with an invalid malloc.

ALUOP_PUSH %B%+%BL%                         # Save our target block count to the stack

#####
# Main malloc blocks loop
.malloc_blocks_loop
## Ensure we are not beyond the end of the ledger
MOV_CH_AH
MOV_CL_AL
MOV_DH_BH
MOV_DL_BL
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .malloc_blocks_loop_2
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .malloc_blocks_loop_2
POP_TD                                      # If we get here, C (ledger pointer) and D (first invalid ledger addr)
JMP .malloc_invalid                         # are equal, so return 0, no allocation done.

## Load the current ledger byte and see if it has
## sufficient zeroes to accommodate our request
.malloc_blocks_loop_2
PEEK_BL                                     # BL = target block count
LDA_C_AL                                    # Load ledger byte into AL
ALUOP_AH %A_popcount%+%AL%                  # AH = population count of AL by nybbles
CALL :heap_push_AH
CALL :merge_popcount
CALL :heap_pop_AH                           # AH = population count of AL
LDI_BH 0x08
ALUOP_AH %B-A%+%BH%+%AH%                    # AH = inverse popcount (count of zeros)
ALUOP_FLAGS %A-B%+%BL%+%AH%                 # num_zeros - needed_zeros
JNO .malloc_blocks_loop_3                   # if no overflow, we have enough zeros
INCR_C                                      # otherwise, move to the next byte in the ledger
JMP .malloc_blocks_loop                     # and try again

## Build a mask representing the desired allocation
.malloc_blocks_loop_3                       # this ledger block has sufficient zeros, but
                                            # we don't know if they are contiguous
LDI_BH 0x00                                 # start with an empty mask in BH
.malloc_blocks_loop_3a
ALUOP_BH %B>>1%+%BH%+%Cin%                  # shift a new bit into AH
ALUOP_BL %B-1%+%BL%                         # decrement our target block count
JNZ .malloc_blocks_loop_3a                  # if BL==0 we are done building the mask

## See if the mask fits in the ledger byte
.malloc_blocks_loop_4                       # BH = mask, on MSB side
PEEK_BL                                     # get our target block count back
.malloc_blocks_loop_5
ALUOP_FLAGS %A&B%+%AL%+%BH%                 # check if mask & ledger byte is zero
JZ .malloc_blocks_loop_6                    # if zero, we found a place for our allocation
ALUOP_BH %B>>1%+%BH%                        # shift the mask right one spot
ALUOP_AH %B_popcount%+%BH%                  # get the popcount of the mask into AH
CALL :heap_push_AH
CALL :merge_popcount
CALL :heap_pop_AH                           # merged popcount of mask in AH
ALUOP_FLAGS %A&B%+%AH%+%BL%                 # ensure we still have the requisite number of bits in the mask
JEQ .malloc_blocks_loop_5                   # if so, loop back and check again if this spot works
INCR_C                                      # otherwise, move to next ledger byte
JMP .malloc_blocks_loop                     # and try again

## We found a spot for the allocation
.malloc_blocks_loop_6                       # we found a place for the allocation, BH contains the mask
                                            # and C contains the address of the ledger byte
MOV_CH_AH                                   # Move C to A so we can call mark_used
MOV_CL_AL
ALUOP_BL %B%+%BH%                           # Put the mask into BL
CALL .ledger_to_addr                        # A is now the real memory address
POP_BL                                      # BL = number of blocks to allocate
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%                         # Save memory address as heap_pop_all will destroy it
CALL .mark_used                             # ledger now marks these blocks as used
CALL :heap_pop_all
POP_AL
POP_AH                                      # Return the real memory address of our allocation
RET

# Invalid value for number of blocks was given
.malloc_invalid
CALL :heap_pop_all
LDI_A 0x0000
RET

#######
# mark_used - sets bits in the ledger indicating these blocks are in use
#
# Inputs:
#  A:  real address of the beginning of the first block
#  BL: number of 16-byte blocks to mark allocated (aka number of bits to set)
#
# Outputs:
#  none
.mark_used
ALUOP_PUSH %B%+%BH%
LDI_BH 0x01
CALL .mark
POP_BH
RET

#######
# free - Return a block of RAM back to the allocator
#
# Inputs:
#  A:  real address to be freed
#  BL: Size of allocation to return, blocks-1
#
# Output:
#  none
:free
ALUOP_PUSH %B%+%BH%
LDI_BH 0x00
ALUOP_BL %B+1%+%BL%     # .mark expects BL to have the absolute number of bits,
CALL .mark              # not an allocation (blocks minus 1)
POP_BH
RET

#######
# mark - general function that can mark blocks as
# used (BH=1) or free (BH=0)
#
# Inputs:
#  A:  real address to be marked
#  BL: Size of allocation to mark, 16*(BL+1)
#  BH: mark used (1) or free (0)
#
# Output:
#  none
.mark
PUSH_CH
PUSH_CL
PUSH_DL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

ALUOP_DL %B%+%BH%                   # Save our used/free flag in DL

ALUOP_BH %B%+%BL%                   # BH=number of bits to set, minus 1

# Get ledger address and bit position of address in A
CALL .addr_to_ledger                # A=ledger byte addr, BL=bit in byte (as mask)
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # Move A to C (ledger byte address)

# Loop across each bit to mark, tracking progress in BH
.mark_loop
LDA_C_AL                            # AL=ledger byte
ALUOP_PUSH %B%+%BH%                 # save BH
MOV_DL_BH                           # retrieve our used/free flag
ALUOP_FLAGS %B%+%BH%                # set or clear zero flag
POP_BH                              # restore BH
JZ .mark_free                       # If zero flag is set, we are marking free, otherwise
ALUOP_ADDR_C %A|B%+%AL%+%BL%        # write updated ledger byte (used) to RAM
JMP .mark_done
.mark_free
ALUOP_ADDR_C %A&~B%+%AL%+%BL%       # Write updated ledger byte (free) to RAM
.mark_done
ALUOP_FLAGS %B-1%+%BL%              # If mask is 0x01, B-1 will be 0
JNZ .mark_shift_and_loop            # Jump if we still have bits left in the mask
LDI_BL 0x80                         # otherwise, reset bit mask to first bit
INCR_C                              # and move to next byte in the ledger
JMP .mark_next_bit                  # and don't shift the mask

.mark_shift_and_loop
ALUOP_BL %B>>1%+%BL%                # shift mask one position right

.mark_next_bit
ALUOP_BH %B-1%+%BH%                 # decrement our bit counter
JNZ .mark_loop                      # done if bit counter is zero

POP_AL
POP_AH
POP_DL
POP_CL
POP_CH
RET

#######
# calloc - Allocate a block of RAM, initialize it with NULLs and return its address
#
# Inputs: same as malloc
# Output: same as malloc
#
:calloc
ALUOP_PUSH %A%+%AL%                     # save the request size
CALL :malloc

# Check if malloc succeeded
ALUOP_FLAGS %A%+%AH%
JNZ .calloc_continue
ALUOP_FLAGS %A%+%AL%
JNZ .calloc_continue
POP_TD                                  # discard saved request size and
RET                                     # return without doing anything if malloc returned zero

.calloc_continue
CALL :heap_push_all

# copy allocated memory address into C
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
# fill memory with NULLs
LDI_AH 0x00

# If request size was 0-6, use the block filler, otherwise
# use the segment filler which is more efficient.
POP_AL                                  # pop saved request size into AL
LDI_BL 0x07
ALUOP_FLAGS %A-B%+%AL%+%BL%             # if AL-7 causes an overflow, then AL is <=6, use block filler
JO .calloc_fill_blocks

.calloc_fill_segments
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%                    # divide AL by 8 to get the number of segments, then add one
ALUOP_AL %A+1%+%AL%
CALL :memfill_segments
CALL :heap_pop_all
RET

.calloc_fill_blocks
CALL :memfill_blocks                    # AL already contains the number of blocks
CALL :heap_pop_all
RET

