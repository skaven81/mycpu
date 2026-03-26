---
name: ody-cpu
description: Wire Wrap Odyssey CPU architecture reference. Use when writing assembly or C code for the Odyssey CPU, looking up register names, ALU operations, ALUOP16 instructions, status flag behavior, or the stack/heap architecture and calling convention.
version: 1.0.0
---

# Odyssey CPU Architecture Reference

## Registers

| Register | Width | Notes |
|----------|-------|-------|
| A (AH, AL) | 8-bit each | ALU input. Can ONLY write to bus through ALU (use identity op). MOV from C/D to A exists (e.g. `MOV_CH_AH`). |
| B (BH, BL) | 8-bit each | ALU input. Same ALU-only write constraint as A. MOV from C/D to B exists (e.g. `MOV_DL_BL`). |
| C (CH, CL) | 16-bit | Hardware INCR/DECR without ALU. Used as address pointer. Can write to bus directly. |
| D (DH, DL) | 16-bit | Hardware INCR/DECR. Saved/restored during interrupts. Can write to bus directly. |
| SP | 8-bit | Stack at 0xBF00-0xBFFF (256 bytes). |
| TAH, TAL, TD | 8-bit | Microcode scratchpad only. Interrupts clobber these -- must MASKINT before direct use. |
| Status | 3 flags | Z (zero), E (equal), O (overflow/carry-out). Backup in bits [7:6:5] for interrupts. |

**CRITICAL - Status Flag Behavior:**
- **Z (zero)** and **O (overflow/carry-out)** flags are computed by the ALU itself based on the result
- **E (equal)** flag is computed OUTSIDE the ALU by XOR gates comparing the two input operands (A-side vs B-side)
- The E flag is set when the two operands are equal, regardless of the ALU operation or result
- Example: `ALUOP_FLAGS %A&B%+%AL%+%BH%` sets E flag if AL==BH (operand comparison), Z flag if (AL&BH)==0 (result comparison)

C/D increment/decrement: `INCR_C`, `DECR_C`, `INCR_D`, `DECR_D`, `INCR4_D`, `INCR8_D`, `DECR4_D`, `DECR8_D`.

## ALU Operations

Register selectors: `%AH%` (0x40), `%AL%` (0x00), `%BH%` (0x80), `%BL%` (0x00), `%Cin%` (0x20). **All ALU instructions must include register selection macros**, even for low registers, for readability.

**Critical:** ALU operations have an "A" side and a "B" side. The "A" side can only select from AH or AL; the B side can only select from BH or BL. It is not possible to subtract AH-AL using %A-B%. That is why there are complementary operations for %A-B% and %B-A% as well as separate %A% and %B% identity operations. %AL% and %BL% macros are both zero (default state of the ALU). %AH% and %BH% set bits to select the high register for that side.

| Opcode | Macro | Description |
|--------|-------|-------------|
| 0x00 | `%zero%` | Constant 0 |
| 0x01 | `%one%` | Constant 1 |
| 0x02 | `%negone%` | Constant 0xFF (-1) |
| 0x03 | `%A%` | Identity A (add `%AH%` for high reg) |
| 0x04 | `%B%` | Identity B (add `%BH%` for high reg) |
| 0x05 | `%A+B%` | Add A+B |
| 0x06 | `%A-B%` | Subtract A-B |
| 0x07 | `%B-A%` | Subtract B-A |
| 0x08 | `%A-1%` | Decrement A |
| 0x09 | `%B-1%` | Decrement B |
| 0x0a | `%A_clrmsb%` | Clear MSB of A |
| 0x0b-0x0d | `%A+B_signed%`, `%A-B_signed%`, `%B-A_signed%` | Signed arithmetic |
| 0x0e-0x0f | `%-A_signed%`, `%-B_signed%` | Signed negation |
| 0x10-0x16 | `%~A%`, `%~B%`, `%A&B%`, `%A\|B%`, `%AxB%`, `%A&~B%`, `%B&~A%` | Logic |
| 0x17-0x18 | `%Amsb%`, `%Bmsb%` | Extract MSB |
| 0x19-0x1c | `%A<<1%`, `%A>>1%`, `%B<<1%`, `%B>>1%` | Logical shifts |
| 0x1d-0x1e | `%A*2%`, `%A/2%` | Arithmetic shift left/right |
| 0x1f | `%Amsb^Bmsb%` | XOR of MSBs |

