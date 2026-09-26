# vim: syntax=asm-mycpu

#####
# music_player - background .MUS playback through the piezo speaker
#
# Split library (not BIOS-resident): symlink this file and
# music_player.h into any ODY build directory that needs it, e.g. from
# os/util/<name>/:
#   ln -s ../../lib/music_player.asm music_player.asm
#   ln -s ../../lib/music_player.h music_player.h
#
# Song data is a sequence of 16-byte note records (see
# music/mkmus/mus_writer.py):
#   offset 0x00  divisor   (16-bit, big-endian; 0x0000 = silence)
#   offset 0x02  duration  (16-bit, big-endian; 32.768kHz ticks)
#   offset 0x04  comment   (12 bytes, null-terminated)
# A record with divisor==0x0000 AND duration==0x0000 ends the song.
#
# Timer 1 (82C54) generates the tone at 1.8432MHz (mode 3, square
# wave, routed to the speaker via the tone-select mux). Timer 2 times
# each note at 32.768kHz (mode 0, one-shot, reloaded on every firing).
# The Timer 2 handler (.mp_next_note) steps through the song entirely
# in the background; the caller keeps running.
#
# Caller obligations:
#  - Keep the song data valid and mapped (e.g. an extended memory page
#    selected into the E window) until :music_stop has been called.
#  - Call :music_stop before exiting the program. It restores the
#    Timer 2 handler, the clock-select byte, and idles timers 1 and 2.
#  - Timer 3's clock-select bits and IRQ latch are left untouched, so
#    Timer 3 remains free for the caller (e.g. a game tick).
#
# All state is file-local label data, so it is compiled into the
# consuming ODY (no VAR pool use).
#
# Sound effects are just short songs (millisecond steps, authored with
# music/mkmus/mksfx.py; see music/README.md). Play one with loop=0 and
# status=0x0000 (skips the per-note comment copy); it replaces anything
# already playing. Each note costs one Timer 2 interrupt, so keep steps
# at 3ms or longer.
#####

####
# music_play - start background playback of in-memory song data
#
# C: void music_play(void *song, uint8_t loop, uint8_t *loop_count,
#                    struct music_status *status);
#
# To use (C calling convention: arguments pushed in reverse order):
#  1. Push the status pointer word (struct music_status *, or 0x0000)
#  2. Push the loop_count pointer word (uint8_t *, or 0x0000)
#  3. Push the loop flag byte (0x00 = play once, nonzero = loop forever)
#  4. Push the song data address word
#  5. Call the function (nothing is returned)
#
# *loop_count (if non-null) is zeroed, then incremented by the handler
# every time the end of the song is reached, saturating at 255. In
# one-shot mode the timers go silent when it becomes 1.
#
# *status (if non-null) is a 13-byte struct music_status: byte 0 is a
# new_note flag the handler sets to 0x01 on each note (the caller
# clears it), bytes 1-12 receive the current note's comment.
#
# Calling this while already playing restarts cleanly (it runs
# :music_stop first). An empty song (first record is the terminator)
# sets *loop_count to 1 and starts nothing.
# Side effects: none (all registers preserved)
:music_play
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :music_stop                # restart safety; no-op when idle

CALL :heap_pop_C                # C = song data address
ST_CH .mp_start
ST_CL .mp_start+1
ST_CH .mp_ptr
ST_CL .mp_ptr+1

CALL :heap_pop_AL               # AL = loop flag
ALUOP_ADDR %A%+%AL% .mp_loop

CALL :heap_pop_D                # D = loop_count pointer (may be null)
ST_DH .mp_count_ptr
ST_DL .mp_count_ptr+1
MOV_DH_AH
MOV_DL_BL
ALUOP_FLAGS %A|B%+%AH%+%BL%
JZ .mp_play_no_count
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%           # *loop_count = 0
.mp_play_no_count

CALL :heap_pop_D                # D = status pointer (may be null)
ST_DH .mp_status_ptr
ST_DL .mp_status_ptr+1
MOV_DH_AH
MOV_DL_BL
ALUOP_FLAGS %A|B%+%AH%+%BL%
JZ .mp_play_no_status
LDI_AL 0x00
ALUOP_ADDR_D %A%+%AL%           # status->new_note = 0
.mp_play_no_status

