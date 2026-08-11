# vim: syntax=asm-mycpu
# music - play a song file through the piezo speaker
#
# Usage: music <filename>
#
# Loads up to the first 8 sectors (4096 bytes) of <filename> into a
# freshly allocated extended memory page (E window, 0xE000) and plays
# it as a sequence of 16-byte note records:
#   offset 0x00  divisor   (16-bit, big-endian; 0x0000 = silence)
#   offset 0x02  duration  (16-bit, big-endian; 32.768kHz ticks)
#   offset 0x04  comment   (12 bytes, null-terminated)
# A record with divisor==0x0000 AND duration==0x0000 marks the end
# of the song.
#
# Timer 1 (82C54) generates the tone at 1.8432MHz (mode 3, square
# wave, routed to the speaker via the tone-select mux). Timer 2
# generates the beat/duration at 32.768kHz (mode 0, one-shot,
# reloaded every time it fires). The timer2 handler (.play_next_note,
# installed as $ptmr_t2_handler) reads the next note record on every
# firing and reports back to the main loop through $music_status:
#   0x00 = idle (consumed)
#   0x01 = new note loaded, $music_comment valid
#   0x02 = end of song reached

:main
CALL :argv_init                 # AL=argc, C=argv base; clobbers A and C
LDI_D .argv_buf
LDI_AL 3                        # 4 blocks = 64 bytes
CALL :memcpy_blocks

LD_AH .argv_buf+2               # argv[1] pointer hi byte
ALUOP_FLAGS %A%+%AH%
JZ .usage                       # null hi byte => argument absent

LD_CH .argv_buf+2               # C = argv[1] string (filename)
LD_CL .argv_buf+3

# --- Locate the file ---
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # A = dirent ptr, or 0x00xx/0x01xx on error

LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%     # E=1 if AH==0x01 (ATA error)
JEQ .err_pathfind_ata
ALUOP_FLAGS %A%+%AH%            # Z=1 if AH==0x00 (not found / syntax error)
JZ .err_notfound

CALL :heap_pop_C                # C = fsh_ptr
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                # D = dirent_ptr (A left unchanged)

# --- Allocate an extended memory page and select it into the E window ---
CALL :extmalloc
CALL :heap_pop_AL               # AL = allocated page, or 0x00 if full
ALUOP_FLAGS %A%+%AL%
JZ .err_extmem_full
CALL :heap_push_AL
CALL :extpage_e_push            # 0xE000 window now mapped to our page

# --- Read up to the first 8 sectors of the file into 0xE000 ---
MOV_CH_AH
MOV_CL_AL
CALL :heap_push_A               # filesystem handle
LDI_C 0xe000
CALL :heap_push_C               # destination address
LDI_A 0x0008
CALL :heap_push_A               # n_sectors = 8 (clamped to file size)
CALL :heap_push_D               # directory entry
LDI_A .music_state
CALL :heap_push_A               # streaming state (zeroed, forces init mode)
CALL :fat16_readfile
CALL :heap_pop_AL               # status: 0x00 = success
ALUOP_FLAGS %A%+%AL%
JNZ .err_read_ata

# Done with the directory entry now that the file is loaded
MOV_DH_AH
MOV_DL_AL
CALL :free                      # free the 32-byte dirent

# --- Timer setup: mode select only, no counts written yet ---
MASKINT

LD_AL $ptmr_clk_select
ALUOP_ADDR %A%+%AL% .music_saved_clk    # remember pre-execution clk/tone byte

ST %ptmr_clk_sel%   %ptmr_clk_tmr1_18M%|%ptmr_clk_tmr2_32k%|%ptmr_tone_t1%
ST $ptmr_clk_select %ptmr_clk_tmr1_18M%|%ptmr_clk_tmr2_32k%|%ptmr_tone_t1%

ST %ptmr_ctrl_write% %ptmr_cw_t1_mode3%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%

ST16 $ptmr_t2_handler .play_next_note   # hook the beat timer's IRQ2 dispatch

CALL .play_next_note                    # load & start the first note

ST %ptmr_clr_all_irq% 0x00              # clear any stale latches from setup
UMASKINT

# --- Wait loop: watch $music_status for the ISR's handoff ---
.wait_loop
LD_AL .music_status
ALUOP_FLAGS %A%+%AL%
JZ .wait_loop

MASKINT
LD_AL .music_status
ST .music_status 0x00
UMASKINT

LDI_BL 0x02
ALUOP_FLAGS %A-B%+%AL%+%BL%     # E=1 if status == end-of-song sentinel
JEQ .song_done

# New note: print the comment (if set) followed by a newline
LDI_C .music_comment
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .wait_loop                   # empty comment, nothing to print
LDI_C .music_comment
CALL :print
LDI_C .newline_str
CALL :print
JMP .wait_loop

