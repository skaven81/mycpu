#include "types.h"
#include "terminal_output.h"

// Tests for previously-untested code paths in c_compiler/codegen.py:
//   - Global array with inferred dimension (uint8_t g_arr[] = {...})
//   - Nested struct init with 16-bit member (InitList recursion + 16-bit emit)
//   - Static local array with partial init (tail zero-fill path)
//   - Static local scalar (byte + word) for BIOS VAR emission (lines 239, 241)
//   - Local array with >= 4 tail bytes (MEMFILL4 path in _emit_zero_fill)
//   - Struct-to-struct assignment (bulk copy without bytes= arg)
//   - Mixed-size BinaryOp: left=word, right=byte (sign-extend other_reg path)
//   - Integer + pointer arithmetic (right-side pointer, lines 1731-1734)
//   - Large constant shift >= 8 bits on 16-bit operand (byte-swap optimization)
//   - Postfix ++ on pointer to 2-byte type (POP_{dest}H restore path, line 1445)
//   - sizeof on a local variable (visit_UnaryOp sizeof via return_var path)
//   - sizeof on a struct member (visit_StructRef return_var path)
//   - sizeof on an integer constant (visit_Constant return_typespec, lines 1131-1134)
//   - sizeof on a char constant (visit_Constant return_typespec char path)
//   - 16-bit return value from function (heap_push_A at function exit)
//   - Passing a pointer argument to a function (is_pointer param path)
//   - Function reference via &func_name (visit_ID generate_lvalue on function)
//   - For loop with C99 variable declaration init (visit_DeclList, lines 352-355)
//   - Nested do-while inside while (delete outer continue/break labels, lines 293-296)
//   - Array indexing on a double pointer (element_var.is_pointer path, line 1083)
//   - Empty statement (visit_EmptyStatement, line 1994)

// ============================================================================
// STRUCT DEFINITIONS (must be at top level per compiler requirements)
// ============================================================================

struct Inner { uint16_t w; };
struct Outer { struct Inner in; uint8_t b; };

struct S3 { uint8_t a; uint8_t b; uint8_t c; };

struct Sized { uint16_t w; uint8_t b; };

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

// Array dimension inference (lines 641-644): no explicit size
uint8_t g_arr[] = {1, 2, 3, 4, 5};

// Nested struct with 16-bit member (lines 1222-1226, 1237-1243)
struct Outer g_nested = {{0x1234}, 0x56};

// Uninitialized globals: used by the --target-rom coverage run to trigger
// the BIOS-mode zero-fill path (lines 183-191) and VAR-style emission
// (lines 226-231).  Not tested at runtime (value is zero after init).
uint8_t g_uninit_byte;
uint16_t g_uninit_word;

// ============================================================================
// TEST HELPERS
// ============================================================================

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

void fail(const char* name) {
    failed_tests++;
    printf("FAIL: ");
    printf(name);
    printf("\n");
}

// ============================================================================
// Test: static local array with partial init (lines 199-208, 661-668)
// The static array is initialized once at program startup.
// ============================================================================
void test_static_local_array(void) {
    // static local array triggers lines 661-662 (recording init_node) and
    // lines 199-208 (emitting bulk_store + tail zero-fill in the global-init func)
    static uint8_t s_arr[8] = {10};

    total_tests++;
    if (s_arr[0] != 10) { fail("static_arr: s_arr[0]==10"); }
    total_tests++;
    if (s_arr[1] != 0) { fail("static_arr: s_arr[1]==0 (zero-fill)"); }
    total_tests++;
    if (s_arr[7] != 0) { fail("static_arr: s_arr[7]==0 (zero-fill)"); }
}

