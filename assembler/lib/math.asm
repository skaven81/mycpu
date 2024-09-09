# vim: syntax=asm-mycpu

# Software math functions

:rand8
# Returns a pseudo-random 8-bit number on the heap. Uses the algorithm
# described here: https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng
#
# seed         new seed
# ----------------------
# 0b0000 0000  xor
# 0b1000 0000  zero
# 0b0xxx xxxx  shift+xor
# 0b1xxx xxxx  shift

VAR global byte $rand_seed
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# load seed into AL
LDI_C $rand_seed
LDA_C_AL

ALUOP_FLAGS %A%+%AL%
JZ .rand8_do_xor            # If seed is 0x00 go straight to the xor
LDI_BL 0x80
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .rand8_shift_no_xor     # If seed is 0x80 then shift but don't do the xor

ALUOP_AL %A<<1%+%AL%        # shift seed left
JO .rand8_ret               # 0b1xxxxxxx case: shift but don't xor

.rand8_do_xor               # 0b0xxxxxxx or 0x00 case: shift and xor
LDI_BL 0x1d                 # see link above for other valid values
ALUOP_AL %AxB%+%AL%+%BL%    # AL xor BL -> AL
JMP .rand8_ret

.rand8_shift_no_xor
ALUOP_AL %A<<1%+%AL%        # shift seed left

.rand8_ret
ALUOP_ADDR_C %A%+%AL%       # store updated seed in $rand_seed
CALL :heap_push_AL          # push the new seed to the heap, then return

POP_CL
POP_CH
POP_BL
POP_AL
RET


:div8
# An 8-bit unsigned divisor is popped from the heap. Then
# an 8-bit unsigned dividend is popped from the heap.
# calculation is complete, the remainder is pushed to the
# heap, then the quotient.
#
# To use:
#  Push the dividend onto the heap
#  Push the divisor onto the heap
#  Call :div8
#  Pop the quotient from the heap
#  Pop the remainder from the heap
#
# If the divisor is zero, both the quotient
# and remainder will be returned as 0xff
ALUOP_PUSH %B%+%BH%     # dividend
ALUOP_PUSH %B%+%BL%     # quotient
ALUOP_PUSH %A%+%AH%     # divisor
ALUOP_PUSH %A%+%AL%     # remainder

# Pop our arguments from the heap
CALL :heap_pop_AH       # divisor
CALL :heap_pop_BH       # dividend

# Check for divide-by-zero
ALUOP_FLAGS %A%+%AH%
JZ .div8_by_zero

# Initialize quotient and remainder
LDI_AL 0x00
LDI_BL 0x00

# Begin subtracting divisor from dividend until
# there is an overflow, counting each iteration
.div8_loop
ALUOP_BH %B-A%+%BH%+%AH%    # subtract divisor from dividend
JO .div8_found_quotient     # if overflow, we have our quotient
ALUOP_BL %B+1%+%BL%         # increment quotient
JMP .div8_loop

.div8_found_quotient        # the last subtraction operation resulted in an overflow
ALUOP_AL %A+B%+%BH%+%AH%    # Add the divisor back to the overflowed dividend, to get the remainder into AL
CALL :heap_push_AL          # remainder
CALL :heap_push_BL          # quotient

.div8_done
POP_AL
POP_AH
POP_BL
POP_BH
RET

.div8_by_zero
LDI_AL 0xff
CALL :heap_push_AL
CALL :heap_push_AL
JMP .div8_done


:signed_invert_a
# The value in A is treated as a signed integer
# and is inverted (negative->positive and vice-versa).
#
# Inputs:
#  A - the value to invert
#
# Outputs:
#  A - the inverted value
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
ALUOP_AL %~A%+%AL%
ALUOP_AH %~A%+%AH%
LDI_BH 0x00
LDI_BL 0x01
CALL :add16_to_a
POP_BH
POP_BL
RET

:signed_invert_b
# The value in B is treated as a signed integer
# and is inverted (negative->positive and vice-versa).
#
# Inputs:
#  B - the value to invert
#
# Outputs:
#  B - the inverted value
ALUOP_PUSH %A%+%AL%
ALUOP_AL %~B%+%BL%
ALUOP_AH %~B%+%BH%
LDI_AL 0x01
CALL :add16_to_b
POP_AL
RET


