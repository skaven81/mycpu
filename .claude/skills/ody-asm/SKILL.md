---
name: ody-asm
description: Wire Wrap Odyssey assembly language reference. Use when writing, reviewing, or debugging Odyssey assembly - covers exact assembler syntax rules, program skeletons (ODY utility, heap-arg function, shell built-in), the complete heap API, tight-loop optimization, validation with asmcheck.sh, common pitfalls, and trace-based debugging.
version: 2.0.0
---

# Odyssey Assembly Reference

## Validate before delivering -- always

There is no emulator, but the assembler run IS the syntax check:

```bash
assembler/asmcheck.sh file.asm [file2.asm ...]     # exit 0 = assembles
assembler/asmcheck.sh --listing file.asm           # dump annotated byte listing
assembler/asmcheck.sh --no-symbols file.asm        # if no BIOS/ROM calls
```

Files are concatenated in the order given (entry-point file first), same as the
real build. For C-containing utilities, `make -C os/util/<name>` is the check.
Error messages report the file and per-file line number of the offending line.
**Never deliver assembly you have not run through asmcheck.**

## Syntax hard rules (the parser rejects violations)

- **One statement per line.** Four line types: label, data, opcode, `VAR`. A
  label CANNOT share a line with an instruction.
- **Label names**: `[A-Za-z0-9_]` only, **minimum 4 characters** after the
  `:` or `.` sigil. `:run`, `.err` fail to parse; `:main`, `.loop` are fine.
  (`$var` names have no length minimum, but 4+ chars is good style.)
- `:name` = global label (exported to symbol table, visible everywhere).
  `.name` = **file-scoped** local label (internally renamed
  `.<FILENAME>_name`). Every file may reuse `.loop`, `.program_exit`, etc.,
  but one file cannot reference another file's locals. Two source files with
  the same basename in one build will collide.
- **Numeric literals are exact-width**: 8-bit args take `0xNN` (exactly 2 hex
  digits), `0b` + exactly 8 bits, `'c'` char, or decimal -128..255. 16-bit
  args take `0xNNNN` (exactly 4 digits), `0b` + 16 bits, decimal, or a label.
  `LDI_AL 0x5` and `LD_AL 0xc0` both FAIL.
- **Label offsets**: decimal only, no spaces. `:main+2` good; `:main+0x02` and
  `:main + 2` fail.
- **Expressions** (`0x05+0x40`, `%A+B%+%AH%`, `$var+1`): operators `* / + - & |`,
  NO whitespace anywhere inside. Avoid a decimal literal followed by `-`
  (`254-0x0a` crashes the parser); put hex first or use all-hex.
- **Mnemonics are strictly UPPERCASE.** `VAR global byte|word|dword|<N> $name`
  keywords are lowercase-exact.
- **Comments**: `#` to end of line. No `;`, no `//`.
- **No directives** other than `VAR`: no ORG, EQU, include, define, align.
  Output is contiguous from offset 0; multi-file programs are concatenated in
  command-line order.
- `$var` always substitutes to a 16-bit address, so it is valid only where a
  `@addr`/16-bit operand is expected. `LD_AL $var` good; `LDI_AL $var` fails.
- Instructions are left-justified by convention (follow it).

### Data lines and strings

```asm
:main
RET
.msgs "Hello\n\0"                     # every C-style string needs explicit \0
.tabl "peek\0" :main 0xff 'Z' .msgs   # mixed items; label items emit 2 bytes hi,lo
```

- Every data line must START with a label. There is no anonymous `.db`.
- Byte items must be 0..255 (no negatives).
- String escapes: `\n \r \t \f \0` plus `\.` and `\:`. **No `\\`, no `\"`,
  no `\xNN`.** A string cannot contain a double-quote.
- A data item that BEGINS with `.` or `:` is treated as a label reference, so
  a string starting with those characters must escape the first char:
  `"\.profile\0"`, `"\:colon first\0"`.
- Quoted string contents are never macro-expanded or label-localized;
  `"%B%B\0"` and `"config.json\0"` assemble byte-exact.

### Avoid VAR in ODY programs -- use label data segments instead

