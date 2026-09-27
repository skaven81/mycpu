#include "theme_music.h"
#include "music_player.h"
#include <types.h>
#include <fat16_pathfind.h>
#include <fat16_readfile.h>
#include <malloc.h>
#include <terminal_output.h>

void *music_memory;

uint8_t play_theme_music(char *filename) {
    struct fat16_dirent *dirent;
    struct fs_handle *fs_handle;
    uint16_t size;
    uint8_t stat;

    // locate and load the music file
    dirent = fat16_pathfind(filename, &fs_handle);
    // errors are 0x0000/0x0001 (not found, bad path) or 0x01nn (ATA error)
    if((uint16_t)dirent < 0x0200) {
        printf("ERROR: music file %s not found: 0x%X\n", filename, (uint16_t)dirent);
        return 1;
    }

    // fat16_readfile writes whole 512-byte sectors, so round the buffer up
    // to a sector multiple (4 segments each). Size 0 is rejected because
    // readfile would read 128 sectors for it; >0x7e00 (63 sectors) would
    // overflow the byte segment count.
    size = dirent->file_size.lo;
    music_memory = calloc_segments((uint8_t)(((size + 511) >> 9) << 2));
    if(!music_memory) {
        free(dirent);
        printf("ERROR: out of memory loading music file %s\n", filename);
        return 1;
    }
    stat = fat16_readfile(NULL, dirent, 0, music_memory, fs_handle);
    free(dirent);
    if(stat > 0) {
        free(music_memory);
        printf("ERROR: unable to read music file %s: 0x%x\n", filename, stat);
        return 1;
    }

    // begin playing in background, looping, don't report status
    music_play(music_memory, 1, NULL, NULL);
    return 0;
}

void stop_theme_music() {
    music_stop();
    free(music_memory);
}
