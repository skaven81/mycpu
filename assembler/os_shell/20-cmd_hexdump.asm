# vim: syntax=asm-mycpu

# View a range of data in hex and ASCII in table format

# This is not a complete implementation and still needs more work. The current method of using
# a format string is not great, because inserting all the color codes is a challenge. Right now
# it's not possible to display hex 0x40 (@) in the ASCII column because the :printf routine
# thinks its a color code and there's no easy way to insert another '@' to make it ignore it.
#
# What should be done instead is to use a format string for the address and hex part of the
# line, then go into a loop to print the ascii part of the line, inserting extra control characters
# as necessary into the output string to get the desired result.

:cmd_hexdump

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Get our second argument
LDI_D $user_input_tokens+4      # D points at second argument pointer
LDA_D_AH                        # put high byte of second arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of second arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Handle two-arg form
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_start_address
ALUOP_PUSH %A%+%AH%             # store start address on the stack for now
ALUOP_PUSH %A%+%AL%             # |

LDI_A $user_input_tokens+4      # Get pointer to second arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
LDA_C_BL                        # Get first char of arg into BL
ALUOP_PUSH %A%+%AL%
LDI_AL '+'
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is first char '+'?
POP_AL
JEQ .get_end_from_range

# second arg is not a range modifier, so just
# process it as a second address
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_end_address
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%               # Copy end address into B
POP_AL
POP_AH                          # Pop start address into A
JMP .process_range

# second arg is a range modifier
.get_end_from_range
INCR_C                          # move to first char after the +
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_range
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%               # Copy range into B
POP_AL
POP_AH                          # Pop start address into A
CALL :add16_to_b                # B=B+A -> end address

# A contains start address
# B contains end address
# We need both to be aligned on 16-byte rows, so we reset the last
# four bits of A, and set the last four bits of B
.process_range
ALUOP_PUSH %B%+%BL%             # Save BL for later
LDI_BL 0x0f                     # Bits to clear in AL
ALUOP_AL %A&~B%+%AL%+%BL%       # clear bits in AL
POP_BL                          # Restore BL
ALUOP_PUSH %A%+%AL%             # Save AL for later
LDI_AL 0x0f                     # Bits to clear in AL
ALUOP_BL %A|B%+%AL%+%BL%        # set bits in BL
POP_AL                          # Restore AL

# Turn color rendering on
ST $term_color_enabled 0x01

# Print start and end addresses
CALL :heap_push_BL
CALL :heap_push_BH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .start_end_str
CALL :printf

.process_range_loop
ALUOP_PUSH %B%+%BL%             # Save end address for the comparison later
ALUOP_PUSH %B%+%BH%
LDI_BL 0x0f
ALUOP_AL %A|B%+%AL%+%BL%        # Set A to the end of this 16-byte row

# Push 16 bytes from xxxf to xxx0 onto heap, for the ASCII columns
.ascii_loop
LDA_A_SLOW_PUSH                 # Fetch byte at A
POP_BH                          # and put it in BH
ALUOP_FLAGS %B%+%BH%            # Check if null
JNZ .is_at                      # If not, is it an at symbol?
LDI_BH '.'                      # Otherwise, load a non-null char to be printed
JMP .pushbh
.is_at
ALUOP_PUSH %A%+%AL%
LDI_AL '@'
ALUOP_FLAGS %A&B%+%AL%+%BH%
POP_AL
JNE .pushbh
LDI_BH '.'
.pushbh
CALL :heap_push_BH              # push byte at address
ALUOP_BL %B-1%+%BL%             # Decrement counter
JO .ascii_loop_done             # Done looping if BL overflows
ALUOP_AL %A-1%+%AL%             # Otherwise decrement AL...
JMP .ascii_loop                 # ...and loop again

.ascii_loop_done
LDI_BL 0x0f
ALUOP_AL %A|B%+%AL%+%BL%        # Set A to the end of this 16-byte row

# Push the same 16 bytes again, for the HEX columns
.hex_loop
LDA_A_SLOW_PUSH                 # Fetch byte at A
POP_DL                          # and put it in DL
CALL :heap_push_DL              # push byte at address
ALUOP_BL %B-1%+%BL%             # Decrement counter
JO .hex_loop_done               # Done looping if BL overflows
ALUOP_AL %A-1%+%AL%             # Otherwise decrement AL...
JMP .hex_loop                   # ...and loop again

.hex_loop_done
# A is back at the xxx0 address, so push that for the address column
CALL :heap_push_AL
CALL :heap_push_AH

# Print the row
ALUOP_PUSH %B%+%BL%
LDI_BL 0x10
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_BL
JZ .use_row_format1
LDI_C .row_format2
JMP .do_print
.use_row_format1
LDI_C .row_format1
.do_print
ST $term_print_raw 0x01
CALL :printf
ST $term_print_raw 0x00
# Print the newline
ALUOP_PUSH %A%+%AL%
LDI_AL '\n'
CALL :putchar
POP_AL

# Increment start address to next row
LDI_BH 0x00
LDI_BL 0x10
CALL :add16_to_a

# Restore end address from stack
POP_BH
POP_BL
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

# If B-A overflows, we are done
CALL :sub16_b_minus_a
POP_BH
POP_BL
JNO .process_range_loop
# Turn color rendering off
ST $term_color_enabled 0x00
RET

.abort_bad_start_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_start_addr_str
CALL :printf
RET

.abort_bad_end_address
POP_TD                          # the start address was on the stack,
POP_TD                          # so we need to discard it.
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_end_addr_str
CALL :printf
RET

.abort_bad_range
POP_TD                          # the start address was on the stack,
POP_TD                          # so we need to discard it.
CALL :heap_push_BL
DECR_C                          # back to the "+"
CALL :heap_push_C
LDI_C .bad_range_str
CALL :printf
RET


.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: hexdump <start-addr> {<end-addr>|+<delta>}\n\0"
.bad_start_addr_str "Error: %s is not a valid start address. strtoi flags: 0x%x\n\0"
.bad_end_addr_str "Error: %s is not a valid end address. strtoi flags: 0x%x\n\0"
.bad_range_str "Error: %s is not a valid range specifier. strtoi flags: 0x%x\n\0"
.start_end_str "Dump of 0x%x%x - 0x%x%x\n\0"
.row_format1 "@350x%x%x@37|@33%x@36%x@33%x@36%x @33%x@36%x@33%x@36%x @33%x@36%x@33%x@36%x @33%x@36%x@33%x@36%x@37|@33%c@36%c@33%c@36%c @33%c@36%c@33%c@36%c @33%c@36%c@33%c@36%c @33%c@36%c@33%c@36%c@37|\0"
.row_format2 "@250x%x%x@37|@23%x@26%x@23%x@26%x @23%x@26%x@23%x@26%x @23%x@26%x@23%x@26%x @23%x@26%x@23%x@26%x@37|@23%c@26%c@23%c@26%c @23%c@26%c@23%c@26%c @23%c@26%c@23%c@26%c @23%c@26%c@23%c@26%c@37|\0"
