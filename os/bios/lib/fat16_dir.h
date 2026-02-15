// Directory walking (non-reentrant: uses global state)
// fat16_dirwalk_start returns entry address, or 0x00nn on error (nn=ATA error)
extern uint16_t fat16_dirwalk_start(struct fs_handle *h, uint16_t dir_cluster);
extern struct fat16_dirent *fat16_dirwalk_next();
extern void fat16_dirwalk_end();

// Search for a file/dir in a directory.
// filter_in: attribute mask to require (0xff=allow all)
// filter_out: attribute mask to exclude (0x18=dirs+vol labels, 0x10=dirs)
// name: filename to match (empty string=match any)
// Returns entry address, 0x0000=not found, 0x02nn=ATA error.
// Caller must free() the returned entry if non-zero.
extern struct fat16_dirent *fat16_dir_find(uint8_t filter_in, uint8_t filter_out, char *name, uint16_t cluster, struct fs_handle *h);
