# vim: syntax=asm-mycpu

# Primitive memory allocator: malloc() and free().  Uses a first-fit approach.
#
# Begin by initializing the RAM that will be used by the allocator by calling malloc_init.
# The first two 128-byte segments are used for the ledger. Each bit in the ledger represents
# a 16-byte block. Thus the address of a given entry in the ledger can be given by:
#  (addr_of_ledger+2) + (full_bytes<<7) + (bit_pos<<4)
# For example, if the memory range starts at 0x6000 and we want to know the address of the
# 4th bit in the second byte:
#
#  |0x6000   |0x6001   |0x6002   |0x6003  |
#  |0000 0000|0001 0000|0000 0000|00000000|
#                `--what address does this bit represent?
#
# (0x6000+2) + (1<<7) + (3<<4) = 0x60b2
#
# Allocating memory uses the first-fit algorithm because it's easy to implement. A new
# malloc request simply walks through the ledger looking for the first 0 (unallocated)
# bit.  It then starts counting until it locates enough contiguous 0's to fit the
# request.  The address of the beginning of the sequence is returned and the ledger
# sets the bits for the allocation to indicate they are now in use.
#
# Freeing memory requires both the address being freed, and the number of 16-byte
# segments to free.  All the function does is reset the bits representing the address
# and its length.

#######
# malloc_init - Initializes a range of RAM to be used for dynamic allocations
#
# Inputs:
#  A:  address of the beginning of the range (the first 256 bytes will be used
#      for record keeping, so the minimum allocation is 256 bytes)
#  BL: number of 128 byte segments to allocate after the initial 256 byte record
#      keeping bitmap.  Max is 254, which allocates 32KiB total.  But there is
#      only ~20KiB of free RAM in main memory so in practical terms, 158 is
#      likely the largest value that should be used.
#
# Output:
#  none
:malloc_init
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

