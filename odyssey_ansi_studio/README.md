# Odyssey ANSI Studio

A Linux desktop app for designing rich TUIs and ANSI art for the **Wire Wrap
Odyssey** computer.

It is a **layer-based** editor: every box, text window, or imported image is its
own layer with a sparse cell grid and an `(x, y)` offset. Layers never interact;
they compose top-down -- the topmost layer with a non-NULL glyph for a cell
supplies that cell's glyph **and** color. "Empty" is not the same as a space: an
empty cell is transparent, a painted space hides whatever is beneath it.

The cell model mirrors the hardware: a 64x60 grid, one CP437 glyph per cell
(character plane `0x4000`), one 6-bit RGB color byte per cell (color plane
`0x5000`, channel levels `0/85/170/255`, bit 7 blink, bit 6 cursor, no
background color). Designs are saved in a layer-preserving project format
(`.oas`) and *exported* to Odyssey-consumable formats.

## Running

```
uv run ./odyssey_ansi_studio.py            # launch the editor
uv run ./odyssey_ansi_studio.py --demo     # launch with a sample document
uv run ./odyssey_ansi_studio.py --install-desktop   # (re)write the XDG launcher + icons
```

`uv` resolves the dependencies (PySide6, Pillow, numpy, jeepney) from the
script's PEP 723 header on first run -- there is no venv or install step. The UI
uses the plain Qt platform theme and system icons; there is no custom styling.

On first launch the app writes a `.desktop` file and icon set into
`~/.local/share` so the task bar / dock shows its icon (Wayland shells ignore
`setWindowIcon`, and match the window to an installed launcher instead). Pass
`--no-desktop-integration` to skip that, or `--install-desktop` to force a
refresh after the repo moves.

## What it does

- **Canvas** -- renders the composited document with the real CP437 font ROM
  (16 swappable banks), opens at 2x with integer zoom, blink preview, rulers, a
  grid toggle, a cyan 64x60 boundary frame, red bars on any edge that has
  off-canvas layer content, and a transparency toggle that shows NULL cells as a
  gray checkerboard.
- **Paint tools** -- a left rail grouped by horizontal rules: *cells*
  (select, cell-edit, recolor, move-layer), *draw* (pencil, eraser, line,
  rectangle, ellipse, flood fill, gradient), and one-shot *new layer* buttons
  (box / text / image / blank). Every stroke is one undo step. A click-to-edit
  **cell inspector** tweaks a single cell's glyph and color.
- **Layer boundary + resize** -- with the select or move tool active, the
  active layer is outlined on the canvas with drag handles. Dragging a handle
  moves and resizes box / text / image layers in place (re-rasterizing) without
  opening the layer's dialog; blank layers show their painted extent and move
  only.
- **Screen eyedropper** -- the Ink panel's "Pick..." button samples any pixel
  on screen (this app or another window) using the desktop's native color
  picker (required on Wayland; an X11 fallback grabs a frozen screenshot). A
  split-screen dialog then opens **with the nearest Odyssey color already
  suggested**; switch between per-channel-RGB and OKLab matching or click the
  64-color grid to override by eye.
- **Ink picker** -- one widget: all 64 Odyssey colors, the 16 ANSI SGR colors,
  R/G/B + blink/cursor, and a named **project palette** saved in the document.
  It is the main window's Ink panel *and* the modal color picker every layer
  dialog's "Pick..." button opens.
- **Glyph picker** -- a 16x16 grid of the current bank, search by
  code/hex/name/character, a recents strip, and the 16-bank selector (switching
  banks re-renders; it never rewrites cell data).
- **Layers** -- add Blank / Box / Text / Image layers; Box and Text layers keep
  their parameters and are **re-editable at any time** (change the style, text,
  or size and the layer re-rasterizes; if you had hand-edited it with the
  drawing tools, it warns first). Duplicate, delete, reorder, merge-down,
  flatten, and group (hide/collapse). Each row has an eye and a padlock toggle.
  Box titles and footers can carry a one-glyph **flair** on each side.
