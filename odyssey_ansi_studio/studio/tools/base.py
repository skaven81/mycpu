"""
Tool interface + shared staging machinery for the paint tools.

WHAT
    A `Tool` turns a press / drag / release gesture (in **document cell**
    coordinates) into edits on the document's *active* layer, routed through
    `History` so every stroke is one undoable step.

    `ToolContext` is the tool's whole view of the world: the document, the
    shared history, the current ink (glyph + color byte), and a handful of
    callbacks back into the UI (redraw, status text, "a cell was selected").
    Tools never import Qt -- the same objects drive the headless tests.

    Staging model (`_start` / `_stage` / `_revert` / `_commit`):
      * `_start`  -- snapshot the active layer + index; refuse a locked or
                     missing layer (the stroke becomes a no-op).
      * `_stage`  -- write one cell **live** into the layer and remember its
                     previous value.  Out-of-document cells are dropped.
      * `_revert` -- undo everything staged so far (shape tools call this at
                     the top of every `drag` before re-plotting; `cancel`
                     calls it too).
      * `_commit` -- push the net change as a single `CellEditCommand` via
                     `History.push_done` (the edit is already applied).

WHY
    Live staging means the canvas shows the true composite mid-stroke with no
    separate preview path.  Storing (old, new) per cell keeps undo memory
    proportional to what changed, and layer-local keys survive the layer
    being moved between the edit and the undo.
"""

from studio.model.cell import Cell
from studio.model.history import CellEditCommand

# Modifier-key bit flags (the UI maps Qt.KeyboardModifiers onto these so the
# tools stay Qt-free).
MOD_SHIFT = 1
MOD_CTRL = 2
MOD_ALT = 4


class ToolContext:
    """Everything a tool can see and touch."""

    def __init__(self, document, history, *,
                 get_glyph, get_attr,
                 set_glyph=None, set_attr=None,
                 on_change=None, on_status=None, on_select=None):
        self.document = document
        self.history = history
        self._get_glyph = get_glyph
        self._get_attr = get_attr
        self._set_glyph = set_glyph
        self._set_attr = set_attr
        self._on_change = on_change
        self._on_status = on_status
        self._on_select = on_select

    # ---- current ink ---------------------------------------------------
    @property
    def glyph(self) -> int:
        return int(self._get_glyph()) & 0xFF

    @property
    def attr(self) -> int:
        return int(self._get_attr()) & 0xFF

    def set_ink(self, *, glyph=None, attr=None):
        """Push a picked glyph / color back to the UI (eyedropper)."""
        if glyph is not None and self._set_glyph is not None:
            self._set_glyph(int(glyph) & 0xFF)
        if attr is not None and self._set_attr is not None:
            self._set_attr(int(attr) & 0xFF)

    # ---- active layer ------------------------------------------------
    def layer_index(self) -> int:
        return self.document.active_layer_index

    def active_layer(self):
        d = self.document
        i = d.active_layer_index
        if 0 <= i < len(d.layers):
            return d.layers[i]
        return None

    # ---- UI callbacks ------------------------------------------------
    def changed(self):
        """A committed edit -- redraw, mark dirty, refresh undo state."""
        if self._on_change is not None:
            self._on_change()

    def status(self, message: str):
        if self._on_status is not None:
            self._on_status(message)

    def select_cell(self, col, row):
        """Point the cell inspector at (col, row) on the active layer."""
        self.document.selection = {(col, row)}
        if self._on_select is not None:
            self._on_select(col, row)


def line_points(x0, y0, x1, y1):
    """Bresenham cell coordinates from (x0,y0) to (x1,y1), inclusive."""
    x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    out = []
    while True:
        out.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy
    return out


