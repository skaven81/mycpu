// Mount a FAT16 filesystem.
// ata_id: 0=master, 1=slave
// start_lo/start_hi: LBA of partition start (usually both 0)
// h: pointer to 128-byte zeroed fs_handle
// Returns status: 0x00=success, 0xfd=extmalloc fail, 0xfe=not FAT16, 0xff=drive not attached
extern uint8_t fat16_mount(uint8_t ata_id, uint16_t start_lo, uint16_t start_hi, struct fs_handle *h);
