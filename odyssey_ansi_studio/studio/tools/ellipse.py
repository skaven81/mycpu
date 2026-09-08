"""Ellipse: inscribed in the press-anchor -> pointer bounding box.

Outline by default; filled when `filled` is set or Ctrl is held.  Cell grids
are coarse, so this uses a straightforward "test every cell center against the
ellipse equation" rasterizer and then, for the outline, keeps the first/last
lit cell of every row *and* every column so the figure always closes.
"""

from studio.model.cell import Cell
from studio.tools.base import MOD_CTRL, ShapeTool


def ellipse_cells(x0, y0, x1, y1, filled=False):
    x0, x1 = sorted((int(x0), int(x1)))
    y0, y1 = sorted((int(y0), int(y1)))
    cx = (x0 + x1) / 2.0
    cy = (y0 + y1) / 2.0
    rx = max((x1 - x0) / 2.0, 0.5)
    ry = max((y1 - y0) / 2.0, 0.5)

    inside_by_row = {}
    for r in range(y0, y1 + 1):
        cols = []
        for c in range(x0, x1 + 1):
            nx = (c - cx) / rx
            ny = (r - cy) / ry
            if nx * nx + ny * ny <= 1.0 + 1e-9:
                cols.append(c)
        if cols:
            inside_by_row[r] = cols

    if filled:
        out = set()
        for r, cols in inside_by_row.items():
            for c in range(min(cols), max(cols) + 1):
                out.add((c, r))
        return out

    out = set()
    for r, cols in inside_by_row.items():
        out.add((min(cols), r))
        out.add((max(cols), r))
    inside_by_col = {}
    for r, cols in inside_by_row.items():
        for c in cols:
            inside_by_col.setdefault(c, []).append(r)
    for c, rows in inside_by_col.items():
        out.add((c, min(rows)))
        out.add((c, max(rows)))
    return out


class EllipseTool(ShapeTool):
    key = "ellipse"
    label = "Ellipse"

    def __init__(self, filled=False):
        super().__init__()
        self.filled = filled

    def _plot(self, ctx, col, row):
        ax, ay = self._anchor
        fill = self.filled ^ bool(self._mods & MOD_CTRL)
        ink = Cell(ctx.glyph, ctx.attr)
        for c, r in ellipse_cells(ax, ay, col, row, filled=fill):
            self._stage(c, r, ink)
