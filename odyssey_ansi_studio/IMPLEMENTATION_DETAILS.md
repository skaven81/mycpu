# Odyssey ANSI Studio -- implementation notes

Everything an agent revisiting this codebase needs that is not obvious from the
source. Read alongside `README.md` (user-facing) and the module docstrings
(each file's `WHAT` / `WHY` is authoritative for that file).

Branch: `odyssey-ansi-studio`. **Nothing is committed** -- do not commit until
the owner asks. Use `uv` for all dependency work. Test bar: `320` tests green as
of 2026-09-07.

---

## 1. Hardware / format facts the code must honor

From skill `ody-io`, `TERMINAL.md`, `os/README-bios-exec.md`, `os/bootbanner/gen.py`:

- Visible grid **64x60**. Character plane `0x4000`..`0x4EFF` (3840 bytes,
  row-major, `off = row*64 + col`). Color plane `0x5000`..`0x5EFF`, same layout.
- Color byte: bit 7 `BLINK` (`0x80`), bit 6 `CURSOR` (`0x40`), bits `[5:4]` red
  index, `[3:2]` green index, `[1:0]` blue index. Each channel index 0..3 maps
  to an intensity in `LEVELS = [0, 85, 170, 255]`. **No background color.**
- The `CURSOR` bit is an editor artifact. Every exporter masks it out by
  default; `BLINK` is kept.
- CP437 glyph codes `< 0x20` and `0x7F` render fine straight to VRAM but are
  eaten as control characters when an `.ANS` is *streamed* to the terminal.
  `cell.is_control_glyph()` is the one canonical predicate; exporters collect a
  warning per offending cell.
- Odyssey terminal ANSI: SGR 30-37 / 90-97, `ESC[0m`, `ESC[5m` / `ESC[25m`
  blink; **no truecolor** (silently dropped). The out-of-spec **`ESC[<v>p`**
  escape writes `v` (0..255) straight into the color plane and switches the
  terminal into color rendering -- this is how the native exporter embeds an
  exact 64-color value plus blink. `ESC[0p` == black.

## 2. Architecture

GUI-independent core + thin Qt layer. **`model/`, `io/`, `convert/`, `tools/`
must stay headless-importable** -- no `from PySide6` except `io/fontrom.py`
(which uses `QImage`/`QColor` purely for its glyph-tile cache, and even that is
only touched by `Bank.glyph_image`; `parse_f08` and the bank table are Qt-free).
`tools/` is Qt-free on purpose: the same `ToolContext` objects drive the
headless tests in `tests/test_tools.py`.

`studio/ui/__init__.py:theme_icon(name, fallback_sp)` is the one icon helper
(`QIcon.fromTheme` -> `QStyle` standard-icon fallback). The entry-point script
re-exports it so it is reachable without importing `__main__`.

## 3. Cell model -- "empty != space"

`model/cell.py`: `Cell(glyph:int, attr:int)` is a `NamedTuple` (hashable,
value-compared). **A NULL / empty cell is `None`, never a `Cell`.** There is
deliberately no "empty Cell" sentinel: the compositor's first-non-None-wins walk
depends on the distinction, and a painted space (`0x20`) still hides layers
below it whereas `None` is transparent.

`cell_to_dict` / `cell_from_dict` are `{"glyph", "attr"}` or `None`.

## 4. Layers (`model/layers.py`)

- `Layer` = metadata (`name`, `visible`, `locked`, `kind`, optional `group`
  string) + integer origin `(offx, offy)` + `cells: dict[(col,row) -> Cell]` in
  **layer-local** coordinates. NULL cells are simply absent.
- Two coordinate spaces: **layer-local** (`get_local` / `set_local`, what the
  paint tools and `CellEditCommand` use) and **document-space** (`get` / `set` /
  `iter_cells` = local + offset, what the compositor and canvas use). Keeping
  the offset separate makes "move this whole box 3 right" an O(1) metadata
  change and keeps undo keys valid across a move.
- `frame()` -> `(col, row, w, h)` in document cells, or `None`. Base layer =
  bounding box of painted cells (move-only, `resizable()` is `False`).
- `to_dict` serializes `cells` as a sorted list of `[lc, lr, glyph, attr]` for
  deterministic output. `layer_from_dict` dispatches on `kind`; an **unknown
  kind falls back to `BlankLayer`** so its cell data survives.

### GeneratedLayer (Box / Text / Image)

`GeneratedLayer` treats `cells` as a **cache of a parameter dict** (`self.params`):

- `_rasterize()` (subclass hook) -> a fresh `{(lc,lr): Cell}` from `params`.
- `regenerate()` overwrites `cells` from `_rasterize()` and snapshots the result
  into `self._raster_cache`.
- `manual_edits()` -> `True` once `cells` drifts from that snapshot. The UI
  **warns before a re-rasterize would discard hand edits** -- but "layers are
  mutable" wins if the user confirms (owner's standing rule).
- `from_dict` re-snapshots via `_rasterize()`, so a load-then-diverge still
  counts as a hand edit.
- `resize(w, h)` writes the param pair the layer uses: `BoxLayer` / `TextLayer`
  use `w`/`h`; `ImageLayer` uses `cols`/`rows`. `_wh()` / `frame()` read
  whichever pair is set. `set_frame(col,row,w,h)` moves + resizes + regenerates.

| Layer | params of note | `_rasterize` |
|---|---|---|
| `BoxLayer` | `style`, `w`, `h`, `box_attr`, `title`/`footer` (+ `_align`, `_attr`, `_flair`), `interior`, `fill_glyph`/`fill_attr`, `shadow`, `shadow_attr` -- see `rasterize.BOX_DEFAULTS` | `rasterize_box(params)` |
| `TextLayer` | `text`, `w`, `h`, `align`, `wrap`, `text_attr`, `opaque`; `.text` / `.rect` are property views onto `params` for older call sites | `rasterize_text(params)` |
| `ImageLayer` | `source_ref` (assets key), `params` = an `ImportParams` dict | `convert(source_img, ImportParams.from_dict(params))`, or the current cells if no pixels attached |

`ImageLayer._source_img` (PIL) and `_source_bytes` (PNG) are **not serialized**.
`attach_source(blob=|image=)` reattaches them after load and sets `source_ref`
from the SHA-256. Without pixels (`source_ref` present but asset missing),
`_rasterize()` returns the cached cells unchanged.

## 5. Document + compositing (`model/document.py`)

- Fixed `WIDTH=64` `HEIGHT=60`, `PLANE_SIZE=3840`. `layers[0]` is the bottom.
- `composite()` -> `(char_plane, color_plane)` as two `width*height` `bytes`,
  row-major. Algorithm: iterate layers **top -> bottom**, and for each non-NULL
  cell that is in-bounds and not yet claimed, write glyph + attr and mark it
  claimed. So "first writer wins" == "topmost visible layer wins", and it
  supplies **both** glyph and color. Cells no layer contributes to are `0x00`
  in both planes.
- `_layer_drawn(layer)` = `layer.visible and group_visible(layer)`. Groups
  (`Document.groups = {name: {visible, collapsed}}`) are a display/visibility
  convenience only; `collapsed` is panel-only. `_prune_groups()` runs after any
  structural change.
- `merge_down(i)` writes every cell layer `i` contributes into layer `i-1`
  (document-space, so both offsets respected), then drops `i`. Merges **raw
  cell data regardless of `visible`** -- composite is unchanged only if both
  were visible.
- `flatten()` replaces the whole stack with one `BlankLayer` holding the
  composite (NULL stays NULL), clears groups.
- `to_dict` / `from_dict`: `SCHEMA_VERSION = 1`. `from_dict` raises `ValueError`
  on a non-mapping or an unknown schema. **`.oas` JSON keys were NOT touched by
  the US-English spelling sweep** -- do not rename them.

## 6. `.oas` project container (`io/project_file.py`)

Plain zip. Members:

- `mimetype` -- first, `ZIP_STORED`, bytes exactly
  `application/x-odyssey-ansi-studio`. Absence tolerated on load; a wrong value
  is rejected.
- `document.json` -- `Document.to_dict()`, UTF-8, `json.dumps(indent=2)`.
- `assets/<sha256hex>.png` -- imported source images, keyed by SHA-256 of the
  bytes.

Write is **atomic**: temp file in the same directory, then `os.replace`. All
read/write failures surface as `ProjectFileError` (a `Document.from_dict`
`ValueError` is wrapped in with its message). `save_project(doc, path,
assets={...})` and `read_assets(path)` move the asset bundle;
`MainWindow._collect_assets` / `_reattach_assets` bracket the calls.

## 7. Exporters

### `io/export_ans.py` -- Odyssey-native `.ANS`

`export_ans(doc, *, trim_trailing_blanks=True, row_separator=b"", null_mode="space")`
-> `ExportResult(data, warnings, byte_count, rows_emitted)`.

- Stream = `ESC[H` then, row-major, `ESC[<v>p` **only when `v` changes** from
  the last emitted, then the raw CP437 glyph byte. `v` = color byte with cursor
  bit masked (`_EXPORT_ATTR_MASK = 0xBF`), blink kept.
- The terminal is 64 wide and auto-wraps, so hardware playback needs no row
  separator (default `b""`). The dialog passes `b"\r\n"` for a file that also
  `cat`s correctly.
- **Locked decisions** (there are golden-file tests -- do not "fix" these):
  - empty doc + `trim_trailing_blanks` -> exactly `ESC[H`, nothing else.
  - `row_separator` is emitted after *every* emitted row including the last, so
    `data.count(sep) == rows_emitted` when `sep` is non-empty and absent from
    glyph data.
  - trim cutoff = last cell that is not (`glyph == 0x20 AND attr == 0x00`);
    wholly-blank trailing rows are then not emitted.
  - warnings are collected over the whole composite (a control glyph is never
    trimmable, so this matches the emitted region).
- `null_mode`: `"space"` -> `(0x20, 0x00)`; `"null"` -> `(0x00, 0x00)`;
  `"block"` -> `(0xDB, 0x00)`; `"transparent"` -> skip the cell, absolutely
  position each row with `ESC[<r>;1H` and step over gaps with `ESC[<n>C`
  (cursor jump forces a color re-assert).

`export_ans16(...)` -- portable: every cell snapped to `nearest_ansi16`, emitted
as `ESC[0m ESC[<sgr>m` (+ `ESC[5m` for blink). Default `row_separator = b"\r\n"`.

`ansi_preview_text(result)` -- latin-1 decode with `ESC` shown as `U+241B` for
the read-only preview pane.

### `io/export_targets.py` -- binary / C / ASM

All start from `Document.composite()`; cursor bit masked by default, blink kept.
Fixed-size plane formats cannot omit a cell, so `null_mode="transparent"`
collapses to `"null"` (leave `0x00`).

- `export_binary(doc, layout="split"|"interleaved", ...)` -> `bytes`. `split` =
  whole char plane then whole color plane; `interleaved` = `char, color` per
  cell.
- `export_c_header(doc, name, ...)` -> `str`. `<NAME>_chr[]` / `<NAME>_clr[]`
  `unsigned char` arrays + `<NAME>_W` / `_H` / `_CELLS` defines + include guard,
  `banners.h` style. `name` sanitized to a C identifier.
- `export_asm(doc, name, ...)` -> `str`. `:<name>_chr` / `:<name>_clr` data
  labels, one line of space-separated `0xNN` literals per plane -- matches this
  repo's assembler data-line grammar (`_chr`/`_clr` suffix guarantees the
  4-char-minimum label length).

