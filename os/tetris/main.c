#include "splash_screen.h"
#include "theme_music.h"
#include <terminal_input.h>
#include <keyboard.h>
#include <clearscreen.h>
#include <terminal_output.h>
#include <cursor.h>

// Clear the splash and give the shell a clean screen. clear_screen doesn't
// move the cursor, so home it and turn it back on (the splash turned it off).
void restore_screen() {
    clear_screen(' ', 0x3f);
    cursor_init();
    cursor_on();
}

int main(int argc, char **argv) {
    uint16_t kb_event;
    uint8_t kb_flags, kb_char;
    uint8_t enter_down;

    /* Display tetris splash screen with theme music playing */
    if(display_splash_screen("SPLASH.BIN") > 0) {
        return 1;
    }
    if(play_theme_music("TETRIS.MUS") > 0) {
        restore_screen();
        return 1;
    }

    // Wait for an Enter press, then exit on its release so the release
    // doesn't leak to the shell. Requiring the press first ignores a late
    // release of the Enter that launched us.
    enter_down = 0;
    while(true) {
        kb_event = kb_readbuf();
        kb_char = (uint8_t)kb_event;
        kb_flags = (uint8_t)(kb_event >> 8);
        // nested ifs, not &&: this compiler's && is bitwise and doesn't short-circuit
        if(kb_char == '\r') {
            if(kb_flags & KB_KEYFLAG_BREAK) {
                if(enter_down) break;
            } else {
                enter_down = 1;
            }
        }
    }
    stop_theme_music();
    restore_screen();

    return 0;
}
