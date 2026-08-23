# vim: syntax=asm-mycpu

# Buffer-based line editor. Replaces the ROM's old marks-based :input
# entirely -- :readline edits a caller-supplied RAM buffer directly, with
# no marks and no separate input-flags state.
#
# Design:
#  - Caller owns the buffer (C), gives its size incl. null terminator (AL),
#    and an echo flag (AH bit 0). Returns AL=length, AH=status (0=Enter,
#    1=Ctrl+C).
#  - Internal state ($rl_*) is not reentrant -- matches every other piece of
#    terminal state in this library ($crsr_*, $ansi_*). One readline call is
#    active at a time.
#  - The screen cursor position always corresponds to buffer index $rl_pos
#    once an operation finishes (invariant maintained by every handler).
#    Since the framebuffer address space is linear (row*64+col, same scheme
#    :cursor_goto_addr/.cursor_advance already use), the screen position for
#    buffer index N is simply $rl_start_addr + N -- no need to track row/col
#    incrementally, and this naturally reproduces the wrap-at-column-64
#    behavior typed text gets from :putchar (.rl_seek). Known limitation: if
#    the input scrolls the screen (crosses the bottom edge), $rl_start_addr
#    goes stale and repositioning after that point would be wrong.
#  - Echo: every screen-touching primitive (.rl_seek, .rl_echo_putchar)
#    silently no-ops when $rl_echo is 0, so buffer edits happen identically
#    whether or not echo is on.
#  - Insert vs overwrite: overwrite mode is CUT/DELETED, to help fit the
#    16 KiB ROM budget. :readline now always inserts; there is no overwrite
#    mode, and the Insert key (0x0f) is simply an unrecognized control code
#    that's ignored. This was a real delete, not a comment-out -- restoring
#    it means re-implementing the mode toggle and the overwrite-write branch
#    from scratch (or pulling the last commit that had it, `6def9fd`, which
#    still carried a working hardware-proven copy in the now-deleted
#    os/util/termtest/40-t_readline.asm).
#  - History is CUT/DISABLED, to help fit the 16 KiB ROM budget. Every
#    history-related line below is commented out with '#', NOT deleted --
#    restore it verbatim by removing the leading '#' from: the
#    $rl_history_* VAR block, the $rl_history_browse_idx reset in
#    :readline's prologue, the Up/Down key dispatch in the poll loop, the
#    .rl_history_up/.rl_history_down/.rl_hist_down_clear handlers, the
#    .rl_history_append call in .rl_enter, and the whole "history helpers"
#    section at the end of the file (.rl_hist_check onward). Design:
#    entirely caller-managed via the $rl_history_* globals. $rl_history_buf
#    ==0 disables history (every history helper starts with .rl_hist_check
#    and no-ops). Enter with non-empty input appends to the circular buffer
#    (.rl_history_append, called from .rl_enter). Up/Down browse via
#    $rl_history_browse_idx (0 = not browsing / editing a fresh line; 1 =
#    newest entry, 2 = next older, ...; reset to 0 at the top of every
#    :readline call), converted to a physical slot index by
#    .rl_hist_calc_idx (write_idx - browse_idx, wrapped mod capacity --
#    capacity is a runtime byte value, not necessarily a power of two, so
#    this is done with an explicit borrow-then-add-capacity step, not a
#    mask). Recall does a full-line repaint (.rl_history_recall_entry):
#    reprint from index 0, blank out any leftover tail from a longer
#    previous line, cursor lands at the end of the recalled text (matches
#    typical shell history UX). Down past the newest entry (browse_idx back
#    to 0) clears the line instead of loading an entry.
#
# The kb/UART/both source-selector (AH bits 1-2, see :readline's header
# below) was added after the rest of this file was already in place, once
# it became clear that a shell driven purely by keyboard-source readline
# couldn't be driven remotely over the serrun serial link. :ptmr_clk_set
# (os/bios/lib/prog_timer.asm, 56 bytes, zero consumers) was cut to make
# ROM room for the addition.

