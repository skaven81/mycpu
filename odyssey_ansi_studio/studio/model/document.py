"""
`Document` -- an ordered stack of layers plus compositing to VRAM planes.

WHAT
    A document is a fixed 64x60 cell canvas (`WIDTH` x `HEIGHT`, plane size
    3840 bytes), a `font_bank` selector, an ordered `layers` list (index 0 =
    bottom, last = top), a `project_palette` of named colors, an
    `active_layer_index`, and an ephemeral `selection`.

    `composite()` renders the stack to the two byte planes the Odyssey blits
    straight to VRAM: the character plane (0x4000) and the color plane
    (0x5000), each `width * height` bytes, row-major (`off = row*width + col`).
    For each cell it walks layers **top -> bottom**; the first *visible* layer
    with a non-NULL `Cell` there supplies BOTH glyph and attr.  A cell no
    layer contributes to is char 0x00 / color 0x00.

WHY
    This is the whole point of the editor: layers are authored independently
    and flattened only here.  `merge_down` and `flatten` bake layers together
    when the user is done with them; `to_dict` / `from_dict` are the
    schema-versioned project form the .oas container (Phase 2) will wrap.
"""

import json

from studio.model.cell import Cell
from studio.model.layers import BlankLayer, Layer, layer_from_dict

WIDTH = 64
HEIGHT = 60

# Aliases -- some call sites read better as "display" dimensions.
DISPLAY_W = WIDTH
DISPLAY_H = HEIGHT

# Bytes in one VRAM plane (char plane 0x4000..0x4EFF, color plane 0x5000..).
PLANE_SIZE = WIDTH * HEIGHT  # 3840

SCHEMA_VERSION = 1


