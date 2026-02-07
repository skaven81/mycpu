# vim: syntax=asm-mycpu

:boot_extram_test
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
ALUOP16O_A %ALU16_A+1%
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
RET

.extram_error
CALL :cursor_on
LDI_C .memtest_error_str
CALL :print
HLT

.memtest_str "Extended memory %UK OK\0"
.memtest_error_str "\nFAILED extended memory test\n\0"
