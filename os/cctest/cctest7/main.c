#include "types.h"
#include "terminal_output.h"
#include "strtoi.h"
#include "string.h"
#include "malloc.h"
extern void exec_chain(char *path);


// Tests for special function dest_reg='A' vs dest_reg='B' paths.
//
// The compiler's visit_BinaryOp gives LEFT operand dest_reg and RIGHT operand
// other_reg. RIGHT is evaluated FIRST. So:
//   func() > 5     -> func gets dest_reg='A' (LEFT)
//   5 < func()     -> func gets dest_reg='B' (RIGHT)
//
// CRITICAL: Tests use DIRECT if(expr) conditions to avoid masking dest_reg
// assignment through helper function parameters.

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

void fail(const char* name) {
    failed_tests++;
    printf("FAIL: ");
    printf(name);
    printf("\n");
}

// ============================================================================
// Group 1: strcmp dest_reg tests
// strcmp() returns int8_t in AL. When dest_reg='B', A must be saved/restored.
// ============================================================================
void test_strcmp_dest_a(void) {
    // strcmp is LEFT operand -> dest_reg='A'
    // strcmp(s, t) == 0
    total_tests++;
    if (!(strcmp("hello", "hello") == 0)) { fail("strcmp_a: equal strings != 0"); }

    total_tests++;
    if (strcmp("hello", "hello") != 0) { fail("strcmp_a: equal strings should be 0"); }

    total_tests++;
    if (!(strcmp("abc", "def") < 0)) { fail("strcmp_a: abc < def"); }

    total_tests++;
    if (!(strcmp("def", "abc") > 0)) { fail("strcmp_a: def > abc"); }

    total_tests++;
    if (!(strcmp("aaa", "aab") < 0)) { fail("strcmp_a: aaa < aab"); }

    total_tests++;
    if (!(strcmp("aab", "aaa") > 0)) { fail("strcmp_a: aab > aaa"); }
}

void test_strcmp_dest_b(void) {
    // strcmp is RIGHT operand -> dest_reg='B'
    // 0 == strcmp(s, t)
    total_tests++;
    if (!(0 == strcmp("hello", "hello"))) { fail("strcmp_b: equal strings != 0"); }

    total_tests++;
    if (0 != strcmp("hello", "hello")) { fail("strcmp_b: equal strings should be 0"); }

    total_tests++;
    if (!(0 > strcmp("abc", "def"))) { fail("strcmp_b: abc < def (reversed)"); }

    total_tests++;
    if (!(0 < strcmp("def", "abc"))) { fail("strcmp_b: def > abc (reversed)"); }

    total_tests++;
    if (!(0 > strcmp("aaa", "aab"))) { fail("strcmp_b: aaa < aab (reversed)"); }

    total_tests++;
    if (!(0 < strcmp("aab", "aaa"))) { fail("strcmp_b: aab > aaa (reversed)"); }
}

// ============================================================================
// Group 2: strtoi dest_reg tests (CRITICAL)
// :strtoi always writes BL (flags), so both paths clobber other_reg.
// ============================================================================
void test_strtoi_dest_a(void) {
    uint8_t flags;
    uint16_t result;

    // strtoi is LEFT operand -> dest_reg='A'
    // strtoi(...) > value

    // Parse zero
    result = (uint16_t)strtoi("0x0000", &flags);
    total_tests++;
    if (flags) { fail("strtoi_a: 0x0000 flags != 0"); }
    total_tests++;
    if (result != 0) { fail("strtoi_a: 0x0000 != 0"); }
    total_tests++;
    if (result > 0) { fail("strtoi_a: 0x0000 > 0 should be false"); }

    // Parse 0x0050 = 80 decimal
    result = (uint16_t)strtoi("0x0050", &flags);
    total_tests++;
    if (flags) { fail("strtoi_a: 0x0050 flags != 0"); }
    total_tests++;
    if (result != 80) { fail("strtoi_a: 0x0050 != 80"); }

    // Direct comparison: strtoi LEFT, literal RIGHT -> strtoi dest_reg='A'
    total_tests++;
    if (!((uint16_t)strtoi("0x0050", &flags) > 50)) { fail("strtoi_a: 0x0050 > 50"); }

    total_tests++;
    if (!((uint16_t)strtoi("0x0050", &flags) == 80)) { fail("strtoi_a: 0x0050 == 80"); }

    // Parse 0x0800 = 2048
    total_tests++;
    if (!((uint16_t)strtoi("0x0800", &flags) == 2048)) { fail("strtoi_a: 0x0800 == 2048"); }
    total_tests++;
    if ((uint16_t)strtoi("0x0800", &flags) > 2048) { fail("strtoi_a: 0x0800 > 2048 false"); }

    // Parse 0xFFFF = 65535 (MSB set -- unsigned)
    result = (uint16_t)strtoi("0xFFFF", &flags);
    total_tests++;
    if (flags) { fail("strtoi_a: 0xFFFF flags != 0"); }
    total_tests++;
    if (result != 65535) { fail("strtoi_a: 0xFFFF != 65535"); }
    total_tests++;
    if (!(result > 0)) { fail("strtoi_a: 0xFFFF > 0"); }

    // MSB set: 0x8000 = 32768
    result = (uint16_t)strtoi("0x8000", &flags);
    total_tests++;
    if (flags) { fail("strtoi_a: 0x8000 flags != 0"); }
    total_tests++;
    if (result != 32768) { fail("strtoi_a: 0x8000 != 32768"); }
    total_tests++;
    if (!(result > 100)) { fail("strtoi_a: 0x8000 > 100"); }
}

