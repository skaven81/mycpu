"""
Odyssey-native `.ANS` exporter.

WHAT
    Turns a `Document` into a linear byte stream the Odyssey terminal can
    replay directly.  Color is carried by the terminal's *out-of-spec*
    ``ESC[<v>p`` escape: ``v`` is the decimal value 0..255 of one color-plane
    byte (blink bit 0x80 kept, cursor bit 0x40 masked out), written straight
    into the color plane, and it also switches the terminal into color
    rendering.  ``ESC[0p`` selects black.  (Refs: skill ``ody-io`` "Color
    Codes"; ``TERMINAL.md``.)

    The stream starts with ``ESC[H`` (cursor home).  Then, in row-major order,
    for each cell: if its ``v`` differs from the last one emitted, an
    ``ESC[<v>p`` escape is written; then the raw CP437 glyph byte.  The
    terminal is 64 columns wide and auto-wraps, so for hardware playback rows
    need no separator (``row_separator`` defaults to empty); the export dialog
    can pass ``b"\\r\\n"`` to get a padded file that also looks right when
    ``cat``ed in a normal terminal.

WHY -- "empty becomes space" here
    A `Document` layer distinguishes NULL (no contributor) from a painted
    space, but a linear character stream cannot: every screen position must
    emit exactly one glyph.  So a cell with no contributor (composite char
    byte 0x00) is exported as glyph 0x20 (space) with attr 0x00.  Trailing
    such cells are dropped when ``trim_trailing_blanks`` is set.

LOCKED DECISIONS
    * An empty document (nothing to draw) with ``trim_trailing_blanks=True``
      exports as exactly ``ESC[H`` -- no ``ESC[0p``, no glyphs.
    * ``row_separator`` is emitted after *every* emitted row, including the
      last one, so ``data.count(row_separator) == rows_emitted`` (when the
      separator is non-empty and not otherwise present in the glyph data).
    * ``trim_trailing_blanks`` trims to the last cell that is not
      (glyph == 0x20 AND attr == 0x00); wholly-blank trailing rows are then
      not emitted at all.
    * Warnings are collected over the whole composited document (a control
      glyph is never itself trimmable, so this matches the emitted region).
"""

from dataclasses import dataclass, field

from studio.model.cell import is_control_glyph
from studio.model.palette import ANSI16, attr_blink, nearest_ansi16

ESC = 0x1B
HOME = b"\x1b[H"

# Color-plane bits: keep blink (0x80), drop the editor-only cursor bit (0x40).
_CURSOR_BIT = 0x40
_EXPORT_ATTR_MASK = 0xFF & ~_CURSOR_BIT  # 0xBF

#: How a cell with no layer contributing anything is written.
NULL_MODES = ("space", "null", "block", "transparent")


def _null_pair(null_mode):
    """(glyph, attr) for an empty cell, or None for 'transparent' (skip it)."""
    if null_mode == "space":
        return (0x20, 0x00)
    if null_mode == "null":
        return (0x00, 0x00)
    if null_mode == "block":
        return (0xDB, 0x00)          # a full block tinted black
    if null_mode == "transparent":
        return None
    raise ValueError(f"unknown null_mode {null_mode!r} (want one of {NULL_MODES})")


@dataclass
class ExportResult:
    """Outcome of :func:`export_ans`.

    Fields:
        data:         the `.ANS` byte stream.
        warnings:     ``(col, row, glyph)`` for every composited cell whose
                      glyph is a terminal control code (``is_control_glyph``),
                      in row-major order.
        byte_count:   ``len(data)`` (convenience for the dialog's live count).
        rows_emitted: number of document rows that produced output (0 for an
                      empty document; 60 for a full 64x60 doc with no trim).
    """

    data: bytes
    warnings: list = field(default_factory=list)
    byte_count: int = 0
    rows_emitted: int = 0


