"""
Layers -- the sparse, offset cell grids that stack to make a document.

WHAT
    A `Layer` holds:
      * metadata: `name`, `visible`, `locked`, `kind`
      * an integer origin offset `(offx, offy)` in document cells
      * `cells`: a sparse `dict[(col, row) -> Cell]` in **layer-local**
        coordinates.  NULL cells are simply absent from the dict.

    Two coordinate spaces meet here:
      * layer-local -- what `cells` is keyed by, what the paint tools and
        `CellEditCommand` operate in (`get_local` / `set_local`).
      * document-space -- local + offset; what the compositor and canvas use
        (`get` / `set` / `iter_cells`).

    Subclasses `BlankLayer`, `BoxLayer`, `TextLayer`, `ImageLayer` differ only
    by `kind` and by the extra parameters they carry for later phases to
    re-rasterize from (a box's style, a text window's text+rect, an image
    layer's source reference).  The rasterization itself is a later phase; the
    cell grid is always the source of truth for compositing.

WHY
    Layers never interact -- no blending, no per-layer color.  Keeping the
    grid sparse and the offset separate makes "move this whole box 3 cells
    right" an O(1) metadata change instead of a rewrite, and makes "is this
    cell empty or a painted space?" a simple `in` check.
"""

from typing import Optional

from studio.model.cell import Cell
from studio.model.rasterize import (
    BOX_DEFAULTS, TEXT_DEFAULTS, rasterize_box, rasterize_text,
)


class Layer:
    """Base layer: sparse local cell grid + document-space offset + flags."""

    kind = "blank"

    def __init__(self, name="Layer", visible=True, locked=False, offx=0, offy=0,
                 group=None):
        self.name = name
        self.visible = visible
        self.locked = locked
        self.offx = int(offx)
        self.offy = int(offy)
        # Optional group name (a plain string key into Document.groups); groups
        # are a display + visibility convenience, they do not nest the stack.
        self.group = group
        # (col, row) in LAYER-LOCAL coords -> Cell.  NULL cells absent.
        self.cells: dict = {}

    # --- layer-local access (paint tools / history commands) --------------

    def get_local(self, lc, lr) -> Optional[Cell]:
        """Cell at a layer-local coordinate, or None."""
        return self.cells.get((lc, lr))

    def set_local(self, lc, lr, cell_or_none):
        """Set / clear a cell at a layer-local coordinate (None clears)."""
        if cell_or_none is None:
            self.cells.pop((lc, lr), None)
        else:
            self.cells[(lc, lr)] = cell_or_none

    # --- document-space access (compositor / canvas) --------------------

    def get(self, col, row) -> Optional[Cell]:
        """Cell at a document-space coordinate, or None."""
        return self.get_local(col - self.offx, row - self.offy)

    def set(self, col, row, cell_or_none):
        """Set / clear a cell at a document-space coordinate (None clears)."""
        self.set_local(col - self.offx, row - self.offy, cell_or_none)

    def clear(self):
        """Drop every cell (the layer becomes fully NULL)."""
        self.cells.clear()

    def iter_cells(self):
        """Yield (doc_col, doc_row, Cell) for every non-NULL cell."""
        ox, oy = self.offx, self.offy
        for (lc, lr), cell in self.cells.items():
            yield lc + ox, lr + oy, cell

    def bbox(self):
        """Bounding box of the non-NULL cells in **document space**.

        Returns (min_col, min_row, max_col, max_row) inclusive, or None when
        the layer is empty.
        """
        if not self.cells:
            return None
        cols = [lc for (lc, _lr) in self.cells]
        rows = [lr for (_lc, lr) in self.cells]
        return (min(cols) + self.offx, min(rows) + self.offy,
                max(cols) + self.offx, max(rows) + self.offy)

    def translate(self, dx, dy):
        """Shift the whole layer by (dx, dy) document cells (adjusts offset)."""
        self.offx += int(dx)
        self.offy += int(dy)

    # --- editable frame (canvas bounding box + resize handles) ------------

    def frame(self):
        """The layer's rectangle in **document cells** as ``(col, row, w, h)``,
        or ``None`` when it has no defined extent (an empty blank layer).

        The base layer has no intrinsic size, so it reports the bounding box
        of its painted cells.
        """
        bb = self.bbox()
        if bb is None:
            return None
        min_c, min_r, max_c, max_r = bb
        return (min_c, min_r, max_c - min_c + 1, max_r - min_r + 1)

    def resizable(self) -> bool:
        """True when :meth:`set_frame` can change this layer's width/height
        (as opposed to only moving it)."""
        return False

    def set_frame(self, col, row, w=None, h=None):
        """Place the layer so its frame's top-left sits at ``(col, row)``.

        The base layer cannot change size, so ``w`` / ``h`` are ignored and the
        painted cells are simply translated.
        """
        bb = self.bbox()
        if bb is None:
            self.offx, self.offy = int(col), int(row)
        else:
            self.offx += int(col) - bb[0]
            self.offy += int(row) - bb[1]

    def copy(self) -> "Layer":
        """A deep, independent copy (round-trips through the dict form)."""
        return layer_from_dict(self.to_dict())

    # --- serialization --------------------------------------------------

    def _params_to_dict(self) -> dict:
        """Subclass hook: extra kind-specific parameters. Base has none."""
        return {}

    def _params_from_dict(self, d) -> None:
        """Subclass hook: load extra kind-specific parameters. Base: no-op."""

    def to_dict(self) -> dict:
        """Full JSON-serializable form.

        `cells` is a list of `[local_col, local_row, glyph, attr]`, sorted for
        deterministic output.
        """
        return {
            "kind": self.kind,
            "name": self.name,
            "visible": self.visible,
            "locked": self.locked,
            "offx": self.offx,
            "offy": self.offy,
            "group": self.group,
            "params": self._params_to_dict(),
            "cells": [
                [lc, lr, int(cell.glyph), int(cell.attr)]
                for (lc, lr), cell in sorted(self.cells.items())
            ],
        }

    @classmethod
    def from_dict(cls, d) -> "Layer":
        """Rebuild a layer of *this class* from `to_dict` output.

        Use the module-level `layer_from_dict` when you need kind dispatch.
        """
        layer = cls(
            name=d.get("name", "Layer"),
            visible=d.get("visible", True),
            locked=d.get("locked", False),
            offx=d.get("offx", 0),
            offy=d.get("offy", 0),
            group=d.get("group"),
        )
        for lc, lr, glyph, attr in d.get("cells", []):
            layer.cells[(lc, lr)] = Cell(int(glyph), int(attr))
        layer._params_from_dict(d.get("params", {}))
        return layer