- **Image import** -- interactive crop rectangle + scale to cells, `blocks` /
  `shades` / `halfblock` glyph mapping, per-channel or perceptual (OKLab) color
  match, posterize levels, and Floyd-Steinberg dithering. The source image is
  embedded in the `.oas` so the layer can be re-quantized later.
- **Save / export** -- `.oas` project files; exports to Odyssey-native
  `ESC[<v>p` `.ANS`, portable 16-color `.ANS`, raw split/interleaved binary, C
  header, ASM data, and PNG. Every text / binary export lets you choose how
  empty cells are stored (space / NULL / black block / transparent cursor-skip).

## Output formats

Every export starts from the same 64x60 **composite**: for each cell, the
topmost layer with a non-NULL glyph supplies that cell's glyph byte (CP437,
`char_plane`) and color byte (`color_plane`). A cell no layer touches is
NULL (glyph `0x00`). The color byte is:

```
bit 7   BLINK
bit 6   CURSOR   (editor-only; always masked to 0 on export)
bits 5:4  red index   0..3 -> intensity 0/85/170/255
bits 3:2  green index 0..3 -> intensity 0/85/170/255
bits 1:0  blue index  0..3 -> intensity 0/85/170/255
```

There is no background color -- a cell is always its glyph's foreground pixels
in that RGB color on black.

Every text/binary exporter takes a `null_mode` for how a NULL cell is
written: `"space"` (glyph `0x20`, attr `0x00`), `"null"` (glyph `0x00`, attr
`0x00`), `"block"` (glyph `0xDB`, a full block, attr `0x00`), or
`"transparent"` (Odyssey-native `.ANS` only -- the cell is skipped with a
cursor-forward move instead of being written, so whatever is already on
screen shows through).

### Odyssey-native `.ANS` (`export_ans`)

The format the Odyssey terminal itself replays. It is a flat byte stream, not
a container -- there is no header and no length field; parse it by executing
it as a tiny escape-code VM against a 64-wide, auto-wrapping cursor:

1. The stream opens with `ESC[H` (`\x1b[H`, cursor home) -- unless the
   document is empty and blank-trimmed, in which case that's the entire
   file.
2. Cells are then emitted in row-major order (row 0 first, left to right).
   For each cell, if its color-attr byte differs from the last one emitted,
   an `ESC[<v>p` escape is written first, where `<v>` is the **decimal**
   value 0-255 of the attr byte with bit 6 (cursor) masked out and bit 7
   (blink) kept -- e.g. `ESC[128p` sets blink+black, `ESC[42p` sets a color
   with blink off. This is an Odyssey-specific out-of-spec CSI escape, not
   standard ANSI SGR; it both sets the color-plane byte for subsequent
   glyphs *and* switches the terminal into color-rendering mode. `ESC[0p`
   selects black with blink off.
3. Immediately after the (possibly omitted) color escape, the cell's raw
   CP437 glyph byte is written -- one byte, no encoding, straight into the
   stream.
4. The terminal is exactly 64 columns wide and auto-wraps at column 64, so
   **rows need no separator for hardware playback** -- row N's last glyph is
   immediately followed by row N+1's first escape/glyph. The exporter can
   optionally insert a `row_separator` (the export dialog offers `\r\n`)
   after every emitted row, including the last, purely so the file also
   looks right when `cat`ed at a normal (non-64-col-locked) terminal; a
   parser must not assume rows are delimited.
5. By default (`trim_trailing_blanks=True`) the stream is cut after the last
   cell that is not a NULL and not a plain `(0x20, attr 0x00)` blank, and any
   wholly-blank rows after that are omitted entirely -- so a shorter file
   does not necessarily mean a shorter document; count colors/glyphs, don't
   assume 64x60 cells are present.