### `io/export_png.py`

`render_image(doc, fontrom, scale=1, show_blink=True)` -> `PIL.Image`. Each cell
= its 8x8 CP437 glyph from `doc.font_bank`, tinted to the cell's nearest-64 RGB
on black. `scale` enlarges nearest-neighbor. `show_blink=False` renders blink
cells black (their "off" phase). Falls back to `fontrom.blank_bank()` if the
`.F08` is missing.

## 8. Palette (`model/palette.py`)

- `PALETTE[code]` for `code` in 0..63 = `(LEVELS[(code>>4)&3], LEVELS[(code>>2)&3],
  LEVELS[code&3])`. `rgb_to_odyssey(r,g,b)` quantizes **each channel
  independently** by `min(3, round(chan/85))`. Matches
  `odyssey_video.palette.rgb_to_odyssey` exactly -- keep them identical so image
  import and the editor quantize the same.
- Attr helpers: `attr_blink` / `attr_cursor` / `attr_rgb_idx` / `make_attr` /
  `attr_to_rgb` / `with_blink` / `with_cursor`. `BLINK_BIT=0x80`,
  `CURSOR_BIT=0x40`, `RGB_MASK=0x3F`.
- `ANSI16` maps 16 exact attr bytes -> `(SGR, name)`; these are the terminal's
  SGR 30-37 / 90-97 colors and every one round-trips exactly through
  `attr_to_rgb`. `ANSI16_BY_SGR` is the reverse. `nearest_ansi16(attr)` snaps by
  RGB distance over the 16-set, preserves blink, drops cursor.

