#include "types.h"
#include "terminal_output.h"
#include "rand.h"
#include "shared.h"
extern void exec_chain(char *path);

// Tests for program-wide globals across C files (ODY mode):
//   - A non-static file-scope definition is a :var_x label that other files
//     reach with a plain `extern` (shared.h / globals.c)
//   - The header pattern: extern declaration then definition in the same
//     file keeps the definition's storage and initializer
//   - Reads and writes in either file see the same storage (word, byte,
//     array, struct, pointer, uninitialized)
//   - `static` globals, static functions, and their static locals with the
//     same names in two files stay separate (.var_x stays file-scoped)
//   - A plain extern also reaches a :var_x data label defined in assembly
//   - `#pragma asmvar` routes an extern to a $VAR, both one declared in this
//     program's own assembly and a BIOS one pulled in through rand.h
//   - A local (or nested-block local) that shadows a global or an extern
//     from a header gets its own storage instead of writing the global
//   - Sequential for loops declaring the same name get separate variables
//   - Global initializers taking the address of another file's global
//     (&x, &arr[i], &s.member) -- the only cross-file initializers allowed

#pragma asmvar cct10_asmword
extern uint16_t cct10_asmword;
extern uint16_t cct10_asm_read(void);
extern void cct10_asm_write(uint16_t v);

// Defined as :var_cct10_asmlabel data in asmvar_helpers.asm: no pragma needed
extern uint16_t cct10_asmlabel;
extern uint16_t cct10_asm_read_label(void);

// Same names as globals.c's statics
static uint8_t file_local = 1;

static uint8_t bump(void) {
    static uint8_t counter = 50;
    counter++;
    return counter;
}

uint16_t total_tests = 0;
uint16_t failed_tests = 0;

// Addresses of globals defined in globals.c: constant, so allowed
uint16_t *word_ptr = &shared_word;
uint8_t  *arr_elem_ptr = &shared_arr[1];
uint16_t *pair_b_ptr = &shared_pair.b;

void fail(const char* name) {
    failed_tests++;
    printf("FAIL: ");
    printf(name);
    printf("\n");
}

// Initializers written by globals.c's init function are visible here
void test_extern_initialized(void) {
    total_tests++;
    if (shared_word != 0x1234) { fail("extern word initializer from other file"); }
    total_tests++;
    if (shared_byte != 0x5A) { fail("extern byte initializer from other file"); }
    total_tests++;
    if (shared_uninit != 0) { fail("extern uninitialized global is zero"); }
}

void test_write_here_read_there(void) {
    shared_word = 0xBEEF;
    total_tests++;
    if (globals_get_word() != 0xBEEF) { fail("write in main, read in globals.c"); }
}

void test_write_there_read_here(void) {
    globals_set_word(0x4321);
    total_tests++;
    if (shared_word != 0x4321) { fail("write in globals.c, read in main"); }
}

void test_extern_array(void) {
    total_tests++;
    if (shared_arr[2] != 30) { fail("extern array element read"); }
    shared_arr[0] = 1;
    total_tests++;
    if (globals_arr_sum() != 91) { fail("extern array write seen by other file"); }
}

void test_extern_struct(void) {
    total_tests++;
    if (shared_pair.a != 7) { fail("extern struct byte member"); }
    total_tests++;
    if (shared_pair.b != 0x0102) { fail("extern struct word member"); }
}

void test_extern_pointer(void) {
    total_tests++;
    if (shared_msg[0] != 'c' || shared_msg[4] != 's') { fail("extern char* global"); }
}

void test_static_stays_file_scoped(void) {
    total_tests++;
    if (file_local != 1) { fail("static global in main.c"); }
    total_tests++;
    if (globals_get_file_local() != 2) { fail("same-named static global in globals.c"); }
    total_tests++;
    if (bump() != 51) { fail("static local in main.c static function"); }
    total_tests++;
    if (globals_bump_counter() != 101) { fail("same-named static local in globals.c static function"); }
}

void test_asmvar_local(void) {
    cct10_asmword = 0xA55A;
    total_tests++;
    if (cct10_asm_read() != 0xA55A) { fail("asmvar: C write, asm read"); }
    cct10_asm_write(0x0FF0);
    total_tests++;
    if (cct10_asmword != 0x0FF0) { fail("asmvar: asm write, C read"); }
}

void test_extern_asm_label(void) {
    cct10_asmlabel = 0x3C5A;
    total_tests++;
    if (cct10_asm_read_label() != 0x3C5A) { fail("plain extern to asm :var_ label"); }
}

void test_asmvar_bios_header(void) {
    rand_seed = 0x42;
    total_tests++;
    if (rand_seed != 0x42) { fail("asmvar: BIOS $rand_seed via rand.h"); }
}

// Locals shadowing a global from another file and a BIOS asmvar from rand.h
void test_local_shadows_global(void) {
    globals_set_word(0x1111);
    rand_seed = 0x77;
    uint16_t shared_word = 0x2222;
    uint8_t rand_seed = 5;
    shared_word++;
    rand_seed++;
    total_tests++;
    if (shared_word != 0x2223) { fail("shadowing local has its own value"); }
    total_tests++;
    if (globals_get_word() != 0x1111) { fail("shadowing local must not write the global"); }
    total_tests++;
    if (rand_seed != 6) { fail("local shadowing asmvar has its own value"); }
}

// Checked from a separate function, where rand_seed means the BIOS VAR again
void test_shadowed_asmvar_untouched(void) {
    total_tests++;
    if (rand_seed != 0x77) { fail("local shadowing asmvar must not write $rand_seed"); }
}

void test_block_shadows_global(void) {
    shared_byte = 0x5A;
    {
        uint8_t shared_byte = 9;
        shared_byte++;
        total_tests++;
        if (shared_byte != 10) { fail("nested-block shadowing local"); }
    }
    total_tests++;
    if (shared_byte != 0x5A) { fail("global after nested-block shadowing"); }
}

// Before for loops had their own scope, the second k silently reused the
// first (uint8_t) k: 300 truncated and `k < 303` never went false
void test_for_scope(void) {
    uint8_t n = 0;
    for (uint8_t k = 0; k < 2; k++) { n++; }
    for (uint16_t k = 300; k < 303; k++) {
        n++;
        if (n > 20) { break; }
    }
    total_tests++;
    if (n != 5) { fail("sequential for loops declaring the same name"); }
}

void test_address_initializers(void) {
    shared_word = 0x5EED;
    total_tests++;
    if (*word_ptr != 0x5EED) { fail("global init &extern_word"); }
    total_tests++;
    if (*arr_elem_ptr != 20) { fail("global init &extern_arr[1]"); }
    total_tests++;
    if (*pair_b_ptr != 0x0102) { fail("global init &extern_struct.member"); }
}

void main(void) {
    test_extern_initialized();
    test_write_here_read_there();
    test_write_there_read_here();
    test_extern_array();
    test_extern_struct();
    test_extern_pointer();
    test_static_stays_file_scoped();
    test_asmvar_local();
    test_extern_asm_label();
    test_asmvar_bios_header();
    test_local_shadows_global();
    test_shadowed_asmvar_untouched();
    test_block_shadows_global();
    test_for_scope();
    test_address_initializers();

    uint16_t passed = total_tests - failed_tests;
    if (failed_tests == 0) {
        printf("cctest10: %U/%U PASS\n", total_tests, total_tests);
    } else {
        printf("cctest10: %U/%U FAIL\n", passed, total_tests);
    }
}
