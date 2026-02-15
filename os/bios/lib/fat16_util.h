struct fs_handle {
    char path[54];                   // 0x00: current dir path (53 chars + null)
    uint16_t current_dir_cluster;    // 0x36: cluster of current dir (0=root)
    uint16_t bytes_per_sector;       // 0x38
    uint8_t sectors_per_cluster;     // 0x3a
    uint16_t reserved_sectors;       // 0x3b
    uint8_t num_fat_copies;          // 0x3d
    uint16_t num_root_entries;       // 0x3e
    struct uint32 total_sectors;     // 0x40
    uint8_t media_descriptor;        // 0x44
    uint16_t sectors_per_fat;        // 0x45
    struct uint32 reserved_lba;      // 0x47: ReservedRegion start
    struct uint32 fat_lba;           // 0x4b: FATRegion start
    struct uint32 rootdir_lba;       // 0x4f: RootDirRegion start
    struct uint32 data_lba;          // 0x53: DataRegion start
    uint16_t fat_size_sectors;       // 0x57
    uint16_t rootdir_size_sectors;   // 0x59
    struct uint32 data_size_sectors; // 0x5b
    uint8_t ata_device_id;           // 0x5f
    char oem_id[9];                  // 0x60
    char volume_label[12];           // 0x69
    uint8_t _reserved[11];           // 0x75: pad to 128 bytes
};

extern struct fs_handle drive_0_fs_handle;
extern struct fs_handle drive_1_fs_handle;

extern uint8_t fat16_get_current_drive_number();
extern uint16_t fat16_get_current_directory_cluster(struct fs_handle *h);
extern uint8_t fat16_handle_get_ataid(struct fs_handle *h);
extern void fat16_print(struct fs_handle *h);
