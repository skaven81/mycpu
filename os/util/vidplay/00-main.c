#include "types.h"
#include "terminal_output.h"
#include "fat16_pathfind.h"
#include "fat16_dirent.h"
#include "fat16_util.h"
#include "fat16_dir.h"
#include "malloc.h"
#include "strtoi.h"
#include "fat16_readfile.h"
#include "clearscreen.h"
#include "sprintf.h"
#include "cursor.h"
#include "extmalloc.h"

#define MAX_FRAMES 2048
#define BUFFER_SIZE (uint8_t)250

extern uint8_t ring_read_page;
extern uint8_t ring_write_page;
extern uint8_t frames_in_buffer;
extern uint16_t total_frames_remaining;
extern uint16_t frame_count;
extern uint16_t playback_frame;
extern uint8_t frame_segments;
extern uint8_t color_mode;

struct fat16_dirent frame_load_dirent;
static uint8_t reserved_pages[250];

static void usage();
static void reserve_extmem_pages();
static void free_extmem_pages();
static void load_frame_from_dirent(struct fat16_dirent *dirent, struct fs_handle *fsh);

extern void start_frame_isr();
extern void stop_frame_isr();

int main(int argc, char **argv) {
    struct fat16_dirent *frames_dirent;
    struct fs_handle *frames_fsh;
    uint16_t *starting_clusters;
    struct fat16_dirwalk_ctx *dirwalk_ctx;
    uint16_t frames_dir_starting_cluster;
    char *frame_filename;
    char strtoi_buf[7];
    uint16_t frame_no;
    uint8_t strtoi_flags;

    frame_count = 0;
    total_frames_remaining = 0;
    frames_in_buffer = 0;
    playback_frame = 0;
    color_mode = 0;

    // first argument should be a path to a directory, else exit with usage/error
    if(argc < 2) {
        usage();
        return 1;
    }
    // use pathfind to get back a dirent for the directory, if it exists
    frames_dirent = fat16_pathfind(argv[1], &frames_fsh);
    if((frames_dirent >> 8) == 0x00) {
        print("Error: directory not found\n");
        return 1;
    }
    if((frames_dirent >> 8) == 0x01) {
        printf("ATA error from pathfind: 0x%x\n", (uint8_t)frames_dirent);
        return 1;
    }
    // directory found: frames_dirent and frames_fsh are valid
    frames_dir_starting_cluster = frames_dirent->start_cluster;
    free(frames_dirent);

    /* Load frame metadata. The approach is a bit hacky but saves on RAM.  Allocate an
     * array of words (each word is a cluster number). As we walk the directory, search
     * for files named <4-digit-hex>.TXT or <4-digit-hex>.COL. For each, strtoi the
     * basename into a number; this is the index in the array (the frame number). At that
     * location in the array, write the starting cluster number of that file. We keep the
     * whole dirent of one of the files, so for each file we need to read, we just replace
     * the starting cluster in the dirent and pass to fat16_readfile().
     * When frame 0 is found, the extension (.TXT vs .COL) determines playback mode.
     */
    starting_clusters = calloc_segments((uint8_t)(MAX_FRAMES >> 7));
    dirwalk_ctx = fat16_dirwalk_start(frames_fsh, frames_dir_starting_cluster);
    if((dirwalk_ctx >> 8) == 0x00) {
        printf("ATA error reading cluster %X: 0x%x\n", frames_dir_starting_cluster, (uint8_t)dirwalk_ctx);
        free(starting_clusters);
        return 1;
    }
    cursor_off();
    print("Loading frame metadata...\n");
    while(1) {
        frames_dirent = fat16_dirwalk_next(dirwalk_ctx);
        if(frames_dirent == 0x0000) // all directory entries walked
            break;
        if(frames_dirent->attribute & 0x10)
            continue; // skip directories
        if((frames_dirent >> 8) == 0x00) {
            printf("ATA error reading directory entry: 0x%x\n", (uint8_t)frames_dirent);
            fat16_dirwalk_end(dirwalk_ctx);
            free(starting_clusters);
            return 1;
        }
        frame_filename = fat16_dirent_filename(frames_dirent);
        strtoi_buf[0] = '0';
        strtoi_buf[1] = 'x';
        strtoi_buf[2] = frame_filename[0];
        strtoi_buf[3] = frame_filename[1];
        strtoi_buf[4] = frame_filename[2];
        strtoi_buf[5] = frame_filename[3];
        strtoi_buf[6] = 0;
        frame_no = (uint16_t)strtoi(strtoi_buf, &strtoi_flags);
        if(strtoi_flags) {
            printf("\nBad frame file %s: 0x%x\n", frame_filename, strtoi_flags);
            free(frame_filename);
            continue;
        }
        if(frame_no > MAX_FRAMES) {
            printf("\nBad frame file %s: larger than %U\n", frame_filename, MAX_FRAMES);
            free(frame_filename);
            continue;
        }
        if(frame_no == 0) {
            // if first frame, copy the dirent struct to a global var,
            // as we need a functional (if fake) dirent when loading frames.
            frame_load_dirent = *frames_dirent;
            frame_segments = (uint8_t)(frames_dirent->file_size.lo >> 7) - 1;
            // detect playback mode from extension: XXXX.COL = color, XXXX.TXT = ascii
            // frame_filename is "XXXX.EXT" so index 5 is first char of extension
            if(frame_filename[5] == 'C') {
                color_mode = 1;
                print("Color mode detected\n");
            } else {
                print("ASCII mode detected\n");
            }
        }
        printf("%s at cluster 0x%X -> frame #%U    \r", frame_filename, frames_dirent->start_cluster, frame_no);
        free(frame_filename);
        starting_clusters[frame_no] = frames_dirent->start_cluster;
        frame_count++;
    }
    print("\n");
    fat16_dirwalk_end(dirwalk_ctx);
    printf("Loaded metadata for %U frames\n", frame_count);

    /* Reserve extended memory pages 0x06..0xFF so BIOS functions
     * (e.g. fat16_next_cluster) cannot allocate into the ring buffer. */
    reserve_extmem_pages();

    /* Start frame playback countdown */
    total_frames_remaining = frame_count;

    /* Preload the frame buffer with the first BUFFER_SIZE frames */
    frame_no = 0;
    frames_in_buffer = 0;
    ring_write_page = 0x05;  // first write increments to 0x06, matching ring_read_page
    ring_read_page = 0x06;
    while((total_frames_remaining > 0) && (frames_in_buffer < (uint8_t)BUFFER_SIZE)) {
        frame_load_dirent.start_cluster = starting_clusters[frame_no];
        load_frame_from_dirent(&frame_load_dirent, frames_fsh);
        frame_no++;
        total_frames_remaining--;
        printf("Loaded frame data for frame %U into page 0x%x\r", frame_no, ring_write_page);
    }
    print("\n");

    // In color mode, clear screen to solid blocks so frame data (color bytes only)
    // replaces the default white-on-black text display
    if(color_mode) {
        clear_screen(0xdb, 0x00);
        // Replace last line on the screen with spaces for status line
        sprintf((void *)0x4ec0, "                                                            ");
    }

    // Start playback
    start_frame_isr();

    // Keep playing while loading more frames
    while(total_frames_remaining > 0) {
        while(frames_in_buffer >= (uint8_t)BUFFER_SIZE); // wait for buffer to not be full
        sprintf((void *)0x4ec0, "Frame(%U/%U) Buf(%u/%u) R/W page(0x%x/0x%x)", playback_frame, frame_count, frames_in_buffer, BUFFER_SIZE, ring_read_page, ring_write_page);
        frame_load_dirent.start_cluster = starting_clusters[frame_no];
        load_frame_from_dirent(&frame_load_dirent, frames_fsh);
        frame_no++;
        total_frames_remaining--;
    }

    // Wait for playback to finish
    while(frames_in_buffer > (uint8_t)0) {
        sprintf((void *)0x4ec0, "Frame(%U/%U) Buf(%u/%u) R/W page(0x%x/0x%x)", playback_frame, frame_count, frames_in_buffer, BUFFER_SIZE, ring_read_page, ring_write_page);
    }

    // End playback
    stop_frame_isr();

    // Release reserved extended memory pages
    free_extmem_pages();

    clear_screen(0x00, 0x3f);   // clear screen back to white text
    cursor_init();              // move cursor to top left
    cursor_on();
    free(starting_clusters);

    return 0;
}