.song_done
MASKINT
ST16 $ptmr_t2_handler :ptmr_noop_handler

ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0% # idle both timers, no counts -> silent
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%
ST %ptmr_clr_all_irq% 0x00

LD_AL .music_saved_clk                  # restore pre-execution clk/tone byte
ALUOP_ADDR %A%+%AL% %ptmr_clk_sel%
ALUOP_ADDR %A%+%AL% $ptmr_clk_select
UMASKINT

CALL :extpage_e_pop                     # release the extended memory page
CALL :extfree

LDI_C .goodbye_str
CALL :print
JMP .program_exit

# --- Error paths ---
.err_read_ata
MOV_DH_AH
MOV_DL_AL
CALL :free
CALL :extpage_e_pop
CALL :extfree
LDI_C .err_read_str
CALL :print
JMP .program_error

.err_extmem_full
MOV_DH_AH
MOV_DL_AL
CALL :free
LDI_C .err_extmem_str
CALL :print
JMP .program_error

.err_pathfind_ata
LDI_C .err_ata_str
CALL :print
JMP .program_error

.err_notfound
LDI_C .err_notfound_str
CALL :print
JMP .program_error

.usage
LDI_C .usage_str
CALL :print
JMP .program_error

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.program_error
LDI_A 0x0001
CALL :heap_push_A
RET

# ====================================================================
# play_next_note - read one 16-byte note record and act on it
#
# Doubles as the raw IRQ2 (timer2) handler: installed directly into
# $ptmr_t2_handler, so it must preserve every register it touches
# (including AL, which the dispatcher parks its latch-walk state in)
# and end with RET, not RETI.
#
# On call: reads the record at .music_ptr, advances .music_ptr past
# it, arms timer1 (tone) and timer2 (duration) for the note (or
# silences timer1 if divisor==0), copies the comment to
# .music_comment, and sets .music_status. If both divisor and
# duration are zero, sets .music_status to the end-of-song sentinel
# and leaves the timers alone (the main loop stops them).
# ====================================================================
.play_next_note
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

LD_CH .music_ptr
LD_CL .music_ptr+1

LDA_C_AH                        # divisor high byte
INCR_C
LDA_C_AL                        # divisor low byte
INCR_C
LDA_C_BH                        # duration high byte
INCR_C
LDA_C_BL                        # duration low byte
INCR_C
# C now points at the 12-byte comment field

ALUOP_FLAGS %A%+%AH%
JNZ .pnn_not_end
ALUOP_FLAGS %A%+%AL%
JNZ .pnn_not_end
ALUOP_FLAGS %B%+%BH%
JNZ .pnn_not_end
ALUOP_FLAGS %B%+%BL%
JNZ .pnn_not_end

# End of song: leave the timers running as-is, just signal the main loop
ST .music_status 0x02
JMP .pnn_done

.pnn_not_end
ALUOP_FLAGS %A%+%AH%
JNZ .pnn_tone
ALUOP_FLAGS %A%+%AL%
JNZ .pnn_tone

# Silence: rewrite timer1's control word, but don't write a count
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode3%
JMP .pnn_duration

.pnn_tone
ALUOP_ADDR %A%+%AL% %ptmr_counter1%     # LSB first
ALUOP_ADDR %A%+%AH% %ptmr_counter1%     # MSB second: (re)activates the tone

.pnn_duration
ALUOP_ADDR %B%+%BL% %ptmr_counter2%     # LSB first
ALUOP_ADDR %B%+%BH% %ptmr_counter2%     # MSB second: resets the beat timer

# Copy the comment; C (src) already points at it. memcpy advances C
# past the 12 bytes, landing exactly on the next note record.
LDI_D .music_comment
LDI_AL 11                       # 12 bytes
CALL :memcpy

ST_CH .music_ptr
ST_CL .music_ptr+1

ST .music_status 0x01

.pnn_done
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
# Static data
# ====================================================================
.usage_str "Usage: music <filename>\n\0"
.err_ata_str "music: ATA error while locating file\n\0"
.err_notfound_str "music: file not found\n\0"
.err_extmem_str "music: extended memory full\n\0"
.err_read_str "music: ATA error while reading file\n\0"
.goodbye_str "music: done playing.\n\0"
.newline_str "\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

# Walking read pointer into the E window; fixed at 0xE000 (the window
# base never moves, only the physical page mapped behind it does).
.music_ptr 0xe0 0x00

.music_status "\0"
.music_saved_clk "\0"
.music_comment "\0\0\0\0\0\0\0\0\0\0\0\0"

# fat16_readfile streaming state (12 bytes, must start zeroed so the
# first call takes the init-stream path instead of resume)
.music_state "\0\0\0\0\0\0\0\0\0\0\0\0"
