#include "types.h"
#include "terminal_output.h"

extern void assert_equal_u8(uint8_t actual, uint8_t expected, const char* test_name);

uint8_t g_otherfile = 10;

static uint8_t incr_static() {
    static uint8_t sui = 80;
    return ++sui;
}

void test_external_statics() {
    uint8_t i;
    i = incr_static(); 
    i = incr_static();
    i = incr_static();
    assert_equal_u8(i, 83, "Local static init in other file");
    assert_equal_u8(g_otherfile, 10, "Global init in other file");
}
