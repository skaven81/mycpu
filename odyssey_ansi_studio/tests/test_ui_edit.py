"""
Offscreen: paint tools + inspector + undo/redo wired through MainWindow.

Drives the window's own `ToolController` and `CellInspector` (no synthetic
mouse events) and checks the document, the dirty flag, and the Edit-menu
undo/redo actions all move together.
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtWidgets import QApplication, QMessageBox

from studio.model.cell import Cell
from studio.model.document import new_blank_document
from studio.ui.cell_inspector import parse_attr, parse_glyph
from studio.ui.demo import demo_document
from studio.ui.main_window import MainWindow


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


@pytest.fixture(autouse=True)
def _no_modal_close(monkeypatch):
    """Never block on the unsaved-changes dialog when a test closes a window."""
    monkeypatch.setattr(QMessageBox, "warning",
                        staticmethod(lambda *a, **k: QMessageBox.Discard))


def _select_tool(win, key):
    win._tool_actions[key].trigger()


def test_pencil_stroke_marks_dirty_and_enables_undo(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    assert win.is_dirty() is False
    assert win.act_undo.isEnabled() is False

    _select_tool(win, "pencil")
    win._set_ink_glyph(0xDB)
    win._set_ink_attr(0x2A)
    ctl = win._controller
    ctl.press(3, 4)
    ctl.drag(6, 4)
    ctl.release(6, 4)

    layer = win.document.layers[win.document.active_layer_index]
    assert layer.get(3, 4) == Cell(0xDB, 0x2A)
    assert layer.get(6, 4) == Cell(0xDB, 0x2A)
    assert win.is_dirty() is True
    assert win.act_undo.isEnabled() is True

    win._undo()
    assert layer.get(3, 4) is None
    assert win.act_redo.isEnabled() is True
    win._redo()
    assert layer.get(5, 4) == Cell(0xDB, 0x2A)
    win.close()


def test_eyedropper_updates_current_ink(qapp):
    doc = new_blank_document()
    doc.layers[0].set_local(2, 2, Cell(0x41, 0x1F))
    win = MainWindow(doc)
    win.show()
    qapp.processEvents()

    _select_tool(win, "eyedropper")
    win._controller.press(2, 2)
    win._controller.release(2, 2)
    assert win._current_glyph() == 0x41
    assert win._current_attr() == 0x1F
    win.close()


def test_cell_edit_tool_then_inspector_apply(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()

    _select_tool(win, "cell-edit")
    win._controller.press(8, 8)
    win._controller.release(8, 8)
    assert win.inspector.selection() == (8, 8)

    win.inspector.ed_glyph.setText("A")
    win.inspector.ed_attr.setText("0x0C")
    win.inspector.cb_blink.setChecked(True)
    win.inspector._emit_apply()

    layer = win.document.layers[win.document.active_layer_index]
    assert layer.get(8, 8) == Cell(0x41, 0x0C | 0x80)
    assert win.is_dirty() is True

    win._undo()
    assert layer.get(8, 8) is None

    # Set NULL on an existing cell
    layer.set_local(8, 8, Cell(0x42, 0x03))
    win._select_cell_for_inspector(8, 8)
    win.inspector._emit_clear()
    assert layer.get(8, 8) is None
    win.close()


def test_locked_layer_blocks_tool_and_inspector(qapp, monkeypatch):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    win.document.layers[0].locked = True

    _select_tool(win, "pencil")
    win._controller.press(1, 1)
    win._controller.release(1, 1)
    assert win.document.layers[0].cells == {}
    assert win.act_undo.isEnabled() is False

    # inspector apply on a locked layer: swallow the modal info box
    monkeypatch.setattr("studio.ui.main_window.QMessageBox.information",
                        lambda *a, **k: None)
    win._select_cell_for_inspector(1, 1)
    win.inspector.ed_glyph.setText("0x41")
    win.inspector.ed_attr.setText("0x0F")
    win.inspector._emit_apply()
    assert win.document.layers[0].cells == {}
    win.close()


def test_shape_tool_escape_cancel_via_canvas(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    _select_tool(win, "rectangle")
    ctl = win._controller
    ctl.press(1, 1)
    ctl.drag(5, 5)
    layer = win.document.layers[0]
    assert len(layer.cells) > 0            # provisional
    ctl.cancel()
    assert layer.cells == {}
    assert win.act_undo.isEnabled() is False
    win.close()


def test_active_layer_follows_layer_list_selection(qapp):
    doc = demo_document()
    win = MainWindow(doc)
    win.show()
    qapp.processEvents()
    lst = win.layers_panel.list
    # top row (display row 0) is the last layer
    lst.setCurrentRow(0)
    assert win.document.active_layer_index == len(doc.layers) - 1
    lst.setCurrentRow(lst.count() - 1)
    assert win.document.active_layer_index == 0
    win.close()


def test_palette_and_glyph_pickers_feed_the_tools(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()

    win.palette_panel._pick_exact(0x24)          # yellow
    win.glyph_picker.choose(0xB1)                # medium shade
    assert win._current_attr() & 0x3F == 0x24
    assert win._current_glyph() == 0xB1

    _select_tool(win, "pencil")
    win._controller.press(4, 4)
    win._controller.release(4, 4)
    layer = win.document.layers[win.document.active_layer_index]
    assert layer.get(4, 4) == Cell(0xB1, 0x24)
    win.close()


def test_bank_change_via_picker_updates_document_and_menu(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    assert win.is_dirty() is False

    win.glyph_picker.combo.setCurrentIndex(4)
    assert win.document.font_bank == 4
    assert win._bank_actions[4].isChecked() is True
    assert win.is_dirty() is True
    win._set_clean()
    win.close()


def test_project_palette_edit_marks_dirty(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    win.palette_panel.set_ink(0x2A)
    win.palette_panel._pp_add()
    assert win.document.project_palette == [{"name": "color 1", "attr": 0x2A}]
    assert win.is_dirty() is True
    win._set_clean()
    win.close()


def test_canvas_flags_off_canvas_layer_content(qapp):
    from studio.model.cell import Cell
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    assert win.canvas.has_overflow() is False

    win.document.layers[0].set_local(-3, 2, Cell(0xDB, 0x0F))   # left of the grid
    win.document.layers[0].set_local(2, 80, Cell(0xDB, 0x0F))   # below the grid
    win.canvas.refresh()
    assert win.canvas._compute_overflow() == {"left", "bottom"}
    win._set_clean()
    win.close()


def test_export_data_menu_writes_files(qapp, tmp_path, monkeypatch):
    from studio.model.cell import Cell
    win = MainWindow(new_blank_document())
    win.document.layers[0].set_local(0, 0, Cell(0x41, 0x2A))
    win.show()
    qapp.processEvents()

    monkeypatch.setattr("studio.ui.main_window.QInputDialog.getInt",
                        lambda *a, **k: (2, True))
    monkeypatch.setattr("studio.ui.main_window.QInputDialog.getItem",
                        lambda *a, **k: ("space (0x20)", True))
    for kind, ext, binary in (("bin-split", ".bin", True), ("c", ".h", False),
                              ("asm", ".asm", False), ("ans16", ".ans", True),
                              ("png", ".png", True)):
        target = str(tmp_path / f"out_{kind}{ext}")
        monkeypatch.setattr("studio.ui.main_window.QFileDialog.getSaveFileName",
                            lambda *a, **k: (target, ""))
        win._export_data(kind)
        data = open(target, "rb" if binary else "r").read()
        assert data
        if kind == "bin-split":
            assert len(data) == 2 * win.document.width * win.document.height
            assert data[0] == 0x41
        if kind == "c":
            assert "_chr[3840]" in data
        if kind == "asm":
            assert data.startswith("# Generated by Odyssey ANSI Studio")
        if kind == "ans16":
            assert data.startswith(b"\x1b[H") and b"\x1b[0m" in data
        if kind == "png":
            assert data[:8] == b"\x89PNG\r\n\x1a\n"
    win._set_clean()
    win.close()


def test_canvas_opens_at_2x_and_transparency_toggles(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    assert win.canvas.zoom() == 2
    assert win.canvas.show_transparency() is False
    win._set_transparency(True)
    assert win.canvas.show_transparency() is True
    assert win.act_show_trans.isChecked() and win.btn_trans.isChecked()
    win._set_transparency(False)
    assert win.canvas.show_transparency() is False
    win.close()


def test_rgb_sliders_are_interactive(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    pp = win.palette_panel
    seen = []
    pp.inkChosen.connect(seen.append)
    pp._sliders["R"].setValue(3)
    pp._sliders["G"].setValue(2)
    pp._sliders["B"].setValue(1)
    assert pp.current_ink() == (3 << 4 | 2 << 2 | 1)
    assert win._current_attr() == pp.current_ink()      # propagated to the tool ink
    assert seen and seen[-1] == pp.current_ink()
    assert pp._slider_vals["R"].text() == "3"
    win.close()


def test_glyph_picker_indicator_follows_ink_and_quick_blocks(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    gp = win.glyph_picker

    win.palette_panel._pick_exact(0x30)               # red
    assert gp._ink_rgb == (255, 0, 0)
    # the selected grid button carries a red border
    sel = gp._buttons[gp.current_glyph()]
    assert "255,0,0" in sel.styleSheet()

    gp.choose(0xB1)                                   # medium-shade quick block
    assert win._current_glyph() == 0xB1
    assert "0xB1" in gp._preview_lbl.text()
    win.close()


def test_parse_helpers():
    assert parse_glyph("0x41") == 0x41
    assert parse_glyph("65") == 65
    assert parse_glyph("A") == 0x41
    assert parse_glyph("") is None
    assert parse_glyph("zzz") is None
    assert parse_attr("0x1F") == 0x1F
    assert parse_attr("31") == 31
    assert parse_attr("nope") is None
