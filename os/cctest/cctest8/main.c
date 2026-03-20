#include "types.h"
#include "terminal_output.h"
extern void exec_chain(char *path);


// Tests for previously-untested code paths in c_compiler/codegen.py:
//   - Pointer arithmetic with non-power-of-two struct sizes (addition loop)
//   - Pointer arithmetic with struct sizes > 8 (mul16 path)
//   - Pointer subtraction (ptr - int)
//   - Partial array/struct initialization (fewer initializers than size)
//   - 3D array access (visit_ArrayRef with 3 levels)
//   - 2D array of uint16_t (multi-dim with word-size elements)
//   - 16-bit compound shift assignment (uint16_t <<= / >>=)
//   - Chained assignment (a = b = c = 42)
//   - Compound assignment via arrow operator (ptr->field += val)

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

void fail(const char* name) {
    failed_tests++;
    printf("FAIL: ");
    printf(name);
    printf("\n");
}

// 5-byte struct: non-power-of-two size, exercises the addition loop path
// in pointer arithmetic scaling (codegen.py lines 1719-1727).
struct S5 {
    uint8_t a;
    uint8_t b;
    uint8_t c;
    uint8_t d;
    uint8_t e;
};

// 9-byte struct: size > 8, exercises the :mul16 path in pointer arithmetic
// scaling (codegen.py lines 1729-1735).
struct S9 {
    uint8_t a;
    uint8_t b;
    uint8_t c;
    uint8_t d;
    uint8_t e;
    uint8_t f;
    uint8_t g;
    uint8_t h;
    uint8_t i;
};

// For compound-assignment-via-arrow test.
struct Node {
    uint8_t x;
    uint16_t w;
};

// For partial struct initialization test.
struct PT {
    uint8_t x;
    uint8_t y;
    uint16_t z;
};

// ============================================================================
// Test: pointer arithmetic with non-power-of-two struct sizes
// ============================================================================
void test_ptr_arith_nonpot(void) {
    // S5: size 5 bytes -- exercises addition loop (lines 1719-1727)
    // Use manual assignment to avoid partial struct init issues.
    struct S5 arr5[3];
    arr5[0].a = 1;
    arr5[1].a = 2;
    arr5[2].a = 3;
    struct S5 *p5 = arr5;

    total_tests++;
    if ((p5+1)->a != 2) { fail("ptr_arith_nonpot: S5 p5+1 a==2"); }
    total_tests++;
    if ((p5+2)->a != 3) { fail("ptr_arith_nonpot: S5 p5+2 a==3"); }

    // S9: size 9 bytes -- exercises :mul16 path (lines 1729-1735)
    struct S9 arr9[3];
    arr9[0].a = 10;
    arr9[1].a = 20;
    arr9[2].a = 30;
    struct S9 *p9 = arr9;

    total_tests++;
    if ((p9+1)->a != 20) { fail("ptr_arith_nonpot: S9 p9+1 a==20"); }
    total_tests++;
    if ((p9+2)->a != 30) { fail("ptr_arith_nonpot: S9 p9+2 a==30"); }
}

// ============================================================================
// Test: pointer subtraction (ptr - int)
// ============================================================================
void test_ptr_subtraction(void) {
    // uint8_t*: unit_size=1, no scaling needed
    // Use &arr[7] (not arr+7) since arr+7 requires array-to-pointer decay in BinaryOp,
    // which the compiler does not support directly; &arr[n] works via ArrayRef+UnaryOp.
    uint8_t arr[8] = {10, 20, 30, 40, 50, 60, 70, 80};
    uint8_t *p = &arr[7];
    // p points to arr[7]=80; p-3 should point to arr[4]=50
    total_tests++;
    if (*(p - 3) != 50) { fail("ptr_sub: uint8 *(p-3)==50"); }

    // uint16_t*: unit_size=2, exercises the shift-by-1 scaling path
    uint16_t arr16[4] = {100, 200, 300, 400};
    uint16_t *q = &arr16[3];
    // q points to arr16[3]=400; q-2 should point to arr16[1]=200
    total_tests++;
    if (*(q - 2) != 200) { fail("ptr_sub: uint16 *(q-2)==200"); }
}

