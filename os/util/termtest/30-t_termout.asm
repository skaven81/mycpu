# vim: syntax=asm-mycpu

# Prototype of the new terminal output library (TERMINAL_REFACTOR.md 2.2).
# Differences from the current os/bios/lib/terminal_output.asm:
#  - Unified $t_term_flags byte (2.2.1) replaces the four separate
#    control variables. 0x00 is the fast/default case.
#  - :t_putchar has a genuine fast path (flags==0) and a slow path
#    (raw/ANSI-hook/edge-behavior). The fast path is tuned for minimum
#    instruction count; the slow path and the control-char handlers are
#    tuned for size and share code wherever the hot path doesn't pay
#    for it.
#  - .cursor_advance replaces the old heavy cursor_right ->
#    .cursor_move_real -> cursor_goto_addr chain (2.3.1).
#  - No @-code parsing in :t_print -- color comes from ANSI (via the
#    :t_ansi_feed hook, stubbed here until Task 3) or from setting
#    $t_term_render_color/$t_term_current_color directly (2.2.4).
#  - :t_putchar_raw replaces :putchar_direct; :t_print_raw is new and
#    keeps its whole working set in registers across the loop.
#
# Performance-critical register conventions used in this file:
#  - putchar saves only AH and BL up front (every path clobbers them);
#    everything else (AL, C, D) is saved only by the paths that
#    actually touch it. This keeps the per-character cost of the
#    common case at the absolute minimum while remaining fully
#    callee-save from the caller's point of view.
#  - The color framebuffer address is always chars_addr | 0x1000, so
#    .cursor_advance derives the color address from the chars address
#    with one OR instead of a second 16-bit increment.
#
# :t_ansi_feed/:t_ansi_flush/:t_ansi_reset and the :t_ansi_* state live in
# 35-t_ansi.asm (Task 3). The only ANSI-related code that stays here is
# the ESC-detection in :t_putchar's slow path, since it's cheap enough to
# inline and keeps the common (non-ANSI) slow-path characters from paying
# for a CALL into the parser file.
#
# State is VAR global (not a label data segment) since this file moves
# into os/bios/lib/ eventually, where label data would be read-only ROM.
VAR global byte $t_term_flags
VAR global byte $t_term_render_color
VAR global byte $t_term_current_color
VAR global 128 $t_printf_buf

######
# Print a single character from AL at the current cursor location, then
# advance the cursor. Honors $t_term_flags (2.2.1/2.2.2).
#
# Inputs:
#  AL - character to print
# All registers preserved.
:t_putchar
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
LD_BL $t_term_flags
ALUOP_FLAGS %B%+%BL%
JNZ .putchar_slow

# --- fast path: $t_term_flags == 0x00 ---
# Two-test screen instead of four ctrl-char compares: everything below
# 0x20 goes to the (cold) .putchar_lowctrl dispatcher, and 0x7f is the
# only ctrl char above it. 0x80-0xff are printable CP437 glyphs and
# sail through, same as the current BIOS behavior.
LDI_BL 0x20
ALUOP_FLAGS %A-B%+%AL%+%BL%          # O set iff AL < 0x20
JO .putchar_lowctrl
LDI_BL 0x7f
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_delete

.putchar_write
PUSH_DH
PUSH_DL
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%                # write the character
LD_BL $t_term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .putchar_fast_adv
LD_DH $t_crsr_addr_color
LD_DL $t_crsr_addr_color+1
LD_BL $t_term_current_color
ALUOP_ADDR_D %B%+%BL%                # write the color byte
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1           # restore D=chars for .cursor_advance
.putchar_fast_adv
CALL .cursor_advance                 # D contract: addr just written
POP_DL
POP_DH

.putchar_done
POP_BL
POP_AH
RET

# Cold dispatcher for chars below 0x20. Anything that isn't BS/CR/LF
# prints as a glyph (matches current BIOS behavior for e.g. tab).
.putchar_lowctrl
LDI_BL 0x08                          # Backspace
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_backspace
LDI_BL 0x0d                          # Carriage return
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_cr
LDI_BL 0x0a                          # Newline
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .putchar_newline
JMP .putchar_write

# --- slow path: $t_term_flags != 0x00 ---
# The flags byte lives in AH for the whole dispatch (BL is the compare
# scratch). BH is never touched, so it doesn't need saving.
.putchar_slow
ALUOP_AH %B%+%BL%                    # AH = flags byte
LDI_BL 0x01                          # bit 0: raw mode
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNZ .putchar_slow_skipctrl           # raw: ctrl chars print as glyphs

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

