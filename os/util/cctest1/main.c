#include "types.h"
#include "terminal_output.h"

// ============================================================================
// STRUCT DEFINITIONS (must be at top level per compiler requirements)
// ============================================================================

// Tests visit_Struct, visit_TypeDecl, visit_IdentifierType
struct Point {
    uint8_t x;
    uint8_t y;
};

struct Rect {
    uint8_t x;
    uint8_t y;
    uint8_t width;
    uint8_t height;
};

// Struct with 2-byte members
struct WordStruct {
    uint16_t a;
    uint16_t b;
};

// Nested struct test
struct Container {
    struct Point p1;
    struct Point p2;
    uint8_t flags;
};

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

// Tests visit_Decl with global scope, _get_static_prefix
uint8_t g_byte = 42;
uint16_t g_word = 0x1234;
int8_t g_signed_byte = -5;
int16_t g_signed_word = -1000;

// Global arrays - tests visit_ArrayDecl
uint8_t g_byte_array[5] = {1, 2, 3, 4, 5};
uint16_t g_word_array[3] = {100, 200, 300};

// Global struct - tests struct initialization
struct Point g_point = {10, 20};

// ============================================================================
// TEST RESULT TRACKING
// ============================================================================

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

void report_failure(const char* test_name) {
    printf("FAIL: ");
    printf(test_name);
    printf("\n");
    failed_tests++;
}

void assert_equal_u8(uint8_t actual, uint8_t expected, const char* test_name) {
    total_tests++;
    if (actual != expected) {
        report_failure(test_name);
        printf("  Expected: 0x%x, Got: 0x%x\n", expected, actual);
    }
}

void assert_equal_u16(uint16_t actual, uint16_t expected, const char* test_name) {
    total_tests++;
    if (actual != expected) {
        report_failure(test_name);
        printf("  Expected: 0x%X, Got: 0x%X\n", expected, actual);
    }
}

void assert_equal_i8(int8_t actual, int8_t expected, const char* test_name) {
    total_tests++;
    if (actual != expected) {
        report_failure(test_name);
        printf("  Expected: %d, Got: %d\n", expected, actual);
    }
}

void assert_equal_i16(int16_t actual, int16_t expected, const char* test_name) {
    total_tests++;
    if (actual != expected) {
        report_failure(test_name);
        printf("  Expected: %D, Got: %D\n", expected, actual);
    }
}

// ============================================================================
// TEST: BASIC ARITHMETIC (visit_BinaryOp, visit_Constant)
// ============================================================================

void test_arithmetic() {
    // 8-bit addition - tests byte ALU path in visit_BinaryOp '+'
    uint8_t a_u8 = 10;
    uint8_t b_u8 = 20;
    uint8_t sum_u8 = a_u8 + b_u8;
    assert_equal_u8(sum_u8, 30, "8-bit addition");
    
    // 16-bit addition - tests word ALU path with ALUOP16O
    uint16_t a_u16 = 1000;
    uint16_t b_u16 = 2000;
    uint16_t sum_u16 = a_u16 + b_u16;
    assert_equal_u16(sum_u16, 3000, "16-bit addition");
    
    // 8-bit subtraction
    uint8_t diff_u8 = 50 - 15;
    assert_equal_u8(diff_u8, 35, "8-bit subtraction");
    
    // 16-bit subtraction
    uint16_t diff_u16 = 5000 - 1234;
    assert_equal_u16(diff_u16, 3766, "16-bit subtraction");
    
    // Signed arithmetic - tests emit_sign_extend
    int8_t s1 = -10;
    int8_t s2 = 5;
    int8_t s_sum = s1 + s2;
    assert_equal_i8(s_sum, -5, "Signed 8-bit addition");
    
    int16_t s3 = -1000;
    int16_t s4 = 500;
    int16_t s_diff = s3 - s4;
    assert_equal_i16(s_diff, -1500, "Signed 16-bit subtraction");
}

// ============================================================================
// TEST: BITWISE OPERATIONS (visit_BinaryOp)
// ============================================================================

