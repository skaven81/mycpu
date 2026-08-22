# vim: syntax=asm-mycpu

# Prototype of the new buffer-based line editor (TERMINAL_REFACTOR.md 2.4).
# Replaces the ROM's marks-based :input with :t_readline, which edits a
# caller-supplied RAM buffer directly -- no marks, no cursor_save_mark/
# cursor_get_mark.
#
# Design (2.4.1/2.4.2):
#  - Caller owns the buffer (C), gives its size incl. null terminator (AL),
#    and an echo flag (AH bit 0). Returns AL=length, AH=status (0=Enter,
#    1=Ctrl+C).
#  - Internal state (.rl_*) is file-local, not reentrant -- matches every
#    other piece of terminal state in this library (:t_crsr_*, :t_ansi_*).
#    One readline call is active at a time.
#  - The screen cursor position always corresponds to buffer index .rl_pos
#    once an operation finishes (invariant maintained by every handler).
#    Since the framebuffer address space is linear (row*64+col, same
#    scheme :t_cursor_goto_addr/.cursor_advance already use), the screen
#    position for buffer index N is simply .rl_start_addr + N -- no need
#    to track row/col incrementally, and this naturally reproduces the
#    wrap-at-column-64 behavior typed text gets from :t_putchar (.rl_seek).
#    Known limitation: if the input scrolls the screen (crosses the bottom
#    edge), .rl_start_addr goes stale and repositioning after that point
#    would be wrong -- out of scope for the tested cases (Task 5).
#  - Echo (2.4.1 decision 3): every screen-touching primitive
#    (.rl_seek, .rl_echo_putchar) silently no-ops when .rl_echo is 0, so
#    buffer edits happen identically whether or not echo is on.
#  - Insert vs overwrite (2.4.1 decision 5) is a local (.rl_insert),
#    defaulting to insert (matches the ROM's $input_flags default of 1).
#  - History (Up/Down) hooks are no-ops for now -- Task 6 wires them to
#    :t_rl_history_*, declared here so Task 6 doesn't need to restructure
#    the dispatch.

######
# Reads a line of input with line editing support.
#
# Inputs:
#  C - pointer to caller-supplied buffer
#  AL - buffer size in bytes, including the null terminator
#  AH - flags: bit 0 = echo (1=on, 0=silent); bits 1-7 reserved
# Outputs:
#  AL - number of characters entered (0 for empty input or Ctrl+C)
#  AH - status: 0 = Enter, 1 = Ctrl+C abort
#  Buffer at C is filled with a null-terminated string
# All other registers preserved.
:t_readline
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

ALUOP_ADDR %A%+%AL% .rl_maxlen
LDI_BL 0x01
ALUOP_ADDR %A&B%+%AH%+%BL% .rl_echo

MOV_CH_AH
MOV_CL_AL
ALUOP_ADDR %A%+%AH% .rl_buf
ALUOP_ADDR %A%+%AL% .rl_buf+1

ST .rl_len 0x00
ST .rl_pos 0x00
ST .rl_insert 0x01                    # default: insert mode

LD_AH :t_crsr_addr_chars
LD_AL :t_crsr_addr_chars+1
ALUOP_ADDR %A%+%AH% .rl_start_addr
ALUOP_ADDR %A%+%AL% .rl_start_addr+1

LD_DH .rl_buf
LD_DL .rl_buf+1
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%                 # buf[0] = 0 (empty string so far)

###
# Poll loop
.rl_poll
CALL :kb_bufsize
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll
CALL :kb_readbuf                      # AH=keyflags, AL=char

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
LDI_BL 0x0f                           # Insert (toggle insert/overwrite)
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_toggle_insert
LDI_BL 0x13                           # Left
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_left
LDI_BL 0x14                           # Right
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_right
LDI_BL 0x12                           # Up
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_history_up
LDI_BL 0x11                           # Down
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_history_down

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
LD_AL .rl_len
CALL .rl_seek                         # cursor to end of input before newline
LD_AL .rl_len
LDI_AH 0x00
JMP .rl_finish

