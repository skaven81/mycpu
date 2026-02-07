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
// TEST: signed and unsigned greater/less than comparisons
// ============================================================================
void test_gt_lt() {
    int8_t i8ten = 10;
    int8_t i8negten = -10;
    int8_t i8one = 1;
    int8_t i8negone = -1;

    uint8_t u8ten = 10;
    uint8_t u8one = 1;

    int16_t i16ten = 10;
    int16_t i16negten = -10;
    int16_t i16one = 1;
    int16_t i16negone = -1;

    uint16_t u16ten = 10;
    uint16_t u16one = 1;


    assert_equal_u8(u8one < u8ten, 1, "1 < 10 (true)");
    assert_equal_u8(u8ten < u8one, 0, "10 < 1 (false)");
    assert_equal_u8(u8one > u8ten, 0, "1 > 10 (false)");
    assert_equal_u8(u8ten > u8one, 1, "10 > 1 (true)");
    assert_equal_u8(u8ten > u8ten, 0, "10 > 10 (false)");
    assert_equal_u8(u8ten >= u8ten, 1, "10 >= 10 (true)");
    assert_equal_u8(u8ten < u8ten, 0, "10 < 10 (false)");
    assert_equal_u8(u8ten <= u8ten, 1, "10 <= 10 (true)");

    assert_equal_i8(i8one < i8ten, 1, "signed 1 < 10 (true)");
    assert_equal_i8(i8ten < i8one, 0, "signed 10 < 1 (false)");
    assert_equal_i8(i8one > i8ten, 0, "signed 1 > 10 (false)");
    assert_equal_i8(i8ten > i8one, 1, "signed 10 > 1 (true)");
    assert_equal_i8(i8ten > i8ten, 0, "signed 10 > 10 (false)");
    assert_equal_i8(i8ten >= i8ten, 1, "signed 10 >= 10 (true)");
    assert_equal_i8(i8ten < i8ten, 0, "signed 10 < 10 (false)");
    assert_equal_i8(i8ten <= i8ten, 1, "signed 10 <= 10 (true)");

    assert_equal_i8(i8negone < i8ten, 1, "signed -1 < 10 (true)");
    assert_equal_i8(i8ten < i8negone, 0, "signed 10 < -1 (false)");
    assert_equal_i8(i8negone > i8ten, 0, "signed -1 > 10 (false)");
    assert_equal_i8(i8ten > i8negone, 1, "signed 10 > -1 (true)");
    assert_equal_i8(i8negten > i8negten, 0, "signed -10 > -10 (false)");
    assert_equal_i8(i8negten >= i8negten, 1, "signed -10 >= -10 (true)");
    assert_equal_i8(i8negten < i8negten, 0, "signed -10 < -10 (false)");
    assert_equal_i8(i8negten <= i8negten, 1, "signed -10 <= -10 (true)");

    assert_equal_u16(u16one < u16ten, 1, "16b 1 < 10 (true)");
    assert_equal_u16(u16ten < u16one, 0, "16b 10 < 1 (false)");
    assert_equal_u16(u16one > u16ten, 0, "16b 1 > 10 (false)");
    assert_equal_u16(u16ten > u16one, 1, "16b 10 > 1 (true)");
    assert_equal_u16(u16ten > u16ten, 0, "16b 10 > 10 (false)");
    assert_equal_u16(u16ten >= u16ten, 1, "16b 10 >= 10 (true)");
    assert_equal_u16(u16ten < u16ten, 0, "16b 10 < 10 (false)");
    assert_equal_u16(u16ten <= u16ten, 1, "16b 10 <= 10 (true)");

    assert_equal_i16(i16one < i16ten, 1, "16b signed 1 < 10 (true)");
    assert_equal_i16(i16ten < i16one, 0, "16b signed 10 < 1 (false)");
    assert_equal_i16(i16one > i16ten, 0, "16b signed 1 > 10 (false)");
    assert_equal_i16(i16ten > i16one, 1, "16b signed 10 > 1 (true)");
    assert_equal_i16(i16ten > i16ten, 0, "16b signed 10 > 10 (false)");
    assert_equal_i16(i16ten >= i16ten, 1, "16b signed 10 >= 10 (true)");
    assert_equal_i16(i16ten < i16ten, 0, "16b signed 10 < 10 (false)");
    assert_equal_i16(i16ten <= i16ten, 1, "16b signed 10 <= 10 (true)");

    assert_equal_i16(i16negone < i16ten, 1, "16b signed -1 < 10 (true)");
    assert_equal_i16(i16ten < i16negone, 0, "16b signed 10 < -1 (false)");
    assert_equal_i16(i16negone > i16ten, 0, "16b signed -1 > 10 (false)");
    assert_equal_i16(i16ten > i16negone, 1, "16b signed 10 > -1 (true)");
    assert_equal_i16(i16negten > i16negten, 0, "16b signed -10 > -10 (false)");
    assert_equal_i16(i16negten >= i16negten, 1, "16b signed -10 >= -10 (true)");
    assert_equal_i16(i16negten < i16negten, 0, "16b signed -10 < -10 (false)");
    assert_equal_i16(i16negten <= i16negten, 1, "16b signed -10 <= -10 (true)");
}


