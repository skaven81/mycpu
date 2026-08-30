# vim: syntax=asm-mycpu

# ANSI escape-sequence state machine, including SGR (color/attribute)
# handling. Replaces the old @-code color parser entirely -- there is no
# @-code handling anywhere in this terminal subsystem.
#
# :putchar (terminal_output.asm) does the ESC-detection and calls
# :ansi_feed for every character while $ansi_state != 0. This file owns
# everything from the first post-ESC character onward.
#
# Not a hot path (bounded by human typing speed or the rare escape-heavy
# print burst), so these routines favor clarity and code size over
# instruction count -- liberal callee-save, no register-sharing tricks.
#
# 256-color/truecolor SGR (`38;5;n` / `38;2;r;g;b` and the `48;...`
# background forms) is deliberately NOT implemented. The Odyssey has no
# background color and only 4 shades per channel, so faithfully mapping
# the xterm-256 cube buys nothing the native color escape below doesn't
# do more directly. All four forms are recognized just far enough to be
# silently discarded as a whole sequence (see the 38/48 lookahead in
# .ansi_semicolon below) rather than mis-dispatched -- e.g. without that,
# "38;5;9" would apply code 5 (blink on) as a side effect.
#
# `ESC [ <v> p` (final byte 'p', ECMA-48 private-use range) is the
# Odyssey-native color escape: it writes <v> (0-255) straight into
# $term_current_color and enables color rendering -- an inline
# equivalent of a direct color-plane write, reaching all 64 colors plus
# the blink (0x80) and cursor (0x40) bits. Values > 255 are rejected as
# an oversized parameter, same as anywhere else in the parser. Setting
# the cursor bit this way leaves stray marks (see cursor_display_sync);
# that is inherent to direct color writes, not specific to this escape.
#
# The 16-color SGR codes (30-37/90-97), the attribute codes
# (0/1/5/22/25), ESC[s / ESC[u cursor save-restore, and every non-SGR
# sequence are fully implemented. .sgr_color_table (the 16-color lookup)
# is a genuinely read-only constant and stays as label data -- ROM
# residency is exactly right for that.
VAR global byte $ansi_state
VAR global 8 $ansi_param_buf
VAR global byte $ansi_param_count
VAR global word $ansi_accum
VAR global byte $ansi_private
VAR global 16 $ansi_seq_buf
VAR global byte $ansi_seq_len
VAR global word $ansi_erase_offset
VAR global word $ansi_erase_count
VAR global byte $ansi_discard
VAR global byte $ansi_sgr_index
VAR global byte $ansi_sgr_pending_shade

######
# Feeds one character into the ANSI parser. Only called while $ansi_state
# is 1 (waiting for '[') or 2 (accumulating a CSI sequence) -- the initial
# ESC that sets state to 1 is handled inline by :putchar and never reaches
# here.
#
# Every character passed in is recorded into $ansi_seq_buf first (for
# error-recovery flushing), then dispatched per the current state.
#
# Inputs:
#  AL - character to feed
# All registers preserved.
:ansi_feed
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

ALUOP_DH %A%+%AL%                    # stash the incoming char in DH

# --- append to $ansi_seq_buf, checking overflow ---
LD_BL $ansi_seq_len
LDI_AH 16
ALUOP_FLAGS %AxB%+%AH%+%BL%          # buffer already full?
JEQ .ansi_invalid

LDI_A $ansi_seq_buf
LDI_BH 0x00
ALUOP16O_A %ALU16_A+B%               # A = seq_buf base + seq_len
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # C = &seq_buf[seq_len]
MOV_DH_AL                            # AL = char again (DH untouched)
ALUOP_ADDR_C %A%+%AL%
LD_BL $ansi_seq_len
ALUOP_BL %B+1%+%BL%
ALUOP_ADDR %B%+%BL% $ansi_seq_len

# --- dispatch on parser state (AL is still the char) ---
LD_BL $ansi_state
LDI_AH 0x01
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .ansi_state1
JMP .ansi_state2

# --- state 1: waiting for '[' ---
.ansi_state1
LDI_BL 0x5b                          # '['
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .ansi_invalid                    # ESC not followed by '[' -- invalid
ST $ansi_state 0x02
ST $ansi_param_count 0x00
ST16 $ansi_accum 0x0000
ST $ansi_private 0x00
ST $ansi_discard 0x00
JMP .ansi_return

