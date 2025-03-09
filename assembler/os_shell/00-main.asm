# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  :uart_clear_usr_msr
ST16    %IRQ5addr%  :uart_clear_dr
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Initialize the heap - this is needed for most commands to work (including :print)
CALL :heap_init

# Initialize color system, we start without processing color data
ST $term_color_enabled 0x00
ST $term_render_color 0x00      # once $term_color_enabled comes on, start out in reset mode
ST $term_print_raw 0x00         # interpret control chars as cursor movement
ST $term_current_color %white%  # ensure color byte has a sane starting value
ST $term_hexbyte_buf 0x00       # fill the hexbyte buf with NULLs
ST $term_hexbyte_buf+1 0x00
ST $term_hexbyte_buf+2 0x00
ST $term_hexbyte_buf+3 0x00
ST $term_hexbyte_buf+4 0x00

# Clear the screen
LDI_AH  0x00
LDI_AL  %white%
CALL :clear_screen

# Initialize the cursor so we can start printing to the screen
CALL :cursor_init
CALL :cursor_display_sync

# Print our OS intro banner and newline
LDI_C .hello_banner
CALL :print

# Print blank line
LDI_AL '\n'
CALL :putchar

# Initialize malloc space 0x6000 .. 0xafff
LDI_A 0x6000
LDI_BL 159   # 160 segments = 20KiB
CALL :malloc_init
LDI_C .malloc_init_banner
LDI_A 0xb000-0x6000
CALL :heap_push_A
LDI_A 0xafff
CALL :heap_push_AL
CALL :heap_push_AH
LDI_A 0x6000
CALL :heap_push_AL
CALL :heap_push_AH
CALL :printf

# Initialize extended memory allocation
CALL :extmalloc_init

# Test extended RAM
CALL :cursor_off
LDI_BH 0x00                             # BH = page number
.extram_loop
ALUOP_ADDR %B%+%BH% %d_page%            # set D page address
ALUOP_ADDR %B%+%BH% 0xd000
ALUOP_ADDR %B%+%BH% 0xdfff
ALUOP_ADDR %B%+%BH% %e_page%            # set E page address
LD_AL 0xe000                            # read E page address
ALUOP_FLAGS %A&B%+%AL%+%BH%             # check if read == write
JNE .extram_error
LD_AL 0xefff
ALUOP_FLAGS %A&B%+%AL%+%BH%             # check if read == write
JNE .extram_error

# move cursor back to beginning of line
LD_AH $crsr_row
LD_AL 0
CALL :cursor_goto_rowcol

# KB tested = (page address + 1) * 4
ALUOP_AL %B%+%BH%
LDI_AH 0x00
CALL :incr16_a
CALL :shift16_a_left
CALL :shift16_a_left

CALL :heap_push_A                       # push KB amount
LDI_C .memtest_str
CALL :printf                            # print the KB tested

ALUOP_BH %B+1%+%BH%                     # increment page
JNO .extram_loop
LDI_AL '\n'
CALL :putchar
CALL :cursor_on
JMP .ata_init

.extram_error
CALL :cursor_on
LDI_C .memtest_error_str
CALL :print
HLT

# ATA init
.ata_init
LDI_BL 0                                # primary master
CALL :heap_push_BL
CALL :ata_identify_string               # ID string is on top of heap
CALL :heap_pop_A                        # save string address so we can free it
CALL :heap_push_A
LDI_BL 0                                # primary master
CALL :heap_push_BL
LDI_C .ata_banner
CALL :printf
LDI_BL 3                                # free 64 bytes, A still contains addr
CALL :free

LDI_BL 1                                # primary slave
CALL :heap_push_BL
CALL :ata_identify_string               # ID string is on top of heap
CALL :heap_pop_A                        # save string address so we can free it
CALL :heap_push_A
LDI_BL 1                                # primary master
CALL :heap_push_BL
LDI_C .ata_banner
CALL :printf
LDI_BL 3                                # free 64 bytes, A still contains addr
CALL :free

# Initialize keyboard
.kb_init
LDI_C .kb_init_banner
CALL :print
CALL :keyboard_init
LDI_C .ok
CALL :print

# Initialize UART
LDI_C .uart_init_banner
CALL :print
CALL :uart_init_9600_8n1
# Unmask interrupts and flush any ready data
UMASKINT
# Pause 0.5s for serial to flush
LDI_AH 0x00 # bcd seconds
LDI_AL 0x50 # bcd subseconds
CALL :sleep
MASKINT
LDI_C .ok
CALL :print

# Print the current CPU clock
CALL :sys_clock_speed
LDI_C .clockspeed_banner
CALL :heap_push_A
CALL :printf

