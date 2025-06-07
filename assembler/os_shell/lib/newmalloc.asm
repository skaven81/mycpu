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
#  0xf8..0xfe - unused, invalid
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

CALL :extpage_d_push_zero           # switch to the zero page at 0xd000

# Put the starting ledger address into C
LDI_C 0xd000 

# Byte to fill into AH (0x00 = unallocated)
LDI_AH 0x00

# The number of ledger bytes will be 8x the value in BL, since BL is the number of 128-byte
# segments to allocate, and each block (each byte in the ledger) is 16 bytes.
# 128 / 16 = 8.  We can use :memfill_half_blocks to fill 8 bytes at a time.
ALUOP_AL %B-1%+%BL%                 # AL = 8-byte half-blocks minus one

# C = address to fill, AH = byte to fill, and
# AL = number of 8-byte half-blocks to fill, minus one
CALL :memfill_half_blocks

CALL :extpage_d_pop                 # Switch d-page back to previous value
CALL :heap_pop_byte                 # Discard previous d-page

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
LDI_B 0xd000                        # Add ledger base addr (B)
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
#       8 blocks -> calls malloc_segments(1)
#       9 blocks -> calls malloc_segments(2)
#       ...
#      15 blocks -> calls malloc_segments(2)
#      16 blocks -> calls malloc_segments(2)
#      17 blocks -> calls malloc_segments(3)
#
# Output:
#  A: Memory address of allocated memory (zero if allocation failed)
:new_malloc_blocks
ALUOP_PUSH %B%+%BL%
LDI_BL 0x08
ALUOP_FLAGS %B-A%+%AL%+%BL%     # if AL >= 8, zero or overflow bit will be set
POP_BL
JO .blocks_as_segments
JZ .blocks_as_segments

# AL was < 8, so we perform allocation in 16-byte blocks
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AL%             # save ledger run length for later
LDI_BH 0x00
ALUOP_BL %A%+%AL%               # B = length of ledger run we need
CALL .find_unused_run           # B will either be a ledger address or zero
ALUOP_FLAGS %B%+%BH%
JNZ .valid_block_allocation
ALUOP_FLAGS %B%+%BL%
JNZ .valid_block_allocation
# if we get here, B was zero so allocation failed, and
# we need to return zero
LDI_A 0x0000
JMP .new_malloc_blocks_done

# If we get here, B contains a ledger address for the beginning of our run of zeroes.
# We need to update the ledger to fill the run with 0xff's, then write the size of the
# allocation in segments, to the first byte of the run.
.valid_block_allocation
CALL :extpage_d_push_zero       # switch to the zero page at 0xd000
PEEK_AL                         # restore AL (number of blocks). For each count,
                                # we need to write 1x 0xff's to the ledger.
ALUOP_AL %A-1%+%AL%             # minus one since :memfill uses bytes minus one
LDI_AH 0xff                     # byte to fill
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%               # C = address to fill
CALL :memfill
ALUOP_PUSH %B%+%BL%
LDI_BL 0xf0
ALUOP_AL %A|B%+%AL%+%BL%        # AL is now 0xfn with n = number of blocks
POP_BL
ALUOP_ADDR_B %A+1%+%AL%         # Write allocation length in blocks to start of ledger addr
                                # Incrementing because we decremented before :memfill
ALUOP_AL %B%+%BL%
ALUOP_AH %B%+%BH%               # copy ledger address to A
CALL .ledger_to_addr            # get memory address of allocation into A
CALL :extpage_d_pop             # restore D page
CALL :heap_pop_byte             # discard previous D page

.new_malloc_blocks_done
POP_TD                          # discard saved AL from before
POP_BL
POP_BH
POP_CL
POP_CH
RET

# AL was >= 8, so we will call :new_malloc_segments instead
.blocks_as_segments
ALUOP_PUSH %B%+%BL%
LDI_BL 0x07
ALUOP_FLAGS %A&B%+%AL%+%BL%     # check if any of the lowest three bits are set
JNZ .blocks_as_segments_roundup
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%            # shift AL right three places to get number of segments
JMP .do_blocks_as_segments
.blocks_as_segments_roundup
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%            # shift AL right three places to get number of segments
ALUOP_AL %A+1%+%AL%
.do_blocks_as_segments
CALL :new_malloc_segments
POP_BL
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
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AL%             # save number of segments that will be written to ledger

ALUOP_BL %A%+%AL%               # number of segments into BL
LDI_BH 0x00
CALL :shift16_b_left            # multiply by 8 to get length of ledger run we need
CALL :shift16_b_left            # ..
CALL :shift16_b_left            # .
CALL .find_unused_run           # B will either be a ledger address or zero
ALUOP_FLAGS %B%+%BH%
JNZ .valid_segment_allocation
ALUOP_FLAGS %B%+%BL%
JNZ .valid_segment_allocation
# if we get here, B was zero so allocation failed, and
# we need to return zero
LDI_A 0x0000
JMP .new_malloc_segments_done

# If we get here, B contains a ledger address for the beginning of our run of zeroes.
# We need to update the ledger to fill the run with 0xff's, then write the size of the
# allocation in segments, to the first byte of the run.
.valid_segment_allocation
CALL :extpage_d_push_zero       # switch to the zero page at 0xd000
PEEK_AL                         # restore AL (number of segments). For each count,
                                # we need to write 8x 0xff's to the ledger.
ALUOP_AL %A-1%+%AL%             # minus one since :memfill_half_blocks uses blocks minus one
LDI_AH 0xff                     # byte to fill
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%               # C = address to fill
CALL :memfill_half_blocks
ALUOP_ADDR_B %A+1%+%AL%         # Write allocation length in segments to start of ledger addr