## 9. Rasterizers (`model/rasterize.py`)

Pure functions: `params` dict in, `{(lc,lr): Cell}` out. Called only from
`GeneratedLayer.regenerate()`.

- `rasterize_box`: degenerate sizes handled first (`1x1` -> `cross`; `1xN` ->
  `v` run; `Nx1` -> `h` run). Otherwise: interior fill first (so the border
  overwrites its own ring cleanly), then edges, then the 4 corners, then
  title/footer labels, then an optional drop shadow (`0xB1`, one cell right +
  below, `setdefault` so it never lands on the box).
- `BOX_STYLES` (in `io/cp437.py`): each style set has the 6 core members
  `tl tr bl br h v` plus 5 junctions `t_left t_right t_up t_down cross`, as
  CP437 **byte codes**. Styles: `single`, `double`, `single_h_double_v`,
  `double_h_single_v`, `block`.
- `LABEL_FLAIRS` -- a title/footer flair is exactly **one glyph each side** of
  the label (one space to the text). `"none"` -> plain inset ` TITLE `;
  `"line"` -> the sentinel: use the box's own junction glyphs weight-matched to
  its border (`_flair_glyphs` returns `CP437_TO_UNICODE[sset["t_right"]]` /
  `["t_left"]`, i.e. single `┤ ├`, double `╣ ╠`), rendered flush on the border
  line -> `──┤ TITLE ├──`; a literal pair like `("{", "}")` otherwise. Flair is
  silently dropped when the box is too narrow (`w < 6`, or budget `< 1`).