# Print the current date and time
LDI_C .clock_banner
LD_AL %tmr_clk_sec%
CALL :heap_push_AL
LD_AL %tmr_clk_min%
CALL :heap_push_AL
LD_AL %tmr_clk_hr%
CALL :heap_push_AL
LD_AL %tmr_clk_date%
CALL :heap_push_AL
LD_AL %tmr_clk_month%
LDI_BL %tmr_clk_month_mask%
ALUOP_AL %A&B%+%AL%+%BL%
CALL :heap_push_AL
LD_AL %tmr_clk_year%
CALL :heap_push_AL
LD_AL %tmr_clk_century%
CALL :heap_push_AL
CALL :printf

# Allocate memory for drive 0 and 1 filesystem handles.
# These are pointers, they contain a memory address, not
# the filesystem handles themselves.
VAR global 128 $drive_0_fs_handle
LDI_C $drive_0_fs_handle
LDI_AH 0x00     # byte to fill
LDI_AL 127      # bytes to fill, minus one
CALL :memfill
LDI_A $drive_0_fs_handle
CALL :heap_push_AL
CALL :heap_push_AH
LDI_AL '0'
CALL :heap_push_AL
LDI_C .mount_filehandle
CALL :printf

VAR global 128 $drive_1_fs_handle
LDI_C $drive_1_fs_handle
LDI_AH 0x00     # byte to fill
LDI_AL 127      # bytes to fill, minus one
CALL :memfill
LDI_A $drive_1_fs_handle
CALL :heap_push_AL
CALL :heap_push_AH
LDI_AL '1'
CALL :heap_push_AL
LDI_C .mount_filehandle
CALL :printf

# Global var for storing our current active drive, a pointer
# to either $drive_0_fs_handle or $drive_1_fs_handle.
# Will be null if no drive is selected
VAR global word $current_fs_handle_ptr
ST $current_fs_handle_ptr   0x00
ST $current_fs_handle_ptr+1 0x00

# Global var for storing the filesystem handle that we booted from
VAR global word $boot_fs_handle_ptr
ST $boot_fs_handle_ptr   0x00
ST $boot_fs_handle_ptr+1 0x00

# Global vars used by shell so commands can parse command line args
VAR global word $user_input_buf
VAR global 32 $user_input_tokens # store up to 16 tokens

# Print blank line
LDI_AL '\n'
CALL :putchar

# Attempt to mount drives
LDI_C $drive_1_fs_handle
CALL :heap_push_C
LDI_C $drive_0_fs_handle
CALL :heap_push_C

LDI_AH 0x00                     # AH = current drive we're working on
.mount_drives_loop
CALL :heap_push_AH
LDI_C .mount_0_str
CALL :printf
CALL :heap_pop_B                # Load filesystem handle address into B
CALL :heap_push_B               # address of filesystem handle
LDI_C 0x0000
CALL :heap_push_C               # high word of filesystem start sector (0x0000)
CALL :heap_push_C               # low word of filesystem start sector (0x0000)
CALL :heap_push_AH              # ATA device ID (AH)
CALL :fat16_mount
CALL :heap_pop_AL               # status byte
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xff = drive not attached
JZ .mount_drives_ok             # 0x00 = success, move on
LDI_C .mount_1_str              # otherwise, print our failure header
CALL :print
JEQ .mount_failed_not_attached
LDI_BL 0xfd
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xfd = extmalloc failed
JEQ .mount_failed_extmalloc
LDI_BL 0xfe
ALUOP_FLAGS %A&B%+%AL%+%BL%     # 0xfe = Not a FAT16 filesystem
JEQ .mount_failed_notfat16
JMP .mount_failed_ataerror      # other = ATA error

# Failure conditions when mounting
.mount_failed_not_attached
LDI_C .mount_2_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_extmalloc
LDI_C .mount_3_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_notfat16
LDI_C .mount_4_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_failed_ataerror
LDI_C .mount_5_str
CALL :heap_push_AL
CALL :printf
JMP .mount_drives_loop_end

.mount_drives_ok
LDI_C .ok
CALL :print
JMP .mount_drives_loop_end

.mount_drives_loop_end
ALUOP_AH %A+1%+%AH%
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .mount_drives_done
JMP .mount_drives_loop
.mount_drives_done

#######
# OS Loader sequence
#######

# Set 0 as current drive
LDI_C $drive_0_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1

# Check for SYSTEM.ODY on that drive
LDI_C .os_bin_filename
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # pointer to dirent if success, or 0x00.. or 0x01.. if error
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .try_drive_1
ALUOP_FLAGS %A%+%AH%
JZ .try_drive_1
JMP .found_system_ody

.try_drive_1
# Set 1 as current drive
LDI_C $drive_1_fs_handle
ST_CH $current_fs_handle_ptr
ST_CL $current_fs_handle_ptr+1
ST_CH $boot_fs_handle_ptr
ST_CL $boot_fs_handle_ptr+1

# Check for SYSTEM.ODY on that drive
LDI_C .os_bin_filename
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A                # pointer to dirent if success, or 0x00.. or 0x01.. if error
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%
JEQ .seekos_failed_notfound
ALUOP_FLAGS %A%+%AH%
JZ .seekos_failed_notfound
JMP .found_system_ody