.putchar_slow_skipctrl
LDI_BL 0x02                          # bit 1: ANSI mode (AH still flags)
ALUOP_FLAGS %A&B%+%AH%+%BL%
JZ .putchar_slow_write               # ANSI off: plain write

LD_BL $t_ansi_state
ALUOP_FLAGS %B%+%BL%
JNZ .putchar_slow_ansi_feed          # mid-sequence: always feed, even ESC

LDI_BL 0x1b                          # ESC
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .putchar_slow_write              # not ESC, not mid-sequence

ST $t_ansi_state 0x01                # start a new escape sequence
ST $t_ansi_seq_buf 0x1b              # record it for error-recovery flush
ST $t_ansi_seq_len 0x01
JMP .putchar_done

.putchar_slow_ansi_feed
CALL :t_ansi_feed
JMP .putchar_done

# Same write block as the fast path, but advancing through the
# flag-driven edge logic. Duplicating these few instructions keeps the
# fast path free of a CALL/RET pair it would otherwise pay per char.
.putchar_slow_write
PUSH_DH
PUSH_DL
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%
LD_BL $t_term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .putchar_slow_adv
LD_DH $t_crsr_addr_color
LD_DL $t_crsr_addr_color+1
LD_BL $t_term_current_color
ALUOP_ADDR_D %B%+%BL%
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
.putchar_slow_adv
CALL .cursor_advance_edge            # D contract: addr just written
POP_DL
POP_DH
JMP .putchar_done

# --- control-character handlers (cold; shared by fast and slow paths;
# each saves exactly the registers it clobbers beyond AH/BL) ---

.putchar_backspace
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
LD_AL $t_crsr_col
CALL :t_cursor_left
LD_BL $t_crsr_col
ALUOP_FLAGS %AxB%+%AL%+%BL%      # col unchanged means cursor was at 0,0
JEQ .putchar_bs_done
LD_CH $t_crsr_addr_chars
LD_CL $t_crsr_addr_chars+1       # cursor location (post-move) in C
INCR_C                           # one step right of the new position
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1       # cursor location in D
CALL .term_strcpy                # shift everything right of cursor left
.putchar_bs_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_AL
JMP .putchar_done

.putchar_delete
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
LD_CH $t_crsr_addr_chars
LD_CL $t_crsr_addr_chars+1
INCR_C
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
CALL .term_strcpy
POP_DL
POP_DH
POP_CL
POP_CH
JMP .putchar_done

.putchar_cr
ALUOP_PUSH %A%+%AL%
LD_AH $t_crsr_row
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
POP_AL
JMP .putchar_done

.putchar_newline
ALUOP_PUSH %A%+%AL%
LD_AH $t_crsr_row
CALL .row_advance_bottomedge     # AH in, AH out (new row)
LDI_AL 0x00
CALL :t_cursor_goto_rowcol
POP_AL
JMP .putchar_done

######
# Writes AL to the framebuffer at the cursor and advances one position.
# No control-char handling, no flag checks, no ANSI, no color. Replaces
# the ROM's :putchar_direct.
#
# Inputs:
#  AL - character to print
# All registers preserved.
:t_putchar_raw
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
PUSH_DH
PUSH_DL
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
ALUOP_ADDR_D %A%+%AL%
CALL .cursor_advance                 # D contract: addr just written
POP_DL
POP_DH
POP_BL
POP_AH
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
LD_AL $t_ansi_state
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
# Prints a null-terminated string at C, one framebuffer write per
# character. No ctrl chars, no ANSI, no color -- this is the maximum-
# throughput bulk path, so the whole working set stays in registers:
# D walks the framebuffer, BL mirrors the column, and the cursor state
# in memory is only touched at line wraps and once at the end.
#
# Inputs:
#  C - address of string to print
:t_print_raw
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
LD_DH $t_crsr_addr_chars
LD_DL $t_crsr_addr_chars+1
LD_BL $t_crsr_col
LDI_AH 0x40                          # right-edge comparand, hoisted
.prraw_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .prraw_done
ALUOP_ADDR_D %A%+%AL%                # write character
INCR_C
ALUOP_BL %B+1%+%BL%                  # col++
ALUOP_FLAGS %AxB%+%AH%+%BL%          # col == 64?
JEQ .prraw_wrap
INCR_D
JMP .prraw_loop                      # 9 instructions per character