void test_strtoi_dest_b(void) {
    uint8_t flags;
    uint16_t result;

    // strtoi is RIGHT operand -> dest_reg='B'
    // value < strtoi(...)

    // Parse zero: 0 < strtoi("0x0000") should be false
    total_tests++;
    if (0 < (uint16_t)strtoi("0x0000", &flags)) { fail("strtoi_b: 0 < 0x0000 false"); }
    total_tests++;
    if (flags) { fail("strtoi_b: 0x0000 flags != 0"); }

    // 50 < strtoi("0x0050") -> 50 < 80 -> true
    total_tests++;
    if (!(50 < (uint16_t)strtoi("0x0050", &flags))) { fail("strtoi_b: 50 < 0x0050"); }

    // 80 == strtoi("0x0050")
    total_tests++;
    if (!(80 == (uint16_t)strtoi("0x0050", &flags))) { fail("strtoi_b: 80 == 0x0050"); }

    // 2048 == strtoi("0x0800")
    total_tests++;
    if (!(2048 == (uint16_t)strtoi("0x0800", &flags))) { fail("strtoi_b: 2048 == 0x0800"); }

    // 2048 < strtoi("0x0800") should be false (equal)
    total_tests++;
    if (2048 < (uint16_t)strtoi("0x0800", &flags)) { fail("strtoi_b: 2048 < 0x0800 false"); }

    // 0xFFFF test: 0 < 65535
    total_tests++;
    if (!(0 < (uint16_t)strtoi("0xFFFF", &flags))) { fail("strtoi_b: 0 < 0xFFFF"); }
    total_tests++;
    if (flags) { fail("strtoi_b: 0xFFFF flags != 0"); }

    // 0x8000 = 32768 test
    total_tests++;
    if (!(100 < (uint16_t)strtoi("0x8000", &flags))) { fail("strtoi_b: 100 < 0x8000"); }
    total_tests++;
    if (!(32768 == (uint16_t)strtoi("0x8000", &flags))) { fail("strtoi_b: 32768 == 0x8000"); }
}

void test_strtoi_nested(void) {
    uint8_t flags;
    uint16_t offset;

    // strtoi LEFT (dest_reg='A'), offset RIGHT (dest_reg='B')
    // Verify offset value survives strtoi clobbering BL
    offset = 100;
    total_tests++;
    if (!((uint16_t)strtoi("0x0050", &flags) + offset > 150)) { fail("strtoi_nest: 80+100 > 150"); }

    offset = 100;
    total_tests++;
    if ((uint16_t)strtoi("0x0050", &flags) + offset != 180) { fail("strtoi_nest: 80+100 != 180"); }

    // Larger offset
    offset = 1000;
    total_tests++;
    if (!((uint16_t)strtoi("0x0800", &flags) + offset > 2048)) { fail("strtoi_nest: 2048+1000 > 2048"); }

    offset = 1000;
    total_tests++;
    if ((uint16_t)strtoi("0x0800", &flags) + offset != 3048) { fail("strtoi_nest: 2048+1000 != 3048"); }
}

// ============================================================================
// Group 3: strtoi8 dest_reg tests
// Same BL clobber issue as strtoi but 8-bit result.
// ============================================================================
void test_strtoi8_dest_a(void) {
    uint8_t flags;
    uint8_t result;

    // strtoi8 is LEFT -> dest_reg='A'
    result = (uint8_t)strtoi8("50", &flags);
    total_tests++;
    if (flags) { fail("strtoi8_a: 50 flags != 0"); }
    total_tests++;
    if (result != 50) { fail("strtoi8_a: 50 != 50"); }

    total_tests++;
    if (!((uint8_t)strtoi8("50", &flags) > 25)) { fail("strtoi8_a: 50 > 25"); }

    total_tests++;
    if (!((uint8_t)strtoi8("50", &flags) == 50)) { fail("strtoi8_a: 50 == 50"); }

    // Hex value
    total_tests++;
    if (!((uint8_t)strtoi8("0xFF", &flags) == 255)) { fail("strtoi8_a: 0xFF == 255"); }

    total_tests++;
    if (!((uint8_t)strtoi8("0x80", &flags) > 0)) { fail("strtoi8_a: 0x80 > 0"); }
}

