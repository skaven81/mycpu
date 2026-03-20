#!/bin/bash
# Usage: bash c_compiler/run_coverage.sh
# Requires: uv (for coverage.py)
# Run from repo root or any directory - script adjusts paths automatically.
cd "$(dirname "$0")/.."
BIOS_INC="-I$(pwd)/os/bios/lib"
C_COMPILER="c_compiler/c_compiler.py"

uv run --with coverage python -m coverage erase

for cfile in os/util/cctest{1,2,3,4,5,6,7,8,9}/main.c; do
    [ -f "$cfile" ] || continue
    echo "Compiling $cfile..."
    uv run --with coverage python -m coverage run --append \
        "$C_COMPILER" --cpp-args="$BIOS_INC" "$cfile" --output=/dev/null 2>/dev/null \
        || echo "  (compile error for $cfile)"
    # Also handle secondary .c files in the same directory
    dir=$(dirname "$cfile")
    for extra in "$dir"/*.c; do
        [ "$extra" = "$cfile" ] && continue
        [ -f "$extra" ] || continue
        echo "Compiling $extra..."
        uv run --with coverage python -m coverage run --append \
            "$C_COMPILER" --cpp-args="$BIOS_INC" "$extra" --output=/dev/null 2>/dev/null \
            || echo "  (compile error for $extra)"
    done
done

# Verbose=1 pass: compile cctest1 with a single --verbose to exercise the
# emit_verbose line 83 path (verbose>=1 but <2).
echo "Compiling os/util/cctest1/main.c (verbose=1 pass)..."
uv run --with coverage python -m coverage run --append \
    "$C_COMPILER" --cpp-args="$BIOS_INC" os/util/cctest1/main.c --output=/dev/null --verbose 2>/dev/null \
    || echo "  (compile error for verbose=1 pass)"

# Verbose=2 pass: compile cctest1 with --verbose 2 to exercise debug-block/
# emit_debug/emit_verbose paths (codegen.py lines 29-36, 65-83).
echo "Compiling os/util/cctest1/main.c (verbose=2 pass)..."
uv run --with coverage python -m coverage run --append \
    "$C_COMPILER" --cpp-args="$BIOS_INC" os/util/cctest1/main.c --output=/dev/null --verbose --verbose 2>/dev/null \
    || echo "  (compile error for verbose=2 pass)"

# BIOS/ROM pass: compile cctest9 with --target-rom to exercise VAR-style
# global/static emission (lines 183-191, 226-231, 238-243) and the
# '$' static prefix path (lines 225-243).
echo "Compiling os/util/cctest9/main.c (--target-rom pass)..."
uv run --with coverage python -m coverage run --append \
    "$C_COMPILER" --cpp-args="$BIOS_INC" os/util/cctest9/main.c --output=/dev/null --target-rom 2>/dev/null \
    || echo "  (compile error for --target-rom pass)"

echo ""
echo "=== Coverage Report (codegen.py, special_functions.py) ==="
echo "    raise Not/Value/SyntaxError lines excluded (.coveragerc) as unreachable"
echo "    with valid C input -- those are defensive guards for invalid/unsupported code."
uv run --with coverage python -m coverage report \
    --include="c_compiler/codegen.py,c_compiler/special_functions.py"

echo ""
echo "HTML report: coverage_html/index.html"
uv run --with coverage python -m coverage html \
    --include="c_compiler/codegen.py,c_compiler/special_functions.py" \
    -d coverage_html
