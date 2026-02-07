# vim: syntax=asm-mycpu

# Test the extended memory

:cmd_memtest

##### Test #1: 0x55/0xaa updates to all 1M extended memory addresses

LDI_C .page_test
CALL :print

CALL :cursor_off

LDI_C 0x0000                            # K counter
CALL :heap_push_C

LDI_BH 0x00                             # page address in BH

.fill_test_loop
ALUOP_ADDR %B%+%BH% %d_page%            # set D page address
LDI_C 0xd000                            # start filling at 0xd000
LDI_AH 0x00                             # 0-255 counter in AH
.fill_test_k_loop                       # test 4 bytes each loop, 4*256=1Ki
LDI_BL 0x55
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
LDI_BL 0xaa
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
INCR_C
LDI_BL 0x55
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
LDI_BL 0xaa
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
INCR_C
LDI_BL 0x55
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
LDI_BL 0xaa
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
INCR_C
LDI_BL 0x55
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
LDI_BL 0xaa
ALUOP_ADDR_C %B%+%BL%
LDA_C_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .fill_test_error
INCR_C
ALUOP_AH %A+1%+%AH%                     # Increment 0-255 counter
JNO .fill_test_k_loop                   # loop until AH overflows, 256 * 4 bytes = 1K

LD_AH $crsr_row
LD_AL 0
CALL :cursor_goto_rowcol                # move cursor back to beginning of line

CALL :heap_pop_A                        # restore K counter into A
ALUOP16O_A %ALU16_A+1%                          # increment it

CALL :heap_push_A                       # push K counter onto heap for printing
CALL :heap_push_BH                      # push page address onto heap for printing
PUSH_CH
PUSH_CL
LDI_C .page_k_str
CALL :printf                            # print the number of KB checked
POP_CL
POP_CH
CALL :heap_push_A                       # store K counter on heap

LDI_BL 0x03
ALUOP_FLAGS %A&B%+%AL%+%BL%             # are the last two bits of K counter clear?
JNZ .fill_test_k_loop                   # If not, write another KB to this page
ALUOP_BH %B+1%+%BH%                     # Otherwise, increment page address
JNO .fill_test_loop                     # And start writing the next page

CALL :heap_pop_word
CALL :heap_pop_byte
CALL :heap_pop_byte                     # flush the heap
LDI_AL '\n'
CALL :putchar                           # move cursor to next line

##### Test #2: Write page number to each page and ensure
##### both 0xd and 0xe addresses work properly

## Write the page address to the first and last byte in each page using 0xd
LDI_BH 0x00                             # BH = page number
.setpage_loop
ALUOP_ADDR %B%+%BH% %d_page%            # set D page address
ALUOP_ADDR %B%+%BH% 0xd000
ALUOP_ADDR %B%+%BH% 0xdfff

LD_AH $crsr_row
LD_AL 0
CALL :cursor_goto_rowcol                # move cursor back to beginning of line

CALL :heap_push_BH                      # push page address onto heap for printing
LDI_C .detest_str
CALL :printf                            # print the write step

ALUOP_BH %B+1%+%BH%                     # increment page
JNO .setpage_loop

## Read the page addresses back using 0xe
LDI_BH 0x00                             # BH = page number
.readpage_loop
ALUOP_ADDR %B%+%BH% %e_page%            # set D page address
LD_AL 0xe000
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .pageaddr_error
LD_AL 0xefff
ALUOP_FLAGS %A&B%+%AL%+%BH%
JNE .pageaddr_error

LD_AH $crsr_row
LD_AL 0
CALL :cursor_goto_rowcol                # move cursor back to beginning of line

CALL :heap_push_BH                      # push page address onto heap for printing
LDI_C .detest_rd_str
CALL :printf                            # print the write step

ALUOP_BH %B+1%+%BH%                     # increment page
JNO .readpage_loop

LDI_AL '\n'
CALL :putchar                           # move cursor to next line
CALL :cursor_on
RET

.fill_test_error
CALL :cursor_on
POP_BL
CALL :heap_pop_word
CALL :heap_pop_byte
CALL :heap_pop_byte
.pageaddr_error
CALL :heap_push_C
LDI_C .error_str
CALL :printf
RET


.page_test "Extended memory test:\n\0"
.page_k_str "  Page 0x%x %UK OK\0"
.detest_str "  Page 0x%x write 0xd000/0xdfff\0"
.detest_rd_str "  Page 0x%x read 0xe000/0xefff OK\0"
.error_str "\nError at address 0x%x%x\n\0"
