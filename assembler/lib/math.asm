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