class Tool:
    """Base class.  Click-only tools override just `press` (+ maybe `release`)."""

    key = ""
    label = ""
    #: False for tools that resolve on press and ignore drag (fill, eyedropper).
    wants_drag = True

    def __init__(self):
        self._changes: dict = {}     # (lc, lr) -> [old_cell_or_none, new_cell_or_none]
        self._layer = None
        self._li = 0
        self._doc = None
        self._mods = 0

    # ---- gesture lifecycle (no-ops by default) --------------------------
    def press(self, ctx, col, row, mods=0):
        pass

    def drag(self, ctx, col, row, mods=0):
        pass

    def release(self, ctx, col, row, mods=0):
        pass

    def cancel(self, ctx):
        """Abort an in-progress stroke: roll back anything staged."""
        self._revert()
        ctx.changed()

    # ---- staging helpers ---------------------------------------------
    def _start(self, ctx, mods=0):
        self._changes = {}
        self._doc = ctx.document
        self._li = ctx.layer_index()
        self._mods = mods
        layer = ctx.active_layer()
        if layer is None:
            self._layer = None
            ctx.status("No active layer to draw on")
        elif layer.locked:
            self._layer = None
            ctx.status(f"Layer '{layer.name}' is locked")
        else:
            self._layer = layer

    def _stage(self, dc, dr, new_cell):
        """Set document-space cell (dc, dr) to `new_cell` (a Cell or None)."""
        layer = self._layer
        if layer is None:
            return
        if not (0 <= dc < self._doc.width and 0 <= dr < self._doc.height):
            return
        lc = dc - layer.offx
        lr = dr - layer.offy
        key = (lc, lr)
        if key not in self._changes:
            self._changes[key] = [layer.get_local(lc, lr), None]
        self._changes[key][1] = new_cell
        layer.set_local(lc, lr, new_cell)

    def _local_cell(self, dc, dr):
        """Current Cell (or None) at a document-space coord on the active layer."""
        layer = self._layer
        if layer is None:
            return None
        return layer.get_local(dc - layer.offx, dr - layer.offy)

    def _revert(self):
        layer = self._layer
        if layer is not None:
            for (lc, lr), (old, _new) in self._changes.items():
                layer.set_local(lc, lr, old)
        self._changes = {}

    def _commit(self, ctx):
        net = {k: (o, n) for k, (o, n) in self._changes.items() if o != n}
        self._changes = {}
        if net and self._layer is not None:
            ctx.history.push_done(CellEditCommand(self._li, net))
            ctx.changed()
            return True
        return False


class FreehandTool(Tool):
    """Stamp along the dragged path.  Subclasses implement `_paint_cell`."""

    def press(self, ctx, col, row, mods=0):
        self._start(ctx, mods)
        self._last = (col, row)
        self._paint_cell(ctx, col, row)

    def drag(self, ctx, col, row, mods=0):
        last = getattr(self, "_last", None)
        if last is None:
            return
        for c, r in line_points(last[0], last[1], col, row):
            self._paint_cell(ctx, c, r)
        self._last = (col, row)

    def release(self, ctx, col, row, mods=0):
        self._commit(ctx)
        self._last = None

    def _paint_cell(self, ctx, c, r):
        raise NotImplementedError


class ShapeTool(Tool):
    """Anchor on press; re-plot the whole figure on every drag."""

    def press(self, ctx, col, row, mods=0):
        self._start(ctx, mods)
        self._anchor = (col, row)
        self._plot(ctx, col, row)

    def drag(self, ctx, col, row, mods=0):
        self._mods = mods
        self._revert()
        anchor = getattr(self, "_anchor", None)
        if anchor is None:
            return
        self._plot(ctx, col, row)

    def release(self, ctx, col, row, mods=0):
        # Re-plot to the final point so a press+release with no intervening
        # drag still draws the whole figure to where the button came up.
        self._mods = mods
        self._revert()
        if getattr(self, "_anchor", None) is not None:
            self._plot(ctx, col, row)
        self._commit(ctx)
        self._anchor = None

    def _plot(self, ctx, col, row):
        raise NotImplementedError


class CellEditTool(Tool):
    """Click a cell to load it into the inspector for glyph/color editing.

    The actual edit is applied by the inspector widget (which emits a
    `CellEditCommand` through the same history); this tool only moves the
    selection.
    """

    key = "cell-edit"
    label = "Cell Edit"
    wants_drag = False

    def press(self, ctx, col, row, mods=0):
        ctx.select_cell(col, row)
