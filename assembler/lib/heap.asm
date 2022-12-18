# vim: syntax=asm-mycpu

# Software heap, generally used for storing extra subroutine arguments

######
# Initialize the heap
:heap_init
ST 0xbe00 0x00
RET

######
# Push a register value onto the heap from AL
#
# Input:
#   AL - byte to push onto the heap
:heap_push_AL
PUSH_DH
PUSH_DL
LDI_DH 0xbe     # heap base address
LD_DL  0xbe00   # heap offset is stored in first byte
INCR_D          # move to next address in the heap
ALUOP_ADDR_D %A%+%AL%   # Write AL to that address
ST_DL  0xbe00   # update offset
POP_DL
POP_DH
RET

######
# Pop a value from the heap into AL
:heap_pop_AL
PUSH_DH
PUSH_DL
LDI_DH 0xbe     # heap base address
LD_DL  0xbe00   # heap offset is stored in first byte
LDA_D_AL        # load byte @ D into AL
DECR_D          # move to previous address in the heap
ST_DL  0xbe00   # update offset
POP_DL
POP_DH
RET

######
# Push 16-bit word from A onto the heap
:heap_push_A
PUSH_DH
PUSH_DL
LDI_DH 0xbe     # heap base address
LD_DL  0xbe00   # heap offset is stored in first byte
INCR_D          # move to next address in the heap
ALUOP_ADDR_D %A%+%AH%   # Write AH to that address
INCR_D          # move to next address in the heap
ALUOP_ADDR_D %A%+%AL%   # Write AL to that address
ST_DL  0xbe00   # update offset
POP_DL
POP_DH
RET

######
# Pop a word from the heap into A
:heap_pop_A
PUSH_DH
PUSH_DL
LDI_DH 0xbe     # heap base address
LD_DL  0xbe00   # heap offset is stored in first byte
LDA_D_AL        # load byte @ D into AL
DECR_D          # move to previous address in the heap
LDA_D_AH        # load byte @ D into AH
DECR_D          # move to previous address in the heap
ST_DL  0xbe00   # update offset
POP_DL
POP_DH
RET


