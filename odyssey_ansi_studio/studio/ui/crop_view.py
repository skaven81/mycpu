"""
`CropView` -- an image preview with a draggable / resizable crop rectangle.

The crop is stored and reported in **source-image pixel** coordinates
``(x, y, w, h)``.  Drag the interior to move it, a handle to resize it, or an
empty area to sweep a new one.  `cropChanged` fires on every change; feed the
spin boxes from it and call `set_crop()` back the other way (it does not
re-emit).
"""

from PySide6.QtCore import QPoint, QRect, QRectF, Qt, Signal
from PySide6.QtGui import QColor, QImage, QPainter, QPen
from PySide6.QtWidgets import QWidget

_HANDLE = 7          # half-size of a grab handle, screen px
_MIN = 2             # smallest crop, source px


class CropView(QWidget):
    cropChanged = Signal(int, int, int, int)      # x, y, w, h in source pixels

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setMinimumSize(240, 200)
        self._img = QImage()
        self._iw = self._ih = 1
        self._crop = QRect(0, 0, 1, 1)           # source px
        self._drag = None                        # (mode, anchor_pt, start_crop)
        self._enabled_edit = True
        self.setMouseTracking(True)

    # ------------------------------------------------------------------
    def set_image(self, image):
        if isinstance(image, QImage):
            self._img = image
        else:  # a PIL image
            rgb = image.convert("RGB")
            self._img = QImage(rgb.tobytes(), rgb.width, rgb.height,
                               rgb.width * 3, QImage.Format_RGB888).copy()
        self._iw = max(1, self._img.width())
        self._ih = max(1, self._img.height())
        self._crop = QRect(0, 0, self._iw, self._ih)
        self.update()

    def set_edit_enabled(self, on):
        self._enabled_edit = bool(on)
        self.update()

    def crop(self):
        c = self._crop
        return (c.x(), c.y(), c.width(), c.height())

    def set_crop(self, x, y, w, h):
        """External update from the spin boxes -- clamp, redraw, no signal."""
        self._crop = self._clamp(QRect(int(x), int(y), int(w), int(h)))
        self.update()

    # ------------------------------------------------------------------
    def _clamp(self, r: QRect) -> QRect:
        # Keep the origin the user asked for; shrink the size to fit if needed.
        x = max(0, min(r.x(), self._iw - _MIN))
        y = max(0, min(r.y(), self._ih - _MIN))
        w = max(_MIN, min(r.width(), self._iw - x))
        h = max(_MIN, min(r.height(), self._ih - y))
        return QRect(x, y, w, h)

    def _view_rect(self) -> QRectF:
        if self._img.isNull():
            return QRectF(self.rect())
        aw, ah = self.width(), self.height()
        scale = min(aw / self._iw, ah / self._ih)
        vw, vh = self._iw * scale, self._ih * scale
        return QRectF((aw - vw) / 2, (ah - vh) / 2, vw, vh)

    def _scale(self) -> float:
        vr = self._view_rect()
        return vr.width() / self._iw if self._iw else 1.0

    def _img_to_view(self, ix, iy):
        vr = self._view_rect()
        s = self._scale()
        return QPoint(int(vr.x() + ix * s), int(vr.y() + iy * s))

    def _view_to_img(self, vx, vy):
        vr = self._view_rect()
        s = self._scale() or 1.0
        return (int(round((vx - vr.x()) / s)), int(round((vy - vr.y()) / s)))

    def _crop_view_rect(self) -> QRect:
        tl = self._img_to_view(self._crop.x(), self._crop.y())
        br = self._img_to_view(self._crop.right() + 1, self._crop.bottom() + 1)
        return QRect(tl, br)

    def _handles(self):
        r = self._crop_view_rect()
        cx, cy = r.center().x(), r.center().y()
        return {
            "nw": r.topLeft(), "n": QPoint(cx, r.top()), "ne": r.topRight(),
            "w": QPoint(r.left(), cy), "e": QPoint(r.right(), cy),
            "sw": r.bottomLeft(), "s": QPoint(cx, r.bottom()), "se": r.bottomRight(),
        }

    def _hit(self, pos):
        for name, hp in self._handles().items():
            if abs(pos.x() - hp.x()) <= _HANDLE and abs(pos.y() - hp.y()) <= _HANDLE:
                return name
        if self._crop_view_rect().contains(pos):
            return "move"
        return None

    # ------------------------------------------------------------------
    def mousePressEvent(self, e):
        if not self._enabled_edit or self._img.isNull():
            return
        mode = self._hit(e.position().toPoint()) or "new"
        self._drag = (mode, e.position().toPoint(), QRect(self._crop))
        if mode == "new":
            ix, iy = self._view_to_img(e.position().x(), e.position().y())
            self._crop = self._clamp(QRect(ix, iy, _MIN, _MIN))
            self._drag = ("se", e.position().toPoint(), QRect(self._crop))
            self._emit()

    def mouseMoveEvent(self, e):
        if self._drag is None:
            return
        mode, _anchor, start = self._drag
        s = self._scale() or 1.0
        dx = int(round((e.position().x() - _anchor.x()) / s))
        dy = int(round((e.position().y() - _anchor.y()) / s))
        r = QRect(start)
        if mode == "move":
            r.translate(dx, dy)
        else:
            if "n" in mode:
                r.setTop(start.top() + dy)
            if "s" in mode:
                r.setBottom(start.bottom() + dy)
            if "w" in mode:
                r.setLeft(start.left() + dx)
            if "e" in mode:
                r.setRight(start.right() + dx)
            r = r.normalized()
        self._crop = self._clamp(r)
        self._emit()

    def mouseReleaseEvent(self, e):
        self._drag = None

    def _emit(self):
        self.update()
        c = self._crop
        self.cropChanged.emit(c.x(), c.y(), c.width(), c.height())

    # ------------------------------------------------------------------
    def paintEvent(self, _e):
        p = QPainter(self)
        p.fillRect(self.rect(), self.palette().window())
        if self._img.isNull():
            p.drawText(self.rect(), Qt.AlignCenter, "(no image)")
            return
        vr = self._view_rect()
        p.drawImage(vr, self._img)

        cr = self._crop_view_rect()
        # dim everything outside the crop
        shade = QColor(0, 0, 0, 120)
        p.setPen(Qt.NoPen)
        p.setBrush(shade)
        p.drawRect(QRectF(vr.left(), vr.top(), vr.width(), cr.top() - vr.top()))
        p.drawRect(QRectF(vr.left(), cr.bottom(), vr.width(), vr.bottom() - cr.bottom()))
        p.drawRect(QRectF(vr.left(), cr.top(), cr.left() - vr.left(), cr.height()))
        p.drawRect(QRectF(cr.right(), cr.top(), vr.right() - cr.right(), cr.height()))

        p.setBrush(Qt.NoBrush)
        p.setPen(QPen(QColor(0, 200, 255), 1))
        p.drawRect(cr)
        if self._enabled_edit:
            p.setBrush(QColor(0, 200, 255))
            for hp in self._handles().values():
                p.drawRect(hp.x() - 3, hp.y() - 3, 6, 6)