# --- state 2: accumulating a CSI sequence ---
.ansi_state2
LDI_BL 0x30
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff AL < 0x30
JO .ansi_invalid
LDI_BL 0x3a
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff AL < 0x3a (i.e. a digit)
JO .ansi_digit
LDI_BL 0x3b                          # ';'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .ansi_semicolon
LDI_BL 0x3f                          # '?'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .ansi_private_flag
LDI_BL 0x40
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff AL < 0x40
JO .ansi_invalid
LDI_BL 0x7f
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff AL < 0x7f
JO .ansi_final_byte
JMP .ansi_invalid                    # >= 0x7f -- out of final-byte range

.ansi_digit
LDI_BL 0x30
ALUOP_AL %A-B%+%AL%+%BL%             # AL = digit value 0-9
CALL .ansi_accum_digit
LD_BL $ansi_accum                    # hi byte -- nonzero means value > 255
ALUOP_FLAGS %B%+%BL%
JNZ .ansi_invalid
JMP .ansi_return

.ansi_semicolon
LD_BL $ansi_discard
ALUOP_FLAGS %B%+%BL%
JNZ .ansi_semicolon_discarding

# 38/48 lookahead: 256-color/truecolor SGR are not implemented (see this
# file's header), so ANY parameter immediately following 38 or 48 begins an
# extended color spec this parser doesn't support. Drop the whole
# sequence silently (valid-but-unsupported) rather than mis-dispatching
# its sub-parameters as if they were independent SGR codes -- e.g.
# without this, "38;5;9" would apply code 5 (blink on) as a side effect.
LD_BL $ansi_param_count
ALUOP_FLAGS %B%+%BL%
JZ .semicolon_store                   # the 2 has no previous param
ALUOP_BL %B<<1%+%BL%
ALUOP_BL %B-1%+%BL%                   # BL = count*2 - 1: offset of the
LDI_BH 0x00                           # previous param's low byte
LDI_A $ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL                              # AL = previous param value
LDI_BL 38
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .semicolon_discard
LDI_BL 48
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .semicolon_store
.semicolon_discard
ST $ansi_discard 0x01
.ansi_semicolon_discarding
ST16 $ansi_accum 0x0000
JMP .ansi_return

.semicolon_store
LD_BL $ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%          # already have 4 params stored?
JEQ .ansi_invalid
CALL .ansi_store_param
JMP .ansi_return

.ansi_private_flag
ST $ansi_private 0x01
JMP .ansi_return

.ansi_final_byte
LD_BL $ansi_discard
ALUOP_FLAGS %B%+%BL%
JNZ .ansi_finish                     # discarded truecolor: drop the whole
                                      # sequence silently -- never dispatch
                                      # with its half-stored params

LD_BL $ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .ansi_invalid
CALL .ansi_store_param                # finalize the trailing parameter
CALL .ansi_dispatch_command            # AL is still the final byte
JMP .ansi_finish

# --- shared exits ---
.ansi_invalid
CALL :ansi_flush
JMP .ansi_epilogue

.ansi_finish
CALL :ansi_reset
JMP .ansi_epilogue

.ansi_return
.ansi_epilogue
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Flushes the buffered raw characters in $ansi_seq_buf to the screen
# via :putchar_raw (bypassing the parser), then resets it. Used both
# for parser error recovery and by :print when a string ends mid-sequence
# (an ESC or an incomplete CSI sequence right before the terminating null).
:ansi_flush
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
LDI_C $ansi_seq_buf
LD_BL $ansi_seq_len
ALUOP_FLAGS %B%+%BL%
JZ .flush_empty
.flush_loop
LDA_C_AL
CALL :putchar_raw
INCR_C
ALUOP_BL %B-1%+%BL%
JNZ .flush_loop
.flush_empty
CALL :ansi_reset
POP_CL
POP_CH
POP_BL
POP_AL
RET

######
# Resets the parser to state 0 with an empty sequence buffer. Does not
# print anything -- callers that need to show the buffered characters
# must go through :ansi_flush instead.
:ansi_reset
ST $ansi_state 0x00
ST $ansi_param_count 0x00
ST16 $ansi_accum 0x0000
ST $ansi_private 0x00
ST $ansi_seq_len 0x00
ST $ansi_discard 0x00
RET

