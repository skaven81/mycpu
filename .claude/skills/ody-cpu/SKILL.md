---
name: ody-cpu
description: Wire Wrap Odyssey CPU architecture reference. Use when writing assembly or C code for the Odyssey CPU - covers the programming model (how it differs from x86/6502/Z80), register roles and asymmetry, ALU operations, ALUOP16 instructions, status flag behavior, and the stack/heap architecture and calling convention.
version: 2.0.0
---

# Odyssey CPU Architecture Reference

## The programming model: unlearn x86, 6502, and Z80

The Odyssey resembles NO architecture you have trained on. Idioms transferred
from accumulator machines (6502, Z80) or register machines (x86) produce
code that is wrong, or correct but 2-3x longer than it should be. There is no
CMP, no general `ADD reg,reg`, no MOV-anywhere, no indexed addressing modes.

**The ALU is the machine's data crossbar.** A single `ALUOP_*` instruction
selects one of 32 operations on the A-side and B-side operands AND delivers
the result anywhere. The mnemonic suffix only picks the destination:

| Destination | Instruction | Notes |
|-------------|-------------|-------|
| Any register | `ALUOP_{AH,AL,BH,BL,CH,CL,DH,DL} $op` | This is also how A/B values reach C/D |
| Absolute memory | `ALUOP_ADDR $op @addr` | Op comes FIRST, then address |
| Memory at pointer | `ALUOP_ADDR_{A,B,C,D} $op` | Compute + store, one instruction |
| Peripheral register | `ALUOP_ADDR_SLOW $op @addr` | The only correct ALU-to-peripheral path |
| Hardware stack | `ALUOP_PUSH $op` | The ONLY way to push A/B |
| Flags only | `ALUOP_FLAGS $op` | Result discarded |

"Compute into a register, then store it" is an x86 habit that wastes an
instruction here: `ALUOP_ADDR_C %A+B%+%AL%+%BL%` adds AL+BL and stores the
sum at [C] in ONE instruction. Writing an ALU result to a peripheral is
`ALUOP_ADDR_SLOW %A%+%AL% 0xC080` -- never `ALUOP_PUSH` followed by
`ST_SLOW_POP`. Before emitting any compute-then-move pair, check whether one
ALUOP with the right destination does both.

**Every ALUOP latches the status flags** (Z, E, O), regardless of
destination. A decrement that lands in a register has already set Z -- a
following `ALUOP_FLAGS` on the same value is a wasted instruction.

## Registers and their asymmetry

| Register | Width | Role |
|----------|-------|------|
| A (AH, AL) | 8+8 | ALU operand. Can ONLY reach the bus through the ALU (identity op `%A%`). |
| B (BH, BL) | 8+8 | ALU operand. Same constraint as A. |
| C (CH, CL) | 16 | Pointer. Writes to bus directly. Hardware `INCR_C`/`DECR_C`. |
| D (DH, DL) | 16 | Pointer. Hardware INCR/DECR incl. `INCR4_D`/`INCR8_D`. Saved during interrupts. |
| SP | 8 | Hardware stack at 0xBF00-0xBFFF (256 bytes). |
| TAH, TAL, TD | 8 | Microcode scratch. Interrupts clobber them -- MASKINT around direct use. |
| Status | 3 flags | Z (zero), E (equal), O (overflow/carry). Backup bits [7:6:5] for interrupts. |

Data-movement asymmetries that trip up every newcomer:

- **A/B -> anywhere**: through the ALU only (`ALUOP_DL %A%+%AL%` copies AL
  to DL; `ALUOP_ADDR_C %A%+%AL%` stores AL at [C]).
- **C/D -> A/B/T**: dedicated `MOV_<SRC>_<DST>` instructions, source named
  first: `MOV_CH_AH`, `MOV_DL_BL`, `MOV_CL_TD`. There are NO MOVs in the
  other direction and none between A and B.
- **Math on C/D**: the ALU cannot read C/D. Copy to A/B via MOV, compute,
  write back via `ALUOP_CH/CL/DH/DL`. For plain +1/-1 stepping use the
  hardware `INCR_C`/`DECR_D` etc. instead (no ALU, no flags).
- **A-side/B-side selection**: the ALU's A input can only be AH or AL; the B
  input only BH or BL. You cannot compute AH-AL in one op -- that is why
  complementary ops exist (`%A-B%` and `%B-A%`, `%A%` and `%B%`).

**CRITICAL - Status Flag Behavior:**
- **Z (zero)**: set when the full 8-bit result is zero.
- **E (equal)**: computed OUTSIDE the ALU by XOR gates comparing the two
  SELECTED input operands (e.g. AL vs BH if those selectors are used) -- E
  is set when the operands are equal regardless of the operation.
  `ALUOP_FLAGS %A&B%+%AL%+%BH%` sets E if AL==BH (operand comparison) and Z
  if (AL&BH)==0 (result comparison).
