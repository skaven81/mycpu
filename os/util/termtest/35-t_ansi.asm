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
ST .ansi_discard 0x00
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
LD_BL .ansi_discard
ALUOP_FLAGS %B%+%BL%
JNZ .ansi_semicolon_discarding

# Truecolor lookahead (2.2.3.1): if this ';' terminates the SECOND
# parameter (index 1) and the first was 38/48 and this one is exactly
# 2, it's ESC[38;2;r;g;bm / ESC[48;2;r;g;bm -- 5 params total, which
# would overflow the 4-param buffer below. Stop storing params for the
# rest of this sequence instead; the final-byte handler treats it as
# valid-but-unsupported (silent) once :ansi_discard is set.
LD_BL :t_ansi_param_count
LDI_AH 1
ALUOP_FLAGS %AxB%+%AH%+%BL%
JNE .semicolon_no_discard_check
LD_BL :t_ansi_param_buf+1
LDI_AH 38
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .semicolon_check_2
LDI_AH 48
ALUOP_FLAGS %AxB%+%AH%+%BL%
JNE .semicolon_no_discard_check
.semicolon_check_2
LD_BL :t_ansi_accum+1
LDI_AH 2
ALUOP_FLAGS %AxB%+%AH%+%BL%
JNE .semicolon_no_discard_check
ST .ansi_discard 0x01
ST16 :t_ansi_accum 0x0000
JMP .ansi_return

.semicolon_no_discard_check
LD_BL :t_ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%          # already have 4 params stored?
JEQ .ansi_invalid
CALL .ansi_store_param
JMP .ansi_return

.ansi_semicolon_discarding
ST16 :t_ansi_accum 0x0000
JMP .ansi_return

.ansi_private_flag
ST :t_ansi_private 0x01
JMP .ansi_return

.ansi_final_byte
LD_BL .ansi_discard
ALUOP_FLAGS %B%+%BL%
JNZ .final_byte_discarding

LD_BL :t_ansi_param_count
LDI_AH 4
ALUOP_FLAGS %AxB%+%AH%+%BL%
JEQ .ansi_invalid
CALL .ansi_store_param                # finalize the trailing parameter
CALL .ansi_dispatch_command            # AL is still the final byte
JMP .ansi_finish

.final_byte_discarding
CALL .ansi_dispatch_command            # AL still the final byte; the SGR
                                        # handler no-ops when discarding
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
ST .ansi_discard 0x00
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
LDI_BL 0x6d                          # 'm'
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .disp_sgr
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

.disp_sgr
LD_BL .ansi_discard
ALUOP_FLAGS %B%+%BL%
JNZ .disp_done                        # 38;2/48;2 truecolor: silent no-op

LD_AL :t_ansi_param_count
ALUOP_FLAGS %A%+%AL%
JNZ .sgr_loop_init
LDI_AL 0x00                           # ESC[m (no params) == reset
CALL .sgr_apply_code
JMP .disp_done

.sgr_loop_init
ST .sgr_index 0x00
ST .sgr_pending_shade 0x00
.sgr_loop
LD_AL .sgr_index
LD_BL :t_ansi_param_count
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O set iff index < count
JNO .sgr_apply_pending

# C = &param_buf[index]; AL = param value (low byte)
LD_AL .sgr_index
ALUOP_AL %A<<1%+%AL%                  # AL = index*2
LDI_AH 0x00
LDI_B :t_ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
INCR_C
LDA_C_AL

LDI_BL 38
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgr_256color
LDI_BL 48
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgr_256color

CALL .sgr_apply_code
LD_AL .sgr_index
ALUOP_ADDR %A+1%+%AL% .sgr_index      # index++
JMP .sgr_loop

.sgr_256color
ALUOP_PUSH %A%+%AL%                   # save 38/48 for later

LD_AL .sgr_index
ALUOP_AL %A+1%+%AL%                   # AL = index+1
LD_BL :t_ansi_param_count
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff (index+1) < count
JNO .sgr_256_skip

