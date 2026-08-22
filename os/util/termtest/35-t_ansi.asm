# vim: syntax=asm-mycpu

# Prototype of the ANSI escape-sequence state machine (TERMINAL_REFACTOR.md
# 2.2.3). Non-SGR sequences only -- Task 4 extends the 'm' dispatch with
# SGR + 256-color.
#
# :t_putchar (30-t_termout.asm) already does the ESC-detection and calls
# :t_ansi_feed for every character while :t_ansi_state != 0. This file
# owns everything from the first post-ESC character onward.
#
# Not a hot path (bounded by human typing speed or the rare escape-heavy
# print burst), so these routines favor clarity and code size over
# instruction count -- liberal callee-save, no register-sharing tricks.

######
# Feeds one character into the ANSI parser. Only called while
# :t_ansi_state is 1 (waiting for '[') or 2 (accumulating a CSI
# sequence) -- the initial ESC that sets state to 1 is handled inline by
# :t_putchar and never reaches here.
#
# Every character passed in is recorded into :t_ansi_seq_buf first (for
# error-recovery flushing), then dispatched per the current state.
#
# Inputs:
#  AL - character to feed
# All registers preserved.
:t_ansi_feed
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

ALUOP_DH %A%+%AL%                    # stash the incoming char in DH

# --- append to :t_ansi_seq_buf, checking overflow ---
LD_BL :t_ansi_seq_len
LDI_AH 16
ALUOP_FLAGS %AxB%+%AH%+%BL%          # buffer already full?
JEQ .ansi_invalid

LDI_A :t_ansi_seq_buf
LDI_BH 0x00
ALUOP16O_A %ALU16_A+B%               # A = seq_buf base + seq_len
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # C = &seq_buf[seq_len]
MOV_DH_AL                            # AL = char again (DH untouched)
ALUOP_ADDR_C %A%+%AL%
LD_BL :t_ansi_seq_len
ALUOP_BL %B+1%+%BL%
ALUOP_ADDR %B%+%BL% :t_ansi_seq_len

# --- dispatch on parser state (AL is still the char) ---
LD_BL :t_ansi_state
LDI_AH 0x01
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .ansi_state1
JMP .ansi_state2

# --- state 1: waiting for '[' ---
.ansi_state1
LDI_BL 0x5b                          # '['
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .ansi_invalid                    # ESC not followed by '[' -- invalid
ST :t_ansi_state 0x02
ST :t_ansi_param_count 0x00
ST16 :t_ansi_accum 0x0000
ST :t_ansi_private 0x00
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
LD_BL :t_ansi_accum                  # hi byte -- nonzero means value > 255
ALUOP_FLAGS %B%+%BL%
JNZ .ansi_invalid
JMP .ansi_return

.ansi_semicolon
LD_BL :t_ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%          # already have 4 params stored?
JEQ .ansi_invalid
CALL .ansi_store_param
JMP .ansi_return

.ansi_private_flag
ST :t_ansi_private 0x01
JMP .ansi_return

.ansi_final_byte
LD_BL :t_ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .ansi_invalid
CALL .ansi_store_param                # finalize the trailing parameter
CALL .ansi_dispatch_command            # AL is still the final byte
JMP .ansi_finish

# --- shared exits ---
.ansi_invalid
CALL :t_ansi_flush
JMP .ansi_epilogue

.ansi_finish
CALL :t_ansi_reset
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
# Flushes the buffered raw characters in :t_ansi_seq_buf to the screen
# via :t_putchar_raw (bypassing the parser), then resets it. Used both
# for parser error recovery and by :t_print when a string ends mid-
# sequence (2.2.3 case 4).
:t_ansi_flush
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
LDI_C :t_ansi_seq_buf
LD_BL :t_ansi_seq_len
ALUOP_FLAGS %B%+%BL%
JZ .flush_empty
.flush_loop
LDA_C_AL
CALL :t_putchar_raw
INCR_C
ALUOP_BL %B-1%+%BL%
JNZ .flush_loop
.flush_empty
CALL :t_ansi_reset
POP_CL
POP_CH
POP_BL
POP_AL
RET

######
# Resets the parser to state 0 with an empty sequence buffer. Does not
# print anything -- callers that need to show the buffered characters
# must go through :t_ansi_flush instead.
:t_ansi_reset
ST :t_ansi_state 0x00
ST :t_ansi_param_count 0x00
ST16 :t_ansi_accum 0x0000
ST :t_ansi_private 0x00
ST :t_ansi_seq_len 0x00
RET

######
# Multiplies :t_ansi_accum by 10 and adds a single decimal digit.
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

LD16_B :t_ansi_accum
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
ALUOP_ADDR %B%+%BH% :t_ansi_accum
ALUOP_ADDR %B%+%BL% :t_ansi_accum+1

POP_DH
POP_BL
POP_BH
POP_AH
RET

