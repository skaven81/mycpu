"""
Screen-wide eyedropper.

`pick_screen_color(parent, on_picked)` lets the user click any pixel on the
screen -- in this app or any other window -- and hands ``on_picked(QColor)``
the color there.

Two back-ends, tried in order:

1. **xdg-desktop-portal** ``org.freedesktop.portal.Screenshot.PickColor``,
   spoken over D-Bus with **jeepney** (PySide6's own QtDBus cannot demarshal
   the portal's ``a{sv}`` reply -- see the back-end 1 comment).  This is the
   only thing that works under Wayland (a sandboxed client cannot read the
   framebuffer itself) and it gives the compositor's own native pixel picker.

2. A frozen full-desktop overlay: grab a screenshot of every screen, show it
   top-most with a zoom loupe, and read the pixel under the next click.  Works
   on X11 where ``QScreen.grabWindow`` returns real pixels; the fallback for
   anyone without the portal.

Esc or a right click cancels.
"""

import sys
import time

from PySide6.QtCore import (
    QCoreApplication, QObject, QPoint, QRect, QRectF, Qt, QThread, Signal, Slot,
)
from PySide6.QtGui import QColor, QGuiApplication, QPainter, QPen, QPixmap
from PySide6.QtWidgets import QWidget

_LOUPE_R = 64        # loupe half-size, px
_LOUPE_Z = 8         # loupe magnification


def _is_wayland() -> bool:
    """True when Qt is talking to a Wayland compositor.

    Deliberately only trusts the live Qt platform plugin -- the ``offscreen``
    plugin used by the test suite reports its own name, so this stays False
    there even when the shell's ``XDG_SESSION_TYPE`` says ``wayland``.
    """
    try:
        return QGuiApplication.platformName().lower().startswith("wayland")
    except Exception:                       # noqa: BLE001
        return False


# ======================================================================
# back-end 1: xdg-desktop-portal Screenshot.PickColor  (spoken via jeepney)
# ======================================================================
#
# Why not PySide6's own QtDBus?  Because it cannot read the portal's reply.
# The Response payload is ``a{sv}`` with the colour under a ``(ddd)`` variant,
# and in PySide6 6.11 ``QDBusArgument`` demarshalling is broken:
# ``asVariant()`` returns an unconvertible pointer and the ``begin*`` walkers
# are the *marshalling* overloads, so any attempt prints
# "QDBusArgument: write from a read-only object" and yields nothing.
#
# jeepney is a tiny pure-Python D-Bus library that parses the reply natively.
# Its blocking client runs on a worker thread (a pick can take many seconds
# while the user aims); the result comes back over a queued Qt signal.

_PORTAL = "org.freedesktop.portal.Desktop"
_PORTAL_PATH = "/org/freedesktop/portal/desktop"
_SCREENSHOT_IFACE = "org.freedesktop.portal.Screenshot"
_REQUEST_IFACE = "org.freedesktop.portal.Request"


def _extract_rgb(results):
    """``(r, g, b)`` floats out of a portal ``Response`` results mapping, else None.

    jeepney parses the ``a{sv}`` to a ``dict`` whose ``color`` value is a
    ``(signature, payload)`` variant tuple around the ``(ddd)`` struct.  A bare
    ``[r, g, b]`` under ``color`` is also accepted (used by the tests).
    """
    try:
        val = results["color"]
    except Exception:                          # noqa: BLE001 - missing / not a map
        return None
    if isinstance(val, tuple) and len(val) == 2 and isinstance(val[0], str):
        val = val[1]                           # unwrap jeepney's variant tuple
    try:
        r, g, b = val
        return float(r), float(g), float(b)
    except Exception:                          # noqa: BLE001
        return None


