"""Flood fill: 4-connected paint-bucket over the *active layer's* own cells.

The match key is the whole `(glyph, attr)` pair (or `None` for an empty cell),
so filling an empty region and filling a solid region both work.  The walk is
bounded to the document rectangle -- filling empty space fills the visible
canvas, not infinity.  Adapted from `os/bootbanner/gen.py:flood_outside`.
"""

from studio.model.cell import Cell
from studio.tools.base import Tool


def _key(cell):
    return None if cell is None else (cell.glyph, cell.attr)


class FillTool(Tool):
    key = "flood-fill"
    label = "Flood Fill"
    wants_drag = False

    def press(self, ctx, col, row, mods=0):
        self._start(ctx, mods)
        layer = self._layer
        if layer is None:
            return
        doc = ctx.document
        w, h = doc.width, doc.height
        new_cell = Cell(ctx.glyph, ctx.attr)
        target = _key(self._local_cell(col, row))
        if target == _key(new_cell):
            ctx.status("Flood fill: already that glyph/color")
            return

        seen = set()
        stack = [(int(col), int(row))]
        while stack:
            dc, dr = stack.pop()
            if (dc, dr) in seen:
                continue
            if not (0 <= dc < w and 0 <= dr < h):
                continue
            seen.add((dc, dr))
            if _key(self._local_cell(dc, dr)) != target:
                continue
            self._stage(dc, dr, new_cell)
            stack.extend(((dc + 1, dr), (dc - 1, dr),
                          (dc, dr + 1), (dc, dr - 1)))

    def release(self, ctx, col, row, mods=0):
        self._commit(ctx)