- `wrap_text(text, width, wrap=True)`: explicit `\n` always breaks; with `wrap`,
  greedy word-wrap and hard-split any word longer than `width`; without,
  paragraphs pass through and the caller clips.
- `rasterize_text`: wrap, clip to `h` lines and `w` columns, align
  (left/center/right), and -- unless `opaque` -- **skip space characters** so
  the text layer is transparent between glyphs.

## 10. Font ROM (`io/fontrom.py`)

- 16 selectable banks. Real hardware ROM = 16 `.F08` files concatenated per
  `bitmapfont/build_font_rom.sh`; **slots 8..15 repeat 0..7 verbatim**
  (`BANKS[i]` uses `_BASE_BANKS[i % 8]`).
- Each `.F08` is **2048 bytes = 256 glyphs x 8 rows, row-major**. `parse_f08`
  raises `ValueError` on any other length.
- **Bit order: bit 7 (MSB) = leftmost pixel.** The Phase-1 brief said "LSB =
  leftmost"; that is wrong. Verified against `CGA.F08` glyph `0x4C` ('L'),
  which only renders as an 'L' MSB-left. Both `Bank._render` and
  `export_png.render_image` mask with `0x80 >> c`.
- `_resolve_bitmapfont_dir` search order: explicit `repo_root` arg ->
  `$ODYSSEY_REPO_ROOT` env -> walk up from this file for a `bitmapfont/`
  sibling -> last-ditch `parents[3]/bitmapfont`.
- `load_bank(i)` raises `FileNotFoundError` (naming the expected path) when the
  asset is missing; callers fall back to `FontRom.blank_bank()` (all-zero) so
  the app still starts. Banks load lazily; `Bank.glyph_image(code, rgb)` caches
  an 8x8 `QImage` tile per `(code, rgb)` (the canvas re-blits the same handful
  thousands of times).

## 11. CP437 (`io/cp437.py`)

- `CP437_TO_UNICODE` -- 256-tuple. `0x00-0x1F` = the control-position
  pictographs (`0x00` -> `U+0000`), `0x20-0x7E` = ASCII, `0x7F` = house,
  `0x80-0xFF` = the DOS high range. Seeded from `os/bootbanner/gen.py`,
  completed to 256.
- `UNICODE_TO_CP437` -- reverse, **lowest CP437 code wins** on a collision.
  `rasterize._u2cp` falls back to `ord(ch) & 0xFF` for anything unmapped.
- `GLYPH_NAMES` / `glyph_name(code)` -- partial (shades/box/blocks well
  covered); `"0xNN"` hex fallback otherwise.
- `is_control_glyph` is re-exported from `model/cell.py` (canonical def there).

## 12. Image import (`convert/image_import.py`)

