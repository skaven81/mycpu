#include "types.h"
#include "terminal_output.h"
#include "strtoi.h"
extern void exec_chain(char *path);


// Tests for comparison operators between signed/unsigned variables and literals.
// Expected behavior matches GCC's C standard integer promotion rules.
//
// CRITICAL: Tests use DIRECT if(expr) conditions in function bodies.
// Using a helper like check(a > 0, ...) would mask the bug because
// the function parameter type propagates as dest_var into BinaryOp,
// causing constants to inherit the parameter's type rather than the
// default 'int' type, which is the actual bug scenario.
//
// On a 16-bit int platform (Odyssey), C rules say:
//   uint8_t  vs int literal: uint8_t promotes to int -> same as unsigned 8-bit
//   int8_t   vs int literal: int8_t  promotes to int -> signed comparison
//   uint16_t vs int literal: uint16_t > int width  -> unsigned 16-bit
//   int16_t  vs int literal: both are int -> signed 16-bit comparison

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

// fail() reports test failures. Use the pattern:
//   total_tests++;
//   if (bad_condition) { fail("test name"); }
// This ensures the comparison is evaluated in an if() context with no dest_var.
void fail(const char* name) {
    failed_tests++;
    printf("FAIL: ");
    printf(name);
    printf("\n");
}

// ============================================================================
// TEST: uint8_t vs literal integer
// uint8_t promotes to int (16-bit signed); all uint8_t values (0-255) are
// non-negative as int, so MSB-set values like 128 must compare > 0.
//
// BUG: if signed_op is determined by OR of both sides, then:
//   left=uint8_t (unsigned), right=int literal (signed) -> signed_op=True
//   -> signed 8-bit comparison -> 128 treated as -128 -> WRONG
// ============================================================================
void test_u8_vs_literal(void) {
    uint8_t a;

    // Values with MSB clear: these work even with signed 8-bit comparison
    a = 0;
    total_tests++;
    if (a > 0) { fail("u8: 0>0 should be false"); }

    a = 1;
    total_tests++;
    if (!(a > 0)) { fail("u8: 1>0 should be true"); }

    a = 127;
    total_tests++;
    if (!(a > 100)) { fail("u8: 127>100 should be true"); }

    a = 127;
    total_tests++;
    if (!(a < 128)) { fail("u8: 127<128 should be true"); }

    // Values with MSB set (128-255): THESE FAIL with signed 8-bit comparison
    // because 0x80 (-128 signed) < 0, so the > 0 comparison is FALSE when wrong.
    a = 128;
    total_tests++;
    if (!(a > 0)) { fail("u8: 128>0 should be true"); }

    a = 128;
    total_tests++;
    if (!(a > 100)) { fail("u8: 128>100 should be true"); }

    a = 128;
    total_tests++;
    if (!(a > 127)) { fail("u8: 128>127 should be true"); }

    a = 200;
    total_tests++;
    if (!(a > 0)) { fail("u8: 200>0 should be true"); }

    a = 200;
    total_tests++;
    if (!(a > 100)) { fail("u8: 200>100 should be true"); }

    a = 255;
    total_tests++;
    if (!(a > 0)) { fail("u8: 255>0 should be true"); }

    a = 255;
    total_tests++;
    if (!(a > 254)) { fail("u8: 255>254 should be true"); }

    a = 200;
    total_tests++;
    if (a > 200) { fail("u8: 200>200 should be false"); }

    a = 200;
    total_tests++;
    if (!(a >= 200)) { fail("u8: 200>=200 should be true"); }

    a = 200;
    total_tests++;
    if (!(a < 255)) { fail("u8: 200<255 should be true"); }

    a = 255;
    total_tests++;
    if (a < 200) { fail("u8: 255<200 should be false"); }

    a = 200;
    total_tests++;
    if (!(a != 0)) { fail("u8: 200!=0 should be true"); }

    a = 200;
    total_tests++;
    if (!(a == 200)) { fail("u8: 200==200 should be true"); }

    a = 128;
    total_tests++;
    if (!(a != 0)) { fail("u8: 128!=0 should be true"); }
}

