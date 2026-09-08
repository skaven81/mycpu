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
