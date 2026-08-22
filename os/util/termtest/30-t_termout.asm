# vim: syntax=asm-mycpu

# Prototype of the new terminal output library (TERMINAL_REFACTOR.md 2.2).
# Differences from the current os/bios/lib/terminal_output.asm:
#  - Unified :t_term_flags byte (2.2.1) replaces the four separate
#    control variables. 0x00 is the fast/default case.
#  - :t_putchar has a genuine fast path (flags==0: no flag checks beyond
#    the single zero-test) and a slow path (raw/ANSI/edge-behavior).
#  - .cursor_advance (fast, default-only) and .cursor_advance_edge
#    (general, flag-driven) replace the old heavy
#    cursor_right -> .cursor_move_real -> cursor_goto_addr chain (2.3.1).
#  - No @-code parsing in :t_print -- color comes from ANSI (via the
#    :t_ansi_feed hook, stubbed here until Task 3) or from setting
#    :t_term_render_color/:t_term_current_color directly (2.2.4).
#  - :t_putchar_raw replaces :putchar_direct; :t_print_raw is new.
#
# :t_ansi_feed and :t_ansi_flush are temporary stubs so this file (and
# its ANSI hook in :t_putchar/:t_print) can be built and tested in
# isolation. Task 3 (35-t_ansi.asm) replaces them with the real state
# machine and removes the stub bodies and :t_ansi_state from this file.

######
# Print a single character from AL at the current cursor location, then
# advance the cursor. Honors :t_term_flags (2.2.1/2.2.2).
#
# Inputs:
#  AL - character to print
:t_putchar
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_DH
PUSH_DL

LD_BL :t_term_flags
ALUOP_FLAGS %B%+%BL%
JNZ .putchar_slow

# --- fast path: :t_term_flags == 0x00 ---
LDI_BL 0x08                          # Backspace
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_backspace
LDI_BL 0x7f                          # Delete
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_delete
LDI_BL 0x0d                          # Carriage return
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_cr
LDI_BL 0x0a                          # Newline
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_newline

LD_DH :t_crsr_addr_chars
LD_DL :t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%                # write the character
LD_BL :t_term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .putchar_fast_advance
LD_DH :t_crsr_addr_color
LD_DL :t_crsr_addr_color+1
LD_BL :t_term_current_color
ALUOP_ADDR_D %B%+%BL%
.putchar_fast_advance
CALL .cursor_advance
JMP .putchar_done

# --- slow path: :t_term_flags != 0x00 ---
.putchar_slow
ALUOP_AH %B%+%BL%                    # AH = flags byte (scratch; AL is the
                                      # char and must stay untouched, AH is
                                      # otherwise unused for the rest of
                                      # this function)
LDI_BH 0x01                          # bit 0: raw mode
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .putchar_slow_skipctrl           # raw: skip ctrl-char checks

LDI_BH 0x08                          # Backspace
ALUOP_FLAGS %AxB%+%AL%+%BH%
JEQ .putchar_backspace
LDI_BH 0x7f                          # Delete
ALUOP_FLAGS %AxB%+%AL%+%BH%
JEQ .putchar_delete
LDI_BH 0x0d                          # Carriage return
ALUOP_FLAGS %AxB%+%AL%+%BH%
JEQ .putchar_cr
LDI_BH 0x0a                          # Newline
ALUOP_FLAGS %AxB%+%AL%+%BH%
JEQ .putchar_newline

.putchar_slow_skipctrl
LDI_BH 0x02                          # bit 1: ANSI mode (AH still holds flags)
ALUOP_FLAGS %A&B%+%AH%+%BH%
JZ .putchar_slow_write               # ANSI off: fall through to plain write

LD_BH :t_ansi_state
ALUOP_FLAGS %B%+%BH%
JNZ .putchar_slow_ansi_feed          # mid-sequence: always feed, even on ESC

LDI_BH 0x1b                          # ESC
ALUOP_FLAGS %AxB%+%AL%+%BH%
JNE .putchar_slow_write              # not ESC, not mid-sequence: plain write

ST :t_ansi_state 0x01                # start a new escape sequence
JMP .putchar_done

