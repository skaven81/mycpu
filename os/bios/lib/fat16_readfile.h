// Context struct for streaming file reads (16 bytes, 1 malloc block).
// Caller allocates via malloc_blocks(1) and zeroes flags byte before first use.
// Pass NULL (0x0000) for state when doing one-shot reads.
struct fat16_readfile_ctx {
    uint8_t flags;                        // 0x00: bit 0 = initialized, bit 1 = EOF
    uint8_t device_id;                    // 0x01: ATA device ID (cached from fs_handle)
    uint16_t current_cluster;             // 0x02: current position in cluster chain
    struct uint32 lba;                    // 0x04: LBA of next sector to read
    uint8_t sectors_remaining_in_cluster; // 0x08: sectors left before next_cluster needed
    uint8_t sectors_per_cluster;          // 0x09: cached from fs_handle
    uint16_t file_sectors_remaining;      // 0x0A: total sectors left in file (for EOF detection)
    uint8_t _reserved[4];                // 0x0C: padding / future use
};

// Read a file into memory. File must be <64KiB.
//
// state: context struct pointer for streaming, or NULL (0x0000) for one-shot
// dirent: directory entry containing the file's start cluster
// n_sectors: number of 512-byte sectors to read (0=read entire file)
// dest: memory address to write file data into (must be 512-byte aligned allocation)
// h: filesystem handle
//
// Returns status: 0x00=success, >0=ATA error code
//
// Four modes:
//   n_sectors==0, any state:     One-shot (reads entire file, state ignored)
//   n_sectors>0, state==NULL:    Sector-limited one-shot (reads first n_sectors sectors)
//   n_sectors>0, state not init: Initial streaming (sets up state, reads n_sectors)
//   n_sectors>0, state init:     Resume streaming (continues from saved state)
//
// After a streaming read, check state->flags & 0x02 for EOF.
extern uint8_t fat16_readfile(struct fat16_readfile_ctx *state,
                              struct fat16_dirent *dirent,
                              uint16_t n_sectors,
                              void *dest,
                              struct fs_handle *h);
