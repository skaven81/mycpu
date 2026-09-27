#include "theme_music.h"
#include "music_player.h"
#include "load_file.h"
#include <types.h>
#include <malloc.h>

void *music_memory;

uint8_t play_theme_music(char *filename) {
    music_memory = load_file(filename, NULL);
    if(!music_memory) {
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