VAR global word $rl_buf
VAR global byte $rl_maxlen
VAR global byte $rl_echo
VAR global byte $rl_source
VAR global byte $rl_len
VAR global byte $rl_pos
VAR global word $rl_start_addr
VAR global word $rl_tmp_addr
VAR global byte $rl_tmp_char
VAR global byte $rl_tmp_idx
VAR global byte $rl_tmp_count
VAR global byte $rl_tmp_blank
VAR global word $rl_tmp_src
VAR global word $rl_tmp_dest
VAR global byte $rl_ret_len
VAR global byte $rl_ret_status

# History. $rl_history_buf==0 (the default) disables history --
# every helper checks it via .rl_hist_check. The caller (the shell, or any
# other consumer) allocates history_buf and fills in capacity/entry_sz to
# enable it.
#VAR global word $rl_history_buf
#VAR global byte $rl_history_capacity
#VAR global byte $rl_history_count
#VAR global byte $rl_history_entry_sz
#VAR global byte $rl_history_write_idx
#VAR global byte $rl_history_browse_idx

######
# Reads a line of input with line editing support.
#
# Inputs:
#  C - pointer to caller-supplied buffer
#  AL - buffer size in bytes, including the null terminator
#  AH - flags: bit 0 = echo (1=on, 0=silent); bit 1 = accept keyboard
#       keystrokes; bit 2 = accept UART bytes (OR both together to accept
#       either, matching the legacy :input source-selector -- ported back
#       in 2026-08-22 so the shell stays drivable over the serrun serial
#       link after the :input->:readline transfer, which had dropped this).
#       A UART byte carries no keyflags (always reported as AH=0x00 to the
#       rest of the poll loop), so e.g. Ctrl+C cannot be sent as a raw 0x03
#       byte with meaning -- it's handled as an ordinary ignored control
#       character, same as any other sub-0x20 byte outside the handled
#       set. Passing neither bit 1 nor bit 2 hangs in the poll loop
#       forever -- that's a caller bug, not a runtime error this detects.
#       Bits 3-7 reserved.
# Outputs:
#  AL - number of characters entered (0 for empty input or Ctrl+C)
#  AH - status: 0 = Enter, 1 = Ctrl+C abort
#  Buffer at C is filled with a null-terminated string
# All other registers preserved.
:readline
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

ALUOP_ADDR %A%+%AL% $rl_maxlen
LDI_BL 0x01
ALUOP_ADDR %A&B%+%AH%+%BL% $rl_echo
ALUOP_ADDR %A%+%AH% $rl_source         # full flags byte, for the poll loop's source check

MOV_CH_AH
MOV_CL_AL
ALUOP_ADDR %A%+%AH% $rl_buf
ALUOP_ADDR %A%+%AL% $rl_buf+1

ST $rl_len 0x00
ST $rl_pos 0x00
#ST $rl_history_browse_idx 0x00        # not browsing yet (harmless if disabled)

LD_AH $crsr_addr_chars
LD_AL $crsr_addr_chars+1
ALUOP_ADDR %A%+%AH% $rl_start_addr
ALUOP_ADDR %A%+%AL% $rl_start_addr+1

LD_DH $rl_buf
LD_DL $rl_buf+1
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%                 # buf[0] = 0 (empty string so far)

