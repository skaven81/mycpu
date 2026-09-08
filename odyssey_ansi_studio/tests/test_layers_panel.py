"""Offscreen: LayersPanel stack ops + re-editable Box/Text + hand-edit warning."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtWidgets import QApplication, QDialog, QMessageBox

from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BlankLayer, BoxLayer, TextLayer
from studio.ui import box_dialog as box_mod
from studio.ui import layers_panel as lp_mod
from studio.ui import text_layer_edit as txt_mod
from studio.ui.layers_panel import LayersPanel


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def _doc(n=1):
    d = Document()
    for i in range(n):
        d.add_layer(BlankLayer(name=f"L{i}"))
    d.active_layer_index = 0
    return d


def _panel(doc):
    p = LayersPanel()
    p.set_document(doc)
    return p


def test_add_blank_selects_new_top_layer(qapp):
    doc = _doc(1)
    p = _panel(doc)
    p.add_blank()
    assert len(doc.layers) == 2
    assert doc.active_layer_index == 1
    assert p.list.count() == 2


def test_delete_and_guard_last_layer(qapp):
    doc = _doc(3)
    p = _panel(doc)
    p._select_index(1)
    p.delete_selected()
    assert len(doc.layers) == 2
    # cannot delete down to zero
    p._select_index(0)
    p.delete_selected()
    p._select_index(0)
    p.delete_selected()
    assert len(doc.layers) == 1


def test_move_up_down_reorders_and_changes_composite(qapp):
    doc = Document()
    a = BlankLayer(name="a"); a.set_local(0, 0, Cell(0x41, 0x0F))
    b = BlankLayer(name="b"); b.set_local(0, 0, Cell(0x42, 0x0F))
    doc.add_layer(a)      # index 0 (bottom)
    doc.add_layer(b)      # index 1 (top) -> composite shows 'B'
    p = _panel(doc)
    assert doc.composite_cell(0, 0).glyph == 0x42

    p._select_index(0)            # select 'a'
    p.move_selected(+1)          # move it up above 'b'
    assert doc.layers[-1].name == "a"
    assert doc.composite_cell(0, 0).glyph == 0x41


def test_duplicate_makes_independent_copy(qapp):
    doc = _doc(1)
    doc.layers[0].set_local(1, 1, Cell(0x41, 0x0F))
    p = _panel(doc)
    p._select_index(0)
    p.duplicate_selected()
    assert len(doc.layers) == 2
    doc.layers[1].set_local(2, 2, Cell(0x58, 0x0F))
    assert (2, 2) not in doc.layers[0].cells


def test_merge_down(qapp):
    doc = Document()
    lo = BlankLayer(name="lo"); lo.set_local(0, 0, Cell(0x41, 0x0F))
    hi = BlankLayer(name="hi"); hi.set_local(1, 0, Cell(0x42, 0x0F))
    doc.add_layer(lo); doc.add_layer(hi)
    p = _panel(doc)
    p._select_index(1)
    p.merge_down_selected()
    assert len(doc.layers) == 1
    assert doc.layers[0].get(0, 0) == Cell(0x41, 0x0F)
    assert doc.layers[0].get(1, 0) == Cell(0x42, 0x0F)


def test_flatten_all_confirmed(qapp, monkeypatch):
    doc = _doc(3)
    doc.layers[0].set_local(0, 0, Cell(0x41, 0x0F))
    p = _panel(doc)
    monkeypatch.setattr(lp_mod.QMessageBox, "question",
                        staticmethod(lambda *a, **k: QMessageBox.Yes))
    p.flatten_all()
    assert len(doc.layers) == 1
    assert doc.layers[0].kind == "blank"


def test_add_box_from_dialog(qapp, monkeypatch):
    doc = _doc(1)
    p = _panel(doc)
    monkeypatch.setattr(box_mod.BoxDialog, "exec", lambda self: QDialog.Accepted)
    monkeypatch.setattr(box_mod.BoxDialog, "result_params",
                        lambda self: {"style": "double", "w": 8, "h": 4})
    p.add_box()
    assert isinstance(doc.layers[-1], BoxLayer)
    assert doc.layers[-1].params["style"] == "double"
    assert doc.layers[-1].cells                      # regenerated
    assert doc.layers[-1].manual_edits() is False


def test_reedit_text_layer_warns_on_hand_edits(qapp, monkeypatch):
    doc = _doc(1)
    t = TextLayer(name="cap", params={"text": "hello", "w": 10, "h": 3})
    t.regenerate()
    t.set_local(0, 2, Cell(0x2A, 0x0F))              # a hand edit
    doc.add_layer(t)
    p = _panel(doc)
    p._select_index(doc.layers.index(t))

    monkeypatch.setattr(txt_mod.TextLayerDialog, "exec",
                        lambda self: QDialog.Accepted)
    monkeypatch.setattr(txt_mod.TextLayerDialog, "result_params",
                        lambda self: {"text": "brand new", "w": 10, "h": 3,
                                      "align": "left", "wrap": True,
                                      "opaque": False, "text_attr": 0x0F})
    warned = []
    monkeypatch.setattr(lp_mod.QMessageBox, "warning",
                        staticmethod(lambda *a, **k: warned.append(a) or QMessageBox.Yes))
    p.edit_selected()
    assert warned                                    # the warning fired
    assert t.text == "brand new"
    assert t.manual_edits() is False                 # re-rasterized


def test_reedit_declined_keeps_layer_untouched(qapp, monkeypatch):
    doc = _doc(1)
    b = BoxLayer(name="frame", params={"w": 8, "h": 5})
    b.regenerate()
    b.set_local(2, 2, Cell(0x2A, 0x0F))
    doc.add_layer(b)
    p = _panel(doc)
    p._select_index(doc.layers.index(b))
    monkeypatch.setattr(box_mod.BoxDialog, "exec", lambda self: QDialog.Accepted)
    monkeypatch.setattr(box_mod.BoxDialog, "result_params",
                        lambda self: {"style": "single", "w": 12, "h": 8})
    monkeypatch.setattr(lp_mod.QMessageBox, "warning",
                        staticmethod(lambda *a, **k: QMessageBox.No))
    p.edit_selected()
    assert b.params["w"] == 8                         # unchanged
    assert b.get_local(2, 2) == Cell(0x2A, 0x0F)      # hand edit kept


def test_add_image_layer_via_dialog(qapp, monkeypatch, tmp_path):
    from PIL import Image
    from studio.io.fontrom import FontRom
    from studio.model.layers import ImageLayer
    from studio.ui import image_import_dialog as iid

    png = tmp_path / "src.png"
    Image.new("RGB", (16, 16), (0, 200, 0)).save(png)

    doc = _doc(1)
    p = LayersPanel(FontRom())
    p.set_document(doc)

    def fake_exec(self):
        self._load(str(png))
        return QDialog.Accepted

    monkeypatch.setattr(iid.ImageImportDialog, "exec", fake_exec)
    p.add_image()

    assert isinstance(doc.layers[-1], ImageLayer)
    lyr = doc.layers[-1]
    assert lyr.cells                       # converted
    assert lyr.source_ref and lyr._source_bytes
    assert lyr.manual_edits() is False


def test_rename(qapp, monkeypatch):
    doc = _doc(1)
    p = _panel(doc)
    p._select_index(0)
    monkeypatch.setattr(lp_mod.QInputDialog, "getText",
                        staticmethod(lambda *a, **k: ("Renamed", True)))
    p.rename_selected()
    assert doc.layers[0].name == "Renamed"


# ==========================================================================
# Layer groups (panel)
# ==========================================================================

def test_panel_group_and_ungroup_selected(qapp):
    doc = _doc(3)
    p = _panel(doc)
    p.list.selectAll()                       # select every row
    import studio.ui.layers_panel as lp
    orig = lp.QInputDialog.getText
    lp.QInputDialog.getText = staticmethod(lambda *a, **k: ("HUD", True))
    try:
        p.group_selected()
    finally:
        lp.QInputDialog.getText = orig
    assert [l.group for l in doc.layers] == ["HUD", "HUD", "HUD"]
    assert "HUD" in doc.groups

    p.list.setCurrentRow(0)
    p.ungroup_selected()
    assert doc.layers[p.selected_index()].group is None


def test_panel_group_visibility_toggle_hides_from_composite(qapp):
    doc = Document()
    a = BlankLayer(name="a"); a.set_local(0, 0, Cell(0x41, 0x0F))
    doc.add_layer(a)
    doc.set_layer_group(0, "g")
    p = _panel(doc)
    p.list.setCurrentRow(0)
    p.toggle_group_visibility()
    assert doc.composite_cell(0, 0) is None
    p.toggle_group_visibility()
    assert doc.composite_cell(0, 0).glyph == 0x41


def test_panel_collapsed_group_shows_one_header_row(qapp):
    doc = _doc(4)
    p = _panel(doc)
    for i in (1, 2):
        doc.set_layer_group(i, "mid")
    p.refresh()
    assert p.list.count() == 4               # 2 ungrouped + 2 grouped rows
    doc.set_group_collapsed("mid", True)
    p.refresh()
    assert p.list.count() == 3               # the 2 grouped rows -> 1 header


def test_row_fits_viewport_and_shows_kind_tag(qapp):
    from PySide6.QtWidgets import QLabel

    doc = _doc(1)
    doc.layers[0].name = "a really quite long layer name that would overflow"
    p = _panel(doc)
    p.resize(220, 300)
    p.show()
    qapp.processEvents()
    p._fit_rows()
    it = p.list.item(0)
    rw = p.list.itemWidget(it)
    vpw = p.list.viewport().width()
    assert it.sizeHint().width() == vpw          # row never forces h-scroll
    assert rw.maximumWidth() == vpw
    texts = [w.text() for w in rw.findChildren(QLabel)]
    assert any("[cells]" in t for t in texts)    # kind tag survives the clamp
    p.close()


def test_visibility_and_lock_toggle_swap_icons(qapp):
    doc = _doc(1)
    p = _panel(doc)
    p.show()
    qapp.processEvents()
    from PySide6.QtWidgets import QToolButton
    rw = p.list.itemWidget(p.list.item(0))
    vis, lock = rw.findChildren(QToolButton)[:2]

    v0 = vis.icon().cacheKey()
    vis.setChecked(False)                         # hide
    assert doc.layers[0].visible is False
    assert vis.icon().cacheKey() != v0            # eye -> eye-with-slash
    assert "Show" in vis.toolTip()

    l0 = lock.icon().cacheKey()
    lock.setChecked(True)                         # lock
    assert doc.layers[0].locked is True
    assert lock.icon().cacheKey() != l0           # open -> closed padlock
    p.close()


def test_set_ink_flows_into_new_layer_dialog(qapp, monkeypatch):
    doc = _doc(1)
    p = _panel(doc)
    p.set_ink(0x2B)
    seen = {}
    monkeypatch.setattr(txt_mod.TextLayerDialog, "__init__",
                        lambda self, *a, **k: seen.__setitem__("ink", k.get("ink")))
    monkeypatch.setattr(txt_mod.TextLayerDialog, "exec", lambda self: 0)
    p.add_text()
    assert seen["ink"] == 0x2B
