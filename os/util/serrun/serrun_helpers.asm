# vim: syntax=asm-mycpu

# serrun_helpers - hand-written assembly helpers for serrun (main.c)
#
# serrun's UART/keyboard byte I/O goes straight through the register-
# convention BIOS primitives via C-callable special-case codegen (see
# c_compiler/special_functions.py + os/bios/lib/uart.h/keyboard.h) -- no
# wrapper needed for those.  The two functions below are genuinely new
# logic specific to serrun, not a calling-convention adapter for an
# existing routine, so they stay hand-written here rather than growing
# special_functions.py.

####
# :size_to_segments - convert a byte size into the segment count needed
# by :malloc_segments (128-byte segments; round up to the nearest 512
# bytes, then divide by 128).  This replicates the allocation-size math
# in os/bios/80-run_system_ody.asm's .exec_alloc_main -- C has no `/`
# operator, so this arithmetic has to live in assembly.
#
# To use:
#  1. Push the size (word) to the heap
#  2. Call the function
#  3. Pop the segment count (byte)
#
# Side effects: none (all registers preserved)
:size_to_segments
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

CALL :heap_pop_A                 # A = size

# Round up to the nearest even AH (adds up to 511 bytes), then shift the
# whole 16-bit value right 7 times (divide by 128) -- same sequence as
# .exec_alloc_main.
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
CALL :shift16_a_right             # /2
CALL :shift16_a_right             # /4
CALL :shift16_a_right             # /8
CALL :shift16_a_right             # /16
CALL :shift16_a_right             # /32
CALL :shift16_a_right             # /64
CALL :shift16_a_right             # /128 -> AL = segment count

CALL :heap_push_AL

POP_AL
POP_AH
RET

####
# :copy_arg_string - duplicate a null-terminated string into a freshly
# calloc'd buffer, sized to fit (rounded up to 16-byte blocks, minimum
# one block).  Used to copy serrun's own argv[] strings before forwarding
# them to the launched program: serrun's own argv memory is BIOS-owned
# and gets freed as soon as serrun returns, before the launched program
# ever runs, so the strings must be duplicated rather than shared.
#
# To use:
#  1. Push the source string address
#  2. Call the function
#  3. Pop the address of the new, null-terminated copy
#
# Side effects: none (all registers preserved).  The destination is
# calloc'd (zero-filled), so the copy ends up null-terminated even though
# :strcpy itself does not write the terminating null.
:copy_arg_string
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                 # C = source string address (untouched below)

# Measure the source length in 16-byte blocks (rounded up, minimum 1),
# walking a scratch copy of the pointer in D so C is left untouched for
# the strcpy call later.  C/D have no direct copy between them, so route
# through A (MOV is C/D -> A/B/T only; A reaches D via the ALU).
MOV_CH_AH
MOV_CL_AL
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                # D = walking copy of the source address
LDI_BL 1                         # BL = block count so far
LDI_AL 16                        # AL = bytes remaining in the current block
.copy_arg_measure_loop
LDA_D_AH                         # AH = next source character
ALUOP_FLAGS %A%+%AH%
JZ .copy_arg_measure_done        # stop at the null terminator
INCR_D
ALUOP_AL %A-1%+%AL%              # one fewer byte left in this block
JNZ .copy_arg_measure_loop
LDI_AL 16                        # this block is full: start counting a new one
ALUOP_BL %B+1%+%BL%
JMP .copy_arg_measure_loop
.copy_arg_measure_done

ALUOP_AL %B%+%BL%                 # AL = block count, ready for calloc_blocks
CALL :calloc_blocks                # A = zeroed destination address
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                  # D = destination address (strcpy dest); A has no direct MOV to D

# C still = original source address; :strcpy advances both C and D
CALL :strcpy                      # copy characters up to (not including) the null

CALL :heap_push_A                 # push the destination address as the result

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# :uart_rx_enable - install the buffered UART receive-interrupt handler
# (:uart_irq_dr_buf) at IRQ5, saving whatever handler was previously
# installed there (into $serrun_saved_irq5) so :uart_rx_disable can
# restore it later.
#
# The BIOS boot default at IRQ5 is :uart_clear_dr (os/bios/00-main.asm),
# which reads and discards every received byte without ever writing it
# into the RAM ring buffer -- uart_bufsize()/uart_readbuf() will report
# "empty" forever, no matter what arrives on the wire, until the buffering
# handler is installed.  This must run before serrun's rendezvous loop.
# Matches the save/install pattern in
# os/util/console/20-cmd_console.asm (the only other program that reads
# from the UART).
#
# To use: call with no arguments (heap-convention: no args, no return)
#
# Side effects: installs :uart_irq_dr_buf at IRQ5.  All registers preserved.
VAR global word $serrun_saved_irq5
:uart_rx_enable
PUSH_CH
PUSH_CL

MASKINT
LD_CL %IRQ5addr%
ST_CL $serrun_saved_irq5
LD_CL %IRQ5addr%+1
ST_CL $serrun_saved_irq5+1
ST16 %IRQ5addr% :uart_irq_dr_buf
UMASKINT

POP_CL
POP_CH
RET

####
# :uart_rx_disable - restore whatever IRQ5 handler was installed before
# the matching :uart_rx_enable call.
#
# To use: call with no arguments (heap-convention: no args, no return)
#
# Side effects: restores the previous IRQ5 vector.  All registers preserved.
:uart_rx_disable
PUSH_CH
PUSH_CL

MASKINT
LD_CL $serrun_saved_irq5
ST_CL %IRQ5addr%
LD_CL $serrun_saved_irq5+1
ST_CL %IRQ5addr%+1
UMASKINT

POP_CL
POP_CH
RET
