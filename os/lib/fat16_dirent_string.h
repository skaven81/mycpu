// Returns allocated 48-byte formatted string. Caller must free().
// dirent: pointer to a parsed (BE) FAT16 directory entry (see
//    fat16_dirent.h, which must be included before this header for the
//    struct fat16_dirent definition).
// Evicted from the BIOS -- see os/lib/fat16_dirent_string.asm.
extern char *fat16_dirent_string(struct fat16_dirent *dirent);
