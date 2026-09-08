"""
The ``--demo`` document: a synthetic `Document` exercising every render path.

Box and text layers are not rasterized until Phase 5, so this hand-places
`Cell`s straight into `BlankLayer`s:

* **background** -- a full-frame double-line border in dim cyan.
* **panel**      -- a smaller single-line box with an amber "MEMORY MAP" title.
* **accents**    -- a horizontal palette gradient strip, blinking "READY"
                    cells (BLINK bit), and a few CURSOR-bit cells.

``DEMO_SELECTION`` / ``DEMO_CARET`` are pushed to ``CanvasView`` by the caller
so the drawn (non-interactive) marquee and caret appear.
"""

from studio.io.cp437 import BOX_STYLES, UNICODE_TO_CP437
from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BlankLayer
from studio.model.palette import make_attr

# Pushed into CanvasView.set_demo_selection / set_caret by the entry point.
DEMO_SELECTION = (12, 8, 16, 6)   # (col, row, w, h)
DEMO_CARET = (20, 10)             # (col, row)

_CYAN = make_attr(0, 2, 2)                 # 0x0a  dim cyan
_AMBER = make_attr(3, 2, 0)                # 0x38  amber
_WHITE = make_attr(2, 2, 2)               # 0x2a  ANSI white


def _char_code(ch: str) -> int:
    """CP437 byte for a character (ASCII 0x20..0x7E is identity)."""
    if 0x20 <= ord(ch) <= 0x7E:
        return ord(ch)
    return UNICODE_TO_CP437.get(ch, ord(ch)) & 0xFF


def _text(layer, col, row, s, attr):
    for i, ch in enumerate(s):
        layer.set_local(col + i, row, Cell(_char_code(ch), attr))


def _box(layer, x0, y0, x1, y1, style, attr):
    st = BOX_STYLES[style]
    for x in range(x0 + 1, x1):
        layer.set_local(x, y0, Cell(st["h"], attr))
        layer.set_local(x, y1, Cell(st["h"], attr))
    for y in range(y0 + 1, y1):
        layer.set_local(x0, y, Cell(st["v"], attr))
        layer.set_local(x1, y, Cell(st["v"], attr))
    layer.set_local(x0, y0, Cell(st["tl"], attr))
    layer.set_local(x1, y0, Cell(st["tr"], attr))
    layer.set_local(x0, y1, Cell(st["bl"], attr))
    layer.set_local(x1, y1, Cell(st["br"], attr))


def demo_document() -> Document:
    doc = Document(font_bank=0)

    background = BlankLayer(name="background")
    _box(background, 0, 0, doc.width - 1, doc.height - 1, "double", _CYAN)

    panel = BlankLayer(name="panel")
    _box(panel, 10, 6, 40, 20, "single", _AMBER)
    _text(panel, 14, 6, " MEMORY MAP ", _AMBER)
    _text(panel, 12, 9, "0x4000  CHAR PLANE", _AMBER)
    _text(panel, 12, 11, "0x5000  COLOR PLANE", _AMBER)
    _text(panel, 12, 13, "64 x 60  CELLS", _AMBER)

    accents = BlankLayer(name="accents")
    # Palette gradient strip, row 3, cols 4..44.
    span = 40
    for i in range(span):
        code = int(i / (span - 1) * 63)
        accents.set_local(4 + i, 3, Cell(0xDB, code))
    # Blinking "READY" (BLINK bit set).
    blink_attr = make_attr(1, 3, 1, blink=True)
    _text(accents, 26, 23, "READY", blink_attr)
    # A few CP437 control-position pictographs (0x03 heart): they render fine
    # to VRAM but collide with terminal control chars, so the .ANS exporter
    # must warn about them.
    for hx in (21, 22, 23):
        accents.set_local(hx, 23, Cell(0x03, make_attr(3, 0, 0)))
    # A few CURSOR-bit cells (rendered as plain color in Phase 1).
    cur_attr = make_attr(3, 3, 3, cursor=True)
    for cx in (24, 25, 26):
        accents.set_local(cx, 25, Cell(0xDB, cur_attr))

    doc.add_layer(background)
    doc.add_layer(panel)
    doc.add_layer(accents)
    doc.active_layer_index = len(doc.layers) - 1
    doc.font_bank = 0
    return doc
