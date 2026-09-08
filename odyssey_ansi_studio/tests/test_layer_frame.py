"""
The active layer shows an editable frame on the canvas: box / text / image
layers expose a ``(col,row,w,h)`` frame with resize handles; a blank layer
reports its painted bounding box and cannot be resized.  Dragging a handle
re-frames the layer and is one undoable step (`ReshapeLayerCommand`).
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from studio.model.cell import Cell
from studio.model.document import new_blank_document
from studio.model.history import ReshapeLayerCommand
from studio.model.layers import BlankLayer, BoxLayer, TextLayer


def _box(w=10, h=6, ox=5, oy=4):
    b = BoxLayer(name="B", params={"w": w, "h": h})
    b.offx, b.offy = ox, oy
    b.regenerate()
    return b


# ---- model -----------------------------------------------------------------

def test_generated_layer_frame_and_resizable():
    b = _box()
    assert b.frame() == (5, 4, 10, 6)
    assert b.resizable() is True


def test_set_frame_moves_resizes_and_regenerates():
    b = _box()
    cells_before = dict(b.cells)
    b.set_frame(2, 3, 20, 8)
    assert b.frame() == (2, 3, 20, 8)
    assert b.params["w"] == 20 and b.params["h"] == 8
    assert b.cells != cells_before          # re-rasterized to the new size


def test_text_layer_frame_keeps_rect_in_sync():
    t = TextLayer(name="T", params={"text": "hi"}, rect=(0, 0, 12, 4))
    t.offx, t.offy = 3, 3
    t.regenerate()
    assert t.frame() == (3, 3, 12, 4)
    t.set_frame(3, 3, 18, 6)
    assert t.params["rect"][2:] == [18, 6]


def test_blank_layer_frame_is_bbox_and_not_resizable():
    lyr = BlankLayer(name="L")
    assert lyr.frame() is None               # empty -> nothing to outline
    lyr.set(6, 7, Cell(0xDB, 0x0F))
    lyr.set(9, 10, Cell(0xDB, 0x0F))
    assert lyr.frame() == (6, 7, 4, 4)
    assert lyr.resizable() is False
    lyr.set_frame(0, 0)                       # move only; w/h ignored
    assert lyr.frame() == (0, 0, 4, 4)


def test_reshape_layer_command_round_trips():
    doc = new_blank_document()
    b = _box()
    doc.add_layer(b)
    idx = len(doc.layers) - 1
    before = b.frame()
    b.set_frame(1, 1, 24, 9)
    after = b.frame()
    cmd = ReshapeLayerCommand(idx, before, after)
    cmd.undo(doc)
    assert doc.layers[idx].frame() == before
    cmd.do(doc)
    assert doc.layers[idx].frame() == after


# ---- canvas interaction --------------------------------------------------

@pytest.fixture(scope="module")
def qapp():
    from PySide6.QtWidgets import QApplication
    return QApplication.instance() or QApplication([])


def _win_with_box(qapp):
    from studio.ui.main_window import MainWindow
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    b = _box()
    win.document.add_layer(b)
    win.layers_panel.refresh()
    win.document.active_layer_index = len(win.document.layers) - 1
    win.canvas.refresh()
    win.canvas.set_frame_editing(True)
    return win, b


def test_canvas_exposes_active_layer_frame_and_handles(qapp):
    win, b = _win_with_box(qapp)
    info = win.canvas._frame_info()
    assert info is not None
    rect, fr, layer = info
    assert fr == (5, 4, 10, 6)
    assert layer is b
    # a resize handle sits on the SE corner of the drawn rect
    assert win.canvas._handle_at(rect.right(), rect.bottom()) == "se"
    # ...and none when the drawing tools are active
    win.canvas.set_frame_editing(False)
    assert win.canvas._frame_info() is None
    win._set_clean()
    win.close()


def test_dragging_a_handle_reframes_the_layer(qapp):
    win, b = _win_with_box(qapp)
    win.canvas._frame_drag = {"handle": "se", "start": b.frame(),
                              "li": win.document.active_layer_index}
    ox, oy = win.canvas.content_origin()
    step = 8 * win.canvas.zoom()
    # pull the SE handle to col 17, row 11 -> 13 wide x 8 tall
    win.canvas._resize_drag_to(ox + 17 * step + 1, oy + 11 * step + 1)
    assert b.frame() == (5, 4, 13, 8)
    win._set_clean()
    win.close()
