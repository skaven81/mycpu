"""Offscreen: CropView clamps, maps coordinates, and round-trips with set_crop."""

import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest

from PySide6.QtCore import QPointF, Qt
from PySide6.QtGui import QMouseEvent, QPointingDevice
from PySide6.QtWidgets import QApplication
from PIL import Image

from studio.ui.crop_view import CropView


@pytest.fixture(scope="module")
def qapp():
    return QApplication.instance() or QApplication([])


def _view(qapp, w=100, h=80):
    v = CropView()
    v.resize(200, 200)
    v.set_image(Image.new("RGB", (w, h), (20, 20, 20)))
    v.show()
    qapp.processEvents()
    return v


def test_set_image_defaults_to_whole_image(qapp):
    v = _view(qapp, 64, 48)
    assert v.crop() == (0, 0, 64, 48)


def test_set_crop_clamps_into_bounds(qapp):
    v = _view(qapp, 100, 80)
    v.set_crop(-10, -10, 5000, 5000)
    assert v.crop() == (0, 0, 100, 80)
    v.set_crop(90, 70, 40, 40)
    assert v.crop() == (90, 70, 10, 10)
    v.set_crop(10, 10, 0, 0)
    x, y, w, h = v.crop()
    assert w >= 2 and h >= 2


def test_drag_interior_moves_crop_and_emits(qapp):
    v = _view(qapp, 100, 100)
    v.set_crop(10, 10, 20, 20)
    seen = []
    v.cropChanged.connect(lambda *a: seen.append(a))

    s = v._scale()
    start = v._img_to_view(20, 20)      # inside the crop
    _press(v, start.x(), start.y())
    _move(v, start.x() + 5 * s, start.y() + 3 * s)
    _release(v, start.x() + 5 * s, start.y() + 3 * s)

    x, y, w, h = v.crop()
    assert (w, h) == (20, 20)
    assert x == 15 and y == 13
    assert seen and seen[-1] == (15, 13, 20, 20)


def test_drag_handle_resizes(qapp):
    v = _view(qapp, 100, 100)
    v.set_crop(10, 10, 30, 30)
    br = v._crop_view_rect().bottomRight()
    s = v._scale()
    _press(v, br.x(), br.y())
    _move(v, br.x() + 10 * s, br.y() + 10 * s)
    _release(v, br.x() + 10 * s, br.y() + 10 * s)
    x, y, w, h = v.crop()
    assert (x, y) == (10, 10)
    assert w > 30 and h > 30


def _press(v, x, y):
    v.mousePressEvent(_ev(QMouseEvent.Type.MouseButtonPress, x, y))


def _move(v, x, y):
    v.mouseMoveEvent(_ev(QMouseEvent.Type.MouseMove, x, y))


def _release(v, x, y):
    v.mouseReleaseEvent(_ev(QMouseEvent.Type.MouseButtonRelease, x, y))


_DEV = QPointingDevice.primaryPointingDevice()


def _ev(kind, x, y):
    return QMouseEvent(kind, QPointF(x, y), QPointF(x, y), Qt.LeftButton,
                       Qt.LeftButton, Qt.NoModifier, _DEV)