`convert(img, params: ImportParams)` -> `{(col,row): Cell}` at origin 0,0.
Pipeline: `_prepared` (RGB + crop-clamp) -> `img.resize((cols, rows*vf), resample)`
-> `_reduce` (posterize + optional dither) -> per-cell luminance + color match.

- `vf = 2` and `resample = Image.BOX` for `halfblock` (each half is a clean
  band average); `Image.LANCZOS` and `vf = 1` for `blocks` / `shades`.
- `_reduce(arr, levels, dither)`: `levels` clamped 2..4; identity when
  `levels == 4 and not dither`; else quantize each channel to `levels` bands and
  (if `dither`) Floyd-Steinberg error-diffuse (7/16, 3/16, 5/16, 1/16).
- Color match: `params.match` `"rgb"` -> `rgb_to_odyssey`; `"oklab"` ->
  `_nearest_oklab` (sRGB->linear->LMS->cbrt->OKLab, nearest of the 64 by squared
  distance; palette OKLab cached in `_PALETTE_OKLAB`).
- Cells with luminance `<= dark_threshold` (default 24) stay **NULL** so an
  imported logo drops onto whatever is beneath. `shades` also skips a cell whose
  ramp glyph is `0x20`.
- `SHADE_RAMP = (0x20, 0xB0, 0xB1, 0xB2, 0xDB)`. `halfblock` uses `0xDF` (upper)
  / `0xDC` (lower) / `0xDB` (full) and the color of the lit half (or the average
  for full).
- `ImportParams` round-trips through `to_dict` / `from_dict` (that dict is what
  `ImageLayer.params` stores in the `.oas`). `fit_cells(src_w, src_h)` suggests
  an aspect-preserving `(cols, rows)` fit into 64x60.

## 13. Tools (`tools/`)

- `ToolContext(document, history, get_glyph, get_attr, set_glyph=, set_attr=,
  on_change=, on_status=, on_select=)` is a tool's whole view of the world. **No
  Qt.** The UI maps `Qt.KeyboardModifiers` onto `MOD_SHIFT|MOD_CTRL|MOD_ALT`
  bit flags so tools stay Qt-free.
- Staging model in `base.py`: `_start` (snapshot active layer + index; refuse a
  locked/missing layer -> the stroke is a no-op), `_stage` (write one cell live,
  remember its old value, drop out-of-doc cells), `_revert` (undo everything
  staged -- shape tools call this at the top of every `drag`), `_commit` (push
  the net change as one `CellEditCommand` via `History.push_done`, since the
  edit is already applied live). Live staging means the canvas shows the true
  composite mid-stroke with no separate preview path.
- `ToolController` (`controller.py`): `press` / `drag` / `release` / `cancel`;
  switching tools cancels the in-flight stroke.
- `TOOL_ORDER` / `build_tools()` define the rail. `select` and `cell-edit` are
  **both `CellEditTool`** (different UX wiring in the window). `move-layer` =
  `MoveLayerTool` (drag shifts `offx/offy`, one `TranslateLayerCommand` on
  release). **Box / Text / Image / Blank are NOT controller tools** -- they are
  one-shot "new layer" rail buttons aliased to `LayersPanel.add_*`.
  `eyedropper` still exists as a tool + shortcut I, but the Ink panel's
  "Pick..." button is the screen-wide picker, not this tool.

## 14. Undo history (`model/history.py`)

- `CellEditCommand(layer_index, changes)` -- `changes` maps a **layer-local**
  `(col,row)` to `(old_cell_or_none, new_cell_or_none)`. Layer-local so the
  command survives the layer being moved between edit and undo. Storing the pair
  (not a layer snapshot) keeps undo memory proportional to what changed.
- `TranslateLayerCommand(layer_index, dx, dy)`, `ReshapeLayerCommand(layer_index,
  before, after)` (frames as `(col,row,w,h)`; calls `set_frame`, which
  regenerates a generated layer).
- `History.push(cmd)` runs `cmd.do()` then records; `push_done(cmd)` records a
  command whose effect is already applied (interactive drags). Depth cap
  `DEFAULT_DEPTH = 200`; oldest entries are dropped permanently.
- **Not yet undoable:** structural layer ops (add / delete / reorder /
  merge-down / flatten / group). Only cell edits, translate, and reshape are.

## 15. Canvas (`ui/canvas_view.py`)

