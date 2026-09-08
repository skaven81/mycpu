"""
The `Cell` value type -- one Odyssey character cell.

WHAT
    A `Cell` is a tiny immutable pair: `glyph` (CP437 code 0..255) and `attr`
    (color byte 0..255, see studio.model.palette).  It is a NamedTuple, so
    it is hashable, cheap to copy, and compares by value.

WHY -- "empty is not a space"
    A NULL / empty cell is represented by **`None`**, never by a `Cell`.  The
    compositor walks layers top-to-bottom and the first layer with a non-None
    `Cell` for a position supplies both glyph and color; a layer that holds a
    space glyph (0x20) still *paints* -- it hides layers below it -- whereas a
    NULL cell is transparent.  Introducing an "empty Cell" sentinel would
    destroy that distinction, so we deliberately do not have one.
"""

from typing import NamedTuple, Optional


class Cell(NamedTuple):
    """One character cell: a CP437 glyph code and an Odyssey color byte."""

    glyph: int  # 0..255, CP437 code
    attr: int   # 0..255, color byte (blink | cursor | rgb222)


def is_control_glyph(glyph: int) -> bool:
    """True for glyph codes that collide with terminal control chars.

    CP437 codes < 0x20 and 0x7F render fine straight to VRAM but are eaten as
    control characters when an .ANS is *streamed* to the terminal, so the
    exporter warns on cells that use them.  This is the one canonical
    definition; studio.io.cp437 re-exports it.
    """
    return glyph < 0x20 or glyph == 0x7F


def cell_to_dict(cell: Optional[Cell]):
    """JSON-friendly form of a cell: `{"glyph": g, "attr": a}` or `None`."""
    if cell is None:
        return None
    return {"glyph": int(cell.glyph), "attr": int(cell.attr)}


def cell_from_dict(d) -> Optional[Cell]:
    """Inverse of `cell_to_dict`; `None` stays `None`."""
    if d is None:
        return None
    return Cell(int(d["glyph"]), int(d["attr"]))