.rl_ctrlc
LD_AL .rl_len                         # seek to end of whatever was visually
CALL .rl_seek                         # typed; the RETURNED string is empty,
ST .rl_len 0x00                       # but the screen isn't scrubbed
LD_DH .rl_buf
LD_DL .rl_buf+1
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%                 # buf[0] = 0
LDI_AL 0x00
LDI_AH 0x01
JMP .rl_finish

.rl_finish                            # Input: AL = return length, AH = return status
ALUOP_ADDR %A%+%AL% .rl_ret_len
ALUOP_ADDR %A%+%AH% .rl_ret_status
LDI_AL 0x0a
CALL .rl_echo_putchar
LD_AL .rl_ret_len
LD_AH .rl_ret_status
JMP .rl_return

###
# Backspace: move left (no-op at buffer start), then remove the char now
# under the cursor and redraw the tail (2.4.2).
.rl_backspace
LD_AL .rl_pos
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos
CALL .rl_shift_left
LD_AL .rl_pos
LDI_BH 0x01
CALL .rl_redraw_tail
JMP .rl_poll

###
# Delete: remove the char under the cursor (no-op at buffer end).
.rl_delete
LD_AL .rl_pos
LD_BL .rl_len
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff pos < len
JNO .rl_poll
LD_AL .rl_pos
CALL .rl_shift_left
LD_AL .rl_pos
LDI_BH 0x01
CALL .rl_redraw_tail
JMP .rl_poll

.rl_home
LDI_AL 0x00
ALUOP_ADDR %A%+%AL% .rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_end
LD_AL .rl_len
ALUOP_ADDR %A%+%AL% .rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_toggle_insert
LD_AL .rl_insert
LDI_BL 0x01
ALUOP_AL %AxB%+%AL%+%BL%
ALUOP_ADDR %A%+%AL% .rl_insert
JMP .rl_poll

.rl_left
LD_AL .rl_pos
ALUOP_FLAGS %A%+%AL%
JZ .rl_poll
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos
CALL .rl_seek
JMP .rl_poll

.rl_right
LD_AL .rl_pos
LD_BL .rl_len
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .rl_poll                          # already at end
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos
CALL .rl_seek
JMP .rl_poll

# Task 6 wires these to :t_rl_history_*; for now (and whenever history is
# disabled) Up/Down are no-ops.
.rl_history_up
JMP .rl_poll

.rl_history_down
JMP .rl_poll

###
# A normal printable character: insert or overwrite per .rl_insert.
.rl_typed_char
ALUOP_ADDR %A%+%AL% .rl_tmp_char
LD_AL .rl_insert
ALUOP_FLAGS %A%+%AL%
JZ .rl_typed_overwrite

# --- insert mode: open a gap at .rl_pos, write the char, redraw the tail ---
CALL .rl_is_full
JEQ .rl_poll                          # buffer full: ignore the keystroke

LD_AL .rl_pos
ALUOP_ADDR %A%+%AL% .rl_tmp_idx       # remember the insertion point
CALL .rl_insert_shift_right

LD_AL .rl_tmp_idx
CALL .rl_buf_addr                     # D = buf + insertion point
LD_AL .rl_tmp_char
ALUOP_ADDR_D %A%+%AL%

LD_AL .rl_len
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_len
LD_AL .rl_tmp_idx
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos

LD_AL .rl_tmp_idx
LDI_BH 0x00                           # string grew: nothing to blank
CALL .rl_redraw_tail
JMP .rl_poll

# --- overwrite mode: replace in place, or extend by one at the end ---
.rl_typed_overwrite
LD_AL .rl_pos
LD_BL .rl_len
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff pos < len
JO .rl_overwrite_inplace

CALL .rl_is_full
JEQ .rl_poll                          # buffer full: ignore

LD_AL .rl_pos
CALL .rl_buf_addr                     # D = buf + pos (currently the null)
LD_AL .rl_tmp_char
ALUOP_ADDR_D %A%+%AL%
INCR_D
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%                 # new null terminator

LD_AL .rl_len
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_len
LD_AL .rl_pos
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos

LD_AL .rl_tmp_char
CALL .rl_echo_putchar
JMP .rl_poll