def export_ans(doc, *, trim_trailing_blanks=True, row_separator=b"",
               null_mode="space") -> ExportResult:
    """Composite `doc` and serialize it to an Odyssey-native `.ANS` stream.

    Args:
        doc: a `studio.model.document.Document`.
        trim_trailing_blanks: drop the run of empty / space+black cells that
            follows the last real cell (and any wholly-blank trailing rows).
        row_separator: bytes emitted after every emitted row (default empty).
        null_mode: how an empty cell (no layer contributes) is written --
            ``"space"`` (0x20 black, the default), ``"null"`` (0x00 byte),
            ``"block"`` (0xDB tinted black), or ``"transparent"`` (skip it with
            a cursor-forward so whatever is already on screen shows through;
            each row is then absolutely positioned with ``ESC[<r>;1H``).

    Returns:
        An :class:`ExportResult`.
    """
    width = doc.width
    height = doc.height
    char_plane, color_plane = doc.composite()
    null_pair = _null_pair(null_mode)
    transparent = null_pair is None

    glyphs = bytearray(width * height)
    attrs = bytearray(width * height)
    empty = bytearray(width * height)   # 1 == no contributor
    warnings = []
    for row in range(height):
        base = row * width
        for col in range(width):
            off = base + col
            raw_glyph = char_plane[off]
            if raw_glyph == 0x00:
                empty[off] = 1
                if not transparent:
                    glyphs[off], attrs[off] = null_pair
                continue
            glyphs[off] = raw_glyph
            attrs[off] = color_plane[off] & _EXPORT_ATTR_MASK
            if is_control_glyph(raw_glyph):
                warnings.append((col, row, raw_glyph))

    # Last cell that is neither an empty nor a painted (0x20, 0x00) blank.
    last = -1
    for off in range(width * height - 1, -1, -1):
        if not (empty[off] or (glyphs[off] == 0x20 and attrs[off] == 0x00)):
            last = off
            break

    n_cells = (last + 1) if trim_trailing_blanks else (width * height)
    rows_emitted = (n_cells + width - 1) // width  # ceil division

    out = bytearray() if transparent else bytearray(HOME)
    current_v = None
    for row in range(rows_emitted):
        base = row * width
        if transparent:
            out += b"\x1b[" + str(row + 1).encode("ascii") + b";1H"
            current_v = None
        skip = 0
        for col in range(width):
            off = base + col
            if off >= n_cells:
                break
            if transparent and empty[off]:
                skip += 1
                continue
            if skip:
                out += b"\x1b[" + str(skip).encode("ascii") + b"C"
                skip = 0
                current_v = None       # cursor jumped; re-assert color
            v = attrs[off]
            if v != current_v:
                out += b"\x1b[" + str(v).encode("ascii") + b"p"
                current_v = v
            out.append(glyphs[off])
        out += row_separator

    data = bytes(out)
    return ExportResult(
        data=data,
        warnings=warnings,
        byte_count=len(data),
        rows_emitted=rows_emitted,
    )


def export_ans16(doc, *, trim_trailing_blanks=True, row_separator=b"\r\n",
                 null_mode="space") -> ExportResult:
    """Portable 16-color `.ANS`: standard SGR codes, no `ESC[<v>p`.

    Every cell's color is snapped to the nearest of the 16 ANSI colors
    (`nearest_ansi16`) and emitted as ``ESC[0m ESC[<sgr>m`` (plus ``ESC[5m``
    for blink).  `null_mode` matches :func:`export_ans` ("space" / "null" /
    "block" / "transparent").
    """
    width, height = doc.width, doc.height
    char_plane, color_plane = doc.composite()
    null_pair = _null_pair(null_mode)
    transparent = null_pair is None

    glyphs = bytearray(width * height)
    styles = [None] * (width * height)   # (sgr, blink) per cell; None == blank
    empty = bytearray(width * height)
    warnings = []
    for row in range(height):
        base = row * width
        for col in range(width):
            off = base + col
            g = char_plane[off]
            if g == 0x00:
                empty[off] = 1
                if not transparent:
                    glyphs[off] = null_pair[0]
                    if null_pair[0] != 0x20:
                        styles[off] = (30, False)   # SGR 30 == black
                continue
            glyphs[off] = g
            attr = color_plane[off]
            snap = nearest_ansi16(attr)
            styles[off] = (ANSI16[snap & 0x3F][0], bool(attr_blink(attr)))
            if is_control_glyph(g):
                warnings.append((col, row, g))

    last = -1
    for off in range(width * height - 1, -1, -1):
        if not (empty[off] or (glyphs[off] == 0x20 and styles[off] is None)):
            last = off
            break
    n_cells = (last + 1) if trim_trailing_blanks else width * height
    rows_emitted = (n_cells + width - 1) // width

    out = bytearray() if transparent else bytearray(HOME)
    current = object()
    for row in range(rows_emitted):
        base = row * width
        if transparent:
            out += b"\x1b[" + str(row + 1).encode("ascii") + b";1H"
            current = object()
        skip = 0
        for col in range(width):
            off = base + col
            if off >= n_cells:
                break
            if transparent and empty[off]:
                skip += 1
                continue
            if skip:
                out += b"\x1b[" + str(skip).encode("ascii") + b"C"
                skip = 0
                current = object()
            st = styles[off]
            if st != current:
                if st is None:
                    out += b"\x1b[0m"
                else:
                    sgr, blink = st
                    out += b"\x1b[0m\x1b[" + str(sgr).encode("ascii") + b"m"
                    if blink:
                        out += b"\x1b[5m"
                current = st
            out.append(glyphs[off])
        out += row_separator

    data = bytes(out)
    return ExportResult(data=data, warnings=warnings,
                        byte_count=len(data), rows_emitted=rows_emitted)


def ansi_preview_text(result: ExportResult) -> str:
    """The stream as text for a read-only preview pane.

    Decoded latin-1 (every byte maps to one char) with the ESC byte shown as
    the visible symbol ``U+241B`` so escapes are readable.
    """
    return result.data.decode("latin-1").replace("\x1b", "␛")
