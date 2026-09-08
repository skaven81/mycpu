"""Rectangle: outline by default; filled when `filled` is set or Ctrl is held."""

from studio.model.cell import Cell
from studio.tools.base import MOD_CTRL, ShapeTool


class RectTool(ShapeTool):
    key = "rectangle"
    label = "Rectangle"

    def __init__(self, filled=False):
        super().__init__()
        self.filled = filled

    def _plot(self, ctx, col, row):
        ax, ay = self._anchor
        x0, x1 = sorted((int(ax), int(col)))
        y0, y1 = sorted((int(ay), int(row)))
        fill = self.filled ^ bool(self._mods & MOD_CTRL)
        ink = Cell(ctx.glyph, ctx.attr)
        for r in range(y0, y1 + 1):
            for c in range(x0, x1 + 1):
                on_edge = c in (x0, x1) or r in (y0, y1)
                if fill or on_edge:
                    self._stage(c, r, ink)