// ============================================================================
// Test: local array with 6 tail bytes -> MEMFILL4 used (line 2284)
// init_bytes=2, tail_bytes=6 -> divmod(6,4)=(1,2) -> 1 MEMFILL4 + 2 singles
// ============================================================================
void test_local_array_memfill4(void) {
    uint8_t arr[8] = {1, 2};

    total_tests++;
    if (arr[0] != 1) { fail("memfill4: arr[0]==1"); }
    total_tests++;
    if (arr[1] != 2) { fail("memfill4: arr[1]==2"); }
    total_tests++;
    if (arr[2] != 0) { fail("memfill4: arr[2]==0 (zero-fill)"); }
    total_tests++;
    if (arr[7] != 0) { fail("memfill4: arr[7]==0 (zero-fill)"); }
}

// ============================================================================
// Test: struct-to-struct assignment (lines 2027, 2255, 2300)
// s2 = s1 triggers _emit_store -> _emit_bulk_store without bytes= argument,
// so bytecount = var.sizeof() (line 2255).
// ============================================================================
void test_struct_assign(void) {
    struct S3 s1;
    s1.a = 11;
    s1.b = 22;
    s1.c = 33;
    struct S3 s2;
    s2 = s1;

    total_tests++;
    if (s2.a != 11) { fail("struct_assign: s2.a==11"); }
    total_tests++;
    if (s2.b != 22) { fail("struct_assign: s2.b==22"); }
    total_tests++;
    if (s2.c != 33) { fail("struct_assign: s2.c==33"); }
}

// ============================================================================
// Test: mixed-size BinaryOp (left=word, right=byte), lines 1706-1708
// When left_var_size==2 and right_var_size==1, the right (byte) operand in
// other_reg is sign/zero-extended to 16 bits before the operation.
// ============================================================================
void test_mixed_size_binop(void) {
    uint16_t w = 1000;
    uint8_t b = 200;
    uint16_t r = w + b;

    total_tests++;
    if (r != 1200) { fail("mixed_binop: 1000+200==1200"); }

    uint16_t w2 = 300;
    uint8_t b2 = 50;
    uint16_t r2 = w2 - b2;

    total_tests++;
    if (r2 != 250) { fail("mixed_binop: 300-50==250"); }
}

// ============================================================================
// Test: integer + pointer (right-side pointer), lines 1731-1734
// n + p where n is int and p is pointer: right_var.is_pointer==True triggers
// the else branch (lines 1731-1734): scale_reg=dest_reg, ptr_reg=other_reg.
// ============================================================================
void test_int_plus_ptr(void) {
    uint8_t arr[5];
    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    arr[3] = 40;
    arr[4] = 50;
    uint8_t *p = arr;
    int16_t n = 3;
    uint8_t *q = n + p;

    total_tests++;
    if (*q != 40) { fail("int+ptr: *(3+arr)==arr[3]==40"); }
}

// ============================================================================
// Test: large constant shift >= 8 bits on 16-bit operand, lines 1795-1803
// For shift >= 8: copy low byte to high (or vice-versa), zero the other,
// then continue with remaining shifts.
// ============================================================================
void test_large_shift(void) {
    uint16_t x = 0x0001;
    uint16_t y = x << 9;

    total_tests++;
    if (y != 0x0200) { fail("large_shift: 0x0001<<9==0x0200"); }

    uint16_t a = 0x8000;
    uint16_t b = a >> 8;

    total_tests++;
    if (b != 0x0080) { fail("large_shift: 0x8000>>8==0x0080"); }
}

// ============================================================================
// Test: postfix ++ on pointer to 2-byte type (line 1445)
// *p++ on uint16_t*: p++ is used as generate_rvalue (to pass the original
// address to the dereference operator).  Since var.typespec.sizeof()==2,
// both the push (line 1409-1410) and the pop (line 1444-1445) of the high
// byte fire.
// ============================================================================
void test_ptr_postfix_word(void) {
    uint16_t arr5[3] = {100, 200, 300};
    uint16_t *p = arr5;
    uint16_t v1 = *p++;
    uint16_t v2 = *p;

    total_tests++;
    if (v1 != 100) { fail("ptr_pp_word: v1==arr5[0]==100"); }
    total_tests++;
    if (v2 != 200) { fail("ptr_pp_word: v2==arr5[1]==200"); }
}

