# Odyssey TODO

Work queued up for the Wire Wrap Odyssey, roughly in priority order. Distilled
from the `journal`; update both when priorities shift.

---

## Active — top of the stack

### Tetris

Finally build a working Tetris. All the prerequisites are now in place: color
video, the programmable timer interrupt, keyboard input, and the recently added
piezo speaker + tone-generation circuitry. This is the thing to work on next;
the boot banner and other recent diversions were getting in the way of it.

---

## Small TODOs (important — do not let these rot)

These are narrow, well-understood fixes/changes. They're cheap and they matter.

### `strsplit` argument overflow detection

The command line is tokenized into a fixed 32-element array (31 args + NULL
terminator). There is currently **no overflow check** — typing a command with
more than 31 arguments will walk off the end of the array. Add a bounds check
that stops tokenizing (and ideally reports an error) at the array limit.
Reference: `journal` entry 2026-02-24, `os/system/40-parse_command.asm`.

### RTC timer interrupt should be off unless in use

Audit the peripheral support routines so the RTC timer interrupt is **disabled
under normal conditions** and only enabled while something actually needs it.
Right now it's left armed when it doesn't need to be. Reference: `journal`
2025-02 VCF laundry list.

### Default the console to 115200 baud

Now that hardware flow control actually works (fixed 2026-07-25), the baud rate
no longer has to be held down to avoid buffer overruns. Switch the default
console baud from 9600 to 115200. Verify a full `serrun` transfer and a text
file transfer through `console` still run clean at the higher rate.

---

## Secondary LCD status display

Add a small secondary LCD dedicated to live system stats, independent of
whatever is running on the main display.

Motivation: the `memstat` command is not very useful because it can only ever
run while `SYSTEM.ODY` is resident — exactly the state where memory pressure is
*lowest* and least interesting. A dedicated status panel sidesteps that.

Wanted on the panel:
  * Memory utilization (main RAM + extended-memory pages)
  * Current date / time
  * Currently executing ODY (name / entry)

Implementation sketch: there is now enough programmable-timer capacity to run a
dedicated system-timer tick on roughly a 500 ms loop that refreshes the LCD in
near-real-time, without disturbing the running program.

Bonus payoff: the same LCD would be invaluable as a tracing / diagnostics
surface when debugging programs — a place to dump state that doesn't fight the
program for the main display.

---

## Dynamic library loading with trampoline tables

Keep ODY executables small by storing most library code in extended memory
instead of baking a copy into every binary.

Design: a trampoline table at a well-known fixed location in main memory
provides stable entry points. Each slot is a small stub that pages in the
correct extended-memory window and jumps to the real function. ODYs call
library routines through the table, so their own footprint stays small and the
bulk of main RAM stays free for data. Reference: `journal` 2026-02-18 roadmap
("Longer term").

---

## Shell polish

The 2026-08-23 terminal refactor delivered the ANSI + readline substrate, so
in-line editing and command history (up/down recall) work today. Still
outstanding:

  * Tab completion (commands and/or filenames)
  * Environment variables, especially `$PATH` — a real search path for command
    resolution instead of the current hardcoded lookup
  * Cache the directory contents of each `$PATH` entry so command resolution
    doesn't re-walk the filesystem on every invocation
  * Fix the pathological case where `$PATH` contains `.` and the current
    directory has hundreds of files: today the shell sits for tens of seconds
    scanning `.` before it falls through to `/SYS`. Needs an indexing or
    early-out strategy so a `.` entry in a large directory is cheap.

---

## FAT16 writes

FAT16 support is currently **read-only**. Implement the write path: allocating
clusters, updating the FAT and directory entries, extending/truncating files,
and flushing. This is a prerequisite for any Odyssey software that needs to
save data to disk.

Good first target: a `COPY` command, to shake out and prove the full
file-creation library path end to end. If feeling ambitious, follow with an
`XCOPY`-style recursive/multi-file variant.

---

## Hardware math co-processor

Not needed today — nothing currently requires large multiplies/divides or
trig functions (sin/tan/etc). But when that need does arrive, the right answer
is a dedicated math co-processor rather than doing it in software: an ATtiny
with some shift registers hung off it for I/O, in the same style as the
keyboard controller. Logged here so the design direction is settled in advance.

---

## FM sound (dialed back)

A proper FM sound-playback capability would be nice down the road, but a full
OPL-3 (YMF262) implementation is realistically **off the table** — too much
integration work. The more likely target is something AdLib-like: all the sound
processing offloaded to the chip, with the Odyssey just writing a few registers
and walking away. Community formats like VGM (raw FM register dumps) would make
playback straightforward if this ever gets built.

---

## Non-code

  * Update the website with the latest changes — new photos showing the ATA
    port, and a video showing the current functionality in action.
