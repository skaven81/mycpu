# C Compiler Optimization Flags

The Odyssey C compiler supports optimization presets and individual flags
that control whether certain repeated inline assembly patterns are replaced
with CALL-based helper subroutines. The helpers live in BIOS ROM
(`os/bios/lib/c_helpers.asm`) and are shared by all compiled programs,
so they add zero bytes to each binary.

## Quick Start

Optimization flags are passed via `C_FLAGS` on the Make command line:

    # Default balanced mode (no flags needed)
    make -j12 all

    # Optimize for size
    make -j12 all C_FLAGS="-Os"

    # Optimize for speed
    make -j12 all C_FLAGS="-Of"

    # Custom: balanced preset with rvalue threshold lowered to 3
    make -j12 all C_FLAGS="-Ob --rval-threshold=3"

**Important**: Use Make command-line override syntax (`make C_FLAGS="..."`)
rather than environment variable syntax (`C_FLAGS="..." make`), because
`config.mk` uses simple assignment (`C_FLAGS :=`) which overrides
environment variables but not command-line overrides.

## Optimization Presets

### `-Ob` -- Balanced (default)

The default when no preset is specified. Uses CALL helpers only where the
cycle penalty is minimal or zero compared to the inline code they replace.
The rvalue threshold of 6 is the cycle break-even point: at stack offsets
of 6 or greater, the CALL helper is actually the same speed or faster than
the inline sequence it replaces.

### `-Os` -- Optimize for Size

Uses all available CALL helpers and lowers the rvalue threshold to 1,
meaning every non-zero stack offset goes through a helper. This maximizes
binary size savings at the cost of additional cycles for small-offset
accesses. The cycle penalty for the smallest offsets (1-2) is up to 13
cycles (~6 us at 2.2 MHz) per access.

### `-Of` -- Optimize for Speed

Disables all CALL helpers. Every variable access, store, and struct
offset computation is emitted inline. This produces the largest binaries
but avoids the CALL/RET overhead (11 cycles per helper invocation).

The one exception is struct self-increment (`use_struct_self_incr`), which
remains enabled because it is both smaller AND faster than the code it
replaces -- it is never a speed penalty.

## Preset Feature Matrix

| Feature                         | `-Of` (speed) | `-Ob` (balanced) | `-Os` (size) |
|---------------------------------|:--------------:|:----------------:|:------------:|
| Rvalue CALL helpers             | off (999)      | offset >= 6      | offset >= 1  |
| Lvalue CALL helpers (offset>=10)| off            | **on**           | **on**       |
| 16-bit store CALL helpers       | off            | **on**           | **on**       |
| Struct self-increment (1-2)     | **on**         | **on**           | **on**       |
| Struct CALL helpers (3-255)     | off            | off              | **on**       |

The `rval_threshold` column shows the minimum `abs(offset)` from the
frame pointer (D register) at which a rvalue load switches from inline
code to a CALL helper. A value of 999 effectively disables all rvalue
helpers since no realistic stack frame reaches that depth.

## Individual Override Flags

These flags override the selected preset for a specific feature. They are
applied after the preset, so they can be used to tweak a preset without
switching to a different one entirely.

### `--rval-threshold=N`

Set the minimum absolute stack offset at which rvalue (value load)
operations use a CALL helper instead of inline code. Overrides the
preset's default.

- Type: integer (0-255 for positive offsets; negative offsets use the
  absolute value)
- Default: 6 (`-Ob`), 1 (`-Os`), 999 (`-Of`)
- Setting to 0 or 1 uses helpers for all non-zero offsets
- Setting to 999 effectively disables rvalue helpers

The rvalue helpers replace the most frequently emitted inline pattern in
compiled code: saving the other register pair, computing D+offset into it,
dereferencing to load the value, and restoring the other register. Each
call site becomes just 2 instructions (LDI + CALL = 5 bytes) for positive
offsets, or 2 instructions (LDI + CALL = 6 bytes) for negative offsets.

**Cycle break-even analysis (16-bit rvalue into A, positive offset):**

| Offset | Inline bytes | Inline cycles | CALL bytes | CALL cycles | Byte savings | Cycle delta |
|--------|-------------|---------------|------------|-------------|--------------|-------------|
| 1      | 20          | 40            | 5          | 53          | +15          | -13         |
| 2      | 22          | 44            | 5          | 53          | +17          | -9          |
| 3      | 24          | 48            | 5          | 53          | +19          | -5          |
| 4      | 20          | 46            | 5          | 53          | +15          | -7          |
| 5      | 22          | 50            | 5          | 53          | +17          | -3          |
| **6**  | **24**      | **54**        | **5**      | **53**      | **+19**      | **+1**      |
| 7      | 26          | 58            | 5          | 53          | +21          | +5          |
| 8      | 20          | 54            | 5          | 53          | +15          | +1          |
| 9      | 22          | 58            | 5          | 53          | +17          | +5          |
| >=10   | 31          | 60            | 5          | 53          | +26          | +7          |

