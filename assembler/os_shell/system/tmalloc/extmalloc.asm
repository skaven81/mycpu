# vim: syntax=asm-mycpu

# extpage_init - setup the extended memory page stacks
:extpage_init
VAR global 64 $extpage_d_stack
VAR global 64 $extpage_e_stack
VAR global word $extpage_d_ptr
VAR global word $extpage_e_ptr
ST16 $extpage_d_ptr $extpage_d_stack
ST16 $extpage_e_ptr $extpage_e_stack
RET

# extpage_d_push - switch to a new D page
# input: byte pushed to heap
# output: %d_page% set to byte on heap
:extpage_d_push
PUSH_CL
PUSH_DH
PUSH_DL
# store the current D page on the stack
LD_CL %d_page%                      # get the current D page into CL
LD_DH $extpage_d_ptr                # get the current D page stack pointer into D
LD_DL $extpage_d_ptr+1              # |
STA_D_CL                            # store the current D page at that address
INCR_D                              # move to next stack entry
ST_DH $extpage_d_ptr                # store the new stack pointer value back to RAM
ST_DL $extpage_d_ptr+1              # |
# set the current D page to the provided value
CALL :heap_pop_CL                   # new D page into CL
ST_CL %d_page%                      # set new D page
POP_DL
POP_DH
POP_CL
RET

# extpage_d_pop - restore a previous D page
# input: none
# output: %d_page% set to value on top of stack
:extpage_d_pop
ALUOP_PUSH %A%+%AL%
PUSH_DH
PUSH_DL
# set up the stack pointer in D, and move to
# previous stack item
LD_DH $extpage_d_ptr
LD_DL $extpage_d_ptr+1
DECR_D
# get this value in CL, then into %d_page%
LDA_D_AL
ALUOP_ADDR %A%+%AL% %d_page%
# store the new stack pointer
ST_DH $extpage_d_ptr
ST_DL $extpage_d_ptr+1
POP_DL
POP_DH
POP_AL
RET

# extpage_e_push - switch to a new E page
# input: byte pushed to heap
# output: %e_page% set to byte on heap
:extpage_e_push
PUSH_CL
PUSH_DH
PUSH_DL
# store the current E page on the stack
LD_CL %e_page%                      # get the current E page into CL
LD_DH $extpage_e_ptr                # get the current E page stack pointer into D
LD_DL $extpage_e_ptr+1              # |
STA_D_CL                            # store the current E page at that address
INCR_D                              # move to next stack entry
ST_DH $extpage_e_ptr                # store the new stack pointer value back to RAM
ST_DL $extpage_e_ptr+1              # |
# set the current E page to the provided value
CALL :heap_pop_CL                   # new E page into CL
ST_CL %e_page%                      # set new E page
POP_DL
POP_DH
POP_CL
RET

# extpage_e_pop - restore a previous E page
# input: none
# output: %e_page% set to value on top of stack
:extpage_e_pop
ALUOP_PUSH %A%+%AL%
PUSH_DH
PUSH_DL
# set up the stack pointer in D, and move to
# previous stack item
LD_DH $extpage_e_ptr
LD_DL $extpage_e_ptr+1
DECR_D
# get this value in CL, then into %e_page%
LDA_D_AL
ALUOP_ADDR %A%+%AL% %e_page%
# store the new stack pointer
ST_DH $extpage_e_ptr
ST_DL $extpage_e_ptr+1
POP_DL
POP_DH
POP_AL
RET

# extpage_d_push_zero - save the current D page value and set it to zero.
# equivalent to doing an `extpage_d_push` with value zero
:extpage_d_push_zero
PUSH_CL
LDI_CL 0x00
CALL :heap_push_CL
CALL :extpage_d_push
POP_CL
RET

# extpage_e_push_zero - save the current E page value and set it to zero.
# equivalent to doing an `extpage_e_push` with value zero
:extpage_e_push_zero
PUSH_CL
LDI_CL 0x00
CALL :heap_push_CL
CALL :extpage_e_push
POP_CL
RET

