#include "splash_screen.h"

int main(int argc, char **argv) {
    if(display_splash_screen("SPLASH.BIN") > 0) {
        return 1;
    }

    return 0;
}
