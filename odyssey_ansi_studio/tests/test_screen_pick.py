"""Offscreen: screen-eyedropper back-end selection + portal colour parsing.

The portal path is never actually invoked here (it would pop the compositor's
UI); we test the RGB extraction helper and that `pick_screen_color` falls back
to the frozen-overlay picker when the portal is unavailable.
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtWidgets import QApplication

from studio.ui import screen_pick


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def test_extract_rgb_from_plain_sequence():
    assert screen_pick._extract_rgb({"color": [1.0, 0.0, 0.5]}) == (1.0, 0.0, 0.5)


def test_extract_rgb_unwraps_jeepney_variant_tuple():
    # jeepney parses the portal a{sv} to a dict; the color value is a
    # (signature, payload) variant tuple around the (ddd) struct.
    res = {"color": ("(ddd)", (0.25, 0.5, 0.75))}
    assert screen_pick._extract_rgb(res) == (0.25, 0.5, 0.75)


def test_extract_rgb_missing_or_unreadable_is_none():
    assert screen_pick._extract_rgb({}) is None
    assert screen_pick._extract_rgb({"color": "nope"}) is None
    assert screen_pick._extract_rgb({"color": ("(dd)", (0.1, 0.2))}) is None


def test_pick_screen_color_falls_back_to_overlay(qapp, monkeypatch):
    """With no portal, the public entry point builds the overlay picker."""
    monkeypatch.setattr(screen_pick, "_portal_pick_color",
                        lambda *a, **k: None)

    class FakeParent:
        pass

    parent = FakeParent()
    got = []
    w = screen_pick.pick_screen_color(parent, got.append)
    assert isinstance(w, screen_pick.ScreenColorPicker)
    assert parent._screen_color_picker is w

    # simulate a click landing on a known pixel of the frozen image
    from PySide6.QtGui import QColor
    w._img.fill(QColor(12, 34, 56).rgb())
    w.picked.emit(w.color_at(5, 5))
    assert got and (got[0].red(), got[0].green(), got[0].blue()) == (12, 34, 56)
    w.close()


def test_pick_screen_color_prefers_portal(qapp, monkeypatch):
    sentinel = object()
    monkeypatch.setattr(screen_pick, "_portal_pick_color",
                        lambda parent, on_picked, on_cancel: sentinel)
    assert screen_pick.pick_screen_color(None, lambda _c: None) is sentinel


def test_grab_virtual_desktop_is_logical_sized(qapp):
    pm, origin = screen_pick.grab_virtual_desktop()
    assert pm.devicePixelRatio() == 1.0
    assert not pm.isNull()
