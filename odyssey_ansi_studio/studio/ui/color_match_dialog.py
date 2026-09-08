"""
`OdysseyColorDialog` -- turn a color sampled from the screen into one of the
Odyssey's 64.

Shows the sampled color and the current pick butted together (split-screen),
their RGB / attr read-outs, a per-channel-RGB or OKLab "closest" suggestion,
and the full 64-color grid to choose from by eye.  `chosen_attr()` returns the
6-bit color byte (no blink / cursor).

The dialog opens with the best match to the sampled color already selected --
no need to touch the metric combo first.  Switching the metric or clicking a
swatch overrides it.
"""

from PySide6.QtCore import QRectF, Qt, Signal
from PySide6.QtGui import QColor, QPainter, QPen
from PySide6.QtWidgets import (
    QComboBox, QDialog, QDialogButtonBox, QGridLayout, QGroupBox, QHBoxLayout,
    QLabel, QVBoxLayout, QWidget,
)

from studio.model.palette import attr_rgb_idx, odyssey_to_rgb, rgb_to_odyssey


def nearest_odyssey(rgb, metric="rgb") -> int:
    """Closest of the 64 color codes to an ``(r, g, b)`` tuple."""
    if metric == "oklab":
        try:
            from studio.convert.image_import import _nearest_oklab
            return int(_nearest_oklab(rgb)) & 0x3F
        except Exception:       # noqa: BLE001 - numpy path is optional
            pass
    return rgb_to_odyssey(*rgb) & 0x3F


class _Split(QWidget):
    """Left half = sampled color, right half = the chosen Odyssey color."""

    def __init__(self):
        super().__init__()
        self.setMinimumHeight(90)
        self._a = QColor(0, 0, 0)
        self._b = QColor(0, 0, 0)

    def set_colors(self, a, b):
        self._a, self._b = QColor(a), QColor(b)
        self.update()

    @staticmethod
    def _ink(c):
        return QColor(255, 255, 255) if c.lightnessF() < 0.5 else QColor(0, 0, 0)

    def paintEvent(self, _e):
        p = QPainter(self)
        w = self.width() / 2
        p.fillRect(QRectF(0, 0, w, self.height()), self._a)
        p.fillRect(QRectF(w, 0, self.width() - w, self.height()), self._b)
        p.setPen(QPen(QColor(0, 0, 0), 1))
        p.drawLine(int(w), 0, int(w), self.height())
        p.setPen(self._ink(self._a))
        p.drawText(QRectF(6, 4, w - 10, 18), Qt.AlignLeft, "sampled")
        p.setPen(self._ink(self._b))
        p.drawText(QRectF(w + 6, 4, w - 10, 18), Qt.AlignLeft, "Odyssey")


class _Swatch(QWidget):
    clicked = Signal()

    def __init__(self, code):
        super().__init__()
        self.code = code
        r, g, b = odyssey_to_rgb(code)
        self._c = QColor(r, g, b)
        self._sel = False
        self.setFixedSize(26, 20)
        self.setCursor(Qt.PointingHandCursor)
        self.setToolTip(f"0x{code:02X}  rgb {r},{g},{b}")

    def set_selected(self, on):
        if on != self._sel:
            self._sel = on
            self.update()

    def mousePressEvent(self, _e):
        self.clicked.emit()

    def paintEvent(self, _e):
        p = QPainter(self)
        p.fillRect(self.rect(), self._c)
        if self._sel:
            p.setPen(QPen(QColor(0, 0, 0), 1))
            p.setBrush(Qt.NoBrush)
            p.drawRect(self.rect().adjusted(0, 0, -1, -1))
            p.setPen(QPen(QColor(255, 255, 255), 2))
            p.drawRect(self.rect().adjusted(2, 2, -3, -3))


class OdysseyColorDialog(QDialog):
    def __init__(self, sampled, current_attr=None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Match an Odyssey color")
        self._sampled = QColor(sampled)
        self._metric = "rgb"
        # Always open on the suggested match for the sampled color; `current_attr`
        # is accepted for call-site compatibility but no longer pre-empts the
        # suggestion (the whole point of sampling is to get a fresh proposal).
        self._chosen = nearest_odyssey(self._srgb(), self._metric)

        root = QVBoxLayout(self)
        self._split = _Split()
        root.addWidget(self._split)

        info = QHBoxLayout()
        self._lbl_sampled = QLabel()
        self._lbl_chosen = QLabel()
        for lb in (self._lbl_sampled, self._lbl_chosen):
            lb.setTextFormat(Qt.PlainText)
        info.addWidget(self._lbl_sampled, 1)
        info.addWidget(self._lbl_chosen, 1)
        root.addLayout(info)

        row = QHBoxLayout()
        row.addWidget(QLabel("Match by"))
        self._cmb = QComboBox()
        self._cmb.addItems(["per-channel RGB", "OKLab (perceptual)"])
        self._cmb.currentIndexChanged.connect(self._on_metric)
        row.addWidget(self._cmb)
        self._lbl_near = QLabel()
        row.addWidget(self._lbl_near, 1)
        root.addLayout(row)

        box = QGroupBox("Odyssey 64")
        grid = QGridLayout(box)
        grid.setSpacing(2)
        self._swatches = []
        for code in range(64):
            sw = _Swatch(code)
            sw.clicked.connect(lambda c=code: self._choose(c))
            grid.addWidget(sw, code // 8, code % 8)
            self._swatches.append(sw)
        root.addWidget(box)

        bb = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        bb.accepted.connect(self.accept)
        bb.rejected.connect(self.reject)
        root.addWidget(bb)

        self._refresh()

    # ---- helpers ----------------------------------------------------
    def _srgb(self):
        s = self._sampled
        return (s.red(), s.green(), s.blue())

    def _on_metric(self, i):
        self._metric = "oklab" if i == 1 else "rgb"
        self._choose(nearest_odyssey(self._srgb(), self._metric))

    def _choose(self, code):
        self._chosen = int(code) & 0x3F
        self._refresh()

    def _refresh(self):
        s = self._sampled
        cr, cg, cb = odyssey_to_rgb(self._chosen)
        self._split.set_colors(s, QColor(cr, cg, cb))
        self._lbl_sampled.setText(
            f"sampled\n{s.name().upper()}\nrgb  {s.red()}, {s.green()}, {s.blue()}")
        ri, gi, bi = attr_rgb_idx(self._chosen)
        self._lbl_chosen.setText(
            f"Odyssey  attr 0x{self._chosen:02X}\n"
            f"rgb  {cr}, {cg}, {cb}\nlevels  {ri}, {gi}, {bi}  (0-3)")
        near = nearest_odyssey(self._srgb(), self._metric)
        mark = "  ✓" if near == self._chosen else ""
        self._lbl_near.setText(f"closest by this metric: 0x{near:02X}{mark}")
        for sw in self._swatches:
            sw.set_selected(sw.code == self._chosen)

    def chosen_attr(self) -> int:
        return self._chosen & 0x3F
