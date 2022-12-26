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
ALUOP_AL %B-1%+%BL%
JNO .decr16b_done
ALUOP_AH %B-1%+%BH%
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

:shift16_a_left
# Performs a 16-bit left shift of A
ALUOP_AL %A<<1%+%AL%                # shift AL
JNO .shift16_a_left_nooverflow      # if overflow,
ALUOP_AH %A<<1%+%AH%+%Cin%          #   shift AH with Cin
RET                                 #   and return
.shift16_a_left_nooverflow          # otherwise,
ALUOP_AH %A<<1%+%AH%                #   shift AH without Cin
RET                                 #   and return

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
JNO .dd_dabble_1_noover         # do nothing if no overflow
LDI_BL 3
ALUOP_AL %A+B%+%AL%+%BL%        # add three to AL lower nybble
.dd_dabble_1_noover

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
JNO .dd_dabble_2_noover         # do nothing if no overflow
LDI_BL 0x30
ALUOP_AL %A+B%+%AL%+%BL%        # add 3 to upper nybble
.dd_dabble_2_noover

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

:double_dabble_word
# Performs the double-dabble algirthm to convert a word (in A)
# into a three-byte BCD representation:
#  * BL, lower nybble - ten thousands
#  * AH, upper nybble - thousands
#  * AH, lower nybble - hundreds
#  * AL, upper nybble - tens
#  * AL, lower nybble - units
RET
