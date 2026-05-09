# vim: syntax=asm-mycpu

# opoke - Odyssey poke with optional mode parameters
#
# Functionally identical to the built-in fpoke/poke shell commands, but
# with a single configurable command that selects the read and write
# methods via optional arguments.
#
# Usage:
#   opoke <addr> <byte>                  fast read + fast write (same as fpoke)
#   opoke <addr> <byte> slow             slow read + slow write (same as poke)
#   opoke <addr> <byte> noread           fast write only, no read-back
#   opoke <addr> <byte> noread slow      slow write only, no read-back
#   opoke <addr> <byte> slow noread      same as above (any order)

:cmd_opoke

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                                # 4 blocks = 64 bytes
CALL :memcpy_blocks

# Reset mode flags
ST $opoke_slow 0x00
ST $opoke_noread 0x00

# Validate argv[1] non-null
LD_AH .argv_buf+2
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Validate argv[2] non-null
LD_AH .argv_buf+4
ALUOP_FLAGS %A%+%AH%
JZ .usage

# Parse address from argv[1]
LD_CH .argv_buf+2
LD_CL .argv_buf+3
CALL :strtoi                            # A=address, BL=flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

# Save address on the CPU stack
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

# Parse byte from argv[2]
LD_CH .argv_buf+4
LD_CL .argv_buf+5
CALL :strtoi8                           # AL=byte, BL=flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_byte

# Save byte on the CPU stack
ALUOP_PUSH %A%+%AL%

# Optional argv[3]
LD_AH .argv_buf+6
ALUOP_FLAGS %A%+%AH%
JZ .args_done
LD_CH .argv_buf+6
LD_CL .argv_buf+7
CALL .check_mode_arg                    # AL=0 on match, non-zero on no match
ALUOP_FLAGS %A%+%AL%
JNZ .abort_bad_mode

# Optional argv[4]
LD_AH .argv_buf+8
ALUOP_FLAGS %A%+%AH%
JZ .args_done
LD_CH .argv_buf+8
LD_CL .argv_buf+9
CALL .check_mode_arg
ALUOP_FLAGS %A%+%AL%
JNZ .abort_bad_mode

.args_done
# Pop saved values back: byte into DL, address into A
POP_DL                                  # DL = byte to write
POP_AL
POP_AH                                  # A = address

# Decide whether to do the pre-read step
LD_BL $opoke_noread
ALUOP_FLAGS %B%+%BL%
JNZ .do_write                           # noread set, skip read

# Read existing byte into DH; method depends on $opoke_slow
LD_BL $opoke_slow
ALUOP_FLAGS %B%+%BL%
JNZ .read_slow

LDA_A_DH                                # fast read
JMP .do_write

.read_slow
LDA_A_SLOW_PUSH
POP_DH                                  # DH = current byte at A

.do_write
LD_BL $opoke_slow
ALUOP_FLAGS %B%+%BL%
JNZ .write_slow

# Fast write
STA_A_DL
JMP .write_done

.write_slow
PUSH_DL
STA_A_SLOW_POP

.write_done
LD_BL $opoke_noread
ALUOP_FLAGS %B%+%BL%
JNZ .print_noread

# Read-and-report form: "0x{addr}: was 0x{DH} now 0x{DL}"
CALL :heap_push_DL
CALL :heap_push_DH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .updated_str
CALL :printf
JMP .program_exit

.print_noread
# Write-only form: "0x{addr}: now 0x{DL}"
CALL :heap_push_DL
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .noread_done_str
CALL :printf
JMP .program_exit

# ----------------------------------------------------------------------
# .check_mode_arg - compare argv string in C against the recognized mode
# keywords ("slow", "noread") and set the corresponding flag on match.
#
# Calling convention:
#   Input:  C = pointer to the candidate argv string
#   Output: AL = 0 on match (and corresponding flag set), non-zero on no match
#   Side effects: updates $opoke_slow or $opoke_noread on match;
#                 strcmp preserves A/B/C/D, so the only register touched
#                 by this routine is AL.
# ----------------------------------------------------------------------
.check_mode_arg
LDI_D .slow_kw
CALL :strcmp                            # AL = strcmp result
ALUOP_FLAGS %A%+%AL%
JNZ .chk_try_noread
ST $opoke_slow 0x01
ALUOP_AL %zero%                         # AL=0 (success)
RET

.chk_try_noread
LDI_D .noread_kw
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JNZ .chk_no_match
ST $opoke_noread 0x01
ALUOP_AL %zero%                         # AL=0 (success)
RET

.chk_no_match
LDI_AL 0xff                             # AL=non-zero (no match)
RET

.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
JMP .program_exit

.abort_bad_byte
POP_TD                                  # discard saved address
POP_TD
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_byte_str
CALL :printf
JMP .program_exit

.abort_bad_mode
POP_TD                                  # discard saved byte
POP_TD                                  # discard saved address (low)
POP_TD                                  # discard saved address (high)
LDI_C .bad_mode_str
CALL :print
JMP .program_exit

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.helpstr "Usage: opoke <addr> <byte> [slow] [noread]\n\0"
.bad_addr_str "Error: %s is not a valid address. strtoi flags: 0x%x\n\0"
.bad_byte_str "Error: %s is not a valid byte specifier. strtoi flags: 0x%x\n\0"
.bad_mode_str "Error: optional mode parameters must be 'slow' and/or 'noread'\n\0"
.updated_str "0x%x%x: was 0x%x now 0x%x\n\0"
.noread_done_str "0x%x%x: now 0x%x\n\0"
.slow_kw "slow\0"
.noread_kw "noread\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

VAR global byte $opoke_slow
VAR global byte $opoke_noread
