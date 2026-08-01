---
name: ody-c
description: Wire Wrap Odyssey C compiler reference. Use when writing C code for the Odyssey - covers which C constructs compile / fail / silently miscompile, the BIOS header inventory and include rules, build integration, compiler error diagnosis, and validated code size optimization techniques.
version: 2.0.0
---

# Odyssey C Compiler Reference

`c_compiler/c_compiler.py` -- a subset of C99, generates unoptimized Odyssey
assembly. Types: `char` (8-bit), `int`/`short` (16-bit), pointers (16-bit).
Convention: params on heap, D register as frame pointer, caller-cleanup.
Uses GCC `cpp` for preprocessing; the ONLY headers are `os/bios/lib/*.h`.

**Verify every C file compiles before delivering: `make -C os/util/<name>`
(or the relevant directory).** Compile errors stop the Makefile; there are no
warnings of any kind, so anything suspicious must be caught by reading.

## Constructs that DO NOT COMPILE (design around these up front)

- **No `*`, `/`, `%` operators -- at all** (nor `*=` `/=` `%=`). The single
  biggest first-try failure. Use shifts for powers of two, repeated addition,
  or an assembly helper. NOTE: `:mul16` and `:div8` in `os/bios/lib/math.asm`
  are NOT C-callable (non-standard heap contracts); write an .asm wrapper
  (pattern: `os/system/900a-cmd_memstat_helpers.asm`).
- **No ternary `?:`, `goto`, `union`, `enum`, function pointers, designated
  initializers, compound literals.** Use `#define` for named constants.
- **Constant contexts accept only bare literals** (int/char/hex, or a
  `#define` that expands to one). No `N+1`, no `sizeof(...)`, no `-1`:
  - array dimensions: `char buf[8]` ok; `char buf[N+1]` fails
  - `case` labels: `case 0x10:` ok; `case -1:` fails
  - aggregate initializers: `{1,2,3}` ok; `{-1,2}` fails (negate at runtime)
  - `char *msgs[2] = {"aa","bb"}` fails -- assign elements one at a time
- **`for (;;)` crashes the compiler** -- a `for` loop must have a condition;
  use `while (1)`.
- **Shift counts must be literal constants**: `x << 2` ok, `x << n` fails.
- **Function names must be >= 4 characters** (assembler label rule).
- **Parameters must be pointers or scalars**: no by-value structs/arrays and
  no array syntax -- `void f(uint8_t *a)` ok; `void f(uint8_t a[])` and
  `void f(struct P p)` fail.
- **Structs must be defined at file scope** (no local struct types). Max 2
  array dimensions.
- **No `long`, `float`, `double`, `bool`** (use `uint8_t` with 0/1), no libc
  headers (`#include <stdio.h>` is a parse error).
- **`static` local variables require an explicit initializer.**
- Calling an undeclared function is an error (no implicit declarations), but
  functions defined later in the same file need no forward declaration.

## Constructs that COMPILE BUT ARE WRONG (silent miscompiles)