LD_AL .sgr_index
ALUOP_AL %A+1%+%AL%
ALUOP_AL %A<<1%+%AL%                  # AL = (index+1)*2
LDI_AH 0x00
LDI_B :t_ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
INCR_C
LDA_C_AL                              # AL = param[index+1]
LDI_BL 5
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .sgr_256_skip

LD_AL .sgr_index
ALUOP_AL %A+1%+%AL%
ALUOP_AL %A+1%+%AL%                   # AL = index+2
LD_BL :t_ansi_param_count
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff (index+2) < count
JNO .sgr_256_skip

LD_AL .sgr_index
ALUOP_AL %A+1%+%AL%
ALUOP_AL %A+1%+%AL%
ALUOP_AL %A<<1%+%AL%                  # AL = (index+2)*2
LDI_AH 0x00
LDI_B :t_ansi_param_buf
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
INCR_C
LDA_C_AL                              # AL = n (256-color index)
POP_BL                                 # BL = 38 or 48
CALL .sgr_apply_256color

LD_AL .sgr_index
ALUOP_AL %A+1%+%AL%
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A+1%+%AL% .sgr_index      # index += 3
JMP .sgr_loop

.sgr_256_skip
POP_BL                                 # discard saved 38/48, balance stack
LD_AL .sgr_index
ALUOP_ADDR %A+1%+%AL% .sgr_index      # index++ (malformed lookahead: skip 1)
JMP .sgr_loop

.sgr_apply_pending
LD_AL .sgr_pending_shade
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgr_do_bold
LDI_BL 2
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgr_do_normal
JMP .disp_done
.sgr_do_bold
CALL .sgrcode_bold
JMP .disp_done
.sgr_do_normal
CALL .sgrcode_normal
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
# Applies one simple SGR code (attributes 0/5/25, foreground colors
# 30-37/90-97/39). Codes 1 (bold) and 22 (normal) are DEFERRED -- they
# set :sgr_pending_shade instead of mutating the color immediately, so
# a combined sequence like ESC[1;31m upgrades the shade AFTER the color
# param is applied regardless of which order the two params appear in
# (see .disp_sgr's post-loop pending-shade application). All other
# codes are silently ignored per 2.2.3's ignored-code table.
#
# Inputs:
#  AL - SGR code (0-255)
# Clobbers: A, B, C.
.sgr_apply_code
LDI_BL 0
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_reset
LDI_BL 1
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_pending_bold
LDI_BL 5
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_blink_on
LDI_BL 22
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_pending_normal
LDI_BL 25
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_blink_off
LDI_BL 39
ALUOP_FLAGS %AxB%+%AL%+%BL%
JEQ .sgrcode_reset

LDI_BL 30
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 30
JO .sgrcode_done
LDI_BL 38
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 38
JO .sgrcode_fg_low

LDI_BL 90
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 90
JO .sgrcode_done
LDI_BL 98
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff AL < 98
JO .sgrcode_fg_high

JMP .sgrcode_done                      # anything else: ignored

.sgrcode_reset
LDI_AL 0x3f
CALL .sgr_set_color
JMP .sgrcode_done

.sgrcode_pending_bold
ST .sgr_pending_shade 0x01
JMP .sgrcode_done

.sgrcode_pending_normal
ST .sgr_pending_shade 0x02
JMP .sgrcode_done

.sgrcode_blink_on
LD_AL :t_term_current_color
LDI_BL 0x80
ALUOP_AL %A|B%+%AL%+%BL%
ALUOP_ADDR %A%+%AL% :t_term_current_color
JMP .sgrcode_done

.sgrcode_blink_off
LD_AL :t_term_current_color
LDI_BL 0x7f
ALUOP_AL %A&B%+%AL%+%BL%
ALUOP_ADDR %A%+%AL% :t_term_current_color
JMP .sgrcode_done

.sgrcode_fg_low
LDI_BL 30
ALUOP_AL %A-B%+%AL%+%BL%              # AL = table index 0-7
CALL .sgr_lookup_color
JMP .sgrcode_done

.sgrcode_fg_high
LDI_BL 82
ALUOP_AL %A-B%+%AL%+%BL%              # AL = table index 8-15
CALL .sgr_lookup_color
JMP .sgrcode_done

.sgrcode_done
RET

