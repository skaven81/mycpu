#pragma once

#include <types.h>

// Background .MUS playback (Timer 1 tone + Timer 2 note timing).
// Split library -- symlink os/lib/music_player.asm and this header into
// the consuming build directory. See music_player.asm for the details.

// Optional per-note handoff filled in by the playback interrupt handler.
struct music_status {
    uint8_t new_note;   // set to 1 by the handler on each note; caller clears
    char comment[12];   // current note's comment (null-terminated)
};

// Start playing in-memory song data in the background; returns at once.
//  song:       16-byte note records ending in an all-zero record. Must
//              stay valid (and mapped, if in an extmem window) until
//              music_stop() is called.
//  loop:       0 = play once then go silent, nonzero = repeat forever
//  loop_count: optional (NULL ok). Zeroed here; incremented each time the
//              end of the song is reached, saturating at 255. 0 means the
//              first pass is still playing.
//  status:     optional (NULL ok). See struct music_status.
extern void music_play(void *song, uint8_t loop, uint8_t *loop_count,
                       struct music_status *status);

// Stop playback and restore the Timer 2 handler and clock-select byte.
// Safe to call at any time, including repeatedly or when not playing.
// Must be called before the program exits if music_play() was called.
extern void music_stop();
