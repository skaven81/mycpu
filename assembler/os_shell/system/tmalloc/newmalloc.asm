# vim: syntax=asm-mycpu

# Primitive memory allocator: malloc() and free().  Uses a first-fit approach.
#
# Terminology:
#  * range: the area of RAM set aside for the memory allocator
#  * segment: 128 bytes, the smallest unit of range
#  * block: 16 bytes, the smallest unit of allocation (1/8 of a segment)
#  * ledger: table recording which blocks are allocated, stored in extended memory
#
#
### USAGE OVERVIEW
#
# Begin by initializing the ledger. The ledger is stored in extended memory to
# ensure that main memory capacity is maximized. Every byte in the ledger
# represents a block (16 bytes) of allocated memory.
#
#  0x00 - unallocated block
#  0x01..0xef - segment allocation size, 1 segment (128 bytes) to 239 segments (30592 bytes)
#  0xf1..0xf7 - block allocation size, 1 block (16 bytes), to 7 blocks (112 bytes)
#  0xff - part of previous allocation
#
# The ledger for a 32KiB allocatable range (maximum we will ever need) is 2048
# bytes long.
#
# Handling an allocation request starts with two sets of functions:
#
#  :malloc_blocks - small allocations by block. The AL register contains the
#  number of blocks to allocate
#
#  :malloc_segments - large allocations by segment. The AL register contains
#  the number of segments to allocate
#
# These functions return the address of allocated memory in register A.
# AH will be 0x00 if allocation failed. AL may contain a code that indicates
# why the allocation failed (future work).
#
# Freeing memory requires placing an address in A then calling :free.
#
# If upon consulting the ledger, the address maps to a byte with value
# 0xff or 0x00, then :free fails, an error is printed to the console,
# and the system halts.
#
#
### MAPPING MEMORY ADDRESSES TO LEDGER ADDRESSES
#
# When :malloc_init is called, the base address of the allocatable range
# is stored in a global variable. So all we need to do is deal with offsets,
# which is easy since the ledger is stored in extended memory and thus always
# starts at 0xd000 (or 0xe000).
#
# Ledger address to memory address:
#   1. Shift ledger byte address left four places
#      * this multiplies by 16, and shifts out the top four bits
#        so it doesn't matter if we're looking at 0xd000 or 0xe000
#        for extended memory
#   2. Add resulting value to allocatable range base address
#
#
# Memory address to ledger address:
#   1. Subtract allocatable range base address from memory address (offset)
#   2. Shift offset right four places
#      * note that an address that isn't on a block boundary will be normalized
#        to the lowest nearby block boundary.
#   3. Add 0xd000 (or 0xe000) to reference the ledger byte
#
#
### ALLOCATION ALGORITHM
#
# Both small and large allocations use "first fit". Since the ledger contains
# offset sizes, it's fast to search for allocatable memory:
#
#   1. Initialize ptr at first ledger byte
#   2. count=0
#   3. while *ptr == 0x00
#      a. count++
#      b. if count == needed_blocks: break and return ptr-count
#      c. ptr++
#   4. if *ptr == 0xff, ptr++ until *ptr == 0x00 then goto 2
#   5. ptr + *ptr (advance past this allocated block) then goto 2

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
#  none; A and BL unchanged
:new_malloc_init
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
# Save initialization values in global vars
VAR global word $new_malloc_range_start
VAR global byte $new_malloc_segments
ALUOP_ADDR %A%+%AH% $new_malloc_range_start
ALUOP_ADDR %A%+%AL% $new_malloc_range_start+1
ALUOP_ADDR %B%+%BL% $new_malloc_segments

CALL :extzero_d                     # switch to the zero page at 0xd000

# Put the starting ledger address into C
LDI_C 0xd000 

# Byte to fill into AL (0x00 = unallocated)
LDI_AL 0x00

