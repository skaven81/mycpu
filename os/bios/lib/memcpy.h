#pragma once

#include "types.h"

// Copy (count_m1 + 1) bytes from src to dest.
extern void memcpy(void *src, void *dest, uint8_t count_m1);

// Copy (blocks_m1 + 1) 16-byte blocks from src to dest.
extern void memcpy_blocks(void *src, void *dest, uint8_t blocks_m1);

// Copy (segments_m1 + 1) 128-byte segments from src to dest.
extern void memcpy_segments(void *src, void *dest, uint8_t segments_m1);
