# vim: syntax=asm-mycpu

# Software heap, generally used for storing extra subroutine arguments
#
# The heap lives at 0xba00 and may grow up to 0xbcff (768b), but there
# is no validation to prevent overrun.
VAR global word $heap_ptr

######
# Initialize the heap
:heap_init
ST16 $heap_ptr 0xb000
RET

######
# Initialize a stack frame. The value in AL (or BL) is the number
# of bytes to allocate for local variables.
:heap_advance_AL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD_BH $heap_ptr
LD_BL $heap_ptr+1
LDI_AH 0x00                         # so we can do 16-bit addition
ALUOP16O_B %ALU16_A+B%                    # advance the heap pointer
ALUOP_ADDR %B%+%BH% $heap_ptr       
ALUOP_ADDR %B%+%BL% $heap_ptr+1     # Save advanced heap pointer
POP_BL
POP_BH
POP_AH
RET

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
# Destroy a stack frame. The value in AL (or BL) is the number
# of bytes to deallocate for local variables.
:heap_retreat_AL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD_BH $heap_ptr
LD_BL $heap_ptr+1
LDI_AH 0x00                         # so we can do 16-bit subtraction
ALUOP16O_B %ALU16_B-A%               # advance the heap pointer
ALUOP_ADDR %B%+%BH% $heap_ptr       
ALUOP_ADDR %B%+%BL% $heap_ptr+1     # Save retreated heap pointer
POP_BL
POP_BH
POP_AH
RET

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
# Push a byte onto the heap
:heap_push_AH
ALUOP_PUSH %A%+%AH%
JMP .do_heap_push_byte
:heap_push_AL
ALUOP_PUSH %A%+%AL%
JMP .do_heap_push_byte
:heap_push_BH
ALUOP_PUSH %B%+%BH%
JMP .do_heap_push_byte
:heap_push_BL
ALUOP_PUSH %B%+%BL%
JMP .do_heap_push_byte
:heap_push_CH
PUSH_CH
JMP .do_heap_push_byte
:heap_push_CL
PUSH_CL
JMP .do_heap_push_byte
:heap_push_DH
PUSH_DH
JMP .do_heap_push_byte
:heap_push_DL
PUSH_DL
JMP .do_heap_push_byte

.do_heap_push_byte
MASKINT                 # Since we'll be using temp registers, we can't afford an IRQ
POP_TD
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
STA_D_TD
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
UMASKINT
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

