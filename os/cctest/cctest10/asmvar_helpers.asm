# vim: syntax=asm-mycpu
# cctest10 helpers: a hand-written VAR that main.c reaches through
# `#pragma asmvar cct10_asmword`, plus accessors so the test can prove
# C and assembly agree on its address.

VAR global word $cct10_asmword

# uint16_t cct10_asm_read(void) - returns $cct10_asmword
:cct10_asm_read
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LD_AH $cct10_asmword
LD_AL $cct10_asmword+1
CALL :heap_push_A
POP_AL
POP_AH
RET

# void cct10_asm_write(uint16_t v) - stores v into $cct10_asmword
:cct10_asm_write
PUSH_CH
PUSH_CL
CALL :heap_pop_C
ST_CH $cct10_asmword
ST_CL $cct10_asmword+1
POP_CL
POP_CH
RET

# A data label named the way the compiler names C globals: main.c reaches
# it with a plain `extern` (no pragma), exactly like a global in another .c
# uint16_t cct10_asm_read_label(void) - returns :var_cct10_asmlabel
:cct10_asm_read_label
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
LD_AH :var_cct10_asmlabel
LD_AL :var_cct10_asmlabel+1
CALL :heap_push_A
POP_AL
POP_AH
RET

:var_cct10_asmlabel "\0\0"
