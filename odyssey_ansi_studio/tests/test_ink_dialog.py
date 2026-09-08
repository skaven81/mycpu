"""Offscreen: the unified `InkChooser` / `InkPickerDialog` / `AttrField` and
ink inheritance + shared project palette in the Box / Text layer dialogs."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtWidgets import QApplication

from studio.model.document import Document
from studio.model.layers import BlankLayer
from studio.ui.box_dialog import BoxDialog
from studio.ui.ink_dialog import AttrField, InkDialog
from studio.ui.palette_panel import InkChooser, InkPickerDialog, PalettePanel
from studio.ui.text_layer_edit import TextLayerDialog


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def test_ink_dialog_is_the_shared_chooser(qapp):
    # InkDialog is now an alias for the unified modal picker.
    assert InkDialog is InkPickerDialog
    d = InkPickerDialog(0x2A)
    assert d.selected_attr() == 0x2A
    assert isinstance(d.chooser, InkChooser)
    d.chooser._pick_rgb(0x15)
    assert d.selected_attr() == 0x15
    d.chooser._sliders["R"].setValue(3)
    assert d.selected_attr() == 0x35


def test_palette_panel_is_an_ink_chooser(qapp):
    # the main-window dock panel and the modal share one implementation
    assert issubclass(PalettePanel, InkChooser)


def test_ink_picker_shares_the_document_project_palette(qapp):
    doc = Document()
    doc.add_layer(BlankLayer(name="l0"))
    doc.project_palette = [{"name": "sky", "attr": 0x0B},
                           {"name": "rust", "attr": 0x30}]
    d = InkPickerDialog(0x00, document=doc)
    assert d.chooser.pp_list.count() == 2
    # picking a saved color drives the dialog's result
    d.chooser._pp_row_clicked(d.chooser.pp_list.item(1))
    assert d.selected_attr() == 0x30
    # adding one from the dialog mutates the shared document list
    d.chooser.set_ink(0x2A)
    d.chooser._pp_add()
    assert [e["attr"] for e in doc.project_palette] == [0x0B, 0x30, 0x2A]


def test_attr_field_roundtrips(qapp):
    f = AttrField(0x0F)
    assert f.value() == 0x0F
    f.setValue(0x3F)
    assert f.value() == 0x3F
    seen = []
    f.changed.connect(seen.append)
    f.setValue(0x21)
    assert seen == [0x21]


def test_new_text_layer_inherits_ink(qapp):
    dlg = TextLayerDialog(ink=0x2B)
    assert dlg.result_params()["text_attr"] == 0x2B
    # re-editing an existing layer keeps its stored color
    keep = TextLayerDialog({"text": "x", "w": 6, "h": 3, "text_attr": 0x07},
                           ink=0x2B)
    assert keep.result_params()["text_attr"] == 0x07


def test_new_box_layer_inherits_ink(qapp):
    dlg = BoxDialog(ink=0x31)
    rp = dlg.result_params()
    assert rp["box_attr"] == 0x31 and rp["fill_attr"] == 0x31
    keep = BoxDialog({"style": "single", "w": 8, "h": 4, "box_attr": 0x0A},
                     ink=0x31)
    assert keep.result_params()["box_attr"] == 0x0A


def test_box_dialog_header_footer_colors_and_flair(qapp):
    dlg = BoxDialog({"style": "single", "w": 20, "h": 6, "box_attr": 0x0F,
                     "title": "HELLO", "title_attr": 0x2A, "title_flair": "line",
                     "footer": "BYE", "footer_attr": 0x30,
                     "footer_flair": "braces"})
    rp = dlg.result_params()
    assert rp["title_attr"] == 0x2A and rp["footer_attr"] == 0x30
    assert rp["title_flair"] == "line" and rp["footer_flair"] == "braces"
    # a fresh dialog defaults the header / footer color to the border color
    fresh = BoxDialog(ink=0x11)
    frp = fresh.result_params()
    assert frp["title_attr"] == 0x11 and frp["footer_attr"] == 0x11
    assert frp["title_flair"] == "none"
