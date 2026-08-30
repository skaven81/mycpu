# vim: syntax=asm-mycpu

# Software heap, generally used for storing extra subroutine arguments
#
# The heap lives at 0xf000 and may grow up to 0xffef (~4k), but there
# is no validation to prevent overrun.
VAR global word $heap_ptr

######
# Initialize the heap
:heap_init
ST16 $heap_ptr 0xf000
RET

######
# Initialize a stack frame. The value in BL is the number
# of bytes to allocate for local variables.
:heap_advance_BL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
LD_AH $heap_ptr
LD_AL $heap_ptr+1
LDI_BH 0x00                         # so we can do 16-bit addition
ALUOP16O_A %ALU16_A+B%                    # advance the heap pointer
ALUOP_ADDR %A%+%AH% $heap_ptr       
ALUOP_ADDR %A%+%AL% $heap_ptr+1     # Save advanced heap pointer
POP_BH
POP_AL
POP_AH
RET

######
# Destroy a stack frame. The value in BL is the number
# of bytes to deallocate for local variables.
:heap_retreat_BL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
LD_AH $heap_ptr
LD_AL $heap_ptr+1
LDI_BH 0x00                         # so we can do 16-bit subtraction
ALUOP16O_A %ALU16_A-B%               # advance the heap pointer
ALUOP_ADDR %A%+%AH% $heap_ptr       
ALUOP_ADDR %A%+%AL% $heap_ptr+1     # Save retreated heap pointer
POP_BH
POP_AL
POP_AH
RET

######
# Push a byte onto the heap.
#
# The byte is routed through AL -- the caller's AL is saved on the hardware
# stack and restored on the way out -- and written with a single
# ALUOP_ADDR_D. No microcode scratch register (TD) is touched, so unlike the
# old POP_TD / STA_D_TD form this needs no MASKINT window: a caller that
# holds an outer MASKINT is no longer silently unmasked by pushing, and an
# IRQ that does NOT itself use the heap can now land anywhere in here
# harmlessly. (A heap-using ISR is still not safe against a mid-push main
# line -- the $heap_ptr read-modify-write is not atomic -- same as the pop
# path has always been.) Flags are not preserved (nor were they by the old
# :heap_push_AL).
:heap_push_AL
ALUOP_PUSH %A%+%AL%     # save caller AL; it already holds the value to push
JMP .do_heap_push_byte
:heap_push_AH
ALUOP_PUSH %A%+%AL%     # save caller AL (used as the transfer register)
ALUOP_AL %A%+%AH%       # AL = value to push
JMP .do_heap_push_byte
:heap_push_BH
ALUOP_PUSH %A%+%AL%
ALUOP_AL %B%+%BH%
JMP .do_heap_push_byte
:heap_push_BL
ALUOP_PUSH %A%+%AL%
ALUOP_AL %B%+%BL%
JMP .do_heap_push_byte
:heap_push_CH
ALUOP_PUSH %A%+%AL%
MOV_CH_AL
JMP .do_heap_push_byte
:heap_push_CL
ALUOP_PUSH %A%+%AL%
MOV_CL_AL
JMP .do_heap_push_byte
:heap_push_DH
ALUOP_PUSH %A%+%AL%
MOV_DH_AL
JMP .do_heap_push_byte
:heap_push_DL
ALUOP_PUSH %A%+%AL%
MOV_DL_AL
JMP .do_heap_push_byte

.do_heap_push_byte      # entry: AL = value to push; caller AL saved on hw stack
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
ALUOP_ADDR_D %A%+%AL%   # [heap_ptr+1] = value -- single instruction, no TD
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
POP_AL                  # restore caller AL
RET

######
# Push a word onto the heap
:heap_push_A
CALL :heap_push_AH
CALL :heap_push_AL
RET
:heap_push_B
CALL :heap_push_BH
CALL :heap_push_BL
RET
:heap_push_C
CALL :heap_push_CH
CALL :heap_push_CL
RET
:heap_push_D
CALL :heap_push_DH
CALL :heap_push_DL
RET

######
# Pop a byte from the heap
:heap_pop_AL
CALL .do_heap_pop_al
RET
:heap_pop_AH
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_AH %A%+%AL%
POP_AL
RET
:heap_pop_BL
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_BL %A%+%AL%
POP_AL
RET
:heap_pop_BH
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_BH %A%+%AL%
POP_AL
RET
:heap_pop_CL
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_CL %A%+%AL%
POP_AL
RET
:heap_pop_CH
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_CH %A%+%AL%
POP_AL
RET
:heap_pop_DL
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_DL %A%+%AL%
POP_AL
RET
:heap_pop_DH
ALUOP_PUSH %A%+%AL%
CALL .do_heap_pop_al
ALUOP_DH %A%+%AL%
POP_AL
RET

.do_heap_pop_al
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
LDA_D_AL
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a word from the heap into A
:heap_pop_A
CALL :heap_pop_AL
CALL :heap_pop_AH
RET
:heap_pop_B
CALL :heap_pop_BL
CALL :heap_pop_BH
RET
:heap_pop_C
CALL :heap_pop_CL
CALL :heap_pop_CH
RET
:heap_pop_D
CALL :heap_pop_DL
CALL :heap_pop_DH
RET

######
# Pop a byte from the heap and discard it
:heap_pop_byte
PUSH_CL
CALL :heap_pop_CL
POP_CL
RET

######
# Pop a word from the heap and discard it
:heap_pop_word
PUSH_CL
CALL :heap_pop_CL
CALL :heap_pop_CL
POP_CL
RET

######
# Push all registers onto the heap
:heap_push_all
CALL :heap_push_A
CALL :heap_push_B
CALL :heap_push_C
CALL :heap_push_D
RET

######
# Pop all registers from the heap
:heap_pop_all
CALL :heap_pop_D
CALL :heap_pop_C
CALL :heap_pop_B
CALL :heap_pop_A
RET

