# vim: syntax=asm-mycpu

# The sprintf function takes an address in C pointing to a format string,
# and copies it to the memory location in D.  As formatting codes are
# encountered, values are popped from the heap and formatted accordingly.
# All registers are maintained in their original state upon return, with
# C and D still pointing to the beginning of their respective strings.
#
# %% - a literal percent sign
# %c - a byte formatted as ASCII (the raw byte is just inserted into the target string)
# %2 - a byte formatted as binary 1s and 0s
# %b - a BCD byte formatted as decimal, one digit per byte (first four bits are ignored)
# %B - a BCD byte formatted as decimal, two digits per byte
# %x - a byte formatted as hex
# %X - a byte formatted as hex, with capital letters
# %u - a byte formatted as unsigned decimal (0-255)
# %U - a word formatted as unsigned decimal (0-65535)
# %d - a byte formatted as a signed decimal (-128-127)
# %D - a word formatted as a signed decimal (-32768-32767)
# %s - a word used as a pointer to a null-terminated string, which is copied into the formatted string

:sprintf
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# walk through the format string until we encounter a null byte
.fmt_loop
LDA_C_BL
ALUOP_FLAGS %B%+%BL%
JZ .fmt_done

# If this char is not a percent sign, copy it to the destination
# string and loop to the next source character
LDI_AL '%'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_percent
LDA_C_TD
STA_D_TD
INCR_C
INCR_D
JMP .fmt_loop

# the percent itself doesn't get copied to the target string,
# so increment C and load the next character into BL.  Then
# increment C again to move past that character
.handle_percent
INCR_C
LDA_C_BL
INCR_C

# Branch to the appropriate handler
LDI_AL '%'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_literal_percent
LDI_AL 'c'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_char
LDI_AL '2'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_binary
LDI_AL 'b'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_bcd_one
LDI_AL 'B'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_hex     # two-char BCD is equivalent to hex conversion
LDI_AL 'x'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_hex
LDI_AL 'X'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_hex_capital
LDI_AL 'u'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_decimal_byte
LDI_AL 'U'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_decimal_word
LDI_AL 'd'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_signed_decimal_byte
LDI_AL 'D'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_signed_decimal_word
LDI_AL 's'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .handle_string
# If we fall through to here and nothing matched, then it's an invalid
# format string so insert an error message instead of a formatted string
JMP .format_error

.fmt_done
# null-terminate the destination string
LDI_TD 0x00
STA_D_TD

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

#### %% a literal percent
.handle_literal_percent
LDI_TD '%'
STA_D_TD
INCR_D
JMP .fmt_loop


#### %c char
.handle_char
ALUOP_PUSH %A%+%AL%
CALL :heap_pop_AL
ALUOP_ADDR_D %A%+%AL%
INCR_D
POP_AL
JMP .fmt_loop


#### %2 8-bit binary
.handle_binary
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
PUSH_CL

CALL :heap_pop_AL               # get byte from heap
LDI_AH 8

.binary_loop
ALUOP_AL %A<<1%+%AL%            # shift AL left
JO .binary_one                  # if Cout, that was a one
LDI_CL '0'                      # otherwise, it's a zero
JMP .onezero_done
.binary_one
LDI_CL '1'
.onezero_done
STA_D_CL                        # write the zero or one to the output string
INCR_D                          # and move to the next place

ALUOP_AH %A-1%+%AH%
JNZ .binary_loop                # loop 8 times to get all 8 bits

POP_CL
POP_AH
POP_AL
JMP .fmt_loop


#### %b BCD with one char per byte
.handle_bcd_one
CALL .handle_bcd_one_real
JMP .fmt_loop

.handle_bcd_one_real
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_AL               # get byte from heap
LDI_BL 0x0f                     # mask for just lower nybble
ALUOP_AL %A&B%+%AL%+%BL%        # AL now has just the lower nybble
LDI_BL '0'                      # character offset
ALUOP_AL %A+B%+%AL%+%BL%        # AL now has the char we want

ALUOP_ADDR_D %A%+%AL%           # store the converted upper nybble into D
INCR_D                          # and increment the destination address

POP_BL
POP_AL
RET


#### %B BCD with two chars per byte, or
#### %x hex with lowercase chars
.handle_hex
PUSH_CL
LDI_CL 'a'-10
CALL .handle_hex_real
POP_CL
JMP .fmt_loop

#### %X hex with uppercase chars
.handle_hex_capital
PUSH_CL
LDI_CL 'A'-10
CALL .handle_hex_real
POP_CL
JMP .fmt_loop

# The code is the same for upper and lower case, the only difference is
# the offset for the a-f vs A-F, which we stored in CL above.
.handle_hex_real
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_AL               # get byte from heap
ALUOP_BL %A%+%AL%               # copy AL to BL
LDI_BH 0x0f                     # mask for just lower nybble
ALUOP_AL %A&B%+%AL%+%BH%        # AL now has just the lower nybble
ALUOP_BL %B>>1%+%BL%            # shift BL (upper four bits) right four spots
ALUOP_BL %B>>1%+%BL%            # ...
ALUOP_BL %B>>1%+%BL%            # ...
ALUOP_BL %B>>1%+%BL%            # so BL now contains the upper nybble

