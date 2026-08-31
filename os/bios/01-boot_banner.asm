# vim: syntax=asm-mycpu

# :boot_banner - boot splash screen.
#
# Loads the boot-sector banner (os/bootbanner/PRISMBAN.ODY, spliced into
# the 448-byte bootstrap-code area of the drive 0 FAT16 boot sector) and
# runs it in place.
#
# Called once from 00-main, after :boot_malloc_init (which brings up
# :extmalloc_init, required by the page allocation below).
#
# MEMORY: the 512-byte load buffer is a properly :extmalloc'd extended
# page mapped with :extpage_e_push / :extpage_e_pop, and released with
# :extfree on every exit path.  Do NOT go back to hardcoding page 0xff:
# by the time this runs, :extmalloc has already handed 0xff out (it
# allocates from the high end, and 00-main takes the first page for the
# command-history ring), so a hardcoded 0xff writes a sector and a
# relocated program straight into live allocated memory.
#
# Everything here is best-effort and SILENT on failure.  Extended memory
# full, drive absent, ATA error, sector-read timeout, or no 'ODY' magic
# in the boot-code area -> just release the page and RET.  The normal
# boot sequence then proceeds unchanged.
#
# On success: relocate the image in place (it was read to 0xE000, the
# ODY starts at byte 0x3E of the sector), clear the screen, keep the
# cursor disabled, CALL_D the banner (it only paints framebuffer rows
# 0..11 and RETs -- no args in, no exit code out), then park the cursor
# on row 12 so the boot log scrolls out below it.

:boot_banner
# --- claim an extended-RAM page for the load buffer ----------------
CALL :extmalloc                     # page number pushed to heap
CALL :heap_pop_AL                   # AL = allocated page
ALUOP_FLAGS %A%+%AL%
JZ .bbnr_no_page                    # 0 = extended memory full.  Page 0 is
                                    # :malloc's ledger/scratch page, so
                                    # reading a sector into it would wreck
                                    # the main-RAM allocator.  Bail out.
CALL :heap_push_AL                  # hand it back to :extpage_e_push
CALL :extpage_e_push                # map it, saving the previous E page

# --- read LBA 0 of drive 0 into 0xE000 ----------------------------
# :ata_read_lba heap args: target addr, LBA bits 27..16, LBA bits
# 15..0, drive byte.  Returns a status byte: 0 = OK, 0xff = drive did
# not respond, anything else = ATA error bits.
LDI_A 0xe000
CALL :heap_push_A                   # target = 0xE000
LDI_A 0x0000
CALL :heap_push_A                   # LBA bits 27..16 = 0
CALL :heap_push_A                   # LBA bits 15..0  = 0
LDI_AL 0x00
CALL :heap_push_AL                  # drive 0 (primary master)
CALL :ata_read_lba
CALL :heap_pop_AL                   # status
ALUOP_FLAGS %A%+%AL%
JNZ .bbnr_release                   # non-zero -> no readable boot sector

# --- check the bootstrap-code area for the 'ODY' magic -----------
LDI_A 0xe000+0x003e                 # 0x3E = boot-code offset in the sector
CALL :heap_push_A
CALL :fat16_inspect_ody
CALL :heap_pop_AL                   # ODY flag byte, or 0xff if not an ODY
LDI_BL 0xff
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .bbnr_release                   # 0xff -> no banner installed

# --- relocate the image in place and run it ---------------------
LDI_A 0xe000+0x003e
CALL :heap_push_A
CALL :fat16_localize_ody            # leaves the entry-point word on the heap

# Clear the screen - the boot banner program assumes a clear screen
LDI_AH 0x00
LDI_AL %white%
CALL :clear_screen
ST $crsr_on 0x00

CALL :heap_pop_D                    # D = banner entry point, from fat16_localize_ody
CALL_D                              # paint the banner

# --- park the cursor just below the 12-row banner --------------
LDI_AH 12                           # row 12 (banner is framebuffer rows 0..11)
LDI_AL 0x00                         # col 0
CALL :cursor_goto_rowcol

.bbnr_release
# Restore the caller's E-page mapping and give the page back.  Reached on
# every path that got as far as :extpage_e_push, success or failure.
CALL :extpage_e_pop                 # restore previous E page; ours -> heap
CALL :extfree                       # release it

.bbnr_no_page
RET

