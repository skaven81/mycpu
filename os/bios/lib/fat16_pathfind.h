// Find a file or directory by path.
// Supported path formats:
//   FILENAME.EXT          - current directory
//   DIR/DIR/FILENAME.EXT  - relative path
//   /DIR/FILENAME.EXT     - absolute from root
//   0:/DIR/FILENAME.EXT   - from drive 0
//   1:/DIR/FILENAME.EXT   - from drive 1
//
// On success: returns pointer to dirent (caller must free()),
//   and writes the filesystem handle pointer to *fs_handle_out.
// On failure: returns error code (high byte 0x00 or 0x01):
//   0x0000 = not found, 0x0001 = path syntax error,
//   0x01nn = ATA error (nn = error code)
// Uses custom call handler for conditional multi-return.
extern struct fat16_dirent *fat16_pathfind(char *path, struct fs_handle **fs_handle_out);
