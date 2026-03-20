# C Compiler Coverage

## Measuring coverage

Run from the repository root:

```bash
bash c_compiler/run_coverage.sh
```

Requires `uv` to be installed (used to pull in `coverage.py` on the fly).

The script compiles all `os/util/cctest*/main.c` files plus several special
passes (verbose=1, verbose=2, --target-rom) and then generates both a
terminal report and an HTML report at `coverage_html/index.html`.

### Interpreting the report

`raise NotImplementedError`, `raise ValueError`, and `raise SyntaxError` lines
are excluded from the count via `.coveragerc` in the repo root.  Those are
defensive guards for invalid or unimplemented input -- they cannot be reached
by a well-formed C program, so they are not a useful coverage target.

With that exclusion, `codegen.py` is at **97%** (44 lines not covered).

## Understanding the test files

| Directory | Purpose |
|-----------|---------|
| `os/util/cctest1/` | Basic expressions, arithmetic, control flow |
| `os/util/cctest2/` | Strings and printf |
| `os/util/cctest3/` | Arrays and structs |
| `os/util/cctest4/` | Pointers |
| `os/util/cctest5/` | More pointer and string ops |
| `os/util/cctest6/` | Switch statements |
| `os/util/cctest7/` | Comparison and logical operators |
| `os/util/cctest8/` | Coverage gap tests (round 1): strcmp path, BinaryOp with array decay |
| `os/util/cctest9/` | Coverage gap tests (round 2): sizeof constants, for-init decl, nested loops, double-pointer indexing, static scalars, BIOS VAR emission |

The `run_coverage.sh` script also has two special-purpose passes:

- **verbose=1 pass** -- re-compiles `cctest1` with `--verbose` to exercise
  the `emit_verbose` path that only fires at verbosity level 1.
- **verbose=2 pass** -- re-compiles `cctest1` with `--verbose --verbose` to
  exercise debug-block and emit_debug paths.
- **--target-rom pass** -- re-compiles `cctest9` with `--target-rom` to
  exercise BIOS-mode `VAR global` emission and the zero-fill loop for
  uninitialized globals.

## Adding more coverage tests

1. Open `coverage_html/index.html` in a browser and identify uncovered (red)
   lines in `codegen.py`.

2. Determine which C construct would cause the compiler to execute that line.
   The function name (e.g. `visit_BinaryOp`) and surrounding context usually
   make this clear.

3. Add a test to the most relevant `cctest` directory.  `cctest9/main.c` is
   a good place for targeted gap-filling tests: each test function documents
   the line numbers it is intended to cover.  Follow the existing pattern:

   ```c
   // ============================================================================
   // Test: <description of what codegen.py path is exercised>
   // Lines covered: <line numbers and brief explanation>
   // ============================================================================
   void test_my_feature(void) {
       // ... code that triggers the path ...
       total_tests++;
       if (result != expected) { fail("my_feature: description"); }
   }
   ```

   Then call `test_my_feature()` from `main()`.

4. If you need a new compilation pass (e.g. a different compiler flag), add it
   to `run_coverage.sh` following the existing verbose/ROM pass patterns.

5. Re-run `bash c_compiler/run_coverage.sh` and check that coverage improved.

### Special-purpose passes

If a code path only fires under a specific compiler flag (e.g. `--target-rom`
for BIOS-mode emission), adding C code to a regular cctest will not help.
Instead, add the C construct to a file that is already compiled under that
flag (e.g. `cctest9` for the `--target-rom` pass) or add a new special pass
in `run_coverage.sh`.

## Currently uncovered reachable paths (44 lines)

These 44 lines are not defensive raises, meaning they are reachable with
valid C -- but require constructs that are not yet present in any cctest:

| Lines | What is needed |
|-------|---------------|
| 44, 48 | An exception with no `coord` attribute on the AST node (rare) |
| 94, 98, 104 | `emit_stackpush/pop` called with a non-empty `skip=` set |
| 429 | A `case` value that triggers a `NotImplementedError` inside `get_value` |
| 484-485 | A `typedef` declaration visited in `codegen` mode |
| 496 | A `TypeDecl` with no name during `type_collection` |
| 515 | An unregistered base type during `type_collection` |
| 598 | `visit_StructRef generate_rvalue` for a struct member larger than 2 bytes |
| 610 | A function declared more than once (re-declaration) |
| 635 | A `Decl` `return_var` where the inner visit returns no name |
| 749-750 | `visit_Typename` called with `return_typespec` mode |
| 769 | A nested function definition (rare) |
| 812 | A variadic parameter (`...`) in a function with `verbose >= 1` |
| 891-896, 902 | Passing an array or struct by pointer as a function argument |
| 1115-1116 | `visit_ArrayRef generate_rvalue` returning address of large struct element |
| 1130 | `visit_Constant return_typespec` for a string literal (e.g. `sizeof("x")`) |
| 1142-1143 | `visit_Constant get_value` for a char or string constant |
| 1147-1148 | `visit_Constant return_array_dim` for a string (e.g. `char s[] = "hi"`) |
| 1316-1319 | `visit_ID return_typespec` mode |
| 1468-1469 | `sizeof` of an expression where `return_typespec` also raises |
| 1593 | Dereferencing a `void *` pointer |
| 1600-1601 | Dereferencing a pointer to a value larger than 2 bytes |
| 1648-1649 | `BinaryOp` where only the right operand is non-constant |
| 1984-1985 | `visit_Compound` called in a mode other than `codegen` |
| 2171 | `_add_array_offset` called with a `Variable` arg instead of an int size |
| 2222, 2228 | `_deref_load` with `addr_reg` being `C` or `D` (not `A` or `B`) |