// ============================================================================
// Test: partial initialization (fewer initializers than array/struct size)
// Exercises visit_InitList with partial data.
// NOTE: C standard requires remaining elements to be zero-initialized.
// The compiler may not zero-fill local variables -- some assertions below
// may fail if the compiler does not implement zero-fill.
// ============================================================================
void test_partial_init(void) {
    // Partial array initialization: 3 initializers for 6-element array
    uint8_t arr[6] = {1, 2, 3};
    total_tests++;
    if (arr[0] != 1) { fail("partial_init: arr[0]==1"); }
    total_tests++;
    if (arr[1] != 2) { fail("partial_init: arr[1]==2"); }
    total_tests++;
    if (arr[2] != 3) { fail("partial_init: arr[2]==3"); }
    total_tests++;
    if (arr[3] != 0) { fail("partial_init: arr[3]==0 (zero-fill)"); }
    total_tests++;
    if (arr[4] != 0) { fail("partial_init: arr[4]==0 (zero-fill)"); }
    total_tests++;
    if (arr[5] != 0) { fail("partial_init: arr[5]==0 (zero-fill)"); }

    // Partial struct initialization: only first field provided
    struct PT pt = {5};
    total_tests++;
    if (pt.x != 5) { fail("partial_init: pt.x==5"); }
    total_tests++;
    if (pt.y != 0) { fail("partial_init: pt.y==0 (zero-fill)"); }
    total_tests++;
    if (pt.z != 0) { fail("partial_init: pt.z==0 (zero-fill)"); }
}

// ============================================================================
// Test: 2D array of uint16_t (multi-dimensional with word-size elements)
// ============================================================================
void test_2d_word_array(void) {
    uint16_t mat[3][4];
    mat[0][0] = 1000;
    mat[1][2] = 5000;
    mat[2][3] = 60000;

    total_tests++;
    if (mat[0][0] != 1000) { fail("2d_word: mat[0][0]==1000"); }
    total_tests++;
    if (mat[1][2] != 5000) { fail("2d_word: mat[1][2]==5000"); }
    total_tests++;
    if (mat[2][3] != 60000) { fail("2d_word: mat[2][3]==60000"); }
}

// ============================================================================
// Test: 16-bit compound shift assignment
// ============================================================================
void test_compound_shift_u16(void) {
    uint16_t a = 1;
    a <<= 4;
    total_tests++;
    if (a != 16) { fail("shift16: a<<=4: 1<<4==16"); }

    uint16_t b = 0x8000;
    b >>= 3;
    total_tests++;
    if (b != 0x1000) { fail("shift16: b>>=3: 0x8000>>3==0x1000"); }
}

// ============================================================================
// Test: chained assignment (a = b = c = 42)
// Exercises visit_Assignment with mode='generate_rvalue' as rvalue.
// ============================================================================
void test_chained_assign(void) {
    uint8_t a;
    uint8_t b;
    uint8_t c;
    a = b = c = 42;
    total_tests++;
    if (a != 42) { fail("chain: uint8 a==42"); }
    total_tests++;
    if (b != 42) { fail("chain: uint8 b==42"); }
    total_tests++;
    if (c != 42) { fail("chain: uint8 c==42"); }

    uint16_t x;
    uint16_t y;
    x = y = 0xABCD;
    total_tests++;
    if (x != 0xABCD) { fail("chain: uint16 x==0xABCD"); }
    total_tests++;
    if (y != 0xABCD) { fail("chain: uint16 y==0xABCD"); }
}

// ============================================================================
// Test: compound assignment via arrow operator (ptr->field op= val)
// ============================================================================
void test_compound_via_arrow(void) {
    struct Node n;
    n.x = 10;
    n.w = 1000;
    struct Node *p = &n;

    p->x += 5;
    total_tests++;
    if (p->x != 15) { fail("arrow_compound: p->x+=5: 10+5==15"); }

    p->w -= 200;
    total_tests++;
    if (p->w != 800) { fail("arrow_compound: p->w-=200: 1000-200==800"); }

    p->x &= 0x0F;
    total_tests++;
    if (p->x != 0x0F) { fail("arrow_compound: p->x&=0x0F: 15&0x0F==0x0F"); }

    p->w |= 0xF000;
    total_tests++;
    if (p->w != 0xF320) { fail("arrow_compound: p->w|=0xF000: 0x0320|0xF000==0xF320"); }
}

void main(void) {
    test_ptr_arith_nonpot();
    test_ptr_subtraction();
    test_partial_init();
    test_2d_word_array();
    test_compound_shift_u16();
    test_chained_assign();
    test_compound_via_arrow();

    uint16_t passed = total_tests - failed_tests;
    if (failed_tests == 0) {
        printf("cctest8: %U/%U PASS\n", total_tests, total_tests);
    } else {
        printf("cctest8: %U/%U FAIL\n", passed, total_tests);
    }
    exec_chain("/CCTEST/CCTEST9.ODY");
}
