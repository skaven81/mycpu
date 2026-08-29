// Wire Wrap Odyssey -- term: inspect and twiddle $term_flags
//
// $term_flags is the unified terminal control byte (see
// TERMINAL_REFACTOR.md 2.2.1). 0x00 is the default fast path: ctrl chars
// on, ANSI off, right-edge wrap+newline, bottom-edge scroll. This command
// lets the shell user read the current value, set it directly as a raw
// hex/decimal byte, or toggle a single named bit on/off.
//
// Deliberately does NOT wrap its own output in ANSI mode the way
// cmd_memstat/cmd_hexdump do -- this command's whole job is leaving
// $term_flags in whatever state the user asked for, so bracketing its
// output with a temporary ANSI-on/off would stomp on that result.

#include "types.h"
#include "terminal_output.h"
#include "shell_argv.h"
#include "string.h"
#include "strtoi.h"

extern uint8_t term_flags;

static void print_usage(void);
static void print_flags(void);
static void print_bit(uint8_t f, uint8_t mask, char *desc);

void cmd_term(void) {
    char *arg1;
    char *arg2;
    uint8_t mask;
    uint8_t flags;
    int16_t val;

    arg1 = shell_get_argv_n(1);
    if (arg1 == 0) {
        print_flags();
        return;
    }

    arg2 = shell_get_argv_n(2);
    if (arg2 == 0) {
        // One-argument form: "term <hex>" sets the raw byte directly.
        val = strtoi(arg1, &flags);
        if (flags) {
            print_usage();
            return;
        }
        term_flags = (uint8_t)val;
        print_flags();
        return;
    }

    // Two-argument form: "term <name> on|off" toggles a single named bit.
    mask = 0;
    if (!strcasecmp(arg1, "raw")) {
        mask = 0x01;
    } else if (!strcasecmp(arg1, "ansi")) {
        mask = 0x02;
    } else if (!strcasecmp(arg1, "nowrap")) {
        mask = 0x04;
    } else if (!strcasecmp(arg1, "nonl")) {
        mask = 0x08;
    } else if (!strcasecmp(arg1, "noscroll")) {
        mask = 0x10;
    } else if (!strcasecmp(arg1, "wraptop")) {
        mask = 0x20;
    } else {
        print_usage();
        return;
    }

    if (!strcasecmp(arg2, "on")) {
        term_flags = term_flags | mask;
    } else if (!strcasecmp(arg2, "off")) {
        term_flags = term_flags & ~mask;
    } else {
        print_usage();
        return;
    }

    print_flags();
}

static void print_flags(void) {
    uint8_t f;
    f = term_flags;
    printf("term_flags = 0x%x\n", f);
    print_bit(f, 0x01, "raw      print ctrl chars (no BS/DEL/CR/LF handling)");
    print_bit(f, 0x02, "ansi     ESC starts the CSI escape-sequence parser");
    print_bit(f, 0x04, "nowrap   right edge: stay at col 63 instead of wrapping");
    print_bit(f, 0x08, "nonl     right edge: don't advance to the next row");
    print_bit(f, 0x10, "noscroll bottom edge: don't scroll, overwrite in place");
    print_bit(f, 0x20, "wraptop  bottom edge (with noscroll): wrap to row 0");
}

static void print_bit(uint8_t f, uint8_t mask, char *desc) {
    uint8_t bit;
    bit = 0;
    if (f & mask) {
        bit = 1;
    }
    printf(" [%u] %s\n", bit, desc);
}

static void print_usage(void) {
    print("Usage: term                  show current $term_flags\n");
    print("       term <hex>            set $term_flags directly, e.g. term 0x02\n");
    print("       term <name> on|off    toggle one flag bit\n");
    print("       names: raw ansi nowrap nonl noscroll wraptop\n");
}