- **O (overflow)**: the high ALU slice's carry-out. Its meaning depends on
  the operation -- verified against `alu/four_bit_alu.py`, the canonical
  source:

| Operation class | O flag meaning |
|-----------------|----------------|
| Unsigned add (`%A+B%`, `%A+1%`, ...) | Carry out of bit 7 (result wrapped past 0xFF) |
| Unsigned subtract (`%A-B%`, `%A-1%`, ...) | Borrow: result wrapped below 0 (for `%A-B%`: A < B) |
| Signed add/sub (`_signed` ops) | Signed overflow (result sign inconsistent with operand signs) |
| Signed negate (`%-A_signed%`) | Set only when negating -128 |
| Logical shift left (`%A<<1%`, `%B<<1%`) | The bit shifted out of the MSB |
| Logical shift right (`%A>>1%`, `%B>>1%`) | Always 0 -- **the shifted-out LSB is LOST** (mask bit 0 first if you need it) |
| Arithmetic shift left (`%A*2%`) | Sign changed (signed overflow), NOT the shifted-out bit |
| Arithmetic shift right (`%A/2%`) | Always 0 (shifted-out LSB lost) |
| Logic (`%A&B%`, `%A\|B%`, `%AxB%`, `%~A%`, ...) | Always 0 |
| `%Amsb%`/`%Bmsb%`/`%Amsb^Bmsb%` | Always 0 (use Z: set iff tested bit clear / signs match) |
| Constants (`%zero%`, `%one%`, `%negone%`) | Always 0 |

- **Unsigned comparison** (no CMP exists): `ALUOP_FLAGS %A-B%+%AL%+%BL%`
  then `JO` (A < B) or `JNO` (A >= B). For pure equality use E with any op:
  `JEQ`/`JNE`.
- **Signed comparison**: O after `%A-B_signed%` means signed OVERFLOW, not
  less-than. Compare signed values by cases -- this is what `%Amsb^Bmsb%`
  exists for:

```asm
:main
ALUOP_FLAGS %Amsb^Bmsb%+%AL%+%BL%   # Z=1: same sign, Z=0: signs differ
JZ .same_sign
ALUOP_FLAGS %Amsb%+%AL%             # signs differ: negative one is smaller
JNZ .a_less_than_b                  # Z=0 -> AL's MSB set -> AL negative -> AL < BL
JMP .a_greater_equal
.same_sign
ALUOP_FLAGS %A-B%+%AL%+%BL%         # same sign: unsigned compare is valid
JO .a_less_than_b
.a_greater_equal
RET
.a_less_than_b
RET
```

**The ALU is a lookup table, and `alu/` is its canonical source.** When you
need to know exactly what an ALU op does to the result or flags, read
`alu/four_bit_alu.py` (per-op logic, E simulated there for completeness) and
`alu/eight_bit_alu.py` (how the two 4-bit slices chain; the O status flag is
the high slice's cout_msb, and the low slice's cout_lsb is disconnected).
`alu/alu_repl.py` lets you interactively evaluate any op. The ALU is also
MUTABLE -- same cost tier as a microcode change (EEPROM reflash, docs,
tooling) -- so if a new ALU operation would massively simplify a problem,
proposing one to the owner is a legitimate option.

## ALU Operations

Register selectors: `%AH%` (0x40), `%AL%` (0x00), `%BH%` (0x80), `%BL%`
(0x00), `%Cin%` (0x20). **Always write the selector macros, even for the
low registers** (they are 0x00 but the convention keeps code readable).

| Opcode | Macro | Description |
|--------|-------|-------------|
| 0x00-0x02 | `%zero%`, `%one%`, `%negone%` | Constants 0, 1, 0xFF |
| 0x03 | `%A%` | Identity A (add `%AH%` for high reg) |
| 0x04 | `%B%` | Identity B (add `%BH%` for high reg) |
| 0x05 | `%A+B%` | Add |
| 0x06 / 0x07 | `%A-B%` / `%B-A%` | Subtract |
| 0x08 / 0x09 | `%A-1%` / `%B-1%` | Decrement |
| 0x0a | `%A_clrmsb%` | Clear MSB of A |
| 0x0b-0x0d | `%A+B_signed%`, `%A-B_signed%`, `%B-A_signed%` | Signed arithmetic |
| 0x0e-0x0f | `%-A_signed%`, `%-B_signed%` | Signed negation |
| 0x10-0x16 | `%~A%`, `%~B%`, `%A&B%`, `%A\|B%`, `%AxB%`, `%A&~B%`, `%B&~A%` | Logic |
| 0x17-0x18 | `%Amsb%`, `%Bmsb%` | Extract MSB |
| 0x19-0x1c | `%A<<1%`, `%A>>1%`, `%B<<1%`, `%B>>1%` | Logical shifts |
| 0x1d-0x1e | `%A*2%`, `%A/2%` | Arithmetic shift left/right |
| 0x1f | `%Amsb^Bmsb%` | XOR of MSBs |

