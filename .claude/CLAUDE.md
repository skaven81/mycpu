# General code and documentation reference

## Unicode characters

NEVER use unicode characters like em-dashes or arrow glyphs in code you write for this project. Use only the standard ASCII character set.

## Comments

All assembly functions MUST include leading comments that explain how to call them.  The comments must include the calling convention (e.g. what registers to set or what to push to the heap, and in what order) and how the return value is obtained after execution.

Any side-effects from executing the function must be noted.

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

## CPU Architecture (brief)

- **8-bit data bus, 16-bit address bus**, ~2.2 MHz clock
- **LUT-based ALU**: two AT28C256 EEPROMs (4-bit slices), 32 distinct operations
- **Microcoded**: 4 EEPROMs, 32 control signals/cycle, up to 16 micro-ops/instruction
- **Big-endian** (ATA/FAT16 data is little-endian, requires byte-order translation)
- Registers: A (AH/AL), B (BH/BL), C (16-bit address), D (16-bit address), SP (8-bit), Status (Z/E/O flags)
- A/B registers can ONLY write to bus through ALU (use identity op `%A%` or `%B%`)

For full register details, ALU operations, ALUOP16, stack/heap architecture, and calling convention, consult skill **ody-cpu**.

## Opcode and Macro References

**When unsure about an instruction or macro, always consult these files before writing code.**

- **`assembler/opcode_cheatsheet`** -- quick high-level overview of all available opcodes. Read this first to find what instructions exist.
- **`assembler/opcodes.out`** -- canonical, authoritative reference of all opcodes with full microcode. Extract a single instruction with:
  ```bash
  awk '/<OPCODE>/,/^[[:space:]]*$/ {print; if (/^[[:space:]]*$/) exit}' assembler/opcodes.out
  ```
- **`assembler/asm_macros`** -- `%name%` text substitution macros. Cross-reference whenever working with ALU operations or any `%macro%` syntax.

## Assembly Language

**CRITICAL**: Instructions are NOT indented. All instructions, labels, directives are **left-justified** (no leading whitespace).

```asm
# vim: syntax=asm-mycpu
:function_name       # Global label (colon prefix)
.local_label         # Local label (dot prefix, scoped to nearest global)
.my_string "Hello\n\0"
VAR global byte $my_byte
VAR global word $my_word    # access: $var (high byte), $var+1 (low byte)
VAR global 32 $my_buffer
```

Notation: `@addr` = 16-bit arg, `$data` = 8-bit arg. BIOS files numbered `00-`, `10-`, etc. for concatenation order.

For assembly patterns, callee-save prolog/epilog, heap parameter passing, comparison/branch patterns, bulk memory ops, and trace-based debugging, consult skill **ody-asm**.

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

From `os/` directory: `make all|bios|system|util`. Install: `make sdcard` (mounts at `/media/skaven/ODYSSEY`). For broad builds (especially after `make clean`), use `make -j12` for much faster parallel builds.

Pipeline: `.c` -> `cpp` -> `c_compiler.py` -> `.asm` -> `assembler.py` -> `.ody` (or `.hex` for BIOS).

BIOS must build first (generates `bios.sym` symbol table). All other components depend on `bios.sym` for ROM library addresses. C headers for BIOS functions in `os/bios/lib/*.h`.

## Git conventions

When creating new utilities (e.g. under `os/util/<name>/`), always include a `.gitignore` in the new directory to exclude generated build artifacts from version control.
There is a top-level `.gitignore` that prevents things like .ODY files and .log files from being included, but since some programs contain a mix of .c and .asm files,
a blanket `*.asm` does not work.  Each utility's `.gitignore` should explicitly list the build artifacts (e.g. .asm files created from .c files) that aren't covered
by the top-level .gitignore.

## C Compiler

`c_compiler/c_compiler.py` -- C99 with caveats, generates unoptimized Odyssey assembly.
Types: `char` (8-bit), `int`/`short` (16-bit), pointers (16-bit). No `long`/`float`.

For C compiler details, known quirks/workarounds, and code size optimization techniques (14 validated patterns), consult skill **ody-c**.

## Memory and I/O

For the full memory map, peripheral addresses, interrupt vectors, video system details, extended memory paging, FAT16, ODY executable format, printf format specifiers, color codes, and keyboard flags, consult skill **ody-io**.

## Constraints Summary

- **ROM**: 16 KiB, ~12 KiB used
- **CPU stack**: 256 bytes (0xBF00-0xBFFF) -- deep recursion dangerous
- **Heap**: ~4 KiB (0xF000-0xFFEF) -- C frames + asm parameter passing
- **RAM**: ~24 KiB (0x6000-0xBEFF) for malloc/ODY executables
- **No linker**: assembler concatenates all source files as one unit
- **A/B write to bus through ALU only**: use identity op to copy out. MOV instructions exist for C/D -> A/B direction only.
- **No CMP instruction**: compare via `ALUOP_FLAGS %A-B%`. O=1 means A < B (underflow), O=0 means A >= B.
- **MEMCPY/MEMFILL count is N-1**: AL=0 copies 1 unit, AL=255 copies 256.
- **Timer values are BCD**: DS1511Y RTC uses BCD encoding.
