"""Paint tools: gesture -> undoable edits on the active layer.

`build_tools()` returns the standard rail as a ``{key: Tool}`` map; the UI
keys its tool-rail actions off the same strings.
"""

from studio.tools.base import (
    MOD_ALT, MOD_CTRL, MOD_SHIFT,
    CellEditTool, FreehandTool, ShapeTool, Tool, ToolContext, line_points,
)
from studio.tools.controller import ToolController
from studio.tools.ellipse import EllipseTool, ellipse_cells
from studio.tools.eraser import EraserTool
from studio.tools.eyedropper import EyedropperTool
from studio.tools.fill import FillTool
from studio.tools.gradient import GradientTool
from studio.tools.line import LineTool
from studio.tools.move_layer import MoveLayerTool
from studio.tools.pencil import PencilTool
from studio.tools.recolor import RecolorTool
from studio.tools.rect import RectTool

__all__ = [
    "MOD_ALT", "MOD_CTRL", "MOD_SHIFT",
    "Tool", "ToolContext", "ToolController", "FreehandTool", "ShapeTool",
    "CellEditTool", "PencilTool", "EraserTool", "LineTool", "RectTool",
    "EllipseTool", "FillTool", "RecolorTool", "EyedropperTool", "MoveLayerTool",
    "GradientTool",
    "line_points", "ellipse_cells", "build_tools", "TOOL_ORDER",
]

#: the controller tools, in rail order; (key, label, freedesktop icon name, impl).
#: "Box" / "Text" / "Image" are *not* here -- they are one-shot "new layer"
#: actions on the rail, aliased to Layer > New (see MainWindow._build_tool_rail).
TOOL_ORDER = [
    ("select", "Select", "edit-select", True),
    ("cell-edit", "Cell Edit", "document-edit", True),
    ("move-layer", "Move Layer", "transform-move", True),
    ("pencil", "Pencil", "draw-freehand", True),
    ("eraser", "Eraser", "draw-eraser", True),
    ("line", "Line", "draw-line", True),
    ("rectangle", "Rectangle", "draw-rectangle", True),
    ("ellipse", "Ellipse", "draw-ellipse", True),
    ("flood-fill", "Flood Fill", "color-fill", True),
    ("gradient", "Gradient", "color-gradient", True),
    ("recolor", "Recolor", "format-fill-color", True),
    ("eyedropper", "Eyedropper", "color-picker", True),
]


def build_tools() -> dict:
    """A fresh ``{key: Tool}`` map for one window."""
    return {
        "select": CellEditTool(),
        "cell-edit": CellEditTool(),
        "move-layer": MoveLayerTool(),
        "pencil": PencilTool(),
        "eraser": EraserTool(),
        "line": LineTool(),
        "rectangle": RectTool(),
        "ellipse": EllipseTool(),
        "flood-fill": FillTool(),
        "gradient": GradientTool(),
        "recolor": RecolorTool(),
        "eyedropper": EyedropperTool(),
    }