`VAR` addresses are assigned AT ASSEMBLY TIME from fixed shared pools:
scalars upward from `0x4f00` (rolls to `0x5f10`), arrays DOWNWARD from
`0xcaff` (floor 0xc800, mostly consumed by the BIOS). ODY programs inherit
the allocation cursors from `bios.sym`, which means:

- Every separately built ODY program's VARs OVERLAY each other, and any
  future multi-process capability (TSRs etc.) would make them collide
  catastrophically.
- A BIOS update shifts the cursors, so all software must be recompiled to
  keep VAR references from colliding.

**In ODY programs, declare variables as label data segments instead** --
same speed (it is all main memory), but the storage is INSIDE the binary
and relocated with it, so there is no address-collision problem:

```asm
:main
LD_AL .my_byte                  # use the label exactly like a $var address
ST16 .my_word 0x1234
LDI_C .my_buf                   # label as pointer to a buffer
RET
.my_byte "\0"                   # 1 byte, initialized to 0
.my_word "\0\0"                 # 2 bytes
.my_buf "\0\0\0\0\0\0\0\0"      # fill with \0 (or spaces) to size the buffer
```

Reserve `VAR global` for BIOS library code (which is what the pools are
for). Big runtime buffers belong in malloc'd RAM (`:malloc_blocks`) or an
extended-memory page.

## Instruction inventory corrections (do not hallucinate these)

- **These do NOT exist**: `ALUOP_TAL`, `ALUOP_TD`, `PUSH_AH/AL/BH/BL`,
  `LD_TAL`, `INCR4_C`, `INCR8_C`, `CMP`, `ADD`, `SUB`, `MOV_AH_CH` (MOV is
  C/D -> A/B/T direction ONLY, named `MOV_<SRC>_<DST>`, e.g. `MOV_CH_AH`).
- The only way to push A/B to the hardware stack is `ALUOP_PUSH %A%+%AH%` etc.
  C/D use `PUSH_CH`/`PUSH_CL`/`PUSH_DH`/`PUSH_DL`. Pop side has all of
  `POP_{AH,AL,BH,BL,CH,CL,DH,DL,TAL,TD}` plus `PEEK_*`. `POP_TD` is the
  idiomatic "pop and discard".
- **`ALUOP_ADDR $op @addr` takes the ALU op FIRST, then the address** --
  reverse of `ST @addr $data`. Same for `ALUOP_ADDR_SLOW $op @addr`.
- Branches: only `JMP JEQ JNE JZ JNZ JO JNO` (+ `_D` variants using register D,
  and `CALL`/`CALL_D`). No JC/JGT/JLT.
- `%ALU16_*%` macros expand to THREE operands -- they fit only the conditional
  forms `ALUOP16O_/E_/Z_{A,B,FLAGS}`. The 2-operand `ALUOP16_A lo hi` needs
  hand-written operands: `ALUOP16_A %A|B% %A|B%+%AH%+%BH%`.
- **`MEMFILL4_C_I` is broken microcode (fills with the opcode byte, not the
  immediate). Use `MEMFILL4_C_PEEK` with the fill byte on the hardware stack,
  or `MEMFILL4_C_DL`.**
- **Peripheral space 0xC000-0xC7FF requires the `_SLOW` opcodes**:
  `LD_SLOW_PUSH @addr`, `ST_SLOW @addr $data`, `ST_SLOW_POP @addr`,
  `LDA_{A,B,C,D}_SLOW_PUSH`, `STA_{A,B,C,D}_SLOW_POP`,
  `ALUOP_ADDR_SLOW $op @addr`, `ALUOP_PUSH_SLOW $op`. Regular loads/stores on
  peripherals return/write garbage silently.
- **Bulk-op instructions vs BIOS functions -- don't conflate them.** The
  INSTRUCTIONS move a fixed amount per execution (microcode cannot loop):
  `MEMCPY_C_D` copies exactly 1 byte, `MEMCPY4_C_D` / `MEMFILL4_C_PEEK` /
  `MEMFILL4_C_DL` move exactly 4 bytes, all auto-incrementing C (and D).
  The BIOS FUNCTIONS loop them with AL as a count that is N-1 (AL=0 does 1
  unit, AL=255 does 256): `:memcpy` (units of 1 byte), `:memcpy_blocks`
  (16-byte blocks), `:memcpy_segments` (128-byte segments), `:memfill`,
  `:memfill_half_blocks`, etc. -- see `os/bios/lib/memcpy.asm` and
  `memfill.asm` headers.

