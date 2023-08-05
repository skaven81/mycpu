# vim: syntax=asm-mycpu

# Memory filling functions

########
# memfill - fill a memory range with bytes
#
# Inputs:
#   C - address to begin fill
#  AH - byte to fill
#  AL - number of bytes to fill, minus 1
#
# Outputs:
#   C - at first byte after fill
#  AH - unchanged
#  AL - unchanged
:memfill
ALUOP_PUSH %A%+%AL%
.memfill_loop
ALUOP_ADDR_C %A%+%AH%                   # write byte to current C address
INCR_C                                  # move to next address
ALUOP_AL %A-1%+%AL%                     # decrement A
JNO .memfill_loop                       # if no overflow, continue looping
POP_AL
RET

########
# memfill_blocks - fill a memory range with bytes
#
# Inputs:
#   C - address to begin fill
#  AH - byte to fill
#  AL - number of 16-byte blocks to fill, minus 1
#
# Outputs:
#   C - at first byte after fill
#  AH - unchanged
#  AL - unchanged
:memfill_blocks
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_BL %A%+%AL%                       # copy number of blocks to BL
LDI_AL 15                               # Number of bytes for each memfill call
.memfill_blocks_loop
CALL :memfill                           # write 16 bytes
ALUOP_BL %B-1%+%BL%                     # decrement BL
JNO .memfill_blocks_loop                # if no overflow, keep looping
POP_BL
POP_AL
RET

########
# memfill_segments - fill a memory range with bytes
#
# Inputs:
#   C - address to begin fill
#  AH - byte to fill
#  AL - number of 128-byte segments to fill, minus 1
:memfill_segments
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_BL %A%+%AL%                       # copy number of segments to BL
LDI_AL 127                              # Number of bytes for each memfill call
.memfill_segments_loop
CALL :memfill                           # write 128 bytes
ALUOP_BL %B-1%+%BL%                     # decrement BL
JNO .memfill_segments_loop              # if no overflow, keep looping
POP_BL
POP_AL
RET