:incr16_a
# Increments the 16-bit value in the A register
#
# Inputs:
#  AL+AH - the value to be incremented
ALUOP_AL %A+1%+%AL%
JNO .incr16a_done
ALUOP_AH %A+1%+%AH%
.incr16a_done
RET

:decr16_a
# Decrements the 16-bit value in the A register
#
# Inputs:
#  AL+AH - the value to be incremented
ALUOP_AL %A-1%+%AL%
JNO .decr16a_done
ALUOP_AH %A-1%+%AH%
.decr16a_done
RET

:incr16_b
# Increments the 16-bit value in the B register
#
# Inputs:
#  BL+BH - the value to be incremented
ALUOP_BL %B+1%+%BL%
JNO .incr16b_done
ALUOP_BH %B+1%+%BH%
.incr16b_done
RET

:decr16_b
# Decrements the 16-bit value in the B register
#
# Inputs:
#  BL+BH - the value to be incremented
ALUOP_BL %B-1%+%BL%
JNO .decr16b_done
ALUOP_BH %B-1%+%BH%
.decr16b_done
RET

:add16_to_a
# Adds 16-bit values A+B, stores result in A
#
# Inputs:
#  AL+AH - first operand
#  BL+BH - second operand
ALUOP_AL %A+B%+%AL%+%BL%
JNO .add16_to_a_high
ALUOP_AH %A+B%+%AH%+%BH%+%Cin%
RET
.add16_to_a_high
ALUOP_AH %A+B%+%AH%+%BH%
RET

:add16_to_b
# Adds 16-bit values A+B, stores result in B
#
# Inputs:
#  AL+AH - first operand
#  BL+BH - second operand
ALUOP_BL %A+B%+%AL%+%BL%
JNO .add16_to_b_high
ALUOP_BH %A+B%+%AH%+%BH%+%Cin%
RET
.add16_to_b_high
ALUOP_BH %A+B%+%AH%+%BH%
RET

:sub16_a_minus_b
# Subtracts 16-bit values A-B, stores result in A
#
# Inputs:
#  AL+AH - first operand
#  BL+BH - second operand
ALUOP_AL %A-B%+%AL%+%BL%
JNO .sub16_a_minus_b_high
ALUOP_AH %A-1%+%AH%
.sub16_a_minus_b_high
ALUOP_AH %A-B%+%AH%+%BH%
RET

:sub16_b_minus_a
# Subtracts 16-bit values B-A, stores result in B
#
# Inputs:
#  AL+AH - first operand
#  BL+BH - second operand
ALUOP_BL %B-A%+%AL%+%BL%
JNO .sub16_b_minus_a_high
ALUOP_BH %B-1%+%BH%
.sub16_b_minus_a_high
ALUOP_BH %B-A%+%AH%+%BH%
RET

:shift16_a_left
# Performs a 16-bit left shift of A
# overflow flag will be set if a bit carried out
ALUOP_AL %A<<1%+%AL%                # shift AL
JNO .shift16_a_left_nooverflow      # if overflow,
ALUOP_AH %A<<1%+%AH%+%Cin%          #   shift AH with Cin
RET                                 #   and return
.shift16_a_left_nooverflow          # otherwise,
ALUOP_AH %A<<1%+%AH%                #   shift AH without Cin
RET                                 #   and return

:shift16_a_right
# Performs a 16-bit right shift of A
ALUOP_PUSH %B%+%BL%
ALUOP_AL %A>>1%+%AL%                # shift AL
LDI_BL 0x01                         # mask to check if AH's LSB is set
ALUOP_FLAGS %A&B%+%AH%+%BL%         # check if AH LSB is set
JZ .shift16_a_right_zero            # if AH LSB is set,
ALUOP_AL %A_setmsb%+%AL%            #   set AL's MSB
.shift16_a_right_zero
ALUOP_AH %A>>1%+%AH%                # shift AH
POP_BL                              # restore BL
RET                                 # and return


:shift16_b_left
# Performs a 16-bit left shift of B
# overflow flag will be set if a bit carried out
ALUOP_BL %B<<1%+%BL%                # shift BL
JNO .shift16_b_left_nooverflow      # if overflow,
ALUOP_BH %B<<1%+%BH%+%Cin%          #   shift BH with Cin
RET                                 #   and return
.shift16_b_left_nooverflow          # otherwise,
ALUOP_BH %B<<1%+%BH%                #   shift BH without Cin
RET                                 #   and return

