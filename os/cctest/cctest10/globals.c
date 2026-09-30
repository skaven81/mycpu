#include "shared.h"

// Definitions for the externs in shared.h (which was included above, so
// every one of these follows an extern declaration of the same name).
uint16_t shared_word = 0x1234;
uint8_t  shared_byte = 0x5A;
uint8_t  shared_arr[4] = {10, 20, 30, 40};
struct Pair shared_pair = {7, 0x0102};
char    *shared_msg = "cross";
uint16_t shared_uninit;

// Same names as statics in main.c: must stay separate per file
static uint8_t file_local = 2;

static uint8_t bump(void) {
    static uint8_t counter = 100;
    counter++;
    return counter;
}

uint16_t globals_get_word(void) { return shared_word; }
void     globals_set_word(uint16_t v) { shared_word = v; }
uint8_t  globals_get_file_local(void) { return file_local; }
uint8_t  globals_bump_counter(void) { return bump(); }

uint16_t globals_arr_sum(void) {
    uint16_t sum = 0;
    uint8_t i;
    for (i = 0; i < 4; i++) { sum += shared_arr[i]; }
    return sum;
}