###
# Poll loop. Checks the enabled source(s) per $rl_source (bit 1 = keyboard,
# bit 2 = UART) -- see :readline's header for the full contract.
#
# Cursor visibility: shown (synced on) here at the top, on every re-entry
# to this loop -- i.e. once per handled keystroke, since every handler
# below finishes with a jump back here, plus redundantly on each idle
# spin iteration while waiting for a key (harmless: re-syncing the same
# already-correct position is a no-op write, and there's nothing else
# for the CPU to do while blocked on human input anyway). Cleared again
# in .rl_poll_have_char, right when a keystroke actually arrives and
# before any handler can move the cursor -- see that label's comment.
.rl_poll
CALL :cursor_on
LD_AL $rl_source
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .rl_poll_skip_kb              # keyboard source not requested
CALL :kb_bufsize
ALUOP_FLAGS %A%+%AL%
JNZ .rl_poll_have_kb             # keyboard has a keystroke waiting, use it
.rl_poll_skip_kb
LD_AL $rl_source
LDI_BL 0x04
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .rl_poll                      # UART source not requested either, keep polling
CALL :uart_bufsize
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll                      # empty, go back to polling
CALL :uart_readbuf               # received byte into AL
LDI_AH 0x00                      # no keyflags for serial input
JMP .rl_poll_have_char
.rl_poll_have_kb
CALL :kb_readbuf                      # AH=keyflags, AL=char
.rl_poll_have_char
CALL :cursor_off                      # clear the idle mark before any
                                       # handler below can move the cursor
                                       # (AH/AL preserved -- cursor_off is
                                       # fully callee-save)

LDI_BL %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNZ .rl_poll                          # ignore break events

ALUOP_FLAGS %A%+%AL%
JZ .rl_poll                           # ignore bare meta-keypresses (char==0)

LDI_BL %kb_keyflag_CTRL%
ALUOP_FLAGS %A&B%+%AH%+%BL%
JZ .rl_not_ctrlc
LDI_BL 'c'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_ctrlc
.rl_not_ctrlc

LDI_BL %kb_keyflag_CTRL%+%kb_keyflag_ALT%+%kb_keyflag_FUNCTION%
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNZ .rl_poll                          # ignore any other modified key

LDI_BL 0x0d                           # Enter (CR)
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_enter
LDI_BL 0x0a                           # Enter (LF)
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_enter
LDI_BL 0x08                           # Backspace
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_backspace
LDI_BL 0x7f                           # Delete
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_delete
LDI_BL 0x02                           # Home
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_home
LDI_BL 0x1e                           # End
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_end
LDI_BL 0x13                           # Left
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_left
LDI_BL 0x14                           # Right
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_right
#LDI_BL 0x12                           # Up
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .rl_history_up
#LDI_BL 0x11                           # Down
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .rl_history_down

LDI_BL ' '                            # printable range: 0x20-0x7e
ALUOP_FLAGS %A-B%+%AL%+%BL%
JO .rl_poll                           # < space -> ignore
LDI_BL '~'
ALUOP_FLAGS %B-A%+%AL%+%BL%
JO .rl_poll                           # > tilde -> ignore
JMP .rl_typed_char

###
# Enter / Ctrl+C: both converge on .rl_finish (newline + return).
.rl_enter
#CALL .rl_history_append               # no-op if history disabled or line empty
LD_AL $rl_len
CALL .rl_seek                         # cursor to end of input before newline
LD_AL $rl_len
LDI_AH 0x00
JMP .rl_finish

.rl_ctrlc
LD_AL $rl_len                         # seek to end of whatever was visually
CALL .rl_seek                         # typed; the RETURNED string is empty,
ST $rl_len 0x00                       # but the screen isn't scrubbed
LD_DH $rl_buf
LD_DL $rl_buf+1
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%                 # buf[0] = 0
LDI_AL 0x00
LDI_AH 0x01
JMP .rl_finish

.rl_finish                            # Input: AL = return length, AH = return status
ALUOP_ADDR %A%+%AL% $rl_ret_len
ALUOP_ADDR %A%+%AH% $rl_ret_status
LDI_AL 0x0a
CALL .rl_echo_putchar
LD_AL $rl_ret_len
LD_AH $rl_ret_status
JMP .rl_return

###
# Backspace: move left (no-op at buffer start), then remove the char now
# under the cursor and redraw the tail.
.rl_backspace
LD_AL $rl_pos
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_pos
CALL .rl_shift_left
LD_AL $rl_pos
LDI_BH 0x01
CALL .rl_redraw_tail
JMP .rl_poll