void test_bitwise() {
    // AND operation - byte path
    uint8_t and_result_u8 = 0xFF & 0x0F;
    assert_equal_u8(and_result_u8, 0x0F, "8-bit AND");
    
    // AND operation - word path
    uint16_t and_result_u16 = 0xF0F0 & 0x0FF0;
    assert_equal_u16(and_result_u16, 0x00F0, "16-bit AND");
    
    // OR operation - byte path
    uint8_t or_result_u8 = 0xF0 | 0x0F;
    assert_equal_u8(or_result_u8, 0xFF, "8-bit OR");
    
    // OR operation - word path
    uint16_t or_result_u16 = 0xF000 | 0x000F;
    assert_equal_u16(or_result_u16, 0xF00F, "16-bit OR");
    
    // XOR operation - byte path
    uint8_t xor_result_u8 = 0xAA ^ 0x55;
    assert_equal_u8(xor_result_u8, 0xFF, "8-bit XOR");
    
    // XOR operation - word path
    uint16_t xor_result_u16 = 0xAAAA ^ 0x5555;
    assert_equal_u16(xor_result_u16, 0xFFFF, "16-bit XOR");
}

// ============================================================================
// TEST: SHIFT OPERATIONS (visit_BinaryOp with constant shifts)
// ============================================================================

void test_shifts() {
    // Left shift - 8-bit, constant value (optimized path)
    uint8_t lshift_u8 = 1 << 3;
    assert_equal_u8(lshift_u8, 8, "8-bit left shift by 3");
    
    // Left shift - 16-bit, constant value (uses ALUOP16O path)
    uint16_t shift_u16 = 1;
    shift_u16 = shift_u16 << 8;
    assert_equal_u16(shift_u16, 256, "16-bit left shift by 8");

    // Right shift - 16-bit, constant value
    shift_u16 = 0x0100 >> 8;
    assert_equal_u16(shift_u16, 1, "16-bit right shift by 8");

    // Left shift - 16-bit, large value (uses optimized path)
    shift_u16 = 1;
    shift_u16 = shift_u16 << 10;
    assert_equal_u16(shift_u16, 0x0400, "16-bit left shift by 10");

    // Right shift - 16-bit, large value (uses optimized path)
    shift_u16 = 0x400;
    shift_u16 = shift_u16 >> 10;
    assert_equal_u16(shift_u16, 0x0001, "16-bit right shift by 10");
    
    // Right shift - 8-bit
    uint8_t rshift_u8 = 64 >> 2;
    assert_equal_u8(rshift_u8, 16, "8-bit right shift by 2");
    
    // Right shift - 16-bit (calls :shift16_a_right)
    uint16_t rshift_u16 = 1024 >> 4;
    assert_equal_u16(rshift_u16, 64, "16-bit right shift by 4");
    
    // Multiple shifts in expression
    uint8_t multi_shift = (8 << 2) >> 1;
    assert_equal_u8(multi_shift, 16, "Multiple shifts");
}

// ============================================================================
// TEST: COMPARISON OPERATIONS (visit_BinaryOp ==, !=)
// ============================================================================

void test_comparisons() {
    // Equality - 8-bit
    uint8_t eq_u8 = (42 == 42);
    assert_equal_u8(eq_u8, 1, "8-bit equality true");
    
    uint8_t neq_u8 = (42 == 43);
    assert_equal_u8(neq_u8, 0, "8-bit equality false");
    
    // Equality - 16-bit
    uint16_t eq_u16 = (1234 == 1234);
    assert_equal_u16(eq_u16, 1, "16-bit equality true");
    
    uint16_t neq_u16 = (1234 == 1235);
    assert_equal_u16(neq_u16, 0, "16-bit equality false");
    
    // Inequality - 8-bit
    uint8_t ineq_u8 = (10 != 20);
    assert_equal_u8(ineq_u8, 1, "8-bit inequality true");
    
    // Inequality - 16-bit
    uint16_t ineq_u16 = (999 != 1000);
    assert_equal_u16(ineq_u16, 1, "16-bit inequality true");
}

// ============================================================================
// TEST: BOOLEAN OPERATIONS (visit_BinaryOp &&, ||)
// ============================================================================

void test_boolean() {
    // Logical AND - both true
    uint8_t and_tt = (1 && 1);
    assert_equal_u8(and_tt, 1, "Logical AND (true && true)");
    
    // Logical AND - one false
    uint8_t and_tf = (1 && 0);
    assert_equal_u8(and_tf, 0, "Logical AND (true && false)");
    
    // Logical OR - both false
    uint8_t or_ff = (0 || 0);
    assert_equal_u8(or_ff, 0, "Logical OR (false || false)");
    
    // Logical OR - one true
    uint8_t or_tf = (0 || 1);
    assert_equal_u8(or_tf, 1, "Logical OR (false || true)");
    
    // Complex boolean expression
    uint8_t complex_bool = ((5 > 3) && (10 == 10)) || (0 != 0);
    assert_equal_u8(complex_bool, 1, "Complex boolean expression");
}

