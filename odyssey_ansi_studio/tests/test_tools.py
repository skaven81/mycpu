"""Headless paint-tool behavior: gesture sequences on a bare Document.

No Qt.  Each test drives a `ToolController` + `ToolContext` and checks the
resulting cell diffs plus undo/redo fidelity.
"""

import pytest

from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.history import History
from studio.model.layers import BlankLayer
from studio.tools import (
    MOD_CTRL, EllipseTool, EraserTool, EyedropperTool, FillTool, GradientTool,
    LineTool, MoveLayerTool, PencilTool, RecolorTool, RectTool, ToolContext,
    ToolController, build_tools,
)


class Ink:
    """Mutable stand-in for the UI's current glyph + color byte."""

    def __init__(self, glyph=0xDB, attr=0x0F):
        self.glyph = glyph
        self.attr = attr


def make(doc=None, ink=None, layers=1):
    doc = doc or Document()
    if not doc.layers:
        for i in range(layers):
            doc.add_layer(BlankLayer(name=f"L{i}"))
        doc.active_layer_index = len(doc.layers) - 1
    ink = ink or Ink()
    hist = History(doc)
    events = {"changes": 0, "status": []}
    ctx = ToolContext(
        doc, hist,
        get_glyph=lambda: ink.glyph,
        get_attr=lambda: ink.attr,
        set_glyph=lambda g: setattr(ink, "glyph", g),
        set_attr=lambda a: setattr(ink, "attr", a),
        on_change=lambda: events.__setitem__("changes", events["changes"] + 1),
        on_status=lambda m: events["status"].append(m),
        on_select=lambda c, r: events.__setitem__("sel", (c, r)),
    )
    return doc, hist, ctx, ink, events


def layer_cells(doc, index=None):
    index = doc.active_layer_index if index is None else index
    return dict(doc.layers[index].cells)


# --------------------------------------------------------------------------
# pencil / eraser
# --------------------------------------------------------------------------

def test_pencil_stroke_sets_cells_and_is_one_undo_step():
    doc, hist, ctx, ink, _ = make()
    ctl = ToolController(ctx, PencilTool())
    ctl.press(2, 2)
    ctl.drag(3, 2)
    ctl.drag(4, 2)
    ctl.release(4, 2)

    want = {(2, 2), (3, 2), (4, 2)}
    assert set(layer_cells(doc)) == want
    assert all(c == Cell(0xDB, 0x0F) for c in layer_cells(doc).values())

    assert hist.undo() is True
    assert layer_cells(doc) == {}
    assert hist.redo() is True
    assert set(layer_cells(doc)) == want
    assert hist.undo() and not hist.undo()  # exactly one step


def test_pencil_fast_drag_has_no_gaps():
    doc, _, ctx, _, _ = make()
    ctl = ToolController(ctx, PencilTool())
    ctl.press(0, 0)
    ctl.drag(5, 0)           # jump 5 cells in one move
    ctl.release(5, 0)
    assert set(layer_cells(doc)) == {(x, 0) for x in range(6)}


def test_eraser_clears_and_undo_restores():
    doc, hist, ctx, _, _ = make()
    layer = doc.layers[doc.active_layer_index]
    for x in range(5):
        layer.set_local(x, 1, Cell(0x41 + x, 0x20))
    ctl = ToolController(ctx, EraserTool())
    ctl.press(1, 1)
    ctl.drag(3, 1)
    ctl.release(3, 1)

    assert set(layer_cells(doc)) == {(0, 1), (4, 1)}
    hist.undo()
    assert len(layer_cells(doc)) == 5


# --------------------------------------------------------------------------
# line / rect / ellipse
# --------------------------------------------------------------------------

def test_line_horizontal_and_diagonal():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, LineTool())
    ctl.press(1, 1)
    ctl.release(4, 1)
    assert set(layer_cells(doc)) == {(1, 1), (2, 1), (3, 1), (4, 1)}
    hist.undo()

    ctl.press(0, 0)
    ctl.release(3, 3)
    assert set(layer_cells(doc)) == {(0, 0), (1, 1), (2, 2), (3, 3)}


