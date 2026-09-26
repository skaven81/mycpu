#pragma once

#include "fat16_util.h"

// Print a human-readable FAT16 filesystem descriptor to the terminal.
// h: pointer to a mounted fs_handle (struct fs_handle is defined by
//    fat16_util.h, included above).
// Evicted from the BIOS -- see os/lib/fat16_print.asm.
extern void fat16_print(struct fs_handle *h);