Adding `%Cin%` (0x20) gives the +1 variants. Predefined in `asm_macros`:
`%A+1%` (0x23), `%B+1%` (0x24), `%A+B+1%`, `%A-B-1%`, `%B-A-1%`, `%A-2%`,
`%B-2%`, and signed forms `%A+B+1_signed%`, `%A-B-1_signed%`,
`%B-A-1_signed%`. **These already include `%Cin%` -- do not add it again.**
Display-color helpers also exist: `%A_setmsb%`/`%A_setblink%` (same op, sets
bit 7) and `%A_clrmsb%`/`%A_clrblink%`. When in doubt,
`assembler/asm_macros` is the authoritative list.

## ALUOP16 Instructions (16-bit ALU)

Perform 16-bit operations with the 8-bit ALU in one instruction: operate on
the low byte, then operate on the high byte, optionally selecting the high
op based on the low op's flags.

**Unconditional (2 operands)**: `ALUOP16_{A,B} $lo_op $hi_op` -- needs
hand-written operand bytes, e.g. `ALUOP16_A %A|B% %A|B%+%AH%+%BH%`.

**Conditional (3 operands)** -- `ALUOP16{O,E,Z}_{A,B,FLAGS} $lo $hi_if_set
$hi_if_clear`. The `%ALU16_*%` macros expand to all THREE operands and fit
ONLY these conditional forms:

| Macro | Operation | Use with |
|-------|-----------|----------|
| `%ALU16_A+1%` / `%ALU16_B+1%` | 16-bit increment | `ALUOP16O_` |
| `%ALU16_A-1%` / `%ALU16_B-1%` | 16-bit decrement | `ALUOP16O_` |
| `%ALU16_A+B%`, `%ALU16_A-B%`, `%ALU16_B-A%` | 16-bit add/sub | `ALUOP16O_` |
| `%ALU16_sA+B%`, `%ALU16_sA-B%`, `%ALU16_sB-A%` | Signed 16-bit | `ALUOP16O_` |
| `%ALU16_A<<1%` / `%ALU16_B<<1%` | 16-bit left shift | `ALUOP16O_` |
| `%ALU16_Azero%` / `%ALU16_Bzero%` | Test == 0 (Z flag) | `ALUOP16Z_FLAGS` |
| `%ALU16_A\|Beq%` | Test A == B (E flag) | `ALUOP16E_FLAGS` |

```asm
:main
ALUOP16O_A %ALU16_A+B%              # A = A + B (16-bit, carry propagated)
ALUOP16O_A %ALU16_A+1%              # A++ (16-bit)
ALUOP16E_FLAGS %ALU16_A|Beq%        # test A == B (flags only)
ALUOP16Z_FLAGS %ALU16_Azero%        # test A == 0 (flags only)
ALUOP16_A %A|B% %A|B%+%AH%+%BH%     # unconditional OR (manual operands)
```

Never compose the three operand bytes of a 16-bit arithmetic op by hand --
a wrong third operand silently computes the wrong high byte. Use the macros.

## Dual Stack/Heap Architecture

Two separate LIFO structures -- do not conflate them:

**Hardware Stack (0xBF00-0xBFFF, 256 bytes)** -- register preservation and
control flow only:
- `CALL`/`RET` push/pop return addresses
- `ALUOP_PUSH %A%+%AL%` / `POP_AL` save/restore A/B
- `PUSH_CH` / `POP_CH` etc. save/restore C/D halves
- Only 256 bytes: deep recursion is dangerous

**Software Heap (0xF000-0xFFEF, ~4 KiB)** -- parameter passing between
functions via `:heap_push_*` / `:heap_pop_*` (full API in skill **ody-asm**).
Grows upward; pointer in `$heap_ptr`; no overflow checking.

Both are ordinary main-memory speed. The hardware stack doubles as fast
single-instruction scratch space when registers run short; the heap costs a
CALL plus internal interrupt masking per access. That masking also means
**heap functions must never be called from an ISR** (their `UMASKINT` would
re-enable interrupts inside the handler), and never between your own
`MASKINT`/`UMASKINT` pair.

## Calling Convention

- **Simple functions**: inputs/outputs in registers (AL byte, A word, C/D
  addresses), documented in the function's header comment.
- **Complex functions**: caller heap-pushes args in the documented order,
  callee pops them (LIFO), callee heap-pushes results, caller pops them.
- **Callee-save**: functions save/restore every register they modify with
  hardware-stack PUSH/POP pairs (restore in exact reverse order). Callers
  assume registers are preserved.
- Heap-push a result BEFORE the epilog POPs (the two structures are
  separate); never push a result onto the hardware stack across your own
  POPs -- that shifts every subsequent pop by one.
- **IRQ handler patching**: save the current vector, install a temporary
  handler, restore after. Handlers communicate with the main loop through
  registers/globals directly.
