#include "types.h"
#include "terminal_output.h"
#include "malloc.h"
#include "fat16_util.h"
#include "fat16_dirent.h"
#include "fat16_dir.h"
#include "fat16_calc.h"
#include "fat16_pathfind.h"
extern void exec_chain(char *path);


uint16_t total = 0;
uint16_t fail = 0;

void pass() {
    total++;
}

void fail_test(char *name) {
    total++;
    fail++;
    printf("FAIL [");
    print(name);
    printf("]\n");
}

void assert_u8(uint8_t actual, uint8_t expected, char *name) {
    total++;
    if (actual != expected) {
        fail++;
        printf("FAIL [");
        print(name);
        printf("] exp=0x%x got=0x%x\n", expected, actual);
    }
}

void assert_u16(uint16_t actual, uint16_t expected, char *name) {
    total++;
    if (actual != expected) {
        fail++;
        printf("FAIL [");
        print(name);
        printf("] exp=0x%X got=0x%X\n", expected, actual);
    }
}

// ---- Section 1: Core types (silent) ----

void test_types() {
    struct uint32 u;
    u.hi = 0x1234;
    u.lo = 0x5678;
    assert_u16(u.hi, 0x1234, "uint32.hi");
    assert_u16(u.lo, 0x5678, "uint32.lo");

    struct uint32 u2;
    struct fs_handle fh;
    struct fat16_dirent de;
    if (sizeof(u2) == 4) { pass(); } else { fail_test("sizeof(uint32)"); }
    if (sizeof(fh) == 128) { pass(); } else { fail_test("sizeof(fs_handle)"); }
    if (sizeof(de) == 32) { pass(); } else { fail_test("sizeof(fat16_dirent)"); }
}

// ---- Section 2: Memory management (silent) ----

void test_memory() {
    uint8_t *p = (uint8_t *)malloc_blocks(1);
    if (p != NULL) { pass(); } else { fail_test("malloc non-null"); }
    *p = 0xAB;
    assert_u8(*p, 0xAB, "malloc write/read");
    free(p);

    p = (uint8_t *)calloc_blocks(1);
    if (p != NULL) { pass(); } else { fail_test("calloc non-null"); }
    assert_u8(*p, 0x00, "calloc zeroed");
    free(p);

    uint8_t *buf = (uint8_t *)malloc_blocks(2);
    if (buf != NULL) { pass(); } else { fail_test("malloc(2) non-null"); }
    uint8_t i;
    for (i = 0; i < 16; i++) {
        buf[i] = i + 0x40;
    }
    assert_u8(buf[0], 0x40, "pattern buf[0]");
    assert_u8(buf[15], 0x4F, "pattern buf[15]");
    free(buf);
}

// ---- Section 3: putchar (visual) ----

void test_putchar() {
    printf("putchar: ");
    putchar('O');
    putchar('K');
    putchar(0x0a);
    printf("putchar_direct: ");
    putchar_direct('O');
    putchar_direct('K');
    putchar(0x0a);
}

// ---- Section 4: fs_handle struct fields (silent) ----
// Expected values from boot sector of current SD card.
// Update these constants if the card is reformatted.

void test_fs_handle() {
    struct fs_handle *h = &drive_0_fs_handle;

    assert_u16(h->bytes_per_sector, 512, "bytes_per_sector");
    assert_u8(h->sectors_per_cluster, 4, "sectors_per_cluster");
    assert_u16(h->sectors_per_fat, 60, "sectors_per_fat");
    assert_u16(h->num_root_entries, 512, "num_root_entries");
    assert_u8(h->num_fat_copies, 2, "num_fat_copies");
    assert_u16(h->current_dir_cluster, 0, "current_dir_cluster");

    // Self-consistency: function return matches struct field
    uint8_t ata_func = fat16_handle_get_ataid(h);
    uint8_t ata_field = h->ata_device_id;
    assert_u8(ata_func, ata_field, "ataid func==struct");

    uint16_t cdc_func = fat16_get_current_directory_cluster(h);
    uint16_t cdc_field = h->current_dir_cluster;
    assert_u16(cdc_func, cdc_field, "dir_cluster func==struct");
}

// ---- Section 5: Directory walking (silent) ----

void test_dirwalk() {
    struct fs_handle *h = &drive_0_fs_handle;
    struct fat16_dirwalk_ctx *ctx = fat16_dirwalk_start(h, 0);
    uint16_t ctx_addr = (uint16_t)ctx;
    if ((ctx_addr >> 8) == 0) {
        fail_test("dirwalk_start");
        return;
    }
    pass();

    uint8_t count = 0;

    while (count < 20) {
        struct fat16_dirent *entry = fat16_dirwalk_next(ctx);
        uint16_t addr = (uint16_t)entry;
        if ((addr >> 8) == 0) {
            break;
        }
        count++;
    }
    fat16_dirwalk_end(ctx);
    if (count >= 2) { pass(); } else { fail_test("dirwalk count>=2"); }
}

// ---- Section 6: dir_find (silent) ----