def _portal_available():
    """``(ok, reason)`` -- is the Screenshot portal present *with* PickColor?

    PickColor landed in Screenshot interface version 2, so the ``version``
    property is also the capability probe.  Synchronous and quick.
    """
    try:
        from jeepney import DBusAddress, MessageType, new_method_call
        from jeepney.io.blocking import open_dbus_connection
    except Exception as exc:                    # noqa: BLE001
        return False, f"jeepney not importable ({exc})"
    conn = None
    try:
        conn = open_dbus_connection(bus="SESSION")
        props = DBusAddress(_PORTAL_PATH, bus_name=_PORTAL,
                            interface="org.freedesktop.DBus.Properties")
        reply = conn.send_and_get_reply(
            new_method_call(props, "GetAll", "s", (_SCREENSHOT_IFACE,)))
        if reply.header.message_type == MessageType.error:
            return False, "Screenshot portal interface not available"
        pmap = reply.body[0] if reply.body else {}
        ver = pmap.get("version")
        if isinstance(ver, tuple):
            ver = ver[-1]
        if not ver or int(ver) < 2:
            return False, f"Screenshot portal version {ver!r} has no PickColor"
        return True, ""
    except Exception as exc:                    # noqa: BLE001
        return False, str(exc)
    finally:
        if conn is not None:
            try:
                conn.close()
            except Exception:                   # noqa: BLE001
                pass


class _PortalPickThread(QThread):
    """Runs the blocking jeepney PickColor request/response off the GUI thread.

    Emits exactly one of ``picked(r, g, b)`` (0..1 floats) or ``failed(reason)``
    -- ``reason`` empty for a plain user cancel, otherwise a line for stderr.
    """

    picked = Signal(float, float, float)
    failed = Signal(str)

    _TIMEOUT_S = 180.0

    def run(self):
        try:
            from jeepney import (DBusAddress, HeaderFields, MatchRule,
                                 MessageType, new_method_call)
            from jeepney.bus_messages import message_bus
            from jeepney.io.blocking import open_dbus_connection
        except Exception as exc:               # noqa: BLE001
            self.failed.emit(f"jeepney unavailable: {exc}")
            return

        conn = None
        try:
            conn = open_dbus_connection(bus="SESSION")
            conn.send_and_get_reply(message_bus.AddMatch(MatchRule(
                type="signal", interface=_REQUEST_IFACE, member="Response")))

            token = f"oas_{int(time.time() * 1000) & 0xFFFFFF}"
            tail = (conn.unique_name or "").lstrip(":").replace(".", "_")
            predicted = f"{_PORTAL_PATH}/request/{tail}/{token}"

            sc = DBusAddress(_PORTAL_PATH, bus_name=_PORTAL,
                             interface=_SCREENSHOT_IFACE)
            reply = conn.send_and_get_reply(new_method_call(
                sc, "PickColor", "sa{sv}",
                ("", {"handle_token": ("s", token)})))
            if reply.header.message_type == MessageType.error:
                self.failed.emit(
                    f"PickColor call failed: "
                    f"{reply.header.fields.get(HeaderFields.error_name)}")
                return
            request_path = reply.body[0] if reply.body else predicted
            want = {request_path, predicted}

            deadline = time.monotonic() + self._TIMEOUT_S
            while not self.isInterruptionRequested():
                left = deadline - time.monotonic()
                if left <= 0:
                    self.failed.emit("timed out waiting for the color pick")
                    return
                try:
                    msg = conn.receive(timeout=min(left, 1.0))
                except TimeoutError:
                    continue
                if msg.header.message_type != MessageType.signal:
                    continue
                fields = msg.header.fields
                if fields.get(HeaderFields.member) != "Response":
                    continue
                if fields.get(HeaderFields.path) not in want:
                    continue
                try:
                    code, res = msg.body
                except Exception:             # noqa: BLE001
                    self.failed.emit("malformed portal Response")
                    return
                if int(code) != 0:
                    self.failed.emit("")       # 1 = user cancelled, 2 = other
                    return
                rgb = _extract_rgb(res)
                if rgb is None:
                    self.failed.emit(
                        f"no readable color in the portal reply: {res!r}")
                    return
                self.picked.emit(*rgb)
                return
            self.failed.emit("")               # interrupted (app quitting)
        except Exception as exc:               # noqa: BLE001
            self.failed.emit(f"portal error: {exc}")
        finally:
            if conn is not None:
                try:
                    conn.close()
                except Exception:              # noqa: BLE001
                    pass