// ============================================================================
// TEST: UNARY OPERATIONS (visit_UnaryOp)
// ============================================================================

void test_unary() {
    // Unary negation - 8-bit (uses %-A_signed%+%AL%)
    int8_t neg_i8 = 10;
    int8_t negated_i8 = -neg_i8;
    assert_equal_i8(negated_i8, -10, "8-bit unary negation");
    
    // Unary negation - 16-bit (calls :signed_invert_a)
    int16_t neg_i16 = 1000;
    int16_t negated_i16 = -neg_i16;
    assert_equal_i16(negated_i16, -1000, "16-bit unary negation");
    
    // Bitwise NOT - 8-bit
    uint8_t not_u8 = ~0x0F;
    assert_equal_u8(not_u8, 0xF0, "8-bit bitwise NOT");
    
    // Bitwise NOT - 16-bit
    uint16_t not_u16 = ~0x00FF;
    assert_equal_u16(not_u16, 0xFF00, "16-bit bitwise NOT");
    
    // Logical NOT - true to false
    uint8_t lnot_t = !1;
    assert_equal_u8(lnot_t, 0, "Logical NOT (true to false)");
    
    // Logical NOT - false to true
    uint8_t lnot_f = !0;
    assert_equal_u8(lnot_f, 1, "Logical NOT (false to true)");
    
    // Unary plus (no-op)
    uint8_t plus_u8 = +42;
    assert_equal_u8(plus_u8, 42, "Unary plus");
}

// ============================================================================
// TEST: INCREMENT/DECREMENT (visit_UnaryOp ++, --, p++, p--)
// ============================================================================

void test_inc_dec() {
    // Pre-increment - 8-bit
    uint8_t pre_inc_u8 = 10;
    uint8_t pre_inc_result = ++pre_inc_u8;
    assert_equal_u8(pre_inc_u8, 11, "Pre-increment value");
    assert_equal_u8(pre_inc_result, 11, "Pre-increment return");
    
    // Post-increment - 8-bit
    uint8_t post_inc_u8 = 10;
    uint8_t post_inc_result = post_inc_u8++;
    assert_equal_u8(post_inc_u8, 11, "Post-increment value");
    assert_equal_u8(post_inc_result, 10, "Post-increment return");
    
    // Pre-decrement - 8-bit
    uint8_t pre_dec_u8 = 10;
    uint8_t pre_dec_result = --pre_dec_u8;
    assert_equal_u8(pre_dec_u8, 9, "Pre-decrement value");
    assert_equal_u8(pre_dec_result, 9, "Pre-decrement return");
    
    // Post-decrement - 8-bit
    uint8_t post_dec_u8 = 10;
    uint8_t post_dec_result = post_dec_u8--;
    assert_equal_u8(post_dec_u8, 9, "Post-decrement value");
    assert_equal_u8(post_dec_result, 10, "Post-decrement return");
    
    // Pre-increment - 16-bit (uses ALUOP16O path)
    uint16_t pre_inc_u16 = 1000;
    uint16_t pre_inc_result_u16 = ++pre_inc_u16;
    assert_equal_u16(pre_inc_u16, 1001, "Pre-increment 16-bit value");
    assert_equal_u16(pre_inc_result_u16, 1001, "Pre-increment 16-bit return");
}

// ============================================================================
// TEST: ASSIGNMENT OPERATIONS (visit_Assignment)
// ============================================================================

void test_assignment() {
    // Simple assignment - 8-bit
    uint8_t assign_u8;
    assign_u8 = 55;
    assert_equal_u8(assign_u8, 55, "Simple 8-bit assignment");
    
    // Simple assignment - 16-bit
    uint16_t assign_u16;
    assign_u16 = 9999;
    assert_equal_u16(assign_u16, 9999, "Simple 16-bit assignment");
    
    // Compound addition assignment - 8-bit
    uint8_t add_assign_u8 = 10;
    add_assign_u8 += 5;
    assert_equal_u8(add_assign_u8, 15, "8-bit += assignment");
    
    // Compound subtraction assignment - 16-bit
    uint16_t sub_assign_u16 = 1000;
    sub_assign_u16 -= 250;
    assert_equal_u16(sub_assign_u16, 750, "16-bit -= assignment");
    
    // Compound shift assignment - left
    uint8_t lshift_assign = 2;
    lshift_assign <<= 3;
    assert_equal_u8(lshift_assign, 16, "<<= assignment");
    
    // Compound shift assignment - right
    uint8_t rshift_assign = 64;
    rshift_assign >>= 2;
    assert_equal_u8(rshift_assign, 16, ">>= assignment");
    
    // Compound AND assignment
    uint8_t and_assign = 0xFF;
    and_assign &= 0x0F;
    assert_equal_u8(and_assign, 0x0F, "&= assignment");
    
    // Compound OR assignment
    uint8_t or_assign = 0xF0;
    or_assign |= 0x0F;
    assert_equal_u8(or_assign, 0xFF, "|= assignment");
    
    // Compound XOR assignment
    uint8_t xor_assign = 0xAA;
    xor_assign ^= 0x55;
    assert_equal_u8(xor_assign, 0xFF, "^= assignment");
}

