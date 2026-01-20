# vim: syntax=asm-mycpu

VAR global byte $timer_flag

# Test #1: MEMFILL
CALL .start_1sec_timer
LDI_AH 0x00                 # character we are filling
LDI_B 0x0000                # we will store frame count in B
.memfill_loop
LDI_C %display_chars%
ALUOP_AH %A+1%+%AH%
LDI_AL 29                   # 30 128 byte segments  -> 60 lines
CALL :memfill_segments
LD_AL $timer_flag           # check if timer expired during this fill
ALUOP_FLAGS %A%+%AL%
JNZ .memfill_loop_done      # If so, don't count this as a completed frame and exit the loop
ALUOP16O_B %ALU16_B+1%
JMP .memfill_loop

.memfill_loop_done
LDI_AH 0x00         # char to fill
LDI_AL %white%      # color to fille
CALL :clear_screen
CALL :cursor_init
CALL :cursor_display_sync   # reset cursor to 0,0
CALL :heap_push_B           # save result on heap

# Test #2: MEMCPY4_C_D
LDI_AL 1
CALL :malloc_blocks         # Get a 16-byte memory array, address is in A
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%           # copy address to D
LDI_AL 0x0f                 # loop counter for 16 extended memory addresses
.extmalloc_loop
CALL :extmalloc             # page ID is on heap
CALL :heap_pop_BL
ALUOP_ADDR_D %B%+%BL%       # store page ID in malloc'd memory
ALUOP_AL %A-1%+%AL%         # decrement counter
JO .extmalloc_done          # if overflow, we've allocated 16 pages
INCR_D                      # otherwise, move to next D address
JMP .extmalloc_loop         # and move to next one

.extmalloc_done
LDA_D_BL                    # Get 16th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_black%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 15th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_red%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 14th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_green%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 13th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_yellow%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 12th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_blue%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 11th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_magenta%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 10th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_cyan%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 9th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_gray%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 8th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_red%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 7th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_green%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 6th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_yellow%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 5th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_blue%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 4th ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_magenta%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 3rd ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_cyan%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 2nd ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_br_white%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte
DECR_D

LDA_D_BL                    # Get 1st ext page ID into BL
CALL :heap_push_BL
CALL :extpage_d_push        # switch to that page at D window
LDI_AH %ansi_black%
LDI_AL 29                   # 30 128-byte segments = 60 rows
LDI_C 0xd000
CALL :memfill_segments
CALL :extpage_d_pop
CALL :heap_pop_byte

LDI_AH '#'                  # fill character
LDI_AL 0x00                 # color
CALL :clear_screen

CALL .start_1sec_timer
LDI_BL 0x0f                 # D offset tracker
LDI_BH 0x00                 # up/down tracking up=0, down=1
LDI_AH 0x00                 # frame counter

.memcpy_loop
LDA_D_AL                    # ext page
CALL :heap_push_AL
CALL :extpage_d_push        # set page D
PUSH_DH
PUSH_DL
LDI_C 0xd000
LDI_D %display_color%
LDI_AL 29                   # 30 128-byte segments = 60 rows
CALL :memcpy_segments
POP_DL
POP_DH
CALL :extpage_d_pop
CALL :heap_pop_byte
ALUOP_AH %A+1%+%AH%         # increment frame counter
ALUOP_FLAGS %B%+%BH%
JZ .memcpy_upcount

.memcpy_downcount
DECR_D
ALUOP_BL %B-1%+%BL%
JNO .memcpy_count_done
INCR_D
LDI_BL 0x0f
LDI_BH 0x00
JMP .memcpy_count_done

.memcpy_upcount
INCR_D
ALUOP_BL %B-1%+%BL%
JNO .memcpy_count_done
DECR_D
LDI_BL 0x0f
LDI_BH 0x01
JMP .memcpy_count_done

.memcpy_count_done
LD_AL $timer_flag           # check if timer expired during this frame
ALUOP_FLAGS %A%+%AL%
JZ .memcpy_loop

.memcpy_loop_done
LDI_AH 0x00         # char to fill
LDI_AL %white%      # color to fill
CALL :clear_screen
CALL :cursor_init
CALL :cursor_display_sync   # reset cursor to 0,0
ALUOP_AL %A%+%AH%           # move frame counter to AL
LDI_AH 0x00                 # reset upper byte
CALL :heap_push_A           # save frame count on heap

MOV_DH_AH
MOV_DL_AL
CALL :free                  # free the 16-byte region


# Test #3: Procedural generation
LDI_AH '@'                  # fill character
LDI_AL 0x00                 # color
LDI_C 0xffff                # frame counter
CALL :clear_screen

CALL .start_1sec_timer
LDI_BL 0xff                 # start color counter
.procedural_loop
INCR_C                      # increment frame counter
ALUOP_BL %B+1%+%BL%         # increment start color on each loop
LDI_A %display_color%       # initialize address counter
.procedural_frame_loop
ALUOP_ADDR_A %B%+%BL%       # write color to this location
ALUOP_BL %B-1%+%BL%         # decrement color counter
JNO .next_char
LDI_BL 0x3f                 # reset back to white if we overflow
.next_char
ALUOP16O_A %ALU16_A+1%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %A%+%AH%
LDI_B 0x5eff
CALL :sub16_b_minus_a       # result in B; if A has moved past writable area, BH will have overflowed
LDI_AH 0xff
ALUOP_FLAGS %A&B%+%AH%+%BH%
POP_AH
POP_BL
JEQ .procedural_loop
LD_BH $timer_flag           # check if timer expired during this frame
ALUOP_FLAGS %B%+%BH%
JZ .procedural_frame_loop
CALL :heap_push_C           # store frame count if timer expired

LDI_AH 0x00         # char to fill
LDI_AL %white%      # color to fill
CALL :clear_screen
CALL :cursor_init
CALL :cursor_display_sync   # reset cursor to 0,0

LDI_C .procedural_str
CALL :printf                # will pop result off heap
LDI_C .memcpy_str
CALL :printf                # will pop result off heap
LDI_C .memfill_str
CALL :printf                # will pop result off heap

RET

.procedural_str "PROCEDURAL: %U frames per second\n\0"
.memcpy_str     "MEMCPY:     %U frames per second\n\0"
.memfill_str    "MEMFILL:    %U frames per second\n\0"

.timeout
ST $timer_flag 0x01
CALL :timer_set_idle
ST16    %IRQ3addr%  :timer_clear_irq
RETI

.start_1sec_timer
MASKINT
ST16    %IRQ3addr%  .timeout
ST $timer_flag 0x00
LDI_AL 0x01     # seconds
CALL :heap_push_AL
LDI_AL 0x00     # subseconds
CALL :heap_push_AL
CALL :timer_set_watchdog
UMASKINT
RET
