# vim: syntax=asm-mycpu

# Memory copying functions

########
# memcpy - copy memory range
#
# Inputs:
#   C - source address
#   D - destination address
#  AL - number of bytes to copy, minus 1
#
# Outputs:
#   C - at first byte after range
#   D - at first byte after range
#  AL - unchanged
:memcpy
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
.memcpy_loop
LDA_C_AH                                # retrieve byte from source
ALUOP_ADDR_D %A%+%AH%                   # write byte to destination
INCR_C                                  # move to next address
INCR_D
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memcpy_loop                        # if no overflow, continue looping
POP_AH
POP_AL
RET

########
# memcpy_blocks - copy memory range in 16-byte blocks
#
# Inputs:
#   C - source address
#   D - destination address
#  AL - number of 16-byte blocks to copy, minus 1
#
# Outputs:
#   C - at first byte after range
#   D - at first byte after range
#  AL - unchanged
:memcpy_blocks
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_BL %A%+%AL%                       # copy number of blocks to BL
LDI_AL 15                               # Number of bytes for each memcpy call
.memcpy_blocks_loop
CALL :memcpy                            # copy 16 bytes
ALUOP_BL %B-1%+%BL%                     # decrement BL
JNO .memcpy_blocks_loop                 # if no overflow, keep looping
POP_BL
POP_AL
RET

########
# memcpy_segments - copy memory range in 128-byte segments
#
# Inputs:
#   C - source address
#   D - destination address
#  AL - number of 128-byte segments to copy, minus 1
:memcpy_segments
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_BL %A%+%AL%                       # copy number of segments to BL
LDI_AL 127                              # Number of bytes for each memcpy call
.memcpy_segments_loop
CALL :memcpy                            # copy 128 bytes
ALUOP_BL %B-1%+%BL%                     # decrement BL
JNO .memcpy_segments_loop               # if no overflow, keep looping
POP_BL
POP_AL
RET