// ============================================================================
// TEST: int8_t vs literal integer
// int8_t promotes to int; signed values -128..127 remain negative/positive.
// Signed byte comparison should work correctly here.
// ============================================================================
void test_s8_vs_literal(void) {
    int8_t a;

    a = 0;
    total_tests++;
    if (a > 0) { fail("s8: 0>0 should be false"); }

    a = 1;
    total_tests++;
    if (!(a > 0)) { fail("s8: 1>0 should be true"); }

    a = 127;
    total_tests++;
    if (!(a > 100)) { fail("s8: 127>100 should be true"); }

    a = -1;
    total_tests++;
    if (a > 0) { fail("s8: -1>0 should be false"); }

    a = -128;
    total_tests++;
    if (a > 0) { fail("s8: -128>0 should be false"); }

    a = -1;
    total_tests++;
    if (!(a > -10)) { fail("s8: -1>-10 should be true"); }

    a = -10;
    total_tests++;
    if (a > -1) { fail("s8: -10>-1 should be false"); }

    a = -128;
    total_tests++;
    if (!(a < 0)) { fail("s8: -128<0 should be true"); }

    a = -1;
    total_tests++;
    if (!(a < 0)) { fail("s8: -1<0 should be true"); }
}

// ============================================================================
// TEST: uint16_t vs literal integer
// On 16-bit int platform: uint16_t can't fit in int, so int converts to uint.
// Unsigned comparison: MSB-set values like 32768 must compare greater than 0.
// BUG: signed_op=True -> signed 16-bit -> 32768 treated as -32768 -> WRONG
// ============================================================================
void test_u16_vs_literal(void) {
    uint16_t a;

    a = 0;
    total_tests++;
    if (a > 0) { fail("u16: 0>0 should be false"); }

    a = 1;
    total_tests++;
    if (!(a > 0)) { fail("u16: 1>0 should be true"); }

    // Values with MSB set: FAIL with signed 16-bit comparison
    a = 32768;
    total_tests++;
    if (!(a > 0)) { fail("u16: 32768>0 should be true"); }

    a = 32768;
    total_tests++;
    if (!(a > 100)) { fail("u16: 32768>100 should be true"); }

    a = 65535;
    total_tests++;
    if (!(a > 0)) { fail("u16: 65535>0 should be true"); }

    a = 65535;
    total_tests++;
    if (!(a > 60000)) { fail("u16: 65535>60000 should be true"); }

    a = 60000;
    total_tests++;
    if (!(a < 65535)) { fail("u16: 60000<65535 should be true"); }

    a = 60000;
    total_tests++;
    if (a > 65535) { fail("u16: 60000>65535 should be false"); }

    a = 32768;
    total_tests++;
    if (!(a > 32767)) { fail("u16: 32768>32767 should be true"); }

    a = 60000;
    total_tests++;
    if (!(a != 0)) { fail("u16: 60000!=0 should be true"); }

    a = 60000;
    total_tests++;
    if (!(a == 60000)) { fail("u16: 60000==60000 should be true"); }
}

// ============================================================================
// TEST: int16_t vs literal integer
// Both sides are int; standard signed 16-bit comparison.
// ============================================================================
void test_s16_vs_literal(void) {
    int16_t a;

    a = 0;
    total_tests++;
    if (a > 0) { fail("s16: 0>0 should be false"); }

    a = 1;
    total_tests++;
    if (!(a > 0)) { fail("s16: 1>0 should be true"); }

    a = -1;
    total_tests++;
    if (a > 0) { fail("s16: -1>0 should be false"); }

    a = -32768;
    total_tests++;
    if (a > 0) { fail("s16: -32768>0 should be false"); }

    a = -1;
    total_tests++;
    if (!(a > -100)) { fail("s16: -1>-100 should be true"); }

    a = -100;
    total_tests++;
    if (a > -1) { fail("s16: -100>-1 should be false"); }

    a = -1;
    total_tests++;
    if (!(a < 0)) { fail("s16: -1<0 should be true"); }

    a = 32767;
    total_tests++;
    if (!(a > 0)) { fail("s16: 32767>0 should be true"); }
}

