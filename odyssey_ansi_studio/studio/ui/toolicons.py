"""
`tool_icon(key)` -- an icon for a tool-rail entry.

Order of preference:
    1. a distinct hand-drawn picture of what the tool does;
    2. a freedesktop theme icon (fallback for keys with no drawing).

The drawings come first because the running desktop's themed / `QStyle` icons
repeatedly turned out unsuitable here -- several paint tools resolved to
near-identical or plain wrong art (Select showed a pencil, Flood Fill a water
drop, Cell Edit matched Select).  Each drawing below is a literal picture of
what the tool does (a dashed marquee for select, a gear + wrench for cell edit,
a four-way arrow for move, a paint can for flood fill, a brush for recolor,
...), stroked in the current ``ButtonText`` color so it tracks light / dark
themes.
"""

import math

from PySide6.QtCore import QPointF, QRectF, Qt
from PySide6.QtGui import (
    QBrush, QColor, QIcon, QLinearGradient, QPainter, QPalette, QPen, QPixmap,
    QPolygonF,
)
from PySide6.QtWidgets import QApplication

_SIZE = 24

#: candidate freedesktop names per tool, most specific first
_THEME = {
    "select":     ["edit-select", "tool-rect-select", "select-rectangular"],
    "cell-edit":  ["document-edit", "edit-entry", "cell-edit"],
    "move-layer": ["transform-move", "object-move", "transform-move-symbolic"],
    "pencil":     ["draw-freehand", "tool-pencil", "draw-pencil"],
    "eraser":     ["draw-eraser", "tool-eraser"],
    "line":       ["draw-line", "tool-line"],
    "rectangle":  ["draw-rectangle", "tool-rectangle"],
    "ellipse":    ["draw-ellipse", "tool-ellipse", "draw-circle"],
    "flood-fill": ["color-fill", "tool-fill", "fill-color"],
    "gradient":   ["color-gradient", "tool-gradient", "fill-gradient-linear"],
    "recolor":   ["draw-brush", "paint-brush", "tool-brush", "format-fill-color"],
    "eyedropper": ["color-picker", "tool-color-picker", "gtk-color-picker"],
    "box":        ["insert-object", "draw-rectangle"],
    "text":       ["insert-text", "draw-text", "format-text-rich"],
    "image":      ["insert-image", "image-x-generic", "insert-photo"],
    "blank":      ["layer-new", "document-new", "list-add"],
}


def _ink() -> QColor:
    app = QApplication.instance()
    if app is not None:
        return app.palette().color(QPalette.ColorRole.ButtonText)
    return QColor(60, 60, 60)


def _pen(p: QPainter, w: float = 1.7) -> None:
    pen = QPen(_ink(), w)
    pen.setJoinStyle(Qt.RoundJoin)
    pen.setCapStyle(Qt.RoundCap)
    p.setPen(pen)
    p.setBrush(Qt.NoBrush)


def _tri(p: QPainter, tip, back, half: float) -> None:
    """A small filled triangle -- arrowhead / nib / drop."""
    tx, ty = tip
    bx, by = back
    dx, dy = tx - bx, ty - by
    ln = (dx * dx + dy * dy) ** 0.5 or 1.0
    px, py = -dy / ln * half, dx / ln * half
    poly = QPolygonF([QPointF(tx, ty),
                      QPointF(bx + px, by + py),
                      QPointF(bx - px, by - py)])
    p.setBrush(_ink())
    p.drawPolygon(poly)
    p.setBrush(Qt.NoBrush)


# ---- one painter per tool; canvas is 24x24 -----------------------------------

def _d_select(p):
    pen = QPen(_ink(), 1.5)
    pen.setDashPattern([2.0, 1.8])          # tight, even dashes on every side
    p.setPen(pen)
    p.setBrush(Qt.NoBrush)
    p.drawRect(QRectF(3.5, 4.5, 16, 14))


def _gear(p, cx, cy, r_in, r_out, teeth=8):
    _pen(p, 1.3)
    for k in range(teeth):
        a = math.tau * k / teeth
        ca, sa = math.cos(a), math.sin(a)
        p.drawLine(QPointF(cx + ca * r_in, cy + sa * r_in),
                   QPointF(cx + ca * r_out, cy + sa * r_out))
    p.drawEllipse(QPointF(cx, cy), r_in, r_in)
    p.drawEllipse(QPointF(cx, cy), r_in * 0.42, r_in * 0.42)


def _d_cell_edit(p):
    # a gear (settings) crossed by a wrench -- "edit this cell's properties"
    _gear(p, 9.0, 13.5, 4.1, 6.0)
    _pen(p, 1.9)
    p.drawLine(QPointF(12.5, 15.5), QPointF(19.5, 8.5))     # wrench handle
    p.drawLine(QPointF(19.5, 8.5), QPointF(21.0, 6.0))      # open jaw
    p.drawLine(QPointF(19.5, 8.5), QPointF(17.2, 7.2))
    p.setBrush(_ink())
    p.drawEllipse(QPointF(12.0, 16.0), 1.7, 1.7)            # closed ring end
    p.setBrush(Qt.NoBrush)


