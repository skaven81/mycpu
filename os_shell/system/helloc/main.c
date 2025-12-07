#include "types.h"
#include "terminal_output.h"
#include "trace.h"

void main() {
    char c;
    char *hex = "0123456789abcdef";
    print("  0 1 2 3 4 5 6 7 8 9 a b c d e f\n");
    print("  -------------------------------\n");
    for(uint8_t row=(uint8_t)0; row<=(uint8_t)15; row++) {
        printf("%c|", hex[row]);
        for(uint8_t col=(uint8_t)0; col<=(uint8_t)15; col++) {
            c = (row<<4) + col;
            putchar_direct(c);
            putchar_direct(' ');
        }
        putchar('\n');
    }
    putchar('\n');
}
