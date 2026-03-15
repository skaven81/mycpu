# odyssey_video -- Odyssey Video Frame Generator

Converts images, GIFs, and video files into frame files for playback on the
Wire Wrap Odyssey computer. Supports two output modes:

- **ASCII mode** (`--ascii`): character-art frames read by `ASCIIVID.ODY`
- **Color mode** (`--color`): color-palette frames (future `COLORVID.ODY`)

## Quick Start

```
# Direct execution (uv auto-installs Python deps on first run):
./odyssey_video.py --ascii --output-dir /mnt/sd/FRAMES/NYANCAT /tmp/nyancat.gif
./odyssey_video.py --color --output-dir /mnt/sd/FRAMES/NYANCAT /tmp/nyancat.gif

# Run tests:
uv run --extra dev pytest tests/ -v
```

`ascii-image-converter` (Go binary) must be installed and on PATH for `--ascii` mode.
Download from: https://github.com/TheZoraiz/ascii-image-converter/releases

## CLI Reference

```
./odyssey_video.py {--ascii|--color|--block} [OPTIONS] input [input ...]

Mode (exactly one required):
  --ascii       Generate .TXT frames via ascii-image-converter
  --color       Generate .COL frames via Odyssey 64-color quantization
  --block       NOT YET IMPLEMENTED (half-block chars for 2x resolution)

Options:
  --output-dir DIR    Where to write frame files (default: current directory)
  --output-fps N      Target frame rate (default: 14)
  --input-fps N       Source frame rate for image sequences/directories (default: 30)
  --height H          Override output height in character cells (must be even,
                      64*H must be divisible by 128; default: auto from aspect ratio)

Input types (auto-detected):
  Single .gif file         GIF frame timing used; --input-fps ignored
  Single video file        Embedded fps used; --input-fps ignored
  Single directory         Sorted image files treated as sequence at --input-fps
  One or more image files  Treated as sequence at --input-fps
```

Output files are named `XXXX.TXT` or `XXXX.COL` (zero-padded uppercase hex,
e.g. `0000.TXT`, `0001.TXT`, ...). The directory is passed directly to `ASCIIVID`.

## Frame Format Specification

This section explains WHY the output format is what it is, grounded in how
`ASCIIVID.ODY` (`os/util/asciivid/`) actually reads and plays back frames.

### File Naming

Files are named `<4-hex-digits>.<ext>` (e.g. `0000.TXT`, `000A.TXT`).
`asciivid` reads the basename as a hex integer to get the frame index, then
looks up the FAT16 starting cluster from a pre-built array. Files out of order
on disk are fine; they are index-sorted in memory.

### Frame Size and Alignment

**All frames in a playback session must be exactly the same size.**

The ISR reads `frame_segments` from a global variable that is set once from
frame 0's file size:

```c
frame_segments = (uint8_t)(frames_dirent->file_size.lo >> 7) - 1;
```

The ISR then copies `(frame_segments + 1) * 128` bytes per frame tick. If any
frame is a different size, the copy will either be truncated or read garbage
from the next frame's extended memory page.

Frame size must therefore be:
- A multiple of 128 bytes
- Equal for every frame in the session
- At most 4096 bytes (the ISR reads up to 8 sectors of 512 bytes = 4096 bytes,
  and extended memory pages are 4 KiB)

The display is 64 cols x 60 rows = 3840 bytes (fits in one 4 KiB page with
room to spare). Smaller heights are fine: e.g. 64x48 = 3072 bytes for 4:3 source.

### ASCII Frame Layout

Each byte is a CP437 character code that maps directly to a framebuffer cell
at 0x4000-0x4EFF. The ISR does a raw `memcpy_segments` from the extended memory
page to 0x4000, so byte N in the frame file lands at display address
`0x4000 + N`. Row-major order, 64 bytes per row, starting at top-left.

`ascii-image-converter` outputs one row per line. The tool strips all `\n`
characters and encodes the result as raw ASCII bytes. If the output is shorter
than `width * height` (can happen with unusual inputs), it is right-padded with
spaces. If longer (e.g. tool emits extra header/footer lines), it is truncated.
The result is then padded to the next multiple of 128 if needed.

### Color Frame Layout

Each byte is an Odyssey color code in the format `[R1:R0][G1:G0][B1:B0]`
(2 bits per channel, 6 bits total, 64 colors). The ISR copies these bytes to
the color framebuffer at 0x5000-0x5EFF. Byte N lands at `0x5000 + N`, giving
one color per character cell.

Color quantization: `round(channel / 85)` per channel, clamped to [0,3].
This maps 256 levels to 4 levels at boundaries: 0-42 -> 0, 43-127 -> 1,
128-212 -> 2, 213-255 -> 3.

## Height Auto-Detection

Height is computed once from the first frame's pixel dimensions and then fixed
for the entire session. Formula (`common.py:compute_frame_height`):

```python
h = round(src_h * 64 / src_w)   # proportional scale to 64-wide
if h % 2 != 0: h += 1           # round up to even (ensures 64*h % 128 == 0)
h = max(2, min(h, 60))          # clamp to valid range
```

Examples:
- 480x360 (4:3): h = round(360*64/480) = 48 -> 3072 bytes/frame
- 640x360 (16:9): h = round(360*64/640) = 36 -> 2304 bytes/frame
- 258x249 (nyan cat, ~1:1): h = round(249*64/258) = 62 -> clamped to 60 -> 3840 bytes/frame

