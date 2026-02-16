#include "types.h"
#include "terminal_output.h"
#include "malloc.h"
#include "fat16_util.h"
#include "fat16_dirent.h"
#include "fat16_dir.h"

uint16_t total = 0;
uint16_t fail = 0;

void assert_u8(uint8_t actual, uint8_t expected, char *name) {
    total++;
    if (actual != expected) {
        fail++;
        printf("FAIL [%s] exp=0x%x got=0x%x\n", name, expected, actual);
    }
}

void assert_u16(uint16_t actual, uint16_t expected, char *name) {
    total++;
    if (actual != expected) {
        fail++;
        printf("FAIL [%s] exp=0x%X got=0x%X\n", name, expected, actual);
    }
}

void print_pad2(uint16_t val) {
    if (val < 10) {
        putchar('0');
    }
    printf("%U", val);
}

void print_dirent(struct fat16_dirent *d) {
    uint8_t *p = (uint8_t *)d;
    uint8_t i;
    uint16_t year;
    uint16_t month;
    uint16_t day;
    uint16_t hour;
    uint16_t minute;

    // Filename (8 chars) + space + extension (3 chars)
    for (i = 0; i < 8; i++) {
        putchar(p[i]);
    }
    putchar(' ');
    for (i = 8; i < 11; i++) {
        putchar(p[i]);
    }
    printf("  ");

    // Write date: YYYY-MM-DD
    year = (d->write_date >> 9) + 1980;
    month = (d->write_date >> 5) & 0x0f;
    day = d->write_date & 0x1f;
    printf("%U-", year);
    print_pad2(month);
    putchar('-');
    print_pad2(day);
    putchar(' ');

    // Write time: HH:MM
    hour = d->write_time >> 11;
    minute = (d->write_time >> 5) & 0x3f;
    print_pad2(hour);
    putchar(':');
    print_pad2(minute);
    printf("  ");

    // Size or <DIR>
    if (d->attribute & 0x10) {
        printf("<DIR>");
    } else if (d->file_size.hi == 0) {
        printf("%U", d->file_size.lo);
    } else {
        printf("0x%X%X", d->file_size.hi, d->file_size.lo);
    }
    putchar(0x0a);
}

void main() {
    struct fs_handle *h = &drive_0_fs_handle;
    uint16_t result = fat16_dirwalk_start(h, 0);
    uint16_t count = 0;
    struct fat16_dirent *entry;
    struct fat16_dirent *parsed;

    if ((result >> 8) == 0) {
        printf("dirwalk_start failed\n");
        return;
    }

    entry = (struct fat16_dirent *)result;
    parsed = (struct fat16_dirent *)malloc_blocks(2);

    while (count < 128) {
        uint8_t fb = entry->filename[0];
        if (fb == 0) {
            break;
        }
        if (fb != 0xe5) {
            uint16_t exp_size_hi;
            uint8_t exp_attr;
            uint16_t exp_cluster;
            uint16_t exp_size_lo;

            // Parse raw entry into native byte order
            fat16_dirent_parse(entry, parsed);

            // Validate parsed struct against getter functions
            exp_attr = fat16_dirent_attribute(entry);
            exp_cluster = fat16_dirent_cluster(entry);
            exp_size_lo = fat16_dirent_filesize(entry, &exp_size_hi);

            assert_u8(parsed->attribute, exp_attr, "attribute");
            assert_u16(parsed->start_cluster, exp_cluster, "cluster");
            assert_u16(parsed->file_size.hi, exp_size_hi, "size_hi");
            assert_u16(parsed->file_size.lo, exp_size_lo, "size_lo");

            // Display directory entry from parsed struct fields
            print_dirent(parsed);

            count++;
        }
        entry = fat16_dirwalk_next();
        uint16_t addr = (uint16_t)entry;
        if ((addr >> 8) == 0) {
            break;
        }
    }

    free(parsed);
    fat16_dirwalk_end();

    printf("\n%U entries", count);
    if (fail > 0) {
        printf(", %U FAILED", fail);
    }
    printf(" (%U tests)\n", total);
}