def test_line_preview_updates_on_drag_then_commits_final():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, LineTool())
    ctl.press(0, 0)
    ctl.drag(9, 0)                       # provisional long line
    assert len(layer_cells(doc)) == 10  # shown live
    ctl.drag(2, 0)                       # shortened before release
    ctl.release(2, 0)
    assert set(layer_cells(doc)) == {(0, 0), (1, 0), (2, 0)}
    hist.undo()
    assert layer_cells(doc) == {}       # single reverting step


def test_rect_outline_leaves_interior_untouched():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, RectTool())
    ctl.press(1, 1)
    ctl.release(4, 3)
    cells = set(layer_cells(doc))
    assert (2, 2) not in cells and (3, 2) not in cells
    for c in (1, 2, 3, 4):
        assert (c, 1) in cells and (c, 3) in cells
    for r in (1, 2, 3):
        assert (1, r) in cells and (4, r) in cells
    hist.undo()
    assert layer_cells(doc) == {}


def test_rect_filled_via_ctrl_modifier():
    doc, _, ctx, _, _ = make()
    ctl = ToolController(ctx, RectTool())
    ctl.press(1, 1, MOD_CTRL)
    ctl.release(3, 3, MOD_CTRL)
    assert set(layer_cells(doc)) == {(c, r) for c in (1, 2, 3) for r in (1, 2, 3)}


def test_rect_filled_flag():
    doc, _, ctx, _, _ = make()
    ctl = ToolController(ctx, RectTool(filled=True))
    ctl.press(0, 0)
    ctl.release(2, 1)
    assert len(layer_cells(doc)) == 6


def test_ellipse_ring_is_hollow_and_closed():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, EllipseTool())
    ctl.press(0, 0)
    ctl.release(6, 6)
    cells = set(layer_cells(doc))
    assert (3, 3) not in cells          # center empty
    assert (0, 3) in cells and (6, 3) in cells
    assert (3, 0) in cells and (3, 6) in cells
    hist.undo()
    assert layer_cells(doc) == {}


# --------------------------------------------------------------------------
# fill
# --------------------------------------------------------------------------

def _draw_border(layer):
    # 0..5 square border on an otherwise empty layer
    for x in range(6):
        layer.set_local(x, 0, Cell(0xB1, 0x08))
        layer.set_local(x, 5, Cell(0xB1, 0x08))
    for y in range(6):
        layer.set_local(0, y, Cell(0xB1, 0x08))
        layer.set_local(5, y, Cell(0xB1, 0x08))


def test_flood_fill_stays_inside_border():
    doc, hist, ctx, ink, _ = make()
    ink.glyph, ink.attr = 0xDB, 0x30
    layer = doc.layers[doc.active_layer_index]
    _draw_border(layer)
    ctl = ToolController(ctx, FillTool())
    ctl.press(2, 2)
    ctl.release(2, 2)

    for x in range(1, 5):
        for y in range(1, 5):
            assert layer.get_local(x, y) == Cell(0xDB, 0x30)
    assert layer.get_local(0, 0) == Cell(0xB1, 0x08)   # border kept
    # cell outside the border never touched
    assert layer.get_local(10, 10) is None
    hist.undo()
    assert layer.get_local(2, 2) is None


def test_flood_fill_noop_when_already_target():
    doc, hist, ctx, ink, events = make()
    ink.glyph, ink.attr = 0x41, 0x0F
    layer = doc.layers[doc.active_layer_index]
    layer.set_local(3, 3, Cell(0x41, 0x0F))
    ctl = ToolController(ctx, FillTool())
    ctl.press(3, 3)
    ctl.release(3, 3)
    assert hist.can_undo() is False
    assert any("already" in m for m in events["status"])


def test_flood_fill_empty_layer_fills_document():
    doc, _, ctx, ink, _ = make()
    ink.glyph, ink.attr = 0x2E, 0x01
    ctl = ToolController(ctx, FillTool())
    ctl.press(0, 0)
    ctl.release(0, 0)
    assert len(layer_cells(doc)) == doc.width * doc.height


