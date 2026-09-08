"""Pencil: stamp the current glyph + ink along the drag."""

from studio.model.cell import Cell
from studio.tools.base import FreehandTool


class PencilTool(FreehandTool):
    key = "pencil"
    label = "Pencil"

    def _paint_cell(self, ctx, c, r):
        self._stage(c, r, Cell(ctx.glyph, ctx.attr))