class BlankLayer(Layer):
    """A plain drawing layer -- all NULL until something paints on it."""

    kind = "blank"


class GeneratedLayer(Layer):
    """Base for layers whose `cells` are a *cache* of a parameter dict.

    `regenerate()` overwrites `cells` from the parameters and snapshots the
    result; `manual_edits()` is true once the cells drift from that snapshot
    (the UI warns before a re-rasterize would discard hand edits).  Layers
    stay mutable forever: change the params, `regenerate()`, done.
    """

    _defaults: dict = {}

    def _rasterize(self) -> dict:
        raise NotImplementedError

    def regenerate(self) -> dict:
        self.cells = dict(self._rasterize())
        self._raster_cache = dict(self.cells)
        return self.cells

    def manual_edits(self) -> bool:
        ref = getattr(self, "_raster_cache", None)
        if ref is None:
            ref = self._rasterize()
        return self.cells != ref

    def set_params(self, **kw):
        self.params.update(kw)

    def resize(self, w, h):
        self.params["w"] = max(int(w), 1)
        self.params["h"] = max(int(h), 1)

    # ---- editable frame -------------------------------------------------

    def _wh(self):
        """This layer's (w, h) in cells from whichever param pair it uses."""
        w = int(self.params.get("w") or self.params.get("cols") or 0)
        h = int(self.params.get("h") or self.params.get("rows") or 0)
        return w, h

    def _set_wh(self, w, h):
        self.resize(w, h)

    def frame(self):
        w, h = self._wh()
        if w and h:
            return (self.offx, self.offy, w, h)
        return super().frame()

    def resizable(self) -> bool:
        return any(self._wh())

    def set_frame(self, col, row, w=None, h=None):
        self.offx, self.offy = int(col), int(row)
        if w is not None and h is not None:
            self._set_wh(max(int(w), 1), max(int(h), 1))
        self.regenerate()

    @classmethod
    def from_dict(cls, d) -> "Layer":
        layer = super().from_dict(d)
        # A snapshot of what the params *would* draw, so a load-then-diverge
        # is still detected as a hand edit.
        layer._raster_cache = dict(layer._rasterize())
        return layer