// ============================================================================
// Test: sizeof on a local variable (lines 1456-1463)
// sizeof(var) goes through return_var path in visit_UnaryOp sizeof handler.
// var.is_type_wrapper is False for regular variables, so the else branch
// (line 1462) fires.
// ============================================================================
void test_sizeof_var(void) {
    uint8_t x = 42;
    uint16_t y = 0x1234;
    int16_t sz1 = sizeof(x);
    int16_t sz2 = sizeof(y);

    total_tests++;
    if (sz1 != 1) { fail("sizeof_var: sizeof(uint8_t var)==1"); }
    total_tests++;
    if (sz2 != 2) { fail("sizeof_var: sizeof(uint16_t var)==2"); }
}

// ============================================================================
// Test: sizeof on a struct member (lines 562-565)
// sizeof(s.w) calls visit_StructRef with mode='return_var', which returns
// the member variable so sizeof can use its size.
// ============================================================================
void test_sizeof_struct_member(void) {
    struct Sized s;
    s.w = 0xABCD;
    s.b = 0x12;
    int16_t sz_w = sizeof(s.w);
    int16_t sz_b = sizeof(s.b);
    int16_t sz_s = sizeof(s);

    total_tests++;
    if (sz_w != 2) { fail("sizeof_struct: sizeof(s.w)==2"); }
    total_tests++;
    if (sz_b != 1) { fail("sizeof_struct: sizeof(s.b)==1"); }
    total_tests++;
    if (sz_s != 3) { fail("sizeof_struct: sizeof(Sized)==3"); }
}

// ============================================================================
// Test: word-returning function (lines 840-842 and 914-915)
// A function returning uint16_t pushes A to heap on exit (line 841) and
// the caller pops via heap_pop_A (line 915).
// ============================================================================
uint16_t get_word(void) {
    return 0x1234;
}

void test_word_return(void) {
    uint16_t result = get_word();

    total_tests++;
    if (result != 0x1234) { fail("word_return: get_word()==0x1234"); }
}

// ============================================================================
// Test: passing a pointer argument (lines 885-889)
// When pv.is_pointer==True, the caller generates the rvalue in generate_rvalue
// mode and checks that the result is a pointer before pushing it.
// ============================================================================
void set_byte(uint8_t *p) {
    *p = 0xFF;
}

void test_ptr_arg(void) {
    uint8_t x = 0;
    set_byte(&x);

    total_tests++;
    if (x != 0xFF) { fail("ptr_arg: set_byte(&x) sets x==0xFF"); }
}

// ============================================================================
// Test: global array with inferred dimension (lines 641-644)
// ============================================================================
void test_global_dim_infer(void) {
    total_tests++;
    if (g_arr[0] != 1) { fail("dim_infer: g_arr[0]==1"); }
    total_tests++;
    if (g_arr[4] != 5) { fail("dim_infer: g_arr[4]==5"); }
}

// ============================================================================
// Test: nested struct init with 16-bit member (lines 1222-1226, 1237-1243)
// g_nested = {{0x1234}, 0x56}: the inner InitList {0x1234} is recursively
// processed (line 1222), and the 16-bit member emits two bytes (line 1237-1243).
// ============================================================================
void test_nested_struct_init(void) {
    total_tests++;
    if (g_nested.in.w != 0x1234) { fail("nested_init: g_nested.in.w==0x1234"); }
    total_tests++;
    if (g_nested.b != 0x56) { fail("nested_init: g_nested.b==0x56"); }
}

// ============================================================================
// Test: function reference via &func_name (lines 1332-1342)
// &ref_func triggers visit_ID in generate_lvalue mode; since ref_func is not
// in the variable table, the function registry path (lines 1332-1342) is taken.
// ============================================================================
void ref_func(void) { }

void test_func_ref(void) {
    uint8_t *fp = (uint8_t *)&ref_func;

    total_tests++;
    if (fp == 0) { fail("func_ref: &ref_func != NULL"); }
}

