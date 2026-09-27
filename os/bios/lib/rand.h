#pragma once

#include "types.h"

// 8-bit pseudo-random number generator (:rand8 in math.asm). Returns the
// next value in a 256-long sequence that visits every byte value 0x00-0xff
// once, and stores it back to rand_seed.
extern uint8_t rand8(void);

// PRNG state ($rand_seed). VAR globals are not zeroed at load, so it holds
// whatever was left behind; assign it for a repeatable sequence, or from
// something variable (e.g. a keypress timing counter) for a different one.
extern uint8_t rand_seed;
