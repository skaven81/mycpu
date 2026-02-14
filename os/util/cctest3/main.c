#include "types.h"
#include "terminal_output.h"
#include "moretests.h"

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
// TEST: CONTROL FLOW - SWITCH (visit_Switch)
// ============================================================================

void test_switch() {
    // Switch with 8-bit value
    uint8_t sw_val = 2;
    uint8_t sw_result = 0;
    switch (sw_val) {
        case 1:
            sw_result = 10;
            break;
        case 2:
            sw_result = 20;
            break;
        case 3:
            sw_result = 30;
            break;
        default:
            sw_result = 99;
            break;
    }
    assert_equal_u8(sw_result, 20, "Switch case 2");
    
    // Switch with default
    uint8_t sw_val2 = 99;
    uint8_t sw_result2 = 0;
    switch (sw_val2) {
        case 1:
            sw_result2 = 10;
            break;
        case 2:
            sw_result2 = 20;
            break;
        default:
            sw_result2 = 77;
            break;
    }
    assert_equal_u8(sw_result2, 77, "Switch default");
    
    // Switch fall-through
    uint8_t sw_val3 = 1;
    uint8_t sw_result3 = 0;
    switch (sw_val3) {
        case 1:
            sw_result3 = sw_result3 + 10;
        case 2:
            sw_result3 = sw_result3 + 20;
            break;
        case 3:
            sw_result3 = sw_result3 + 30;
            break;
    }
    assert_equal_u8(sw_result3, 30, "Switch fall-through");
    
    // Switch with 16-bit value - tests 2-byte comparison path
    uint16_t sw_val16 = 0x0200;
    uint8_t sw_result16 = 0;
    switch (sw_val16) {
        case 0x0100:
            sw_result16 = 1;
            break;
        case 0x0200:
            sw_result16 = 2;
            break;
        case 0x0300:
            sw_result16 = 3;
            break;
    }
    assert_equal_u8(sw_result16, 2, "Switch 16-bit value");
}

// ============================================================================
// TEST: SIZEOF OPERATOR (visit_UnaryOp sizeof)
// ============================================================================

void test_sizeof() {
    // sizeof on basic types
    uint8_t sz_u8 = sizeof(uint8_t);
    assert_equal_u8(sz_u8, 1, "sizeof(uint8_t)");
    
    uint8_t sz_u16 = sizeof(uint16_t);
    assert_equal_u8(sz_u16, 2, "sizeof(uint16_t)");
    
    // sizeof on variables
    uint8_t var_u8 = 0;
    uint8_t sz_var = sizeof(var_u8);
    assert_equal_u8(sz_var, 1, "sizeof(variable)");
    
    // sizeof on arrays
    uint8_t arr_sz[10];
    uint8_t sz_arr = sizeof(arr_sz);
    assert_equal_u8(sz_arr, 10, "sizeof(array)");
    
    // sizeof on struct
    struct Point pt_sz;
    uint8_t sz_struct = sizeof(pt_sz);
    assert_equal_u8(sz_struct, 2, "sizeof(struct Point)");
    
    struct Rect rect_sz;
    uint8_t sz_rect = sizeof(rect_sz);
    assert_equal_u8(sz_rect, 4, "sizeof(struct Rect)");
    
    // sizeof on pointer
    uint8_t *ptr_sz = 0;
    uint8_t sz_ptr = sizeof(ptr_sz);
    assert_equal_u8(sz_ptr, 2, "sizeof(pointer)");
}

// ============================================================================
// TEST: CAST OPERATIONS (visit_Cast)
// ============================================================================