######
# Upgrades any channel currently at shade-2 to shade-3 in
# :t_term_current_color (SGR 1, bold -- deferred; see .disp_sgr).
# Channels at any other shade are left unchanged.
#
# Clobbers: A, B.
.sgrcode_bold
LD_AL :t_term_current_color
LDI_BL 0x30
ALUOP_BH %A&B%+%AL%+%BL%              # BH = color & 0x30 (red field)
LDI_AH 0x20
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .bold_check_g
LDI_BL 0x10
ALUOP_AL %A|B%+%AL%+%BL%
.bold_check_g
LDI_BL 0x0c
ALUOP_BH %A&B%+%AL%+%BL%              # BH = color & 0x0c (green field)
LDI_AH 0x08
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .bold_check_b
LDI_BL 0x04
ALUOP_AL %A|B%+%AL%+%BL%
.bold_check_b
LDI_BL 0x03
ALUOP_BH %A&B%+%AL%+%BL%              # BH = color & 0x03 (blue field)
LDI_AH 0x02
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .bold_apply
LDI_BL 0x01
ALUOP_AL %A|B%+%AL%+%BL%
.bold_apply
ALUOP_ADDR %A%+%AL% :t_term_current_color
RET

######
# Downgrades any channel currently at shade-3 to shade-2 in
# :t_term_current_color (SGR 22, normal -- deferred; see .disp_sgr).
#
# Clobbers: A, B.
.sgrcode_normal
LD_AL :t_term_current_color
LDI_BL 0x30
ALUOP_BH %A&B%+%AL%+%BL%
LDI_AH 0x30
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .normal_check_g
LDI_BL 0xef
ALUOP_AL %A&B%+%AL%+%BL%
.normal_check_g
LDI_BL 0x0c
ALUOP_BH %A&B%+%AL%+%BL%
LDI_AH 0x0c
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .normal_check_b
LDI_BL 0xfb
ALUOP_AL %A&B%+%AL%+%BL%
.normal_check_b
LDI_BL 0x03
ALUOP_BH %A&B%+%AL%+%BL%
LDI_AH 0x03
ALUOP_FLAGS %AxB%+%AH%+%BH%
JNE .normal_apply
LDI_BL 0xfe
ALUOP_AL %A&B%+%AL%+%BL%
.normal_apply
ALUOP_ADDR %A%+%AL% :t_term_current_color
RET

######
# Looks up :sgr_color_table[AL] (index 0-15) and applies it via
# .sgr_set_color. Shared by plain SGR 30-37/90-97 and the 256-color
# n<16 case (2.2.3.1, which is defined to match the 16-color table).
#
# Inputs:
#  AL - table index 0-15
# Clobbers: A, B, C.
.sgr_lookup_color
LDI_AH 0x00
LDI_B .sgr_color_table
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL
CALL .sgr_set_color
RET

######
# Sets :t_term_current_color to AL and turns on color rendering.
#
# Inputs:
#  AL - color byte
.sgr_set_color
ALUOP_ADDR %A%+%AL% :t_term_current_color
ST :t_term_render_color 0x01
RET

######
# Applies the SGR 38;5;n / 48;5;n 256-color quantization (2.2.3.1). The
# background form (48) is parsed but produces no color change,
# consistent with every other background SGR code.
#
# Inputs:
#  AL - palette index n (0-255)
#  BL - 38 (foreground) or 48 (background)
# Clobbers: A, B, C. Preserves D (.sgr_cube_to_color saves/restores it).
.sgr_apply_256color
ALUOP_PUSH %A%+%AL%                   # save n
LDI_AH 38
ALUOP_FLAGS %AxB%+%AH%+%BL%
POP_AL                                 # restore n regardless of branch
JNE .apply256_done                    # 48 (background): parsed, ignored

LDI_BL 16
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff n < 16
JO .apply256_low16

LDI_BL 232
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff n < 232
JO .apply256_cube

LDI_BL 232
ALUOP_AL %A-B%+%AL%+%BL%              # AL = g = n - 232
CALL .sgr_gray_to_color
JMP .apply256_done

.apply256_low16
CALL .sgr_lookup_color
JMP .apply256_done

