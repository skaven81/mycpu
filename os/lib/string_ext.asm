# vim: syntax=asm-mycpu

#####
# String functions evicted from the BIOS ROM (os/bios/lib/string.asm).
# Not part of the BIOS build -- symlink into a consuming ODY program's build
# directory (relative symlink, e.g. `ln -s ../../lib/string_ext.asm
# string_ext.asm`) so it compiles into that program instead of living in
# shared ROM. See os/lib/trace.asm for the precedent of this pattern.
#
# :strcat has a hybrid calling convention (heap-loop of source pointers
# plus a destination address passed directly in register D) -- see the
# accompanying string_ext.h for why it is documented rather than declared
# as a plain C extern.
#####

#######
# Concatenates null-terminated strings referenced on the heap.
#
# After execution, the D register will point at the beginning
# of the concatenated string, and AL will be zero.
#
# Inputs:
#  D: Destination address
#  AL: count of pointers to pop from heap
#  heap: string pointer words

:strcat
PUSH_DH
PUSH_DL
PUSH_CH
PUSH_CL

ALUOP_FLAGS %A%+%AL%
JZ .strcat_done
.strcat_loop
CALL :heap_pop_C
# C now has the address of the string to concatenate
# D has the destination address
CALL :strcpy
# D now points at the end of the concatenated string,
# but has not written a null yet.
ALUOP_AL %A-1%+%AL%
JNZ .strcat_loop
.strcat_done
# Write the final null at the end of D
ALUOP_ADDR_D %zero%
POP_CL
POP_CH
POP_DL
POP_DH
RET
