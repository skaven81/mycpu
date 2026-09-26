#include "splash_screen.h"
#include <types.h>
#include <fat16_pathfind.h>
#include <fat16_readfile.h>
#include <terminal_output.h>
#include <malloc.h>
#include <extmalloc.h>
#include <memcpy.h>

uint16_t display_splash_screen(char *filename) {
    // locate the splash screen file
    struct fat16_dirent *dirent;
    struct fs_handle *fs_handle;
    uint8_t extpage;
    uint8_t stat;

    dirent = fat16_pathfind(filename, &fs_handle);
    if(dirent <= 0x00ff) {
        printf("ERROR: splash screen file %s not found: 0x%X\n", filename, *dirent);
        return 1;
    }
    printf("Found splash screen file %s: 0x%X\n", filename, *dirent);

    // Load the splash screen file into two extended memory pages in the D+E window.
    extpage_d_push(extmalloc());
    extpage_e_push(extmalloc());
    // state can be NULL when reading the whole file
    // n_sectors = 0 reads whole file (and doesn't require state)
    // dest is 0xd000 as allocated above
    stat = fat16_readfile(NULL, dirent, 0, (void *)0xd000, fs_handle);
    free(fs_handle);
    free(dirent);
    if(stat > 0) {
        extfree(extpage_d_pop());
        printf("ERROR: unable to read splash screen file %s: 0x%x\n", filename, stat);
        return 1;
    }

    // The splash screen binary starts with the characters (offset 0x0000/0xd000 - 0x0eff/0xdeff)
    // then moves on to the colors (offset 0x0f00/0xdf00 - 0x1dff/0xedff)

    // Copy the characters into memory. 64x60=3840 bytes, or 3840/16 = 240 blocks, minus 1 = 239
    memcpy_blocks((void *)0xd000, (void *)0x4000, (uint8_t)239);
    // Copy the colors into memory. Same number of blocks, but start location is 0xd000 + 0x
    memcpy_blocks((void *)0xdf00, (void *)0x5000, (uint8_t)239);

    extfree(extpage_e_pop());
    extfree(extpage_d_pop());
    return 0;
}