class Document:
    """A layered Odyssey text-mode picture."""

    def __init__(self, width=WIDTH, height=HEIGHT, font_bank=0):
        self.width = int(width)
        self.height = int(height)
        self.font_bank = int(font_bank)
        self.layers: list[Layer] = []
        # Each entry: {"name": str, "attr": int}
        self.project_palette: list[dict] = []
        # {group_name: {"visible": bool, "collapsed": bool}}.  A layer whose
        # `.group` names a hidden group is skipped by the compositor; collapse
        # is a panel-only display state.
        self.groups: dict = {}
        self.active_layer_index = 0
        # Ephemeral, not serialized: a set of (col, row) cells.
        self.selection: set = set()

    # --- layer groups (display + visibility only) --------------------

    def group_visible(self, layer) -> bool:
        """False iff `layer` is in a group that is currently hidden."""
        g = getattr(layer, "group", None)
        if g is None:
            return True
        return bool(self.groups.get(g, {}).get("visible", True))

    def _layer_drawn(self, layer) -> bool:
        return layer.visible and self.group_visible(layer)

    def ensure_group(self, name):
        self.groups.setdefault(name, {"visible": True, "collapsed": False})

    def set_layer_group(self, index, name):
        """Tag layer `index` with group `name` (or None to ungroup)."""
        self.layers[index].group = name
        if name:
            self.ensure_group(name)
        self._prune_groups()

    def set_group_visible(self, name, on):
        self.ensure_group(name)
        self.groups[name]["visible"] = bool(on)

    def set_group_collapsed(self, name, on):
        self.ensure_group(name)
        self.groups[name]["collapsed"] = bool(on)

    def rename_group(self, old, new):
        if not new or old == new:
            return
        for layer in self.layers:
            if getattr(layer, "group", None) == old:
                layer.group = new
        self.groups[new] = self.groups.pop(old, {"visible": True, "collapsed": False})

    def group_layers(self, name):
        return [i for i, ly in enumerate(self.layers)
                if getattr(ly, "group", None) == name]

    def _prune_groups(self):
        live = {getattr(ly, "group", None) for ly in self.layers} - {None}
        self.groups = {k: v for k, v in self.groups.items() if k in live}

    # --- compositing --------------------------------------------------

    def composite_cell(self, col, row):
        """The single composited `Cell` at (col, row) in document space, or None.

        Walks layers top -> bottom; first visible layer with a non-NULL cell
        wins.
        """
        for layer in reversed(self.layers):
            if not self._layer_drawn(layer):
                continue
            cell = layer.get(col, row)
            if cell is not None:
                return cell
        return None

    def composite(self):
        """Render to `(char_plane, color_plane)` -- two `width*height` byte strings.

        Row-major, `off = row*width + col`.  Cells with no contributor are
        0x00 in both planes.
        """
        n = self.width * self.height
        char_plane = bytearray(n)
        color_plane = bytearray(n)
        filled = bytearray(n)  # 1 once a higher layer has claimed the cell

        # Top layer first so "first writer wins" == "topmost visible wins".
        for layer in reversed(self.layers):
            if not self._layer_drawn(layer):
                continue
            for dc, dr, cell in layer.iter_cells():
                if 0 <= dc < self.width and 0 <= dr < self.height:
                    off = dr * self.width + dc
                    if not filled[off]:
                        filled[off] = 1
                        char_plane[off] = cell.glyph & 0xFF
                        color_plane[off] = cell.attr & 0xFF
        return bytes(char_plane), bytes(color_plane)

    # --- layer stack management -------------------------------------

    def add_layer(self, layer, at=None):
        """Insert `layer` (default: on top) and make it the active layer."""
        if at is None:
            self.layers.append(layer)
            self.active_layer_index = len(self.layers) - 1
        else:
            self.layers.insert(at, layer)
            self.active_layer_index = at
        return layer

    def remove_layer(self, i):
        """Delete layer `i`, clamping the active index to a valid layer."""
        del self.layers[i]
        if self.active_layer_index >= len(self.layers):
            self.active_layer_index = max(0, len(self.layers) - 1)
        self._prune_groups()

    def move_layer(self, i, to):
        """Move layer `i` to index `to` (reorders the stack)."""
        layer = self.layers.pop(i)
        self.layers.insert(to, layer)
        self.active_layer_index = to

    def merge_down(self, i):
        """Merge layer `i` down onto layer `i-1`, then drop layer `i`.

        Every cell layer `i` contributes is written into layer `i-1` (both
        offsets respected; the result is stored in `i-1`'s local coords), so
        on any conflict the upper layer's cell wins.  Layer `i-1` keeps its
        own name and flags.

        NOTE: this merges raw cell data regardless of `visible`.  The
        composite is unchanged only when both layers were visible.
        """
        if i <= 0 or i >= len(self.layers):
            raise IndexError("merge_down requires 1 <= i < len(layers)")
        upper = self.layers[i]
        lower = self.layers[i - 1]
        for dc, dr, cell in upper.iter_cells():
            lower.set(dc, dr, cell)
        del self.layers[i]
        if self.active_layer_index >= len(self.layers):
            self.active_layer_index = len(self.layers) - 1
        self._prune_groups()

    def flatten(self):
        """Replace the whole stack with one `BlankLayer` holding the composite.

        Only cells that have a contributor are written; NULL stays NULL.
        Returns the new layer.
        """
        flat = BlankLayer(name="Flattened")
        for row in range(self.height):
            for col in range(self.width):
                cell = self.composite_cell(col, row)
                if cell is not None:
                    flat.cells[(col, row)] = cell
        self.layers = [flat]
        self.active_layer_index = 0
        self.groups = {}
        return flat

    # --- serialization --------------------------------------------------

    def to_dict(self):
        """Schema-versioned dict form (the .oas `document.json` payload)."""
        return {
            "schema": SCHEMA_VERSION,
            "width": self.width,
            "height": self.height,
            "font_bank": self.font_bank,
            "active_layer_index": self.active_layer_index,
            "project_palette": [dict(e) for e in self.project_palette],
            "groups": {k: dict(v) for k, v in self.groups.items()},
            "layers": [layer.to_dict() for layer in self.layers],
        }

    @classmethod
    def from_dict(cls, d):
        """Inverse of `to_dict`.  Raises `ValueError` if `d` is not a mapping
        or carries an unknown schema version."""
        if not isinstance(d, dict):
            raise ValueError(f"document must be a JSON object, got {type(d).__name__}")
        schema = d.get("schema", SCHEMA_VERSION)
        if schema != SCHEMA_VERSION:
            raise ValueError(f"unsupported document schema: {schema!r}")
        doc = cls(
            width=d.get("width", WIDTH),
            height=d.get("height", HEIGHT),
            font_bank=d.get("font_bank", 0),
        )
        doc.project_palette = [dict(e) for e in d.get("project_palette", [])]
        doc.layers = [layer_from_dict(ld) for ld in d.get("layers", [])]
        doc.active_layer_index = d.get("active_layer_index", 0)
        raw_groups = d.get("groups", {})
        if isinstance(raw_groups, dict):
            doc.groups = {
                str(k): {"visible": bool(v.get("visible", True)),
                         "collapsed": bool(v.get("collapsed", False))}
                for k, v in raw_groups.items() if isinstance(v, dict)
            }
        doc._prune_groups()
        return doc

    def to_json(self, **json_kwargs):
        """`to_dict` serialized with the stdlib `json` module."""
        return json.dumps(self.to_dict(), **json_kwargs)

    @classmethod
    def from_json(cls, s):
        """Parse JSON text produced by `to_json`."""
        return cls.from_dict(json.loads(s))


def new_blank_document():
    """A fresh `Document` with a single empty `BlankLayer` named "Layer 1"."""
    doc = Document()
    doc.add_layer(BlankLayer(name="Layer 1"))
    doc.active_layer_index = 0
    return doc
