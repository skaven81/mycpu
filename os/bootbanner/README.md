# bootbanner

`PRISMBAN.ODY` -- the "Wire Wrap" Odyssey boot banner (WIRE WRAP heading in
cyan half-blocks with magenta `░▒▓█` chrome wedges, ODYSSEY in ROYGBIV
half-blocks, on black). It is assembled to fit the **448-byte bootstrap-code
area of a FAT16 boot sector** and lives in sector 0 of the SD card rather
than as a `SYS/` command.

## Boot hook contract

At boot the BIOS loads LBA 0 and inspects the first three bytes of the
bootstrap-code area (offset `0x03E`). If they are the ASCII magic `ODY`, the
BIOS relocates the ODY image into RAM and `CALL`s it, then continues the
boot sequence. The BIOS-side implementation is
**`os/bios/01-boot_banner.asm`** (`:boot_banner`), called once from
`os/bios/00-main.asm`; see "BIOS loader implementation" below. The split of
responsibilities:

* **Caller, before:** the screen is already cleared when the banner is
  entered (the BIOS does this at `os/bios/00-main.asm` regardless).
* **Banner:** paints the framebuffer only -- glyph plane `0x4000`, colour
  plane `0x5000` -- then `RET`s. Nothing is passed in or out; no heap, no
  args, no exit code. Registers are trashed freely.
* **Caller, after:** cursor positioning / re-init.

It must never hang or `HLT` -- there is no software reset.

### Self-contained -- no BIOS coupling

`prismban.asm` makes **no `CALL`/`JMP` outside its own code** and references
**no BIOS symbols** -- `memfill`/`memcpy` are inlined as the local
`.fill`/`.copy` helpers, and there is no cursor call, no heap use. It
assembles with no symbol table (`asmcheck.sh --no-symbols`), so a BIOS
rebuild that shifts `bios.sym` does **not** invalidate the installed banner.
It only needs rebuilding + reinstalling when the art (`gen.py`) changes.
`make check` still compares against a freshly built `PRISMBAN.ODY` and
catches that case.

## BIOS loader implementation

The loader lives in **`os/bios/01-boot_banner.asm`** (numbered files in
`os/bios/` are concatenated in sorted order; `00-main.asm` is the entry
file). It is *not* the normal BIOS program-exec path -- it is a plain
`CALL_D` into the relocated image with no argv/argc, no heap frame, no exit
code. What `:boot_banner` does, in order:

1. `:extmalloc` one extended-RAM page for a 512-byte load buffer and
   `:extpage_e_push` it into the `0xE000` window (saving the caller's E
   page). **Do not go back to hardcoding page `0xff`:** by the time this
   runs, `00-main.asm` has already taken the first `:extmalloc` page for the
   command-history ring, and `:extmalloc` hands pages out from the high end,
   so `0xff` is live allocated memory.
2. Poison the magic byte at `0xE03E` (`ST 0xe03e 0x00`) *before* the read.
   **Load-bearing:** extended RAM is not cleared by a CPU reset, so on a
   warm boot the page can still hold the previous boot's banner image
   *already relocated*. Relocation is not idempotent and the `ODY` magic is
   never rewritten, so a stale image would pass the magic check and get
   relocated a second time -- every internal address ends up ~`0xE068` too
   high, landing inside peripheral space, and `CALL_D` into that crashes the
   machine. Clearing the `O` first guarantees the checks below only ever see
   bytes this boot's ATA read actually delivered.
3. `:ata_read_lba` -- read LBA 0 of drive 0 into `0xE000` (whole 512-byte
   sector). Any non-zero status -> release the page and `RET` silently.
4. `:fat16_inspect_ody` at `0xE000+0x3E`. `0xff` (not an ODY) -> release and
   `RET`.
5. `:fat16_localize_ody` at `0xE000+0x3E` -- relocates the image **in place**
   and leaves the entry-point word on the heap. See "ODY relocation" below.
6. `:clear_screen`, cursor forced off, `CALL_D` the entry point. The banner
   paints framebuffer rows 0..11 and `RET`s.