class _PortalPick(QObject):
    """Owns one ``_PortalPickThread`` and routes its result to the caller.

    A ``QObject`` so the worker's ``picked`` / ``failed`` signals cross back to
    the GUI thread as a queued connection.
    """

    def __init__(self, parent, on_picked, on_cancel):
        super().__init__(parent if isinstance(parent, QObject) else None)
        self._parent = parent
        self._on_picked = on_picked
        self._on_cancel = on_cancel
        self._done = False
        self._th = _PortalPickThread()
        self._th.picked.connect(self._got_rgb)
        self._th.failed.connect(self._got_fail)
        app = QCoreApplication.instance()
        if app is not None:
            app.aboutToQuit.connect(self._abort)
        self._th.start()

    def _abort(self):
        if self._th.isRunning():
            self._th.requestInterruption()
            self._th.wait(2000)

    @Slot(float, float, float)
    def _got_rgb(self, r, g, b):
        if self._done:
            return
        self._done = True
        self._on_picked(QColor.fromRgbF(max(0.0, min(1.0, r)),
                                        max(0.0, min(1.0, g)),
                                        max(0.0, min(1.0, b))))

    @Slot(str)
    def _got_fail(self, reason):
        if self._done:
            return
        self._done = True
        if reason:
            sys.stderr.write(f"[screen_pick] {reason}\n")
            if _is_wayland():
                _warn_no_portal(self._parent)
        if self._on_cancel is not None:
            self._on_cancel()


def _portal_pick_color(parent, on_picked, on_cancel):
    """Start the portal picker.  Returns a keep-alive handle, or None if the
    portal is not usable at all (caller then does the overlay / the warning)."""
    ok, why = _portal_available()
    if not ok:
        sys.stderr.write(f"[screen_pick] portal color picker unavailable: "
                         f"{why}\n")
        return None
    holder = _PortalPick(parent, on_picked, on_cancel)
    if parent is not None:
        parent._screen_color_picker = holder
    return holder


# ======================================================================
# back-end 2: frozen-screenshot overlay (X11 fallback)
# ======================================================================

def grab_virtual_desktop():
    """``(QPixmap, QPoint)`` -- every screen composited into one logical-sized
    pixmap, and its top-left in global coordinates.  Each screen's grab is
    scaled to its *logical* geometry so widget coordinates map 1:1 (no
    device-pixel-ratio skew on a HiDPI display)."""
    screens = QGuiApplication.screens()
    virt = QRect()
    for s in screens:
        virt = virt.united(s.geometry())
    if virt.isEmpty():
        virt = QRect(0, 0, 1, 1)
    canvas = QPixmap(virt.size())
    canvas.setDevicePixelRatio(1.0)
    canvas.fill(Qt.black)
    p = QPainter(canvas)
    for s in screens:
        shot = s.grabWindow(0)
        g = s.geometry()
        p.drawPixmap(QRectF(g.x() - virt.x(), g.y() - virt.y(),
                            g.width(), g.height()),
                     shot, QRectF(0, 0, shot.width(), shot.height()))
    p.end()
    return canvas, virt.topLeft()