.putchar_slow_ansi_feed
CALL :t_ansi_feed
JMP .putchar_done

.putchar_slow_write
LD_DH :t_crsr_addr_chars
LD_DL :t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%
LD_BL :t_term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .putchar_slow_advance
LD_DH :t_crsr_addr_color
LD_DL :t_crsr_addr_color+1
LD_BL :t_term_current_color
ALUOP_ADDR_D %B%+%BL%
.putchar_slow_advance
CALL .cursor_advance_edge
JMP .putchar_done

# --- shared control-character handlers (both paths land here) ---

.putchar_backspace
LD_AH :t_crsr_row
LD_AL :t_crsr_col
CALL :t_cursor_left
LD_BH :t_crsr_row
LD_BL :t_crsr_col
ALUOP_FLAGS %AxB%+%AL%+%BL%     # col the same?
JEQ .putchar_done                # if cursor didn't move, do nothing
LD_CH :t_crsr_addr_chars
LD_CL :t_crsr_addr_chars+1       # cursor location (post-move) in C
INCR_C                           # one step right of the new position
LD_DH :t_crsr_addr_chars
LD_DL :t_crsr_addr_chars+1       # cursor location in D
CALL .term_strcpy                # shift everything right of cursor, one left
JMP .putchar_done

.putchar_delete
LD_CH :t_crsr_addr_chars
LD_CL :t_crsr_addr_chars+1
INCR_C
LD_DH :t_crsr_addr_chars
LD_DL :t_crsr_addr_chars+1
CALL .term_strcpy
JMP .putchar_done

.putchar_cr
LD_AH :t_crsr_row
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
JMP .putchar_done

.putchar_newline
LD_AH :t_crsr_row
CALL .row_advance_bottomedge     # AH in, AH out (new row)
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
JMP .putchar_done

.putchar_done
POP_DL
POP_DH
POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Writes AL to the framebuffer at the cursor and advances one position.
# No control-char handling, no flag checks, no ANSI, no color. Replaces
# the ROM's :putchar_direct.
#
# Inputs:
#  AL - character to print
:t_putchar_raw
PUSH_DH
PUSH_DL
LD_DH :t_crsr_addr_chars
LD_DL :t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%
CALL .cursor_advance
POP_DL
POP_DH
RET

######
# Prints a null-terminated string at C via :t_putchar. If the ANSI parser
# is left mid-sequence when the string ends, flushes the buffered escape
# characters and resets it (2.2.3 case 4).
#
# Inputs:
#  C - address of string to print
:t_print
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
.print_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done
CALL :t_putchar
INCR_C
JMP .print_loop
.print_done
LD_AL :t_ansi_state
ALUOP_FLAGS %A%+%AL%
JZ .print_no_flush
CALL :t_ansi_flush
.print_no_flush
CALL :t_cursor_display_sync
POP_CL
POP_CH
POP_AL
RET

######
# Prints a null-terminated string at C via :t_putchar_raw. No ctrl chars,
# no ANSI, no color -- maximum-throughput bulk output.
#
# Inputs:
#  C - address of string to print
:t_print_raw
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
.print_raw_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .print_raw_done
CALL :t_putchar_raw
INCR_C
JMP .print_raw_loop
.print_raw_done
POP_CL
POP_CH
POP_AL
RET

######
# Formats fmt (C) with heap-pushed args via the ROM's :sprintf into a
# private 128-byte buffer, then prints it via :t_print.
#
# Inputs:
#  C - address of format string
#  heap - parameters for the format string
:t_printf
PUSH_DH
PUSH_DL
PUSH_CH
PUSH_CL
LDI_D :t_printf_buf
CALL :sprintf
LDI_C :t_printf_buf
CALL :t_print
POP_CL
POP_CH
POP_DL
POP_DH
RET

######
# Scrolls the display up one line (chars + colors, always in lockstep).
# Does not touch the cursor.
:t_term_scroll
CALL :heap_push_all

LDI_C %display_chars%+64    # beginning of second line
LDI_D %display_chars%       # beginning of first line
LDI_AL 28                   # 29 128-byte segments -> 58 lines
CALL :memcpy_segments
LDI_AL 3                    # 4 16-byte blocks -> 1 line
CALL :memcpy_blocks