# --------------------------------------------------------------------------
# recolor / eyedropper
# --------------------------------------------------------------------------

def test_recolor_keeps_glyph_changes_attr_skips_nulls():
    doc, hist, ctx, ink, _ = make()
    ink.attr = 0x2A
    layer = doc.layers[doc.active_layer_index]
    layer.set_local(1, 1, Cell(0x41, 0x0F))
    layer.set_local(3, 1, Cell(0x42, 0x0F))   # (2,1) left NULL
    ctl = ToolController(ctx, RecolorTool())
    ctl.press(1, 1)
    ctl.drag(2, 1)
    ctl.drag(3, 1)
    ctl.release(3, 1)

    assert layer.get_local(1, 1) == Cell(0x41, 0x2A)
    assert layer.get_local(3, 1) == Cell(0x42, 0x2A)
    assert layer.get_local(2, 1) is None
    hist.undo()
    assert layer.get_local(1, 1) == Cell(0x41, 0x0F)


def test_eyedropper_loads_ink_without_history():
    doc, hist, ctx, ink, _ = make()
    doc.layers[doc.active_layer_index].set_local(4, 4, Cell(0xE0, 0x9C))
    ctl = ToolController(ctx, EyedropperTool())
    ctl.press(4, 4)
    ctl.release(4, 4)
    assert (ink.glyph, ink.attr) == (0xE0, 0x9C)
    assert hist.can_undo() is False


# --------------------------------------------------------------------------
# targeting: active layer, lock, offset
# --------------------------------------------------------------------------

def test_edits_hit_only_the_active_layer():
    doc = Document()
    doc.add_layer(BlankLayer(name="lower"))
    doc.add_layer(BlankLayer(name="upper"))
    doc.active_layer_index = 1
    _, _, ctx, _, _ = make(doc)
    ctl = ToolController(ctx, PencilTool())
    ctl.press(2, 2)
    ctl.release(2, 2)
    assert doc.layers[0].cells == {}
    assert set(doc.layers[1].cells) == {(2, 2)}


def test_locked_layer_rejects_edits():
    doc = Document()
    doc.add_layer(BlankLayer(name="locked"))
    doc.layers[0].locked = True
    doc.active_layer_index = 0
    _, hist, ctx, _, events = make(doc)
    ctl = ToolController(ctx, PencilTool())
    ctl.press(1, 1)
    ctl.drag(2, 1)
    ctl.release(2, 1)
    assert doc.layers[0].cells == {}
    assert hist.can_undo() is False
    assert any("locked" in m for m in events["status"])


def test_offset_layer_stores_local_coords():
    doc = Document()
    doc.add_layer(BlankLayer(name="shifted", offx=5, offy=3))
    doc.active_layer_index = 0
    _, _, ctx, _, _ = make(doc)
    ctl = ToolController(ctx, PencilTool())
    ctl.press(10, 10)
    ctl.release(10, 10)
    assert set(doc.layers[0].cells) == {(5, 7)}          # 10-5, 10-3
    assert doc.composite_cell(10, 10) is not None


def test_out_of_document_cells_are_dropped():
    doc, _, ctx, _, _ = make()
    ctl = ToolController(ctx, LineTool())
    ctl.press(1, 1)
    ctl.release(200, 1)                                  # runs off the canvas
    assert max(c for c, _ in layer_cells(doc)) < doc.width


# --------------------------------------------------------------------------
# controller stroke lifecycle
# --------------------------------------------------------------------------

def test_tool_switch_mid_stroke_reverts_provisional():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, LineTool())
    ctl.press(0, 0)
    ctl.drag(8, 0)
    assert len(layer_cells(doc)) == 9        # provisional shown
    ctl.set_tool(EraserTool())               # switch before release
    assert layer_cells(doc) == {}            # rolled back
    assert hist.can_undo() is False