.rl_overwrite_inplace
LD_AL .rl_pos
CALL .rl_buf_addr
LD_AL .rl_tmp_char
ALUOP_ADDR_D %A%+%AL%

LD_AL .rl_pos
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_pos

LD_AL .rl_tmp_char
CALL .rl_echo_putchar
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
# (.rl_start_addr + AL, address-linear -- see file header). No-ops if echo
# is off.
#
# Inputs:
#  AL - buffer index
# Clobbers: A, B.
.rl_seek
LD_BL .rl_echo
ALUOP_FLAGS %B%+%BL%
JZ .rl_seek_ret
ALUOP_BL %A%+%AL%
LDI_BH 0x00
LD_AH .rl_start_addr
LD_AL .rl_start_addr+1
ALUOP16O_A %ALU16_A+B%
JMP :t_cursor_goto_addr               # tail call
.rl_seek_ret
RET

######
# Prints AL via :t_putchar unless echo is off.
#
# Inputs:
#  AL - char
.rl_echo_putchar
ALUOP_PUSH %A%+%AL%
LD_AL .rl_echo
ALUOP_FLAGS %A%+%AL%
POP_AL
JZ .rl_echo_ret
CALL :t_putchar
.rl_echo_ret
RET

######
# Tests whether the buffer already holds the maximum content chars
# (maxlen-1). Shared by the insert and overwrite-extend paths.
#
# Outputs: E flag set iff full (JEQ after the call).
# Clobbers: A, B.
.rl_is_full
LD_AL .rl_maxlen
LDI_BL 0x01
ALUOP_AL %A-B%+%AL%+%BL%              # AL = maxlen-1 (max content chars)
LD_BL .rl_len
ALUOP_FLAGS %AxB%+%AL%+%BL%
RET

######
# Computes a pointer into the readline buffer at a given index.
#
# Inputs:
#  AL - buffer index
# Outputs:
#  D - .rl_buf + AL
# Clobbers: A, B.
.rl_buf_addr
ALUOP_BL %A%+%AL%
LDI_BH 0x00
LD_AH .rl_buf
LD_AL .rl_buf+1
ALUOP16O_A %ALU16_A+B%
ALUOP_ADDR %A%+%AH% .rl_tmp_addr
ALUOP_ADDR %A%+%AL% .rl_tmp_addr+1
LD_DH .rl_tmp_addr
LD_DL .rl_tmp_addr+1
RET

######
# Seeks the screen cursor to buffer index AL, then reprints buf[AL..len-1]
# via :t_putchar, then BH additional trailing spaces (to erase leftover
# glyphs when the content shrank), then reseeks to .rl_pos. Every step is
# a no-op when echo is off (via .rl_seek/.rl_echo_putchar).
#
# Inputs:
#  AL - start index to reprint from
#  BH - trailing blank count (0 or 1)
# Clobbers: A, B, D.
.rl_redraw_tail
ALUOP_ADDR %B%+%BH% .rl_tmp_blank
ALUOP_PUSH %A%+%AL%
CALL .rl_seek
POP_AL

LD_BL .rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - start_index
ALUOP_ADDR %B%+%BL% .rl_tmp_count
CALL .rl_buf_addr                     # D = buf + start_index

.rl_rt_loop
LD_BL .rl_tmp_count
ALUOP_FLAGS %B%+%BL%
JZ .rl_rt_blanks
LDA_D_AL
CALL .rl_echo_putchar
INCR_D
LD_BL .rl_tmp_count
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% .rl_tmp_count
JMP .rl_rt_loop
.rl_rt_blanks
LD_BL .rl_tmp_blank
ALUOP_FLAGS %B%+%BL%
JZ .rl_rt_reseek
LDI_AL ' '
CALL .rl_echo_putchar
LD_BL .rl_tmp_blank
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% .rl_tmp_blank
JMP .rl_rt_blanks
.rl_rt_reseek
LD_AL .rl_pos
JMP .rl_seek                          # tail call

