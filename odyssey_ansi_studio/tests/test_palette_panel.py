"""Offscreen: PalettePanel ink picking + project-palette CRUD + persistence."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QApplication

from studio.io.project_file import load_project, save_project
from studio.model.document import Document
from studio.model.layers import BlankLayer
from studio.ui.palette_panel import PalettePanel


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def _doc():
    d = Document()
    d.add_layer(BlankLayer(name="l0"))
    return d


def test_swatch_click_emits_composed_attr_keeping_flags(qapp):
    p = PalettePanel()
    seen = []
    p.inkChosen.connect(seen.append)
    p.set_ink(0x80)                 # blink on, color 0
    p._pick_rgb(0x2A)              # click "white" swatch
    assert seen[-1] == 0x80 | 0x2A
    assert p.current_ink() == 0xAA


def test_ansi16_button_sets_exact_byte(qapp):
    p = PalettePanel()
    seen = []
    p.inkChosen.connect(seen.append)
    p._pick_exact(0x24)           # SGR 33 yellow
    assert seen[-1] & 0x3F == 0x24


def test_sliders_and_flags_compose(qapp):
    p = PalettePanel()
    seen = []
    p.inkChosen.connect(seen.append)
    p._sliders["R"].setValue(3)
    p._sliders["G"].setValue(1)
    p._sliders["B"].setValue(0)
    p.cb_blink.setChecked(True)
    assert p.current_ink() == (3 << 4 | 1 << 2 | 0) | 0x80
    assert seen                      # emitted on each change


def test_set_ink_syncs_controls_without_emitting(qapp):
    p = PalettePanel()
    seen = []
    p.inkChosen.connect(seen.append)
    p.set_ink(0x35)
    assert seen == []
    assert p._sliders["R"].value() == 3
    assert p._sliders["G"].value() == 1
    assert p._sliders["B"].value() == 1


def test_project_palette_add_remove_rename(qapp):
    doc = _doc()
    p = PalettePanel()
    p.set_document(doc)
    assert p.pp_list.count() == 0

    p.set_ink(0x2A)
    p._pp_add()
    p.set_ink(0x15)
    p._pp_add()
    assert [e["attr"] for e in doc.project_palette] == [0x2A, 0x15]
    assert p.pp_list.count() == 2

    # rename row 0
    it = p.pp_list.item(0)
    it.setText("ivory")
    assert doc.project_palette[0]["name"] == "ivory"

    # click row 1 -> ink loads
    seen = []
    p.inkChosen.connect(seen.append)
    p._pp_row_clicked(p.pp_list.item(1))
    assert p.current_ink() == 0x15
    assert seen[-1] == 0x15

    # remove row 0
    p.pp_list.setCurrentRow(0)
    p._pp_remove()
    assert [e["attr"] for e in doc.project_palette] == [0x15]
    assert p.pp_list.count() == 1


def test_set_document_loads_existing_palette(qapp):
    doc = _doc()
    doc.project_palette = [{"name": "sky", "attr": 0x0B},
                           {"name": "rust", "attr": 0x30}]
    p = PalettePanel()
    p.set_document(doc)
    assert [p.pp_list.item(i).text() for i in range(p.pp_list.count())] == \
        ["sky", "rust"]
    assert p.pp_list.item(0).data(Qt.UserRole) == 0x0B


def test_project_palette_persists_through_oas(qapp, tmp_path):
    doc = _doc()
    p = PalettePanel()
    p.set_document(doc)
    p.set_ink(0x2A)
    p._pp_add()
    p.pp_list.item(0).setText("paper")

    path = str(tmp_path / "pal.oas")
    save_project(doc, path)
    reloaded = load_project(path)
    assert reloaded.project_palette == [{"name": "paper", "attr": 0x2A}]
