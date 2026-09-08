"""
Offscreen: the tool rail is grouped, non-rearrangeable, and the Ink / Cell
Inspector panels sit where the user asked (Ink top-right, Inspector left).
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QApplication, QDialog

from studio.model.document import new_blank_document
from studio.ui import layers_panel as lp_mod
from studio.ui.main_window import MainWindow


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def test_rail_is_sectioned_and_locked(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()

    assert win.tool_rail.isMovable() is False
    assert win.tool_rail.isFloatable() is False
    # right-click "hide toolbars/docks" menu is suppressed
    assert win.createPopupMenu() is None

    texts = [a.text() for a in win.tool_rail.actions()]
    seps = [a for a in win.tool_rail.actions() if a.isSeparator()]
    assert len(seps) >= 2            # select | draw | new-layer -> 2 rules
    # eyedropper is NOT on the rail...
    assert not any("Eyedropper" in t for t in texts)
    # ...but is still a real, reachable tool action
    assert "eyedropper" in win._tool_actions
    # new-layer one-shot actions present, and not part of the exclusive group
    for k in ("box", "text", "image"):
        assert k in win._tool_actions
        assert win._tool_actions[k] not in win._tool_group.actions()
    win.close()


def test_rail_sections_and_new_layer_buttons(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    # recolor is a checkable tool in the exclusive group (first rail section)
    assert win._tool_actions["recolor"] in win._tool_group.actions()
    # four one-shot "new layer" buttons, none of them in the tool group
    for k in ("box", "text", "image", "blank"):
        assert k in win._tool_actions
        assert win._tool_actions[k] not in win._tool_group.actions()
    win.close()


def test_ink_and_inspector_placement(qapp):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()

    left = set(type(w).__name__ for w in win.dock_ink.findChildren(object))
    right = set(type(w).__name__ for w in win.dock_layers.findChildren(object))
    assert "CellInspector" in left and "GlyphPicker" in left
    assert "PalettePanel" in right and "LayersPanel" in right
    assert "PalettePanel" not in left and "CellInspector" not in right
    win.close()


def test_pick_button_runs_screen_color_match(qapp, monkeypatch):
    """'Pick…' samples a screen pixel, then a match dialog sets the ink."""
    import studio.ui.screen_pick as sp
    import studio.ui.color_match_dialog as cmd
    from PySide6.QtGui import QColor

    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    win._ink_attr = 0x80          # blink bit set -> must survive the match

    captured = {}
    monkeypatch.setattr(sp, "pick_screen_color",
                        lambda parent, on_picked, on_cancel=None:
                        captured.__setitem__("cb", on_picked))

    class FakeDlg:
        def __init__(self, sampled, current_attr=None, parent=None):
            captured["sampled"] = QColor(sampled)

        def exec(self):
            return 1

        def chosen_attr(self):
            return 0x2A

    monkeypatch.setattr(cmd, "OdysseyColorDialog", FakeDlg)

    win.palette_panel.btn_eyedrop.click()
    assert "cb" in captured                       # entered screen-sample mode
    captured["cb"](QColor(10, 20, 30))            # user clicked a pixel
    assert captured["sampled"].red() == 10
    assert win._ink_attr == (0x80 | 0x2A)         # color swapped, blink kept
    win._set_clean()
    win.close()


def test_docks_never_scroll_horizontally(qapp):
    from PySide6.QtWidgets import QScrollArea
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    for dock in (win.dock_ink, win.dock_layers):
        sa = dock.widget()
        assert isinstance(sa, QScrollArea)
        assert sa.horizontalScrollBarPolicy() == Qt.ScrollBarAlwaysOff
        # content fits the viewport at the default width -> nothing clipped
        assert (sa.widget().minimumSizeHint().width()
                <= sa.viewport().width() + 1)
        assert dock.maximumWidth() <= 420
    # squeezing the window must not create a horizontal scrollbar either
    win.resize(760, 720)
    qapp.processEvents()
    for dock in (win.dock_ink, win.dock_layers):
        assert dock.widget().horizontalScrollBar().maximum() == 0
    win.close()


def test_new_layer_rail_button_adds_a_layer(qapp, monkeypatch):
    win = MainWindow(new_blank_document())
    win.show()
    qapp.processEvents()
    n = len(win.document.layers)

    monkeypatch.setattr(lp_mod.BoxDialog, "exec", lambda self: QDialog.Accepted)
    win._tool_actions["box"].trigger()
    assert len(win.document.layers) == n + 1
    win._set_clean()
    win.close()