def _d_move(p):
    _pen(p, 1.6)
    p.drawLine(QPointF(12, 5), QPointF(12, 19))
    p.drawLine(QPointF(5, 12), QPointF(19, 12))
    _tri(p, (12, 2.5), (12, 7), 3.0)
    _tri(p, (12, 21.5), (12, 17), 3.0)
    _tri(p, (2.5, 12), (7, 12), 3.0)
    _tri(p, (21.5, 12), (17, 12), 3.0)


def _d_pencil(p):
    _pen(p, 1.6)
    p.drawLine(QPointF(15.5, 5.5), QPointF(8, 13))
    p.drawLine(QPointF(18, 8), QPointF(10.5, 15.5))
    p.drawLine(QPointF(15.5, 5.5), QPointF(18, 8))
    p.drawLine(QPointF(8, 13), QPointF(10.5, 15.5))
    _tri(p, (5.2, 18.8), (9.25, 14.25), 2.6)


def _d_eraser(p):
    _pen(p, 1.5)
    p.drawPolygon(QPolygonF([QPointF(6, 14), QPointF(13, 7),
                             QPointF(19, 11), QPointF(12, 18)]))
    p.drawLine(QPointF(12, 18), QPointF(19, 11))
    p.drawLine(QPointF(4.5, 19.5), QPointF(15, 19.5))


def _d_line(p):
    _pen(p, 1.7)
    p.drawLine(QPointF(5, 19), QPointF(19, 5))
    p.setBrush(_ink())
    p.drawEllipse(QPointF(5, 19), 2, 2)
    p.drawEllipse(QPointF(19, 5), 2, 2)
    p.setBrush(Qt.NoBrush)


def _d_rectangle(p):
    _pen(p, 1.7)
    p.drawRect(QRectF(4, 6, 16, 12))


def _d_ellipse(p):
    _pen(p, 1.7)
    p.drawEllipse(QRectF(4, 6, 16, 12))


def _d_fill(p):
    # an upright paint can: tapered body, paint surface, bail handle, one drip
    _pen(p, 1.6)
    p.drawPolygon(QPolygonF([QPointF(6.5, 7.5), QPointF(17.5, 7.5),
                             QPointF(16.0, 19.0), QPointF(8.0, 19.0)]))
    p.drawArc(QRectF(7.5, 2.0, 9, 8), 15 * 16, 150 * 16)      # bail handle
    p.setBrush(_ink())
    p.drawEllipse(QRectF(6.5, 5.5, 11, 4))                    # paint surface
    p.drawEllipse(QPointF(12.0, 21.0), 1.6, 2.1)             # drip
    p.setBrush(Qt.NoBrush)


def _d_gradient(p):
    g = QLinearGradient(4, 0, 20, 0)
    c0 = QColor(_ink()); c0.setAlpha(235)
    c1 = QColor(_ink()); c1.setAlpha(25)
    g.setColorAt(0.0, c0)
    g.setColorAt(1.0, c1)
    p.fillRect(QRectF(4, 6, 16, 12), QBrush(g))
    _pen(p, 1.4)
    p.drawRect(QRectF(4, 6, 16, 12))


def _d_recolor(p):
    _pen(p, 1.6)
    p.drawLine(QPointF(19, 4), QPointF(12, 11))
    p.setBrush(_ink())
    p.drawPolygon(QPolygonF([QPointF(10.5, 9.5), QPointF(13.5, 12.5),
                             QPointF(11.5, 14.5), QPointF(8.5, 11.5)]))
    p.setBrush(Qt.NoBrush)
    p.drawPolygon(QPolygonF([QPointF(8.5, 11.5), QPointF(5, 16),
                             QPointF(8, 19), QPointF(11.5, 14.5)]))
    p.drawArc(QRectF(3, 16.5, 8, 5), 0, -180 * 16)


def _d_eyedropper(p):
    _pen(p, 1.6)
    p.drawLine(QPointF(17, 4), QPointF(10, 11))
    p.setBrush(_ink())
    p.drawEllipse(QRectF(15.3, 2.3, 5, 5))
    p.setBrush(Qt.NoBrush)
    p.drawPolyline(QPolygonF([QPointF(10, 11), QPointF(7, 15.5),
                              QPointF(9.5, 18), QPointF(13.5, 14)]))
    _tri(p, (5.4, 20.2), (8.25, 16.75), 2.2)


def _d_box(p):
    _pen(p, 1.5)
    p.drawRect(QRectF(3.5, 5.5, 17, 13))
    p.drawRect(QRectF(6, 8, 12, 8.5))


def _d_text(p):
    _pen(p, 1.9)
    p.drawLine(QPointF(5, 6.5), QPointF(19, 6.5))
    p.drawLine(QPointF(12, 6.5), QPointF(12, 18.5))