def test_cancel_reverts_and_second_press_is_clean():
    doc, hist, ctx, _, _ = make()
    ctl = ToolController(ctx, RectTool())
    ctl.press(0, 0)
    ctl.drag(4, 4)
    ctl.cancel()
    assert layer_cells(doc) == {}
    ctl.press(1, 1)
    ctl.release(2, 2)
    assert set(layer_cells(doc)) == {(1, 1), (2, 1), (1, 2), (2, 2)}


def test_move_layer_tool_shifts_offset_and_undoes():
    doc = Document()
    lyr = BlankLayer(name="art")
    lyr.set_local(0, 0, Cell(0x41, 0x0F))
    doc.add_layer(lyr)
    _, hist, ctx, _, _ = make(doc)
    ctl = ToolController(ctx, MoveLayerTool())
    ctl.press(10, 10)
    ctl.drag(13, 12)
    ctl.release(13, 12)
    assert (lyr.offx, lyr.offy) == (3, 2)
    assert doc.composite_cell(3, 2) == Cell(0x41, 0x0F)
    hist.undo()
    assert (lyr.offx, lyr.offy) == (0, 0)
    hist.redo()
    assert (lyr.offx, lyr.offy) == (3, 2)


def test_move_layer_tool_cancel_restores_offset():
    doc = Document()
    doc.add_layer(BlankLayer(name="art"))
    _, hist, ctx, _, _ = make(doc)
    ctl = ToolController(ctx, MoveLayerTool())
    ctl.press(5, 5)
    ctl.drag(9, 7)
    assert (doc.layers[0].offx, doc.layers[0].offy) == (4, 2)
    ctl.cancel()
    assert (doc.layers[0].offx, doc.layers[0].offy) == (0, 0)
    assert hist.can_undo() is False


def test_gradient_recolors_existing_cells_along_the_drag():
    doc = Document()
    lyr = BlankLayer(name="bar")
    for x in range(8):
        lyr.set_local(x, 0, Cell(0xDB, 0x3F))       # white row
    doc.add_layer(lyr)
    ink = Ink(glyph=0xDB, attr=0x3F)                 # start = white
    _, hist, ctx, _, _ = make(doc, ink)
    grad = GradientTool(end_attr=0x00)               # fade to black
    ctl = ToolController(ctx, grad)
    ctl.press(0, 0)
    ctl.drag(7, 0)
    ctl.release(7, 0)

    assert lyr.get_local(0, 0).attr == 0x3F          # start stays white
    assert lyr.get_local(7, 0).attr == 0x00          # end is black
    assert lyr.get_local(3, 0).attr not in (0x3F, 0x00)   # a mid band
    assert all(lyr.get_local(x, 0).glyph == 0xDB for x in range(8))  # glyphs kept
    hist.undo()
    assert all(lyr.get_local(x, 0).attr == 0x3F for x in range(8))


def test_gradient_fill_mode_stamps_blocks():
    doc = Document()
    doc.add_layer(BlankLayer(name="l"))
    ink = Ink(glyph=0xDB, attr=0x3F)
    _, _, ctx, _, _ = make(doc, ink)
    grad = GradientTool(fill=True, end_attr=0x00)
    ctl = ToolController(ctx, grad)
    ctl.press(0, 0)
    ctl.release(3, 2)
    cells = layer_cells(doc)
    assert len(cells) == 12                          # whole 4x3 box filled
    assert all(c.glyph == 0xDB for c in cells.values())


def test_build_tools_has_every_rail_key():
    tools = build_tools()
    for key in ("pencil", "eraser", "line", "rectangle", "ellipse",
                "flood-fill", "gradient", "recolor", "eyedropper", "cell-edit",
                "select", "gradient", "move-layer"):
        assert key in tools


def test_cell_edit_tool_moves_selection():
    doc, _, ctx, _, events = make()
    tools = build_tools()
    ctl = ToolController(ctx, tools["cell-edit"])
    ctl.press(7, 9)
    ctl.release(7, 9)
    assert doc.selection == {(7, 9)}
    assert events["sel"] == (7, 9)
