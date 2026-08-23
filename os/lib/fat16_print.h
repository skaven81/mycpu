// Print a human-readable FAT16 filesystem descriptor to the terminal.
// h: pointer to a mounted fs_handle (see fat16_util.h, which must be
//    included before this header for the struct fs_handle definition).
// Evicted from the BIOS -- see os/lib/fat16_print.asm.
extern void fat16_print(struct fs_handle *h);
