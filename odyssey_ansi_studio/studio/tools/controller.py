"""
`ToolController` -- routes press / drag / release to the active `Tool`.

It owns exactly one piece of state: whether a stroke is in progress.  On a
tool switch (or explicit `cancel`) mid-stroke it rolls the current tool back
so a half-drawn shape never leaks into the document.  Coordinates are already
document cell coordinates by the time they reach here; the canvas does the
pixel maths.
"""


class ToolController:
    def __init__(self, ctx, tool=None):
        self.ctx = ctx
        self.tool = tool
        self._active = False

    def set_tool(self, tool):
        if self._active and self.tool is not None:
            self.tool.cancel(self.ctx)
        self._active = False
        self.tool = tool

    def press(self, col, row, mods=0):
        if self.tool is None:
            return
        if self._active:
            self.tool.cancel(self.ctx)
        self._active = True
        self.tool.press(self.ctx, col, row, mods)

    def drag(self, col, row, mods=0):
        if self.tool is None or not self._active:
            return
        self.tool.drag(self.ctx, col, row, mods)

    def release(self, col, row, mods=0):
        if self.tool is None or not self._active:
            return
        self.tool.release(self.ctx, col, row, mods)
        self._active = False

    def cancel(self):
        if self.tool is not None and self._active:
            self.tool.cancel(self.ctx)
        self._active = False

    @property
    def is_active(self) -> bool:
        return self._active
