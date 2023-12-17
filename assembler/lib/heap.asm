# vim: syntax=asm-mycpu

# Software heap, generally used for storing extra subroutine arguments
#
# The heap lives at 0xba00 and may grow up to 0xbcff (768b), but there
# is no validation to prevent overrun.
VAR global word $heap_ptr

######
# Initialize the heap
:heap_init
ST16 $heap_ptr 0xba00
RET

######
# Push a register value onto the heap from AL
#
# Input:
#   AL - byte to push onto the heap
:heap_push_AL
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
ALUOP_ADDR_D %A%+%AL%
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push a register value onto the heap from AH
#
# Input:
#   AH - byte to push onto the heap
:heap_push_AH
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
ALUOP_ADDR_D %A%+%AH%
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET


######
# Pop a value from the heap into AL
:heap_pop_AL
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
# Pop a value from the heap into AH
:heap_pop_AH
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
LDA_D_AH
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push 16-bit word from A onto the heap
:heap_push_A
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
INCR_D
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a word from the heap into A
:heap_pop_A
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
LDA_D_AL
DECR_D
LDA_D_AH
DECR_D
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push a register value onto the heap from BL
#
# Input:
#   BL - byte to push onto the heap
:heap_push_BL
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
ALUOP_ADDR_D %B%+%BL%
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push a register value onto the heap from BH
#
# Input:
#   BH - byte to push onto the heap
:heap_push_BH
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
INCR_D
ALUOP_ADDR_D %B%+%BH%
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET


######
# Pop a value from the heap into BL
:heap_pop_BL
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
LDA_D_BL
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a value from the heap into BH
:heap_pop_BH
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
LDA_D_BH
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push 16-bit word from B onto the heap
:heap_push_B
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
INCR_D
ALUOP_ADDR_D %B%+%BH%
INCR_D
ALUOP_ADDR_D %B%+%BL%
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a word from the heap into B
:heap_pop_B
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
LDA_D_BL
DECR_D
LDA_D_BH
DECR_D
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
RET


######
# Push 16-bit word from C onto the heap
:heap_push_C
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
INCR_D
STA_D_CH
INCR_D
STA_D_CL
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a word from the heap into C
:heap_pop_C
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LD_AH   $heap_ptr
LD_AL   $heap_ptr+1
LDA_A_CL
CALL :decr16_a
LDA_A_CH
CALL :decr16_a
ALUOP_ADDR %A%+%AH% $heap_ptr
ALUOP_ADDR %A%+%AL% $heap_ptr+1
POP_AL
POP_AH
RET

######
# Push a register value onto the heap from DL
#
# Input:
#   DL - byte to push onto the heap
:heap_push_DL
PUSH_CH
PUSH_CL
LD_CH  $heap_ptr
LD_CL  $heap_ptr+1
INCR_C
STA_C_DL
ST_CH  $heap_ptr
ST_CL  $heap_ptr+1
POP_CL
POP_CH
RET

######
# Push a register value onto the heap from DH
#
# Input:
#   DH - byte to push onto the heap
:heap_push_DH
PUSH_CH
PUSH_CL
LD_CH  $heap_ptr
LD_CL  $heap_ptr+1
INCR_C
STA_C_DH
ST_CH  $heap_ptr
ST_CL  $heap_ptr+1
POP_CL
POP_CH
RET

######
# Push 16-bit word from D onto the heap
:heap_push_D
PUSH_CH
PUSH_CL
LD_CH   $heap_ptr
LD_CL   $heap_ptr+1
INCR_C
STA_C_DH
INCR_C
STA_C_DL
ST_CH   $heap_ptr
ST_CL   $heap_ptr+1
POP_CL
POP_CH
RET

######
# Pop a word from the heap into D
:heap_pop_D
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LD_AH   $heap_ptr
LD_AL   $heap_ptr+1
LDA_A_DL
CALL :decr16_a
LDA_A_DH
CALL :decr16_a
ALUOP_ADDR %A%+%AH% $heap_ptr
ALUOP_ADDR %A%+%AL% $heap_ptr+1
POP_AL
POP_AH
RET

######
# Pop a byte from the heap and discard it
:heap_pop_byte
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Pop a word from the heap and discard it
:heap_pop_word
PUSH_DH
PUSH_DL
LD_DH  $heap_ptr
LD_DL  $heap_ptr+1
DECR_D
DECR_D
ST_DH  $heap_ptr
ST_DL  $heap_ptr+1
POP_DL
POP_DH
RET

######
# Push all registers onto the heap
:heap_push_all
PUSH_DH
PUSH_DL
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
# push A, B, C onto heap using D register
# for incrementing address.
INCR_D
ALUOP_ADDR_D    %A%+%AH%
INCR_D
ALUOP_ADDR_D    %A%+%AL%
INCR_D
ALUOP_ADDR_D    %B%+%BH%
INCR_D
ALUOP_ADDR_D    %B%+%BL%
INCR_D
STA_D_CH
INCR_D
STA_D_CL
# To push D onto heap we need to save
# the heap pointer and reload it into C
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
POP_DL
POP_DH
PUSH_CH
PUSH_CL
LD_CH   $heap_ptr
LD_CL   $heap_ptr+1
INCR_C
STA_C_DH
INCR_C
STA_C_DL
ST_CH   $heap_ptr
ST_CL   $heap_ptr+1
POP_CL
POP_CH
RET

######
# Pop all registers from the heap
:heap_pop_all
LD_DH   $heap_ptr
LD_DL   $heap_ptr+1
# Pop DL, DH, CL, CH first, putting them in the stack
LDA_D_AL
ALUOP_PUSH %A%+%AL% # push heap DL onto stack
DECR_D
LDA_D_AL
ALUOP_PUSH %A%+%AL% # push heap DH onto stack
DECR_D
LDA_D_AL
ALUOP_PUSH %A%+%AL% # push heap CL onto stack
DECR_D
LDA_D_AL
ALUOP_PUSH %A%+%AL% # push heap CH onto stack
DECR_D
# The rest can pop directly into their destinations
LDA_D_BL
DECR_D
LDA_D_BH
DECR_D
LDA_D_AL
DECR_D
LDA_D_AH
DECR_D
# Save the new heap pointer
ST_DH   $heap_ptr
ST_DL   $heap_ptr+1
# Now pop C and D off the stack
POP_CH
POP_CL
POP_DH
POP_DL
RET

