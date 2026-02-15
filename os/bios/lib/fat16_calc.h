// Get the next cluster in a file's cluster chain.
// Returns next cluster number. Special values:
//   0x0000=free, 0x0001=reserved/ATA error, 0xfff7=bad sector,
//   0xfff8-0xffff=end of file
extern uint16_t fat16_next_cluster(struct fs_handle *h, uint16_t cluster);

// Convert an LBA address to a FAT16 cluster number.
extern uint16_t fat16_lba_to_cluster(struct fs_handle *h, uint16_t lba_hi, uint16_t lba_lo);

// Convert a cluster number to LBA address.
// Returns lo word of LBA; writes hi word to *lba_hi.
// Uses custom call handler for 2-word return.
extern uint16_t fat16_cluster_to_lba(struct fs_handle *h, uint16_t cluster, uint16_t *lba_hi);