Custom `paintEvent` renders `doc.composite()` with real ROM glyphs on black.
Opens at 2x, integer zoom only. `cellHovered = Signal(int, int, object)`,
`zoomChanged = Signal(int)`. `set_frame_editing(on)` (the window turns it on for
select/move-layer) draws the active layer's amber dashed frame + resize handles
+ size badge; `_compute_overflow` drives the red per-edge off-canvas bars.
Blink is a `QTimer`. `content_pixel_size()` / `_grow_to_show_canvas()` in the
window grow the frame on first show so the whole 64x60 grid is visible at 2x
(clamped to the screen).

## 16. Screen eyedropper (`ui/screen_pick.py`) -- READ THIS BEFORE TOUCHING IT

`pick_screen_color(parent, on_picked, on_cancel=None)` -- two back-ends tried in
order.

**Back-end 1: `org.freedesktop.portal.Screenshot.PickColor` spoken with
`jeepney`, NOT QtDBus.** This is settled; do not "simplify" it back to QtDBus.

- PySide6 **6.11.2** cannot demarshal a `QDBusArgument` at all. Proven by probe
  against a real `a{sv}` from `Properties.GetAll`:
  - `QDBusArgument.asVariant()` returns an unconvertible pointer
    (`pointerToPython() ... is null for Shiboken.VoidPtr`).
  - `beginArray()` / `beginMap()` / `beginStructure()` are the **marshalling**
    (write) overloads only -- on a read-only arg they print
    `QDBusArgument: write from a read-only object` and a later call **SIGABRTs**
    the process (`You can't recurse into an empty array`).
  - `dict(arg)` / `list(arg)` -> "not iterable".
  The portal `Response` payload (`a{sv}`, color under a `(ddd)` variant) is
  therefore unreadable through QtDBus. normcap's `QDBusAbstractInterface` +
  `Signal(QDBusMessage)` + `beginArray` walk (which does ship in normcap) does
  **not** work on this stack -- tried, failed, twice.
- `jeepney` is pure-Python, parses `a{sv}` / `(ddd)` natively (an `a{sv}` comes
  back as a `dict` whose variant values are `(signature_str, payload)` tuples).
- `_portal_available()` -> `(ok, reason)`: sync `GetAll` on the Screenshot
  interface, check `version >= 2` (PickColor landed in Screenshot v2, so the
  version property is also the capability probe).
- `_PortalPickThread(QThread)` runs jeepney's **blocking** client off the GUI
  thread (a pick can take many seconds while the user aims): `AddMatch` on
  `Request.Response`, then predict the request object path from a chosen
  `handle_token` --
  `/org/freedesktop/portal/desktop/request/<unique_name with leading ':' stripped
  and '.'->'_'>/<token>` -- and subscribe **before** calling `PickColor`, because
  the `Response` can beat the method reply. Then a
  `conn.receive(timeout=min(left, 1.0))` loop (honors `isInterruptionRequested()`,
  180 s deadline) until a `Response` signal on our path. Emits `picked(r,g,b)`
  (0..1 floats) or `failed(reason)` (`""` == plain cancel).
- `_PortalPick(QObject)` owns the thread so the worker's signals cross back to
  the GUI thread as a **queued** connection; `_got_rgb` / `_got_fail` are
  `@Slot`s; `aboutToQuit` -> interrupt + join. On a real failure under Wayland
  it shows `_warn_no_portal` (a QMessageBox naming
  `xdg-desktop-portal-gnome`/`-gtk`).
- `_extract_rgb(results)` unwraps jeepney's `('(ddd)', (r,g,b))` variant tuple;
  also accepts a bare `[r,g,b]` (the unit tests use that shape).
- `_is_wayland()` trusts **only** `QGuiApplication.platformName()` so the
  offscreen test suite takes the overlay branch even when
  `XDG_SESSION_TYPE=wayland`.

**Back-end 2: frozen-screenshot overlay (`ScreenColorPicker`).** X11 only --
`QScreen.grabWindow(0)` returns black under Wayland. `grab_virtual_desktop()`
composites every screen into one **logical-sized** pixmap (each screen scaled to
its logical geometry, so no DPR skew on HiDPI). Loupe + hex readout follow the
pointer; next left click yields the pixel; Esc / right click cancels. On Wayland
a failed portal call reports the reason rather than showing the (necessarily
black) overlay.