######
# Multiplies $ansi_accum by 10 and adds a single decimal digit.
#
# Inputs:
#  AL - digit value (0-9)
# All registers preserved.
.ansi_accum_digit
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_DH
ALUOP_DH %A%+%AL%                    # stash digit in DH (survives the
                                      # A/B scratch use below)

LD16_B $ansi_accum
ALUOP16O_B %ALU16_B<<1%              # B = accum*2
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ALUOP16O_B %ALU16_B<<1%              # B = accum*4
ALUOP16O_B %ALU16_B<<1%              # B = accum*8
POP_AL
POP_AH                                # A = accum*2
ALUOP16O_B %ALU16_A+B%                # B = accum*10
MOV_DH_AL                             # AL = digit (from DH)
LDI_AH 0x00                           # zero-extend digit into A
ALUOP16O_B %ALU16_A+B%                # B = accum*10 + digit
ALUOP_ADDR %B%+%BH% $ansi_accum
ALUOP_ADDR %B%+%BL% $ansi_accum+1

POP_DH
POP_BL
POP_BH
POP_AH
RET

######
# Stores $ansi_accum into $ansi_param_buf[$ansi_param_count], increments
# the count, and resets the accumulator. Caller must ensure
# param_count < 4 before calling.
.ansi_store_param
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
LD_BL $ansi_param_count
LDI_BH 0x00
ALUOP_BL %B<<1%+%BL%                 # BL = param_count*2 (word offset)
LDI_A $ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # C = &param_buf[param_count]
LD16_A $ansi_accum
ALUOP_ADDR_C %A%+%AH%
INCR_C
ALUOP_ADDR_C %A%+%AL%
LD_BL $ansi_param_count
ALUOP_BL %B+1%+%BL%
ALUOP_ADDR %B%+%BL% $ansi_param_count
ST16 $ansi_accum 0x0000
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Returns n (movement count) for A/B/C/D sequences: param[0] if a
# nonzero param was given, else the default of 1.
#
# Outputs:
#  BL - n
.ansi_get_n
LD_AL $ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .getn_default
LD_BL $ansi_param_buf+1
ALUOP_FLAGS %B%+%BL%
JNZ .getn_done
.getn_default
LDI_BL 0x01
.getn_done
RET

######
# Returns the mode parameter for J/K sequences: param[0] if given
# (0 is a valid mode, not a "use default" sentinel here), else 0.
#
# Outputs:
#  AL - mode
.ansi_get_mode
LD_AL $ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .getmode_default
LD_AL $ansi_param_buf+1
RET
.getmode_default
LDI_AL 0x00
RET

######
# Returns the fill color byte used by J/K erase commands (Part 3
# decision: current color & 0x3F when render is on, else white).
#
# Outputs:
#  BL - fill color byte
.ansi_get_erase_color
LD_BL $term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .getcolor_white
LD_BL $term_current_color
LDI_AH 0x3f
ALUOP_BL %A&B%+%AH%+%BL%
RET
.getcolor_white
LDI_BL 0x3f
RET

######
# value = max(0, value - n)
#
# Inputs:
#  AL - value, BL - n
# Outputs:
#  AL - clamped result
.ansi_dec_clamp0
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff value < n
JO .decclamp_zero
ALUOP_AL %A-B%+%AL%+%BL%
RET
.decclamp_zero
LDI_AL 0x00
RET

######
# value = min(max, value + n) -- used for both the row axis (max=59, from
# .disp_down) and the column axis (max=63, from .disp_right). Merged from
# two near-identical copies (max used to be a baked-in constant); the ALU
# can read the new max input straight off the B-port, so this is actually
# fewer instructions than either original copy, not just de-duplicated.
#
# Inputs:
#  AL - value, BL - n, BH - max
# Outputs:
#  AL - clamped result
# Clobbers: AH.
.ansi_inc_clamp
ALUOP_AH %B-A%+%BH%+%AL%             # AH = room = max - value
ALUOP_FLAGS %A-B%+%AH%+%BL%          # O set iff room < n
JO .incclamp_max
ALUOP_AL %A+B%+%AL%+%BL%
RET
.incclamp_max
ALUOP_AL %B%+%BH%                    # AL = max (still in BH)
RET

