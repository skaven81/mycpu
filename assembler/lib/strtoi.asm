# vim: syntax=asm-mycpu

# Functions for converting strings into numbers

######
# strtoi - takes a string and determines the numeric base
# by looking at the first two chars:
#   0x - hexadecimal
#   -[0-9] - negative signed decimal
#   [0-9][0-9] - unsigned decimal
# The C register is placed at the first non-prefix char
# and the appropriate function is called to convert
# the value to an integer.  For a negative signed integer,
# the value is then converted to two's complement.
#
# Inputs:
#  C - address of null-terminated string to convert
#
# Outputs:
#  A - converted number, or 0x0000 if conversion failed
#  BL - flags, will be zero if conversion succeeded
#       0x01 - overflow: number does not fit in 16 bits
#       0x02 - invalid: an unexpected character was encountered
#       0x04 - empty: an empty string was provided
:strtoi
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BH%

# Load the first two chars into BL and BH
LDA_C_BL
ALUOP_FLAGS %B%+%BL%
JZ .strtoi_emptystring
INCR_C
LDA_C_BH
ALUOP_FLAGS %B%+%BH%
JZ .strtoi_handle_onechar

# The string is at least two characters, check the prefix
# and direct conversion accordingly.
LDI_AL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .strtoi_first_is_zero
LDI_AL '-'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .strtoi_handle_negative

# String is at least two characters, and does not
# start with '0x' or '-' so it must be a decimal.
.strtoi_handle_decimal
DECR_C                      # Point C back at the beginning of the string
CALL :strdectoi             # A and BL are now set
JMP .strtoi_done

# The first character is zero, direct conversion based
# on the next character, x=hex, otherwise dec
.strtoi_first_is_zero
LDI_AL 'x'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .strtoi_handle_hex
DECR_C                      # Point C to the first char (the zero)
CALL :strdectoi             # A and BL are now set
JMP .strtoi_done

# The input starts with -, handle as negative signed decimal
.strtoi_handle_negative
CALL :strdectoi             # C was already pointed at first decimal char, now A and BL are set
ALUOP_FLAGS %B%+%BL%        # check for success
JNZ .strtoi_done            # and return now if conversion failed
LDI_BH 0x80                 # check high bit of AH
ALUOP_FLAGS %A&B%+%AH%+%BH% # |
JNZ .strtoi_negative_overflow # and abort if set
CALL :signed_invert_a       # make A negative
LDI_BL 0x00                 # flag success
JMP .strtoi_done

# The decimal conversion succeeded, but the number
# is too large to be turned into a negative number
.strtoi_negative_overflow
LDI_A 0x0000
LDI_BL 0x01                 # flag overflow
JMP .strtoi_done

# The input starts with 0x, handle as hex
.strtoi_handle_hex
INCR_C                      # Point C to the beginning of the hex string
CALL :strhextoi             # A and BL are now set
JMP .strtoi_done

# The input string is just one character, in BL, so it
# must be a decimal char, anything else would be invalid.
.strtoi_handle_onechar
DECR_C                      # Point C back at the beginning of the string
CALL :strdectoi             # A and BL are now set
JMP .strtoi_done

# The input string was empty
.strtoi_emptystring
LDI_A 0x0000                # return zero
LDI_BL 0x04                 # flag that it was an empty string
JMP .strtoi_done

.strtoi_done
POP_BH
POP_CL
POP_CH
RET

######
# strhextoi - takes a string that is expected to contain
# just [0-9a-f] characters, and converts it into a number.
#
# Inputs:
#  C - address of null-terminated string to convert
#
# Outputs:
#  A  - converted number, or 0x0000 if conversion failed
#  BL - flags, will be zero if conversion succeeded
#       0x01 - overflow: number does not fit in 16 bits
#       0x02 - invalid: an unexpected character was encountered
:strhextoi
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
ALUOP_PUSH %B%+%BH%

LDI_A 0x0000                # start with zero in A
# Walk through the string processing chars until we hit a null
.strhextoi_loop
# Fetch next char and ensure it's valid; abort if it's invalid
ALUOP_PUSH %A%+%AL%
LDA_C_AL                    # next character into AL
ALUOP_FLAGS %A%+%AL%
JZ .strhextoi_done          # if we hit null, we are done
LDI_BL '0'
ALUOP_FLAGS %A-B%+%BL%+%AL% # see if char is < '0'
JO .strtoi_invalid_char  # if so, abort
LDI_BL 'f'
ALUOP_FLAGS %B-A%+%BL%+%AL% # see if char is > 'f'
JO .strtoi_invalid_char
LDI_BL '9'
ALUOP_FLAGS %B-A%+%BL%+%AL% # see if char is > '9', but this isn't an immediate fail...
JNO .strhextoi_valid_char
LDI_BL 'a'
ALUOP_FLAGS %A-B%+%BL%+%AL% # ...if it's >= 'a' then it's OK
JO .strtoi_invalid_char
.strhextoi_valid_char       # if we get here, char is [0-9a-f]
ALUOP_BL %A%+%AL%           # put char into BL
POP_AL                      # restore AL

