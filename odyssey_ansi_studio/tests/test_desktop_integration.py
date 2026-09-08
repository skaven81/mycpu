"""Offscreen: XDG desktop integration writes a well-formed .desktop + icons
into XDG_DATA_HOME and is idempotent."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import sys

import pytest

from PySide6.QtWidgets import QApplication

from studio.ui import desktop_integration as di


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


@pytest.mark.skipif(sys.platform != "linux", reason="XDG integration is Linux-only")
def test_writes_desktop_and_icons(qapp, tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    monkeypatch.setattr(di, "_refresh_caches", lambda *_a, **_k: None)

    path = di.ensure_desktop_integration(force=True)
    assert path is not None and path.exists()

    text = path.read_text()
    assert text.startswith("[Desktop Entry]")
    assert f"StartupWMClass={di.APP_ID}" in text
    assert f"Icon={di.APP_ID}" in text
    assert "Exec=" in text and "%F" in text

    icons = sorted(tmp_path.glob("icons/hicolor/*/apps/*.png"))
    assert len(icons) >= 4
    assert all(p.name == f"{di.APP_ID}.png" for p in icons)
    assert all(p.stat().st_size > 0 for p in icons)


@pytest.mark.skipif(sys.platform != "linux", reason="XDG integration is Linux-only")
def test_idempotent_second_run_writes_nothing(qapp, tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_DATA_HOME", str(tmp_path))
    monkeypatch.setattr(di, "_refresh_caches", lambda *_a, **_k: None)

    di.ensure_desktop_integration()
    desktop = tmp_path / "applications" / f"{di.APP_ID}.desktop"
    mtime = desktop.stat().st_mtime_ns

    assert di.ensure_desktop_integration() is None      # nothing changed
    assert desktop.stat().st_mtime_ns == mtime


def test_never_raises_on_bad_data_home(qapp, monkeypatch):
    monkeypatch.setenv("XDG_DATA_HOME", "/proc/nonexistent/cannot/write")
    monkeypatch.setattr(di, "_refresh_caches", lambda *_a, **_k: None)
    # a failed write must be swallowed -- desktop integration can never stop
    # the app from starting.
    di.ensure_desktop_integration(force=True)           # no exception
    assert not (di._data_home() / "applications" / f"{di.APP_ID}.desktop").exists()
