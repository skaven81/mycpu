#include "types.h"
#include "terminal_output.h"
#include "malloc.h"
#include "fat16_util.h"
#include "fat16_dirent.h"
#include "fat16_dir.h"
#include "fat16_calc.h"
#include "fat16_pathfind.h"
#include "fat16_readfile.h"
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

// ---- Section 1: Context-based dirwalk ----

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
        // Entry is auto-parsed to BE; attribute accessible directly
        if (entry->attribute & 0x10) {
            // It's a directory
        }
        count++;
    }
    fat16_dirwalk_end(ctx);
    if (count >= 2) { pass(); } else { fail_test("dirwalk count>=2"); }
}

// ---- Section 2: dir_find with parsed entry ----

void test_dir_find() {
    struct fs_handle *h = &drive_0_fs_handle;
    struct fat16_dirent *found = fat16_dir_find(0xff, 0x00, "SYS", 0, h);
    uint16_t addr = (uint16_t)found;

    if (addr == 0 || (addr >> 8) < 0x40) {
        fail_test("dir_find SYS found");
        return;
    }
    pass();

    // Entry is already parsed to BE; use direct field access
    uint8_t attr = found->attribute;
    if (attr & 0x10) { pass(); } else { fail_test("dir_find SYS is dir"); }

    uint16_t cluster = found->start_cluster;
    if (cluster > 0) { pass(); } else { fail_test("dir_find SYS cluster>0"); }

    free(found);
}

// ---- Section 3: readfile (read first sector) ----

void test_readfile() {
    struct fs_handle *found_h;
    struct fat16_dirent *entry = fat16_pathfind("/SYSTEM.ODY", &found_h);
    uint16_t addr = (uint16_t)entry;
    if (addr == 0 || (addr >> 8) < 0x40) {
        fail_test("readfile pathfind");
        return;
    }
    pass();

    // Allocate 512 bytes and read first sector
    void *buf = (void *)malloc_segments(4);  // 4 segments x 128 bytes = 512 bytes
    if (buf == 0) {
        fail_test("readfile malloc");
        free(entry);
        return;
    }
    pass();

    struct fat16_readfile_ctx *no_state = (struct fat16_readfile_ctx *)0;
    uint8_t status = fat16_readfile(no_state, entry, 1, buf, found_h);
    assert_u8(status, 0x00, "readfile status");

    // Check ODY magic bytes
    uint8_t *p = (uint8_t *)buf;
    assert_u8(p[0], 'O', "ODY magic O");
    assert_u8(p[1], 'D', "ODY magic D");
    assert_u8(p[2], 'Y', "ODY magic Y");

    free(buf);
    free(entry);
}

// ---- Section 4: pathfind ----

void test_pathfind() {
    struct fs_handle *h;

    // Test finding SYS directory (returns parsed entry)
    struct fat16_dirent *entry = fat16_pathfind("SYS", &h);
    uint16_t addr = (uint16_t)entry;
    if (addr != 0 && (addr >> 8) >= 0x40) {
        pass();
        uint8_t attr = entry->attribute;
        if (attr & 0x10) { pass(); } else { fail_test("pathfind SYS is dir"); }
        free(entry);
    } else {
        fail_test("pathfind SYS");
    }

    // Test not found
    entry = fat16_pathfind("NOEXIST.TXT", &h);
    addr = (uint16_t)entry;
    assert_u16(addr, 0x0000, "pathfind NOEXIST");

    // Test ".." from subdir -- returns synthesized entry (cluster=0, root)
    entry = fat16_pathfind("SYS/..", &h);
    addr = (uint16_t)entry;
    if (addr != 0 && (addr >> 8) >= 0x40) {
        pass();
        assert_u16(entry->start_cluster, 0x0000, "pathfind SYS/.. cluster==root");
        free(entry);
    } else {
        fail_test("pathfind SYS/..");
    }

    // Test compound path with ".." (navigate in, back out, in again)
    entry = fat16_pathfind("SYS/../SYS", &h);
    addr = (uint16_t)entry;
    if (addr != 0 && (addr >> 8) >= 0x40) {
        pass();
        free(entry);
    } else {
        fail_test("pathfind SYS/../SYS");
    }

    // Test bare root path "/"
    entry = fat16_pathfind("/", &h);
    addr = (uint16_t)entry;
    if (addr != 0 && (addr >> 8) >= 0x40) {
        pass();
        assert_u8(entry->attribute & 0x10, 0x10, "pathfind / is dir");
        assert_u16(entry->start_cluster, 0x0000, "pathfind / cluster==0");
        free(entry);
    } else {
        fail_test("pathfind /");
    }
}

// ---- Main ----

void main() {
    // Reset to root directory: pathfind tests use relative paths from root
    drive_0_fs_handle.current_dir_cluster = 0;
    test_dirwalk();
    test_dir_find();
    test_readfile();
    test_pathfind();

    uint16_t passed = total - fail;
    if (fail == 0) {
        printf("cctest5: %U/%U PASS\n", total, total);
    } else {
        printf("cctest5: %U/%U FAIL\n", passed, total);
    }
    exec_chain("/CCTEST/CCTEST6.ODY");
}