// ============================================================================
// TEST: CONTROL FLOW - IF/ELSE (visit_If)
// ============================================================================

void test_if_else() {
    // Simple if - true condition
    uint8_t if_result1 = 0;
    if (1) {
        if_result1 = 42;
    }
    assert_equal_u8(if_result1, 42, "If statement (true)");
    
    // Simple if - false condition
    uint8_t if_result2 = 0;
    if (0) {
        if_result2 = 42;
    }
    assert_equal_u8(if_result2, 0, "If statement (false)");
    
    // If-else - true path
    uint8_t ifelse_result1 = 0;
    if (5 > 3) {
        ifelse_result1 = 1;
    } else {
        ifelse_result1 = 2;
    }
    assert_equal_u8(ifelse_result1, 1, "If-else (true path)");
    
    // If-else - false path
    uint8_t ifelse_result2 = 0;
    if (3 > 5) {
        ifelse_result2 = 1;
    } else {
        ifelse_result2 = 2;
    }
    assert_equal_u8(ifelse_result2, 2, "If-else (false path)");
    
    // Nested if
    uint8_t nested_result = 0;
    if (1) {
        if (1) {
            nested_result = 99;
        }
    }
    assert_equal_u8(nested_result, 99, "Nested if");
    
    // If with 16-bit condition - tests high byte check path
    uint16_t big_val = 0x0100;
    uint8_t if16_result = 0;
    if (big_val) {
        if16_result = 1;
    }
    assert_equal_u8(if16_result, 1, "If with 16-bit condition");
}

// ============================================================================
// TEST: CONTROL FLOW - WHILE LOOP (visit_While)
// ============================================================================

void test_while() {
    // Simple while loop
    uint8_t count1 = 0;
    uint8_t sum1 = 0;
    while (count1 < 5) {
        sum1 = sum1 + count1;
        count1++;
    }
    assert_equal_u8(sum1, 10, "While loop sum");
    assert_equal_u8(count1, 5, "While loop counter");
    
    // While loop - never executes
    uint8_t never_exec = 0;
    while (0) {
        never_exec = 99;
    }
    assert_equal_u8(never_exec, 0, "While loop (never executes)");
    
    // Nested while
    uint8_t outer2 = 0;
    uint8_t inner_sum = 0;
    while (outer2 < 3) {
        uint8_t inner2 = 0;
        while (inner2 < 2) {
            inner_sum++;
            inner2++;
        }
        outer2++;
    }
    assert_equal_u8(inner_sum, 6, "Nested while loop");
}

// ============================================================================
// TEST: CONTROL FLOW - DO-WHILE LOOP (visit_DoWhile)
// ============================================================================

void test_do_while() {
    // Simple do-while
    uint8_t count3 = 0;
    uint8_t sum3 = 0;
    do {
        sum3 = sum3 + count3;
        count3++;
    } while (count3 < 5);
    assert_equal_u8(sum3, 10, "Do-while loop sum");
    
    // Do-while executes at least once
    uint8_t once = 0;
    do {
        once = 42;
    } while (0);
    assert_equal_u8(once, 42, "Do-while executes once");
}

// ============================================================================
// TEST: CONTROL FLOW - FOR LOOP (visit_For)
// ============================================================================

