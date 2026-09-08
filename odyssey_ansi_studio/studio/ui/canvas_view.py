"""
`CanvasView` -- the read-only rendering surface for a composited `Document`.

WHAT
    A `QAbstractScrollArea` whose viewport shows the document exactly as the
    Odyssey would: black ground, one 8x8 CP437 glyph per cell tinted to its
    6-bit RGB color, no anti-aliasing.  It renders from a cached native
    `QImage` of ``cols*8 x rows*8`` (512x480 for a stock document) and, in
    `paintEvent`, integer-scale-blits that image with smoothing OFF so pixels
    stay crisp at every zoom.

    Phase 1 is view-only.  There is no editing; the selection marquee and caret
    are *drawn* from values pushed in via `set_demo_selection` / `set_caret` so
    later phases can wire them to real interaction without touching the painter.

WHY
    Keeping a pre-composited image and only scaling it in `paintEvent` makes
    zoom and blink redraws trivial, and guarantees the on-screen result is a
    pixel-exact function of `Document.composite_cell` + the selected font bank.
"""

from PySide6.QtCore import QRectF, Qt, QTimer, Signal
from PySide6.QtGui import QColor, QFont, QImage, QPainter, QPen
from PySide6.QtWidgets import QAbstractScrollArea, QWidget

from studio.tools.base import MOD_ALT, MOD_CTRL, MOD_SHIFT

CELL = 8                      # native pixels per cell edge
ZOOM_STEPS = (1, 2, 3, 4, 6, 8)
BLINK_MS = 500                # 2 Hz preview toggle
RULER = 18                    # ruler margin thickness, px
HANDLE = 9                    # active-layer resize handle size / hit slop, px

#: handle key -> resize cursor shape
_HANDLE_CURSOR = {
    "nw": Qt.SizeFDiagCursor, "se": Qt.SizeFDiagCursor,
    "ne": Qt.SizeBDiagCursor, "sw": Qt.SizeBDiagCursor,
    "n": Qt.SizeVerCursor, "s": Qt.SizeVerCursor,
    "e": Qt.SizeHorCursor, "w": Qt.SizeHorCursor,
}

_CHECK_A = QColor(0x3C, 0x3C, 0x3C)
_CHECK_B = QColor(0x58, 0x58, 0x58)


def _make_checker():
    """An 8x8 tile: 2x2 blocks of 4px, two non-black grays (GIMP-style)."""
    img = QImage(CELL, CELL, QImage.Format_ARGB32_Premultiplied)
    img.fill(_CHECK_A)
    p = QPainter(img)
    p.fillRect(0, 0, 4, 4, _CHECK_B)
    p.fillRect(4, 4, 4, 4, _CHECK_B)
    p.end()
    return img


class _Ruler(QWidget):
    """A thin tick/label strip that scroll- and zoom-syncs with the canvas."""

    def __init__(self, canvas: "CanvasView", horizontal: bool):
        super().__init__(canvas)
        self._canvas = canvas
        self._horizontal = horizontal

    def paintEvent(self, _event):
        c = self._canvas
        p = QPainter(self)
        pal = self.palette()
        p.fillRect(self.rect(), pal.window())
        p.setPen(pal.mid().color())
        p.drawLine(self.rect().topLeft(), self.rect().bottomLeft()
                   if not self._horizontal else self.rect().topRight())

        z = c.zoom()
        ox, oy = c.content_origin()
        font = QFont(self.font())
        font.setPointSizeF(6.5)
        p.setFont(font)
        p.setPen(pal.windowText().color())

        if self._horizontal:
            for col in range(c.doc_cols() + 1):
                x = ox + col * CELL * z
                if x < -2 or x > self.width() + 2:
                    continue
                major = (col % 8 == 0)
                tick = self.height() // 2 if major else 4
                p.drawLine(int(x), self.height() - tick, int(x), self.height())
                if major and col < c.doc_cols():
                    p.drawText(int(x) + 2, self.height() - 6, str(col))
        else:
            for row in range(c.doc_rows() + 1):
                y = oy + row * CELL * z
                if y < -2 or y > self.height() + 2:
                    continue
                major = (row % 8 == 0)
                tick = self.width() // 2 if major else 4
                p.drawLine(self.width() - tick, int(y), self.width(), int(y))
                if major and row < c.doc_rows():
                    p.drawText(1, int(y) + 8, str(row))