Add `%Cin%` (0x20) for +1 variants (e.g., `%A+1%` = 0x23, `%A+B+1%` = 0x25).

## ALUOP16 Instructions (16-bit ALU)

Perform 16-bit operations using the 8-bit ALU in two steps: operate on low byte, then conditionally operate on high byte based on the resulting flags.

**Unconditional (2 operands)**: `ALUOP16_{A,B} lo_op hi_op` -- lo_op stores to low reg, hi_op stores to high reg.

**Conditional (3 operands)** -- lo_op executes first, sets flags, then flag selects which hi_op runs:
- `ALUOP16O_{A,B,FLAGS}` -- checks **O** (overflow) flag
- `ALUOP16E_{A,B,FLAGS}` -- checks **E** (equal) flag
- `ALUOP16Z_{A,B,FLAGS}` -- checks **Z** (zero) flag

Format: `ALUOP16O_A lo_op hi_op_if_set hi_op_if_clear`. The `_FLAGS` variants only set flags without writing registers.

**Key insight**: the low byte operation's flags inform high byte handling. E.g., 16-bit add: if low byte overflows, high byte add includes carry (+1); if not, normal high byte add.

### Predefined ALUOP16 macros (from `asm_macros`)

Each macro expands to 3 values (the operand tuple). Use with `ALUOP16O_` for arithmetic/shifts:

| Macro | Operation |
|-------|-----------|
| `%ALU16_A+1%` / `%ALU16_B+1%` | 16-bit increment |
| `%ALU16_A-1%` / `%ALU16_B-1%` | 16-bit decrement |
| `%ALU16_A+B%` | 16-bit A = A + B |
| `%ALU16_A-B%` / `%ALU16_B-A%` | 16-bit subtraction |
| `%ALU16_sA+B%` / `%ALU16_sA-B%` / `%ALU16_sB-A%` | Signed 16-bit arithmetic |
| `%ALU16_A<<1%` / `%ALU16_B<<1%` | 16-bit left shift |

Use with `ALUOP16E_FLAGS` or `ALUOP16Z_FLAGS` for comparisons:

| Macro | Operation |
|-------|-----------|
| `%ALU16_Azero%` / `%ALU16_Bzero%` | Test == 0 (Z flag) |
| `%ALU16_A\|Beq%` | Test A == B (E flag) |

### ALUOP16 examples

```asm
ALUOP16O_A %ALU16_A+B%              # A = A + B (16-bit)
ALUOP16O_A %ALU16_A+1%              # A++ (16-bit)
ALUOP16E_FLAGS %ALU16_A|Beq%        # test A == B (flags only)
ALUOP16Z_FLAGS %ALU16_Azero%        # test A == 0 (flags only)
ALUOP16_A %A|B% %A|B%+%AH%+%BH%    # unconditional OR (manual operands)
```

## Dual Stack/Heap Architecture

Two separate LIFO structures:

**Hardware Stack (0xBF00-0xBFFF, 256 bytes)** -- register preservation and control flow only:
- `CALL`/`RET` push/pop return addresses
- `ALUOP_PUSH %A%+%AL%` / `POP_AL` save/restore A/B registers
- `PUSH_CH` / `POP_CH` save/restore C/D half-registers

**Software Heap (0xB000-0xB9FF, 2.5 KiB)** -- parameter passing between functions:
- `:heap_push_AL`, `:heap_push_A`, `:heap_push_D` -- push args before calling
- `:heap_pop_AL`, `:heap_pop_A` -- pop results after calling
- `:heap_push_all` / `:heap_pop_all` -- bulk save/restore all register pairs
- `:heap_advance_AL` / `:heap_retreat_AL` -- allocate/deallocate frames (C compiler)
- Grows upward from 0xB000. Pointer in `$heap_ptr`.

## Calling Convention

- **Simple functions**: inputs/outputs in specific registers (AL for byte, A for word, C/D for addresses)
- **Complex functions**: caller pushes args to heap, function pops internally. Args pushed in documented order (popped LIFO inside function).
- **Callee-save**: virtually every function saves/restores ALL registers it modifies using PUSH/POP pairs. Caller can assume registers are preserved.
- **IRQ handler patching**: functions save current IRQ vector on stack, install temporary handler, restore after. Handlers communicate with main loop by modifying registers directly (e.g., spinlocks).