# Empty song? (first record is the all-zero terminator). Checked here
# so the handler's loop-restart path can never spin on a terminator.
LDA_C_AH                        # C still = song start
INCR_C
LDA_C_AL
INCR_C
LDA_C_BH
INCR_C
LDA_C_BL
ALUOP_FLAGS %A|B%+%AH%+%BH%
JNZ .mp_play_start
ALUOP_FLAGS %A|B%+%AL%+%BL%
JNZ .mp_play_start

LD_DH .mp_count_ptr             # empty: report "one pass done" and bail
LD_DL .mp_count_ptr+1
MOV_DH_AH
MOV_DL_BL
ALUOP_FLAGS %A|B%+%AH%+%BL%
JZ .mp_play_done
LDI_AL 0x01
ALUOP_ADDR_D %A%+%AL%
JMP .mp_play_done

.mp_play_start
MASKINT

# Save the caller's clock-select byte and Timer 2 handler for :music_stop
LD_AL $ptmr_clk_select
ALUOP_ADDR %A%+%AL% .mp_saved_clk
LD_CH $ptmr_t2_handler
LD_CL $ptmr_t2_handler+1
ST_CH .mp_saved_t2
ST_CL .mp_saved_t2+1

# New clock select: keep Timer 3's clock bits, take over T1/T2 + tone
LDI_BL 0b00110000
ALUOP_AL %A&B%+%AL%+%BL%
LDI_BL %ptmr_clk_tmr1_18M%|%ptmr_clk_tmr2_32k%|%ptmr_tone_t1%
ALUOP_AL %A|B%+%AL%+%BL%
ALUOP_ADDR %A%+%AL% %ptmr_clk_sel%
ALUOP_ADDR %A%+%AL% $ptmr_clk_select

ST %ptmr_ctrl_write% %ptmr_cw_t1_mode3%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%

ST16 $ptmr_t2_handler .mp_next_note     # hook the beat timer's IRQ2 dispatch
ST .mp_active 0x01

CALL .mp_next_note                      # load & start the first note

ST %ptmr_base%+%ptmr_clr_t1%+%ptmr_clr_t2% 0x00   # clear stale T1/T2 latches
UMASKINT

.mp_play_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# music_stop - stop playback and restore the timer state
#
# C: void music_stop();
#
# To use: just call it (no arguments, nothing returned).
#
# Restores the Timer 2 handler and clock-select byte saved by
# :music_play, idles timers 1 and 2 (silent, no further IRQs) and
# clears their IRQ latches. Safe to call at any time: mid-song, after
# a one-shot song has ended, repeatedly, or without :music_play ever
# having been called (then it does nothing). Makes no heap calls.
# Side effects: none (all registers preserved)
:music_stop
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

MASKINT
LD_AL .mp_active
ALUOP_FLAGS %A%+%AL%
JZ .mp_stop_done

LD_CH .mp_saved_t2                      # restore the caller's T2 handler
LD_CL .mp_saved_t2+1
ST_CH $ptmr_t2_handler
ST_CL $ptmr_t2_handler+1

ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0% # idle both timers, no counts -> silent
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%
ST %ptmr_base%+%ptmr_clr_t1%+%ptmr_clr_t2% 0x00

LD_AL .mp_saved_clk                     # restore the caller's clk/tone byte
ALUOP_ADDR %A%+%AL% %ptmr_clk_sel%
ALUOP_ADDR %A%+%AL% $ptmr_clk_select

ST .mp_active 0x00

.mp_stop_done
UMASKINT
POP_CL
POP_CH
POP_AL
RET

# ====================================================================
# mp_next_note - Timer 2 handler: read one note record and act on it
#
# Installed directly into $ptmr_t2_handler and dispatched by
# :ptmr_isr_std via CALL_D, so it must preserve every register it
# touches (including AL, which the dispatcher parks its latch-walk
# state in), end with RET (not RETI), and never call heap functions.
#
# Reads the record at .mp_ptr and advances .mp_ptr past it:
#  - note: arms timer1 (tone, or silence if divisor==0) and timer2
#    (duration); copies the comment to status->comment and sets
#    status->new_note if a status pointer was given.
#  - terminator: bumps *loop_count (saturating at 255, if non-null);
#    then either rewinds to the song start (loop mode) or idles both
#    timers (one-shot mode; :music_stop still does the restore).
# ====================================================================
.mp_next_note
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