void test_dir_find() {
    struct fs_handle *h = &drive_0_fs_handle;
    struct fat16_dirent *found = fat16_dir_find(0xff, 0x00, "SYS", 0, h);
    uint16_t addr = (uint16_t)found;

    if (addr == 0 || (addr >> 8) < 0x40) {
        fail_test("dir_find SYS found");
        return;
    }
    pass();

    uint8_t attr = found->attribute;
    if (attr & 0x10) { pass(); } else { fail_test("dir_find SYS is dir"); }

    uint16_t cluster = found->start_cluster;
    if (cluster > 0) { pass(); } else { fail_test("dir_find SYS cluster>0"); }

    free(found);
}

// ---- Section 7: File sizes via dirwalk (silent) ----
// Dirs/volume labels should have size 0; regular files size > 0.

void test_filesize() {
    struct fs_handle *h = &drive_0_fs_handle;
    struct fat16_dirwalk_ctx *ctx = fat16_dirwalk_start(h, 0);
    uint16_t ctx_addr = (uint16_t)ctx;
    if ((ctx_addr >> 8) == 0) {
        fail_test("filesize dirwalk_start");
        return;
    }

    uint8_t count = 0;

    while (count < 10) {
        struct fat16_dirent *entry = fat16_dirwalk_next(ctx);
        uint16_t addr = (uint16_t)entry;
        if ((addr >> 8) == 0) {
            break;
        }

        uint16_t size_hi = entry->file_size.hi;
        uint16_t size_lo = entry->file_size.lo;
        uint8_t attr = entry->attribute;

        if (attr & 0x18) {
            // Directory or volume label: size must be 0
            assert_u16(size_hi, 0, "dir/vol size_hi==0");
            assert_u16(size_lo, 0, "dir/vol size_lo==0");
        } else {
            // Regular file: size must be > 0
            if (size_hi > 0 || size_lo > 0) { pass(); } else { fail_test("file size>0"); }
        }
        count++;
    }
    fat16_dirwalk_end(ctx);
    if (count >= 2) { pass(); } else { fail_test("filesize count>=2"); }
}

// ---- Section 8: Cluster chain (silent) ----

void test_cluster_chain() {
    struct fs_handle *h = &drive_0_fs_handle;
    struct fat16_dirent *sys = fat16_dir_find(0xff, 0x00, "SYS", 0, h);
    uint16_t saddr = (uint16_t)sys;
    if (saddr == 0 || (saddr >> 8) < 0x40) {
        fail_test("cluster_chain SYS not found");
        return;
    }

    uint16_t cluster = sys->start_cluster;
    free(sys);
    if (cluster > 0) { pass(); } else { fail_test("SYS start cluster>0"); }

    uint8_t ended = 0;
    uint8_t count = 1;
    while (count < 20) {
        uint16_t next = fat16_next_cluster(h, cluster);
        if (next >= 0xfff8) {
            ended = 1;
            break;
        }
        if (next == 0x0001 || next == 0xfff7) {
            break;
        }
        cluster = next;
        count++;
    }
    if (ended) { pass(); } else { fail_test("cluster chain ends normally"); }
    if (count >= 1) { pass(); } else { fail_test("cluster chain len>=1"); }
}

// ---- Section 9: Cluster-to-LBA (silent) ----

void test_cluster_to_lba() {
    struct fs_handle *h = &drive_0_fs_handle;
    uint16_t lba_hi;

    // Cluster 2 = first data cluster, LBA must be > 0
    uint16_t lba_lo = fat16_cluster_to_lba(h, 2, &lba_hi);
    if (lba_hi > 0 || lba_lo > 0) { pass(); } else { fail_test("cluster2 lba>0"); }
}

// ---- Section 10: pathfind ----

void test_pathfind_expect(char *path, uint8_t expect_found) {
    struct fs_handle *h;
    struct fat16_dirent *entry = fat16_pathfind(path, &h);
    uint16_t result = (uint16_t)entry;

    if (expect_found) {
        if (result != 0 && (result >> 8) >= 0x40) {
            pass();
            free(entry);
        } else {
            fail_test(path);
        }
    } else {
        if (result == 0) {
            pass();
        } else if ((result >> 8) >= 0x40) {
            fail_test(path);
            free(entry);
        } else {
            fail_test(path);
        }
    }
}

void test_pathfind() {
    test_pathfind_expect("SYS", 1);
    test_pathfind_expect("/SYS", 1);
    test_pathfind_expect("0:/SYS", 1);
    test_pathfind_expect("NOEXIST.TXT", 0);
}

// ---- Main ----

void main() {
    // Reset to root directory: tests use relative paths and expect CWD == root
    drive_0_fs_handle.current_dir_cluster = 0;
    test_types();
    test_memory();
    test_putchar();
    test_fs_handle();
    test_dirwalk();
    test_dir_find();
    test_filesize();
    test_cluster_chain();
    test_cluster_to_lba();

    test_pathfind();

    uint16_t passed = total - fail;
    if (fail == 0) {
        printf("cctest4: %U/%U PASS\n", total, total);
    } else {
        printf("cctest4: %U/%U FAIL\n", passed, total);
    }
    exec_chain("/CCTEST/CCTEST5.ODY");
}
