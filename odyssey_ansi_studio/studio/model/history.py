"""
Undo / redo -- a small command-pattern stack.

WHAT
    A `Command` knows how to `do(doc)` and `undo(doc)` itself.  `History`
    keeps an undo stack and a redo stack: `push(cmd)` runs the command and
    clears the redo stack; `undo()` / `redo()` walk between them.  An optional
    depth cap (default 200) drops the oldest undo entries.

    `CellEditCommand(layer_index, changes)` is the concrete command the paint
    tools (Phase 3) emit.  `changes` maps a **layer-local** `(col, row)` to a
    `(old_cell_or_none, new_cell_or_none)` pair, so one brush stroke that
    touches many cells is a single undoable step.

WHY
    Storing an explicit old/new pair per cell (rather than a snapshot of the
    layer) keeps memory proportional to what actually changed and makes
    redo a trivial re-apply.  Commands operate in layer-local coords because
    that is what survives a layer being moved between the edit and the undo.
"""

from studio.model.cell import Cell

DEFAULT_DEPTH = 200


class Command:
    """Base class: subclasses implement `do` and `undo`."""

    def do(self, doc) -> None:
        raise NotImplementedError

    def undo(self, doc) -> None:
        raise NotImplementedError


class CellEditCommand(Command):
    """Set a batch of cells on one layer, in layer-local coordinates.

    `changes`: `{(local_col, local_row): (old_cell_or_none, new_cell_or_none)}`.
    """

    def __init__(self, layer_index: int, changes: dict):
        self.layer_index = layer_index
        # Copy so a caller mutating its dict afterwards can't corrupt history.
        self.changes = dict(changes)

    def _apply(self, doc, pick_new: bool):
        layer = doc.layers[self.layer_index]
        for (lc, lr), (old, new) in self.changes.items():
            layer.set_local(lc, lr, new if pick_new else old)

    def do(self, doc):
        self._apply(doc, pick_new=True)

    def undo(self, doc):
        self._apply(doc, pick_new=False)


class TranslateLayerCommand(Command):
    """Shift one layer's origin by (dx, dy) document cells."""

    def __init__(self, layer_index: int, dx: int, dy: int):
        self.layer_index = layer_index
        self.dx = int(dx)
        self.dy = int(dy)

    def do(self, doc):
        layer = doc.layers[self.layer_index]
        layer.offx += self.dx
        layer.offy += self.dy

    def undo(self, doc):
        layer = doc.layers[self.layer_index]
        layer.offx -= self.dx
        layer.offy -= self.dy


class ReshapeLayerCommand(Command):
    """Restore a layer's frame -- its origin and (for a generated layer) its
    width/height, regenerating its cells.

    ``before`` / ``after`` are ``(col, row, w, h)`` tuples as returned by
    ``Layer.frame()``.  Used by the canvas resize handles; the drag applies
    the change live, so this is recorded with ``History.push_done``.
    """

    def __init__(self, layer_index: int, before, after):
        self.layer_index = layer_index
        self.before = tuple(before)
        self.after = tuple(after)

    def _apply(self, doc, frame):
        doc.layers[self.layer_index].set_frame(*frame)

    def do(self, doc):
        self._apply(doc, self.after)

    def undo(self, doc):
        self._apply(doc, self.before)


class History:
    """An undo/redo stack bound (optionally) to one document."""

    def __init__(self, doc=None, depth: int = DEFAULT_DEPTH):
        self.doc = doc
        self.depth = depth
        self._undo: list[Command] = []
        self._redo: list[Command] = []

    def _target(self, doc):
        target = doc if doc is not None else self.doc
        if target is None:
            raise ValueError("History has no document: pass one to __init__ or the call")
        return target

    def push(self, cmd: Command, doc=None):
        """Execute `cmd`, record it for undo, and clear the redo stack."""
        target = self._target(doc)
        cmd.do(target)
        self._record(cmd)

    def push_done(self, cmd: Command):
        """Record a command whose effect is **already applied** to the document.

        Interactive paint tools mutate the layer live while the user drags, so
        by the time the stroke ends the change is done.  `undo()` still reverses
        it and `redo()` re-applies it.
        """
        self._record(cmd)

    def _record(self, cmd: Command):
        self._undo.append(cmd)
        self._redo.clear()
        if self.depth and len(self._undo) > self.depth:
            # Drop the oldest entries; they become permanent.
            del self._undo[: len(self._undo) - self.depth]

    def undo(self, doc=None) -> bool:
        """Undo the most recent command.  Returns False if nothing to undo."""
        if not self._undo:
            return False
        target = self._target(doc)
        cmd = self._undo.pop()
        cmd.undo(target)
        self._redo.append(cmd)
        return True

    def redo(self, doc=None) -> bool:
        """Re-apply the most recently undone command.  False if none."""
        if not self._redo:
            return False
        target = self._target(doc)
        cmd = self._redo.pop()
        cmd.do(target)
        self._undo.append(cmd)
        return True

    def can_undo(self) -> bool:
        return bool(self._undo)

    def can_redo(self) -> bool:
        return bool(self._redo)

    def clear(self):
        """Forget all history."""
        self._undo.clear()
        self._redo.clear()
