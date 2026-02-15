// FAT16 directory entry (32 bytes)
// WARNING: Multi-byte fields are stored in little-endian (disk byte order),
// but the CPU is big-endian. Use the helper functions below for correct values.
struct fat16_dirent {
    char filename[8];                // 0x00: space-padded 8.3 name
    char extension[3];               // 0x08: space-padded extension
    uint8_t attribute;               // 0x0b: bit 4 = directory
    uint8_t _reserved[2];            // 0x0c
    uint16_t create_time;            // 0x0e: (little-endian)
    uint16_t create_date;            // 0x10: (little-endian)
    uint16_t access_date;            // 0x12: (little-endian)
    uint16_t cluster_hi;             // 0x14: high cluster word (FAT32 only, 0 in FAT16)
    uint16_t write_time;             // 0x16: (little-endian)
    uint16_t write_date;             // 0x18: (little-endian)
    uint16_t start_cluster;          // 0x1a: (little-endian)
    struct uint32 file_size;         // 0x1c: (little-endian)
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