ALUOP_AL %B%+%BL%
ALUOP_AH %B%+%BH%               # copy ledger address to A
CALL .ledger_to_addr            # get memory address of allocation into A
CALL :extpage_d_pop             # restore D page
CALL :heap_pop_byte             # discard previous D page

.new_malloc_segments_done
POP_TD                          # discard saved AL from before
POP_BL
POP_BH
POP_CL
POP_CH
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
#
# The algorithm works "backwards" to take advantage of some overflow
# conditions and counting to zero.
#
# C contains the current ledger address.  Initialize at the last byte
# in the ledger.  This way we can decrement it, and once it crosses
# over to 0xcfff we know we've run out of ledger.
#
# Save the target count on the heap
# Start looping through the ledger looking for zeroes:
#  - if address is < 0xd000 then we failed allocation, return zero
#  - if zero, decrement B.
#    - if B == 0, we have found enough zeroes and C contains the beginning of the run, so return it
#    - if B > 0, we need to find more zeroes, so go to the next ledger byte
#  - else, restore B and go to next ledger byte
.find_unused_run
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
PUSH_CL
PUSH_CH
CALL :extpage_d_push_zero           # switch to the zero page at 0xd000

CALL :heap_push_B                   # save target count for later
CALL :heap_push_B                   # save it again, this one will stay the original value

# store the address of the last byte in the ledger into C
LD_AL $new_malloc_segments          # there are 8x this many bytes in the ledger
LDI_AH 0x00
CALL :shift16_a_left
CALL :shift16_a_left
CALL :shift16_a_left                # A contains the number of ledger bytes
LDI_B 0xd000
CALL :add16_to_a                    # A contains the address of the last ledger byte, plus one
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # C now contains the address of the last ledger byte, plus one
                                    # the first thing the .find_unused_run_loop will do is decrement this.
.find_unused_run_loop
DECR_C
MOV_CH_AL                           # check to see if we've left 0xd000 land
LDI_BL 0xcf
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .find_unused_run_failed

LDA_C_AL                            # load ledger byte into AL
ALUOP_FLAGS %A%+%AL%
JZ .find_unused_run_iszero

.find_unused_run_isnotzero          # found a nonzero, so
CALL :heap_pop_B                    # restore current count
CALL :heap_pop_B                    # restore original count
CALL :heap_push_B                   # save original count
CALL :heap_push_B                   # save current count (which is now reset)
JMP .find_unused_run_loop           # try next ledger byte

.find_unused_run_iszero             # found a zero, so
CALL :heap_pop_B                    # restore current count
CALL :decr16_b                      # decrement counter
CALL :heap_push_B                   # put it back on the heap
ALUOP_FLAGS %B%+%BH%
JNZ .find_unused_run_loop           # if current count isn't zero, keep going
ALUOP_FLAGS %B%+%BL%
JNZ .find_unused_run_loop           # if current count isn't zero, keep going

.find_unused_run_success
CALL :heap_pop_word                 # discard current count
CALL :heap_pop_word                 # discard original count
MOV_CH_BH
MOV_CL_BL                           # copy current ledger address to B
JMP .find_unused_run_done           # and return it

.find_unused_run_failed
CALL :heap_pop_word                 # discard current count
CALL :heap_pop_word                 # discard original count
LDI_B 0x0000                        # we'll return zero indicating allocation failure

.find_unused_run_done
CALL :extpage_d_pop                 # Switch d-page back to previous value
CALL :heap_pop_byte                 # Discard previous d-page
POP_CH
POP_CL
POP_AH
POP_AL
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
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
CALL :extpage_d_push_zero

# Convert real address to ledger address
CALL .addr_to_ledger                    # A contains ledger address at 0xd000 base
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                       # C contains ledger address
INCR_C                                  # pre-increment before loop starts

# Walk backward until we reach a value <ff
.free_loop
DECR_C                                  # move to next byte in ledger
LDA_C_AL                                # get ledger byte into AL
ALUOP_FLAGS %A+1%+%AL%                  # if overflow, value was 0xff
JO .free_loop                           # ... and we should keep looping

ALUOP_FLAGS %A%+%AL%                    # check AL
JZ .free_done                           # if zero, we're in an unallocated zone already, nothing to do

# C points at the ledger address of the beginning of an allocation
# AL contains the allocation size, 01-ef = segments, f1-f8 blocks
LDI_BL 0xf0
ALUOP_BL %A&B%+%AL%+%BL%                # BL will be 0xf0 if ledger byte was 0xfn
LDI_AH 0xf0
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .free_blocks

.free_segments
LDI_AH 0x00                             # byte to fill
ALUOP_AL %A-1%+%AL%                     # minus one because :memfill_half_blocks takes blocks minus one
CALL :memfill_half_blocks               # Write nulls to ledger address in C, in half blocks (8 bytes = one malloc segment)
JMP .free_done

.free_blocks
LDI_AH 0x00                             # byte to fill
LDI_BL 0x0f
ALUOP_AL %A&B%+%AL%+%BL%                # strip top 0xfn to get number of blocks
ALUOP_AL %A-1%+%AL%                     # minus one because :memfill takes bytes minus one
CALL :memfill                           # Write nulls to ledger address in C, in bytes (1 byte = one malloc block)

.free_done
CALL :extpage_d_pop                     # reset D page
CALL :heap_pop_byte                     # discard previous D page
POP_CL
POP_CH
POP_BL
POP_AL
POP_AH
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