######
# Stores :t_ansi_accum into :t_ansi_param_buf[:t_ansi_param_count],
# increments the count, and resets the accumulator. Caller must ensure
# param_count < 4 before calling.
.ansi_store_param
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
LD_BL :t_ansi_param_count
LDI_BH 0x00
ALUOP_BL %B<<1%+%BL%                 # BL = param_count*2 (word offset)
LDI_A :t_ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # C = &param_buf[param_count]
LD16_A :t_ansi_accum
ALUOP_ADDR_C %A%+%AH%
INCR_C
ALUOP_ADDR_C %A%+%AL%
LD_BL :t_ansi_param_count
ALUOP_BL %B+1%+%BL%
ALUOP_ADDR %B%+%BL% :t_ansi_param_count
ST16 :t_ansi_accum 0x0000
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
LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .getn_default
LD_BL :t_ansi_param_buf+1
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
LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .getmode_default
LD_AL :t_ansi_param_buf+1
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
LD_BL :t_term_render_color
ALUOP_FLAGS %B%+%BL%
JZ .getcolor_white
LD_BL :t_term_current_color
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
# value = min(59, value + n) -- used for the row axis.
#
# Inputs:
#  AL - value, BL - n
# Outputs:
#  AL - clamped result
.ansi_inc_clamp59
ALUOP_BH %A%+%AL%                    # BH = value copy
LDI_AH 59
ALUOP_AH %A-B%+%AH%+%BH%             # AH = room = 59 - value
ALUOP_FLAGS %A-B%+%AH%+%BL%          # O set iff room < n
JO .incclamp59_max
ALUOP_AL %A+B%+%AL%+%BL%
RET
.incclamp59_max
LDI_AL 59
RET

######
# value = min(63, value + n) -- used for the column axis.
#
# Inputs:
#  AL - value, BL - n
# Outputs:
#  AL - clamped result
.ansi_inc_clamp63
ALUOP_BH %A%+%AL%
LDI_AH 63
ALUOP_AH %A-B%+%AH%+%BH%
ALUOP_FLAGS %A-B%+%AH%+%BL%
JO .incclamp63_max
ALUOP_AL %A+B%+%AL%+%BL%
RET
.incclamp63_max
LDI_AL 63
RET

######
# Fills count bytes starting at D with the byte in BL.
#
# Inputs:
#  D - start address
#  A - count (16-bit, 0 is a valid no-op)
#  BL - fill byte
# Clobbers: A, D.
.ansi_fill_range
ALUOP16Z_FLAGS %ALU16_Azero%
JZ .fillrange_done
.fillrange_loop
ALUOP_ADDR_D %B%+%BL%
INCR_D
ALUOP16O_A %ALU16_A-1%
ALUOP16Z_FLAGS %ALU16_Azero%
JNZ .fillrange_loop
.fillrange_done
RET

######
# Erases a range of the display, chars filled with 0x00 and colors
# filled per :ansi_get_erase_color, sharing the range across both
# framebuffers (2.2.3 J/K commands).
#
# Inputs:
#  A - start offset within the display page (0-3839)
#  B - count (16-bit)
.ansi_erase_range
ALUOP_ADDR %A%+%AH% .erase_offset
ALUOP_ADDR %A%+%AL% .erase_offset+1
ALUOP_ADDR %B%+%BH% .erase_count
ALUOP_ADDR %B%+%BL% .erase_count+1

LDI_A %display_chars%
LD16_B .erase_offset
ALUOP16O_A %ALU16_A+B%
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%
LD16_A .erase_count
LDI_BL 0x00
CALL .ansi_fill_range

LDI_A %display_color%
LD16_B .erase_offset
ALUOP16O_A %ALU16_A+B%
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%
CALL .ansi_get_erase_color            # BL = fill color; clobbers A, so
                                       # fetch it before loading the count
LD16_A .erase_count
CALL .ansi_fill_range
RET

######
# Executes the command selected by the final byte in AL, using the
# parameters already stored in :t_ansi_param_buf/_count and
# :t_ansi_private. Unrecognized final bytes are a silent no-op (2.2.3
# "valid but unsupported").
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
LDI_BL 0x4a                          # 'J'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_erase_screen
LDI_BL 0x4b                          # 'K'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_erase_line
LDI_BL 0x73                          # 's'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_save
LDI_BL 0x75                          # 'u'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_restore
LDI_BL 0x68                          # 'h'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_h
LDI_BL 0x6c                          # 'l'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_l
JMP .disp_done                       # unsupported final byte: no-op

.disp_up
CALL .ansi_get_n
LD_AL :t_crsr_row
CALL .ansi_dec_clamp0
ALUOP_AH %A%+%AL%
LD_AL :t_crsr_col
CALL :t_cursor_goto_rowcol
JMP .disp_done