// ============================================================================
// TEST: uint8_t vs uint8_t (two unsigned byte variables)
// Both promote to int; comparison is effectively unsigned 8-bit.
// BUG: signed_op = OR of both sides; since both are unsigned, signed_op=False.
// This test should PASS even without the fix (both sides unsigned).
// ============================================================================
void test_u8_vs_u8(void) {
    uint8_t a;
    uint8_t b;

    a = 200; b = 100;
    total_tests++;
    if (!(a > b)) { fail("u8 vs u8: 200>100 should be true"); }

    a = 200; b = 200;
    total_tests++;
    if (a > b) { fail("u8 vs u8: 200>200 should be false"); }

    a = 128; b = 127;
    total_tests++;
    if (!(a > b)) { fail("u8 vs u8: 128>127 should be true"); }

    a = 255; b = 0;
    total_tests++;
    if (!(a > b)) { fail("u8 vs u8: 255>0 should be true"); }

    a = 0; b = 255;
    total_tests++;
    if (!(a < b)) { fail("u8 vs u8: 0<255 should be true"); }

    a = 200; b = 128;
    total_tests++;
    if (!(a > b)) { fail("u8 vs u8: 200>128 should be true"); }
}

// ============================================================================
// TEST: uint8_t vs int8_t (mixed signedness bytes)
// Both promote to int. uint8_t 128-255 become positive ints.
// int8_t -128..-1 become negative ints.
// BUG: signed_op = OR -> True (int8_t is signed). Signed 8-bit comparison:
//   uint8_t 200 (0xC8=-56) vs int8_t -1 (0xFF=-1): -56 > -1 -> FALSE (WRONG)
// Expected: (int)200 > (int)-1 -> TRUE
// ============================================================================
void test_u8_vs_s8(void) {
    uint8_t a;
    int8_t b;

    a = 200; b = 100;
    total_tests++;
    if (!(a > b)) { fail("u8 vs s8: 200>s8(100) should be true"); }

    a = 200; b = -1;
    total_tests++;
    if (!(a > b)) { fail("u8 vs s8: 200>s8(-1) should be true"); }

    a = 0; b = -1;
    total_tests++;
    if (!(a > b)) { fail("u8 vs s8: 0>s8(-1) should be true"); }

    a = 128; b = -1;
    total_tests++;
    if (!(a > b)) { fail("u8 vs s8: 128>s8(-1) should be true"); }
}

// ============================================================================
// TEST: strtoi return value used in comparison with a large literal.
// Reproduces the asciivid bug: frame 0x0000 rejected as "larger than 2048"
// because the strtoi special-function handler had the C-register save/restore
// in the wrong order, causing A to hold the *old* C value instead of the
// strtoi result.  On hardware C is typically a RAM address (>0x6000), which
// is unsigned-greater-than 2048, triggering the false rejection.
// ============================================================================
void test_strtoi_result(void) {
    uint16_t frame_no;
    int8_t flags8;
    uint8_t flags;

    // Parsing "0x0000" must yield exactly 0.
    frame_no = (uint16_t)strtoi("0x0000", &flags);
    total_tests++;
    if (flags) { fail("strtoi 0x0000: flags should be 0 (success)"); }
    total_tests++;
    if (frame_no != 0) { fail("strtoi 0x0000: result should be 0"); }
    // The asciivid comparison: 0 > 2048 must be false.
    total_tests++;
    if (frame_no > 2048) { fail("strtoi 0x0000: 0 > 2048 should be false"); }

    // Parsing "0x0800" must yield exactly 2048.
    frame_no = (uint16_t)strtoi("0x0800", &flags);
    total_tests++;
    if (flags) { fail("strtoi 0x0800: flags should be 0 (success)"); }
    total_tests++;
    if (frame_no != 2048) { fail("strtoi 0x0800: result should be 2048"); }
    total_tests++;
    if (frame_no > 2048) { fail("strtoi 0x0800: 2048 > 2048 should be false"); }

    // Parsing "0x0801" must yield 2049, which IS > 2048.
    frame_no = (uint16_t)strtoi("0x0801", &flags);
    total_tests++;
    if (flags) { fail("strtoi 0x0801: flags should be 0 (success)"); }
    total_tests++;
    if (frame_no != 2049) { fail("strtoi 0x0801: result should be 2049"); }
    total_tests++;
    if (!(frame_no > 2048)) { fail("strtoi 0x0801: 2049 > 2048 should be true"); }
}

void main(void) {
    test_u8_vs_literal();
    test_s8_vs_literal();
    test_u16_vs_literal();
    test_s16_vs_literal();
    test_u8_vs_u8();
    test_u8_vs_s8();
    test_strtoi_result();

    uint16_t passed = total_tests - failed_tests;
    if (failed_tests == 0) {
        printf("cctest6: %U/%U PASS\n", total_tests, total_tests);
    } else {
        printf("cctest6: %U/%U FAIL\n", passed, total_tests);
    }
    exec_chain("/CCTEST/CCTEST7.ODY");
}
