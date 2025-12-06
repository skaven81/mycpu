# vim: syntax=asm-mycpu

:cmd_ascii
# print the header
LDI_AL '\n'
CALL :putchar
LDI_C .header
CALL :print
LDI_C .header2
CALL :print

LDI_AL 0x00             # AL will be our character to print in the grid
LDI_C .hex_str          # easier way to iterate through all 16 hex chars
.ascii_row_loop
# Print the row header on the left
ALUOP_PUSH %A%+%AL%     # save AL (current char
LDA_C_AL                # get the next row header char
CALL :putchar_direct
LDI_AL '|'
CALL :putchar_direct
POP_AL                  # get AL (current char) back
INCR_C                  # move to next row header char

# Print 16 characters
LDI_AH 0x10             # AH is our column counter
.ascii_column_loop
CALL :putchar_direct    # Print the character (AL)
ALUOP_PUSH %A%+%AL%     # And then a space
LDI_AL ' '              # |
CALL :putchar           # |
POP_AL                  # |
ALUOP_AL %A+1%+%AL%     # Move to next character
ALUOP_AH %A-1%+%AH%     # Decrement column counter
JNZ .ascii_column_loop  # If row counter is not zero, keep looping on this row
                        # otherwise, continue to next row

# Prep for next row to print
ALUOP_PUSH %A%+%AL%     # Print a newline
LDI_AL '\n'             # |
CALL :putchar           # |
POP_AL                  # |

# We are done if AL loops around to 0x00 again
ALUOP_FLAGS %A%+%AL%
JNZ .ascii_row_loop

# Print a final newline when we are done
LDI_AL '\n'
CALL :putchar

RET

.header  "  0 1 2 3 4 5 6 7 8 9 a b c d e f\n\0"
.header2 "  -------------------------------\n\0"
.hex_str "0123456789abcdef\0"