.disp_down
CALL .ansi_get_n
LD_AL :t_crsr_row
CALL .ansi_inc_clamp59
ALUOP_AH %A%+%AL%
LD_AL :t_crsr_col
CALL :t_cursor_goto_rowcol
JMP .disp_done

.disp_right
CALL .ansi_get_n
LD_AL :t_crsr_col
CALL .ansi_inc_clamp63
ALUOP_PUSH %A%+%AL%
LD_AH :t_crsr_row
POP_AL
CALL :t_cursor_goto_rowcol
JMP .disp_done

.disp_left
CALL .ansi_get_n
LD_AL :t_crsr_col
CALL .ansi_dec_clamp0
ALUOP_PUSH %A%+%AL%
LD_AH :t_crsr_row
POP_AL
CALL :t_cursor_goto_rowcol
JMP .disp_done

.disp_gotorc
LDI_BL 1                             # default row (1-based)
LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_row_default
LD_AL :t_ansi_param_buf+1
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_row_default
ALUOP_BL %A%+%AL%
.gotorc_row_default
ALUOP_BL %B-1%+%BL%                  # BL = new row (0-based)
ALUOP_PUSH %B%+%BL%

LDI_BL 1                             # default col (1-based)
LD_AL :t_ansi_param_count
LDI_BH 2
ALUOP_FLAGS %A-B%+%AL%+%BH%          # O set iff count < 2
JO .gotorc_col_default
LD_AL :t_ansi_param_buf+3
ALUOP_FLAGS %A%+%AL%
JZ .gotorc_col_default
ALUOP_BL %A%+%AL%
.gotorc_col_default
ALUOP_BL %B-1%+%BL%                  # BL = new col (0-based)

POP_AH                                # AH = new row
ALUOP_AL %B%+%BL%                    # AL = new col
CALL :t_cursor_goto_rowcol
JMP .disp_done

.disp_erase_screen
CALL .ansi_get_mode
ALUOP_FLAGS %A%+%AL%
JZ .es_m0
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .es_m1
JMP .es_m2

.es_m0
LD_AH :t_crsr_row
LD_AL :t_crsr_col
CALL :t_cursor_conv_rowcol           # A = cursor offset
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # C = offset copy
LDI_B 3840
ALUOP16O_B %ALU16_B-A%               # B = count = 3840 - offset
MOV_CH_AH
MOV_CL_AL                            # A = offset (restored)
CALL .ansi_erase_range
JMP .disp_done

.es_m1
LD_AH :t_crsr_row
LD_AL :t_crsr_col
CALL :t_cursor_conv_rowcol           # A = cursor offset
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%                    # B = offset copy
ALUOP16O_B %ALU16_B+1%               # B = count = offset + 1
LDI_A 0x0000                         # A = start offset 0
CALL .ansi_erase_range
JMP .disp_done

.es_m2
LDI_A 0x0000
LDI_B 3840
CALL .ansi_erase_range
JMP .disp_done

.disp_erase_line
CALL .ansi_get_mode
ALUOP_FLAGS %A%+%AL%
JZ .el_m0
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .el_m1
JMP .el_m2

.el_m0
LD_AH :t_crsr_row
LD_AL :t_crsr_col
CALL :t_cursor_conv_rowcol           # A = cursor offset (erase start)
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                    # stash offset in C
LDI_BH 0x00
LD_BL :t_crsr_col
LDI_AH 64
ALUOP_BL %A-B%+%AH%+%BL%             # BL = 64 - col
MOV_CH_AH
MOV_CL_AL                            # A = offset (restored)
CALL .ansi_erase_range
JMP .disp_done

.el_m1
LD_AH :t_crsr_row
LDI_AL 0x00
CALL :t_cursor_conv_rowcol           # A = row start offset
LDI_BH 0x00
LD_BL :t_crsr_col
ALUOP_BL %B+1%+%BL%                  # BL = col + 1
CALL .ansi_erase_range
JMP .disp_done

.el_m2
LD_AH :t_crsr_row
LDI_AL 0x00
CALL :t_cursor_conv_rowcol           # A = row start offset
LDI_B 64
CALL .ansi_erase_range
JMP .disp_done

.disp_save
CALL :t_cursor_save
JMP .disp_done

.disp_restore
CALL :t_cursor_restore
JMP .disp_done

.disp_h
LD_AL :t_ansi_private
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL :t_ansi_param_buf+1
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done
CALL :t_cursor_on
JMP .disp_done

.disp_l
LD_AL :t_ansi_private
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JZ .disp_done
LD_AL :t_ansi_param_buf+1
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .disp_done
CALL :t_cursor_off
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

:t_ansi_state "\0"
:t_ansi_param_buf "\0\0\0\0\0\0\0\0"
:t_ansi_param_count "\0"
:t_ansi_accum "\0\0"
:t_ansi_private "\0"
:t_ansi_seq_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
:t_ansi_seq_len "\0"
.erase_offset "\0\0"
.erase_count "\0\0"
