#include "load_file.h"
#include <types.h>
#include <fat16_pathfind.h>
#include <fat16_readfile.h>
#include <malloc.h>
#include <terminal_output.h>

// Read a whole file into memory. dest must be 512-byte aligned (e.g. the
// 0xD000 ext page window); pass NULL to get a zeroed, sector-rounded malloc
// buffer the caller must free(). Returns the data pointer, or NULL after
// printing an error (0xFFFF = out of memory, otherwise pathfind/readfile code).
void *load_file(char *filename, void *dest) {
    struct fat16_dirent *dirent;
    struct fs_handle *fs_handle;
    uint16_t err, size;
    void *buf;

    buf = NULL;
    dirent = fat16_pathfind(filename, &fs_handle);
    // errors are 0x0000/0x0001 (not found, bad path) or 0x01nn (ATA error)
    err = (uint16_t)dirent;
    if(err >= 0x0200) {
        buf = dest;
        err = 0xffff;
        if(!buf) {
            // fat16_readfile writes whole 512-byte sectors, so round up to a
            // sector multiple (4 segments each). Files over 0x7e00 bytes
            // (63 sectors) would overflow the byte segment count.
            size = dirent->file_size.lo;
            buf = calloc_segments((uint8_t)(((size + 511) >> 9) << 2));
        }
        if(buf) {
            err = fat16_readfile(NULL, dirent, 0, buf, fs_handle);
            if(err) {
                if(!dest) {
                    free(buf);
                }
                buf = NULL;
            }
        }
        free(dirent);
    }
    if(!buf) {
        printf("ERROR: can't load %s: 0x%X\n", filename, err);
    }
    return buf;
}
