# vim: syntax=asm-mycpu

# `colors` -- a quick color reference for anyone designing Odyssey UIs.
# Every swatch is built the same way: set the color with a real terminal
# escape, print a solid block glyph (CP437 0xDB, the full block) in that
# color, reset back to white with ESC[0m, then print -- in white -- the
# exact escape you would type to get that color. Both sections run with
# ANSI mode ($term_flags bit 1) ON, since both rely on the escape parser;
# the command restores $term_flags to 0x00 before it returns.
#
#  1. The 16 named ANSI SGR foreground colors: 30-37 (standard) and
#     90-97 (bright). Color set via ESC[<n>m; label printed as "[<n>m".
#     8 swatches per row; each row closed with ESC[0m + newline.
#  2. All 64 Odyssey color-byte values, 0x00-0x3f. Color set via the
#     Odyssey-native ESC[<v>p escape (v is decimal, and is written
#     straight into $term_current_color); label printed in decimal as
#     "[<v>p" -- the exact escape you would type. 8 per row, newline
#     after each row.
#
# Every token (block + label) is padded to a fixed width with leading /
# trailing spaces so 8 tokens sit in aligned columns inside the 64-column
# terminal without the auto-wrap splitting a token. Section 2's label is
# 1 or 2 digits, so the loop picks a narrow or wide format accordingly.

:cmd_colors
ST $term_render_color 0x01      # color rendering on for the whole command
ST $term_flags 0x02            # ANSI mode on: both sections use the escape parser

# --- Section 1: the 16 named ANSI SGR colors ---
LDI_C .hdr_ansi
CALL :print

LDI_AL 30
CALL .print_swatch
LDI_AL 31
CALL .print_swatch
LDI_AL 32
CALL .print_swatch
LDI_AL 33
CALL .print_swatch
LDI_AL 34
CALL .print_swatch
LDI_AL 35
CALL .print_swatch
LDI_AL 36
CALL .print_swatch
LDI_AL 37
CALL .print_swatch
CALL .swatch_row_end

LDI_AL 90
CALL .print_swatch
LDI_AL 91
CALL .print_swatch
LDI_AL 92
CALL .print_swatch
LDI_AL 93
CALL .print_swatch
LDI_AL 94
CALL .print_swatch
LDI_AL 95
CALL .print_swatch
LDI_AL 96
CALL .print_swatch
LDI_AL 97
CALL .print_swatch
CALL .swatch_row_end

# --- Section 2: all 64 Odyssey color bytes via ESC[<v>p ---
LDI_C .hdr_raw
CALL :print

LDI_AL 0x00
LDI_BL 0x40
LDI_BH 0x08                     # tokens remaining in the current row of 8
.raw_loop
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .raw_loop_done
CALL :heap_push_AL             # value for the "[<v>p" decimal label
CALL :heap_push_AL             # value for the "%d" that feeds ESC[<v>p
# pick a narrow (1-digit) or wide (2-digit) label so the columns line up
ALUOP_PUSH %B%+%BL%           # save the 0x40 row-terminator sentinel
LDI_BL 0x0a
LDI_C .raw_label_narrow
ALUOP_FLAGS %A-B%+%AL%+%BL%    # AL - 10; O set when AL < 10
JO .raw_emit                   # 1-digit value -- keep the narrow label
LDI_C .raw_label_wide
.raw_emit
POP_BL                         # restore the sentinel
CALL :printf
ALUOP_AL %A+1%+%AL%
ALUOP_BH %B-1%+%BH%            # row countdown -- also latches flags
JNZ .raw_loop
LDI_C :str_nl
CALL :print                     # row of 8 done -- break the line
LDI_BH 0x08
JMP .raw_loop
.raw_loop_done

ST $term_flags 0x00            # back to the fast/default terminal path
ST $term_render_color 0x00
RET

######
# Prints one named-SGR color swatch: ESC[<n>m, block, ESC[0m, then the
# label "[<n>m" in white. The SGR number in AL is pushed twice -- both %d
# specifiers in .swatch_fmt consume it, so the label can never drift out
# of sync with the color actually applied.
#
# Inputs:
#  AL - SGR foreground code (30-37 or 90-97)
.print_swatch
CALL :heap_push_AL
CALL :heap_push_AL
LDI_C .swatch_fmt
CALL :printf
RET

.swatch_row_end
LDI_C .row_end_fmt
CALL :print
RET

.hdr_ansi "ANSI SGR colors (ESC[Nm):\n\0"
.swatch_fmt 0x1b "[%dm" 0xdb 0x1b "[0m [%dm \0"
.row_end_fmt 0x1b "[0m\n\0"
.hdr_raw "\nOdyssey color bytes (ESC[Np), N in decimal:\n\0"
.raw_label_narrow 0x1b "[%dp" 0xdb 0x1b "[0m [%dp  \0"
.raw_label_wide 0x1b "[%dp" 0xdb 0x1b "[0m [%dp \0"