:shift16_b_right
# Performs a 16-bit right shift of B
ALUOP_PUSH %A%+%AL%
ALUOP_BL %B>>1%+%BL%                # shift BL
LDI_AL 0x01                         # mask to check if BH's LSB is set
ALUOP_FLAGS %A&B%+%BH%+%AL%         # check if BH LSB is set
JZ .shift16_b_right_zero            # if BH LSB is set,
LDI_AL 0x80
ALUOP_BL %A|B%+%BL%+%AL%            #   set BL's MSB
.shift16_b_right_zero
ALUOP_BH %B>>1%+%BH%                # shift BH
POP_AL                              # restore AL
RET                                 # and return

:merge_popcount
# The ALU popcount instruction returns the population count
# of each nybble, not the whole byte.  So this function merges
# the result of a popcount instruction.
#
# Input: 1 byte, top of heap
# Output: 1 byte, top of heap
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_AL                   # Retrieve our operand into AL
ALUOP_BL %A>>1%+%AL%                # Shift the upper nybble of BL four places
ALUOP_BL %B>>1%+%BL%                # Shift the upper nybble of BL four places
ALUOP_BL %B>>1%+%BL%                # Shift the upper nybble of BL four places
ALUOP_BL %B>>1%+%BL%                # Shift the upper nybble of BL four places
ALUOP_AL %A+B%+%AL%+%BL%            # Add the lower nybbles together
LDI_BL 0x0f                         # Mask out the upper nybble in AL
ALUOP_AL %A&B%+%AL%+%BL%            # AL now contains the combined value
CALL :heap_push_AL                  # Put final value onto the heap
POP_BL
POP_AL
RET

:double_dabble_byte
# Performs the double-dabble algorithm to convert a byte (in AL)
# into a two-byte BCD representation (returned in A, with the lower
# nybble of AH being the hundreds place, and AL containing the tens
# and units places).
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

# move AL to BL as we will shift out of BL into AL and AH
ALUOP_BL %A%+%AL%
# initialize A to zero
LDI_A 0x0000
# use BH to count 7 iterations; the last iteration is just
# a shift with no >=5 / +3 testing
LDI_BH 7

.ddbyte_loop
CALL :shift16_a_left            # shift the A register left.  This left a 0 in the LSB of AL.
ALUOP_BL %B<<1%+%BL%            # shift the BL register left.
JNO .dd_byte_noover             # if no overflow, do nothing
ALUOP_AL %A+1%+%AL%             #   otherwise, set the first bit in AL
.dd_byte_noover

# We now need to check all three nybbles for >= 5, and add three.  We
# need to do this from LSB to MSB.
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

# AL, lower nybble
LDI_BH 0x0f                     # mask for lower nybble
ALUOP_BL %A&B%+%AL%+%BH%        # put lower nybble of AL into BL
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_byte_dabble_1_noover    # do nothing if no overflow
LDI_BL 3
ALUOP_AL %A+B%+%AL%+%BL%        # add three to AL lower nybble
.dd_byte_dabble_1_noover

# AL, upper nybble
ALUOP_BL %A%+%AL%               # copy AL to BL
ALUOP_BL %B>>1%+%BL%            # shift BL right four places
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_byte_dabble_2_noover    # do nothing if no overflow
LDI_BL 0x30
ALUOP_AL %A+B%+%AL%+%BL%        # add 3 to upper nybble
.dd_byte_dabble_2_noover

# AH lower nybble will never exceed 2 (0-255), so no need to
# check for >= 5 in this nybble.

POP_BL
POP_BH
ALUOP_BH %B-1%+%BH%             # loop if we have bits left in BL
JNZ .ddbyte_loop

CALL :shift16_a_left            # shift the A register left.  This left a 0 in the LSB of AL.
ALUOP_BL %B<<1%+%BL%            # shift the BL register left (last, 8th bit)
JNO .dd_byte_noover_last        # if no overflow, do nothing
ALUOP_AL %A+1%+%AL%             #   otherwise, set the first bit in AL
.dd_byte_noover_last

