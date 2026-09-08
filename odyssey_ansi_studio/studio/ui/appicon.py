"""
`app_icon()` -- the window / taskbar icon.

A stylized rendition of Anthropic's mascot ("Clawd"), drawn in code in the
warm clay-on-cream palette and a chunky block style that nods at the CP437
graphics this editor exists to make.  No external asset is bundled; the icon
is painted at a range of sizes so the window manager can pick one that fits.
"""

import math

from PySide6.QtCore import QPointF, QRectF, Qt
from PySide6.QtGui import QColor, QIcon, QPainter, QPen, QPixmap

_CREAM = QColor("#F1EBDD")
_CLAY = QColor("#CC785C")
_CLAY_DK = QColor("#A85C42")
_INK = QColor("#2B2A26")

_SIZES = (16, 20, 24, 32, 48, 64, 128, 256)


def _paint(p: QPainter, s: int) -> None:
    u = s / 32.0
    p.setRenderHint(QPainter.Antialiasing, True)

    # rounded cream tile so the mark reads on any panel color
    p.setPen(Qt.NoPen)
    p.setBrush(_CREAM)
    p.drawRoundedRect(QRectF(1 * u, 1 * u, 30 * u, 30 * u), 7 * u, 7 * u)

    cx, cy = 16 * u, 16.5 * u

    # four stubby rays -- the "spark" of the mascot
    p.setPen(QPen(_CLAY_DK, 2.6 * u, Qt.SolidLine, Qt.RoundCap))
    for deg in (-70, -25, 25, 70):
        a = math.radians(deg - 90)
        p.drawLine(QPointF(cx + math.cos(a) * 8.6 * u, cy + math.sin(a) * 8.6 * u),
                   QPointF(cx + math.cos(a) * 12.8 * u, cy + math.sin(a) * 12.8 * u))

    # body
    p.setPen(Qt.NoPen)
    p.setBrush(_CLAY)
    p.drawEllipse(QRectF(cx - 10 * u, cy - 9.5 * u, 20 * u, 19 * u))

    # eyes + smile
    p.setBrush(_INK)
    p.drawEllipse(QRectF(cx - 4.6 * u, cy - 3.2 * u, 3.1 * u, 4.3 * u))
    p.drawEllipse(QRectF(cx + 1.5 * u, cy - 3.2 * u, 3.1 * u, 4.3 * u))
    p.setBrush(Qt.NoBrush)
    p.setPen(QPen(_INK, 1.9 * u, Qt.SolidLine, Qt.RoundCap))
    p.drawArc(QRectF(cx - 4.2 * u, cy - 1.0 * u, 8.4 * u, 7.0 * u),
              200 * 16, 140 * 16)


def app_icon() -> QIcon:
    ic = QIcon()
    for s in _SIZES:
        pm = QPixmap(s, s)
        pm.fill(Qt.transparent)
        p = QPainter(pm)
        try:
            _paint(p, s)
        finally:
            p.end()
        ic.addPixmap(pm)
    return ic
