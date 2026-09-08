"""
Rasterizers: turn a Box / Text layer's *parameters* into a sparse cell grid.

WHAT
    `rasterize_box(params)` and `rasterize_text(params)` are pure functions:
    ``params`` dict in, ``{(local_col, local_row): Cell}`` out (layer-local
    coordinates, NULL cells simply absent).  The layer classes call these from
    `regenerate()`; nothing here touches a `Layer` or a `Document`.

WHY
    A generated layer's cell grid is a *cache* of its parameters.  Keeping the
    generation pure means "re-open the box dialog, change the style, redraw"
    is a one-liner, and the divergence check that warns before overwriting a
    hand-edited generated layer is just ``cells != rasterize(params)``.
"""

from studio.io.cp437 import BOX_STYLES, CP437_TO_UNICODE, UNICODE_TO_CP437
from studio.model.cell import Cell

# --- box ------------------------------------------------------------------

# A title / footer "flair" is exactly ONE glyph on each side of the label text
# (with a single space between the glyph and the text).  ``LABEL_FLAIRS`` maps
# the Box dialog's combo choice to ``(left_glyph, right_glyph)``:
#
#   * ``None``           -- no flair, a plain inset label ("  TITLE  ").
#   * ``"line"``         -- the sentinel: use the box's own line-drawing
#                           junction glyphs, weight-matched to its border
#                           (single ``┤ ├``, double ``╣ ╠``, mixed as defined
#                           in ``cp437.BOX_STYLES``).  Renders as
#                           ``──┤ TITLE ├──``.
#   * a ``(l, r)`` pair  -- literal single characters, e.g. ``{`` / ``}``.
#
# The border line to either side of the label is the box's own edge, so a
# brace/bracket flair automatically reads as "line meeting a brace".
LABEL_FLAIRS = {
    "none":        None,
    "line":        "line",
    "braces":      ("{", "}"),
    "square":      ("[", "]"),
    "parens":      ("(", ")"),
    "angles":      ("<", ">"),
    "guillemets":  ("«", "»"),   # « »
    "bars":        ("|", "|"),
    "colons":      (":", ":"),
    "stars":       ("*", "*"),
}

BOX_DEFAULTS = {
    "style": "single",          # key into cp437.BOX_STYLES
    "w": 12,
    "h": 5,
    "box_attr": 0x0F,
    "title": "",
    "title_align": "left",      # left | center | right
    "title_attr": None,         # None -> follow box_attr
    "title_flair": "none",      # key into LABEL_FLAIRS
    "footer": "",
    "footer_align": "right",
    "footer_attr": None,
    "footer_flair": "none",
    "interior": "none",         # none | space | fill
    "fill_glyph": 0xB0,
    "fill_attr": None,
    "shadow": False,
    "shadow_attr": 0x15,        # dim gray -- a shadow you can actually see
}

TEXT_DEFAULTS = {
    "text": "",
    "w": 16,
    "h": 4,
    "align": "left",            # left | center | right
    "wrap": True,
    "text_attr": 0x0F,
    "opaque": False,            # paint spaces (hide layers below) or leave NULL
}


def _u2cp(ch: str) -> int:
    return UNICODE_TO_CP437.get(ch, ord(ch) & 0xFF)


def rasterize_box(params: dict) -> dict:
    p = {**BOX_DEFAULTS, **(params or {})}
    w = max(int(p["w"]), 1)
    h = max(int(p["h"]), 1)
    sset = BOX_STYLES.get(p["style"], BOX_STYLES["single"])
    attr = int(p["box_attr"]) & 0xFF
    cells: dict = {}

    if w == 1 and h == 1:
        cells[(0, 0)] = Cell(sset["cross"], attr)
        return cells
    if w == 1:
        for y in range(h):
            cells[(0, y)] = Cell(sset["v"], attr)
        return cells
    if h == 1:
        for x in range(w):
            cells[(x, 0)] = Cell(sset["h"], attr)
        return cells

    # interior first, so the border overwrites its own ring cleanly
    interior = p["interior"]
    if interior == "space":
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                cells[(x, y)] = Cell(0x20, attr)
    elif interior == "fill":
        fg = int(p["fill_glyph"]) & 0xFF
        fa = int(p["fill_attr"] if p["fill_attr"] is not None else attr) & 0xFF
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                cells[(x, y)] = Cell(fg, fa)

    # border
    for x in range(w):
        cells[(x, 0)] = Cell(sset["h"], attr)
        cells[(x, h - 1)] = Cell(sset["h"], attr)
    for y in range(h):
        cells[(0, y)] = Cell(sset["v"], attr)
        cells[(w - 1, y)] = Cell(sset["v"], attr)
    cells[(0, 0)] = Cell(sset["tl"], attr)
    cells[(w - 1, 0)] = Cell(sset["tr"], attr)
    cells[(0, h - 1)] = Cell(sset["bl"], attr)
    cells[(w - 1, h - 1)] = Cell(sset["br"], attr)

    # title / footer -- inset label, optionally wrapped in a one-glyph flair
    # (the "line" flair uses this box's own junction glyphs, `sset`).
    _label(cells, p["title"], 0, w,
           p["title_align"],
           int((p["title_attr"] if p["title_attr"] is not None else attr)) & 0xFF,
           p.get("title_flair", "none"), sset)
    _label(cells, p["footer"], h - 1, w,
           p["footer_align"],
           int((p["footer_attr"] if p["footer_attr"] is not None else attr)) & 0xFF,
           p.get("footer_flair", "none"), sset)

    # drop shadow, one cell right and below; never over the box itself
    if p["shadow"]:
        sg, sa = 0xB1, int(p["shadow_attr"]) & 0xFF
        for y in range(1, h + 1):
            cells.setdefault((w, y), Cell(sg, sa))
        for x in range(1, w + 1):
            cells.setdefault((x, h), Cell(sg, sa))

    return cells