6. With `null_mode="transparent"`, NULL cells are never written. Instead
   each row begins with an absolute `ESC[<row+1>;1H` position (1-based), and
   runs of consecutive NULL cells within a row are skipped with a relative
   `ESC[<n>C` (cursor forward `n`) instead of `ESC[<v>p`+glyph pairs; the
   color escape is re-asserted after any such jump since the terminal's
   "last color" tracking cannot be assumed to persist across a positioning
   command.
7. CP437 codes below `0x20` and `0x7F` are valid glyphs on real VRAM but
   collide with this stream's own control characters (`ESC`, cursor moves);
   the exporter flags these cells as warnings but still emits them literally
   -- a strict parser will misinterpret them as control codes, matching real
   hardware behavior when the file is streamed to a live terminal.

### Portable 16-color `.ANS` (`export_ans16`)

Same composite and row-major traversal as above, but written in standard
SGR so any conventional ANSI-art viewer/terminal can render it (approximately
-- see the palette note below):

1. Opens with `ESC[H`.
2. Each cell's RGB color (from its 6-bit color code, ignoring blink/cursor)
   is snapped to whichever of the Odyssey's **16 named ANSI colors** is
   nearest by RGB distance (`nearest_ansi16`) -- a single nearest-neighbor
   lookup against a fixed 16-entry table, no dithering or per-channel remap.
   Those 16 reference colors are the same 6-bit color codes the Odyssey
   terminal's own SGR handling recognizes for `ESC[30-37m` (black, red,
   green, yellow, blue, magenta, cyan, white) and `ESC[90-97m` ("bright"
   versions of the same eight); which range a given cell snaps to depends
   purely on which of the 16 reference RGB values is closest, independent of
   that cell's own blink bit. The blink bit itself is carried separately
   (see below), not folded into the color snap.
3. Whenever a cell's resolved style (the snapped SGR code + blink flag)
   differs from the previous cell's, the stream emits `ESC[0m` (full reset)
   then `ESC[<sgr>m`, where `<sgr>` is one of `30-37` or `90-97` per the
   snap above. If the cell is blinking, `ESC[5m` follows immediately after
   the color SGR.
4. A NULL cell rendered as `null_mode="space"` (the default) needs no style
   at all if the running style is already "no style" (`ESC[0m` only, no
   color); the exporter tracks this so plain space runs don't repeat
   `ESC[0m` redundantly for every cell, but do not rely on run-length -- a
   spec-correct parser should apply each escape as it's seen, not assume any
   particular batching.
5. `row_separator` defaults to `\r\n` here (unlike the Odyssey-native
   exporter) since this format's whole purpose is to be viewed in ordinary
   terminals/tools that do not auto-wrap at exactly column 64.
6. `trim_trailing_blanks` and `null_mode` (including `"transparent"`, using
   the same absolute-position / cursor-forward scheme as the native
   exporter) behave identically to `export_ans`.

Because the snap is to only 16 colors, this format is lossy relative to the
Odyssey's native 64-color space -- do not round-trip through it expecting
exact colors back.

### Raw binary -- split-plane and interleaved (`export_binary`)

A fixed-size, headerless dump of the two VRAM planes -- exactly
`width * height` bytes each (3840 bytes for the standard 64x60 document; a
non-default document size changes this), with **no dimension recorded in the
file**. A parser must know (or be told out-of-band) `width`/`height` to
reshape the bytes back into a grid; offset within a plane is always
`row * width + col`.

* **`layout="split"`** (default) -- the entire char plane first
  (`width*height` bytes, one CP437 byte per cell, row-major), immediately
  followed by the entire color plane (`width*height` bytes, one attr byte per
  cell, same row-major order, cursor bit always masked to 0). Total file size
  `2 * width * height` bytes. This layout matches the Odyssey's real VRAM
  layout: char plane at `0x4000`, color plane at `0x5000`, so it can be
  `memcpy`'d straight into place on real hardware.
* **`layout="interleaved"`** -- the two planes are zipped byte-for-byte:
  `char[0], color[0], char[1], color[1], ...`, i.e. even byte offsets are
  glyphs, odd byte offsets are attrs. Same total size as split. Useful when a
  consumer wants one struct-of-2-bytes per cell rather than two parallel
  arrays.