.prraw_wrap                          # cold: once per 64 characters
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% $t_crsr_col      # sync col=63 so .cursor_advance
CALL .cursor_advance                 # re-increments it (D = written addr)
LD_DH $t_crsr_addr_chars             # resync locals: advance may have
LD_DL $t_crsr_addr_chars+1           # wrapped a row or scrolled
LD_BL $t_crsr_col
LDI_AH 0x40                          # (clobbered by .cursor_advance)
JMP .prraw_loop

.prraw_done                          # write registers back to cursor state
ALUOP_ADDR %B%+%BL% $t_crsr_col
MOV_DL_BL
ALUOP_ADDR %B%+%BL% $t_crsr_addr_chars+1
ALUOP_ADDR %B%+%BL% $t_crsr_addr_color+1
MOV_DH_AH
ALUOP_ADDR %A%+%AH% $t_crsr_addr_chars
LDI_BL 0x10
ALUOP_AH %A|B%+%AH%+%BL%             # color addr = chars addr | 0x1000
ALUOP_ADDR %A%+%AH% $t_crsr_addr_color
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_AL
POP_AH
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
LDI_D $t_printf_buf
CALL :sprintf
LDI_C $t_printf_buf
CALL :t_print
POP_CL
POP_CH
POP_DL
POP_DH
RET

######
# Scrolls the display up one line (chars + colors, always in lockstep).
# Does not touch the cursor. Runtime is dominated by the two 3.7 KiB
# block copies, so the wrapper stays simple.
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
# Default cursor advance: one position right, wrap to col 0 + next row
# at the right edge, scroll at the bottom. This is the hot inner step
# of putchar's fast path, putchar_raw, and print_raw's wrap handling.
#
# Inputs:
#  D - address of the character cell just written (== the current
#      $t_crsr_addr_chars). Both callers have D loaded already, which
#      is what lets this routine advance with a single INCR_D instead
#      of two load/increment/store sequences on the cached addresses.
# Clobbers: AH, BL, D, flags. Callers must save these.
# AL is preserved (it still holds the caller's character).
.cursor_advance
INCR_D
MOV_DH_AH
ALUOP_ADDR %A%+%AH% $t_crsr_addr_chars
LDI_BL 0x10
ALUOP_AH %A|B%+%AH%+%BL%             # color addr = chars addr | 0x1000
ALUOP_ADDR %A%+%AH% $t_crsr_addr_color
MOV_DL_BL
ALUOP_ADDR %B%+%BL% $t_crsr_addr_chars+1
ALUOP_ADDR %B%+%BL% $t_crsr_addr_color+1
LD_BL $t_crsr_col
ALUOP_BL %B+1%+%BL%
ALUOP_ADDR %B%+%BL% $t_crsr_col      # transient 64 fixed on the edge path
LDI_AH 0x40
ALUOP_FLAGS %AxB%+%AH%+%BL%          # col == 64?
JEQ .cadv_rightedge
RET                                  # common case: 15 instructions + RET

.cadv_rightedge                      # cold: once per 64 characters
ALUOP_PUSH %A%+%AL%
LD_AH $t_crsr_row
ALUOP_AH %A+1%+%AH%
LDI_BL 0x3c
ALUOP_FLAGS %AxB%+%AH%+%BL%          # walked off the bottom?
JEQ .cadv_bottom
# mid-screen wrap: the linearly-incremented addresses are already
# correct for (row+1, col 0) -- only row/col need fixing up
ALUOP_ADDR %A%+%AH% $t_crsr_row
LDI_AL 0x00
ALUOP_ADDR %A%+%AL% $t_crsr_col
POP_AL
RET
.cadv_bottom
CALL :t_term_scroll                  # cursor lands on (59,0); goto also
LDI_AH 0x3b                          # repairs the addresses we advanced
LDI_AL 0x00                          # past the end of the framebuffer
CALL :t_cursor_goto_rowcol
POP_AL
RET

######
# Flag-driven cursor advance for the slow path: honors $t_term_flags
# bits 2-5 for right-edge and bottom-edge behavior (2.2.1). Away from
# the right edge every advance is identical to the default one, so this
# just delegates -- slow-path characters cost only three instructions
# more than fast-path ones until the cursor is actually at col 63.
#
# Inputs:
#  D - address of the character cell just written (same contract as
#      .cursor_advance; only the delegation path uses it)
# Clobbers: AH, BL, D, flags. AL preserved.
.cursor_advance_edge
LD_BL $t_crsr_col
LDI_AH 0x3f
ALUOP_FLAGS %AxB%+%AH%+%BL%          # at col 63?
JNE .cursor_advance                  # no: default advance (tail call)

