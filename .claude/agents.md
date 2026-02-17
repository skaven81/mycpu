# Wire Wrap Odyssey - Agent Reference

Custom 8-bit computer built from discrete 7400-series HC logic ICs. NOT a pre-existing architecture (not 6502, Z80, etc.) -- the CPU, instruction set, and toolchain are entirely original.

Website: https://wirewrapodyssey.com (pages at e.g. `wirewrapodyssey.com/arch-alu.html`)
Source: https://github.com/skaven81/mycpu

## Working Style and Constraints

- **You cannot run code to test it.** You have no access to the hardware. Ask the owner to compile, copy to SD card, and test.
- **C preferred over assembly where practical** -- but C output is unoptimized and wasteful of RAM/cycles. Use a judicious mix: assembly for performance/size-critical subroutines, C for complex logic where performance is less important.
- **ROM space is precious** -- 16 KiB EEPROM, ~12 KiB used. New features should be ODY executables on disk, not ROM.
- **Practical over perfect** -- working code first, optimize later. Debug methodically, don't paper over bugs.
- **Future directions**: video playback (Bad Apple), sound chip (OPL-3/YMF262), programmable timer interrupts, games.

## CPU Architecture

- **8-bit data bus, 16-bit address bus**, ~2.2 MHz clock
- **LUT-based ALU**: two AT28C256 EEPROMs (4-bit slices), 32 distinct operations
- **Microcoded**: 4 EEPROMs, 32 control signals/cycle, 15-bit instruction register (8-bit opcode + 3-bit ALU flags + 4-bit sequence counter), up to 16 micro-ops/instruction
- **Big-endian** (ATA/FAT16 data is little-endian, requires byte-order translation)

## Registers

| Register | Width | Notes |
|----------|-------|-------|
| A (AH, AL) | 8-bit each | ALU input. Can ONLY write to bus through ALU (use identity op to move). |
| B (BH, BL) | 8-bit each | ALU input. Same ALU-only write constraint as A. |
| C (CH, CL) | 16-bit | Hardware INCR/DECR without ALU. Used as address pointer. |
| D (DH, DL) | 16-bit | Hardware INCR/DECR. Saved/restored during interrupts. |
| SP | 8-bit | Stack at 0xBF00-0xBFFF (256 bytes). |
| TAH, TAL, TD | 8-bit | Microcode scratchpad only. Interrupts clobber these -- must MASKINT before direct use. |
| Status | 3 flags | Z (zero), E (equal), O (overflow/carry-out). Backup in bits [7:6:5] for interrupts. |

**CRITICAL - Status Flag Behavior:**
- **Z (zero)** and **O (overflow/carry-out)** flags are computed by the ALU itself based on the result
- **E (equal)** flag is computed OUTSIDE the ALU by XOR gates comparing the two input operands (A-side vs B-side)
- The E flag is set when the two operands are equal, regardless of the ALU operation or result
- Example: `ALUOP_FLAGS %A&B%+%AL%+%BH%` sets E flag if AL==BH (operand comparison), Z flag if (AL&BH)==0 (result comparison)

C/D increment/decrement: `INCR_C`, `DECR_C`, `INCR_D`, `DECR_D`, `INCR4_D`, `INCR8_D`, `DECR4_D`, `DECR8_D`.

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

### Calling Convention

- **Simple functions**: inputs/outputs in specific registers (AL for byte, A for word, C/D for addresses)
- **Complex functions**: caller pushes args to heap, function pops internally. Args pushed in documented order (popped LIFO inside function).
- **Callee-save**: virtually every function saves/restores ALL registers it modifies using PUSH/POP pairs. Caller can assume registers are preserved.
- **IRQ handler patching**: functions save current IRQ vector on stack, install temporary handler, restore after. Handlers communicate with main loop by modifying registers directly (e.g., spinlocks).

## Macros

`assembler/asm_macros` defines `%name%` text substitution macros (single-pass replacement). Used for ALU ops, register selectors, peripheral addresses, colors, etc.

## ALU Operations

Register selectors: `%AH%` (0x40), `%AL%` (0x00), `%BH%` (0x80), `%BL%` (0x00), `%Cin%` (0x20). **All ALU instructions must include register selection macros**, even for low registers, for readability.

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

## Memory Map

```
0x0000-0x3EFF  Program ROM (16 KiB)
0x4000-0x4EFF  Framebuffer characters (64x60 grid)
0x4F00-0x4FFF  Hidden framebuffer (global variables)
0x5000-0x5EFF  Framebuffer color (1 byte/char)
0x5F00-0x5F0F  Interrupt vector table (8 x 16-bit)
0x5F10-0x5FFF  Hidden framebuffer (global variables)
0x6000-0xAFFF  ~20 KiB dynamic RAM (malloc region)
0xB000-0xB9FF  2.5 KiB heap/software stack
0xBA00-0xBCFF  768 bytes global assembly arrays
0xBD00-0xBDFF  256 bytes UART circular buffer
0xBE00-0xBEFF  256 bytes keyboard circular buffer
0xBF00-0xBFFF  256 bytes CPU hardware stack
0xC000-0xCFFF  Peripheral registers (memory-mapped I/O)
0xD000-0xDFFF  Extended RAM D-page window (4 KiB)
0xE000-0xEFFF  Extended RAM E-page window (4 KiB)
0xF000-0xFFFF  Unallocated (0xFFFF reserved/idle bus)
```

