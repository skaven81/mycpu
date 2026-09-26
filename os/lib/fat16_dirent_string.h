#pragma once

#include "fat16_dirent.h"

// Returns allocated 48-byte formatted string. Caller must free().
// dirent: pointer to a parsed (BE) FAT16 directory entry (struct
//    fat16_dirent is defined by fat16_dirent.h, included above).
// Evicted from the BIOS -- see os/lib/fat16_dirent_string.asm.
extern char *fat16_dirent_string(struct fat16_dirent *dirent);