Note for ASCII mode: terminal character cells are typically ~2x taller than
wide, so ASCII art of a square image will appear vertically stretched. This
is handled by `ascii-image-converter` internally when it computes character
density; the tool is given the target character dimensions and adjusts its
sampling accordingly.

## Module Overview

```
odyssey_video/
  odyssey_video.py     CLI entry point (uv PEP 723 inline deps, directly executable)
  common.py            Constants (DISPLAY_W=64, DISPLAY_H=60, FRAME_ALIGN=128)
                       compute_frame_height(), pad_frame()
  palette.py           64-color palette table, rgb_to_odyssey(), odyssey_to_rgb()
  ascii_converter.py   image_to_ascii_frame(): shells out to ascii-image-converter
  color_converter.py   image_to_color_frame(): numpy quantization pipeline
  frame_extractor.py   extract_frames(): yields PIL Images at target FPS from any input
  pyproject.toml       Python deps + pytest config (uv run --extra dev pytest)
  tests/
    conftest.py        sys.path setup so tests import from parent dir
    test_palette.py
    test_ascii_converter.py
    test_color_converter.py
    test_frame_extractor.py
    test_integration.py
```

## Known Issues and Potential Bug Areas

### ascii-image-converter output variability

`ascii-image-converter` v1.13.1 flags:
- `--no-color`, `--braille=false`, `--only-braille=false` **do not exist** -- plain
  ASCII output is the default; those flags must NOT be passed or the tool exits 1.
- `--dimensions W,H` sets exact character dimensions.
- Color output is enabled with `-C`/`--color` (not used here).

If a future version of the tool changes its CLI, `ascii_converter.py:image_to_ascii_frame`
will get a `RuntimeError` from the `CalledProcessError` handler. The fix is to
update the argument list in that function.

The tool may also prepend/append decorative lines or emit extra whitespace in
some output modes. `ascii_converter.py` defensively truncates or pads to the
expected `width * height` byte count.

### GIF frame timing

GIF frames each carry a `duration` field in milliseconds (stored in
`img.info["duration"]`). Some GIFs omit this field; it defaults to 100ms (10fps)
in `frame_extractor.py:_frames_from_gif`. If a GIF looks wrong speed-wise, check
whether the GIF's per-frame durations are uniform or variable.

For a looping GIF, `_frames_from_gif` plays exactly one loop (it stops when
`t_out >= total_duration`). To get multiple loops, pass `--output-fps` lower
than the GIF's natural frame rate, or loop the GIF externally before converting.

### Video fps detection

For video files, the extractor tries `imageio.v3` first and falls back to `imageio`
v2 API. The FPS is read from the file's metadata. If the embedded FPS is missing
or wrong (common with poorly-encoded files), pass `--input-fps` to override.

### Image sequence ordering

When given a directory or multiple image files, frames are sorted by filename
(alphabetically). For sequences numbered without zero-padding (e.g. `frame1.png`,
`frame10.png`, `frame2.png`), the sort order will be wrong (lexicographic, not
numeric). Ensure source images use zero-padded names (e.g. `frame_0001.png`).

### Frame count limit

`asciivid` hard-codes `MAX_FRAMES = 2048`. Generating more than 2048 frames
will silently truncate playback (the extra frames are never indexed). At 14fps
that is about 2.4 minutes of content.

### Extended memory ring buffer size

`asciivid` reserves extended memory pages 0x06 through 0xFF (250 pages, one
frame per page). At 3840 bytes/frame, each page comfortably holds one frame
(4 KiB pages). At 4096 bytes/frame (64x64, maximum), this is exactly one page.
Frames larger than 4096 bytes are impossible -- that would exceed the extended
memory window size and overflow into the next page.

### Color mode: character cells vs pixels

In color mode, each output byte colors one **character cell** (8x8 pixels on the
display). The player only sets color bytes (0x5000 region); it does not write any
character data (0x4000 region). Whatever characters are already on screen will be
colorized. In practice, running color playback without first clearing the screen
to a known character (e.g. space 0x20 or block 0xDB) will show garbled content.
The colorvid player (not yet written) will need to either fill the character
framebuffer with solid block chars, or combine the color stream with a companion
character stream.

### Padding character for ASCII frames

When a frame is shorter than `width * height` (e.g. the converter emitted fewer
characters than expected), it is padded with ASCII space (0x20). When a frame
total is not a multiple of 128, `pad_frame()` in `common.py` also pads with
space bytes. This is intentional: space is invisible on the display and is
preferable to any other fill character.

## Future Work

### --block mode (CP437 half-block characters)

Half-block characters (U+2580 family, CP437 codes 0xDC/0xDF/0xDB/0xDD/0xDE/0x20)
give 2x effective vertical resolution: a 64x60 character grid becomes a 64x120
pixel grid. Implementation would:

1. Scale source to 64 wide, height*2 tall
2. For each pair of pixel rows, compute top and bottom cell colors
3. Map (top_color, bottom_color) to a CP437 half-block char + foreground/background color byte
4. Output two streams: one .TXT (character codes) and one .COL (color bytes)

The player ISR would need to copy both streams simultaneously.
This is left as `NotImplementedError` in the CLI with a placeholder `--block` flag.

### colorvid player

`COLORVID.ODY` does not yet exist. It will be essentially the same as `ASCIIVID.ODY`
but copying frames to 0x5000 (color memory) instead of 0x4000 (character memory),
and pre-filling character memory with solid block chars (0xDB) so the color stream
is visible. Frame files would use the `.COL` extension.
