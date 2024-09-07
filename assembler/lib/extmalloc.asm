# vim: syntax=asm-mycpu

# Extended memory page allocator
#
# Start by calling :extmalloc_init to initialize the ledger. The ledger is stored in
# 32 bytes of global memory, with each bit of the 32-byte range representing one
# extended memory page (from 0x00 to 0xff). 0 is free, 1 is allocated.
#
# Allocate an extended memory page by calling :extmalloc. The function returns a byte
# on the heap that contains the page number that was allocated. If extended memory
# is full, it will return zero (the zero page is usable as scratch space without
# allocation).
#
# When done, push the page number onto the heap and call :extfree.


:extmalloc_init
VAR global 32 $extmalloc_ledger
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BL%
LDI_C $extmalloc_ledger         # track ledger address in C
LDI_BL 32                       # 32 bytes to clear
.extmalloc_init_loop
ALUOP_ADDR_C %zero%             # Write zero to address in C
INCR_C
ALUOP_BL %B-1%+%BL%             # decrement BL
JNZ .extmalloc_init_loop        # loop until zero
POP_BL
POP_CL
POP_CH
RET

####
# Allocate an extended memory page
#
# No inputs
#
# Outputs a byte on the heap containing the allocated address.
# If zero, extended memory is full.
#
# The allocator loops through the 32 bytes in the ledger, looking for the first
# one that is not 0xff. Each loop it decrements the return value by 8. When it
# finds a ledger byte that has a free bit, it counts right to left until it finds
# the free bit (decrementing the return value each time), then sets the first
# cleared bit it finds and returns the resulting value.
#
# If the loop completes all 32 ledger bytes without finding a free page, it
# returns zero. The zero page is not a "successful" allocation -- it means
# the extended memory is full; any subsequent calls to :extmalloc will return
# zero. Programs can (with caution) use the zero page without allocating it,
# as a scratch space.
:extmalloc
PUSH_DH
PUSH_DL
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%

LDI_D $extmalloc_ledger+31      # Track ledger address in D
LDI_C 0x00ff                    # CL = return value
LDI_BL 32                       # 32 ledger bytes to check

.extmalloc_loop
LDA_D_AL                        # Load ledger byte into AL
ALUOP_FLAGS %A+1%+%AL%          # If AL is 0xff, this will set the overflow bit
JO .extmalloc_ledger_byte_full
# this ledger byte has a free bit, so let's find it
LDI_BH 0x01                     # start with rightmost bit
.extmalloc_byte_loop
ALUOP_FLAGS %A&B%+%AL%+%BH%     # check if bit is set
JZ .extmalloc_found_page        # exit with success if found
ALUOP_BH %B<<1%+%BH%            # Shift the bitmask left...
DECR_C                          # ...which also takes us to the previous page
JMP .extmalloc_byte_loop        # we know there's a clear bit in there so no need to check for overflow

.extmalloc_ledger_byte_full
DECR_C                          # decrement C 8x as we're going to jump straight
DECR_C                          # to the next byte in the ledger
DECR_C
DECR_C
DECR_C
DECR_C
DECR_C
DECR_C
DECR_D                          # Move to previous ledger byte
ALUOP_BL %B-1%+%BL%             # Decrement ledger counter
JZ .extmalloc_full
JMP .extmalloc_loop

.extmalloc_found_page           # We found a free page! BH contains the bitmask
ALUOP_ADDR_D %A|B%+%AL%+%BH%    # we need to set, and CL contains the page number
CALL :heap_push_CL
JMP .extmalloc_done

.extmalloc_full
LDI_BL 0x00
CALL :heap_push_BL
JMP .extmalloc_done

.extmalloc_done
POP_AH
POP_AL
POP_BH
POP_BL
POP_CL
POP_CH
POP_DL
POP_DH
RET


####
# Free an extended memory page
#
# Input: byte on heap with memory page to free
# Output: none
:extfree
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LDI_A $extmalloc_ledger

# The ledger byte is $extmalloc_ledger + ($page >> 3),
# so get that set up in A
CALL :heap_pop_BL               # extended memory page in BL
ALUOP_PUSH %B%+%BL%             # save full memory page for later
ALUOP_BL %B>>1%+%BL%            # Shift memory page right 3 positions to get ledger offset
ALUOP_BL %B>>1%+%BL%            # |
ALUOP_BL %B>>1%+%BL%            # |
LDI_BH 0x00
CALL :add16_to_a                # add to ledger address; A now has ledger byte addr
POP_BL                          # BL has full memory page again

ALUOP_PUSH %A%+%AL%
LDI_AL 0x07
ALUOP_BL %A&B%+%AL%+%BL%        # BL has the offset in the ledger byte
POP_AL

LDI_BH 0x80                     # start with leftmost bit
.extfree_loop
ALUOP_BL %B-1%+%BL%             # decrement offset
JO .extfree_go                  # if overflow, BH has the mask we want to clear
ALUOP_BH %B>>1%+%BH%            # otherwise, shift the mask
JMP .extfree_loop

.extfree_go
PUSH_CL
LDA_A_CL                        # current ledger byte in CL
ALUOP_PUSH %A%+%AL%
MOV_CL_AL
ALUOP_BH %A&~B%+%AL%+%BH%       # updated ledger byte into BH
POP_AL
POP_CL
ALUOP_ADDR_A %B%+%BH%           # write updated ledger

POP_BL
POP_BH
POP_AL
POP_AH
RET