POP_BL
POP_BH
RET

.ddword_shiftleft
# Shift the original number in C left
ALUOP_PUSH %B%+%BL%
MOV_CL_BL
MOV_CH_BH
CALL :shift16_b_left
JO .ddword_origshift_carry      # if there was not a carry-out when B shifted,
PUSH 0x00                       #   store a 0 for later
JMP .ddword_origshift_done
.ddword_origshift_carry         # else,
PUSH 0x01                       #   store a 1 for later
.ddword_origshift_done          # we'll use this value to carry-in a bit if needed into AL
ALUOP_CH %B%+%BH%               # store original number back to C
ALUOP_CL %B%+%BL%
POP_BH                          # put our carry flag into BH
POP_BL

# Shift thousands, hundreds, tens and ones (A) to the left
CALL :shift16_a_left
JO .ddword_ashift_carry         # if there was not a carry-out when A shifted,
PUSH 0x00                       #   store a 0 for later
JMP .ddword_ashift_done
.ddword_ashift_carry            # else,
PUSH 0x01                       #   store a 1 for later
.ddword_ashift_done             # we'll use this value to carry-in a bit if needed into BL
ALUOP_AL %A+B%+%AL%+%BH%        # set the lower bit if there was a carry-out earlier
POP_BH                          # our new carry bit (from the A shift) is now in BH

# Shift ten thousands (BL) to the left
ALUOP_FLAGS %B%+%BH%            # check our carry bit
JZ .ddword_bshift_nocarry
ALUOP_BL %B<<1%+%BL%+%Cin%
JMP .ddword_bshift_done
.ddword_bshift_nocarry
ALUOP_BL %B<<1%+%BL%
.ddword_bshift_done
RET

:double_dabble_word
# Performs the double-dabble algorithm to convert a word (in A)
# into a three-byte BCD representation:
#  * BL, lower nybble - ten thousands
#  * AH, upper nybble - thousands
#  * AH, lower nybble - hundreds
#  * AL, upper nybble - tens
#  * AL, lower nybble - units
ALUOP_PUSH %B%+%BH%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# We will keep the original number in CH/CL and do swaps 
# into BH/BL as needed for shifting
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%

# Initialize our output registers
LDI_A 0x0000
LDI_BL 0x00

# We will perform 15 shift+dabble operations, and one last shift at the end.
# Since we need all of our A/B registers for output and math, we'll keep our
# loop counter in D[L].
LDI_D 0x000f

.ddword_loop
CALL .ddword_shiftleft          # shift everything to the left

ALUOP_PUSH %B%+%BL%             # save BL (ten thousands), will restore after dabbling A

# Dabble AL, lower nybble (ones)
LDI_BH 0x0f                     # mask for lower nybble
ALUOP_BL %A&B%+%AL%+%BH%        # put lower nybble of AL into BL
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_word_dabble_1_noover    # do nothing if no overflow
LDI_BL 3
ALUOP_AL %A+B%+%AL%+%BL%        # add three to AL lower nybble
.dd_word_dabble_1_noover

# Dabble AL, upper nybble (tens)
ALUOP_BL %A%+%AL%               # copy AL to BL
ALUOP_BL %B>>1%+%BL%            # shift BL right four places
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_word_dabble_2_noover    # do nothing if no overflow
LDI_BL 0x30
ALUOP_AL %A+B%+%AL%+%BL%        # add 3 to upper nybble
.dd_word_dabble_2_noover

# Dabble AH, lower nybble (hundreds)
LDI_BH 0x0f                     # mask for lower nybble
ALUOP_BL %A&B%+%AH%+%BH%        # put lower nybble of AH into BL
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_word_dabble_3_noover    # do nothing if no overflow
LDI_BL 3
ALUOP_AH %A+B%+%AH%+%BL%        # add three to AL lower nybble
.dd_word_dabble_3_noover

# Dabble AH, upper nybble (thousands)
ALUOP_BL %A%+%AH%               # copy AH to BL
ALUOP_BL %B>>1%+%BL%            # shift BL right four places
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_BL %B>>1%+%BL%
ALUOP_PUSH %A%+%AL%
LDI_AL 4
ALUOP_FLAGS %A-B%+%AL%+%BL%     # set overflow flag if BL is >= 5
POP_AL
JNO .dd_word_dabble_4_noover    # do nothing if no overflow
LDI_BL 0x30
ALUOP_AH %A+B%+%AH%+%BL%        # add 3 to upper nybble
.dd_word_dabble_4_noover