LDI_C %display_chars%+3776  # C to the beginning of the last line
LDI_AH 0x00
LDI_AL 3
CALL :memfill_blocks

LDI_C %display_color%+64
LDI_D %display_color%
LDI_AL 28
CALL :memcpy_segments
LDI_AL 3
CALL :memcpy_blocks

LDI_C %display_color%+3776
LDI_AH %white%
LDI_AL 3
CALL :memfill_blocks

CALL :heap_pop_all
RET

######
# Fast cursor advance for the common case (:t_term_flags == 0x00
# guaranteed by the caller -- see :t_putchar's fast path). Always wraps
# to col 0 + next row at the right edge, scrolling at the bottom. No
# flag checks at all -- see .cursor_advance_edge for the general case.
#
# No inputs/outputs; operates on :t_crsr_* state.
.cursor_advance
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

LD16_A :t_crsr_addr_chars
ALUOP16O_A %ALU16_A+1%
ALUOP_ADDR %A%+%AH% :t_crsr_addr_chars
ALUOP_ADDR %A%+%AL% :t_crsr_addr_chars+1

LD16_A :t_crsr_addr_color
ALUOP16O_A %ALU16_A+1%
ALUOP_ADDR %A%+%AH% :t_crsr_addr_color
ALUOP_ADDR %A%+%AL% :t_crsr_addr_color+1

LD_AL :t_crsr_col
ALUOP_AL %A+1%+%AL%
LDI_BL 0x40
ALUOP_FLAGS %AxB%+%AL%+%BL%       # col == 64?
JNE .cadv_storecol                 # common case: no row change

LDI_AL 0x00
LD_AH :t_crsr_row
ALUOP_AH %A+1%+%AH%
LDI_BL 0x3c                        # 60
ALUOP_FLAGS %AxB%+%AH%+%BL%        # row == 60?
JNE .cadv_storerow

CALL :t_term_scroll                 # bottom edge: scroll, land on (59,0)
LDI_AH 0x3b
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
JMP .cadv_done

.cadv_storerow
ALUOP_ADDR %A%+%AH% :t_crsr_row
.cadv_storecol
ALUOP_ADDR %A%+%AL% :t_crsr_col

.cadv_done
POP_BL
POP_AL
POP_AH
RET

######
# General cursor-advance for the slow path: honors :t_term_flags bits
# 2-5 for right-edge and bottom-edge behavior (2.2.1). Not performance-
# tuned (that's .cursor_advance, used only for the flags==0 default
# case) -- recomputes the final row/col and lets :t_cursor_goto_rowcol
# derive the addresses, trading a little speed for one obviously-correct
# path through the edge-behavior matrix.
#
# No inputs/outputs; operates on :t_crsr_* state and :t_term_flags.
.cursor_advance_edge
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

LD_AH :t_crsr_row
LD_AL :t_crsr_col
ALUOP_AL %A+1%+%AL%
LDI_BL 0x40
ALUOP_FLAGS %AxB%+%AL%+%BL%          # col == 64 (walked off the right edge)?
JNE .cae_apply                        # no -- new col in range, same row

# --- right edge reached: bits 2-3 decide column and whether row advances ---
# AH (row) must survive this whole block -- it's the input to
# .row_advance_bottomedge / :t_cursor_goto_rowcol below -- so it's saved
# on the hardware stack while borrowed as scratch for the flags byte.
ALUOP_PUSH %A%+%AH%
LD_BL :t_term_flags
ALUOP_AH %B%+%BL%                     # AH = flags (scratch copy)
LDI_BH 0x04                           # bit 2: no-wrap
ALUOP_FLAGS %A&B%+%AH%+%BH%
JZ .cae_wrapcol
LDI_AL 0x3f                           # no-wrap: stay at col 63
JMP .cae_col_decided
.cae_wrapcol
LDI_AL 0x00                           # wrap: col 0
.cae_col_decided