.apply256_cube
LDI_BL 16
ALUOP_AL %A-B%+%AL%+%BL%              # AL = idx = n - 16
CALL .sgr_cube_to_color
JMP .apply256_done

.apply256_done
RET

######
# Decomposes a 6x6x6 color-cube index into an Odyssey color byte via
# the shade-quantization table (2.2.3.1: xterm levels 0-5 -> shades
# 0,1,1,2,2,3) and applies it via .sgr_set_color.
#
# Inputs:
#  AL - cube index (0-215, i.e. n-16 for SGR 38;5;n)
# Clobbers: A, B, C. Preserves D.
.sgr_cube_to_color
PUSH_DH
PUSH_DL

LDI_BH 0x00                           # r = 0
.cube_r_loop
LDI_BL 36
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff idx < 36
JO .cube_r_done
ALUOP_AL %A-B%+%AL%+%BL%
ALUOP_BH %B+1%+%BH%
JMP .cube_r_loop
.cube_r_done
ALUOP_DH %B%+%BH%                     # DH = r

LDI_BH 0x00                           # g = 0
.cube_g_loop
LDI_BL 6
ALUOP_FLAGS %A-B%+%AL%+%BL%           # O iff idx < 6
JO .cube_g_done
ALUOP_AL %A-B%+%AL%+%BL%
ALUOP_BH %B+1%+%BH%
JMP .cube_g_loop
.cube_g_done
ALUOP_DL %B%+%BH%                     # DL = g; AL is now b (0-5)

LDI_AH 0x00
LDI_B .sgr_cube_shade
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL                              # AL = shade_b
ALUOP_PUSH %A%+%AL%                   # push shade_b

MOV_DL_AL                             # AL = g
LDI_AH 0x00
LDI_B .sgr_cube_shade
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL                              # AL = shade_g
ALUOP_PUSH %A%+%AL%                   # push shade_g

MOV_DH_AL                             # AL = r
LDI_AH 0x00
LDI_B .sgr_cube_shade
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL                              # AL = shade_r

ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%                  # AL = shade_r << 4
POP_BL                                 # BL = shade_g
ALUOP_BL %B<<1%+%BL%
ALUOP_BL %B<<1%+%BL%                  # BL = shade_g << 2
ALUOP_AL %A|B%+%AL%+%BL%              # AL |= shade_g<<2
POP_BL                                 # BL = shade_b
ALUOP_AL %A|B%+%AL%+%BL%              # AL |= shade_b

CALL .sgr_set_color

POP_DL
POP_DH
RET

######
# Applies the 24-step grayscale ramp (2.2.3.1: shade = round(g*3/23))
# via a precomputed table, then applies it via .sgr_set_color.
#
# Inputs:
#  AL - gray step (0-23, i.e. n-232 for SGR 38;5;n)
# Clobbers: A, B, C.
.sgr_gray_to_color
LDI_AH 0x00
LDI_B .sgr_gray_table
ALUOP16O_A %ALU16_A+B%
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%
LDA_C_AL                              # AL = shade s (0-3)
ALUOP_BL %A%+%AL%                     # BL = s
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%                  # AL = s<<2
ALUOP_BH %A%+%AL%                     # BH = s<<2
ALUOP_AL %A<<1%+%AL%
ALUOP_AL %A<<1%+%AL%                  # AL = s<<4
ALUOP_AL %A|B%+%AL%+%BH%              # AL |= s<<2
ALUOP_AL %A|B%+%AL%+%BL%              # AL |= s
CALL .sgr_set_color
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
.ansi_discard "\0"
.sgr_index "\0"
.sgr_pending_shade "\0"
.sgr_color_table 0x00 0x20 0x08 0x28 0x02 0x22 0x0a 0x2a 0x15 0x30 0x0c 0x3c 0x03 0x33 0x0f 0x3f
.sgr_cube_shade 0x00 0x01 0x01 0x02 0x02 0x03
.sgr_gray_table 0x00 0x00 0x00 0x00 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x02 0x02 0x02 0x02 0x02 0x02 0x02 0x02 0x03 0x03 0x03 0x03
