---
name: ody-c
description: Wire Wrap Odyssey C compiler reference and code size optimization guide. Use when writing C code for the Odyssey, working with the c_compiler, investigating compiler bugs/quirks, or optimizing generated assembly size. Contains known compiler limitations, workarounds, and 14 validated optimization techniques.
version: 1.0.0
---

# Odyssey C Compiler Reference

## C Compiler Overview

`c_compiler/c_compiler.py` -- C99 with caveats, generates unoptimized Odyssey assembly.

- Types: `char` (8-bit), `int`/`short` (16-bit), pointers (16-bit). No `long`/`float`.
- Convention: params on heap, D register as frame pointer, caller-cleanup.
- Special codegen: `printf()`, `print()`, `halt()`. Assembly-callable functions needing non-standard call sequences are handled in `c_compiler/special_functions.py`.
- Uses GCC `cpp` for preprocessing. Headers in `os/bios/lib/*.h`.

## Known Quirks (TODOs)

- **TODO: Inline cast-to-pointer as function argument fails.** `func((void *)0xD000)` produces "Incompatible types" because `visit_Typename` in cast expressions does not propagate `is_pointer` in `return_typespec` mode. Workaround: declare a typed local variable (`char *buf = (char *)0xD000;`) and pass that instead. Fix: propagate `is_pointer` through `visit_Typename` in `return_typespec` mode in `codegen.py`.
- **TODO: String literals cannot begin with `:` or `.`.** The assembler treats leading `:` as a global label and leading `.` as a local label or directive, so string data starting with those characters will be misassembled. Workaround: restructure strings to avoid leading `:` or `.`, or emit the first byte separately.

## Code Size Optimization Techniques

The C compiler generates unoptimized, verbose assembly. Validated in `900-cmd_memstat.c`: 16.6% reduction (3147 to 2626 lines).

### 1. File-scope statics instead of local variables

Local variables at heap offset N require computing D+N (expensive for N>8). Use file-scope `static` instead:

```c
// Expensive: accessed as D+45 via 16-bit arithmetic per access
uint16_t range_start, total_bytes, ...;  // 15+ locals = offset 45!

// Cheap: accessed via fixed global address (LDI_B $var; LDA_B_AL)
static uint16_t s_range_start, s_total_bytes, ...;
```

Also eliminates `heap_advance_BL`/`heap_retreat_BL` calls in function prolog/epilog.

**Note:** C compiler requires explicit initializer for `static` local variables (e.g. `static uint16_t x = 0;`). File-scope statics are simpler when initializers would be awkward.

**Note on large arrays:** File-scope and `static` local arrays are allocated in the ODY binary. For large arrays (hundreds of bytes), declare a pointer instead and call `malloc_segments()`/`malloc_blocks()` at runtime.

### 2. Move hot simple functions to assembly

Functions called in tight loops generate enormous assembly from C due to calling-convention overhead. Write them as assembly functions (global labels `:func_name`) and declare `extern` in C. A 5-line C function generating 162 assembly lines becomes ~22 assembly instructions. See `os/system/900a-cmd_memstat_helpers.asm` for the pattern.

### 3. Pre-computed constant data instead of output loops

Replace loops that emit fixed repeated bytes with a pre-built data string in assembly:
```asm
:my_separator_func
PUSH_CH
PUSH_CL
LDI_C .sep_data
CALL :print
POP_CL
POP_CH
RET
.sep_data "@23" 0xCD 0xCD 0xCD ... (64 bytes) "@r\0"
```
The assembler supports mixed data items: `"string" 0xNN 0xNN "more\0"`.

### 4. The BinaryBool pattern -- the primary waste target

Every `==`, `!=`, `<`, `>=` comparison materializes a 0/1 boolean result in AL before branching (~14-20 lines). Direct truthiness tests (is-zero / is-nonzero) need only ~8 lines. **Identify every comparison in hot loops and restructure to use truthiness where possible.**

To find BinaryBool patterns in generated assembly, search for `binarybool_isfalse` or `binarybool_istrue` labels. Reducing their count is the primary metric.

### 5. XOR trick for inequality tests