class ScreenColorPicker(QWidget):
    """A frozen full-desktop overlay whose next click yields a pixel color."""

    picked = Signal(QColor)
    cancelled = Signal()

    def __init__(self, parent=None):
        super().__init__(None, Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                         | Qt.BypassWindowManagerHint | Qt.Tool)
        self._pm, self._origin = grab_virtual_desktop()
        self._img = self._pm.toImage()
        self.setGeometry(QRect(self._origin, self._pm.size()))
        self.setMouseTracking(True)
        self.setCursor(Qt.CrossCursor)
        self._pos = QPoint(0, 0)

    def color_at(self, x, y) -> QColor:
        x = max(0, min(self._img.width() - 1, int(x)))
        y = max(0, min(self._img.height() - 1, int(y)))
        return QColor(self._img.pixel(x, y))

    # ---- events ------------------------------------------------------
    def mouseMoveEvent(self, e):
        self._pos = e.position().toPoint()
        self.update()

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            col = self.color_at(e.position().x(), e.position().y())
            self.close()
            self.picked.emit(col)
        else:
            self.close()
            self.cancelled.emit()

    def keyPressEvent(self, e):
        if e.key() == Qt.Key_Escape:
            self.close()
            self.cancelled.emit()

    def paintEvent(self, _e):
        p = QPainter(self)
        p.drawPixmap(0, 0, self._pm)
        p.fillRect(self.rect(), QColor(0, 0, 0, 36))

        pt = self._pos
        src = _LOUPE_R / _LOUPE_Z
        box = QRectF(pt.x() + 20, pt.y() + 20, _LOUPE_R * 2, _LOUPE_R * 2)
        if box.right() > self.width():
            box.moveLeft(pt.x() - 20 - box.width())
        if box.bottom() > self.height():
            box.moveTop(pt.y() - 20 - box.height())

        p.setRenderHint(QPainter.SmoothPixmapTransform, False)
        p.drawImage(box, self._img,
                    QRectF(pt.x() - src, pt.y() - src, src * 2, src * 2))
        p.setPen(QPen(QColor(255, 255, 255), 2))
        p.setBrush(Qt.NoBrush)
        p.drawRect(box)
        cx, cy = box.center().x(), box.center().y()
        p.setPen(QPen(QColor(255, 40, 40), 1))
        p.drawLine(int(cx), int(box.top()), int(cx), int(box.bottom()))
        p.drawLine(int(box.left()), int(cy), int(box.right()), int(cy))

        col = self.color_at(pt.x(), pt.y())
        tag = QRectF(box.left(), box.bottom() + 3, box.width(), 18)
        p.fillRect(tag, QColor(0, 0, 0, 205))
        p.setPen(QColor(255, 255, 255))
        p.drawText(tag, Qt.AlignCenter,
                   f"{col.name().upper()}   {col.red()},{col.green()},{col.blue()}")
        p.end()


def _overlay_pick_color(parent, on_picked, on_cancel):
    w = ScreenColorPicker(parent)
    if parent is not None:
        parent._screen_color_picker = w      # keep it alive
    w.picked.connect(on_picked)
    if on_cancel is not None:
        w.cancelled.connect(on_cancel)
    w.show()
    w.raise_()
    w.activateWindow()
    w.setFocus()
    return w


# ======================================================================
# public entry point
# ======================================================================

def _warn_no_portal(parent):
    try:
        from PySide6.QtWidgets import QMessageBox
        QMessageBox.warning(
            parent, "Screen color picker unavailable",
            "The desktop's color-picker service (xdg-desktop-portal) did not "
            "respond, so a pixel can't be sampled from the screen under "
            "Wayland.\n\n"
            "Make sure xdg-desktop-portal and its GNOME/GTK backend "
            "(xdg-desktop-portal-gnome or -gtk) are installed and running, "
            "then try again. The terminal output has the specific error.")
    except Exception:                       # noqa: BLE001
        pass


def pick_screen_color(parent, on_picked, on_cancel=None):
    """Sample a color anywhere on screen; call ``on_picked(QColor)`` with it.

    Uses the desktop portal when available (required on Wayland, where a client
    cannot read the framebuffer itself).  Falls back to a frozen-screenshot
    overlay on X11; on Wayland a failed portal call reports the reason rather
    than showing the (necessarily black) overlay.
    """
    holder = _portal_pick_color(parent, on_picked, on_cancel)
    if holder is not None:
        return holder
    if _is_wayland():
        _warn_no_portal(parent)
        if on_cancel is not None:
            on_cancel()
        return None
    return _overlay_pick_color(parent, on_picked, on_cancel)
