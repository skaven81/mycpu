"""
`nearest_odyssey` / `OdysseyColorDialog`: snap a sampled color to one of the
Odyssey's 64 and let the user override it.
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtGui import QColor
from PySide6.QtWidgets import QApplication

from studio.model.palette import odyssey_to_rgb
from studio.ui.color_match_dialog import OdysseyColorDialog, nearest_odyssey


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def test_nearest_odyssey_round_trips_exact_palette_colors(qapp):
    for code in (0x00, 0x3F, 0x2A, 0x15, 0x30, 0x03):
        assert nearest_odyssey(odyssey_to_rgb(code), "rgb") == code


def test_nearest_odyssey_oklab_returns_valid_code(qapp):
    assert 0 <= nearest_odyssey((123, 200, 45), "oklab") < 64


def test_dialog_preselects_nearest(qapp):
    dlg = OdysseyColorDialog(QColor(255, 255, 255))
    assert dlg.chosen_attr() == 0x3F
    dlg._choose(0x00)
    assert dlg.chosen_attr() == 0x00


def test_dialog_suggests_from_the_sample_not_the_old_ink(qapp):
    # the suggestion is immediate and comes from the sampled color -- the old
    # ink passed as `current_attr` no longer pre-empts it.
    dlg = OdysseyColorDialog(QColor(0, 0, 0), current_attr=0xC0 | 0x2A)
    assert dlg.chosen_attr() == 0x00
    dlg2 = OdysseyColorDialog(QColor(250, 250, 250), current_attr=0x00)
    assert dlg2.chosen_attr() == 0x3F