LDI_AH 9
ALUOP_FLAGS %A-B%+%BL%+%AH%     # if BL is > 9,
JO .hex_letter_upper            # use a-f
LDI_AH '0'                      # otherwise use numbers
JMP .hex_apply_upper
.hex_letter_upper
MOV_CL_AH                       # use letters
.hex_apply_upper
ALUOP_AH %A+B%+%AH%+%BL%        # AH now has the char we want

ALUOP_ADDR_D %A%+%AH%           # store the converted upper nybble into D
INCR_D                          # and increment the destination address

LDI_BH 9
ALUOP_FLAGS %B-A%+%AL%+%BH%     # if AL is > 9,
JO .hex_letter_lower            # use a-f
LDI_BH '0'                      # otherwise use numbers
JMP .hex_apply_lower
.hex_letter_lower
MOV_CL_BH                       # use letters
.hex_apply_lower
ALUOP_BH %A+B%+%BH%+%AL%        # BH now has the char we want

ALUOP_ADDR_D %B%+%BH%           # store the converted upper nybble into D
INCR_D                          # and increment the destination address

POP_BL
POP_BH
POP_AL
POP_AH
RET


#### %u unsigned decimal byte 0-255
.handle_decimal_byte
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
CALL :heap_pop_AL
CALL :double_dabble_byte        # AH+AL now contains BCD representation [00][00]-[02][55]
CALL :heap_push_AH
CALL .handle_bcd_one_real
CALL :heap_push_AL
CALL .handle_hex_real           # hex = BCD representation for doubled digits
POP_AL
POP_AH
JMP .fmt_loop


#### %U unsigned decimal word 0-65535
.handle_decimal_word
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_A
CALL :double_dabble_word        # BL+AH+AL now contains BCD representation
CALL :heap_push_BL
CALL .handle_bcd_one_real
CALL :heap_push_AH
CALL .handle_hex_real           # hex = BCD representation for doubled digits
CALL :heap_push_AL
CALL .handle_hex_real           # hex = BCD representation for doubled digits
POP_BL
POP_AL
POP_AH
JMP .fmt_loop


#### %d signed decimal byte -128-127
.handle_signed_decimal_byte
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_AL
LDI_BL 0b10000000
ALUOP_FLAGS %A&B%+%AL%+%BL%     # check first bit of AL
JZ .sdb_positive                # if negative,
ALUOP_AL %~A%+%AL%              #   invert AL to make it positive
ALUOP_AL %A+1%+%AL%             #   and add one to get absolute value
LDI_BL '-'                      #   write a minus
JMP .sdb_posnegdone
.sdb_positive                   # if positive,
LDI_BL ' '                      #   write a space
.sdb_posnegdone
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :double_dabble_byte        # AH+AL now contains BCD representation [00][00]-[01][27]
CALL :heap_push_AH
CALL .handle_bcd_one_real
CALL :heap_push_AL
CALL .handle_hex_real           # hex = BCD representation for doubled digits
POP_BL
POP_AL
JMP .fmt_loop


#### %D signed decimal word -32768-32767
.handle_signed_decimal_word
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
CALL :heap_pop_A
LDI_BL 0b10000000
ALUOP_FLAGS %A&B%+%AH%+%BL%     # check first bit of AH
JZ .sdw_positive                # if negative,
ALUOP_AL %~A%+%AL%              #   invert AL to make it positive
ALUOP_AH %~A%+%AH%              #   invert AH to make it positive
CALL :incr16_a                  #   and add one to get absolute value
LDI_BL '-'                      #   write a minus
JMP .sdw_posnegdone
.sdw_positive                   # if positive,
LDI_BL ' '                      #   write a space
.sdw_posnegdone
ALUOP_ADDR_D %B%+%BL%
INCR_D
CALL :double_dabble_word        # BL+AH+AL now contains BCD representation
CALL :heap_push_BL
CALL .handle_bcd_one_real
CALL :heap_push_AH
CALL .handle_hex_real           # hex = BCD representation for doubled digits
CALL :heap_push_AL
CALL .handle_hex_real           # hex = BCD representation for doubled digits
POP_BL
POP_AL
POP_AH
JMP .fmt_loop


#### %s string
.handle_string
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_A        # pop the address of the src string from the heap
.fmt_str_loop
LDA_A_BL                # get char from string
ALUOP_FLAGS %B%+%BL%    # check if null
JZ .fmt_str_done        # we don't copy the null, just drop out
ALUOP_ADDR_D %B%+%BL%   # copy char to dest string
INCR_D                  # move to next char in dest string
CALL :incr16_a          # move to next char in src string
JMP .fmt_str_loop

.fmt_str_done
POP_BL
POP_AL
POP_AH
JMP .fmt_loop


#### Invalid formatting code
.format_error
PUSH_CH
PUSH_CL
ALUOP_PUSH %B%+%BL%

LDI_C .errstr
.fmt_err_loop
LDA_C_BL                # get char from error string
ALUOP_FLAGS %B%+%BL%    # check if null
JZ .fmt_err_done        # we don't copy the null, just drop out
ALUOP_ADDR_D %B%+%BL%   # copy char to dest string
INCR_D                  # move to next char in dest string
INCR_C                  # move to next char in err string
JMP .fmt_err_loop

.fmt_err_done
POP_BL
POP_CL
POP_CH
JMP .fmt_loop
.errstr "{ERRFMT}\0"
