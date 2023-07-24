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
#  BL: number of 128 byte segments to allocate. Max is 254, which allocates 32KiB.
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
CALL :incr16_a
ALUOP_BL %B-1%+%BL%
JNZ .ledger_null_loop

# The ledger uses up RAM in the allocated space, so we have to mark those blocks as used.
LD_BL $malloc_segments              # Restore BL to the number of 128-byte segments

# BL is the number of _bytes_ that the ledger uses.  This has to be
# divided by 16 to get the number of _bits_ that need to be set in
# the ledger.
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
# mark_used - sets bits in the ledger indicating these blocks are in use
#
# Inputs:
#  A:  address of the beginning of the first block
#  BL: number of 16-byte blocks to mark allocated (aka number of bits to set)
#
# Outputs:
#  none
.mark_used
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BH%

ALUOP_BH %B%+%BL%                   # BH=number of bits to set

# Get ledger address and bit position of address in A
CALL .map_to_ledger                 # A=ledger byte addr, BL=bit in byte (as mask)
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # Move A to C (ledger byte address)

# Loop across each bit to mark as used, tracking progress in BH
.mark_used_loop
LDA_C_AL                            # AL=ledger byte
ALUOP_ADDR_C %A|B%+%AL%+%BL%        # Write updated ledger byte to RAM
ALUOP_FLAGS %B-1%+%BL%              # If mask is 0x01, B-1 will be 0
JNZ .mark_used_shift_and_loop       # Jump if we still have bits left in the mask

LDI_BL 0x80                         # otherwise, reset bit mask to first bit
INCR_C                              # and move to next byte in the ledger
JMP .mark_used_next_bit             # and don't shift the mask

.mark_used_shift_and_loop
ALUOP_BL %B>>1%+%BL%                # shift mask one position right

.mark_used_next_bit
ALUOP_BH %B-1%+%BH%                 # decrement our bit counter
JNZ .mark_used_loop                 # done if bit counter is zero

POP_BH
POP_CL
POP_CH
RET

#######
# map_to_ledger - takes a memory address and returns the ledger address
# and bit mask of that address.  Addresses are rounded down to the nearest block.
#
# Example:
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
#
# Inputs:
#  A: memory address, generally an address returned by malloc.
#     Last four bits will be discarded.
#
# Outputs:
#  A: memory address of the ledger byte of this block
#  BL: bit position in the byte, as a mask
.map_to_ledger
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
CALL :add16_to_a                    # Add base addr (B) to ledger idx (A) and store in A

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

POP_CL
POP_BH
RET

#######
# malloc - Allocate a block of RAM and return its address
#
# Inputs:
#  AL: Size of desired allocation, 16*(AL+1) (0 = 16 bytes, 1 = 32 bytes, ... 255 = 4096 bytes)
#
# Output:
#  A:  Memory address of allocated memory (will be zero if allocation failed)
:malloc
RET


#######
# free - Return a block of RAM back to the allocator
#
# Inputs:
#  A:  Address to be freed
#  BL: Size of allocation to return, 16*(BL+1)
#
# Output:
#  none
:free
RET

