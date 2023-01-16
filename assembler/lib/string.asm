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
# address of the null byte (with D not having yet
# written the null byte)
#
# Inputs:
#  C: Source address
#  D: Destination address

:strcpy
ALUOP_PUSH %A%+%AH%     # save previous AH contents
.strcpy_loop
LDA_C_AH                # load character from source into AH
ALUOP_FLAGS %A%+%AH%    # check if AH is null
JZ .strcpy_done         # bail out if it is
ALUOP_ADDR_D %A%+%AH%   # write character from AH to dest
INCR_C                  # move to next source byte
INCR_D                  # move to next dest byte
JMP .strcpy_loop        # keep looping until AH is null
.strcpy_done
POP_AH
RET

#######
# Prepends a character to the string referenced
# by D. Walks the string until a null is found,
# then extends the string to the right by one
# byte, then inserts the new character at the
# original location.
#
# Inputs:
#  AL: character to insert
#  D: insertion address point
:strprepend
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AL%
LDI_B 0
.strprepend_find_null_loop
LDA_D_AL
ALUOP_FLAGS %A%+%AL%    # Does D point at a null?
JZ .strprepend_found_null
INCR_D
CALL :incr16_b          # count how many bytes we need to copy
JMP .strprepend_find_null_loop
.strprepend_found_null
CALL :incr16_b          # new string is +1 chars so we have +1 char to copy
.strprepend_copy_loop   # D points to null at end of string
LDA_D_AL                # get this character
INCR_D
ALUOP_ADDR_D %A%+%AL%   # copy it one spot to the right
DECR_D
DECR_D                  # move D to spots to the left
CALL :decr16_b
ALUOP_FLAGS %B%+%BL%
JNZ .strprepend_copy_loop
ALUOP_FLAGS %B%+%BH%
JNZ .strprepend_copy_loop
INCR_D                  # Done copying, put D back at the insertion point
POP_AL                  # Restore char to insert from the stack
ALUOP_ADDR_D %A%+%AL%   # Write the character to insert
POP_BL
POP_BH
RET

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

#######
# Compares two strings referenced in C and D.  The result
# is returned in AL, and will be negative if C < D, positive
# if C > D, or zero if C == D.
#
# C and D will point at the addresses where the first difference
# was found, or at the terminating nulls if the strings were
# the same.
#
# Inputs:
#  C: pointer to string 1
#  D: pointer to string 2
# Outputs:
#  AL: result

:strcmp
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%
ALUOP_AL %zero%

.strcmp_loop
# Load the next character
LDA_C_AH
LDA_D_BH
# Done if we found a difference (including C or D is null but the other isn't)
ALUOP_AL %A-B%+%AH%+%BH%
JNZ .strcmp_done
# Done if C (or D, since we know they're the same) is null
ALUOP_FLAGS %A%+%AH%
JZ .strcmp_done
INCR_C
INCR_D
JMP .strcmp_loop
.strcmp_done
POP_BH
POP_AH
RET