# at the right edge (cold): pick the new column from bit 2, then the
# new row from bit 3 + the bottom-edge logic, and let goto_rowcol
# derive the addresses. Flags stay latched across LD/LDI, which lets
# the result of each bit test be preloaded before its branch.
ALUOP_PUSH %A%+%AL%
LD_AH $t_term_flags
LDI_BL 0x04                          # bit 2: no-wrap
ALUOP_FLAGS %A&B%+%AH%+%BL%
LDI_AL 0x3f                          # preload: stay at col 63
JNZ .cae_col_done
LDI_AL 0x00                          # wrap to col 0
.cae_col_done
LDI_BL 0x08                          # bit 3: no-newline (AH still flags)
ALUOP_FLAGS %A&B%+%AH%+%BL%
LD_AH $t_crsr_row
JNZ .cae_apply                       # no-newline: row unchanged
CALL .row_advance_bottomedge         # AH in, AH out
.cae_apply
CALL :t_cursor_goto_rowcol
POP_AL
RET

######
# Given the current row in AH, computes the row after a "move to next
# row" event (newline, or a right-edge wrap that advances rows),
# honoring $t_term_flags bits 4-5 for bottom-edge behavior and calling
# :t_term_scroll when scrolling is wanted. Shared by
# .cursor_advance_edge and .putchar_newline.
#
# Inputs:
#  AH - current row (0-59)
# Outputs:
#  AH - new row (0-59)
# Clobbers: flags. (BL saved internally.)
.row_advance_bottomedge
ALUOP_PUSH %B%+%BL%
ALUOP_AH %A+1%+%AH%
LDI_BL 0x3c
ALUOP_FLAGS %AxB%+%AH%+%BL%          # walked off the bottom?
JNE .rab_done

# row 60 never survives -- every branch below overwrites AH, so it can
# hold the flags byte for the bit tests in the meantime
LD_AH $t_term_flags
LDI_BL 0x10                          # bit 4: no-scroll
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNZ .rab_noscroll
CALL :t_term_scroll                  # default: scroll (regardless of
LDI_AH 0x3b                          # bit 5 -- see spec 2.2.1 note)
JMP .rab_done
.rab_noscroll
LDI_BL 0x20                          # bit 5: wrap-to-top (AH still flags)
ALUOP_FLAGS %A&B%+%AH%+%BL%
LDI_AH 0x00                          # preload: wrap to row 0
JNZ .rab_done
LDI_AH 0x3b                          # no-scroll no-wrap: clamp to row 59
.rab_done
POP_BL
RET

######
# Terminal-aware strcpy: copies both display characters and display
# colors from C to D in lockstep, stopping after the byte following a
# null character. Used by backspace/delete to shift text left.
#
# All four pointer registers are in use (C/D walk the chars, A/B walk
# the colors). The char copy uses the single-instruction MEMCPY_C_D
# (atomic, so an interrupt can't land mid-copy); the color copy has no
# equivalent bulk instruction (it's fixed to C/D), so it still carries
# the byte through TD by hand across two instructions -- interrupts are
# masked across exactly those two, since TD is microcode scratch that
# IRQ entry clobbers regardless of what the handler does. Runs at human
# keystroke rate, so per-iteration cost is fine.
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

# AH:AL now holds the source color address -- save it around the BH bump
# below, which needs AL as ALU scratch (the ALU's B-port can only read
# BH/BL, so the OR mask for "BH | 0x10" has to come from the A-port, and
# that means AH or AL; AL is free of anything ELSE right now, but its
# current value is half of the address we still need for the loop).
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

MOV_DH_BH                   # Copy DH to BH
LDI_AL 0x10
ALUOP_BH %A|B%+%BH%+%AL%    # Bump DH up to the 0x5000 range
MOV_DL_BL                   # Copy DL to BL

POP_AL
POP_AH                      # restore AH:AL = source color address

.term_strcpy_loop
ALUOP_PUSH %A%+%AL%
LDA_C_AL
ALUOP_FLAGS %A%+%AL%        # check (BEFORE copying) whether this char is null
POP_AL
MEMCPY_C_D                  # copy the char C->D; auto-increments both C and D
MASKINT
LDA_A_TD                    # load color from source into TD
STA_B_TD                    # write color from TD to dest
UMASKINT
JZ .term_strcpy_done        # we are done once the null itself has been copied
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
