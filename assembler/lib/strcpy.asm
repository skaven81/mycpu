# vim: syntax=asm-mycpu

#######
# Copies data from one location in RAM (register C)
# to another location in RAM (register D).  Will copy
# until a null byte is encountered, but does not copy
# the null byte itself.  If you want the destination
# string to be null-terminated, write a NULL at address
# in D after returning from this function.
#
# After execution, both C and D will point to the
# address of the null byte.
#
# Inputs:
#  C: Source address
#  D: Destination address

:strcpy
ALUOP_PUSH %A%+%AH%     # save previous AH contents
.loop
LDA_C_AH                # load character from source into AH
ALUOP_FLAGS %A%+%AH%    # check if AH is null
JZ .done                # bail out if it is
ALUOP_ADDR_D %A%+%AH%   # write character from AH to dest
INCR_C                  # move to next source byte
INCR_D                  # move to next dest byte
JMP .loop               # keep looping until AH is null
.done
POP_AH
RET