## Core patterns

```asm
# ALU ops (register selectors always required; flags latch on EVERY ALUOP)
ALUOP_AL %A+B%+%AL%+%BL%       # AL + BL -> AL
ALUOP_DL %A%+%AL%              # copy AL to DL (A/B reach the bus only via ALU)
ALUOP_ADDR_C %A%+%AL%          # store AL to memory at [C] -- compute+store in one
ALUOP_FLAGS %A-B%+%AL%+%BL%    # compare AL vs BL (no CMP instruction)
ALUOP_ADDR_SLOW %A%+%AL% 0xC080  # write AL to a peripheral register, one instr

# Comparisons: O flag after %A-B% means A < B (underflow). JO = "A < B",
# JNO = "A >= B". E flag compares the two OPERANDS for equality regardless of
# the op (even %A&B%), Z tests the RESULT for zero.

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

# Memory/variables
VAR global byte $my_var
VAR global word $my_word_var
LDI_C 0x4000                    # 16-bit address into C
LDA_C_AL                        # load byte at [C] into AL
ST $my_var 0x42                 # store immediate to variable
LD_AL $my_var                   # load variable
LD16_A $my_word_var             # load 16-bit variable into AH:AL
```

## The complete heap API (anything else is hallucinated)

Parameter passing uses the software heap (0xF000-0xFFEF), NOT the hardware
stack. The full set of functions in `os/bios/lib/heap.asm`:

- Push byte: `:heap_push_{AH,AL,BH,BL,CH,CL,DH,DL}`
- Push word: `:heap_push_{A,B,C,D}`
- Pop byte: `:heap_pop_{AH,AL,BH,BL,CH,CL,DH,DL}`
- Pop word: `:heap_pop_{A,B,C,D}`
- Discard: `:heap_pop_byte`, `:heap_pop_word`
- Bulk: `:heap_push_all` / `:heap_pop_all` (pushes A,B,C,D / pops D,C,B,A --
  note `:heap_pop_all` clobbers A; preserve a result in AL around it with
  `ALUOP_PUSH %A%+%AL%` ... `POP_AL`)
- Frames (C compiler): `:heap_advance_{AL,BL}`, `:heap_retreat_{AL,BL}`
- `:heap_init`; pointer in `$heap_ptr`; NO overflow checking.

Heap functions mask interrupts internally; you don't need MASKINT around
them. **This also means heap functions are NOT safe to call from an ISR** --
their internal `UMASKINT` would re-enable interrupts inside the handler.
ISRs must work with registers, the hardware stack, and direct memory only.

Interrupt-masking rules for your own code (e.g. around direct TAH/TAL/TD
use, which interrupts clobber):
- Always assume interrupts are enabled.
- `MASKINT` must be quickly followed by `UMASKINT` -- keep the window tight.
- NEVER call a function that may itself execute `UMASKINT` (any heap
  function, and anything that calls one) between your MASKINT/UMASKINT pair
  -- it would silently unmask early.

**Balance is everything.** The #1 historical bug class is an unbalanced heap:
every pushed arg must be popped by the callee, every returned value must be
popped (or explicitly discarded with `:heap_pop_byte`/`:heap_pop_word`) by the
caller. Multi-value returns to watch: `:div8` pushes remainder then quotient
(pop TWO), `:fat16_pathfind` pushes 2 on success / 1 on error,
`:extpage_d_pop` returns a value that must be consumed.

### printf/sprintf: args pushed in REVERSE order

Last format specifier's value is pushed FIRST (from `os/util/opeek/opeek.asm`):

```asm
CALL :heap_push_BL              # 3rd specifier (%x)
CALL :heap_push_AL              # 2nd specifier (%x = address low)
CALL :heap_push_AH              # 1st specifier (%x = address high)
LDI_C .peek_pfx
CALL :printf
.peek_pfx "0x%x%x: 0x%x\n\0"
```

