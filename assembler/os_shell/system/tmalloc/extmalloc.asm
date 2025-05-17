# vim: syntax=asm-mycpu

# extzero_d - save the current e-page value and set it to zero.
:extzero_d
VAR global byte $extzero_d
PUSH_CL
LD_CL %d_page%
ST_CL $extzero_d
ALUOP_ADDR %zero% %d_page%
POP_CL
RET

# extzero_d_restore - set %d_page% back to the saved value
:extzero_d_restore
PUSH_CL
LD_CL $extzero_d
ST_CL %d_page%
POP_CL
RET

# extzero_e - save the current e-page value and set it to zero.
:extzero_e
VAR global byte $extzero_e
PUSH_CL
LD_CL %e_page%
ST_CL $extzero_e
ALUOP_ADDR %zero% %e_page%
POP_CL
RET

# extzero_e_restore - set %e_page% back to the saved value
:extzero_e_restore
PUSH_CL
LD_CL $extzero_e
ST_CL %e_page%
POP_CL
RET