At offset 6, the CALL helper is 1 cycle *faster* than inline and 19 bytes
smaller. This is why the default threshold is 6.

Helpers only exist for the A and B register pairs. When the compiler needs
to load a value into the C register (e.g. for printf's format string
argument), the inline code path is always used regardless of this setting.

BIOS ROM helpers used:
- `__cc_rval16p_A`, `__cc_rval16p_B` -- 16-bit load, positive offset
- `__cc_rval8p_AL`, `__cc_rval8p_BL` -- 8-bit load, positive offset
- `__cc_rval16n_A`, `__cc_rval16n_B` -- 16-bit load, negative offset
- `__cc_rval8n_AL`, `__cc_rval8n_BL` -- 8-bit load, negative offset

### `--no-lval-helpers`

Disable lvalue (address computation) CALL helpers for stack offsets >= 10.

- Default: enabled (`-Ob`, `-Os`), disabled (`-Of`)
- Saves 10 bytes per call site (inline is 15 bytes, CALL is 5 bytes)
- Cycle penalty: 7 cycles per call (inline 28c vs CALL 35c)

For offsets 1-9, the compiler always uses an efficient inline INCR/DECR
sequence to adjust the D register, copy it, then restore D. This is
both smaller and faster than any CALL-based approach for small offsets.

For offsets >= 10, the inline code must save the other register pair,
load the 16-bit offset, perform a 16-bit add, and restore. This takes
15 bytes. The CALL helper replaces it with LDI + CALL (5 bytes).

BIOS ROM helpers used:
- `__cc_lval_p_B`, `__cc_lval_p_A` -- positive offset (unsigned byte)
- `__cc_lval_n_B`, `__cc_lval_n_A` -- negative/signed offset (16-bit)

### `--no-store-helpers`

Disable 16-bit store CALL helpers.

- Default: enabled (`-Ob`, `-Os`), disabled (`-Of`)
- Saves 9 bytes per call site (inline is 12 bytes, CALL is 3 bytes)
- Cycle penalty: 11 cycles per call (inline 24c vs CALL 35c)

The inline 16-bit store is 4 instructions (12 bytes): write high byte,
increment address, write low byte, decrement address. The CALL helper
replaces all 4 with a single CALL instruction (3 bytes).

8-bit stores are always inline (1 instruction, 2 bytes -- smaller than
a CALL instruction).

BIOS ROM helpers used:
- `__cc_store16_AB` -- store A value to address in B
- `__cc_store16_BA` -- store B value to address in A

### `--no-struct-helpers`

Disable struct member offset CALL helpers for offsets 3-255.

- Default: disabled (`-Ob`, `-Of`), enabled (`-Os`)
- Saves 5 bytes per call site (inline is 13 bytes, CALL site is 8 bytes)
- Cycle penalty: 13 cycles per call (inline 24c vs CALL 37c)

When accessing a struct member, the compiler must add the member's byte
offset to the base address register. For offsets 3-255, the inline
code saves/restores the other register pair (4 instructions), loads the
16-bit offset, and performs a 16-bit add (total: 6 instructions, 13 bytes).

The CALL helper reduces the call site to 4 instructions (8 bytes):
push the other register's low byte, load the offset, CALL the helper,
pop the other register's low byte. The helper internally handles the
16-bit addition.

This optimization is only enabled in `-Os` mode because the 13-cycle
penalty is significant for struct-heavy code (e.g. FAT16 directory
traversal).

BIOS ROM helpers used:
- `__cc_add_off_p_B` -- add offset in AL to address in B
- `__cc_add_off_p_A` -- add offset in BL to address in A

### `--no-struct-self-incr`

Disable the struct self-increment optimization for member offsets 1-2.
**Debug only** -- this flag exists for testing purposes. There is no
reason to disable this in production.

- Default: enabled in all presets (including `-Of`)
- This optimization is a pure win: both smaller AND faster than inline

For struct member offsets of 1 or 2, the compiler emits one or two
`ALUOP16O` self-increment instructions instead of the full 6-instruction
inline save/load/add/restore sequence.

