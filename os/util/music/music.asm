# vim: syntax=asm-mycpu
# music - play a song file through the piezo speaker
#
# Usage: music <filename>
#
# Loads up to the first 8 sectors (4096 bytes) of <filename> into a
# freshly allocated extended memory page (E window, 0xE000) and plays
# it once with the background player in music_player.asm (symlinked
# from os/lib/), printing each note's comment verbatim as it starts
# (mkmus.py bakes the spaces/newlines into the comments, so lyrics run
# on one line per bar).
#
# Song files are built from source in music/ at the repo root; see
# music/README.md.

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

# --- Start background playback (C order: args pushed in reverse) ---
LDI_A .status_buf
CALL :heap_push_A               # status: new_note flag + comment
LDI_A .loop_count
CALL :heap_push_A               # loop_count
LDI_AL 0x00
CALL :heap_push_AL              # loop = false: play once
LDI_A 0xe000
CALL :heap_push_A               # song data
CALL :music_play

# --- Wait loop: print comments until the first pass completes ---
.wait_loop
LD_AL .loop_count
ALUOP_FLAGS %A%+%AL%
JNZ .song_done

LD_AL .status_buf               # new_note flag
ALUOP_FLAGS %A%+%AL%
JZ .wait_loop
ST .status_buf 0x00

LD_AL .status_buf+1             # empty comment, nothing to print
ALUOP_FLAGS %A%+%AL%
JZ .wait_loop
LDI_C .status_buf+1
CALL :print
JMP .wait_loop

.song_done
CALL :music_stop

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
# Static data
# ====================================================================
.usage_str "Usage: music <filename>\n\0"
.err_ata_str "music: ATA error while locating file\n\0"
.err_notfound_str "music: file not found\n\0"
.err_extmem_str "music: extended memory full\n\0"
.err_read_str "music: ATA error while reading file\n\0"
.goodbye_str "music: done playing.\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

# struct music_status: new_note flag byte + 12-byte comment
.status_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0"
.loop_count "\0"

# fat16_readfile streaming state (12 bytes, must start zeroed so the
# first call takes the init-stream path instead of resume)
.music_state "\0\0\0\0\0\0\0\0\0\0\0\0"