## Where code should live

Three tiers, by cost of change. Default to the cheapest tier and promote
only when proven:

1. **ODY executable (disk)** -- cheapest to iterate: rebuild, copy to SD,
   run. New functionality starts here, including functions that will
   eventually become BIOS library routines: compile them INTO the ODY
   first, and only after they are confirmed working on hardware propose
   moving them into the BIOS. RAM is the constraint (~24 KiB minus the
   program itself).
2. **BIOS library (`os/bios/**`)** -- shared code every ODY can call; 16 KiB
   of ROM is "free real estate" that costs no main memory. Moderately
   expensive to change: EEPROM reflash, plus ALL software must be
   recompiled (function addresses and VAR cursors shift) and the SD card
   re-burned. Truly multi-use, hardware-proven routines belong here.

   **The BIOS is, by design, almost always full.** If a new candidate
   routine does not fit, that is normal -- look for an EVICTION candidate:
   an existing BIOS library used by only one (or very few) ODY programs.
   Demote it to compiled-in code in its consumer(s), freeing ROM for the
   new, more-widely-reusable routine. To find candidates, grep all of
   `os/system/` and `os/util/` (both `.asm` and `.c`/headers) for each
   `:funcname` in the suspect library and count distinct consumers.
   Propose the swap to the owner with the usage counts -- eviction is a
   BIOS change and carries the same reflash/recompile cost.

   **Editing an EXISTING BIOS library follows the same iterate-in-ODY
   rule**: copy the library source into a test ODY, iterate and verify on
   hardware there (renaming its globals/labels if they collide with the
   ROM-resident versions), and only once the new version is proven does
   the BIOS-sited copy get updated. Never iterate directly on
   `os/bios/lib/` code.
3. **CPU microcode / new instructions / new ALU operations** -- most
   expensive: CPU or ALU EEPROM reflash, logic-analyzer symbol tables,
   documentation. But a specialized instruction or ALU op can yield huge
   wins on gnarly problems (this is exactly where `MEMFILL4_*` and the
   `_SLOW` opcodes came from; the ALU is a mutable lookup table, source in
   `alu/`). Only PROPOSE such changes to the owner with the case for them;
   never treat this as a normal code change.

**C vs assembly within a program**: C for readable, less-performance-
critical logic; hand-written `.asm` helper files (auto-discovered by the
build) for tight loops, ISRs, and anything cycle- or size-critical. The
compiler's output is verbose and inefficient -- see skill **ody-c** for
the split pattern.

## Where data should live

All of these are the same speed (plain main-memory access) -- choose by
lifetime and safety, not speed:

- **Label data segments in the ODY** (see the VAR section above): the
  default for program globals. Localized, no collisions, zero overhead.
- **Extended memory pages (0xD000/0xE000 windows)**: just as fast as main
  memory, and often the cheapest way to hold lots of state: `:extmalloc` a
  page once, then address every variable as a CONSTANT offset (0xD000,
  0xD001, ...) -- no malloc, no pointers, no pointer arithmetic, and it
  frees up the tiny register file. Great fit when a program has many
  variables or large tables.
- **Hardware stack**: fast single-instruction scratch (`ALUOP_PUSH`/`POP_*`)
  when registers run short mid-computation. Only 256 bytes -- keep it
  shallow and balanced.
- **The heap**: same RAM speed but each access costs a CALL and internal
  masking -- use it for parameter passing and call frames, not as scratch.
- **Reentrant locals**: if a function can be re-entered (recursion, called
  from an ISR, or callable while already active), label globals are unsafe.
  Use the C compiler's frame technique -- awkward but correct:

```asm
:my_reentrant_func
PUSH_DH                         # preserve caller frame pointer
PUSH_DL
ALUOP_PUSH %B%+%BL%
LD_DH $heap_ptr                 # D = my frame base (current heap top)
LD_DL $heap_ptr+1
LDI_BL 4                        # reserve 4 bytes of locals
CALL :heap_advance_BL
# locals live at [D+0]..[D+3]; walk D (INCR_D) or copy D to C to address them
# ... body ...
LDI_BL 4
CALL :heap_retreat_BL           # free the frame
POP_BL
POP_DL
POP_DH
RET
```

  If reentrancy is NOT possible, prefer label globals -- frame offsets cost
  real instructions on every access.