| Offset | Self-incr bytes | Self-incr cycles | Inline bytes | Inline cycles |
|--------|-----------------|------------------|--------------|---------------|
| 1      | 4               | 8                | 13           | 24            |
| 2      | 8               | 16               | 13           | 24            |

At offset 1: 9 bytes smaller and 16 cycles faster.
At offset 2: 5 bytes smaller and 8 cycles faster.

This is enabled even in `-Of` (speed) mode because disabling it would
make the code both larger and slower.

## BIOS ROM Overhead

The 16 helper functions in `os/bios/lib/c_helpers.asm` add approximately
236 bytes to the BIOS ROM image. This is a one-time cost shared by all
compiled programs.

| Helper group            | Count | Total bytes |
|-------------------------|------:|------------:|
| Rvalue loaders          | 8     | ~156        |
| Lvalue address loaders  | 4     | ~38         |
| 16-bit store helpers    | 2     | ~26         |
| Struct offset helpers   | 2     | ~18         |
| **Total**               | **16**| **~236**    |

BIOS ROM usage after adding helpers: 15,641 of 16,384 bytes (743 remaining).

## Measured Results

All measurements taken from a clean build of the full project (`make clean
&& make -j12 bios && make -j12 system util cctest`). Assembly-only programs
are unaffected by these flags and are excluded from the table.

### Binary sizes by preset

| Binary       | -Of (speed) | -Ob (balanced) | -Os (size)  |
|--------------|------------:|---------------:|------------:|
| SYSTEM.ODY   | 15,507      | 14,614         | 14,236      |
| VIDPLAY.ODY  | 9,433       | 7,854          | 7,182       |
| CCTEST1.ODY  | 14,354      | 12,164         | 11,348      |
| CCTEST2.ODY  | 14,741      | 13,145         | 11,948      |
| CCTEST3.ODY  | 10,237      | 9,398          | 8,507       |
| CCTEST4.ODY  | 9,688       | 8,639          | 7,402       |
| CCTEST5.ODY  | 6,534       | 5,856          | 4,964       |
| CCTEST6.ODY  | 14,209      | 13,390         | 12,680      |
| CCTEST7.ODY  | 18,738      | 17,619         | 16,662      |
| CCTEST8.ODY  | 8,192       | 7,382          | 6,960       |
| CCTEST9.ODY  | 9,137       | 8,207          | 7,916       |

### Savings vs -Of baseline

| Binary       | -Ob savings       | -Os savings        |
|--------------|------------------:|-------------------:|
| SYSTEM.ODY   | -893 (-5.8%)      | -1,271 (-8.2%)     |
| VIDPLAY.ODY  | -1,579 (-16.7%)   | -2,251 (-23.9%)    |
| CCTEST1.ODY  | -2,190 (-15.3%)   | -3,006 (-20.9%)    |
| CCTEST2.ODY  | -1,596 (-10.8%)   | -2,793 (-18.9%)    |
| CCTEST3.ODY  | -839 (-8.2%)      | -1,730 (-16.9%)    |
| CCTEST4.ODY  | -1,049 (-10.8%)   | -2,286 (-23.6%)    |
| CCTEST5.ODY  | -678 (-10.4%)     | -1,570 (-24.0%)    |
| CCTEST6.ODY  | -819 (-5.8%)      | -1,529 (-10.8%)    |
| CCTEST7.ODY  | -1,119 (-6.0%)    | -2,076 (-11.1%)    |
| CCTEST8.ODY  | -810 (-9.9%)      | -1,232 (-15.0%)    |
| CCTEST9.ODY  | -930 (-10.2%)     | -1,221 (-13.4%)    |

### Totals (C-compiled binaries only)

| Preset              | Total bytes | vs -Of baseline     |
|---------------------|------------:|--------------------:|
| -Of (speed)         | 130,770     | --                  |
| -Ob (balanced)      | 118,268     | -12,502 (-9.6%)     |
| -Os (size)          | 109,805     | -20,965 (-16.0%)    |

### Observations

- **-Ob** delivers 5-17% size reduction per binary with minimal cycle
  penalty. The rvalue helpers at threshold 6 are at or past the cycle
  break-even point, so most accesses are no slower than inline.

- **-Os** delivers 8-24% size reduction. The additional savings come from
  lowering the rvalue threshold to 1 (catching all small-offset accesses)
  and enabling struct CALL helpers for offsets 3+.

- Programs with many local variables and function parameters (VIDPLAY,
  CCTEST4, CCTEST5) see the largest percentage savings because they have
  the most frame-relative accesses.

- SYSTEM.ODY shows smaller percentage savings because it includes
  substantial hand-written assembly code that is unaffected by these
  optimizations.
