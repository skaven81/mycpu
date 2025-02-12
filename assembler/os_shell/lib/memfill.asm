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
PUSH_DL
ALUOP_DL %A%+%AH%                       # copy fill byte to DL where it's faster to loop
.memfill_loop
STA_C_DL                                # write byte to current C address
INCR_C                                  # move to next address
ALUOP_AL %A-1%+%AL%                     # decrement A
JNO .memfill_loop                       # if no overflow, continue looping
POP_DL
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
ALUOP_PUSH %A%+%AH%                     # fill byte is top of stack
.memfill_blocks_loop
MEMFILL4_C_PEEK                         # write 4 bytes + incr C
MEMFILL4_C_PEEK                         # write 4 bytes + incr C
MEMFILL4_C_PEEK                         # write 4 bytes + incr C
MEMFILL4_C_PEEK                         # write 4 bytes + incr C
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memfill_blocks_loop                # if no overflow, keep looping
POP_AH
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
ALUOP_PUSH %A%+%AH%
.memfill_segments_loop
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # write 16 bytes + incr C
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
MEMFILL4_C_PEEK                         # |
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memfill_segments_loop              # if no overflow, keep looping
POP_AH
POP_AL
RET