## The BIOS exec loop: program lifecycle, args, and chaining

`os/README-bios-exec.md` is the authoritative program-interface spec; the
implementation is `os/bios/80-run_system_ody.asm`. The essentials:

The BIOS runs a forever-loop: read+clear the IPC block, run the requested
program (or SYSTEM.ODY as fallback), clean up after it returns, repeat.
Consequences for every program you write:

- **Receiving arguments**: the BIOS ALWAYS pushes argv (word pointer) then
  argc (16-bit) to the heap before `CALL_D`, even for SYSTEM.ODY. Consume
  them at entry with `CALL :argv_init` (pops argc into AL, argv base into
  C), or if your program ignores args, still discard them:
  `CALL :heap_pop_word` twice. The argv array is (hi,lo) pointer pairs,
  0x0000-terminated; `argv[0]` is the command name. Strings are owned by
  the BIOS -- never `:free` them.
- **Exit code is REQUIRED**: push a 16-bit exit code
  (`LDI_A 0x0000 / CALL :heap_push_A`) before the final `RET`. The BIOS
  pops it unconditionally; today the value is ignored, but future shells
  will use it (conventions: 0x0000 success, 0x0001 failure, 0x00FF
  abnormal). Skipping the push makes that pop read garbage -- technically
  harmless (see resilience below) but poor practice.
- **Chaining -- NEVER `CALL_D` another program's binary.** Direct calls
  leave both programs resident in the small RAM. Instead, fill the IPC
  block globals and return normally; the BIOS frees YOUR memory first,
  then loads the next program:
  1. `:fat16_pathfind` the target -- gives a malloc'd dirent ptr + fsh ptr
  2. store them in `$exec_dirent_ptr` / `$exec_fsh_ptr`
  3. optionally build a malloc'd argv array (malloc'd strings) and set
     `$exec_argv_ptr` / `$exec_argc` -- the BIOS frees all of it afterward
  4. push your exit code and `RET`
  Control only flows FORWARD: when the chained program exits, the BIOS
  checks the IPC block again, falling back to SYSTEM.ODY -- there is no
  "return to caller".
- **Memory ownership**: the BIOS frees the program binary, argv, and the
  IPC dirent. Everything else the program mallocs must be freed by the
  program before it returns, or it leaks until reboot (there is no audit).