void test_strtoi8_dest_b(void) {
    uint8_t flags;

    // strtoi8 is RIGHT -> dest_reg='B'
    total_tests++;
    if (!(25 < (uint8_t)strtoi8("50", &flags))) { fail("strtoi8_b: 25 < 50"); }

    total_tests++;
    if (!(50 == (uint8_t)strtoi8("50", &flags))) { fail("strtoi8_b: 50 == 50"); }

    total_tests++;
    if (50 < (uint8_t)strtoi8("50", &flags)) { fail("strtoi8_b: 50 < 50 false"); }

    total_tests++;
    if (!(0 < (uint8_t)strtoi8("0xFF", &flags))) { fail("strtoi8_b: 0 < 0xFF"); }

    total_tests++;
    if (!(255 == (uint8_t)strtoi8("0xFF", &flags))) { fail("strtoi8_b: 255 == 0xFF"); }

    total_tests++;
    if (!(0 < (uint8_t)strtoi8("0x80", &flags))) { fail("strtoi8_b: 0 < 0x80"); }
}

// ============================================================================
// Group 4: malloc_blocks dest_reg tests
// malloc_blocks returns pointer in A. When dest_reg='B', A is saved/restored.
// ============================================================================
void test_malloc_dest_a(void) {
    void *ptr;
    char *buf;

    // malloc_blocks is LEFT -> dest_reg='A'
    // malloc_blocks(1) != 0
    total_tests++;
    ptr = malloc_blocks(1);
    if (ptr == NULL) { fail("malloc_a: returned NULL"); }

    // Write and read back to confirm pointer validity
    buf = (char *)ptr;
    *buf = 42;
    total_tests++;
    if (*buf != 42) { fail("malloc_a: write/read failed"); }
    free(ptr);

    // Direct comparison: malloc LEFT, 0 RIGHT
    ptr = malloc_blocks(1);
    total_tests++;
    if (!((uint16_t)ptr != 0)) { fail("malloc_a: ptr != 0 direct"); }
    free(ptr);

    // Allocate larger block
    ptr = malloc_blocks(2);
    total_tests++;
    if (ptr == NULL) { fail("malloc_a: 2-block returned NULL"); }
    buf = (char *)ptr;
    buf[0] = 10;
    buf[31] = 20;
    total_tests++;
    if (buf[0] != 10) { fail("malloc_a: 2-block buf[0]"); }
    total_tests++;
    if (buf[31] != 20) { fail("malloc_a: 2-block buf[31]"); }
    free(ptr);
}

void test_malloc_dest_b(void) {
    void *ptr;
    char *buf;

    // malloc_blocks is RIGHT -> dest_reg='B'
    // 0 != malloc_blocks(1)
    ptr = malloc_blocks(1);
    total_tests++;
    if (!(0 != (uint16_t)ptr)) { fail("malloc_b: 0 != ptr"); }

    // Write and read back
    buf = (char *)ptr;
    *buf = 99;
    total_tests++;
    if (*buf != 99) { fail("malloc_b: write/read failed"); }
    free(ptr);

    // Allocate and verify
    ptr = malloc_blocks(2);
    total_tests++;
    if (NULL == ptr) { fail("malloc_b: 2-block NULL"); }
    buf = (char *)ptr;
    buf[0] = 55;
    buf[15] = 77;
    total_tests++;
    if (buf[0] != 55) { fail("malloc_b: 2-block buf[0]"); }
    total_tests++;
    if (buf[15] != 77) { fail("malloc_b: 2-block buf[15]"); }
    free(ptr);
}

