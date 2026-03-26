---
name: ody-asm
description: Wire Wrap Odyssey assembly language patterns and debugging reference. Use when writing, reviewing, or debugging Odyssey assembly code, looking up callee-save patterns, heap parameter passing, comparison/branch patterns, bulk memory ops, or when inserting trace calls to debug assembly.
version: 1.0.0
---

# Odyssey Assembly Patterns Reference

## Key Assembly Patterns

```asm
# ALU ops (register selectors always required)
ALUOP_AL %A+B%+%AL%+%BL%       # AL + BL -> AL
ALUOP_AL %A+B%+%AH%+%BH%       # AH + BH -> AL
ALUOP_DL %A%+%AL%               # copy AL to DL (A/B write through ALU only)
ALUOP_ADDR_D %A%+%AH%           # copy AH to memory at address in D
ALUOP_FLAGS %A-B%+%AL%+%BL%     # compare AL vs BL (flags only, no CMP instruction)

# Callee-save prolog/epilog (restore in REVERSE order)
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
# ... body ...
POP_CL
POP_CH
POP_AL
POP_AH
RET

# Heap parameter passing
CALL :heap_push_AL              # push arg
CALL :some_function             # function pops args internally
CALL :heap_pop_AL               # pop return value

# Memory/variables
LDI_C 0x4000                    # 16-bit address into C
LDA_C_AL                        # load byte at [C] into AL
ST $my_var 0x42                 # store immediate to variable
LD_AL $my_var                   # load variable
LD16_A $my_word_var             # load 16-bit variable into AH:AL
```

All instructions are left-justified in actual code. Indentation above is for readability only.

## Important Code Patterns

- **No CMP instruction**: compare via subtraction (`ALUOP_FLAGS %A-B%`) and check flags. **O flag for subtraction: O=1 means underflow (A < B), O=0 means no underflow (A >= B).** Use `JO` to branch when A < B, `JNO` to branch when A >= B. E flag compares operands directly (use any ALU op, even AND/OR).
- **No hardware multiply/divide**: software in `math.asm` (`:mul16`, `:div8`). Multiply-by-10 = `8a + 2a` via shifts.
- **MEMCPY/MEMFILL count is N-1**: AL=0 copies 1 unit, AL=255 copies 256.
- **Hardware bulk ops**: `MEMCPY_C_D`, `MEMCPY4_C_D`, `MEMFILL4_C_PEEK`, `MEMFILL4_C_I` auto-increment C (and D for copies).
- **JMP for tail calls**: preserves caller's return address on stack.
- **MASKINT/UMASKINT**: required around transfer register (TAH/TAL/TD) use, since interrupts clobber them. Heap functions do this internally.
- **256-byte circular buffers**: keyboard (0xBE00) and UART (0xBD00) -- only low byte of pointers changes for natural wraparound.
- **Display memory is directly manipulated**: terminal input works on display memory, not a separate buffer. `:cursor_mark_getstring` copies from display to buffer.
- **Timer values are BCD**: DS1511Y RTC uses BCD (0x75 = 75, not 117).
- **Shared error labels**: related functions share error-exit labels when stack frames match.

## Troubleshooting Assembly Code

Some static analysis of assembly is reasonable. But once the problem gets complex, it's better to take a step back and collect additional information through tracing. Any .asm file may have `:trace_N` (`:trace_0`, `:trace_1`, etc.) calls inserted at strategic locations. See also `os/bios/lib/trace.asm`. For example:

```asm
CALL :trace_0  # comment about what we expect to see here
```

The trace functions are entirely idempotent -- they do not cause any changes to any registers or memory (aside from printing the trace data to the console). Every trace call prints to the console:
- an identifier, `DEBUG0`, `DEBUG1` ... `DEBUG7`
- the memory address where the CALL to trace was initiated
- The current values stored in all four primary registers (A, B, C, D)
- The current extended memory pages used by 0xe... and 0xd...

When debugging code generated from C, first `make <c-file-basename>.asm` to generate the assembly file, then directly edit the generated .asm file to insert trace calls. Then `make` to assemble the output binary. As long as you don't edit the .c file, you can keep editing the .asm file to move or add traces, and `make` will keep regenerating the binary without clobbering your traces.

Ask the owner to run and report trace output back.
