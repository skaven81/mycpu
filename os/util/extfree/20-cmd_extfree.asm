# vim: syntax=asm-mycpu

:cmd_extfree

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

# Ensure we have an argument (argv[1])
LDI_D .argv_buf+2               # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Convert the argument into an integer
LDI_A .argv_buf+2               # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A .argv_buf+3               # |
LDA_A_CL                        # |
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_page

# Free the page
CALL :heap_push_AL              # put page to free onto heap
CALL :extfree                   # free the page
JMP .program_exit

.abort_bad_page
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_page_str
CALL :printf
JMP .program_exit

.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.helpstr "Usage: extfree <page>\n\0"
.bad_page_str "Error: %s is not a valid page number. strtoi flags: 0x%x\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
