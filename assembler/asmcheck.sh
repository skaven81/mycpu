#!/bin/bash
# asmcheck.sh - syntax-check Odyssey assembly without producing output
#
# There is no emulator or linter for the Odyssey; a successful assembler
# run IS the syntax check.  This wrapper assembles the given source files
# exactly like an ODY build would (macros + BIOS symbol table) and throws
# the binary away.  Exit 0 means the code assembles.
#
# Usage:
#   asmcheck.sh [options] file.asm [file2.asm ...]
#
# Multiple files are concatenated in the order given, same as the real
# build (put the entry-point file first).
#
# Options:
#   --target <main|ext-d|ext-e|ext-de>   ODY memory target (default: main)
#   --no-symbols                         don't load os/bios/bios.sym
#                                        (for code with no ROM/BIOS calls)
#   --listing                            dump the annotated byte listing
#                                        to stdout instead of discarding

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

TARGET=main
USE_SYMBOLS=1
OUTPUT=/dev/null
SOURCES=()

while [ $# -gt 0 ]; do
    case "$1" in
        --target)
            TARGET="$2"; shift 2 ;;
        --no-symbols)
            USE_SYMBOLS=0; shift ;;
        --listing)
            OUTPUT=-; shift ;;
        -h|--help)
            sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)
            SOURCES+=("$1"); shift ;;
    esac
done

if [ ${#SOURCES[@]} -eq 0 ]; then
    echo "asmcheck: no source files given (try --help)" >&2
    exit 2
fi

OPCODES="$SCRIPT_DIR/opcodes.out"
MACROS="$SCRIPT_DIR/asm_macros"
SYMBOLS="$REPO_ROOT/os/bios/bios.sym"

# opcodes.out is generated (and gitignored); build it if missing
if [ ! -f "$OPCODES" ]; then
    echo "asmcheck: generating $OPCODES" >&2
    (cd "$SCRIPT_DIR" && ./gen_opcodes.sh > /dev/null) || {
        echo "asmcheck: failed to generate opcodes.out" >&2; exit 2; }
fi

SYMARGS=()
if [ "$USE_SYMBOLS" = 1 ]; then
    if [ ! -f "$SYMBOLS" ]; then
        echo "asmcheck: $SYMBOLS not found; build it first with:" >&2
        echo "  make -C $REPO_ROOT/os bios" >&2
        echo "(or pass --no-symbols if the code calls no BIOS functions)" >&2
        exit 2
    fi
    SYMARGS=(--symbols "$SYMBOLS")
fi

"$SCRIPT_DIR/assembler.py" \
    --opcodes "$OPCODES" \
    --macros "$MACROS" \
    "${SYMARGS[@]}" \
    --odyssey --odyssey-target "$TARGET" \
    -o "$OUTPUT" \
    "${SOURCES[@]}"
rc=$?

if [ $rc -eq 0 ]; then
    echo "asmcheck: OK (${SOURCES[*]})" >&2
else
    echo "asmcheck: FAILED (${SOURCES[*]})" >&2
fi
exit $rc