#######
## Fills count bytes starting at D with the byte in BL.
##
## Inputs:
##  D - start address
##  A - count (16-bit, 0 is a valid no-op)
##  BL - fill byte
## Clobbers: A, D.
#.ansi_fill_range
#ALUOP16Z_FLAGS %ALU16_Azero%
#JZ .fillrange_done
#.fillrange_loop
#ALUOP_ADDR_D %B%+%BL%
#INCR_D
#ALUOP16O_A %ALU16_A-1%
#ALUOP16Z_FLAGS %ALU16_Azero%
#JNZ .fillrange_loop
#.fillrange_done
#RET
#
#######
## Erases a range of the display, chars filled with 0x00 and colors
## filled per :ansi_get_erase_color, sharing the range across both
## framebuffers. Used by the J/K erase commands.
##
## Inputs:
##  A - start offset within the display page (0-3839)
##  B - count (16-bit)
#.ansi_erase_range
#ALUOP_ADDR %A%+%AH% $ansi_erase_offset
#ALUOP_ADDR %A%+%AL% $ansi_erase_offset+1
#ALUOP_ADDR %B%+%BH% $ansi_erase_count
#ALUOP_ADDR %B%+%BL% $ansi_erase_count+1
#
#LDI_A %display_chars%
#LD16_B $ansi_erase_offset
#ALUOP16O_A %ALU16_A+B%
#ALUOP_DH %A%+%AH%
#ALUOP_DL %A%+%AL%
#LD16_A $ansi_erase_count
#LDI_BL 0x00
#CALL .ansi_fill_range
#
#LDI_A %display_color%
#LD16_B $ansi_erase_offset
#ALUOP16O_A %ALU16_A+B%
#ALUOP_DH %A%+%AH%
#ALUOP_DL %A%+%AL%
#CALL .ansi_get_erase_color            # BL = fill color; clobbers A, so
#                                       # fetch it before loading the count
#LD16_A $ansi_erase_count
#CALL .ansi_fill_range
#RET
#
######
# Executes the command selected by the final byte in AL, using the
# parameters already stored in $ansi_param_buf/_count and $ansi_private.
# A syntactically valid but unrecognized/unsupported final byte is a
# silent no-op -- the sequence has already been consumed by the parser,
# it just doesn't do anything.
#
# Inputs:
#  AL - final byte
.ansi_dispatch_command
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

LDI_BL 0x41                          # 'A'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_up
LDI_BL 0x42                          # 'B'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_down
LDI_BL 0x43                          # 'C'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_right
LDI_BL 0x44                          # 'D'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_left
LDI_BL 0x48                          # 'H'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_gotorc
LDI_BL 0x66                          # 'f'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_gotorc
LDI_BL 0x4a                          # 'J' (mode-2 full clear only; see
ALUOP_FLAGS %AxB%+%AL%+%BL%          # .disp_erase_screen)
JEQ .disp_erase_screen
# 'K' (erase-line) is CUT/DISABLED, same as J's partial modes below --
# both were dropped to help fit the 16 KiB ROM budget. Restore by
# uncommenting this dispatch entry and .disp_erase_line, and the
# .ansi_fill_range/.ansi_erase_range helpers above (also commented).
#LDI_BL 0x4b                          # 'K'
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .disp_erase_line
LDI_BL 0x68                          # 'h'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_h
LDI_BL 0x6c                          # 'l'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_l
LDI_BL 0x6d                          # 'm'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_sgr
LDI_BL 0x70                          # 'p' -- Odyssey native color (non-spec)
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_setcolor
LDI_BL 0x73                          # 's' -- save cursor position
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_savecursor
LDI_BL 0x75                          # 'u' -- restore cursor position
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_restorecursor
JMP .disp_done                       # unsupported final byte: no-op

.disp_up
CALL .ansi_get_n
LD_AL $crsr_row
CALL .ansi_dec_clamp0
ALUOP_AH %A%+%AL%
LD_AL $crsr_col
CALL :cursor_goto_rowcol
JMP .disp_done

.disp_down
CALL .ansi_get_n
LD_AL $crsr_row
LDI_BH 59
CALL .ansi_inc_clamp
ALUOP_AH %A%+%AL%
LD_AL $crsr_col
CALL :cursor_goto_rowcol
JMP .disp_done