Downstream: `OdysseyColorDialog(sampled, current_attr)` in
`ui/color_match_dialog.py` opens **with `nearest_odyssey(sample)` already
selected** (split-screen + swatch grid + readouts populated). `nearest_odyssey`
takes `metric="rgb"|"oklab"`. `MainWindow._match_screen_color` keeps the
existing blink/cursor bits and swaps only the color.

Verified end to end that the worker starts, `_portal_available()` is
`(True, "")`, and the real `PickColor` call is made. The final Response parse on
a live pixel click is exercised by
`scratchpad/eyedropper_check.py` (needs a human click); jeepney's native
`a{sv}`/`(ddd)` parse and `_extract_rgb` are unit-tested.

## 17. Desktop integration (`ui/desktop_integration.py`)

GNOME/Wayland ignores `setWindowIcon()` for the shell; it binds the window (via
`app_id` = `odyssey-ansi-studio`, set with `setDesktopFileName`) to an installed
`.desktop`. `ensure_desktop_integration(force=False)` writes
`~/.local/share/applications/odyssey-ansi-studio.desktop` (with
`StartupWMClass`) + `icons/hicolor/<sz>/apps/odyssey-ansi-studio.png` (7 sizes
from `appicon.app_icon()`), idempotent (`_write_if_changed`), best-effort (never
raises). Called on launch unless `--selftest` / `--no-desktop-integration`;
`--install-desktop` forces it and exits. The entry script builds `QApplication`
**before** the install branch because `QPixmap` needs a `QGuiApplication`.

## 18. Entry point (`odyssey_ansi_studio.py`)

PEP 723 header: `["PySide6>=6.6", "Pillow>=9.0", "numpy>=1.21", "jeepney>=0.8"]`
(mirrored in `pyproject.toml` and `requirements.txt` -- keep all three in sync).
Flags: `--demo` (sample doc), `--selftest` (build window, render one frame,
print `ok`, exit 0, no event loop), `--shot PATH` (with `--selftest`, save the
canvas PNG), `--install-desktop`, `--no-desktop-integration`. `--selftest`
implies `--demo`'s document.

## 19. Testing

`tests/conftest.py` puts the package root on `sys.path` (no install step), one
file per module. Widget tests need `QT_QPA_PLATFORM=offscreen`; core tests do
not.

```
QT_QPA_PLATFORM=offscreen uv run --extra dev pytest tests/ -q     # 320 pass
uv run ./odyssey_ansi_studio.py --selftest
uv run ./odyssey_ansi_studio.py --demo --selftest
uv run python -m compileall -q studio odyssey_ansi_studio.py
```

`tests/test_compositing_props.py` is property-based (order/offset/empty!=space
invariants). Exporters have golden-byte tests -- expect to update them
deliberately, never casually.

## 20. Prior art reused (do not re-implement)

- `odyssey_video/palette.py` -- `PALETTE`, `rgb_to_odyssey`, `odyssey_to_rgb`
  (behavior copied into `model/palette.py`; keep identical).
- `bitmapfont/int10h/FONTS/**/*.F08` -- the 8x8 CP437 fonts;
  `bitmapfont/build_font_rom.sh` -- the canonical 16-slot bank assignment.
- `os/bootbanner/gen.py` -- seed for the CP437 table and the color-byte layout.

## 21. Standing constraints

- **Do not commit** until the owner explicitly asks.
- Use `uv` for all dependency loading.
- Owner's box is **Ubuntu GNOME Wayland** -- the root cause of most
  "X is broken" reports. Test eyedropper / taskbar-icon behavior with that in
  mind.
- Owner email `paul.krizak@gmail.com` is for identifying the owner's own work
  only -- never send it to an unrelated service.
- **Layers stay mutable**: a Box/Text/Image layer's params are editable forever
  and re-rasterize on change; the UI warns before overwriting hand-edits but the
  re-rasterize wins on confirm; every layer kind is resizable.
- Styling: plain platform theme, `QIcon.fromTheme` + `QStyle` fallback, no
  custom styling. Effort goes into behavior, not window dressing.

## 22. Still deferred (not started)

Glyph best-fit / edge-ASCII image conversion; RLE packing + an `ody_rle_unpack`
ROM routine (needs firmware work -- confirm with owner); control-socket / MCP
parity with `odyssey_console` (cross-system -- confirm with owner); undo for
structural layer operations (add/delete/reorder/merge/flatten/group as `History`
commands -- reshape/translate/cell-edit are already done).
