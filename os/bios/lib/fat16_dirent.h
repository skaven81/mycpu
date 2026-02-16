// FAT16 directory entry (32 bytes)
// On-disk fields are little-endian; the CPU is big-endian.
// Raw entries (from dirwalk or ATA reads) still have LE fields — use the
// getter functions below or call fat16_dirent_parse() to byte-swap into
// a native-endian struct where fields can be accessed directly.
struct fat16_dirent {
    char filename[8];                // 0x00: space-padded 8.3 name
    char extension[3];               // 0x08: space-padded extension
    uint8_t attribute;               // 0x0b: bit 4 = directory
    uint8_t _reserved[2];            // 0x0c
    uint16_t create_time;            // 0x0e
    uint16_t create_date;            // 0x10
    uint16_t access_date;            // 0x12
    uint16_t cluster_hi;             // 0x14: high cluster word (FAT32 only, 0 in FAT16)
    uint16_t write_time;             // 0x16
    uint16_t write_date;             // 0x18
    uint16_t start_cluster;          // 0x1a
    struct uint32 file_size;         // 0x1c
};

// Returns allocated string with "FILENAME.EXT" format. Caller must free().
extern char *fat16_dirent_filename(struct fat16_dirent *dirent);

// Returns attribute byte from dirent.
extern uint8_t fat16_dirent_attribute(struct fat16_dirent *dirent);

// Returns starting cluster (byte-swapped to native big-endian).
extern uint16_t fat16_dirent_cluster(struct fat16_dirent *dirent);

// Returns allocated 48-byte formatted string. Caller must free().
extern char *fat16_dirent_string(struct fat16_dirent *dirent);

// Returns lo word of file size; writes hi word to *size_hi.
// Uses custom call handler for 2-word return.
extern uint16_t fat16_dirent_filesize(struct fat16_dirent *dirent, uint16_t *size_hi);

// Copy a raw 32-byte directory entry into dest, byte-swapping all
// multi-byte numeric fields from little-endian to native big-endian.
// Supports in-place parsing (raw == dest).
extern void fat16_dirent_parse(struct fat16_dirent *raw, struct fat16_dirent *dest);