void test_cast() {
    // Cast uint8_t to uint16_t
    uint8_t val8 = 200;
    uint16_t val16_from8 = (uint16_t)val8;
    assert_equal_u16(val16_from8, 200, "Cast uint8_t to uint16_t");
    
    // Cast uint16_t to uint8_t (truncation)
    uint16_t val16b = 0x1234;
    uint8_t val8_from16 = (uint8_t)val16b;
    assert_equal_u8(val8_from16, 0x34, "Cast uint16_t to uint8_t");
    
    // Cast to pointer type
    uint8_t val_for_ptr = 42;
    uint8_t *ptr_from_cast = (uint8_t*)&val_for_ptr;
    assert_equal_u8(*ptr_from_cast, 42, "Cast to pointer");
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

void test_functions() {
    // Simple function call - 8-bit
    uint8_t func_result1 = add_u8(10, 20);
    assert_equal_u8(func_result1, 30, "Function call 8-bit");
    
    // Simple function call - 16-bit
    uint16_t func_result2 = add_u16(1000, 2000);
    assert_equal_u16(func_result2, 3000, "Function call 16-bit");
    
    // Mixed parameter sizes
    uint16_t func_result3 = mixed_params(50, 1000);
    assert_equal_u16(func_result3, 1050, "Function mixed params");
    
    // Pointer parameter
    uint8_t mod_val = 15;
    modify_by_ptr(&mod_val);
    assert_equal_u8(mod_val, 25, "Function pointer param");
    
    // Struct pointer parameter
    struct Point pt_func;
    pt_func.x = 10;
    pt_func.y = 20;
    modify_point(&pt_func);
    assert_equal_u8(pt_func.x, 11, "Function struct param .x");
    assert_equal_u8(pt_func.y, 21, "Function struct param .y");
    
    // Array parameter
    uint8_t test_arr[5] = {1, 2, 3, 4, 5};
    uint8_t arr_sum = sum_array(test_arr, 5);
    assert_equal_u8(arr_sum, 15, "Function array param");
    
    // Void function
    g_byte = 0;
    void_function();
    assert_equal_u8(g_byte, 123, "Void function");
    
    // Function with local variables
    uint8_t locals_result = func_with_locals(5, 10);
    assert_equal_u8(locals_result, 30, "Function with locals");
    
    // Function with static local
    uint8_t static1 = func_with_static();
    uint8_t static2 = func_with_static();
    uint8_t static3 = func_with_static();
    assert_equal_u8(static1, 1, "Static local call 1");
    assert_equal_u8(static2, 2, "Static local call 2");
    assert_equal_u8(static3, 3, "Static local call 3");
}

// ============================================================================
// TEST: GLOBAL VARIABLES (visit_Decl with global scope)
// ============================================================================

void set_globals() {
    g_byte = 42;
    g_word = 0x1234;
    g_signed_byte = -5;
    g_signed_word = -1000;
}

void test_globals() {
    // Access global variables
    set_globals();
    assert_equal_u8(g_byte, 42, "Global byte read");
    assert_equal_u16(g_word, 0x1234, "Global word read");
    assert_equal_i8(g_signed_byte, -5, "Global signed byte read");
    assert_equal_i16(g_signed_word, -1000, "Global signed word read");
    
    // Modify global variables
    g_byte = 99;
    assert_equal_u8(g_byte, 99, "Global byte write");
    
    g_word = 0xABCD;
    assert_equal_u16(g_word, 0xABCD, "Global word write");
    
    // Global arrays
    assert_equal_u8(g_byte_array[0], 1, "Global array [0]");
    assert_equal_u8(g_byte_array[4], 5, "Global array [4]");
    assert_equal_u16(g_word_array[1], 200, "Global word array [1]");
    
    // Global struct
    assert_equal_u8(g_point.x, 10, "Global struct .x");
    assert_equal_u8(g_point.y, 20, "Global struct .y");
}

// ============================================================================
// TEST: SCOPED VARIABLES (visit_Compound)
// ============================================================================

void test_scopes() {
    uint8_t outer_var = 10;
    
    {
        uint8_t inner_var = 20;
        outer_var = outer_var + inner_var;
    }
    
    assert_equal_u8(outer_var, 30, "Scoped variable access");
    
    // Nested scopes
    uint8_t scope_sum = 0;
    {
        uint8_t level1 = 5;
        {
            uint8_t level2 = 10;
            {
                uint8_t level3 = 15;
                scope_sum = level1 + level2 + level3;
            }
        }
    }
    assert_equal_u8(scope_sum, 30, "Nested scopes");
}

// ============================================================================
// TEST: COMMA OPERATOR (visit_ExprList)
// ============================================================================

void test_comma_operator() {
    // Comma operator - evaluates all, returns last
    uint8_t comma_a = 0;
    uint8_t comma_b = 0;
    uint8_t comma_result = (comma_a = 10, comma_b = 20, comma_a + comma_b);
    
    assert_equal_u8(comma_a, 10, "Comma operator side effect 1");
    assert_equal_u8(comma_b, 20, "Comma operator side effect 2");
    assert_equal_u8(comma_result, 30, "Comma operator result");
    
    // In for loop
    uint8_t comma_i;
    uint8_t comma_j;
    uint8_t comma_count = 0;
    for (comma_i = 0, comma_j = 0; comma_i < 3; comma_i++, comma_j++) {
        comma_count++;
    }
    assert_equal_u8(comma_count, 3, "Comma in for loop");
    assert_equal_u8(comma_j, 3, "Comma in for increment");
}

// ============================================================================
// TEST: STRING LITERALS (visit_Constant with string type)
// ============================================================================

void test_strings() {
    // String literal registration and access
    const char *str1 = "Hello";
    
    // Access individual characters
    assert_equal_u8(str1[0], 'H', "String literal [0]");
    assert_equal_u8(str1[1], 'e', "String literal [1]");
    assert_equal_u8(str1[4], 'o', "String literal [4]");
    assert_equal_u8(str1[5], 0, "String null terminator");
    
    // String comparison (manual)
    const char *str2 = "Test";
    uint8_t str_match = 1;
    if (str2[0] != 'T' || str2[1] != 'e' || str2[2] != 's' || str2[3] != 't') {
        str_match = 0;
    }
    assert_equal_u8(str_match, 1, "String literal content");
}

// ============================================================================
// TEST: ADDRESS CALCULATION EDGE CASES (_get_var_base_address)
// ============================================================================

void test_address_calculation() {
    // Local variable with small offset (uses INCR/DECR path, <= 20)
    uint8_t local_small1 = 1;
    uint8_t local_small2 = 2;
    uint8_t local_small3 = 3;
    
    uint8_t *ptr_small = &local_small2;
    assert_equal_u8(*ptr_small, 2, "Small offset address");
    
    // Force larger offset test by declaring many locals
    uint8_t large_off1 = 1;
    uint8_t large_off2 = 2;
    uint8_t large_off3 = 3;
    uint8_t large_off4 = 4;
    uint8_t large_off5 = 5;
    uint8_t large_off6 = 6;
    uint8_t large_off7 = 7;
    uint8_t large_off8 = 8;
    uint8_t large_off9 = 9;
    uint8_t large_off10 = 10;
    uint8_t large_off11 = 11;
    uint8_t large_off12 = 12;
    uint8_t large_off13 = 13;
    uint8_t large_off14 = 14;
    uint8_t large_off15 = 15;
    uint8_t large_off16 = 16;
    uint8_t large_off17 = 17;
    uint8_t large_off18 = 18;
    uint8_t large_off19 = 19;
    uint8_t large_off20 = 20;
    uint8_t large_off21 = 21;
    uint8_t large_off22 = 22;
    uint8_t large_off23 = 23;
    
    // This should trigger the add16 path (offset > 20)
    uint8_t *ptr_large = &large_off23;
    assert_equal_u8(*ptr_large, 23, "Large offset address");
}

// ============================================================================
// MAIN TEST RUNNER
// ============================================================================

void main() {
    printf("=== Compiler Test Suite ===\n");
    printf("\n");
    
    test_switch();
    test_sizeof();
    test_cast();
    test_functions();
    test_globals();
    test_scopes();
    test_comma_operator();
    test_strings();
    test_address_calculation();
    test_external_statics();
    
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
