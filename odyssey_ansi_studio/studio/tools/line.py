"""Line: Bresenham segment from the press anchor to the pointer."""

from studio.model.cell import Cell
from studio.tools.base import ShapeTool, line_points


class LineTool(ShapeTool):
    key = "line"
    label = "Line"

    def _plot(self, ctx, col, row):
        ax, ay = self._anchor
        ink = Cell(ctx.glyph, ctx.attr)
        for c, r in line_points(ax, ay, col, row):
            self._stage(c, r, ink)