static void reserve_extmem_pages() {
    uint8_t i;
    print("Reserving extended memory pages...\n");
    for(i = 0; i < (uint8_t)250; i++) {
        reserved_pages[i] = extmalloc();
    }
}

static void free_extmem_pages() {
    uint8_t i;
    for(i = 0; i < (uint8_t)250; i++) {
        extfree(reserved_pages[i]);
    }
}

static void load_frame_from_dirent(struct fat16_dirent *dirent, struct fs_handle *fsh) {
    static void *d_window = 0xd000;
    static void *null_ptr = 0x0000;

    // set D page window
    ring_write_page++;
    if(ring_write_page == 0) // rollover from 0xff to 0x00
        ring_write_page = 0x06;
    *((uint8_t *)0xc200) = ring_write_page;

    // no context pointer (one shot)
    // dirent = fake/mangled dirent that contains the cluster number from the cache
    // 8 = max number of sectors (512 * 8 = 4096 bytes)
    // dest = D page
    // ignore status output
    fat16_readfile(null_ptr, dirent, 8, d_window, fsh);

    frames_in_buffer++;
}

static void usage() {
    print("Usage: vidplay <directory>\n");
    print("  Plays ASCII videos (.TXT frames) or color videos (.COL frames)\n");
    print("  Mode is auto-detected from the extension of frame 0000.*\n");
}