7. Park the cursor at row 12, col 0 so the rest of the boot log scrolls out
   below the banner.
8. `.bbnr_release`: `:extpage_e_pop` (restore the caller's E page; ours goes
   back on the heap) + `:extfree`. Reached on every path that got as far as
   step 1.

**Placement / dependency.** `:boot_banner` must be called *after*
`:boot_malloc_init` in `00-main.asm` -- that is what runs `:extmalloc_init`
(sets up the ledger and `$extpage_e_ptr` that step 1 needs). It does **not**
need `:boot_mount_drives` (it reads a raw LBA, not a file) and does not need
`:boot_ata_init` (that only prints presence banners; the ATA port is reset
by the same `/RST` line as the CPU, so the controller looks identical on a
cold or warm boot). Everything printed to the screen before the banner runs
is wiped by the banner's own `:clear_screen`, so the "Odyssey OS v1.0"
version line and anything that must survive onto the finished screen are
printed *after* the `CALL :boot_banner`.

**Everything is best-effort and silent on failure.** Extended memory full,
drive absent, ATA error, no `ODY` magic -> the page is released and the
normal boot sequence proceeds with no banner and no message.

### ODY relocation (what constrains the banner binary)

`PRISMBAN.ODY` is a standard ODY image (see `os/README-bios-exec.md` and
`assembler.py`'s ODY writer):

| Bytes | Meaning |
| --- | --- |
| `0..2` | magic `ODY` (never rewritten by relocation) |
| `3` | flags (memory target; `0x00` = main) |
| `4..5` | relocation-entry count, **big-endian** |
| `6 .. 6+2N-1` | N x 16-bit relocation offsets (file-relative, i.e. they include the header) |
| `6+2N ..` | raw machine code |

For the current banner: count = `0x0012` = **18**, so the header is
`6 + 18*2` = **42 bytes** (`0x2A`) and the code is `426 - 42` = **384
bytes**. `:fat16_localize_ody` computes
`first_byte_of_program = base + 6 + 2*N` and adds it to each reloc slot in
place. Loaded at `base = 0xE03E`, `first_byte_of_program = 0xE068`; the
relocated image occupies `0xE03E .. 0xE1E7`, comfortably inside the
512-byte sector read to `0xE000`.

Consequences for anyone regenerating the art:

* **Relocation is not idempotent** -- hence the poison store (step 2). Never
  relocate an image twice.
* **The banner must stay self-contained.** `prismban.asm` assembles with no
  symbol table (`--no-symbols`); it references no BIOS symbol and makes no
  `CALL`/`JMP` outside its own body. A larger banner with more internal
  label references just means a larger reloc table (bigger header) -- fine
  as long as the total still fits 448 bytes and the loaded image still fits
  the sector.
* **No BIOS-exec niceties.** The loader `CALL_D`s the entry directly, so the
  banner must not call `:argv_init`, must not push an exit code, and must
  end in a bare `RET`. It must never hang or `HLT` -- there is no software
  reset.

## Replacing or editing the banner art

The generator `gen.py` is the source of truth; `prismban.asm` is generated
and carries a "do not hand-edit" header. Workflow:

1. Edit `gen.py` (see "How gen.py works" below).
2. `make gen` (== `python3 gen.py`) -> regenerates `prismban.asm` and, as a
   side effect, the design-exploration debris (`*.ans`, `*.chr`, `*.clr`,
   `banners.h`, `preview-all.ans` -- all `.gitignore`d; `cat *.ans` for a
   truecolor terminal preview).
3. `make` -> assembles `PRISMBAN.ODY`; **fails if it exceeds 448 bytes**.
   Keep it self-contained (no BIOS symbols) so the `--no-symbols` assemble
   still works and a BIOS reflash never invalidates the installed banner.
4. `sudo make install SDCARD_DEV=/dev/sdX` on an unmounted card (see below).
5. `make check` to confirm the card now carries the freshly built image.

A pure art change touches **only** the SD card boot sector -- no BIOS
rebuild, no EEPROM reflash. You only touch `os/bios/` if you are changing
the *loader* contract (where/how the image is read, relocated, or called),
and every `os/bios/` edit shifts `bios.sym` and invalidates every flashed
`.ODY` until the EEPROM is physically reflashed and the SD card re-burned.

### How gen.py works

`gen.py` started life as a mockup tool for four candidate designs -- the
`DIRS` list: `prism`, `chrome`, `phosphor`, `nameplate`. Each `build()`
returns a `rows` grid of `(glyph, rgb)` cells on a 64-column canvas.
**Only `prism()` feeds the boot sector.** The other three are dead
design exploration kept for reference; they emit `.ans`/`.chr`/`.clr`
previews and nothing else. If you want a different look, either restyle
`prism()` or point the `if name == "prism"` block at another builder.

The ODY is built by `emit_asm(rows)` from the `prism` grid, and it is only
*partly* generated:

* **`ASM_BODY` is a hand-written assembly string constant** -- the whole
  painting routine (`.fill` / `.copy` / `.cell` helpers, the four colour
  `.fill` runs, the `.cbld` ROYGBIV-band loop, the glyph unpack loop, the
  wedge overlay). `emit_asm` does **not** synthesize this from the art. If
  you change the art's *geometry* -- row count, the band's start column,
  the wedge columns, the number/width of the colour runs -- you must edit
  `ASM_BODY` by hand to match.
* **Only four data tables are computed from `rows`** and appended after
  `ASM_BODY`:
  * `.glut` (4 B) -- 2-bit code -> CP437 glyph, fixed (`0x20 0xdc 0xdf 0xdb`).
  * `.wpat` (6 B) -- heading wedge shade run, fixed (`b0 b1 b2 b2 b1 b0`).
  * `.roys` (7 B) -- the seven ODYSSEY per-letter colour bytes, read out of
    the grid. **Recolouring the letters is data-driven** -- edit the
    `PRISM` palette and it flows straight through here.
  * `.gmap` (192 B) -- 12 fb rows x 16 bytes, 4 cells per byte, 2 bits per
    cell = `.glut` index. This is the entire glyph plane; edit the fonts
    (`FONT2`, `WW_FONT`) and it regenerates.
* **The heading colours (`0x33` magenta / `0x3f` white / `0x0f` cyan) are
  NOT data-driven** -- they are hardcoded both as `LDI_AH` immediates in
  `ASM_BODY` and in `emit_asm`'s assertions. Change one, change all three.

`emit_asm` is guarded by `assert`s that re-derive the colour model from the
grid and fail the build if the art violates what `ASM_BODY` assumes:
heading rows 0-2 magenta at the wedge ends / white row 0 / cyan rows 1-2;
fb rows 3 and 11 all spaces; the colour band = cols 0-4 clear, then seven
7-wide single-colour runs each followed by one clear gap column (starting
at col 5, i.e. `0x5105` in the `.cbld` loop's `LDI_C`), then clear to the
edge; exactly 12 fb rows. A failing assert means `ASM_BODY` and the art
have drifted apart -- fix whichever is wrong, they must agree.

## Debugging notes / known hazards

History worth not re-discovering:

* **Cold-boot works, warm reset skips the banner** was the headline symptom
  during bring-up. Two independent causes were entangled:
  * The stale twice-relocated warm-boot image described above (fixed by the
    poison store).
  * A **pre-existing BIOS bug in `os/bios/50-uart_init.asm`** -- it did
    `LDI_AH 0x50` / `CALL :heap_push_AL`, pushing whatever `:print` left in
    `AL` instead of the intended BCD `0x50` as the `:sleep` duration.
    `:sleep`'s `.sleep_wait` spinlock is unbounded, so a non-BCD duration
    hangs the machine forever. This had *always* been latent; the banner
    only exposed it by moving `$crsr_row` to 12, which changed the
    `:print`/scroll path and thus the garbage value left in `AL` at that
    line. Fixed in `fcfcd96` (`:heap_push_AL` -> `:heap_push_AH`). If a
    future banner change resurrects a "hangs right after some boot line"
    symptom, suspect a similar leftover-register bug in the BIOS routine
    *printed just before the hang*, not the banner.
* **Unbounded loops still lurking** (not banner bugs, but they turn a bad
  value into a hang instead of an error): `:sleep`'s `.sleep_wait`, and
  `ata.asm`'s `.ata_wait_data_request_ready` (checks `ERR` only *after* the
  wait).
* The banner never corrupts memory or touches the heap balance -- it only
  repaints the framebuffer. If SYSTEM.ODY later fails to load, the banner is
  almost certainly not the cause; check the loader's page bookkeeping
  (`:extpage_e_pop` / `:extfree` balance) and whatever runs between it and
  `:boot_system_ody`.

## FAT16 boot sector layout

Offsets per <http://www.maverick-os.dk/FileSystemFormats/FAT16_FileSystem.html>,
cross-checked against `os/bios/lib/fat16_mount.asm`:

| Offset | Size | Field |
| --- | --- | --- |
| `0x000` | 3 | jump instruction |
| `0x003` | 8 | OEM name |
| `0x00B` | 25 | BIOS Parameter Block |
| `0x024` | 18 | extended BPB (drive#, `0x29` sig, volume ID, label) |
| `0x036` | 8 | filesystem type `"FAT16   "` -- **BIOS checks this** |
| `0x03E` | **448** | **bootstrap code area -- the ODY goes here** |
| `0x1FE` | 2 | `0x55 0xAA` signature -- **BIOS checks this** |

`make install` rewrites only the 448-byte window at `0x03E`. The BPB and the
signature are left byte-for-byte intact, so the filesystem stays mountable.

## Targets

Installing the banner is rare -- only when the art (`gen.py`) changes. The
banner is self-contained, so BIOS rebuilds never require a reinstall. Day to
day you only touch Phase 1.

### Phase 1 -- unprivileged (build + check)

| Target | Effect |
| --- | --- |
| `make` | assemble `prismban.asm` -> `PRISMBAN.ODY`; fails if it exceeds 448 bytes |
| `make gen` | regenerate `prismban.asm` from `gen.py` (the source of truth) |
| `make check` | read LBA 0 of the card (plain `dd`, no `sudo`) and report whether its boot-code area matches the freshly built `PRISMBAN.ODY` |

`make check` exits `0` only when the installed banner is byte-identical to
the freshly built `PRISMBAN.ODY`; any other outcome -- stale, not installed,
device unknown, or unreadable without privileges -- is a non-zero exit with
a message saying which. (Mounting the card usually grants your desktop
session enough access to read LBA 0; otherwise `sudo make check`.)

### Phase 2 -- root only (rewrites the raw boot sector)

| Target | Effect |
| --- | --- |
| `sudo make install` | splice `PRISMBAN.ODY` into the boot-code area of the card |
| `sudo make format` | `mkfs.fat` a fresh unpartitioned FAT16 onto the card, then install (**erases the card**) |

Run as a normal user, `install` and `format` fail immediately with a message
telling you to re-run under `sudo` -- they never touch the device.

## SD card device

The card is assumed **unpartitioned** -- the FAT16 filesystem is written
straight to the disk, so LBA 0 of the whole device is the boot sector. Pass
the device explicitly; for `install`/`format` unmount it first:

```
make check              SDCARD_DEV=/dev/sdX
sudo make install       SDCARD_DEV=/dev/sdX
```

If `SDCARD_DEV` is omitted it is resolved from the mount of
`INSTALL_DIRECTORY` (`os/config.mk`), which only works while the card is
still mounted (fine for `check`). `make install` refuses to write unless
LBA 0 already holds a FAT16 boot sector (signature + type string), prompts
once (skip with `FORCE=1`), and reads the window back to verify.

There is no `mkfs`/`mtools` utility that injects boot code into an existing
FAT16 without reformatting (and `mtools` is not installed here), so the
splice is a single targeted `dd conv=notrunc` of just the 448-byte window --
never a full-sector raw write. `make format` is the `mkfs` path, for
bringing up a blank card.