.disp_right
CALL .ansi_get_n
LD_AL $crsr_col
LDI_BH 63
CALL .ansi_inc_clamp
ALUOP_PUSH %A%+%AL%
LD_AH $crsr_row
POP_AL
CALL :cursor_goto_rowcol
JMP .disp_done

.disp_left
CALL .ansi_get_n
LD_AL $crsr_col
CALL .ansi_dec_clamp0
ALUOP_PUSH %A%+%AL%
LD_AH $crsr_row
POP_AL
CALL :cursor_goto_rowcol
JMP .disp_done

.disp_gotorc
LDI_BL 1                             # default row (1-based)
LD_AL $ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_row_default
LD_AL $ansi_param_buf+1
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_row_default
ALUOP_BL %A%+%AL%
.gotorc_row_default
ALUOP_BL %B-1%+%BL%                  # BL = new row (0-based)
ALUOP_PUSH %B%+%BL%

LDI_BL 1                             # default col (1-based)
LD_AL $ansi_param_count
LDI_BH 2
ALUOP_FLAGS %A-B%+%AL%+%BH%          # O set iff count < 2
JO .gotorc_col_default
LD_AL $ansi_param_buf+3
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_col_default
ALUOP_BL %A%+%AL%
.gotorc_col_default
ALUOP_BL %B-1%+%BL%                  # BL = new col (0-based)

POP_AH                                # AH = new row
ALUOP_AL %B%+%BL%                    # AL = new col
CALL :cursor_goto_rowcol
JMP .disp_done

# J (erase-screen), mode 2 (full clear) ONLY -- modes 0/1 (cursor-to-end,
# start-to-cursor, via .ansi_erase_range) are CUT/DISABLED, along with all
# of K (erase-line), to help fit the 16 KiB ROM budget. A full clear is
# cheap: the ROM already has :clear_screen for exactly this, so mode 2
# just computes the erase-fill color and calls it directly, instead of
# going through the generic (now-removed) byte-range erase machinery.
# Modes 0/1 are silently ignored as an unsupported-but-valid mode value,
# not treated as a full clear -- a script expecting a partial erase should
# not have its whole screen wiped instead.
.disp_erase_screen
CALL .ansi_get_mode
LDI_BL 2
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done
CALL .ansi_get_erase_color            # BL = fill color (see
                                       # .ansi_get_erase_color's header)
LDI_AH 0x00
ALUOP_AL %B%+%BL%
CALL :clear_screen
JMP .disp_done

# --- everything below to .disp_h is the CUT/DISABLED original J (modes
# 0/1) and K (all modes) implementation, kept for restoration -- see the
# .ansi_fill_range/.ansi_erase_range comment block above and the 'K'
# dispatch comment for the other two pieces that go with it.
#.disp_erase_screen
#CALL .ansi_get_mode
#ALUOP_FLAGS %A%+%AL%
#JZ .es_m0
#LDI_BL 1
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .es_m1
#JMP .es_m2
#
#.es_m0
#LD_AH $crsr_row
#LD_AL $crsr_col
#CALL :cursor_conv_rowcol             # A = cursor offset
#ALUOP_CH %A%+%AH%
#ALUOP_CL %A%+%AL%                    # C = offset copy
#LDI_B 3840
#ALUOP16O_B %ALU16_B-A%               # B = count = 3840 - offset
#MOV_CH_AH
#MOV_CL_AL                            # A = offset (restored)
#CALL .ansi_erase_range
#JMP .disp_done
#
#.es_m1
#LD_AH $crsr_row
#LD_AL $crsr_col
#CALL :cursor_conv_rowcol             # A = cursor offset
#ALUOP_BH %A%+%AH%
#ALUOP_BL %A%+%AL%                    # B = offset copy
#ALUOP16O_B %ALU16_B+1%               # B = count = offset + 1
#LDI_A 0x0000                         # A = start offset 0
#CALL .ansi_erase_range
#JMP .disp_done
#
#.es_m2
#LDI_A 0x0000
#LDI_B 3840
#CALL .ansi_erase_range
#JMP .disp_done
#
#.disp_erase_line
#CALL .ansi_get_mode
#ALUOP_FLAGS %A%+%AL%
#JZ .el_m0
#LDI_BL 1
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .el_m1
#JMP .el_m2
#
#.el_m0
#LD_AH $crsr_row
#LD_AL $crsr_col
#CALL :cursor_conv_rowcol             # A = cursor offset (erase start)
#ALUOP_CH %A%+%AH%
#ALUOP_CL %A%+%AL%                    # stash offset in C
#LDI_BH 0x00
#LD_BL $crsr_col
#LDI_AH 64
#ALUOP_BL %A-B%+%AH%+%BL%             # BL = 64 - col
#MOV_CH_AH
#MOV_CL_AL                            # A = offset (restored)
#CALL .ansi_erase_range
#JMP .disp_done
#
#.el_m1
#LD_AH $crsr_row
#LDI_AL 0x00
#CALL :cursor_conv_rowcol             # A = row start offset
#LDI_BH 0x00
#LD_BL $crsr_col
#ALUOP_BL %B+1%+%BL%                  # BL = col + 1
#CALL .ansi_erase_range
#JMP .disp_done
#
#.el_m2
#LD_AH $crsr_row
#LDI_AL 0x00
#CALL :cursor_conv_rowcol             # A = row start offset
#LDI_B 64
#CALL .ansi_erase_range
#JMP .disp_done

