"""Offscreen: GlyphPicker grid / search / recent / bank switching."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtWidgets import QApplication

from studio.io.fontrom import GLYPH_COUNT, FontRom
from studio.model.document import Document
from studio.model.layers import BlankLayer
from studio.model.cell import Cell
from studio.io.cp437 import CP437_TO_UNICODE
from studio.ui.glyph_picker import GlyphPicker, _match


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


@pytest.fixture(scope="module")
def rom():
    return FontRom()


def test_grid_has_every_glyph(qapp, rom):
    gp = GlyphPicker(rom)
    assert len(gp._buttons) == GLYPH_COUNT == 256


def test_choose_emits_and_updates_recent(qapp, rom):
    gp = GlyphPicker(rom)
    seen = []
    gp.glyphChosen.connect(seen.append)
    gp.choose(0x41)
    gp.choose(0xB0)
    assert seen == [0x41, 0xB0]
    assert gp.current_glyph() == 0xB0
    assert gp._recent[:2] == [0xB0, 0x41]      # most-recent first


def test_set_current_glyph_does_not_emit(qapp, rom):
    gp = GlyphPicker(rom)
    seen = []
    gp.glyphChosen.connect(seen.append)
    gp.set_current_glyph(0x02)
    assert seen == []
    assert gp._buttons[0x02].isChecked() is True


def test_search_matcher():
    assert _match(0x41, "0x41") and not _match(0x42, "0x41")
    assert _match(65, "65")
    assert _match(0xDB, "block")             # "full block" in the name
    assert _match(0xB1, "shade")             # "medium shade"
    assert not _match(0x41, "shade")
    assert _match(0x03, CP437_TO_UNICODE[0x03])   # literal character match
    assert _match(0x20, "")                   # empty query matches all


def test_search_filters_grid_visibility(qapp, rom):
    gp = GlyphPicker(rom)
    gp.show()
    gp.search.setText("0xDB")
    vis = [c for c, b in gp._buttons.items() if b.isVisibleTo(gp)]
    assert vis == [0xDB]
    gp.search.setText("")
    assert all(b.isVisibleTo(gp) for b in gp._buttons.values())


def test_bank_combo_change_emits_bankchanged(qapp, rom):
    gp = GlyphPicker(rom)
    seen = []
    gp.bankChanged.connect(seen.append)
    gp.combo.setCurrentIndex(3)
    assert seen == [3]
    assert gp.bank_index() == 3
    # programmatic set_bank must NOT re-emit
    gp.set_bank(5)
    assert seen == [3]
    assert gp.bank_index() == 5


def test_bank_switch_leaves_composite_identical(qapp):
    doc = Document()
    lyr = BlankLayer(name="art")
    lyr.set_local(1, 1, Cell(0x41, 0x2A))
    lyr.set_local(2, 3, Cell(0xB1, 0x14))
    doc.add_layer(lyr)

    before = doc.composite()
    for bank in range(16):
        doc.font_bank = bank
        assert doc.composite() == before      # bank never touches cell data