## Peripherals

| Address | Peripheral |
|---------|------------|
| 0xC000-0xC001 | PS/2 Keyboard (0xC000=key, 0xC001=flags) |
| 0xC080-0xC0FF | RTC/Timer DS1511Y (BCD-encoded values) |
| 0xC100-0xC1FF | UART 82C52 (data, ctrl/status, modem ctrl, baud/modem status) |
| 0xC200-0xC2FF | Extended RAM page registers (even=D-page, odd=E-page) |
| 0xC300-0xC30F | ATA CS0/CS1 registers |
| 0xC310-0xC31F | ATA high byte latch (write hi first, lo write triggers 16-bit ATA write) |

## Interrupts

8-line priority encoder. IRQ saves PC and D register to stack. RETI restores status flag backup.

| IRQ | Vector | Source |
|-----|--------|--------|
| 1 | 0x5F02 | Keyboard |
| 3 | 0x5F06 | Timer |
| 4 | 0x5F08 | UART modem status |
| 5 | 0x5F0A | UART data ready |

IRQ 0/2/6/7 reserved.

## Video

640x480 VGA, 64x60 character grid (8x8 chars, CP437 font). Dual-port SRAM: chars at 0x4000-0x4EFF, color at 0x5000-0x5EFF. Color byte: `[BLINK][CURSOR][Rfg][Gfg][Bfg][Rbg][Gbg][Bbg]` (64 colors + blink + cursor).

## Repository Structure

```
mycpu2/
├── alu/               # ALU EEPROM lookup tables (rarely modified)
├── assembler/         # Custom Python assembler (pyparsing-based)
│   ├── assembler.py   # Main assembler + basic linking
│   ├── gen_opcodes.sh # Opcode/microcode generator
│   ├── asm_macros     # %name% text substitution macros
│   ├── opcode_cheatsheet  # Instruction quick reference
│   ├── opcodes        # Opcode definitions with microcode
│   └── macros         # Nano-ops (control signal groups)
├── c_compiler/        # Custom C99-to-assembly compiler (pycparser-based)
│   ├── c_compiler.py  # Entry point
│   ├── codegen.py     # Main code generator (~127 KB, AST visitor)
│   └── special_functions.py  # printf, print, halt handling
├── os/
│   ├── config.mk / rules.mk / Makefile
│   ├── bios/          # 16 KiB EEPROM image (files numbered 00- to 80-)
│   │   ├── 00-main.asm  # Entry: IRQ setup, boot sequence
│   │   └── lib/       # ~30 library modules linked into ROM
│   │       # Key: heap, malloc, extmalloc, ata, fat16_*, terminal_*,
│   │       # cursor, sprintf, string, strtoi, math, keyboard, uart,
│   │       # timer, memcpy, memfill, system, trace
│   ├── system/        # SYSTEM.ODY shell (10-shell, commands as 900-cmd_*.asm)
│   └── util/          # Disk-loaded .ODY utilities (ascii, hexdump, malloc, etc.)
├── bitmapfont/        # [IGNORE]
├── keyboard_controller_attiny/  # [IGNORE]
├── logisim/           # [IGNORE]
└── journal            # Development log (context on working style and history)
```

## Build System

From `os/` directory: `make all|bios|system|util`. Install: `make sdcard` (mounts at `/media/skaven/ODYSSEY`).

Pipeline: `.c` -> `cpp` -> `c_compiler.py` -> `.asm` -> `assembler.py` -> `.ody` (or `.hex` for BIOS).

BIOS must build first (generates `bios.sym` symbol table). All other components depend on `bios.sym` for ROM library addresses. C headers for BIOS functions in `os/bios/lib/*.h`.

## Assembly Language

**CRITICAL**: Instructions are NOT indented. All instructions, labels, directives are **left-justified** (no leading whitespace).

```asm
# vim: syntax=asm-mycpu
# Global labels (colon prefix) - visible across files
:function_name
# Local labels (dot prefix) - scoped to nearest preceding global label
.local_label
# String literals
.my_string "Hello\n\0"
# Variables (can appear anywhere in code, storage allocated separately)
VAR global byte $my_byte
VAR global word $my_word       # access: $var (high byte), $var+1 (low byte)
VAR global 32 $my_buffer       # 32-byte buffer
```