// ============================================================================
// TEST: ARRAYS (visit_ArrayDecl, visit_ArrayRef)
// ============================================================================

void test_arrays() {
    // Array declaration and initialization - 8-bit elements
    uint8_t arr_u8[5] = {10, 20, 30, 40, 50};
    
    // Array access - tests _add_array_offset with element_size=1
    assert_equal_u8(arr_u8[0], 10, "Array access [0]");
    assert_equal_u8(arr_u8[2], 30, "Array access [2]");
    assert_equal_u8(arr_u8[4], 50, "Array access [4]");
    
    // Array modification
    arr_u8[1] = 99;
    assert_equal_u8(arr_u8[1], 99, "Array modification");
    
    // Array declaration - 16-bit elements
    // Tests _add_array_offset with element_size=2 (power-of-2 shift path)
    uint16_t arr_u16[4] = {100, 200, 300, 400};
    assert_equal_u16(arr_u16[0], 100, "16-bit array access [0]");
    assert_equal_u16(arr_u16[3], 400, "16-bit array access [3]");
    
    // Array of size-3 structs - tests element_size=3 (addition loop path)
    struct Point points[3];
    points[0].x = 1;
    points[0].y = 2;
    points[1].x = 3;
    points[1].y = 4;
    points[2].x = 5;
    points[2].y = 6;
    
    assert_equal_u8(points[0].x, 1, "Struct array [0].x");
    assert_equal_u8(points[1].y, 4, "Struct array [1].y");
    assert_equal_u8(points[2].x, 5, "Struct array [2].x");
    
    // Array of size-4 structs (Rect) - tests element_size=4 (power-of-2 path)
    struct Rect rects[2];
    rects[0].x = 10;
    rects[0].width = 20;
    rects[1].y = 30;
    rects[1].height = 40;
    
    assert_equal_u8(rects[0].x, 10, "Rect array [0].x");
    assert_equal_u8(rects[1].height, 40, "Rect array [1].height");
    
    // Multi-dimensional array - tests nested ArrayRef
    uint8_t matrix[3][3] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };
    
    assert_equal_u8(matrix[0][0], 1, "2D array [0][0]");
    assert_equal_u8(matrix[1][1], 5, "2D array [1][1]");
    assert_equal_u8(matrix[2][2], 9, "2D array [2][2]");
    assert_equal_u8(matrix[1][2], 6, "2D array [1][2]");
}

// ============================================================================
// TEST: POINTERS (visit_UnaryOp &, *, visit_PtrDecl)
// ============================================================================

void test_pointers() {
    // Address-of operator - 8-bit
    uint8_t val_u8 = 42;
    uint8_t *ptr_u8 = &val_u8;
    
    // Dereference operator - tests _deref_load with size=1
    uint8_t deref_val_u8 = *ptr_u8;
    assert_equal_u8(deref_val_u8, 42, "8-bit pointer dereference");
    
    // Modify through pointer
    *ptr_u8 = 77;
    assert_equal_u8(val_u8, 77, "8-bit pointer modification");
    
    // Address-of operator - 16-bit
    uint16_t val_u16 = 1234;
    uint16_t *ptr_u16 = &val_u16;
    
    // Dereference operator - tests _deref_load with size=2
    uint16_t deref_val_u16 = *ptr_u16;
    assert_equal_u16(deref_val_u16, 1234, "16-bit pointer dereference");
    
    // Modify through pointer
    *ptr_u16 = 5678;
    assert_equal_u16(val_u16, 5678, "16-bit pointer modification");
    
    // Pointer to struct
    struct Point pt;
    pt.x = 100;
    pt.y = 200;
    struct Point *ptr_pt = &pt;
    
    // Access through pointer - tests visit_StructRef with '->' operator
    assert_equal_u8(ptr_pt->x, 100, "Struct pointer access ->x");
    assert_equal_u8(ptr_pt->y, 200, "Struct pointer access ->y");
    
    // Modify through pointer
    ptr_pt->x = 111;
    ptr_pt->y = 222;
    assert_equal_u8(pt.x, 111, "Struct pointer modification ->x");
    assert_equal_u8(pt.y, 222, "Struct pointer modification ->y");
}

