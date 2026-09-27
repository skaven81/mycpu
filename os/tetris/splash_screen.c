#include "splash_screen.h"
#include "load_file.h"
#include <types.h>
#include <extmalloc.h>
#include <memcpy.h>
#include <cursor.h>

uint16_t display_splash_screen(char *filename) {
    void *loaded;

    // Load the splash screen file into two extended memory pages in the D+E window.
    extpage_d_push(extmalloc());
    extpage_e_push(extmalloc());
    loaded = load_file(filename, (void *)0xd000);

    if(loaded) {
        // The terminal bakes the cursor into the color plane (bit 0x40); turn
        // it off first so it doesn't later clear that bit on a splash cell.
        cursor_off();

        // The splash screen binary starts with the characters (offset 0x0000/0xd000 - 0x0eff/0xdeff)
        // then moves on to the colors (offset 0x0f00/0xdf00 - 0x1dff/0xedff)

        // Copy the characters into memory. 64x60=3840 bytes, or 3840/16 = 240 blocks, minus 1 = 239
        memcpy_blocks((void *)0xd000, (void *)0x4000, (uint8_t)239);
        // Copy the colors into memory. Same number of blocks, but start location is 0xd000 + 0x0f00
        memcpy_blocks((void *)0xdf00, (void *)0x5000, (uint8_t)239);
    }

    // unmap and free both pages on success and failure alike
    extfree(extpage_e_pop());
    extfree(extpage_d_pop());

    if(!loaded) {
        return 1;
    }
    return 0;
}