`null_mode` here can only be `"null"` (glyph `0x00`), `"space"` (`0x20`), or
`"block"` (`0xDB`) -- `"transparent"` is accepted but collapses to `"null"`,
since a fixed-size plane format has no way to "omit" a cell.

#### Worked example -- standard 64x60 document

`width=64`, `height=60`, so each plane is `64*60 = 3840` bytes and every cell
offset within a plane is `row*64 + col` (0-indexed, row 0 / col 0 = top-left).
Total file size is `2 * 3840 = 7680` bytes for **both** layouts -- they
differ only in *where* a given cell's two bytes land, not in overall size.

**`layout="split"`** -- this is where "split" happens: the char plane
occupies the first `width*height` bytes (offsets `0` .. `width*height - 1`),
and the color plane starts immediately after, at absolute offset
`width*height` (`3840` for 64x60), running to `2*width*height - 1`. Put
another way, a cell's color byte is always exactly `width*height` bytes
*after* its char byte, and that fixed split point is the only thing a parser
needs to know beyond `width`/`height`:

| Screen location (col,row) | Char byte offset (`row*64+col`) | Color byte offset (`+3840`) |
|---|---|---|
| (0,0) -- top-left | `0` | `3840` |
| (63,0) -- end of row 0 | `63` | `3903` |
| (0,1) -- start of row 1 | `64` | `3904` |
| (32,30) -- roughly center | `1952` | `5792` |
| (63,59) -- bottom-right, last cell | `3839` | `7679` |

File size: **7680 bytes**, split point (char plane end / color plane start):
**offset 3840** (`= width*height`), file end: **offset 7679**.

**`layout="interleaved"`** -- there is no split point; each cell's two bytes
are adjacent, char first then color, so a cell's byte pair starts at
`2*(row*64+col)`:

| Screen location (col,row) | Char byte offset (`2*(row*64+col)`) | Color byte offset (`+1`) |
|---|---|---|
| (0,0) -- top-left | `0` | `1` |
| (63,0) -- end of row 0 | `126` | `127` |
| (0,1) -- start of row 1 | `128` | `129` |
| (32,30) -- roughly center | `3904` | `3905` |
| (63,59) -- bottom-right, last cell | `7678` | `7679` |

File size: **7680 bytes** (same total as split), file end: **offset 7679**.

For a non-default document size, substitute `width*height` for `3840` (the
plane size and split point) and `2*width*height` for `7680` (the total file
size) throughout.

### C header (`export_c_header`)

A generated, human-readable `.h` file, not a binary format -- parse it as C
source. For a document exported with `name="foo"` it defines:

```c
#define FOO_W      64          /* doc.width */
#define FOO_H      60          /* doc.height */
#define FOO_CELLS  3840         /* width * height */

static const unsigned char foo_chr[3840] = { 0x20, 0x20, ... };  /* char plane, row-major */
static const unsigned char foo_clr[3840] = { 0x00, 0x00, ... };  /* color plane, row-major */
```

`name` is sanitized to a valid C identifier (non-word characters become `_`,
a leading digit gets a `_` prefix) and upper-cased for the macros. An
`#ifndef`/`#define`/`#endif` include guard (`FOO_H`) wraps the file unless
`guard=False`. Byte values are `0x`-prefixed uppercase hex, one source line
per document row (`width` values per line) for readability -- line breaks in
the C array carry no semantic meaning, only the two arrays' element order
does. `mask_cursor` and `null_mode` behave as in `export_binary`.

### ASM data (`export_asm`)

A generated text file in this repo's assembler's data-literal syntax (not a
binary format). For `name="foo"`:

```
# Generated by Odyssey ANSI Studio.
# 64x60 cells, row-major (off = row*64 + col).
# Char plane loads at 0x4000, color plane at 0x5000.

:foo_chr 0x20 0x20 0x20 ...
:foo_clr 0x00 0x00 0x00 ...
```

