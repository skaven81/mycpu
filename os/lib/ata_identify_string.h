#pragma once

#include "types.h"

// Identify an ATA drive and return a malloc'd (4 blocks, 64 bytes) string
// describing it: "${model}${firmware} ${capacity}MiB\0", or "Not detected\0"
// if the drive did not respond. Caller must free() the returned string.
// drive_id: 0=master, 1=slave.
// Evicted from the BIOS -- see os/lib/ata_identify_string.asm.
extern char *ata_identify_string(uint8_t drive_id);