// ============================================================================
// TEST: POINTER ARITHMETIC (visit_BinaryOp +, - with pointers)
// ============================================================================

void test_pointer_arithmetic() {
    // Pointer arithmetic - 8-bit elements (unit_size=1, no scaling)
    uint8_t bytes[5] = {10, 20, 30, 40, 50};
    uint8_t *ptr_bytes = bytes;
    
    ptr_bytes = ptr_bytes + 2;
    assert_equal_u8(*ptr_bytes, 30, "Pointer + 2 (8-bit)");
    
    ptr_bytes = ptr_bytes - 1;
    assert_equal_u8(*ptr_bytes, 20, "Pointer - 1 (8-bit)");
    
    // Pointer arithmetic - 16-bit elements (unit_size=2, shift path)
    uint16_t words[4] = {100, 200, 300, 400};
    uint16_t *ptr_words = words;
    
    ptr_words = ptr_words + 2;
    assert_equal_u16(*ptr_words, 300, "Pointer + 2 (16-bit)");
    
    // Pointer arithmetic - struct (unit_size=3, addition loop path)
    struct Point points2[3];
    points2[0].x = 1;
    points2[1].x = 2;
    points2[2].x = 3;
    struct Point *ptr_points = points2;
    
    ptr_points = ptr_points + 1;
    assert_equal_u8(ptr_points->x, 2, "Pointer + 1 (struct size 3)");
    
    ptr_points = ptr_points + 1;
    assert_equal_u8(ptr_points->x, 3, "Pointer + 2 (struct size 3)");
    
    // Pointer increment - tests pointer-specific increment path
    uint16_t vals[3] = {111, 222, 333};
    uint16_t *p_inc = vals;
    p_inc++;
    assert_equal_u16(*p_inc, 222, "Pointer increment");
    
    // Pointer decrement
    p_inc--;
    assert_equal_u16(*p_inc, 111, "Pointer decrement");
}

// ============================================================================
// TEST: STRUCTS (visit_Struct, visit_StructRef)
// ============================================================================

void test_structs() {
    // Struct member access with '.' operator
    struct Point pt1;
    pt1.x = 55;
    pt1.y = 66;
    
    assert_equal_u8(pt1.x, 55, "Struct member .x");
    assert_equal_u8(pt1.y, 66, "Struct member .y");
    
    // Struct with 16-bit members - tests _add_member_offset
    struct WordStruct ws;
    ws.a = 0x1234;
    ws.b = 0x5678;
    
    assert_equal_u16(ws.a, 0x1234, "Struct 16-bit member .a");
    assert_equal_u16(ws.b, 0x5678, "Struct 16-bit member .b");
    
    // Nested struct - tests recursive struct access
    struct Container cont;
    cont.p1.x = 10;
    cont.p1.y = 20;
    cont.p2.x = 30;
    cont.p2.y = 40;
    cont.flags = 0xFF;
    
    assert_equal_u8(cont.p1.x, 10, "Nested struct .p1.x");
    assert_equal_u8(cont.p2.y, 40, "Nested struct .p2.y");
    assert_equal_u8(cont.flags, 0xFF, "Nested struct .flags");
    
    // Struct initialization with InitList - tests visit_InitList
    struct Point pt2 = {88, 99};
    assert_equal_u8(pt2.x, 88, "Struct init list .x");
    assert_equal_u8(pt2.y, 99, "Struct init list .y");
}

// ============================================================================
// MAIN TEST RUNNER
// ============================================================================

void main() {
    printf("=== Compiler Test Suite ===\n");
    printf("\n");
    
    test_arithmetic();
    test_bitwise();
    test_shifts();
    test_comparisons();
    test_boolean();
    test_unary();
    test_inc_dec();
    test_assignment();
    test_arrays();
    test_pointers();
    test_pointer_arithmetic();
    test_structs();
    
    printf("\n");
    printf("=== Test Results ===\n");
    printf("Total tests: %U\n", total_tests);
    printf("Failed tests: %U\n", failed_tests);
    
    if (failed_tests == 0) {
        printf("\n*** ALL TESTS PASSED ***\n");
    } else {
        printf("\n*** SOME TESTS FAILED ***\n");
    }
}
