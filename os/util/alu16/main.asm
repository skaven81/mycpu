# vim: syntax=asm-mycpu

:main

LDI_C .test_str

# ALUOP16_A - unconditional OR
LDI_A 0xfa00
LDI_B 0x005f
ALUOP16_A %A|B% %A|B%+%AH%+%BH%
CALL :heap_push_A
LDI_A 0xfa5f
CALL :heap_push_A
LDI_A .test1
CALL :heap_push_A
CALL :printf

# ALUOP16_B - unconditional OR
LDI_A 0x5500
LDI_B 0xf0af
ALUOP16_B %A|B% %A|B%+%AH%+%BH%
CALL :heap_push_B
LDI_A 0xf5af
CALL :heap_push_A
LDI_A .test2
CALL :heap_push_A
CALL :printf

# ALUOP16O_A - add, no overflow
LDI_A 0x0f0f
LDI_B 0x0101
ALUOP16O_A %ALU16_A+B%
CALL :heap_push_A
LDI_A 0x1010
CALL :heap_push_A
LDI_A .test3
CALL :heap_push_A
CALL :printf

# ALUOP16O_B - add, no overflow
LDI_A 0x0f0f
LDI_B 0x0101
ALUOP16O_B %ALU16_A+B%
CALL :heap_push_B
LDI_A 0x1010
CALL :heap_push_A
LDI_A .test4
CALL :heap_push_A
CALL :printf

# ALUOP16O_A - add, overflow
LDI_A 0xf0ff
LDI_B 0x010f
ALUOP16O_A %ALU16_A+B%
CALL :heap_push_A
LDI_A 0xf20e
CALL :heap_push_A
LDI_A .test5
CALL :heap_push_A
CALL :printf

# ALUOP16O_B - add, overflow
LDI_A 0xf0ff
LDI_B 0x010f
ALUOP16O_B %ALU16_A+B%
CALL :heap_push_B
LDI_A 0xf20e
CALL :heap_push_A
LDI_A .test6
CALL :heap_push_A
CALL :printf

# ALUOP16O_A - shift, no overflow
LDI_A 0xf04f
ALUOP16O_A %A<<1% %A<<1%+%AH%+%Cin% %A<<1%+%AH%
CALL :heap_push_A
LDI_A 0xe09e
CALL :heap_push_A
LDI_A .test7
CALL :heap_push_A
CALL :printf

# ALUOP16O_B - shift, overflow
LDI_B 0xf08f
ALUOP16O_B %B<<1% %B<<1%+%BH%+%Cin% %B<<1%+%BH%
CALL :heap_push_B
LDI_A 0xe11e
CALL :heap_push_A
LDI_A .test8
CALL :heap_push_A
CALL :printf

# ALUOP16E_FLAGS - equal
LDI_A 0xf04f
LDI_B 0xf04f
ALUOP16E_FLAGS %A|B% %A|B%+%AH%+%BH% %A|B%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x02
CALL :heap_push_AL
LDI_A .test9
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

# ALUOP16E_FLAGS - not equal lo
LDI_A 0xf04f
LDI_B 0xf040
ALUOP16E_FLAGS %A|B% %A|B%+%AH%+%BH% %A|B%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x00
CALL :heap_push_AL
LDI_A .test10
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

# ALUOP16E_FLAGS - not equal hi
LDI_A 0xf04f
LDI_B 0x804f
ALUOP16E_FLAGS %A|B% %A|B%+%AH%+%BH% %A|B%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x00
CALL :heap_push_AL
LDI_A .test11
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

# ALUOP16Z_FLAGS - zero
LDI_A 0x0000
ALUOP16Z_FLAGS %A% %A%+%AH% %A%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x01
CALL :heap_push_AL
LDI_A .test12
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

# ALUOP16Z_FLAGS - non zero lo
LDI_A 0x0001
ALUOP16Z_FLAGS %A% %A%+%AH% %A%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x00
CALL :heap_push_AL
LDI_A .test13
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

# ALUOP16Z_FLAGS - non zero hi
LDI_A 0x0100
ALUOP16Z_FLAGS %A% %A%+%AH% %A%
STATUS_AL
CALL :heap_push_AL
LDI_AL 0x00
CALL :heap_push_AL
LDI_A .test14
CALL :heap_push_A
LDI_C .test_str8
CALL :printf

RET

.test1 "ALUOP16_A A|B\0"
.test2 "ALUOP16_B A|B\0"
.test3 "ALUOP16O_A A+B no overflow\0"
.test4 "ALUOP16O_B A+B no overflow\0"
.test5 "ALUOP16O_A A+B w/ overflow\0"
.test6 "ALUOP16O_B A+B w/ overflow\0"
.test7 "ALUOP16O_A A<<1 no overflow\0"
.test8 "ALUOP16O_A A<<1 w/ overflow\0"
.test9 "ALUOP16E_FLAGS equal\0"
.test10 "ALUOP16E_FLAGS not equal lo\0"
.test11 "ALUOP16E_FLAGS not equal hi\0"
.test12 "ALUOP16Z_FLAGS zero\0"
.test13 "ALUOP16Z_FLAGS nonzero lo\0"
.test14 "ALUOP16Z_FLAGS nonzero hi\0"
.test_str "%s: exp: %X act: %X\n\0"
.test_str8 "%s: exp: %x act: %x\n\0"