// ============================================================================
// Test: static scalar variables (byte + word) for BIOS VAR emission.
// In --target-rom mode the emitter writes:
//   VAR global byte $name   (line 239)
//   VAR global word $name   (line 241)
// for static locals with sizeof==1 and sizeof==2 respectively.
// The existing s_arr[8] above has sizeof==8 and only covers line 243.
// ============================================================================
void test_static_scalars(void) {
    static uint8_t s_byte = 5;
    static uint16_t s_word = 42;

    total_tests++;
    if (s_byte != 5) { fail("static_scalars: s_byte==5"); }
    total_tests++;
    if (s_word != 42) { fail("static_scalars: s_word==42"); }
}

// ============================================================================
// Test: sizeof on integer and char constants (lines 1129-1134, 1456-1457,
// 1464-1470).
// sizeof(5) -> visit_Constant return_typespec (line 1131-1132),
//   since return_var raises NotImplementedError (lines 1456-1457 catch it),
//   then falls through to typespec path (lines 1464-1470).
// sizeof('a') -> same path but hits line 1133-1134 (char branch).
// ============================================================================
void test_sizeof_constant(void) {
    int16_t sz_int = sizeof(5);
    int16_t sz_char = sizeof('a');

    total_tests++;
    if (sz_int != 2) { fail("sizeof_const: sizeof(5)==2"); }
    total_tests++;
    if (sz_char != 1) { fail("sizeof_const: sizeof('a')==1"); }
}

// ============================================================================
// Test: for loop with C99 variable declaration in init (lines 352-355).
// pycparser wraps C99 for-loop declarations in a DeclList node; visit_DeclList
// iterates over the decls and calls visit() on each (lines 353-354).
// ============================================================================
void test_for_c99_init(void) {
    uint8_t sum = 0;
    for (uint8_t i = 0; i < 5; i++) {
        sum++;
    }

    total_tests++;
    if (sum != 5) { fail("for_c99: sum==5"); }
}

// ============================================================================
// Test: nested do-while inside while (lines 293-296).
// visit_DoWhile checks for and removes continue_label/break_label from kwargs
// (lines 293-296) when those keys are already present (set by the enclosing
// while loop).
// ============================================================================
void test_nested_dowhile(void) {
    uint8_t count = 0;
    uint8_t x = 0;
    while (x < 3) {
        do {
            count++;
            x++;
        } while (0);
    }

    total_tests++;
    if (count != 3) { fail("nested_dowhile: count==3"); }
}

// ============================================================================
// Test: array indexing on a double-pointer (line 1083).
// When base_var.pointer_depth > 1, element_var.is_pointer is True, so
// element_size is set to 2 (16-bit address) rather than the base type size.
// uint8_t **pp has pointer_depth==2, so pp[0] triggers this path.
// ============================================================================
void test_dbl_ptr_index(void) {
    uint8_t a = 77;
    uint8_t *pa = &a;
    uint8_t **pp = &pa;
    uint8_t *elem = pp[0];  // double-pointer array access -> line 1083

    total_tests++;
    if (*elem != 77) { fail("dbl_ptr_index: *pp[0]==77"); }
}

// ============================================================================
// main
// ============================================================================
void main(void) {
    ;   // empty statement: exercises visit_EmptyStatement (line 1994)

    test_static_local_array();
    test_local_array_memfill4();
    test_struct_assign();
    test_mixed_size_binop();
    test_int_plus_ptr();
    test_large_shift();
    test_ptr_postfix_word();
    test_sizeof_var();
    test_sizeof_struct_member();
    test_word_return();
    test_ptr_arg();
    test_global_dim_infer();
    test_nested_struct_init();
    test_func_ref();
    test_static_scalars();
    test_sizeof_constant();
    test_for_c99_init();
    test_nested_dowhile();
    test_dbl_ptr_index();

    uint16_t passed = total_tests - failed_tests;
    if (failed_tests == 0) {
        printf("cctest9: %U/%U PASS\n", total_tests, total_tests);
    } else {
        printf("cctest9: %U/%U FAIL\n", passed, total_tests);
    }
}