###
# Delete: remove the char under the cursor (no-op at buffer end).
.rl_delete
LD_AL $rl_pos
LD_BL $rl_len
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff pos < len
JNO .rl_poll
LD_AL $rl_pos
CALL .rl_shift_left
LD_AL $rl_pos
LDI_BH 0x01
CALL .rl_redraw_tail
JMP .rl_poll

.rl_home
LDI_AL 0x00
ALUOP_ADDR %A%+%AL% $rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_end
LD_AL $rl_len
ALUOP_ADDR %A%+%AL% $rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_left
LD_AL $rl_pos
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_right
LD_AL $rl_pos
LD_BL $rl_len
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_poll                          # already at end
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_pos
CALL .rl_seek
JMP .rl_poll

####
## Up: browse one entry further into the past (no-op if disabled or already
## at the oldest stored entry).
#.rl_history_up
#CALL .rl_hist_check
#JZ .rl_poll
#
#LD_AL $rl_history_browse_idx
#LD_BL $rl_history_count
#ALUOP_FLAGS %AxB%+%AL%+%BL%
#JEQ .rl_poll                          # already showing the oldest entry
#
#ALUOP_AL %A+1%+%AL%
#ALUOP_ADDR %A%+%AL% $rl_history_browse_idx
#
#CALL .rl_hist_calc_idx                # AL = target physical slot
#CALL .rl_history_recall_entry
#JMP .rl_poll
#
####
## Down: browse one entry back toward the present; past the newest entry,
## clears the line (no-op if disabled or already on the fresh/empty line).
#.rl_history_down
#CALL .rl_hist_check
#JZ .rl_poll
#
#LD_AL $rl_history_browse_idx
#ALUOP_FLAGS %A%+%AL%
#JZ .rl_poll                           # already on the fresh line
#
#ALUOP_AL %A-1%+%AL%                   # Z set iff browse_idx just hit 0
#ALUOP_ADDR %A%+%AL% $rl_history_browse_idx
#JZ .rl_hist_down_clear
#
#CALL .rl_hist_calc_idx
#CALL .rl_history_recall_entry
#JMP .rl_poll
#
#.rl_hist_down_clear
#LD_AL $rl_len
#ALUOP_ADDR %A%+%AL% $rl_tmp_blank     # remember old length to blank it out
#LDI_AL 0x00
#ALUOP_ADDR %A%+%AL% $rl_len
#ALUOP_ADDR %A%+%AL% $rl_pos
#LD_DH $rl_buf
#LD_DL $rl_buf+1
#LDI_AL 0x00
#ALUOP_ADDR_D %A%+%AL%                 # buf[0] = 0
#LDI_AL 0x00
#LD_BH $rl_tmp_blank
#CALL .rl_redraw_tail
#JMP .rl_poll
#
###
# A normal printable character: insert or overwrite per $rl_insert.
.rl_typed_char
ALUOP_ADDR %A%+%AL% $rl_tmp_char

# Always insert -- overwrite mode is CUT/DELETED (see file header).
CALL .rl_is_full
JEQ .rl_poll                          # buffer full: ignore the keystroke

LD_AL $rl_pos
ALUOP_ADDR %A%+%AL% $rl_tmp_idx       # remember the insertion point
CALL .rl_insert_shift_right

LD_AL $rl_tmp_idx
CALL .rl_buf_addr                     # D = buf + insertion point
LD_AL $rl_tmp_char
ALUOP_ADDR_D %A%+%AL%

LD_AL $rl_len
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_len
LD_AL $rl_tmp_idx
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_pos

LD_AL $rl_tmp_idx
LDI_BH 0x00                           # string grew: nothing to blank
CALL .rl_redraw_tail
JMP .rl_poll

.rl_return
POP_BL
POP_BH
POP_DL
POP_DH
POP_CL
POP_CH
RET

