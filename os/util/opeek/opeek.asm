# vim: syntax=asm-mycpu

# opeek - Odyssey peek with optional mode parameter
#
# Functionally identical to the built-in fpeek/peek shell commands, but with
# a single configurable command that selects the read method via an optional
# argument.
#
# Usage:
#   opeek <addr>          fast read (same as fpeek)
#   opeek <addr> slow     slow read (same as peek)

:cmd_opeek

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                                # 4 blocks = 64 bytes
CALL :memcpy_blocks

# Default to fast read
ST $opeek_slow 0x00

# Validate argv[1] non-null (high byte of pointer != 0)
LD_AH .argv_buf+2
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Parse address from argv[1]
LD_CH .argv_buf+2
LD_CL .argv_buf+3
CALL :strtoi                            # A=address, BL=flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

# Save address on the CPU stack while we examine argv[2]
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

# Optional argv[2] mode parameter
LD_AH .argv_buf+4
ALUOP_FLAGS %A%+%AH%
JZ .read_byte                           # no mode arg, use default fast

# argv[2] is present; must be the literal "slow"
LD_CH .argv_buf+4
LD_CL .argv_buf+5
LDI_D .slow_kw
CALL :strcmp                            # AL=result, all other regs preserved
ALUOP_FLAGS %A%+%AL%
JNZ .abort_bad_mode
ST $opeek_slow 0x01

.read_byte
POP_AL
POP_AH                                  # A = address

LD_BL $opeek_slow
ALUOP_FLAGS %B%+%BL%
JNZ .read_slow

# Fast read
LDA_A_BL                                # BL = byte at A
JMP .print_result

.read_slow
LDA_A_SLOW_PUSH                         # push byte at A (slow)
POP_BL                                  # BL = byte at A

.print_result
CALL :heap_push_BL                      # arg: byte
CALL :heap_push_AL                      # arg: address low
CALL :heap_push_AH                      # arg: address high
LDI_C .peek_pfx
CALL :printf
ALUOP_PUSH %A%+%AL%
ALUOP_AL %B%+%BL%                       # AL = byte
CALL :putchar_direct
POP_AL
LDI_C .peek_end
CALL :print
JMP .program_exit

.abort_bad_mode
POP_TD
POP_TD                                  # discard saved address
LDI_C .bad_mode_str
CALL :print
JMP .program_exit

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
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

.helpstr "Usage: opeek <addr> [slow]\n\0"
.bad_addr_str "Error: %s is not a valid address. strtoi flags: 0x%x\n\0"
.bad_mode_str "Error: optional mode parameter must be 'slow'\n\0"
.peek_pfx "0x%x%x: 0x%x (\0"
.peek_end ")\n\0"
.slow_kw "slow\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

VAR global byte $opeek_slow
