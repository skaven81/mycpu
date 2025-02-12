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
.memcpy_loop
MEMCPY_C_D                              # Copy C to D, incr C&D
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memcpy_loop                        # if no overflow, continue looping
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
.memcpy_blocks_loop
MEMCPY4_C_D                             # Copy 4 bytes C to D, incr C&D
MEMCPY4_C_D                             # Copy 4 bytes C to D, incr C&D
MEMCPY4_C_D                             # Copy 4 bytes C to D, incr C&D
MEMCPY4_C_D                             # Copy 4 bytes C to D, incr C&D
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memcpy_blocks_loop                 # if no overflow, keep looping
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
.memcpy_segments_loop
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # Copy 16 bytes C to D, incr C&D
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
MEMCPY4_C_D                             # |
ALUOP_AL %A-1%+%AL%                     # decrement AL
JNO .memcpy_segments_loop               # if no overflow, keep looping
POP_AL
RET