# Binary is found, A contains the address of a copy
# of the directory entry (which needs to be freed),
# and the heap has the filesystem handle where it was
# found (which should match $current_fs_handle_ptr and
# $boot_fs_handle_ptr)
.found_system_ody
CALL :heap_pop_word             # discard the filesystem handle

CALL :heap_push_AL              # print boot status
CALL :heap_push_AH
LDI_C .mount_seekos_2
CALL :printf

# Allocate a proper memory segment for the binary
.allocate_ody_memory

# Round the file size up to the nearest 512 bytes
ALUOP_DH %A%+%AH%               # copy dirent to D for safekeeping
ALUOP_DL %A%+%AL%
CALL :heap_push_D               # directory entry
CALL :fat16_dirent_filesize
CALL :heap_pop_A                # low word of file size
CALL :heap_pop_word             # high word of file size (ignored)

CALL :heap_push_AL              # push filesize for printf later
CALL :heap_push_AH

# Our goal is to take the 16-bit filesize and convert it to a malloc
# number that is rounded up to the nearest 512 bytes.
#
# Rounding to the nearest 512 bytes means clearing the lowest 9 bits
# (which rounds _down_ to the nearest 512 bytes), so we then need to
# add 0x0200 to the result to round up. Observe that this means we
# completely ignore the bottom 8 bits.  So the "add" step is really
# to just add 0x02 to the high byte, and set the low byte to zero.
# We can simplify the addition so that we only need to add 0x01 to the
# high byte, by shifting it right first, then adding 1, then shifting
# left.
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
# Shift right four positions (divide by 16) to get the number of blocks we need to malloc
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
# But this is the actual number of blocks; malloc expects that number, minus one.
ALUOP_AL %A-1%+%AL%
CALL :heap_push_AL              # push block count for printf later
CALL :malloc
CALL :heap_push_AL              # push malloc address for printf
CALL :heap_push_AH
LDI_C .ody_malloc
CALL :printf
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # copy address to C

# Load the ODY into RAM
LD_BH $boot_fs_handle_ptr
LD_BL $boot_fs_handle_ptr+1
CALL :heap_push_B               # filesystem handle
CALL :heap_push_C               # target memory address
LDI_AL 0                        # load all sectors
CALL :heap_push_AL
CALL :heap_push_D               # directory entry
CALL :fat16_readfile
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JZ .localize_ody                # success, proceed to localize the file
CALL :heap_push_AL              # error, print ATA error
LDI_C .mount_seekos_5
CALL :printf
JMP .boot_halt

.localize_ody
# Free the directory handle, we no longer need it
MOV_DH_AH
MOV_DL_AL
LDI_B 1                         # 32 bytes to free
CALL :free

# Localize the ODY memory addresses
CALL :heap_push_C               # address of binary
CALL :fat16_localize_ody
CALL :heap_pop_D                # first byte of program
CALL_D                          # execute the program - this should never return

# Error! We should not have exited the shell
.boot_halt
CALL :heap_push_AL
LDI_C .boot_halt_str
CALL :printf
HLT

# Failure condition when seeking the OS binary
.seekos_failed_notfound
LDI_C .sys_not_found
CALL :print
HLT

# Inert target for unused interrupts
.noirq
RETI

.ok "OK\n\0"
.hello_banner "Odyssey OS v1.0\n\n\0"
.malloc_init_banner "Malloc range 0x%x%x-0x%x%x (%U bytes)\n\0"
.memtest_str "Extended memory %UK OK\0"
.memtest_error_str "\nFAILED extended memory test\n\0"
.kb_init_banner "Keyboard init \0"
.uart_init_banner "UART init 9600,8n1 \0"
.clockspeed_banner "Current CPU frequency %UkHz\n\0"
.clock_banner "Current clock %B%B-%B-%B %B:%B:%B\n\0" # YYYY-MM-DD HH:MM:SS
.ata_banner "ATA%u: %s\n\0"
.mount_filehandle "Filesystem handle address for drive %c: 0x%x%x\n\0"
.mount_0_str "Mounting drive %u...\0"
.mount_1_str "FAILED: \0"
.mount_2_str "Drive 0 not responding (code 0x%x)\n\0"
.mount_3_str "Extmalloc failed (code 0x%x)\n\0"
.mount_4_str "Not a FAT16 filesystem (code 0x%x)\n\0"
.mount_5_str "ATA error (code 0x%x)\n\0"
.mount_seekos_2 "Found: directory entry at 0x%x%x, executing..\n\0"
.mount_seekos_5 "ATA error loading system binary: 0x%x\n\0"
.os_bin_filename "/SYSTEM.ODY\0"
.sys_not_found "SYSTEM.ODY not found. System halted.\n\0"
.boot_halt_str "System process exited. Status byte 0x%x\nSystem halted.\n\0"
.ody_malloc "SYSTEM.ODY loaded at 0x%x%x size %u from filesize 0x%x%x\n\0"