# Valid char, shift A left and make room for the converted BL
CALL :shift16_a_left        # Make room in A for the next 4 bits
JO .strtoi_overflow         # |
CALL :shift16_a_left        # |
JO .strtoi_overflow         # |
CALL :shift16_a_left        # |
JO .strtoi_overflow         # |
CALL :shift16_a_left        # |
JO .strtoi_overflow         # |
CALL :hextoi                # BL is now the integer value
ALUOP_AL %A+B%+%AL%+%BL%    # set lowest four bits
INCR_C                      # move to next char
JMP .strhextoi_loop         # and process it

# Finished successfully
.strhextoi_done
POP_AL                      # restore AL from our strcheck loop
LDI_BL 0x00                 # zero flag means success
POP_BH
POP_DL
POP_DH
POP_CL
POP_CH
RET

# Abort processing and return with an invalid flag
.strtoi_invalid_char
POP_AL                      # restore AL from our strcheck loop
LDI_A 0x0000
LDI_BL 0x02                 # set "invalid" flag
POP_BH
POP_DL
POP_DH
POP_CL
POP_CH
RET

# Abort processing and return with an overflow flag
.strtoi_overflow
LDI_A 0x0000
LDI_BL 0x01                 # set "overflow" flag
POP_BH
POP_DL
POP_DH
POP_CL
POP_CH
RET


######
# strdectoi - takes a string that is expected to contain
# just [0-9] characters, and converts it into an unsigned
# integer.
#
# Inputs:
#  C - address of null-terminated string to convert
#
# Outputs:
#  A  - converted number, or 0x0000 if conversion failed
#  BL - flags, will be zero if conversion succeeded
#       0x01 - overflow: number does not fit in 16 bits
#       0x02 - invalid: an unexpected character was encountered
:strdectoi
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
ALUOP_PUSH %B%+%BH%

LDI_A 0x0000                # start with zero in A
# Walk through string processing chars until we hit a null
.strdectoi_loop
ALUOP_PUSH %A%+%AL%
LDA_C_AL                    # next character into AL
ALUOP_FLAGS %A%+%AL%
JZ .strdectoi_done          # if we hit null, we are done
LDI_BL '0'
ALUOP_FLAGS %A-B%+%BL%+%AL% # see if char is < '0'
JO .strtoi_invalid_char     # if so, abort
LDI_BL '9'
ALUOP_FLAGS %B-A%+%BL%+%AL% # see if char is > '9'
JO .strtoi_invalid_char
.strdectoi_valid_char       # if we get here, char is [0-9]
ALUOP_BL %A%+%AL%           # move AL char into BL
POP_AL                      # restore AL from above

CALL :shift16_a_left        # multiply A by two
JO .strtoi_overflow      
ALUOP_DH %A%+%AH%           # Save A (2a) in D
ALUOP_DL %A%+%AL%           # |
CALL :shift16_a_left        # continue to finish multiplying A by eight
JO .strtoi_overflow         # |
CALL :shift16_a_left        # |
JO .strtoi_overflow         # |
ALUOP_PUSH %B%+%BL%         # Save BL
MOV_DH_BH                   # Get our old 2a value out of D into B
MOV_DL_BL                   # |
CALL :add16_to_a            # 8a+2a=10a
POP_BL                      # Put BL back
JO .strtoi_overflow
CALL :hextoi                # BL is now the integer value
LDI_BH 0x00
CALL :add16_to_a            # add BL to A
JO .strtoi_overflow
INCR_C                      # move to next char
JMP .strdectoi_loop         # and keep processing

# Finished successfully
.strdectoi_done
POP_AL                      # restore AL from strcheck loop
LDI_BL 0x00                 # zero flag means success
POP_BH
POP_DL
POP_DH
POP_CL
POP_CH
RET

#######
# Converts a character 0-9a-f into a number
#
# Inputs:
#  BL - the character - no range checking is done, assumed
#       to be between 0-9 or a-f inclusive.
#
# Outputs:
#  BL - the numeric equivalent of the character
:hextoi
ALUOP_PUSH %A%+%AL%
LDI_AL '9'
ALUOP_FLAGS %A-B%+%AL%+%BL% # if char is a-f this will overflow
JO .hextoi_handle_af
# this is a 0-9 char
LDI_AL '0'
ALUOP_BL %B-A%+%BL%+%AL%    # convert 0-9 to number
POP_AL
RET
.hextoi_handle_af
LDI_AL 'a'
ALUOP_BL %B-A%+%BL%+%AL%    # convert a-f to number
LDI_AL 0x0a
ALUOP_BL %A+B%+%BL%+%AL%    # shift up to a-f (10-15)
POP_AL
RET

