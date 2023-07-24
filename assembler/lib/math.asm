# vim: syntax=asm-mycpu

# Software math functions

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
ALUOP_AH %A+1%+%AH%
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
ALUOP_BH %B+1%+%BH%
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
ALUOP_AL %B>>1%+%BL%                # shift BL
LDI_AL 0x01                         # mask to check if BH's LSB is set
ALUOP_FLAGS %A&B%+%BH%+%AL%         # check if BH LSB is set
JZ .shift16_b_right_zero            # if BH LSB is set,
LDI_AL 0x80
ALUOP_BL %A|B%+%BL%+%AL%            #   set BL's MSB
.shift16_b_right_zero
ALUOP_BH %B>>1%+%BH%                # shift BH
POP_AL                              # restore AL
RET                                 # and return


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