def _d_image(p):
    _pen(p, 1.5)
    p.drawRect(QRectF(3.5, 5.5, 17, 13))
    p.setBrush(_ink())
    p.drawEllipse(QRectF(7, 8, 3.2, 3.2))
    p.setBrush(Qt.NoBrush)
    p.drawPolyline(QPolygonF([QPointF(4, 17), QPointF(9, 12), QPointF(12, 15),
                              QPointF(16, 10), QPointF(20, 16)]))


def _d_blank(p):
    # a fresh sheet with a "+" -- an empty new layer
    _pen(p, 1.5)
    p.drawRect(QRectF(4.5, 3.5, 12, 15))
    _pen(p, 1.9)
    p.drawLine(QPointF(17.5, 15), QPointF(17.5, 21))
    p.drawLine(QPointF(14.5, 18), QPointF(20.5, 18))


_CUSTOM = {
    "select": _d_select, "cell-edit": _d_cell_edit, "move-layer": _d_move,
    "pencil": _d_pencil, "eraser": _d_eraser, "line": _d_line,
    "rectangle": _d_rectangle, "ellipse": _d_ellipse, "flood-fill": _d_fill,
    "gradient": _d_gradient, "recolor": _d_recolor, "eyedropper": _d_eyedropper,
    "box": _d_box, "text": _d_text, "image": _d_image, "blank": _d_blank,
}


def tool_icon(key: str) -> QIcon:
    """A distinct hand-drawn icon for tool `key`; a freedesktop theme icon
    only as a fallback for keys with no drawing."""
    fn = _CUSTOM.get(key)
    if fn is not None:
        return _icon_from(fn)
    for name in _THEME.get(key, []):
        ic = QIcon.fromTheme(name)
        if not ic.isNull():
            return ic
    return QIcon()


def _icon_from(fn) -> QIcon:
    pm = QPixmap(_SIZE, _SIZE)
    pm.fill(Qt.transparent)
    p = QPainter(pm)
    p.setRenderHint(QPainter.Antialiasing, True)
    try:
        fn(p)
    finally:
        p.end()
    return QIcon(pm)


# ---- layer-row state icons (visibility / lock) ------------------------------
#
# The layer list needs icons that read as *state*, not as a yes/no button --
# an eye that is struck through when the layer is hidden, a padlock that is
# open when the layer is unlocked.  Same custom-first reasoning as the tools:
# the desktop's "visibility" / "object-locked" names resolve to a green tick
# and a red cross here, which say nothing about what the toggle does.

def _d_eye(p):
    _pen(p, 1.6)
    p.drawPolyline(QPolygonF([QPointF(3.5, 12), QPointF(7, 8), QPointF(12, 6.5),
                              QPointF(17, 8), QPointF(20.5, 12)]))
    p.drawPolyline(QPolygonF([QPointF(3.5, 12), QPointF(7, 16), QPointF(12, 17.5),
                              QPointF(17, 16), QPointF(20.5, 12)]))
    p.setBrush(_ink())
    p.drawEllipse(QPointF(12, 12), 2.7, 2.7)
    p.setBrush(Qt.NoBrush)


def _d_eye_off(p):
    _d_eye(p)
    pen = QPen(QColor(210, 45, 45), 2.2)
    pen.setCapStyle(Qt.RoundCap)
    p.setPen(pen)
    p.drawLine(QPointF(4.5, 5.5), QPointF(19.5, 18.5))


def _lock_body(p):
    p.setBrush(_ink())
    p.setPen(QPen(_ink(), 1.2))
    p.drawRoundedRect(QRectF(5.5, 10, 13, 10.5), 1.6, 1.6)
    p.setBrush(Qt.NoBrush)
    p.setPen(QPen(_slot_color(), 1.8))
    p.drawLine(QPointF(12, 13.2), QPointF(12, 17.2))        # keyhole slot


def _d_lock_closed(p):
    _pen(p, 1.6)
    p.drawArc(QRectF(7.5, 3.5, 9, 11), 0, 180 * 16)         # shackle down over body
    _lock_body(p)


def _d_lock_open(p):
    _pen(p, 1.6)
    # same body, shackle lifted and swung open to the left
    p.drawArc(QRectF(3.5, 2.0, 9, 11), 80 * 16, 170 * 16)
    _lock_body(p)


def _slot_color():
    # a keyhole color that contrasts with the filled lock body in either theme
    c = _ink()
    return QColor(255, 255, 255) if c.lightnessF() < 0.5 else QColor(245, 245, 245)


def layer_vis_icon(visible: bool) -> QIcon:
    """Eye when `visible`, eye with a red slash when hidden."""
    return _icon_from(_d_eye if visible else _d_eye_off)


def layer_lock_icon(locked: bool) -> QIcon:
    """Closed padlock when `locked`, open padlock when unlocked."""
    return _icon_from(_d_lock_closed if locked else _d_lock_open)
