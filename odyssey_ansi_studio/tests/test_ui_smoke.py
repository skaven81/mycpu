"""
Offscreen smoke test: the window builds and the canvas renders a frame.

Runs under QT_QPA_PLATFORM=offscreen (forced here so the suite needs no
display).  Asserts construction raises nothing and the rendered canvas has at
least one non-black pixel (the demo document paints plenty).
"""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtCore import QSettings
from PySide6.QtWidgets import QApplication

from studio.io.project_file import load_project
from studio.ui import main_window as mw_mod
from studio.ui.demo import DEMO_CARET, DEMO_SELECTION, demo_document
from studio.ui.export_dialog import ExportAnsDialog
from studio.ui.main_window import MainWindow


@pytest.fixture(scope="module")
def qapp():
    app = QApplication.instance() or QApplication([])
    yield app


def _has_non_black(image):
    for y in range(0, image.height(), 5):
        for x in range(0, image.width(), 5):
            c = image.pixelColor(x, y)
            if c.red() or c.green() or c.blue():
                return True
    return False


def test_main_window_builds_and_renders(qapp):
    win = MainWindow(demo_document())
    win.canvas.set_demo_selection(DEMO_SELECTION)
    win.canvas.set_caret(DEMO_CARET)
    win.resize(1280, 860)
    win.show()
    win.canvas.refresh()
    qapp.processEvents()

    img = win.canvas.grab().toImage()
    assert not img.isNull()
    assert img.width() > 0 and img.height() > 0
    assert _has_non_black(img), "canvas rendered all black"
    win.close()


def test_font_bank_switch_refreshes(qapp):
    win = MainWindow(demo_document())
    win.show()
    qapp.processEvents()
    win._set_font_bank(3)
    assert win.document.font_bank == 3
    assert win.is_dirty() is True          # bank is a document property
    win.canvas.refresh()
    qapp.processEvents()
    img = win.canvas.grab().toImage()
    assert _has_non_black(img)
    win._set_clean()
    win.close()


def test_view_toggles_do_not_raise(qapp):
    win = MainWindow(demo_document())
    win.show()
    qapp.processEvents()
    win._set_grid(True)
    win._set_rulers(False)
    win._set_blink_preview(False)
    win.canvas.zoom_in()
    win.canvas.zoom_out()
    win.canvas.zoom_reset()
    win.canvas.fit_to_window()
    qapp.processEvents()
    win.close()


def _isolated_settings(tmp_path):
    return QSettings(str(tmp_path / "settings.ini"), QSettings.IniFormat)


def test_save_as_then_load_roundtrips(qapp, tmp_path, monkeypatch):
    target = str(tmp_path / "foo.oas")
    win = MainWindow(demo_document(), settings=_isolated_settings(tmp_path))
    monkeypatch.setattr(mw_mod.QFileDialog, "getSaveFileName",
                        lambda *a, **k: (target, ""))

    assert win._file_save_as() is True
    assert os.path.exists(target)
    assert win.current_path() == target
    assert win.is_dirty() is False

    reloaded = load_project(target)
    assert reloaded.to_dict() == win.document.to_dict()
    win.close()


def test_save_as_pushes_recent_menu(qapp, tmp_path, monkeypatch):
    target = os.path.join(str(tmp_path), "bar.oas")
    settings = _isolated_settings(tmp_path)
    win = MainWindow(demo_document(), settings=settings)
    assert win.m_recent.isEnabled() is False  # empty at start

    monkeypatch.setattr(mw_mod.QFileDialog, "getSaveFileName",
                        lambda *a, **k: (target, ""))
    win._file_save_as()

    texts = [a.text() for a in win.m_recent.actions()]
    assert os.path.abspath(target) in texts
    assert "Clear Recent" in texts
    assert win.m_recent.isEnabled() is True
    assert os.path.abspath(target) in [str(p) for p in settings.value("recentFiles")]
    win.close()


def test_new_document_guard_and_clean(qapp, tmp_path):
    win = MainWindow(demo_document(), settings=_isolated_settings(tmp_path))
    win.mark_dirty()
    assert win.is_dirty() is True
    # Clear the flag so New's Save/Discard/Cancel guard does not prompt.
    win._set_clean()
    win._file_new()
    assert win.current_path() is None
    assert win.is_dirty() is False
    assert len(win.document.layers) == 1
    win.close()


def test_export_dialog_recomputes_and_warns(qapp):
    dlg = ExportAnsDialog(demo_document())
    res = dlg.export_result()
    assert res is not None
    assert res.data.startswith(b"\x1b[H")
    assert res.byte_count > 0

    base_count = res.byte_count
    dlg.chk_newline.setChecked(True)  # add \r\n per row
    grown = dlg.export_result()
    assert grown.byte_count > base_count
    assert grown.rows_emitted > 0
    assert grown.byte_count == base_count + 2 * grown.rows_emitted

    # The demo places three 0x03 (heart) control-code cells.
    assert dlg.warn_list.count() == 3
    assert dlg.warn_box.isVisibleTo(dlg) or not dlg.isVisible()
    assert "→ 0x03" in dlg.warn_list.item(0).text()


def test_export_dialog_null_mode_combo_changes_output(qapp):
    dlg = ExportAnsDialog(demo_document())
    space = dlg.export_result().data
    # switch to "transparent"
    for i in range(dlg.cb_null.count()):
        if dlg.cb_null.itemData(i) == "transparent":
            dlg.cb_null.setCurrentIndex(i)
            break
    trans = dlg.export_result().data
    assert trans != space
    assert not trans.startswith(b"\x1b[H")     # transparent mode: no leading home
    assert b"\x1b[1;1H" in trans               # absolute row positioning
    # and "block"
    for i in range(dlg.cb_null.count()):
        if dlg.cb_null.itemData(i) == "block":
            dlg.cb_null.setCurrentIndex(i)
            break
    assert b"\xdb" in dlg.export_result().data


def test_export_dialog_save_writes_binary(qapp, tmp_path, monkeypatch):
    out = str(tmp_path / "art")  # no suffix -> dialog adds .ans
    dlg = ExportAnsDialog(demo_document())
    monkeypatch.setattr("studio.ui.export_dialog.QFileDialog.getSaveFileName",
                        lambda *a, **k: (out, ""))
    dlg._on_save()
    written = open(out + ".ans", "rb").read()
    assert written == dlg.export_result().data
    assert written.startswith(b"\x1b[H")