class CanvasView(QAbstractScrollArea):
    """Scrollable, zoomable, read-only view of a composited document."""

    #: (col, row, Cell|None) for the cell under the pointer.
    cellHovered = Signal(int, int, object)
    #: current integer zoom factor.
    zoomChanged = Signal(int)

    def __init__(self, fontrom, parent=None):
        super().__init__(parent)
        self._fontrom = fontrom
        self._doc = None

        self._zoom = 2                # editor opens at 2x
        self._did_initial_fit = False

        self._blink_preview = True
        self._blink_on = True
        self._show_grid = False
        self._show_rulers = True
        self._show_transparency = False
        self._checker = _make_checker()

        self._demo_selection = None   # QRectF in cell units, or None
        self._caret = None            # (col, row), or None
        self._hover = None            # last (col, row) under the pointer

        self._img_full = QImage(1, 1, QImage.Format_ARGB32_Premultiplied)
        self._img_noblink = QImage(1, 1, QImage.Format_ARGB32_Premultiplied)
        self._bank_error = None       # str when the wanted bank could not load
        self._overflow = set()        # sides ("left"/"right"/"top"/"bottom") with off-canvas cells

        self._controller = None       # studio.tools ToolController, or None
        self._painting = False        # True between a left press and its release

        # active-layer frame + resize handles (shown for select / move tools)
        self._frame_editing = False
        self._frame_drag = None       # dict while dragging a handle
        self._frame_hover = None      # handle key under the pointer

        self.setFrameShape(QAbstractScrollArea.NoFrame)
        self.setFocusPolicy(Qt.StrongFocus)
        self.viewport().setMouseTracking(True)
        self.viewport().setAutoFillBackground(True)

        self._col_ruler = _Ruler(self, horizontal=True)
        self._row_ruler = _Ruler(self, horizontal=False)

        self._blink_timer = QTimer(self)
        self._blink_timer.setInterval(BLINK_MS)
        self._blink_timer.timeout.connect(self._tick_blink)
        self._blink_timer.start()

        self._position_rulers()

    # ---- document ----------------------------------------------------------

    def set_document(self, doc):
        """Point the canvas at ``doc`` and rebuild at the current zoom."""
        self._doc = doc
        self._did_initial_fit = True   # open at 2x, don't auto-fit
        self.refresh()
        self._apply_zoom(self._zoom)

    def document(self):
        return self._doc

    def doc_cols(self):
        return self._doc.width if self._doc is not None else 64

    def doc_rows(self):
        return self._doc.height if self._doc is not None else 60

    def bank_error(self):
        """The last font-bank load error string, or None."""
        return self._bank_error

    # ---- cache build -----------------------------------------------------

    def _bank(self):
        idx = self._doc.font_bank if self._doc is not None else 0
        try:
            bank = self._fontrom.load_bank(idx)
            self._bank_error = None
            return bank
        except FileNotFoundError as exc:
            self._bank_error = str(exc)
            return self._fontrom.blank_bank()

    def _rebuild_cache(self):
        from studio.model.palette import attr_blink, odyssey_to_rgb

        cols, rows = self.doc_cols(), self.doc_rows()
        w, h = cols * CELL, rows * CELL
        full = QImage(w, h, QImage.Format_ARGB32_Premultiplied)
        full.fill(QColor(0, 0, 0))
        noblink = QImage(w, h, QImage.Format_ARGB32_Premultiplied)
        noblink.fill(QColor(0, 0, 0))

        pf = QPainter(full)
        pn = QPainter(noblink)
        for painter in (pf, pn):
            painter.setRenderHint(QPainter.SmoothPixmapTransform, False)

        if self._doc is not None:
            bank = self._bank()
            composite_cell = self._doc.composite_cell
            checker = self._checker if self._show_transparency else None
            for row in range(rows):
                for col in range(cols):
                    cell = composite_cell(col, row)
                    x, y = col * CELL, row * CELL
                    if cell is None:
                        if checker is not None:
                            pf.drawImage(x, y, checker)
                            pn.drawImage(x, y, checker)
                        continue
                    tile = bank.glyph_image(cell.glyph, odyssey_to_rgb(cell.attr))
                    pf.drawImage(x, y, tile)
                    if not attr_blink(cell.attr):
                        pn.drawImage(x, y, tile)
        pf.end()
        pn.end()
        self._img_full = full
        self._img_noblink = noblink
        self._overflow = self._compute_overflow()

    def _compute_overflow(self):
        """Which document edges have visible layer cells beyond them."""
        sides = set()
        if self._doc is None:
            return sides
        w, h = self.doc_cols(), self.doc_rows()
        for layer in self._doc.layers:
            if not layer.visible:
                continue
            bb = layer.bbox()
            if bb is None:
                continue
            min_c, min_r, max_c, max_r = bb
            if min_c < 0:
                sides.add("left")
            if max_c > w - 1:
                sides.add("right")
            if min_r < 0:
                sides.add("top")
            if max_r > h - 1:
                sides.add("bottom")
        return sides

    def has_overflow(self):
        return bool(self._overflow)

    def refresh(self):
        """Rebuild the composited image cache and repaint.

        Call after: document change, ``font_bank`` change, or any layer
        ``.visible`` toggle.
        """
        self._rebuild_cache()
        self._update_scrollbars()
        self.viewport().update()
        self._col_ruler.update()
        self._row_ruler.update()

    # ---- geometry helpers ---------------------------------------------

    def _content_size(self):
        z = self._zoom
        return self.doc_cols() * CELL * z, self.doc_rows() * CELL * z

    def content_pixel_size(self):
        """`QSize` of the scaled document at the current zoom (no rulers)."""
        from PySide6.QtCore import QSize
        cw, ch = self._content_size()
        return QSize(cw, ch)

    def content_origin(self):
        """Top-left of the scaled document in viewport pixels (centered if small)."""
        cw, ch = self._content_size()
        vp = self.viewport().size()
        hv = self.horizontalScrollBar().value()
        vv = self.verticalScrollBar().value()
        ox = -hv if cw > vp.width() else (vp.width() - cw) // 2
        oy = -vv if ch > vp.height() else (vp.height() - ch) // 2
        return ox, oy

    def _update_scrollbars(self):
        cw, ch = self._content_size()
        vp = self.viewport().size()
        hbar = self.horizontalScrollBar()
        vbar = self.verticalScrollBar()
        hbar.setPageStep(vp.width())
        hbar.setSingleStep(CELL * self._zoom)
        hbar.setRange(0, max(0, cw - vp.width()))
        vbar.setPageStep(vp.height())
        vbar.setSingleStep(CELL * self._zoom)
        vbar.setRange(0, max(0, ch - vp.height()))

    def _position_rulers(self):
        show = self._show_rulers
        m = RULER if show else 0
        self.setViewportMargins(m, m, 0, 0)
        if show:
            vg = self.viewport().geometry()
            self._col_ruler.setGeometry(vg.left(), vg.top() - m, vg.width(), m)
            self._row_ruler.setGeometry(vg.left() - m, vg.top(), m, vg.height())
            self._col_ruler.show()
            self._row_ruler.show()
        else:
            self._col_ruler.hide()
            self._row_ruler.hide()

    def cell_at(self, vx, vy):
        """(col, row) for a viewport pixel, or None if outside the document."""
        ox, oy = self.content_origin()
        step = CELL * self._zoom
        col = int((vx - ox) // step)
        row = int((vy - oy) // step)
        if 0 <= col < self.doc_cols() and 0 <= row < self.doc_rows():
            return col, row
        return None

    def cell_at_clamped(self, vx, vy):
        """(col, row) for a viewport pixel, clamped into the document."""
        ox, oy = self.content_origin()
        step = CELL * self._zoom
        col = int((vx - ox) // step)
        row = int((vy - oy) // step)
        col = max(0, min(self.doc_cols() - 1, col))
        row = max(0, min(self.doc_rows() - 1, row))
        return col, row

    # ---- active-layer frame + resize handles -------------------------

    def set_frame_editing(self, on):
        """Show/hide the active layer's boundary + resize handles.

        The owner turns this on for the select / move-layer tools and off for
        the drawing tools.
        """
        on = bool(on)
        if on == self._frame_editing:
            return
        self._frame_editing = on
        if not on:
            self._frame_hover = None
            self.viewport().unsetCursor()
        self.viewport().update()

    def frame_editing(self):
        return self._frame_editing

    def _active_layer(self):
        d = self._doc
        if d is None:
            return None
        i = getattr(d, "active_layer_index", -1)
        return d.layers[i] if 0 <= i < len(d.layers) else None

    def _frame_info(self):
        """``(QRectF_px, (fc, fr, fw, fh), layer)`` for the active layer's
        frame, or ``None`` when there is nothing to outline."""
        if not self._frame_editing or self._doc is None:
            return None
        layer = self._active_layer()
        if layer is None or not getattr(layer, "visible", True):
            return None
        fr = layer.frame()
        if fr is None:
            return None
        ox, oy = self.content_origin()
        step = CELL * self._zoom
        fc, frow, fw, fh = fr
        rect = QRectF(ox + fc * step, oy + frow * step, fw * step, fh * step)
        return rect, tuple(fr), layer

    @staticmethod
    def _handle_points(rect):
        x, y, w, h = rect.x(), rect.y(), rect.width(), rect.height()
        return {
            "nw": (x, y), "n": (x + w / 2, y), "ne": (x + w, y),
            "w": (x, y + h / 2), "e": (x + w, y + h / 2),
            "sw": (x, y + h), "s": (x + w / 2, y + h), "se": (x + w, y + h),
        }

    def _handle_at(self, vx, vy):
        info = self._frame_info()
        if info is None:
            return None
        rect, _fr, layer = info
        if not layer.resizable():
            return None
        for key, (hx, hy) in self._handle_points(rect).items():
            if abs(vx - hx) <= HANDLE and abs(vy - hy) <= HANDLE:
                return key
        return None

    def _resize_drag_to(self, vx, vy):
        d = self._frame_drag
        pc, pr = self.cell_at_clamped(vx, vy)
        fc, frow, fw, fh = d["start"]
        left, top, right, bottom = fc, frow, fc + fw, frow + fh
        hk = d["handle"]
        if "w" in hk:
            left = min(pc, right - 1)
        if "e" in hk:
            right = max(pc + 1, left + 1)
        if "n" in hk:
            top = min(pr, bottom - 1)
        if "s" in hk:
            bottom = max(pr + 1, top + 1)
        self._doc.layers[d["li"]].set_frame(left, top, right - left, bottom - top)
        self.refresh()

    # ---- editing -------------------------------------------------------

    def set_controller(self, controller):
        """Attach a `studio.tools.ToolController`; mouse gestures route to it."""
        self._controller = controller

    @staticmethod
    def _mods(event):
        m = 0
        mod = event.modifiers()
        if mod & Qt.ShiftModifier:
            m |= MOD_SHIFT
        if mod & Qt.ControlModifier:
            m |= MOD_CTRL
        if mod & Qt.AltModifier:
            m |= MOD_ALT
        return m

    def hovered_cell(self):
        return self._hover

    # ---- Qt events (routed from the viewport by QAbstractScrollArea) ----

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self._update_scrollbars()
        self._position_rulers()

    def showEvent(self, event):
        super().showEvent(event)
        if not self._did_initial_fit:
            self._did_initial_fit = True
            self.fit_to_window()

    def scrollContentsBy(self, dx, dy):
        self.viewport().update()
        self._col_ruler.update()
        self._row_ruler.update()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton and self._frame_editing:
            key = self._handle_at(event.position().x(), event.position().y())
            if key is not None:
                info = self._frame_info()
                _rect, fr, layer = info
                if getattr(layer, "manual_edits", lambda: False)():
                    from PySide6.QtWidgets import QMessageBox
                    if QMessageBox.warning(
                            self, "Resize layer?",
                            f"Resizing '{layer.name}' re-generates it and "
                            "discards edits made with the drawing tools.\n\n"
                            "Continue?",
                            QMessageBox.Yes | QMessageBox.No,
                            QMessageBox.No) != QMessageBox.Yes:
                        return
                self._frame_drag = {
                    "handle": key, "start": fr,
                    "li": self._doc.active_layer_index,
                }
                self.setFocus()
                return

        if (self._controller is not None
                and event.button() == Qt.LeftButton):
            hit = self.cell_at(event.position().x(), event.position().y())
            if hit is not None:
                self.setFocus()
                self._painting = True
                self._controller.press(hit[0], hit[1], self._mods(event))
                self.refresh()
                return
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        pos = event.position()

        if self._frame_drag is not None:
            self._resize_drag_to(pos.x(), pos.y())
            super().mouseMoveEvent(event)
            return
        if self._frame_editing and not self._painting:
            key = self._handle_at(pos.x(), pos.y())
            if key != self._frame_hover:
                self._frame_hover = key
                if key is None:
                    self.viewport().unsetCursor()
                else:
                    self.viewport().setCursor(_HANDLE_CURSOR[key])

        hit = self.cell_at(pos.x(), pos.y())
        if hit is not None:
            self._hover = hit
            cell = self._doc.composite_cell(*hit) if self._doc is not None else None
            self.cellHovered.emit(hit[0], hit[1], cell)
        if self._painting and self._controller is not None:
            c, r = self.cell_at_clamped(pos.x(), pos.y())
            self._controller.drag(c, r, self._mods(event))
            self.refresh()
        super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event):
        if self._frame_drag is not None and event.button() == Qt.LeftButton:
            d = self._frame_drag
            self._frame_drag = None
            layer = self._doc.layers[d["li"]]
            after = layer.frame()
            if after is not None and tuple(after) != tuple(d["start"]):
                ctx = self._controller.ctx if self._controller is not None else None
                if ctx is not None:
                    from studio.model.history import ReshapeLayerCommand
                    ctx.history.push_done(
                        ReshapeLayerCommand(d["li"], d["start"], tuple(after)))
                    ctx.changed()
            self.refresh()
            return

        if self._painting and event.button() == Qt.LeftButton:
            c, r = self.cell_at_clamped(event.position().x(), event.position().y())
            self._controller.release(c, r, self._mods(event))
            self._painting = False
            self.refresh()
            return
        super().mouseReleaseEvent(event)

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Escape and self._frame_drag is not None:
            d = self._frame_drag
            self._frame_drag = None
            self._doc.layers[d["li"]].set_frame(*d["start"])
            self.refresh()
            return
        if (event.key() == Qt.Key_Escape and self._controller is not None
                and self._painting):
            self._controller.cancel()
            self._painting = False
            self.refresh()
            return
        super().keyPressEvent(event)

    def leaveEvent(self, event):
        # Freeze the readout on the last cell -- deliberately no re-emit.
        super().leaveEvent(event)

    def paintEvent(self, _event):
        p = QPainter(self.viewport())
        p.fillRect(self.viewport().rect(), QColor(0, 0, 0))
        ox, oy = self.content_origin()
        cw, ch = self._content_size()
        src = self._img_noblink if (self._blink_preview and not self._blink_on) \
            else self._img_full
        p.setRenderHint(QPainter.SmoothPixmapTransform, False)
        p.drawImage(QRectF(ox, oy, cw, ch), src,
                    QRectF(0, 0, src.width(), src.height()))
        if self._show_grid:
            self._paint_grid(p, ox, oy)
        self._paint_bounds(p, ox, oy, cw, ch)
        self._paint_layer_frame(p)
        if self._demo_selection is not None:
            self._paint_marquee(p, ox, oy)
        if self._caret is not None:
            self._paint_caret(p, ox, oy)
        p.end()

    # ---- overlay painters ------------------------------------------------

    def _paint_grid(self, p, ox, oy):
        z = self._zoom
        col = self.palette().mid().color()
        col.setAlpha(70)
        p.setPen(QPen(col, 1))
        rows, cols = self.doc_rows(), self.doc_cols()
        x1, y1 = ox, oy
        x2, y2 = ox + cols * CELL * z, oy + rows * CELL * z
        for c in range(cols + 1):
            x = ox + c * CELL * z
            p.drawLine(int(x), int(y1), int(x), int(y2))
        for r in range(rows + 1):
            y = oy + r * CELL * z
            p.drawLine(int(x1), int(y), int(x2), int(y))

    def _paint_bounds(self, p, ox, oy, cw, ch):
        """A crisp frame at the 64x60 document edge, plus red bars on any side
        that has layer content spilling outside the display area."""
        p.save()
        p.setBrush(Qt.NoBrush)
        frame = QColor(0, 200, 255)          # fixed cyan -- reads on black
        p.setPen(QPen(frame, 1))
        p.drawRect(QRectF(ox - 1, oy - 1, cw + 1, ch + 1))

        if self._overflow:
            warn = QColor(255, 60, 60, 180)
            p.setPen(Qt.NoPen)
            p.setBrush(warn)
            t = 3
            if "left" in self._overflow:
                p.drawRect(QRectF(ox - 1 - t, oy - 1, t, ch + 2))
            if "right" in self._overflow:
                p.drawRect(QRectF(ox + cw + 1, oy - 1, t, ch + 2))
            if "top" in self._overflow:
                p.drawRect(QRectF(ox - 1, oy - 1 - t, cw + 2, t))
            if "bottom" in self._overflow:
                p.drawRect(QRectF(ox - 1, oy + ch + 1, cw + 2, t))
        p.restore()

    def _paint_layer_frame(self, p):
        """Dashed amber outline of the active layer, with resize handles when
        the layer can be resized."""
        info = self._frame_info()
        if info is None:
            return
        rect, fr, layer = info
        accent = QColor(255, 176, 64)          # amber -- distinct from doc cyan
        p.save()
        p.setBrush(Qt.NoBrush)
        p.setPen(QPen(accent, 1, Qt.DashLine))
        p.drawRect(rect)

        if layer.resizable():
            p.setPen(QPen(accent, 1))
            p.setBrush(accent)
            for hx, hy in self._handle_points(rect).values():
                p.drawRect(QRectF(hx - HANDLE / 2, hy - HANDLE / 2,
                                  HANDLE, HANDLE))

        badge = f"{fr[2]}x{fr[3]}"
        fm = p.fontMetrics()
        bw = fm.horizontalAdvance(badge) + 8
        bh = fm.height() + 2
        bx = rect.x()
        by = rect.y() - bh - 1
        if by < 0:
            by = rect.y() + 1
        p.setPen(Qt.NoPen)
        p.setBrush(QColor(0, 0, 0, 170))
        p.drawRect(QRectF(bx, by, bw, bh))
        p.setPen(accent)
        p.drawText(QRectF(bx, by, bw, bh), Qt.AlignCenter, badge)
        p.restore()

    def _paint_marquee(self, p, ox, oy):
        z = self._zoom
        r = self._demo_selection
        x = ox + r.x() * CELL * z
        y = oy + r.y() * CELL * z
        w = r.width() * CELL * z
        h = r.height() * CELL * z
        p.save()
        p.setCompositionMode(QPainter.CompositionMode_Difference)
        p.setPen(QPen(self.palette().highlight().color(), 1, Qt.DashLine))
        p.setBrush(Qt.NoBrush)
        p.drawRect(QRectF(x, y, w, h))
        p.restore()

        badge = f"{int(r.width())}x{int(r.height())}"
        fm = p.fontMetrics()
        bw = fm.horizontalAdvance(badge) + 8
        bh = fm.height() + 2
        by = y - bh if (y - bh) >= oy else y
        p.fillRect(QRectF(x, by, bw, bh), self.palette().toolTipBase())
        p.setPen(self.palette().toolTipText().color())
        p.drawText(QRectF(x, by, bw, bh), Qt.AlignCenter, badge)

    def _paint_caret(self, p, ox, oy):
        z = self._zoom
        col, row = self._caret
        x = ox + col * CELL * z
        y = oy + row * CELL * z
        p.save()
        p.setCompositionMode(QPainter.CompositionMode_Difference)
        p.setPen(QPen(QColor(255, 255, 255), 1))
        p.setBrush(Qt.NoBrush)
        p.drawRect(QRectF(x, y, CELL * z, CELL * z))
        p.restore()

    # ---- zoom ----------------------------------------------------------

    def zoom(self):
        return self._zoom

    def _apply_zoom(self, z):
        z = int(z)
        if z not in ZOOM_STEPS:
            z = min(ZOOM_STEPS, key=lambda s: abs(s - z))
        self._zoom = z
        self._update_scrollbars()
        self._position_rulers()
        self.viewport().update()
        self._col_ruler.update()
        self._row_ruler.update()
        self.zoomChanged.emit(self._zoom)

    def zoom_in(self):
        i = ZOOM_STEPS.index(self._zoom)
        if i < len(ZOOM_STEPS) - 1:
            self._apply_zoom(ZOOM_STEPS[i + 1])

    def zoom_out(self):
        i = ZOOM_STEPS.index(self._zoom)
        if i > 0:
            self._apply_zoom(ZOOM_STEPS[i - 1])

    def zoom_reset(self):
        self._apply_zoom(1)

    def fit_to_window(self):
        vp = self.viewport().size()
        best = 1
        for z in ZOOM_STEPS:
            if (self.doc_cols() * CELL * z <= vp.width()
                    and self.doc_rows() * CELL * z <= vp.height()):
                best = z
        self._apply_zoom(best)

    # ---- view toggles --------------------------------------------------

    def _tick_blink(self):
        self._blink_on = not self._blink_on
        if self._blink_preview:
            self.viewport().update()

    def set_blink_preview(self, on):
        self._blink_preview = bool(on)
        self.viewport().update()

    def set_show_grid(self, on):
        self._show_grid = bool(on)
        self.viewport().update()

    def set_show_transparency(self, on):
        """Paint a gray checkerboard in cells that no layer contributes to."""
        self._show_transparency = bool(on)
        self.refresh()

    def show_transparency(self):
        return self._show_transparency

    def set_show_rulers(self, on):
        self._show_rulers = bool(on)
        self._position_rulers()
        self._update_scrollbars()
        self.viewport().update()

    def set_demo_selection(self, rect_or_none):
        """Draw (not edit) a marquee.  Accepts a QRect/QRectF, a
        ``(col, row, w, h)`` tuple, or None."""
        if rect_or_none is None:
            self._demo_selection = None
        elif isinstance(rect_or_none, (tuple, list)):
            c, r, w, h = rect_or_none
            self._demo_selection = QRectF(c, r, w, h)
        else:
            self._demo_selection = QRectF(rect_or_none)
        self.viewport().update()

    def set_caret(self, cell_coord_or_none):
        """Draw (not edit) a caret box.  Accepts ``(col, row)`` or None."""
        self._caret = tuple(cell_coord_or_none) if cell_coord_or_none else None
        self.viewport().update()