# No need to dabble BL (ten thousands) as it can never
# get large enough to need a carry.
POP_BL                          # restore BL (ten thousands)

DECR_D                          # decrement loop counter
MOV_DL_BH                       # grab our loop counter from DL
ALUOP_FLAGS %B%+%BH%
JNZ .ddword_loop                # loop if we have bits left

CALL .ddword_shiftleft          # one more shift before we leave

POP_DL
POP_DH
POP_CL
POP_CH
POP_BH
RET

###
# Add two 32-bit numbers
#
# To use:
#  1. Push high word of second operand
#  2. Push high word of first operand
#  3. Push low word of second operand
#  4. Push low word of first operand
#  5. Call the function
#  6. Pop low word of result
#  7. Pop high word of result
:add32
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH

CALL :heap_pop_A        # low word of first operand
CALL :heap_pop_B        # high word of first operand
CALL :add16_to_b        # B now contains the low word result
JO .add32_carry         # note if we need to carry in to next add
CALL .add32_high_common
JMP .add32_done

.add32_carry
CALL .add32_high_common
LDI_A 0x0001
CALL :add16_to_b        # add carry

.add32_done
# result high word is in B, low word is in D
CALL :heap_push_B
CALL :heap_push_D

POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.add32_high_common
ALUOP_DL %B%+%BL%       # store low word result in D
ALUOP_DH %B%+%BH%
CALL :heap_pop_A        # high word of first operand
CALL :heap_pop_B        # high word of second operand
CALL :add16_to_b
RET

###
# Multiply two 16-bit numbers using the shfit-and-add algorithm
#
# 1. Push multiplicand
# 2. Push multiplier
# 3. Call the function
# 4. Pop low word of result
# 5. Pop high word of result
:mul16
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH

# Load multiplier into B
CALL :heap_pop_B

# Load multiplicand into C+D and push to stack as 32-bit value
LDI_C 0x0000
CALL :heap_pop_D
PUSH_CH # msb
PUSH_CL
PUSH_DH
PUSH_DL # lsb

# Initialize C (high) and D (low) to store our result
LDI_C 0x0000
LDI_D 0x0000

.mul16_loop
ALUOP_FLAGS %B%+%BH%
JNZ .mul16_continue
ALUOP_FLAGS %B%+%BL%
JZ .mul16_done              # stop looping if multiplier is zero
.mul16_continue

LDI_AL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL% # Check if LSB of multiplier is 1
JZ .mul16_noadd

# Add multiplcand to result
CALL :heap_push_B           # save multiplier
POP_BL                      # restore multiplicand from stack
POP_BH
POP_AL
POP_AH
CALL :heap_push_A           # high word of multiplicand
CALL :heap_push_C           # high word of result
CALL :heap_push_B           # low word of multiplicand
CALL :heap_push_D           # low word of result
CALL :add32
CALL :heap_pop_D            # write low word of result
CALL :heap_pop_C            # write high word of result
ALUOP_PUSH %A%+%AH%         # Put multiplicand back onto stack
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_B            # restore multiplier

.mul16_noadd
# Shift multiplier right
CALL :shift16_b_right

# Shift multiplicand left
CALL :heap_push_B           # save multiplier
POP_BL                      # restore multiplicand from stack
POP_BH
POP_AL
POP_AH
CALL :shift16_b_left
JO .mul16_multilpicand_cin
CALL :shift16_a_left
JMP .mul16_multilpicand_done
.mul16_multilpicand_cin
CALL :shift16_a_left
ALUOP_AL %A+1%+%AL%
.mul16_multilpicand_done
ALUOP_PUSH %A%+%AH%         # Put multiplicand back onto stack
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_B            # restore multiplier

JMP .mul16_loop

.mul16_done                 # Result is in C+D
CALL :heap_push_C           # high word of result
CALL :heap_push_D           # low word of result

POP_TD                      # clear multiplicand from stack
POP_TD
POP_TD
POP_TD

POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