def _flair_glyphs(flair, sset):
    """``(left, right)`` single characters for a flair choice, '' if none."""
    spec = LABEL_FLAIRS.get(flair)
    if spec == "line":
        # `t_right` (┤) closes the border arriving from the left of the text;
        # `t_left` (├) opens it again on the right.  Weight follows this style.
        return (CP437_TO_UNICODE[sset["t_right"]],
                CP437_TO_UNICODE[sset["t_left"]])
    if isinstance(spec, tuple):
        return spec
    return ("", "")


def _label(cells, text, row, w, align, attr, flair="none", sset=None):
    text = (text or "").splitlines()[0].strip() if text else ""
    if not text or w < 6:
        return
    if sset is None:
        sset = BOX_STYLES["single"]
    lf, rf = _flair_glyphs(flair, sset)
    if lf or rf:
        # flair glyph sits flush on the border line, one space to the text
        deco_l = f"{lf} " if lf else ""
        deco_r = f" {rf}" if rf else ""
        budget = w - 4 - len(deco_l) - len(deco_r)
        if budget < 1:                   # too narrow for flair -- plain label
            deco_l = deco_r = ""
            budget = w - 4
            label = f" {text[:budget]} "
        else:
            label = f"{deco_l}{text[:budget]}{deco_r}"
    else:
        label = f" {text[: w - 4]} "
    n = len(label)
    if align == "center":
        start = (w - n) // 2
    elif align == "right":
        start = w - 1 - n
    else:
        start = 2
    start = max(1, min(start, w - 1 - n))
    for i, ch in enumerate(label):
        cells[(start + i, row)] = Cell(_u2cp(ch), attr)


# --- text ---------------------------------------------------------------

def wrap_text(text: str, width: int, wrap: bool = True) -> list:
    """Break `text` into display lines no wider than `width`.

    Explicit newlines always break.  With `wrap`, each paragraph is greedily
    word-wrapped and any single word longer than `width` is hard-split.
    Without `wrap`, paragraphs pass through untouched (the caller clips).
    """
    width = max(int(width), 1)
    out = []
    for para in (text or "").split("\n"):
        if not wrap:
            out.append(para)
            continue
        words = para.split(" ")
        line = ""
        for word in words:
            while len(word) > width:
                if line:
                    out.append(line)
                    line = ""
                out.append(word[:width])
                word = word[width:]
            if not line:
                line = word
            elif len(line) + 1 + len(word) <= width:
                line += " " + word
            else:
                out.append(line)
                line = word
        out.append(line)
    return out


def rasterize_text(params: dict) -> dict:
    p = {**TEXT_DEFAULTS, **(params or {})}
    w = max(int(p["w"]), 1)
    h = max(int(p["h"]), 1)
    attr = int(p["text_attr"]) & 0xFF
    align = p["align"]
    opaque = bool(p["opaque"])
    lines = wrap_text(p["text"], w, bool(p["wrap"]))

    cells: dict = {}
    for r, line in enumerate(lines[:h]):
        line = line[:w]
        if align == "center":
            pad = (w - len(line)) // 2
        elif align == "right":
            pad = w - len(line)
        else:
            pad = 0
        pad = max(0, pad)
        for i, ch in enumerate(line):
            if ch == " " and not opaque:
                continue
            cells[(pad + i, r)] = Cell(_u2cp(ch), attr)
    return cells