class BoxLayer(GeneratedLayer):
    """A framed-box layer: border glyphs from a style set, optional styled
    title / footer, interior fill, and a drop shadow -- all from `params`."""

    kind = "box"
    _defaults = BOX_DEFAULTS

    def __init__(self, *args, params=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.params: dict = {**BOX_DEFAULTS, **(dict(params) if params else {})}
        self._raster_cache = None

    def _params_to_dict(self):
        return dict(self.params)

    def _params_from_dict(self, d):
        self.params = {**BOX_DEFAULTS, **(dict(d) if d else {})}

    def _rasterize(self):
        return rasterize_box(self.params)


class TextLayer(GeneratedLayer):
    """A text-window layer: multi-line text, word-wrapped and aligned inside a
    `w` x `h` window, re-rasterized from `params` on every edit.

    `text` and `rect` stay available as attributes for older call sites; both
    are views onto `params`.
    """

    kind = "text"
    _defaults = TEXT_DEFAULTS

    def __init__(self, *args, text="", rect=None, params=None, **kwargs):
        super().__init__(*args, **kwargs)
        p = {**TEXT_DEFAULTS, **(dict(params) if params else {})}
        if text:
            p["text"] = text
        if rect:
            p["rect"] = list(rect)
            p["w"], p["h"] = int(rect[2]), int(rect[3])
        self.params: dict = p
        self._raster_cache = None

    # --- legacy attribute views ---------------------------------------
    @property
    def text(self):
        return self.params.get("text", "")

    @text.setter
    def text(self, value):
        self.params["text"] = value

    @property
    def rect(self):
        r = self.params.get("rect")
        return tuple(r) if r else None

    @rect.setter
    def rect(self, value):
        if value:
            self.params["rect"] = list(value)
            self.params["w"], self.params["h"] = int(value[2]), int(value[3])
        else:
            self.params.pop("rect", None)

    def _params_to_dict(self):
        return dict(self.params)

    def _params_from_dict(self, d):
        self.params = {**TEXT_DEFAULTS, **(dict(d) if d else {})}

    def _rasterize(self):
        p = dict(self.params)
        r = p.get("rect")
        if r:
            p["w"], p["h"] = int(r[2]), int(r[3])
        return rasterize_text(p)

    def resize(self, w, h):
        super().resize(w, h)
        r = self.params.get("rect")
        if r:
            self.params["rect"] = [r[0], r[1], self.params["w"], self.params["h"]]


class ImageLayer(GeneratedLayer):
    """An imported-image layer.

    `source_ref` keys the original PNG in the project's ``assets/`` bundle;
    `params` is an `ImportParams` dict (crop, target cols/rows, mode).  The
    source pixels are re-attached after load (`attach_source`); with them the
    layer re-quantises on any param change like any other generated layer.
    Without them (`source_ref` present but the asset missing) the cached cells
    are kept as-is.
    """

    kind = "image"

    def __init__(self, *args, source_ref=None, params=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.source_ref = source_ref
        self.params: dict = dict(params) if params else {}
        self._raster_cache = None
        self._source_img = None       # PIL.Image (RGB), not serialized
        self._source_bytes = None     # PNG bytes for the asset bundle

    def _params_to_dict(self):
        return {"source_ref": self.source_ref, "params": dict(self.params)}

    def _params_from_dict(self, d):
        d = d or {}
        self.source_ref = d.get("source_ref")
        self.params = dict(d.get("params", {}))

    def attach_source(self, blob=None, image=None):
        """Give the layer its source pixels (PNG `blob` and/or a PIL `image`)."""
        from studio.convert.image_import import image_from_bytes, png_bytes, source_ref
        if blob is not None:
            self._source_bytes = blob
            self._source_img = image_from_bytes(blob)
        elif image is not None:
            self._source_img = image.convert("RGB")
            self._source_bytes = png_bytes(self._source_img)
        if self._source_bytes is not None:
            self.source_ref = source_ref(self._source_bytes)

    def has_source(self) -> bool:
        return self._source_img is not None

    def _set_wh(self, w, h):
        self.params["cols"] = max(int(w), 1)
        self.params["rows"] = max(int(h), 1)

    def resize(self, w, h):
        self._set_wh(w, h)

    def _rasterize(self):
        if self._source_img is None:
            return dict(self.cells)   # no pixels -> keep whatever we have
        from studio.convert.image_import import ImportParams, convert
        return convert(self._source_img, ImportParams.from_dict(self.params))


_LAYER_CLASSES = {
    "blank": BlankLayer,
    "box": BoxLayer,
    "text": TextLayer,
    "image": ImageLayer,
}


def layer_from_dict(d) -> Layer:
    """Factory: build the right Layer subclass from a `to_dict` mapping.

    Unknown `kind` falls back to `BlankLayer` so an unrecognised layer keeps
    its cell data rather than being dropped.
    """
    cls = _LAYER_CLASSES.get(d.get("kind", "blank"), BlankLayer)
    return cls.from_dict(d)