void test_for() {
    // Simple for loop - tests 1-byte condition path
    uint8_t sum_for = 0;
    uint8_t i;
    for (i = 0; i < 5; i++) {
        sum_for = sum_for + i;
    }
    assert_equal_u8(sum_for, 10, "For loop sum");
    
    // For loop with 16-bit condition - tests 2-byte condition path
    uint16_t sum_for16 = 0;
    uint16_t j;
    for (j = 0; j < 3; j++) {
        sum_for16 = sum_for16 + j;
    }
    assert_equal_u16(sum_for16, 3, "For loop 16-bit sum");
    
    // For loop - empty body
    uint8_t k;
    for (k = 0; k < 10; k++) {
        // Empty
    }
    assert_equal_u8(k, 10, "For loop empty body");
    
    // Nested for loop
    uint8_t nested_for_sum = 0;
    uint8_t m;
    uint8_t n;
    for (m = 0; m < 3; m++) {
        for (n = 0; n < 2; n++) {
            nested_for_sum++;
        }
    }
    assert_equal_u8(nested_for_sum, 6, "Nested for loop");
}

// ============================================================================
// TEST: CONTROL FLOW - BREAK/CONTINUE (visit_Break, visit_Continue)
// ============================================================================

void test_break_continue() {
    // Break in while loop
    uint8_t break_count = 0;
    while (1) {
        break_count++;
        if (break_count == 3) {
            break;
        }
    }
    assert_equal_u8(break_count, 3, "Break in while loop");
    
    // Continue in while loop
    uint8_t cont_sum = 0;
    uint8_t cont_i = 0;
    while (cont_i < 5) {
        cont_i++;
        if (cont_i == 3) {
            continue;
        }
        cont_sum = cont_sum + cont_i;
    }
    assert_equal_u8(cont_sum, 12, "Continue in while loop");
    
    // Break in for loop
    uint8_t break_for = 0;
    uint8_t bf_i;
    for (bf_i = 0; bf_i < 10; bf_i++) {
        break_for++;
        if (bf_i == 4) {
            break;
        }
    }
    assert_equal_u8(break_for, 5, "Break in for loop");
    
    // Continue in for loop
    uint8_t cont_for_sum = 0;
    uint8_t cf_i;
    for (cf_i = 0; cf_i < 5; cf_i++) {
        if (cf_i == 2) {
            continue;
        }
        cont_for_sum = cont_for_sum + cf_i;
    }
    assert_equal_u8(cont_for_sum, 8, "Continue in for loop");
}

// ============================================================================
// TEST: FUNCTION CALLS (visit_FuncCall, visit_FuncDef)
// ============================================================================

// Helper function - 8-bit parameter and return
uint8_t add_u8(uint8_t a_param, uint8_t b_param) {
    return a_param + b_param;
}

// Helper function - 16-bit parameter and return
uint16_t add_u16(uint16_t a16_param, uint16_t b16_param) {
    return a16_param + b16_param;
}

// Helper function - mixed parameter sizes
uint16_t mixed_params(uint8_t byte_param, uint16_t word_param) {
    return byte_param + word_param;
}

// Helper function - pointer parameter
void modify_by_ptr(uint8_t *ptr_param) {
    *ptr_param = *ptr_param + 10;
}

// Helper function - struct pointer parameter (structs by reference only)
void modify_point(struct Point *pt_param) {
    pt_param->x = pt_param->x + 1;
    pt_param->y = pt_param->y + 1;
}

// Helper function - array parameter (degrades to pointer)
uint8_t sum_array(uint8_t *arr_param, uint8_t len) {
    uint8_t sum_result = 0;
    uint8_t idx;
    for (idx = 0; idx < len; idx++) {
        sum_result = sum_result + arr_param[idx];
    }
    return sum_result;
}

// Helper function - void return type
void void_function() {
    g_byte = 123;
}

// Helper function - local variables (tests localvar_offset)
uint8_t func_with_locals(uint8_t param1, uint8_t param2) {
    uint8_t local1 = param1 + 5;
    uint8_t local2 = param2 + 10;
    uint8_t local3 = local1 + local2;
    return local3;
}

// Helper function - static local variable
uint8_t func_with_static() {
    static uint8_t static_counter = 0;
    static_counter++;
    return static_counter;
}


// ============================================================================
// MAIN TEST RUNNER
// ============================================================================

void main() {
    printf("=== Compiler Test Suite ===\n");
    printf("\n");
    
    test_gt_lt();
    test_if_else();
    test_while();
    test_do_while();
    test_for();
    test_break_continue();
    
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
