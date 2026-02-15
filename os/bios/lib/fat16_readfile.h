// Read a file into memory. File must be <64KiB.
// dirent: directory entry containing the file's start cluster
// max_sectors: max 512-byte sectors to read (0=read entire file)
// target: memory address to write file data into (must be 512-byte aligned allocation)
// h: filesystem handle
// Returns status: 0x00=success, >0=ATA error code
extern uint8_t fat16_readfile(struct fat16_dirent *dirent, uint8_t max_sectors, void *target, struct fs_handle *h);