LDI_BH 0x08                           # bit 3: no-newline (AH still flags)
ALUOP_FLAGS %A&B%+%AH%+%BH%
POP_AH                                # restore row (flags survive the POP)
JNZ .cae_apply                        # no-newline: row unchanged, apply now

CALL .row_advance_bottomedge          # AH in, AH out (new row)

.cae_apply
CALL :t_cursor_goto_rowcol

POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Given the current row in AH, computes the row after a "move to next
# row" event (newline, or the right-edge case that advances rows),
# honoring :t_term_flags bits 4-5 for bottom-edge behavior, scrolling
# via :t_term_scroll if needed. Shared by .cursor_advance_edge and
# .putchar_newline.
#
# Inputs:
#  AH - current row (0-59)
# Outputs:
#  AH - new row (0-59)
.row_advance_bottomedge
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

ALUOP_AH %A+1%+%AH%
LDI_BL 0x3c                           # 60
ALUOP_FLAGS %AxB%+%AH%+%BL%           # row == 60 (walked off the bottom)?
JNE .rab_done

# row==60 is now a settled fact -- every remaining branch overwrites AH
# explicitly, so it's free to reuse as scratch for the flags byte from
# here on (no need to preserve the old "60").
LD_BL :t_term_flags
ALUOP_AH %B%+%BL%                     # AH = flags (scratch)
LDI_BH 0x10                           # bit 4: no-scroll
ALUOP_FLAGS %A&B%+%AH%+%BH%
JNZ .rab_noscroll

CALL :t_term_scroll                    # default (bit4=0): always scroll,
LDI_AH 0x3b                            # regardless of bit5 (see spec note)
JMP .rab_done

.rab_noscroll
LD_BL :t_term_flags
ALUOP_AH %B%+%BL%
LDI_BH 0x20                           # bit 5: wrap-to-top
ALUOP_FLAGS %A&B%+%AH%+%BH%
JZ .rab_stopbottom
LDI_AH 0x00                           # wrap-to-top: row 0
JMP .rab_done
.rab_stopbottom
LDI_AH 0x3b                           # no-scroll, no-wrap: clamp to row 59

.rab_done
POP_BL
POP_BH
RET

######
# Terminal-aware strcpy: copies both display characters and display
# colors from C to D in lockstep, stopping after the byte following a
# null character. Used by backspace/delete to shift text left.
#
# Inputs:
#  C - source address (in the %display_chars% range)
#  D - destination address (also in %display_chars% range)
.term_strcpy
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

MOV_CH_AH                   # Copy CH to AH
LDI_BL 0x10
ALUOP_AH %A|B%+%AH%+%BL%    # Bump CH up to the 0x5000 range
MOV_CL_AL                   # Copy CL to AL

MOV_DH_BH                   # Copy DH to BH
LDI_AL 0x10
ALUOP_BH %A|B%+%BH%+%AL%    # Bump DH up to the 0x5000 range
MOV_DL_BL                   # Copy DL to BL

.term_strcpy_loop
LDA_C_TD                    # load character from source into TD
STA_D_TD                    # write character from TD to dest
LDA_A_TD                    # load color from source into TD
STA_A_TD                    # write color from TD to dest

ALUOP_PUSH %A%+%AL%
LDA_C_AL
ALUOP_FLAGS %A%+%AL%        # check if current char is null
POP_AL
JZ .term_strcpy_done        # we are done if the last copied char was null
INCR_C                      # move to next source char
INCR_D                      # move to next dest char
ALUOP16O_A %ALU16_A+1%              # move to next source color
ALUOP16O_B %ALU16_B+1%              # move to next dest color
JMP .term_strcpy_loop       # keep looping until we hit a null character
.term_strcpy_done
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
# Temporary stub for the ANSI escape-sequence state machine. Task 3
# (35-t_ansi.asm) replaces this and removes :t_ansi_state from this
# file. Left as a no-op so :t_putchar's ANSI hook builds and can be
# exercised (staying permanently in state 0) before Task 3 lands.
:t_ansi_feed
RET

:t_ansi_flush
ST :t_ansi_state 0x00
RET

:t_ansi_state "\0"

:t_term_flags "\0"
:t_term_render_color "\0"
:t_term_current_color "\0"
:t_printf_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