Notation: `@addr` = 16-bit arg, `$data` = 8-bit arg. BIOS files numbered `00-`, `10-`, etc. for concatenation order.

### Key assembly patterns

```asm
# ALU ops (register selectors always required)
ALUOP_AL %A+B%+%AL%+%BL%       # AL + BL -> AL
ALUOP_AL %A+B%+%AH%+%BH%       # AH + BH -> AL
ALUOP_DL %A%+%AL%               # copy AL to DL (A/B write through ALU only)
ALUOP_ADDR_D %A%+%AH%           # copy AH to memory at address in D
ALUOP_FLAGS %A-B%+%AL%+%BL%     # compare AL vs BL (flags only, no CMP instruction)

# Callee-save prolog/epilog (reverse order restore)
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

Note: all instructions above are left-justified in actual code. Indentation here is for document readability only.

## C Compiler

`c_compiler/c_compiler.py` -- C99 with caveats, generates unoptimized Odyssey assembly.

- Types: `char` (8-bit), `int`/`short` (16-bit), pointers (16-bit). No `long`/`float`.
- Convention: params on heap, D register as frame pointer, caller-cleanup.
- Special codegen: `printf()`, `print()`, `halt()`.
- Uses GCC `cpp` for preprocessing. Headers in `os/bios/lib/*.h`.

## ODY Executable Format

| Offset | Content |
|--------|---------|
| 0-2 | Magic: `ODY` |
| 3 | Flags (2 bits: memory target) |
| 4-5 | Count of relocation entries (16-bit) |
| 6+ | N x 16-bit relocation offsets, then raw machine code |

Loader adds base address to each relocation offset. CALL targets to ROM functions are absolute (not relocated).

## Extended Memory

1 MiB (two 512 KiB AS6C4008), accessed via two 4 KiB windows. D-window: 0xD000, page register at 0xC200 (even). E-window: 0xE000, page register at 0xC201 (odd). Physical = (page << 12) | (addr & 0x0FFF). Pages 0x000-0x7FF reserved for malloc ledger.

## FAT16

Read-only FAT16 over ATA (PIO mode). Drives `0:` and `1:` (master/slave). 512-byte sectors, 28-bit LBA. 8.3 filenames (max 8-char command names).

## Important Code Patterns

- **No CMP instruction**: compare via subtraction (`ALUOP_FLAGS %A-B%`) and check flags. O flag = unsigned comparison (underflow). E flag compares operands directly (use any ALU op, even AND/OR).
- **No hardware multiply/divide**: software in `math.asm` (`:mul16`, `:div8`). Multiply-by-10 = `8a + 2a` via shifts.
- **MEMCPY/MEMFILL count is N-1**: AL=0 copies 1 unit, AL=255 copies 256.
- **Hardware bulk ops**: `MEMCPY_C_D`, `MEMCPY4_C_D`, `MEMFILL4_C_PEEK`, `MEMFILL4_C_I` auto-increment C (and D for copies).
- **JMP for tail calls**: preserves caller's return address on stack.
- **MASKINT/UMASKINT**: required around transfer register (TAH/TAL/TD) use, since interrupts clobber them. Heap functions do this internally.
- **256-byte circular buffers**: keyboard (0xBE00) and UART (0xBD00) -- only low byte of pointers changes for natural wraparound.
- **Display memory is directly manipulated**: terminal input works on display memory, not a separate buffer. `:cursor_mark_getstring` copies from display to buffer.
- **Timer values are BCD**: DS1511Y RTC uses BCD (0x75 = 75, not 117).
- **Shared error labels**: related functions share error-exit labels when stack frames match.

## Constraints Summary

- **ROM**: 16 KiB, ~12 KiB used
- **CPU stack**: 256 bytes -- deep recursion dangerous
- **Heap**: 2.5 KiB -- C frames + asm parameter passing
- **RAM**: ~20 KiB (0x6000-0xAFFF) for malloc/ODY executables
- **No linker**: assembler concatenates all source files as one unit
- **A/B write through ALU only**: use identity op to copy

## printf Format Specifiers

`%%` literal, `%c` char, `%2` binary, `%b`/`%B` BCD (1/2 digits), `%x`/`%X` hex (byte/word), `%u`/`%U` unsigned decimal (byte/word), `%d`/`%D` signed decimal (byte/word), `%s` string pointer.

## Color Codes (`:print` strings)

`@[shade:0-3][color:0-7]` (0=blk 1=blu 2=grn 3=cyn 4=red 5=mag 6=yel 7=wht), `@x[hex]` raw, `@b/@B` blink off/on, `@c/@C` cursor off/on, `@r` reset.

## Keyboard Flags (0xC001)

`0x01` BREAK, `0x02` CTRL, `0x04` ALT, `0x08` FUNCTION, `0x10` SHIFT, `0x20` NUMLOCK, `0x40` CAPSLOCK, `0x80` SCROLLLOCK.
