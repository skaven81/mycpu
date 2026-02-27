# vim: syntax=asm-mycpu

:cmd_extmalloc

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

# Check first argument so we know what subcommand to run
LD_CH .argv_buf+2
LD_CL .argv_buf+3      # pointer to second token string in C
MOV_CH_AL                       # high byte of pointer into AL
ALUOP_FLAGS %A%+%AL%            # check if zero
JZ .usage                       # no first argument if zero, so usage

# Jump to the next command phase based on first character of first argument
LDA_C_BH                        # BH contains the first character of the first argument
LDI_AL 'd'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .alloc_d
LDI_AL 'e'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .alloc_e
LDI_AL 'f'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .do_free
LDI_C .error_command
CALL :print
JMP .usage

.alloc_d
CALL :extmalloc                 # page ID on heap
CALL :heap_pop_AL
CALL :heap_push_AL
CALL :extpage_d_push            # use ID on heap to set D page
CALL :heap_push_AL
LDI_C .done_d
CALL :printf
JMP .program_exit

.alloc_e
CALL :extmalloc                 # page ID on heap
CALL :heap_pop_AL
CALL :heap_push_AL
CALL :extpage_e_push            # use ID on heap to set E page
CALL :heap_push_AL
LDI_C .done_e
CALL :printf
JMP .program_exit

.do_free
# Check second argument so we know if it's D or E to free
LD_CH .argv_buf+4
LD_CL .argv_buf+5      # pointer to third token string in C
MOV_CH_AL                       # high byte of pointer into AL
ALUOP_FLAGS %A%+%AL%            # check if zero
JZ .usage                       # no first argument if zero, so usage

# Jump to the next command phase based on first character of first argument
LDA_C_BH                        # BH contains the first character of the first argument
LDI_AL 'd'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .free_d
LDI_AL 'e'
ALUOP_FLAGS %A&B%+%AL%+%BH%
JEQ .free_e
LDI_C .error_command2
CALL :print
JMP .usage

.free_d
CALL :extpage_d_pop             # freed page ID is on heap
CALL :heap_pop_AL
CALL :heap_push_AL
CALL :extfree
CALL :heap_push_AL
LDI_C .done_fd
CALL :printf
JMP .program_exit

.free_e
CALL :extpage_e_pop             # freed page ID is on heap
CALL :heap_pop_AL
CALL :heap_push_AL
CALL :extfree
CALL :heap_push_AL
LDI_C .done_fe
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

.done_fd "Freed page 0x%x from 0xd000\n\0"
.done_fe "Freed page 0x%x from 0xe000\n\0"
.done_d "Allocated page 0x%x to 0xd000\n\0"
.done_e "Allocated page 0x%x to 0xe000\n\0"
.helpstr "Usage:\n  extmallc [de] - allocate a new extended memory page and assign to D or E page\n  extmallc f [de] - free the D or E page\n\0"
.error_command "ERR: invalid subcommand provided, expecting one of [def]\n\0"
.error_command2 "ERR: free command requires [de] argument\n\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