######
# Removes one character from the buffer at index AL, shifting buf[AL+1..
# len] (including the null terminator) left over buf[AL..len-1]. len--.
#
# Inputs:
#  AL - index to remove
# Clobbers: A, B, C, D.
.rl_shift_left
ALUOP_ADDR %A%+%AL% .rl_tmp_idx
LD_BL .rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - N (copy count, incl. null)
ALUOP_ADDR %B%+%BL% .rl_tmp_count

CALL .rl_buf_addr                     # D = buf + N (dest)
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% .rl_tmp_dest
ALUOP_ADDR %A%+%AL% .rl_tmp_dest+1

LD_AL .rl_tmp_idx
LDI_BL 0x01
ALUOP_AL %A+B%+%AL%+%BL%              # AL = N+1
CALL .rl_buf_addr                     # D = buf + N + 1 (source)

LD_CH .rl_tmp_dest
LD_CL .rl_tmp_dest+1                  # C free to use: :t_readline preserves
                                       # the caller's C via push/pop around
                                       # the whole function
.rl_shiftl_loop
LD_BL .rl_tmp_count
ALUOP_FLAGS %B%+%BL%
JZ .rl_shiftl_done
LDA_D_TD
STA_C_TD
INCR_D
INCR_C
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% .rl_tmp_count
JMP .rl_shiftl_loop
.rl_shiftl_done
LD_AL .rl_len
ALUOP_AL %A-1%+%AL%
ALUOP_ADDR %A%+%AL% .rl_len
RET

######
# Opens a one-character gap at buffer index AL, shifting buf[AL..len]
# (including the null terminator) right by one. Does NOT update .rl_len
# (the caller bumps it after writing the new character into the gap).
#
# Inputs:
#  AL - index of the new gap
# Clobbers: A, B, C, D.
.rl_insert_shift_right
ALUOP_ADDR %A%+%AL% .rl_tmp_idx
LD_BL .rl_len
ALUOP_BL %B-A%+%AL%+%BL%              # BL = len - N
ALUOP_BL %B+1%+%BL%                   # BL = len - N + 1 (copy count, incl. null)
ALUOP_ADDR %B%+%BL% .rl_tmp_count

LD_AL .rl_len                         # source: buf + len (the current null)
CALL .rl_buf_addr
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% .rl_tmp_src
ALUOP_ADDR %A%+%AL% .rl_tmp_src+1

LD_AL .rl_len
LDI_BL 0x01
ALUOP_AL %A+B%+%AL%+%BL%              # dest: buf + len + 1
CALL .rl_buf_addr
MOV_DH_AH
MOV_DL_AL
ALUOP_ADDR %A%+%AH% .rl_tmp_dest
ALUOP_ADDR %A%+%AL% .rl_tmp_dest+1

LD_CH .rl_tmp_src
LD_CL .rl_tmp_src+1                   # C = source pointer, walked downward
LD_DH .rl_tmp_dest
LD_DL .rl_tmp_dest+1                  # D = dest pointer, walked downward
.rl_shiftr_loop
LD_BL .rl_tmp_count
ALUOP_FLAGS %B%+%BL%
JZ .rl_shiftr_done
LDA_C_TD
STA_D_TD
DECR_C
DECR_D
ALUOP_BL %B-1%+%BL%
ALUOP_ADDR %B%+%BL% .rl_tmp_count
JMP .rl_shiftr_loop
.rl_shiftr_done
RET

.rl_buf "\0\0"
.rl_maxlen "\0"
.rl_echo "\0"
.rl_len "\0"
.rl_pos "\0"
.rl_insert "\0"
.rl_start_addr "\0\0"
.rl_tmp_addr "\0\0"
.rl_tmp_char "\0"
.rl_tmp_idx "\0"
.rl_tmp_count "\0"
.rl_tmp_blank "\0"
.rl_tmp_src "\0\0"
.rl_tmp_dest "\0\0"
.rl_ret_len "\0"
.rl_ret_status "\0"

# History (2.4.3) -- disabled until Task 6 fills in :t_rl_history_capacity/
# _count/_entry_sz/_write_idx/_browse_idx and wires .rl_history_up/_down.
:t_rl_history_buf "\0\0"
