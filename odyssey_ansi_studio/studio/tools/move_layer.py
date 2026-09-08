"""Move Layer: drag on the canvas to shift the whole active layer's origin.

Cell data never changes -- only the layer's ``(offx, offy)``.  The drag moves
the layer live; the release records one `TranslateLayerCommand` for the net
delta so undo puts it back in a single step.
"""

from studio.model.history import TranslateLayerCommand
from studio.tools.base import Tool


class MoveLayerTool(Tool):
    key = "move-layer"
    label = "Move Layer"

    def __init__(self):
        super().__init__()
        self._anchor = (0, 0)
        self._acc = (0, 0)

    def press(self, ctx, col, row, mods=0):
        self._li = ctx.layer_index()
        self._anchor = (col, row)
        self._acc = (0, 0)
        layer = ctx.active_layer()
        if layer is None or layer.locked:
            self._layer = None
            ctx.status("No movable layer (none active or locked)")
        else:
            self._layer = layer

    def drag(self, ctx, col, row, mods=0):
        if self._layer is None:
            return
        ax, ay = self._anchor
        want = (col - ax, row - ay)
        self._layer.offx += want[0] - self._acc[0]
        self._layer.offy += want[1] - self._acc[1]
        self._acc = want
        ctx.changed()

    def release(self, ctx, col, row, mods=0):
        self.drag(ctx, col, row, mods)
        if self._layer is not None and self._acc != (0, 0):
            ctx.history.push_done(
                TranslateLayerCommand(self._li, self._acc[0], self._acc[1]))
            ctx.changed()
        self._layer = None

    def cancel(self, ctx):
        if getattr(self, "_layer", None) is not None and self._acc != (0, 0):
            self._layer.offx -= self._acc[0]
            self._layer.offy -= self._acc[1]
            ctx.changed()
        self._layer = None