`a ^ b` produces zero when equal, non-zero when different. Use `if (a ^ b)` instead of `if (a != b)`:
```c
if (s_cur_color ^ s_last_color) { ... }    // ~8 lines, no BinaryBool
if (s_cur_color != s_last_color) { ... }   // ~14 lines, BinaryBool
```
Also works against constants: `if (s_b ^ 0xFF)` instead of `if (s_b != 0xFF)`. Both operands must be the same size.

### 6. Truthiness tests instead of equality comparisons

`if (!x)` and `if (x)` test zero/non-zero directly without materializing a boolean:
```c
if (!s_b) { ... }        // ~8 lines -- direct ALUOP_FLAGS + branch
if (s_b == 0) { ... }    // ~14 lines -- BinaryBool
```
Also applies to `uint16_t` variables (ALUOP16Z_FLAGS: ~10 lines vs ~20 for BinaryBool).

### 7. Nested ifs instead of && operators

Each `&&` causes both sub-expressions to be materialized as BinaryBool values (~8 extra lines per `&&`). Replace with nested ifs:
```c
// Expensive: ~8 extra lines per &&
if (s_sysody_addr != 0 && s_sysody_addr >= s_range_start) { ... }

// Cheap: short-circuit via control flow
if (s_sysody_addr >= s_range_start) {
    if (...) { ... }
}
```

### 8. Sentinel values to eliminate loop guard conditions

Use an out-of-range sentinel value so a guard condition is automatically false:
```c
// With sentinel: s_sysody_ls = 0xFFFF makes s_i >= 0xFFFF always false
// for valid ledger indices (0-2040), no flag needed
s_sysody_ls = 0xFFFF;
if (s_i >= s_sysody_ls) {
    if (s_i <= s_sysody_le) { s_is_sysody = 1; }
}
```

### 9. Decrement-first pattern to avoid == 1 BinaryBool

Decrement before testing rather than comparing to 1 before decrement:
```c
// Expensive: if (remaining == 1) costs ~14 lines (BinaryBool)
if (s_alloc_remaining == 1) { /* last byte */ }
s_alloc_remaining--;

// Cheap: decrement first, then test zero (~8 lines)
s_alloc_remaining--;
if (s_alloc_remaining) { /* not last */ } else { /* last */ }
```

### 10. Remove dead variables

Variables written but never read waste code. After restructuring logic, scan for assignments whose value is never consumed and remove them.

### 11. Static local arrays with aggregate initializers

Declare constant data arrays as `static` local **inside the function** (not file scope). File-scope statics ignore initializers and emit all zeros; static locals trigger MEMCPY4_C_D initialization:
```c
// Wrong: file-scope static ignores the initializer, emits all zeros
static char s_col_strs[28] = {'@','3','1',0, ...};

// Right: static local triggers MEMCPY4_C_D initialization at function entry
static void my_func(void) {
    static char s_col_strs[28] = {'@','3','1',0, ...};
    ...
}
```
Note: initialization runs every call, so prefer this for infrequently-called functions.

### 12. Table lookup to replace dispatch chains

Replace `if (x == 0) ...; else if (x == 1) ...` chains with a table indexed by a shift of x:
```c
// Cheap: one shift, one array access, zero BinaryBool patterns
s_col_off = s_cur_color & 0x00FF;
s_col_off = s_col_off << 2;          // multiply by 4 (entry size)
printf("%s", &s_col_strs[s_col_off]);
```
Declare the table as a static local array with aggregate initializer (see technique 11).

### 13. Exploit natural integer wrap for loop termination

For `uint8_t` counters (0-255), use `do { ... counter++; } while (counter)`. After 255++, wraps to 0 and exits -- no explicit comparison needed:
```c
se_page = 1;
do {
    ...
    se_page++;
} while (se_page);   // 255 iterations, no comparison instruction
```

### 14. Hoist special cases outside loops to eliminate per-iteration branches

If the first (or last) iteration requires special-case handling, emit it explicitly before (or after) the loop:
```c
// Hoist page-0 (always special) outside the 1-255 loop
print("@34");
emit_ch(0xB2);              // page 0: always scratch, emitted once
se_bit_mask = 0x40;
se_page = 1;
do { ... se_page++; } while (se_page);   // pages 1-255 only, no branch
```
