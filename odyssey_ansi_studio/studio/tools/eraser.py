"""Eraser: set every touched cell on the active layer back to NULL."""

from studio.tools.base import FreehandTool


class EraserTool(FreehandTool):
    key = "eraser"
    label = "Eraser"

    def _paint_cell(self, ctx, c, r):
        self._stage(c, r, None)
