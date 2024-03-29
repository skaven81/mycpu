# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

CALL :heap_init

LDI_C .fmt1
LDI_D %display_chars%
LDI_AL 0xef
CALL :heap_push_AL
LDI_AL 0xbe
CALL :heap_push_AL
LDI_AL 0x34
CALL :heap_push_AL
LDI_AL 0x12
CALL :heap_push_AL

CALL :sprintf

LDI_C .fmt2
LDI_D %display_chars%+128
LDI_A .substr
CALL :heap_push_A

CALL :sprintf

LDI_C .fmt3
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL
LDI_D %display_chars%+256
CALL :sprintf

LDI_C .fmt4
LDI_AL '$'
CALL :heap_push_AL
LDI_AL '#'
CALL :heap_push_AL
LDI_AL '@'
CALL :heap_push_AL
LDI_AL '!'
CALL :heap_push_AL
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL

LDI_D %display_chars%+384
CALL :sprintf

LDI_C .fmt5
LDI_AL 0
CALL :heap_push_AL
LDI_AL 255
CALL :heap_push_AL
LDI_AL 125
CALL :heap_push_AL
LDI_AL 37
CALL :heap_push_AL
LDI_AL 9
CALL :heap_push_AL
LDI_D %display_chars%+512
CALL :sprintf

LDI_C .fmt6
LDI_AL -127
CALL :heap_push_AL
LDI_AL 127
CALL :heap_push_AL
LDI_AL -125
CALL :heap_push_AL
LDI_AL 37
CALL :heap_push_AL
LDI_AL -9
CALL :heap_push_AL
LDI_D %display_chars%+640
CALL :sprintf

LDI_C .fmt7
LDI_A 42017
CALL :heap_push_A
LDI_A 7270
CALL :heap_push_A
LDI_A 207
CALL :heap_push_A
LDI_A 18 
CALL :heap_push_A
LDI_A 4  
CALL :heap_push_A
LDI_D %display_chars%+768
CALL :sprintf

LDI_C .fmt8
LDI_A 32017
CALL :heap_push_A
LDI_A 7270
CALL :heap_push_A
LDI_A 207
CALL :heap_push_A
LDI_D %display_chars%+896
CALL :sprintf

LDI_C .fmt9
LDI_A -32017
CALL :heap_push_A
LDI_A -7270
CALL :heap_push_A
LDI_A -207
CALL :heap_push_A
LDI_D %display_chars%+1024
CALL :sprintf

LDI_C .fmt10
LDI_D %tmr_clk_sec%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_min%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_hr%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_date%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_month%
LDA_D_AL
LDI_BL %tmr_clk_month_mask%
ALUOP_AL %A&B%+%AL%+%BL%
CALL :heap_push_AL
LDI_D %tmr_clk_year%
LDA_D_AL
CALL :heap_push_AL
LDI_D %tmr_clk_century%
LDA_D_AL
CALL :heap_push_AL
LDI_D %display_chars%+1152
CALL :sprintf

VAR global 64 $teststring
LDI_C .ts1
LDI_D $teststring
CALL :strcpy                    # copy .ts into RAM at $teststring
ALUOP_ADDR_D %zero%             # null-terminate the copied string
LDI_D %display_chars%+1280
LDI_C $teststring
CALL :sprintf                   # print "A test string"

LDI_A .ts2
CALL :heap_push_A
LDI_A .ts1
CALL :heap_push_A
LDI_AL 2
LDI_D $teststring
CALL :strcat
LDI_D %display_chars%+1344
LDI_C $teststring
CALL :sprintf                   # print "A test string we can test with"

LDI_AL '1'
LDI_D $teststring
CALL :strprepend
LDI_D %display_chars%+1408
LDI_C $teststring
CALL :sprintf                   # print "1A test string we can test with"

LDI_AL '2'
LDI_D $teststring+10
CALL :strprepend
LDI_D %display_chars%+1472
LDI_C $teststring
CALL :sprintf                   # print "1A test st2ring we can test with"

LDI_AL '3'
LDI_D $teststring+32
CALL :strprepend
LDI_D %display_chars%+1536
LDI_C $teststring
CALL :sprintf                   # print "1A test st2ring we can test with3"


.loop
CALL :sys_clock_speed
CALL :heap_push_A
LDI_C .fmt11
LDI_D %display_chars%+1664
CALL :sprintf
JMP .loop

HLT

.fmt1 "Percent:[%%] hex:[0x%X%x 0x%X%x] error:[%$]\0"
.fmt2 "An error %y and a substring [%s]\0"
.substr "Hello, world!\0"
.fmt3 "BCD HH:MM %B:%B or in binary %2:%2\0"
.fmt4 "BCD-short HH:MM %b:%b   Raw chars [%c%c%c%c]\0"
.fmt5 "Decimal 9 [%u] 37 [%u] 125 [%u] 255 [%u] 0 [%u]\0"
.fmt6 "Signed -9 [%d] 37 [%d] -125 [%d] 127 [%d] -127 [%d]\0"
.fmt7 "Word 4 [%U] 18 [%U] 207 [%U] 7270 [%U] 42017 [%U]\0"
.fmt8 "Signed Word 207 [%D] 7270 [%D] 32017 [%D]\0"
.fmt9 "Signed Word -207 [%D] -7270 [%D] -32017 [%D]\0"
.fmt10 "yyyy-mm-dd HH:MM:SS %B%B-%B-%B %B:%B:%B\0"
.fmt11 "Current clock speed: %UkHz\0"
.ts1 "A test string\0"
.ts2 " we can test with\0"

.noirq
RETI