.disp_h
LD_AL $ansi_private
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL $ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL $ansi_param_buf+1
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done
CALL :cursor_on
JMP .disp_done

.disp_l
LD_AL $ansi_private
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL $ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL $ansi_param_buf+1
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done
CALL :cursor_off
JMP .disp_done

.disp_sgr
# No empty-parameter special case is needed here: the final-byte
# handler always stores the pending accumulator, so a bare ESC[m
# arrives as a single parameter of value 0 -- which IS the reset code.
# Nor a truecolor check: a discarded sequence is dropped before
# dispatch ever runs.
ST $ansi_sgr_index 0x00
ST $ansi_sgr_pending_shade 0x00
.sgr_loop
LD_AL $ansi_sgr_index
LD_BL $ansi_param_count
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff index < count
JNO .sgr_apply_pending
CALL .sgr_get_param                   # AL = param[index]
CALL .sgr_apply_code                  # 38/48 fall through as ignored codes
                                      # (256-color/truecolor isn't
                                      # implemented -- see file header; the
                                      # parser already dropped anything
                                      # WITH a following param, so a bare
                                      # 38/48 reaching here has no
                                      # sub-params to misinterpret)
LD_AL $ansi_sgr_index
ALUOP_ADDR %A+1%+%AL% $ansi_sgr_index        # index++
JMP .sgr_loop

# Params exhausted: apply a deferred bold/normal (codes 1/22) last, so
# ESC[1;31m and ESC[31;1m both mean light red -- the shade change
# always operates on the final color.
#
# The shade math exploits the color byte layout: each channel is a
# 2-bit field, and (color >> 1) & 0x15 extracts every channel's high
# bit aligned onto its own low bit (the 0x15 also masks off the
# blink/cursor bits' shift spill). Bold upgrades shade 2 -> 3 (binary
# 10 -> 11) by ORing that in: only fields with the high bit set gain a
# low bit. Normal downgrades 3 -> 2 (11 -> 10) by AND-NOTing it out.
# Shades 0 and 1 have no high bit and pass through both unchanged.
.sgr_apply_pending
LD_AL $ansi_sgr_pending_shade
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgr_pend_bold
LDI_BL 2
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done                        # no pending shade change

LD_AL $term_current_color             # SGR 22 (normal)
ALUOP_BL %A>>1%+%AL%
LDI_AH 0x15
ALUOP_BL %A&B%+%AH%+%BL%              # BL = channel high bits, aligned low
ALUOP_ADDR %A&~B%+%AL%+%BL% $term_current_color
JMP .disp_done

.sgr_pend_bold
LD_AL $term_current_color             # SGR 1 (bold)
ALUOP_BL %A>>1%+%AL%
LDI_AH 0x15
ALUOP_BL %A&B%+%AH%+%BL%
ALUOP_ADDR %A|B%+%AL%+%BL% $term_current_color
JMP .disp_done