Two label lines, each holding one plane as a single space-separated run of
`0xNN` byte literals in row-major order -- there is no line wrapping, the
whole plane is one logical line per label. `name` is sanitized to
`[0-9A-Za-z_]` (defaulting to `screen` if that leaves nothing). Lines
starting with `#` are assembler comments and carry no data. `mask_cursor` and
`null_mode` behave as in `export_binary`.

### PNG (`export_png`)

A real raster image, `width*8*scale` by `height*8*scale` pixels (each cell is
an 8x8 glyph from the active font bank). Rendering, per cell: skip entirely
(leave black) if the glyph is `0x00` (NULL); skip if `show_blink=False` and
the cell's blink bit is set (renders blink's "off" phase); otherwise decode
the glyph's 8 rows of 8 bits from the font bank (bit 7 = leftmost pixel) and
plot each set bit in the cell's RGB color (from the same 6-bit color code as
every other format, `LEVELS = [0, 85, 170, 255]` per channel) on a black
background -- there is no anti-aliasing or background fill beyond black.
`scale` (default 3 in the UI) does a final nearest-neighbor resize, so the
image stays crisp at any integer zoom; a consumer that wants 1:1 hardware
pixels should request `scale=1`.

## Design

The code splits into a **GUI-independent core** and a **thin Qt layer**:

```
studio/model/    cells, layers, document + compositing, undo history, rasterizers
studio/io/       CP437 tables, font ROM, .oas container, exporters
studio/convert/  image import / quantization
studio/tools/    paint-tool gestures -> undoable edits (no Qt imports)
studio/ui/       PySide6 widgets, dialogs, the main window
```

Everything under `model/`, `io/`, `convert/`, and `tools/` is
headless-importable and has no Qt dependency except `io/fontrom.py` (which uses
`QImage` for its glyph-tile cache). The Qt layer is just another caller of the
core; the same objects drive the headless tests.

The single source of truth for what renders is each layer's sparse
`dict[(col, row) -> Cell]`. Box / Text / Image layers additionally carry a
parameter dict and treat their cell grid as a regenerable cache -- see
`IMPLEMENTATION_DETAILS.md`.

## Making changes

Run the test suite (one file per module):

```
QT_QPA_PLATFORM=offscreen uv run --extra dev pytest tests/ -q
```

Quick smoke checks:

```
uv run ./odyssey_ansi_studio.py --selftest            # build window, render one frame, exit
uv run ./odyssey_ansi_studio.py --demo --selftest
uv run ./odyssey_ansi_studio.py --selftest --shot /tmp/shot.png
uv run python -m compileall -q studio odyssey_ansi_studio.py
```

Widget tests run under `QT_QPA_PLATFORM=offscreen`; core tests need no display.
`tests/conftest.py` puts the package root on `sys.path`, so there is no install
step.

**`IMPLEMENTATION_DETAILS.md`** has the hardware/format facts, the layer and
compositing semantics, the exporter contracts, the font-ROM bit order, the
screen-eyedropper D-Bus situation, and the other things that are easy to get
wrong when revisiting this code.

## Project layout

```
odyssey_ansi_studio.py     entry point (PEP 723 header, argparse, --demo/--selftest)
studio/
  model/    palette  cell  layers  document  history  rasterize
  io/       cp437  fontrom  project_file  export_ans  export_targets  export_png
  convert/  image_import
  tools/    base  controller  pencil  eraser  line  rect  ellipse
            fill  recolor  eyedropper  move_layer  gradient
  ui/       main_window  canvas_view  palette_panel  glyph_picker  toolicons
            appicon  desktop_integration  screen_pick  color_match_dialog
            ink_dialog  layers_panel  cell_inspector  box_dialog
            text_layer_edit  crop_view  image_import_dialog  export_dialog  demo
tests/      one file per module; run headless with QT_QPA_PLATFORM=offscreen
```
