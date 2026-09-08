"""Eyedropper: load the composited cell under the pointer into the current ink.

Reads the *composite* (what the user sees), not just the active layer, and
makes no document change -- nothing lands in the undo history.
"""

from studio.tools.base import Tool


class EyedropperTool(Tool):
    key = "eyedropper"
    label = "Eyedropper"
    wants_drag = False

    def press(self, ctx, col, row, mods=0):
        cell = ctx.document.composite_cell(col, row)
        if cell is None:
            ctx.status(f"({col},{row}) is empty -- nothing to pick")
            return
        ctx.set_ink(glyph=cell.glyph, attr=cell.attr)
        ctx.status(f"Picked glyph 0x{cell.glyph:02X}, attr 0x{cell.attr:02X}")

    # dragging the eyedropper keeps sampling
    def drag(self, ctx, col, row, mods=0):
        self.press(ctx, col, row, mods)