- **Resilience**: the BIOS collapses (re-initializes) the heap before
  launching each ODY, so exiting with an unbalanced heap is TECHNICALLY
  safe -- but it is poor practice: the exit-code pop reads garbage and a
  gross imbalance triggers the BIOS heap warning. Exit clean. (Heap
  balance WITHIN your program's own call chains is a different matter --
  that is the #1 real bug class; see the heap API section.) A program that
  `HLT`s or never returns hangs the system (expected for fatal errors).

## Program skeletons

### ODY utility (`os/util/<name>/`, dir name max 8 chars)

Entry point is byte 0 of the binary -- the first file's first instruction.
Single-file utilities need no `:main`; multi-file builds put the file
containing `^:main` first. Skeleton (see `os/util/opeek/opeek.asm`):

```asm
# vim: syntax=asm-mycpu
# myutil - one-line description
#
# Usage: myutil <addr>

:main
CALL :argv_init                 # AL=argc, C=argv base; clobbers A and C!
LDI_D .argv_buf
LDI_AL 3                        # copy 4 blocks = 64 bytes (count is N-1)
CALL :memcpy_blocks

LD_AH .argv_buf+2               # argv[1] pointer hi byte (argv[n] at +2n)
ALUOP_FLAGS %A%+%AH%
JZ .usage                       # null hi byte => argument absent

LD_CH .argv_buf+2               # C = argv[1] string (owned by BIOS: never :free)
LD_CL .argv_buf+3
CALL :strtoi                    # A = value, BL = error flags
ALUOP_FLAGS %B%+%BL%
JNZ .usage

# ... body ...
JMP .program_exit

.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.program_exit
LDI_A 0x0000                    # 16-bit exit code -- REQUIRED by the ABI:
CALL :heap_push_A               # the BIOS pops this unconditionally
RET

.helpstr "Usage: myutil <addr>\n\0"
.argv_buf 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
```

Files needed: the `.asm`, a 3-line `Makefile`
(`include ../../config.mk` / `INSTALL_SUBDIR := SYS` / `include ../../rules.mk`),
and a `.gitignore` listing generated artifacts. `os/util/Makefile`
auto-discovers the directory; no registration needed.

### Function taking args on the heap

Document the calling recipe in a leading comment -- this is mandatory style:

```asm
####
# my_func - what it does
#
# To use:
#  1. Push the source address word
#  2. Push the count byte
#  3. Call the function
#  4. Pop the result byte
# Side effects: none (all registers preserved)
:my_func
ALUOP_PUSH %A%+%AH%             # callee-save on the HARDWARE stack
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
CALL :heap_pop_AL               # pop args in REVERSE push order (LIFO)
CALL :heap_pop_C
# ... body computes into A ...
CALL :heap_push_A               # heap-push result BEFORE the register POPs
POP_CL                          # restore in exact reverse order
POP_CH
POP_AL
POP_AH
RET
```

Simple functions instead take args/results directly in registers (AL byte,
A word, C/D addresses) -- always documented in the comment. Never push a
result onto the HARDWARE stack across your own epilog POPs (classic
off-by-one frame corruption); the heap is separate and safe for that.

### Shell built-in (`os/system/900-cmd_*.asm`)

Different from an ODY utility: no argv_init, no exit-code push.

```asm
:cmd_mycmd
LDI_AL 1
CALL :shell_get_argv_n          # A = argv[1] string address, 0x0000 if absent
ALUOP_FLAGS %A%+%AH%
JZ .usage
# ... body ...
RET
.usage
LDI_C .helpstr
CALL :print
RET
.helpstr "Usage: mycmd <arg>\n\0"
```

Register it in the `.cmd_list` table in `os/system/40-parse_command.asm`
(alphabetical, before `.cmd_end 0x00`): `.cmd_150 "mycmd\0" :cmd_mycmd`.
Built-ins are linked into SYSTEM.ODY, so shell-local labels like
`:shell_get_argv_n` resolve at `make -C os system` time (they are NOT in
bios.sym -- a standalone asmcheck of one command file reports them
unresolved; check the whole system build instead).

## Tight loops: minimize instructions per iteration

Inner loops must not need hand-optimization afterward. Every instruction in a
loop body costs real time at 2.2 MHz. Checklist:

- **Hoist everything invariant** (address setup, constants) above the loop.
  Do callee-saves ONCE outside; never push/pop or heap-touch inside a loop.
- **Walk with C/D pointers** (`INCR_C`, `INCR_D`, `INCR4_D`, `INCR8_D` are
  single hardware instructions) instead of recomputing addresses.
- **Compute directly to the destination.** `ALUOP_ADDR_C %A%+%AL%` stores AL
  at [C] in one instruction -- there is no separate "store AL" instruction to
  pair with a compute.
- **Every ALUOP latches flags, and ONLY ALUOPs do** (verified against the
  microcode: no load, store, MOV, INCR/DECR, PUSH/POP, or CALL/RET touches
  the status register). So a decrement IS a test: follow
  `ALUOP_BH %B-1%+%BH%` immediately with `JNZ` -- a separate `ALUOP_FLAGS`
  is a wasted instruction. And flags survive any stretch of non-ALU
  instructions, so you may set flags, then load/store freely, then branch.
- **Use the hardware bulk ops** (`MEMCPY_C_D`, `MEMCPY4_C_D`,
  `MEMFILL4_C_PEEK`, `MEMFILL4_C_DL`) whenever the shape fits -- they beat any
  loop.
- **Count down, not up**: down-counting ends on the free Z flag; up-counting
  needs a comparison.

Example -- XOR-checksum 256 bytes at 0x6000. Five instructions per iteration:

```asm
LDI_C 0x6000                    # walking pointer      (hoisted)
LDI_AL 0x00                     # checksum accumulator (hoisted)
LDI_BH 0x00                     # counter: wraps for 256 iterations
.ckloop
LDA_C_BL                        # byte at [C] -> BL
ALUOP_AL %AxB%+%AL%+%BL%        # AL ^= BL
INCR_C                          # hardware increment, no ALU needed
ALUOP_BH %B-1%+%BH%             # BH-- ... and this already set the flags
JNZ .ckloop                     # so no ALUOP_FLAGS needed
```

The x86-trained version of this loop re-tests the counter with a separate
`ALUOP_FLAGS %B%+%BH%` (6/iter) or keeps the counter in memory (9+/iter).
Neither is acceptable.

**The wrap trick above is for FIXED 256-iteration loops only.** For a
runtime count N (which may be zero), test before entering and decrement at
the bottom:

```asm
:main
LDI_C 0x6000                    # pointer (example setup)
LDI_BH 0x10                     # BH = runtime count N
LDI_AL 0x00
ALUOP_FLAGS %B%+%BH%            # is N zero?
JZ .done                        # skip loop entirely if so
.loop
LDA_C_BL                        # ... body using BL as scratch ...
INCR_C
ALUOP_BH %B-1%+%BH%             # N-- (sets Z when it hits zero)
JNZ .loop
.done
RET
```

**Accumulating bytes into a 16-bit total** (A = AH:AL) cannot use the
`%ALU16_*%` macros when BH is busy as a counter -- add the byte into AL and
propagate carry manually. O=1 after an unsigned add means overflow:

```asm
ALUOP_AL %A+B%+%AL%+%BL%        # AL += byte in BL (O set on carry-out)
JNO .nocarry
ALUOP_AH %A+1%+%AH%             # carry into the high byte
.nocarry
```

## Pitfalls from the development journal

- **Heap imbalance** is the #1 debugging time sink. Audit every CALL against
  the callee's documented push/pop recipe, especially error paths.
- **Null-check the right register**: after a subtract-compare, AL holds the
  result (0 whenever chars are EQUAL, not just at string end); test the
  original byte in BL instead.
- **Success flags**: `:fat16_pathfind`-style functions signal errors via
  sentinel values (BH == 0x00 not-found, 0x01 ATA error, else success) --
  test the sentinels explicitly, never bit-mask a pointer byte.
- **16-bit operand triples**: never compose ALUOP16 operand bytes by hand;
  use the `%ALU16_*%` macros from `assembler/asm_macros` (authoritative).
- **JMP, not CALL, for tail calls** -- preserves the caller's return address
  (and trace identity).
- **Reentrancy**: no `VAR global` scratch state in anything reachable from an
  ISR or from itself; use the heap or a context struct in malloc'd memory.
- **Big-endian CPU, little-endian disk**: every FAT16 multi-byte field needs
  byte-swapping (`:fat16_dirent_parse` etc.).
- **256-byte circular buffers** (keyboard 0xCC00, UART 0xCB00): only the low
  pointer byte changes, giving free wraparound.
- **ISRs are ordinary functions**: they must save and restore EVERY register
  they touch before `RETI` (flags are handled by the status backup + RETI).
  And they must never call heap functions (see the heap section).
- **Timer/RTC values are BCD** (0x75 means 75).

## Debugging with trace calls

Static analysis has limits; once a problem gets complex, collect ground truth
with traces. Insert `CALL :trace_0` ... `:trace_7` at strategic points (see
`os/bios/lib/trace.asm`). Traces are idempotent -- no register or memory
changes -- and print: DEBUGn tag, the caller's address, A/B/C/D values, and
the current extended-memory pages.

For C-generated code: `make <basename>.asm` once, insert traces directly in
the generated .asm, then `make` -- the binary is rebuilt from your edited .asm
as long as the .c is untouched.

Ask the owner to run on hardware and report the trace output. Use skill
**ody-remap-log** to correlate `assembler.log` offsets with runtime addresses.