######
# --- internal helpers ---

######
# Moves the screen cursor to the position corresponding to buffer index AL
# ($rl_start_addr + AL, address-linear -- see file header). No-ops if echo
# is off.
#
# Inputs:
#  AL - buffer index
# Clobbers: A, B.
.rl_seek
LD_BL $rl_echo
ALUOP_FLAGS %B%+%BL%
JZ .rl_seek_ret
ALUOP_BL %A%+%AL%
LDI_BH 0x00
LD_AH $rl_start_addr
LD_AL $rl_start_addr+1
ALUOP16O_A %ALU16_A+B%
JMP :cursor_goto_addr                 # tail call
.rl_seek_ret
RET

######
# Prints AL via :putchar unless echo is off.
#
# Inputs:
#  AL - char
.rl_echo_putchar
ALUOP_PUSH %A%+%AL%
LD_AL $rl_echo
ALUOP_FLAGS %A%+%AL%
POP_AL
JZ .rl_echo_ret
CALL :putchar
.rl_echo_ret
RET

######
# Tests whether the buffer already holds the maximum content chars
# (maxlen-1). Shared by the insert and overwrite-extend paths.
#
# Outputs: E flag set iff full (JEQ after the call).
# Clobbers: A, B.
.rl_is_full
LD_AL $rl_maxlen
LDI_BL 0x01
ALUOP_AL %A-B%+%AL%+%BL%              # AL = maxlen-1 (max content chars)
LD_BL $rl_len
ALUOP_FLAGS %AxB%+%AL%+%BL%
RET

######
# Computes a pointer into the readline buffer at a given index.
#
# Inputs:
#  AL - buffer index
# Outputs:
#  D - $rl_buf + AL
# Clobbers: A, B.
.rl_buf_addr
ALUOP_BL %A%+%AL%
LDI_BH 0x00
LD_AH $rl_buf
LD_AL $rl_buf+1
ALUOP16O_A %ALU16_A+B%
ALUOP_ADDR %A%+%AH% $rl_tmp_addr
ALUOP_ADDR %A%+%AL% $rl_tmp_addr+1
LD_DH $rl_tmp_addr
LD_DL $rl_tmp_addr+1
RET

######
# Seeks the screen cursor to buffer index AL, then reprints buf[AL..len-1]
# via :putchar, then BH additional trailing spaces (to erase leftover
# glyphs when the content shrank), then reseeks to $rl_pos. Every step is a
# no-op when echo is off (via .rl_seek/.rl_echo_putchar).
#
# Inputs:
#  AL - start index to reprint from
#  BH - trailing blank count (0 or 1)
# Clobbers: A, B, D.
.rl_redraw_tail
ALUOP_ADDR %B%+%BH% $rl_tmp_blank
ALUOP_PUSH %A%+%AL%
CALL .rl_seek
POP_AL

LD_BL $rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - start_index
ALUOP_ADDR %B%+%BL% $rl_tmp_count
CALL .rl_buf_addr                     # D = buf + start_index

.rl_rt_loop
LD_BL $rl_tmp_count
ALUOP_FLAGS %B%+%BL%
JZ .rl_rt_blanks
LDA_D_AL
CALL .rl_echo_putchar
INCR_D
LD_BL $rl_tmp_count
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% $rl_tmp_count
JMP .rl_rt_loop
.rl_rt_blanks
LD_BL $rl_tmp_blank
ALUOP_FLAGS %B%+%BL%
JZ .rl_rt_reseek
LDI_AL ' '
CALL .rl_echo_putchar
LD_BL $rl_tmp_blank
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% $rl_tmp_blank
JMP .rl_rt_blanks
.rl_rt_reseek
LD_AL $rl_pos
JMP .rl_seek                          # tail call

