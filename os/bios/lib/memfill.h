#pragma once

#include "types.h"

// Fill (count_m1 + 1) bytes starting at addr with byte.
extern void memfill(void *addr, uint8_t byte, uint8_t count_m1);

// Fill (halfblocks_m1 + 1) 8-byte half-blocks starting at addr with byte.
extern void memfill_half_blocks(void *addr, uint8_t byte, uint8_t halfblocks_m1);

// Fill (blocks_m1 + 1) 16-byte blocks starting at addr with byte.
extern void memfill_blocks(void *addr, uint8_t byte, uint8_t blocks_m1);

// Fill (segments_m1 + 1) 128-byte segments starting at addr with byte.
extern void memfill_segments(void *addr, uint8_t byte, uint8_t segments_m1);
