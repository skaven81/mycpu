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

#######
# Splits a string, into multiple strings.
#
# Walks the string referenced in C, and upon encountering the split character
# (AH), callocs some memory and copies the token into it.  Contiguous split
# characters are ignored.
#
# Upon return, the array referenced by D will contain pointers to the split
# strings, with a pair of null values marking the end of the list.  AH will contain
# the number of tokens that were found (and thus the number of pointers in
# the target array).
#
# Inputs:
#  AH: character to split the string by
#  AL: size of calloc allocation, as number of 16-byte blocks minus 1
#   C: address of null-terminated string to split
#   D: address of array where token pointers will be stored
#
# Outputs:
#  AH: number of tokens found
:strsplit
CALL :heap_push_all

# Handle the corner case of C pointing at any empty string
LDA_C_BL
ALUOP_FLAGS %B%+%BL%
JNZ .strsplit_loop_start                # start normal tokenizing if first char is non-null
ALUOP_ADDR_D %zero%                     # otherwise, store two NULLs in the array referenced by D
INCR_D                                  # |
ALUOP_ADDR_D %zero%                     # '
CALL :heap_pop_all                      # restore all the registers
LDI_AH 0                                # set AH (number of tokens) to zero
RET                                     # and return

.strsplit_loop_start
LDI_BH 0                                # initialize token counter (BH)
.strsplit_loop_newtoken
# Start by allocating a new memory block for the next token
CALL :heap_push_A                       # Save A as we're going to overwrite it when calling calloc
CALL :calloc                            # A now contains a pointer to allocated memory
ALUOP_ADDR_D %A%+%AH%                   # Save high byte of pointer to token array
INCR_D
ALUOP_ADDR_D %A%+%AL%                   # Save low byte of pointer to token array
INCR_D
PUSH_DL                                 # Save token array pointer for later
PUSH_DH

ALUOP_DH %A%+%AH%                       # Copy destination string pointer to D
ALUOP_DL %A%+%AL%                       # '
CALL :heap_pop_A                        # Restore AH (split character)
                                        # Restore AL (calloc size)
ALUOP_BH %B+1%+%BH%                     # Increment BH (number of tokens)
.strsplit_loop_copystring
# Copy the source string (C) to the destination string (D)
# until we encounter the split character (AH)
LDA_C_BL                                # next character from source string into BL
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .strsplit_loop_skipsplitchars       # check if character (BL) is is the split char (AH)
ALUOP_FLAGS %B%+%BL%
JZ .strsplit_loop_done                  # check if character (BL) is is null
ALUOP_ADDR_D %B%+%BL%                   # not the split char or NULL, so write the character to the target string
INCR_D                                  # and move to the next target char
INCR_C                                  # and move to the next source char
JMP .strsplit_loop_copystring           # then loop back to copying

.strsplit_loop_skipsplitchars           # if we are here, C points at a split char
INCR_C                                  # move to next source char
LDA_C_BL                                # next character from source string into BL
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .strsplit_loop_skipsplitchars       # continue looping if character (BL) == split character (AH)
ALUOP_FLAGS %B%+%BL%
JZ .strsplit_loop_done                  # bail if we encounter a NULL
POP_DH                                  # otherwise,
POP_DL                                  #  Restore token array pointer into D
JMP .strsplit_loop_newtoken             #  and allocate a new string and continue copying

.strsplit_loop_done
# We arrive here when the source string (C) points at a NULL
POP_DH                                  # Restore token array pointer into D
POP_DL
ALUOP_ADDR_D %zero%                     # write the terminating NULLs to the array
INCR_D
ALUOP_ADDR_D %zero%
ALUOP_PUSH %B%+%BH%                     # save BH (token counter) on stack
CALL :heap_pop_all
POP_AH                                  # and restore it into AH
RET