######
# Removes one character from the buffer at index AL, shifting buf[AL+1..
# len] (including the null terminator) left over buf[AL..len-1]. len--.
#
# Inputs:
#  AL - index to remove
# Clobbers: A, B, C, D.
.rl_shift_left
ALUOP_ADDR %A%+%AL% $rl_tmp_idx
LD_BL $rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - N (copy count, incl. null;
                                       # N is always an existing index, so
                                       # this is always >= 1)
ALUOP_ADDR %B%+%BL% $rl_tmp_count

CALL .rl_buf_addr                     # D = buf + N (dest)
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% $rl_tmp_dest
ALUOP_ADDR %A%+%AL% $rl_tmp_dest+1

LD_AL $rl_tmp_idx
LDI_BL 0x01
ALUOP_AL %A+B%+%AL%+%BL%              # AL = N+1
CALL .rl_buf_addr                     # D = buf + N + 1 (source)
ST_DH $rl_tmp_src
ST_DL $rl_tmp_src+1

# dest (N) < source (N+1), so a forward copy is safe (never reads data
# it has already overwritten) -- use the ROM's :memcpy instead of a
# hand-rolled loop through TD, which isn't interrupt-safe (TD is
# microcode scratch clobbered by IRQ entry). :memcpy wants C = source,
# D = dest -- the reverse of how the addresses were just computed above
# -- so load both fresh from the stashed words rather than shuffling
# registers (MOV only ever goes C/D -> A/B/T, never D -> C).
LD_CH $rl_tmp_src
LD_CL $rl_tmp_src+1
LD_DH $rl_tmp_dest
LD_DL $rl_tmp_dest+1
LD_AL $rl_tmp_count
ALUOP_AL %A-1%+%AL%                   # :memcpy takes count-1
CALL :memcpy

LD_AL $rl_len
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% $rl_len
RET

######
# Opens a one-character gap at buffer index AL, shifting buf[AL..len]
# (including the null terminator) right by one. Does NOT update $rl_len
# (the caller bumps it after writing the new character into the gap).
#
# Inputs:
#  AL - index of the new gap
# Clobbers: A, B, C, D.
.rl_insert_shift_right
ALUOP_ADDR %A%+%AL% $rl_tmp_idx
LD_BL $rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - N
ALUOP_BL %B+1%+%BL%                   # BL = len - N + 1 (copy count, incl. null)
ALUOP_ADDR %B%+%BL% $rl_tmp_count

LD_AL $rl_len                         # source: buf + len (the current null)
CALL .rl_buf_addr
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% $rl_tmp_src
ALUOP_ADDR %A%+%AL% $rl_tmp_src+1

LD_AL $rl_len
LDI_BL 0x01
ALUOP_AL %A+B%+%AL%+%BL%              # dest: buf + len + 1
CALL .rl_buf_addr
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% $rl_tmp_dest
ALUOP_ADDR %A%+%AL% $rl_tmp_dest+1

LD_CH $rl_tmp_src
LD_CL $rl_tmp_src+1                   # C = source pointer, walked downward
LD_DH $rl_tmp_dest
LD_DL $rl_tmp_dest+1                  # D = dest pointer, walked downward
.rl_shiftr_loop
LD_BL $rl_tmp_count
ALUOP_FLAGS %B%+%BL%
JZ .rl_shiftr_done
# dest = source+1 here, so this must walk high-to-low (an overlapping
# forward copy would read already-overwritten bytes) -- the ROM's
# increment-only :memcpy/MEMCPY_C_D can't do that direction, so this
# stays a hand-rolled loop through TD. TD is microcode scratch clobbered
# by IRQ entry, so mask interrupts across the exact two instructions
# that carry the byte through it.
MASKINT
LDA_C_TD
STA_D_TD
UMASKINT
DECR_C
DECR_D
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% $rl_tmp_count
JMP .rl_shiftr_loop
.rl_shiftr_done
RET

#######
## --- history helpers ---
#
#######
## Tests whether history is enabled.
##
## Outputs: Z flag clear iff $rl_history_buf != 0 (JZ after the call means
##          "disabled").
## Clobbers: A, B.
#.rl_hist_check
#LD_AH $rl_history_buf
#LD_AL $rl_history_buf+1
#ALUOP_BL %A%+%AL%
#ALUOP_FLAGS %A|B%+%AH%+%BL%
#RET
#
#######
## Converts a browse depth into a physical history slot index:
## index = (write_idx - browse_idx) mod capacity. capacity is an arbitrary
## runtime byte (not necessarily a power of two), so an underflowing
## subtraction is corrected by adding capacity back on rather than masking.
##
## Outputs:
##  AL - physical slot index
## Clobbers: A, B.
#.rl_hist_calc_idx
#LD_AL $rl_history_write_idx
#LD_BL $rl_history_browse_idx
#ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff write_idx < browse_idx
#JNO .rl_hist_calc_done
#ALUOP_AL %A-B%+%AL%+%BL%              # AL = write_idx - browse_idx, wrapped mod 256
#LD_BL $rl_history_capacity
#ALUOP_AL %A+B%+%AL%+%BL%              # AL += capacity -> correct mod-capacity index
#RET
#.rl_hist_calc_done
#ALUOP_AL %A-B%+%AL%+%BL%
#RET
#
#######
## Computes the RAM address of history slot AL (history_buf + AL*entry_sz),
## via repeated 16-bit addition -- slot counts are small (bounded by
## capacity, a handful to a few dozen in practice), so this stays far cheaper
## than pulling in the general-purpose :mul16.
##
## Inputs:
##  AL - history slot index
## Outputs:
##  D - history_buf + AL*entry_sz
## Clobbers: A, B.
#.rl_hist_addr
#ALUOP_ADDR %A%+%AL% $rl_tmp_idx       # remaining iteration count
#LD_AH $rl_history_buf
#LD_AL $rl_history_buf+1               # A = running address accumulator
#.rl_hist_addr_loop
#LD_BL $rl_tmp_idx
#ALUOP_FLAGS %B%+%BL%
#JZ .rl_hist_addr_done
#LDI_BH 0x00
#LD_BL $rl_history_entry_sz
#ALUOP16O_A %ALU16_A+B%
#LD_BL $rl_tmp_idx
#ALUOP_BL %B-1%+%BL%
#ALUOP_ADDR %B%+%BL% $rl_tmp_idx
#JMP .rl_hist_addr_loop
#.rl_hist_addr_done
#ALUOP_ADDR %A%+%AH% $rl_tmp_addr
#ALUOP_ADDR %A%+%AL% $rl_tmp_addr+1
#LD_DH $rl_tmp_addr
#LD_DL $rl_tmp_addr+1
#RET
#
#######
## Appends the current buffer to the history ring (Enter with non-empty
## input only), then advances write_idx (wrapping at capacity) and count
## (capped at capacity). No-op if history is disabled or the line is empty.
##
## Clobbers: A, B, C, D.
#.rl_history_append
#CALL .rl_hist_check
#JZ .rl_hist_append_ret
#
#LD_AL $rl_len
#ALUOP_FLAGS %A%+%AL%
#JZ .rl_hist_append_ret                # spec: empty Enter is not recorded
#
#LD_AL $rl_history_write_idx
#CALL .rl_hist_addr                    # D = destination slot
#
## buf (source) and the history slot (dest) are disjoint allocations, so
## there's no overlap direction to worry about -- the ROM's :memcpy is a
## direct fit (and avoids carrying each byte through TD by hand, which
## isn't interrupt-safe: TD is microcode scratch clobbered by IRQ entry).
#LD_CH $rl_buf
#LD_CL $rl_buf+1
#
## Copy min(len, entry_sz-1) raw characters, then always write our own null
## terminator afterward -- never rely on copying the source's own trailing
## null, because when len is clamped down, the source byte at that offset
## is a real character, not a null. entry_sz is a caller-managed global
## with no library-enforced relationship to $rl_maxlen, so a caller that
## configures entry_sz smaller than maxlen+1
## would otherwise have a max-length line overflow this :memcpy into the
## next history slot; truncating here matches this file's existing
## maxlen-truncation philosophy for the input buffer itself.
#LD_AL $rl_len
#LD_BL $rl_history_entry_sz
#ALUOP_BL %B-1%+%BL%                   # BL = entry_sz - 1 (max chars that fit)
#ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff len < entry_sz-1 (already safe)
#JO .rl_hist_append_len_safe
#ALUOP_AL %B%+%BL%                     # clamp: AL = entry_sz - 1 (safe char count)
#.rl_hist_append_len_safe
#ALUOP_AL %A-1%+%AL%                   # :memcpy count-1 == (safe char count) - 1
#CALL :memcpy
#ALUOP_ADDR_D %zero%                   # explicit null at dest + safe char count
#                                       # (:memcpy's documented D postcondition)
#
#LD_AL $rl_history_write_idx
#ALUOP_AL %A+1%+%AL%
#LD_BL $rl_history_capacity
#ALUOP_FLAGS %AxB%+%AL%+%BL%           # E set iff wrapped past the last slot
#JNE .rl_hist_append_wstore
#LDI_AL 0x00
#.rl_hist_append_wstore
#ALUOP_ADDR %A%+%AL% $rl_history_write_idx
#
#LD_AL $rl_history_count
#LD_BL $rl_history_capacity
#ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff count < capacity
#JNO .rl_hist_append_ret               # already full: count stays capped
#ALUOP_AL %A+1%+%AL%
#ALUOP_ADDR %A%+%AL% $rl_history_count
#
#.rl_hist_append_ret
#RET
#
#######
## Loads history slot AL into the readline buffer, updating $rl_len and
## $rl_pos (cursor lands at the end of the recalled text). Does not touch
## the screen -- callers handle repaint.
##
## Inputs:
##  AL - history slot index
## Clobbers: A, B, C, D.
#.rl_hist_load
#CALL .rl_hist_addr                    # D = source slot
#LD_CH $rl_buf
#LD_CL $rl_buf+1
#LDI_BL 0x00                           # running length
#.rl_hist_load_loop
#LDA_D_AL
#ALUOP_ADDR_C %A%+%AL%                 # buf[i] = char (copies the null too)
#ALUOP_FLAGS %A%+%AL%
#JZ .rl_hist_load_done
#INCR_C
#INCR_D
#ALUOP_BL %B+1%+%BL%
#JMP .rl_hist_load_loop
#.rl_hist_load_done
#ALUOP_ADDR %B%+%BL% $rl_len
#LD_AL $rl_len
#ALUOP_ADDR %A%+%AL% $rl_pos
#RET
#
#######
## Full-line repaint after recalling history slot AL: loads the entry, then
## reprints from index 0, blanking out any leftover tail from a longer
## previous line.
##
## Inputs:
##  AL - history slot index
## Clobbers: A, B, D (and whatever .rl_hist_load / .rl_redraw_tail clobber).
#.rl_history_recall_entry
#LD_BL $rl_len
#ALUOP_ADDR %B%+%BL% $rl_tmp_blank     # stash old length
#CALL .rl_hist_load
#
#LD_AL $rl_tmp_blank                   # old length
#LD_BL $rl_len                         # new length
#ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff old < new (nothing to blank)
#JO .rl_hrecall_noblanks
#ALUOP_AL %A-B%+%AL%+%BL%              # AL = old - new
#JMP .rl_hrecall_have
#.rl_hrecall_noblanks
#LDI_AL 0x00
#.rl_hrecall_have
#ALUOP_ADDR %A%+%AL% $rl_tmp_blank
#
#LDI_AL 0x00                           # reprint from the start of the line
#LD_BH $rl_tmp_blank
#CALL .rl_redraw_tail
#RET
