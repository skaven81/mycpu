"""Recolor: change the color byte of existing cells, keeping their glyph.

NULL cells are left NULL -- there is nothing to recolor.
"""

from studio.model.cell import Cell
from studio.tools.base import FreehandTool


class RecolorTool(FreehandTool):
    key = "recolor"
    label = "Recolor"

    def _paint_cell(self, ctx, c, r):
        cur = self._local_cell(c, r)
        if cur is None:
            return
        if cur.attr != ctx.attr:
            self._stage(c, r, Cell(cur.glyph, ctx.attr))