# The ledger will be 8x the size in BL, since BL is
# the number of 128-byte segments to allocate, and
# each block (each byte in the ledger) is 16 bytes.
# 128 / 16 = 8.  We can use :memfill_blocks to fill
# 16 bytes at a time, which means we should take BL
# and divide by 2 (shift right one) and add one, to
# cover cases where an odd number of segments was
# requested.
ALUOP_AL %B>>1%+%BL%
ALUOP_AL %A+1%+%AL%

# Now C = address to fill, AH = byte to fill, and
# AL = number of 16-byte blocks to fill
CALL :memfill_blocks

CALL :extzero_d_restore             # Switch d-page back to previous value

POP_CL
POP_CH
POP_BL
POP_AL
POP_AH
RET

#######
# ledger_to_addr - takes a ledger address and returns the
# memory address of that value.
#
# Input:
#  A: memory offset inside the ledger (top four bits ignored)
#
# Output:
#  A: real address (ledger_offset<<4)+$new_malloc_range_start
.ledger_to_addr
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

CALL :shift16_a_left                        # get number of bytes by
CALL :shift16_a_left                        # multiplying ledger offset
CALL :shift16_a_left                        # by 16
CALL :shift16_a_left

LD16_B $new_malloc_range_start              # Load memory base address into B
CALL :add16_to_a                            # A = A+B

POP_BL
POP_BH
RET

#######
# addr_to_ledger - takes a memory address and returns the ledger offset
# of that address. Assumes 0xd000 base address - to use 0xe000 just replace
# the top four bits of the returned value.
#
# Inputs:
#  A: memory address, generally an address returned by malloc.
#     Last four bits will be discarded.
#
# Output:
#  A: memory address of the ledger byte of this block assuming 0xd000 page
.addr_to_ledger
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

LD16_B $new_malloc_range_start              # Load memory base address into B

CALL :sub16_a_minus_b                       # A = offset from base address

# Shift the offset right four bits to get the block index (the byte
# offset in the ledger representing this address)
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right

# Add the ledger index to the ledger base address
LD16_B 0xd000                       # Add ledger base addr (B)
CALL :add16_to_a                    # to ledger offset (A) and store in A

POP_BL
POP_BH
RET

#######
# malloc_blocks - Allocate 16-byte blocks of ram. If AL is >7, the
# value is divided by 8 (shifted right three places) and then
# malloc_segments is called instead.  Therefore, it's recommended
# to only use malloc_blocks with values 1-7.
#
# Inputs:
#  AL: Size of allocation in blocks (1-7)
#       1 block (16 bytes)
#       2 blocks (32 bytes)
#       ...
#       7 blocks (112 bytes)
#       8 blocks -> calls malloc_segments(8>>3=1)
#       9 blocks -> calls malloc_segments(9>>3=1)
#
# Output:
#  A: Memory address of allocated memory (zero if allocation failed)
:new_malloc_blocks
RET


#######
# malloc_segments - Allocate a 128-byte segments of RAM and return its address
#
# Inputs:
#  AL: Size of desired allocation in segments (1-239, 0x01-0xef)
#       1 segment (128 bytes) to 239 segments (30592 bytes)
#
# Output:
#  A:  Memory address of allocated memory (zero if allocation failed)
:new_malloc_segments
RET


#######
# find_unused_run - Iterate through the ledger and return the
# ledger address of the beginning of a run of 0x00 bytes, or
# return 0x0000 if not found.
#
# Inputs:
#  B: length of ledger run to find
#
# Output:
#  B: 0x0000 if not found, else 0xdnnn representing ledger address
#     of located run
.find_unused_run
CALL :extzero_d                     # switch to the zero page at 0xd000

CALL :extzero_d_restore             # Switch d-page back to previous value
RET

#######
# free - Return RAM back to the allocator
#
# Inputs:
#  A:  real address to be freed
#
# Output:
#  none
:new_free
RET


#######
# calloc - Allocate a block of RAM, initialize it with NULLs and return its address
#
# Inputs: same as malloc
# Output: same as malloc
#
:new_calloc_blocks
RET

:new_calloc_segments
RET