.mp_nn_read
LD_CH .mp_ptr
LD_CL .mp_ptr+1

LDA_C_AH                        # divisor high byte
INCR_C
LDA_C_AL                        # divisor low byte
INCR_C
LDA_C_BH                        # duration high byte
INCR_C
LDA_C_BL                        # duration low byte
INCR_C
# C now points at the 12-byte comment field

ALUOP_FLAGS %A|B%+%AH%+%BH%
JNZ .mp_nn_note
ALUOP_FLAGS %A|B%+%AL%+%BL%
JNZ .mp_nn_note

# --- End of song ---
LD_DH .mp_count_ptr
LD_DL .mp_count_ptr+1
MOV_DH_AH
MOV_DL_BL
ALUOP_FLAGS %A|B%+%AH%+%BL%
JZ .mp_nn_counted               # no counter supplied
LDA_D_AL
ALUOP_AL %A+1%+%AL%
JO .mp_nn_counted               # already 255: saturate, don't wrap to 0
ALUOP_ADDR_D %A%+%AL%
.mp_nn_counted

LD_AL .mp_loop
ALUOP_FLAGS %A%+%AL%
JZ .mp_nn_oneshot

LD_CH .mp_start                 # loop: rewind and play the first record
LD_CL .mp_start+1               # (never a terminator; :music_play checks)
ST_CH .mp_ptr
ST_CL .mp_ptr+1
JMP .mp_nn_read

.mp_nn_oneshot
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0% # idle both timers -> silent, no IRQs
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%
JMP .mp_nn_done

# --- Normal note ---
.mp_nn_note
ALUOP_FLAGS %A%+%AH%            # divisor==0 means silence (both bytes are on
JNZ .mp_nn_tone                 # the A side, so they can't be ORed together)
ALUOP_FLAGS %A%+%AL%
JNZ .mp_nn_tone

# Silence: rewrite timer1's control word, but don't write a count
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode3%
JMP .mp_nn_duration

.mp_nn_tone
ALUOP_ADDR %A%+%AL% %ptmr_counter1%     # LSB first
ALUOP_ADDR %A%+%AH% %ptmr_counter1%     # MSB second: (re)activates the tone

.mp_nn_duration
ALUOP_ADDR %B%+%BL% %ptmr_counter2%     # LSB first
ALUOP_ADDR %B%+%BH% %ptmr_counter2%     # MSB second: resets the beat timer

LD_DH .mp_status_ptr
LD_DL .mp_status_ptr+1
MOV_DH_AH
MOV_DL_BL
ALUOP_FLAGS %A|B%+%AH%+%BL%
JZ .mp_nn_skip_comment

# Copy the comment into status->comment (offset 1); :memcpy advances C
# past the 12 bytes, landing exactly on the next note record.
INCR_D
LDI_AL 11                       # 12 bytes
CALL :memcpy
LD_DH .mp_status_ptr
LD_DL .mp_status_ptr+1
LDI_AL 0x01
ALUOP_ADDR_D %A%+%AL%           # status->new_note = 1
ST_CH .mp_ptr
ST_CL .mp_ptr+1
JMP .mp_nn_done

.mp_nn_skip_comment
MOV_CH_AH                       # .mp_ptr = C + 12 (skip the comment)
MOV_CL_AL
LDI_B 0x000c
ALUOP16O_B %ALU16_A+B%
ALUOP_ADDR %B%+%BH% .mp_ptr
ALUOP_ADDR %B%+%BL% .mp_ptr+1

.mp_nn_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

# ====================================================================
# State (file-local, compiled into the consuming ODY)
# ====================================================================
.mp_start "\0\0"                # song base address (loop rewind target)
.mp_ptr "\0\0"                  # next record to play
.mp_count_ptr "\0\0"            # uint8_t *loop_count, or 0x0000
.mp_status_ptr "\0\0"           # struct music_status *, or 0x0000
.mp_saved_t2 "\0\0"             # caller's $ptmr_t2_handler
.mp_loop "\0"                   # nonzero = loop forever
.mp_saved_clk "\0"              # caller's $ptmr_clk_select
.mp_active "\0"                 # 1 = timers/handler owned by us
