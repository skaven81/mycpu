# vim: syntax=asm-mycpu

# Previews the terminal's color codes. Two sections:
#  1. The 16 named ANSI SGR foreground colors (30-37 standard, 90-97
#     bright) -- each swatch is set via a real ESC[NNm escape and labeled
#     with that same SGR number, so this is a genuine preview of what
#     each ANSI color CODE looks like (replaces the old @-code grid,
#     which both set color AND printed its own @-code as the label).
#  2. All 64 raw Odyssey color-byte values (0x00-0x3f), swept via direct
#     framebuffer color writes (TERMINAL_REFACTOR.md 2.2.4/2.2.5) rather
#     than ANSI -- 256-color SGR (38;5;n) was cut from the BIOS during
#     the Phase 2 ROM-budget gate, so this is the only way left to reach
#     values ANSI can't name. Labeled with the raw hex byte, since that's
#     what it actually is, not an ANSI code.

:cmd_colors
ST $term_render_color 0x01      # color rendering on for the whole command

# --- Section 1: named ANSI SGR colors ---
ST $term_flags 0x02             # ANSI mode on so the SGR escapes below apply
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

ST $term_flags 0x00             # ANSI parsing off; section 2 is plain text

# --- Section 2: raw color bytes (direct framebuffer) ---
LDI_C .hdr_raw
CALL :print

LDI_AL 0x00
LDI_BL 0x40
.raw_loop
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .raw_loop_done
ALUOP_ADDR %A%+%AL% $term_current_color   # set the raw color byte directly
CALL :heap_push_AL
LDI_C .raw_label_fmt
CALL :printf
ALUOP_AL %A+1%+%AL%
JMP .raw_loop
.raw_loop_done
LDI_C :str_nl
CALL :print              # not a bare putchar -- see :print's header

ST $term_render_color 0x00
RET

######
# Prints one ANSI color swatch: sets the SGR color in AL and prints that
# same number as the label (one heap value, pushed twice -- both %u
# specifiers in .swatch_fmt consume it, so the label can never drift out
# of sync with the color actually applied).
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

.hdr_ansi "ANSI SGR colors:\n\0"
.swatch_fmt 0x1b "[%um%u \0"
.row_end_fmt 0x1b "[0m\n\0"
.hdr_raw "\nRaw color bytes (direct framebuffer):\n\0"
.raw_label_fmt "0x%x \0"
