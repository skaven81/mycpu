# vim: syntax=asm-mycpu

###
# Assembly helpers for cmd_memstat -- emit_ch, emit_sgr, memstat_sep_d,
# memstat_sep_s
#
# These are hand-written in assembly to avoid the code bloat produced by the
# C compiler for these hot-path / simple functions.
#
# All of these assume the caller has $term_flags bit 1 (ANSI mode) set --
# cmd_memstat() sets it for the whole command. Without it, the ESC bytes
# these emit would print as literal garbage glyphs instead of being
# consumed by the ANSI state machine.
###

###
# :emit_ch -- write one character to the terminal with the current print color
#
# Input:
#   Push the character byte to the heap before calling (CALL :heap_push_AL)
#
# Output:
#   None
#
# Calling convention:
#   CALL :heap_push_AL          # push character
#   CALL :emit_ch               # write char + color
#   # callee retreats 1 byte from heap on return
#
# Side effects:
#   Calls :putchar (advances terminal cursor).
#   Writes $term_current_color to the color framebuffer at cursor-1.
#   Does NOT modify any registers (callee-save).
###
:emit_ch
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH

# Load parameter c from heap (heap_push increments then stores, so
# heap_ptr points TO the parameter byte).
LD_CH $heap_ptr
LD_CL $heap_ptr+1
LDA_C_AL                        # AL = character byte

# Emit the character; putchar preserves all registers
CALL :putchar

# Write current print color to the color framebuffer position we just wrote.
# After putchar, crsr_addr_color has been advanced one past the written position.
LD_CH $crsr_addr_color
LD_CL $crsr_addr_color+1
DECR_C                          # C = color address of the char we just wrote
LD_AL $term_current_color
ALUOP_ADDR_C %A%+%AL%           # store color byte

# Retreat heap: free the 1-byte parameter
LDI_BL 1
CALL :heap_retreat_BL

POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

###
# :emit_sgr -- write an ANSI SGR escape (ESC[<n>m) for a 2-digit code
#
# Input:
#   Push the SGR code byte to the heap before calling (CALL :heap_push_AL)
#   (30-37, 90-97, or 0 for reset -- must expand to exactly 1 or 2 digits,
#   this codebase's only current callers use 2-digit codes plus 0)
#
# Output:
#   None
#
# Calling convention: same as :emit_ch (heap_push_AL, CALL, callee
# retreats 1 byte from heap on return).
#
# Side effects: prints via :printf (advances terminal cursor through the
# ANSI parser, does not itself touch the color framebuffer -- the SGR
# handler in terminal_ansi.asm does that). Does NOT modify any registers
# (callee-save).
###
:emit_sgr
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

LD_CH $heap_ptr
LD_CL $heap_ptr+1
LDA_C_AL                        # AL = SGR code byte
LDI_BL 1
CALL :heap_retreat_BL           # free the 1-byte parameter

CALL :heap_push_AL              # re-push it as :printf's %u argument
LDI_C .emit_sgr_fmt
CALL :printf

POP_CL
POP_CH
POP_AL
RET
.emit_sgr_fmt 0x1b "[%um\0"

###
# :memstat_sep_d -- print a 64-character double-line separator
#
# Calls :print with a pre-built string: color SGR 36 (cyan), 64x0xCD,
# reset SGR 0. The 64 characters wrap the terminal to the next line
# naturally.
#
# Input:   None
# Output:  None
# Saves/restores: all registers (callee-save)
###
:memstat_sep_d
PUSH_CH
PUSH_CL
LDI_C .sep_d_data
CALL :print
POP_CL
POP_CH
RET
.sep_d_data 0x1b "[36m" 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0xCD 0x1b "[0m\0"

###
# :memstat_sep_s -- print a 64-character single-line separator
#
# Calls :print with a pre-built string: color SGR 36 (cyan), 64x0xC4,
# reset SGR 0. The 64 characters wrap the terminal to the next line
# naturally.
#
# Input:   None
# Output:  None
# Saves/restores: all registers (callee-save)
###
:memstat_sep_s
PUSH_CH
PUSH_CL
LDI_C .sep_s_data
CALL :print
POP_CL
POP_CH
RET
.sep_s_data 0x1b "[36m" 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0xC4 0x1b "[0m\0"