# ESC[<v>p -- Odyssey-native color: write param[0] straight into the
# current color byte (see this file's header). The final-byte handler
# always stores the trailing accumulator, so a bare ESC[p arrives as a
# single param of 0; anything > 255 was already rejected by the digit
# accumulator, so param[0] is the whole value.
.disp_setcolor
LD_AL $ansi_param_buf+1
CALL .sgr_set_color                   # AL -> $term_current_color; render on
JMP .disp_done

# ESC[s / ESC[u -- cursor position save/restore.
.disp_savecursor
CALL :cursor_save
JMP .disp_done

.disp_restorecursor
CALL :cursor_restore
JMP .disp_done

.disp_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Applies one simple SGR code: 0/39 reset, 5/25 blink, and the
# foreground colors 30-37/90-97. Codes 1 (bold) and 22 (normal) only
# record themselves in $ansi_sgr_pending_shade -- .sgr_apply_pending
# applies the shade change after the parameter loop finishes. Every other
# code (background colors, underline, italic, etc.) is silently ignored --
# this terminal has no independent background color or those attributes.
#
# Inputs:
#  AL - SGR code (0-255)
# Clobbers: A, B, C.
.sgr_apply_code
ALUOP_FLAGS %A%+%AL%
JZ .sgrcode_reset                     # 0: reset
LDI_BL 39
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_reset                    # 39: default fg == reset (spec)
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_pending_bold
LDI_BL 22
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_pending_normal
LDI_BL 5
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_blink_on
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_blink_off

LDI_BL 30
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 30
JO .sgrcode_done
LDI_BL 38
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 38: codes 30-37
JO .sgrcode_fg_low
LDI_BL 90
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 90
JO .sgrcode_done
LDI_BL 98
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 98: codes 90-97
JO .sgrcode_fg_high
.sgrcode_done
RET                                   # anything else: ignored

.sgrcode_reset
LDI_AL 0x3f                           # white; bit 7 clear drops blink too
JMP .sgr_set_color                    # (tail call)

.sgrcode_pending_bold
ST $ansi_sgr_pending_shade 0x01
RET

.sgrcode_pending_normal
ST $ansi_sgr_pending_shade 0x02
RET

.sgrcode_blink_on
LDI_BL 0x80
LD_AL $term_current_color
ALUOP_ADDR %A|B%+%AL%+%BL% $term_current_color
RET

.sgrcode_blink_off
LDI_BL 0x80
LD_AL $term_current_color
ALUOP_ADDR %A&~B%+%AL%+%BL% $term_current_color
RET

.sgrcode_fg_high
LDI_BL 82                             # 90-97 -> table index 8-15
JMP .sgrcode_fg_common
.sgrcode_fg_low
LDI_BL 30                             # 30-37 -> table index 0-7
.sgrcode_fg_common
ALUOP_AL %A-B%+%AL%+%BL%
LDI_B .sgr_color_table
JMP .sgr_table_color                  # (tail call)

######
# Reads the low byte of $ansi_param_buf[AL]. (Param values are always
# <= 255 -- the digit accumulator flushes anything larger -- so the low
# byte is the whole value.)
#
# Inputs:
#  AL - parameter index (0-3)
# Outputs:
#  AL - parameter value
# Clobbers: AH, B, C.
.sgr_get_param
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A+1%+%AL%                   # AL = index*2 + 1 (low-byte offset)
LDI_B $ansi_param_buf
# ... falls through into .sgr_table_lookup

######
# Reads table[AL] from a byte table based at B.
#
# Inputs:
#  AL - index, B - table base address
# Outputs:
#  AL - table byte
# Clobbers: AH, C.
.sgr_table_lookup
LDI_AH 0x00
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL
RET

######
# Looks up table[AL] (byte table based at B) and makes it the current
# rendered color.
#
# Inputs:
#  AL - index, B - table base address
# Clobbers: A, C.
.sgr_table_color
CALL .sgr_table_lookup
# ... falls through into .sgr_set_color

######
# Sets $term_current_color to AL and turns on color rendering.
#
# Inputs:
#  AL - color byte
.sgr_set_color
ALUOP_ADDR %A%+%AL% $term_current_color
ST $term_render_color 0x01
RET

.sgr_color_table 0x00 0x20 0x08 0x28 0x02 0x22 0x0a 0x2a 0x15 0x30 0x0c 0x3c 0x03 0x33 0x0f 0x3f
