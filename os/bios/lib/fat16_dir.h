// Context struct for directory walking (16 bytes, 1 malloc block).
// Allocated by dirwalk_start, freed by dirwalk_end.
struct fat16_dirwalk_ctx {
    uint16_t fs_handle;              // 0x00: pointer to fs_handle
    struct uint32 next_sector_lba;   // 0x02: LBA of next sector to read
    uint16_t sector_data;            // 0x06: pointer to 512-byte sector buffer
    uint8_t dir_idx;                 // 0x08: entry index (0-15, 0xFF=before-first)
    uint8_t sectors_remaining;       // 0x09: sectors left to read
    uint8_t _reserved[6];           // 0x0A: padding
};

// Initialize directory walking. Returns context pointer.
// High byte >= 0x60 = success, 0x00nn = error (nn = ATA error byte).
extern struct fat16_dirwalk_ctx *fat16_dirwalk_start(struct fs_handle *h, uint16_t dir_cluster);

// Advance to next valid directory entry. Skips deleted (0xE5) entries,
// detects end-of-directory (0x00), and auto-parses each entry to big-endian.
// Returns entry pointer: high byte >= 0x40 = valid, 0x0000 = end, 0x00nn = error.
// Returned entry points into internal sector buffer (do NOT free it).
extern struct fat16_dirent *fat16_dirwalk_next(struct fat16_dirwalk_ctx *ctx);

// Free sector buffer and context struct.
extern void fat16_dirwalk_end(struct fat16_dirwalk_ctx *ctx);

// Search for a file/dir in a directory.
// filter_in: attribute mask to require (0xff=allow all)
// filter_out: attribute mask to exclude (0x18=dirs+vol labels, 0x10=dirs)
// name: filename to match (empty string=match any)
// Returns malloc'd copy of matching entry (already parsed to BE).
// 0x0000=not found, 0x02nn=ATA error.
// Caller must free() the returned entry if non-zero/non-error.
extern struct fat16_dirent *fat16_dir_find(uint8_t filter_in, uint8_t filter_out, char *name, uint16_t cluster, struct fs_handle *h);