- **`&&` and `||` are BITWISE, not logical, and NOT short-circuiting.**
  `if (a && b)` computes `a & b`: with a=1, b=2 the result is 0 (false!),
  and both sides are ALWAYS evaluated (`p && p->x` dereferences NULL).
  Only safe when both operands are already 0/1. **Default to nested `if`s**
  -- which are also smaller (see optimization #7).
- **`(void)f();` generates NO code** -- the call vanishes entirely. Never
  cast a call to void.
- **Returning a struct by value** compiles but returns garbage (low byte of
  an address). Return through an out-pointer parameter.
- **Declare `main` as `int main(int argc, char **argv)` and `return` an
  exit code.** The BIOS exec loop pushes argv+argc to the heap before every
  program and pops a 16-bit exit code after (see `os/README-bios-exec.md`);
  this signature consumes and produces exactly that, keeping the heap
  balanced. `void main()` compiles but leaves the BIOS-pushed args on the
  heap and returns a garbage exit code -- technically safe (the BIOS
  collapses the heap before each launch) but poor practice. Argument
  facts: `argv[0]` is the
  command name, `argv[argc]` is NULL, argc==0/argv==NULL when not launched
  from a shell command, and argv memory is BIOS-owned -- never `free()` it.
  (The Makefile greps sources for `int main`/`void main` to place the entry
  file first on the assembler command line; in multi-file programs, also
  name the entry file so it sorts first, e.g. `00-main.c`.)
- **BIOS special functions dispatch on the `extern` storage class.** printf,
  print, malloc_*, str*, fat16_*, ext*, halt, etc. get custom register-based
  call sequences ONLY if declared `extern` (the BIOS headers do this -- so
  always `#include` the header rather than hand-declaring).
- **Evaluation order is right-to-left** for binary operands and call
  arguments -- side effects in argument lists happen in reverse source order.
- **`printf`/`print` format argument must be a simple expression**: a string
  literal or a plain `char *` variable. `printf(msgs[i])` fails to compile;
  assign to a local `char *` first. (Args after the format are unrestricted.)
- Known bug: **inline cast-to-pointer as a function argument fails**
  (`func((void *)0xD000)` -> "Incompatible types"). Declare a typed local
  (`char *buf = (char *)0xD000;`) and pass that.
- String literals must not BEGIN with `:` or `.` (assembler treats the data
  item as a label). Restructure or emit that first char separately.
- `const`/`volatile` parse but are completely ignored. Narrowing assignments
  (`uint8_t b = w;`) are silent.

## What works (use freely)

`if/else`, `while`, `do/while`, `for` (with condition; C99 init-decl ok),
`switch/case/default` with fall-through (body may contain ONLY case/default
at its top level; no statements before the first case; no duplicate cases),
`break`, `continue`, comma operator, recursion (hardware stack is 256 bytes
-- keep it shallow), `struct` (file scope), `typedef` (incl. anonymous
struct typedefs), 2D arrays, `sizeof` (variables, types, members), all of
`+ - & | ^ ~ ! << >> == != < <= > >=`, `++`/`--`, compound assignment except
`*= /= %=`, casts incl. widening with correct sign extension,
`*(char *)0xD000 = 5;` absolute pointer access, pointer arithmetic (scaled
by pointee size; `void *` stride 1), signed/unsigned comparison follows C
promotion rules, `extern` globals map to assembly `$name` variables.

**Global and static initializers work** -- scalars, arrays, nested structs,
inferred dimensions (`uint8_t t[] = {1,2,3};`), string-array init
(`char b[8] = "hi";` zero-fills the tail). They are emitted into a
`.__global_local_init__` routine called at program start (static locals:
re-initialized on every call to their function, not once).

## BIOS headers (`os/bios/lib/*.h`)

`#include "name.h"`; the Makefile passes the include path. **Headers do not
include their own dependencies -- order matters. Include `types.h` first,
always** (`uint8_t/uint16_t/int8_t/int16_t`, `struct uint32 {hi,lo}`,
`true/false/NULL` -- there is NO `bool`).

| Header | Contents |
|--------|----------|
| `terminal_output.h` | `printf(char*,...)`, `print(char*)`, `putchar(char)`, `putchar_direct(char)` |
| `sprintf.h` | `sprintf(char *dest, char *fmt, ...)` |
| `halt.h` | `halt()` (emits a bare HLT) |
| `malloc.h` | `malloc_blocks/calloc_blocks/malloc_segments/calloc_segments(uint8_t)` -> `void*`, `free(void*)` |
| `string.h` | `strcmp/strcasecmp(a,b)`, `strcpy(src,dest)` (ARG ORDER! does not write the NUL), `strupper(src,dest)`, `strprepend(c,s)`, `strsplit(...)` |
| `strtoi.h` | `strtoi(char*, uint8_t *flags)`, `strtoi8(...)` -- clobber BL |
| `extmalloc.h` | `extmalloc()`, `extfree`, `extpage_d_push/pop`, `extpage_e_push/pop` |
| `clearscreen.h` | `clear_screen(char, uint8_t color)` |
| `cursor.h` | `cursor_init/off/on()` |
| `shell_argv.h` | `shell_get_argv_n(uint8_t)` -> `char*` (SYSTEM.ODY built-ins ONLY) |
| `trace.h` | `trace()`, `trace_begin/end()`, `trace_0()..trace_7()` |
| `fat16_*.h` (8 files) | fs handles, dirent parsing, dirwalk, pathfind, readfile, cluster math -- most need `fat16_util.h` (+ `types.h`) first |

**No header exists** for math.asm, memcpy.asm, memfill.asm, timer.asm,
keyboard.asm, uart.asm, heap.asm, system.asm -- most do NOT follow the C
calling convention; do not declare them `extern` yourself. Write a small
.asm wrapper obeying the standard convention (pop args off heap, push
result) and declare THAT `extern`.

printf format specifiers (lowercase = byte, UPPERCASE = word): `%%`, `%c`,
`%2` binary, `%b` BCD digit, `%x`/`%X` hex, `%u`/`%U` unsigned dec,
`%d`/`%D` signed dec, `%s` string.

## Build integration

A standalone program lives in `os/util/<name>/` -- the DIRECTORY name (max
8 chars) becomes `NAME.ODY`. Three files:

```make
# os/util/<name>/Makefile -- this is the whole file
include ../../config.mk
INSTALL_SUBDIR := SYS
include ../../rules.mk
```

plus the source (`.c` and `.asm` auto-discovered, `%.c -> %.asm ->` binary)
and a `.gitignore` listing generated `.asm` files. Optional Makefile
overrides: `C_SOURCES`, `ASM_SOURCES`, `C_FLAGS`, `MEM_TARGET`
(`main|ext-d|ext-e|ext-de`). Build: `make -C os/util/<name>`; the BIOS must
be built first (`make -C os bios` provides `bios.sym` and the C helper ROM
routines). `make C_VERBOSE=verbose` tees `c_compiler.log`.

Idiomatic skeleton:

```c
#include "types.h"
#include "terminal_output.h"

struct P { uint8_t x; uint16_t y; };     /* structs at file scope only */

static uint16_t s_count = 0;             /* file-scope statics are cheap */

static void show(struct P *p);           /* params by pointer only */

int main(int argc, char **argv) {        /* the exec-loop interface */
    struct P p;
    p.x = 1;
    p.y = 500;
    if (argc) { printf("cmd=%s\n", argv[0]); }
    show(&p);
    return 0;                            /* exit code -- required */
}

static void show(struct P *p) {
    printf("x=%u y=%U\n", p->x, p->y);
}
```

Mixing assembly: put a `.asm` alongside, export `:label` functions with the
standard heap convention, declare them `extern` in C.

## Dividing work between C and assembly

C is much more readable but the compiler generates verbose, inefficient
code -- there is no optimizer. The house pattern:

- **C** for program structure, argument handling, and logic that runs a
  handful of times.
- **Hand-written `.asm` helpers** (same directory, auto-linked) for tight
  loops, ISRs, and anything cycle- or size-critical. A 5-line C function in
  a hot loop can cost 150+ generated lines; the same function hand-written
  is ~20 instructions.
- ISRs must NEVER be written in C: the compiler's prolog/epilog uses the
  heap functions, which unmask interrupts internally (fatal inside a
  handler). ISRs are always hand-written assembly.

Data placement: in ODY builds the compiler emits globals/statics as data
blocks INSIDE the binary (localized, no address collisions -- this is why
file-scope statics are the recommended cheap storage). Only `--target-rom`
(BIOS) builds use `VAR global` pool addresses. For large state, consider an
extended-memory page: `extmalloc()` once, then access variables at constant
offsets via pointer casts (`*(uint8_t *)0xD000` etc.) -- no malloc or
pointer arithmetic needed.

New shared-library candidates: implement them compiled-in first (in the
ODY), and only after hardware testing propose promotion into `os/bios/lib/`
-- a BIOS change forces an EEPROM reflash and a recompile of ALL software.
The same rule covers CHANGES to existing BIOS libraries: copy the routine
into a test ODY, iterate there, and update the BIOS copy only once proven.
The BIOS is by design nearly full; if a promotion candidate does not fit,
look for a single-consumer BIOS routine to demote into its one user
(details and how to count consumers: skill **ody-asm**, "Where code should
live").

## Reading compiler errors

Errors print the exception, then one `At source: file:line:col` per AST
level -- **the FIRST `At source:` line is the real location.** Category by
exception type:

- `NotImplementedError: BinaryOp ... op X` -> unsupported operator (`* / %`)
- `NotImplementedError: <Node> visitor not implemented` -> unsupported
  construct (ternary, goto, union, enum...)
- `NotImplementedError: ... mode get_value ...` -> non-literal in a constant
  context (array dim, case label, initializer element)
- `SyntaxError: Incompatible types in function call` -> pointer/size
  mismatch or the inline-cast quirk
- `AttributeError: 'NoneType' ...` with no source coord -> an edge case like
  `for(;;)` or a string-pointer-array initializer

## Code size optimization techniques (all validated on real programs)

The compiler is a straight AST walker -- it optimizes nothing. A 16.6%
size reduction on `900-cmd_memstat.c` came from these, in impact order:

1. **File-scope statics instead of locals.** Locals at heap offset N cost
   16-bit D+N arithmetic per access; statics are a fixed address. Also
   eliminates frame advance/retreat in the prolog/epilog. (For big buffers
   use `malloc_blocks()` -- statics are embedded in the binary.)
2. **Move hot small functions to assembly.** Calling-convention overhead
   dwarfs tiny function bodies (162 generated lines -> 22 hand-written).
3. **Pre-computed constant data instead of emit loops** (the assembler
   accepts mixed `"str" 0xNN "str\0"` data lines).
4. **Avoid BinaryBool materialization -- the primary waste.** Every
   `== != < >=` comparison builds a 0/1 in AL (~14-20 lines); truthiness
   tests (`if (x)`, `if (!x)`) cost ~8. Count `binarybool_` labels in
   generated .asm to measure progress.
5. **XOR for inequality**: `if (a ^ b)` instead of `if (a != b)` (~8 vs ~14
   lines; operands must be same size).
6. **Truthiness instead of `== 0` / `!= 0`.**
7. **Nested `if`s instead of `&&`** -- smaller AND correct (see silent
   miscompiles above).
8. **Sentinel values** (e.g. 0xFFFF) to make a guard comparison always-false
   instead of tracking a flag.
9. **Decrement-then-test-zero** instead of `if (x == 1)` before decrement.
10. **Delete dead variables** (no warnings will tell you).
11. **Aggregate-initialized lookup tables**: declare constant tables as
    `static` arrays with initializers -- works at file scope OR function
    scope (function-scope static arrays re-run their MEMCPY4 init on every
    call, so file scope is better for hot functions).
12. **Table lookup instead of if/else-if dispatch chains** (shift + index).
13. **Exploit uint8_t wraparound for 256-iteration loops**:
    `do { ... } while (++counter);` needs no comparison at all.
14. **Hoist first/last-iteration special cases out of the loop body.**