// ============================================================================
// Group 5: Complex nested expressions
// Multiple special function calls in one expression.
// ============================================================================
void test_complex_nested(void) {
    uint8_t flags1;
    uint8_t flags2;
    uint16_t result;

    // strcmp and strtoi in same expression (short-circuit &&)
    // strcmp LEFT (dest_reg='A'), 0 RIGHT -> strcmp dest_reg='A'
    // strtoi LEFT (dest_reg='A'), 100 RIGHT -> strtoi dest_reg='A'
    total_tests++;
    if (!(strcmp("abc", "abc") == 0 && (uint16_t)strtoi("0x0080", &flags1) > 100)) {
        fail("complex: strcmp==0 && strtoi>100");
    }

    // Two strtoi calls: LEFT gets dest_reg='A', RIGHT gets dest_reg='B'
    // x = strtoi(a) + strtoi(b) -- but RIGHT evaluated first
    result = (uint16_t)strtoi("0x000A", &flags1) + (uint16_t)strtoi("0x0014", &flags2);
    total_tests++;
    if (result != 30) { fail("complex: 10 + 20 != 30"); }
    total_tests++;
    if (flags1) { fail("complex: 0x000A flags != 0"); }
    total_tests++;
    if (flags2) { fail("complex: 0x0014 flags != 0"); }

    // Larger values to catch truncation
    result = (uint16_t)strtoi("0x0100", &flags1) + (uint16_t)strtoi("0x0200", &flags2);
    total_tests++;
    if (result != 768) { fail("complex: 256 + 512 != 768"); }

    // strtoi on both sides of comparison
    // LEFT strtoi dest_reg='A', RIGHT strtoi dest_reg='B'
    total_tests++;
    if (!((uint16_t)strtoi("0x0100", &flags1) < (uint16_t)strtoi("0x0200", &flags2))) {
        fail("complex: 0x100 < 0x200");
    }

    total_tests++;
    if (!((uint16_t)strtoi("0x0200", &flags1) > (uint16_t)strtoi("0x0100", &flags2))) {
        fail("complex: 0x200 > 0x100");
    }

    total_tests++;
    if (!((uint16_t)strtoi("0x00FF", &flags1) == (uint16_t)strtoi("0x00FF", &flags2))) {
        fail("complex: 0xFF == 0xFF");
    }

    // strcmp on both sides
    total_tests++;
    if (!(strcmp("abc", "def") < strcmp("xyz", "abc"))) {
        fail("complex: strcmp abc,def < strcmp xyz,abc");
    }
}

// ============================================================================
// Group 6: Register pressure / chained binary ops
// Verify values survive through multi-step expression evaluation.
// ============================================================================
void test_register_pressure(void) {
    uint8_t flags;
    uint16_t a;
    uint16_t b;
    uint16_t result;

    // result = strtoi() + var -- strtoi LEFT (dest_reg='A'), var RIGHT (dest_reg='B')
    a = 500;
    result = (uint16_t)strtoi("0x0100", &flags) + a;
    total_tests++;
    if (result != 756) { fail("regpres: 256 + 500 != 756"); }

    // result = var + strtoi() -- var LEFT (dest_reg='A'), strtoi RIGHT (dest_reg='B')
    a = 500;
    result = a + (uint16_t)strtoi("0x0100", &flags);
    total_tests++;
    if (result != 756) { fail("regpres: 500 + 256 != 756"); }

    // Chained: strtoi() + strtoi() + var
    a = 50;
    result = (uint16_t)strtoi("0x000A", &flags) + (uint16_t)strtoi("0x0014", &flags) + a;
    total_tests++;
    if (result != 80) { fail("regpres: 10+20+50 != 80"); }

    // Variable on both sides around function call
    a = 100;
    b = 100;
    total_tests++;
    if (!(a + (uint16_t)strtoi("0x0032", &flags) > b)) {
        fail("regpres: 100+50 > 100");
    }

    // Compare two expressions each containing a variable and a function call
    a = 10;
    b = 500;
    total_tests++;
    if (!((a + (uint16_t)strtoi("0x0100", &flags)) < b)) {
        fail("regpres: 10+256 < 500");
    }

    a = 10;
    b = 200;
    total_tests++;
    if ((a + (uint16_t)strtoi("0x0100", &flags)) < b) {
        fail("regpres: 10+256 < 200 false");
    }

    // malloc result used in arithmetic
    a = (uint16_t)malloc_blocks(1);
    total_tests++;
    if (a == 0) { fail("regpres: malloc for arith"); }
    // Just verify pointer is in dynamic RAM range (0x6000-0xAFFF)
    total_tests++;
    if (!(a >= 24576)) { fail("regpres: ptr >= 0x6000"); }
    total_tests++;
    if (!(a < 45056)) { fail("regpres: ptr < 0xB000"); }
    free((void *)a);
}

void main(void) {
    test_strcmp_dest_a();
    test_strcmp_dest_b();
    test_strtoi_dest_a();
    test_strtoi_dest_b();
    test_strtoi_nested();
    test_strtoi8_dest_a();
    test_strtoi8_dest_b();
    test_malloc_dest_a();
    test_malloc_dest_b();
    test_complex_nested();
    test_register_pressure();

    uint16_t passed = total_tests - failed_tests;
    if (failed_tests == 0) {
        printf("cctest7: %U/%U PASS\n", total_tests, total_tests);
    } else {
        printf("cctest7: %U/%U FAIL\n", passed, total_tests);
    }
    exec_chain("/CCTEST/CCTEST8.ODY");
}
