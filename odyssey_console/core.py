"""OdysseyCore -- the whole capability surface: video capture, serial
link, and file transfer, wired together in one place so the Qt GUI and
the control socket (odyctl / MCP) are just two equally-thin callers of
the same object. This is what lets an agent do anything a human can do
at the window: every method here is something the GUI also calls.
"""

import time
from collections import deque

from PySide6.QtCore import QBuffer, QByteArray, QIODevice
from PySide6.QtGui import QImage

from serial_link import SerialLink, DEFAULT_BAUD, list_ports
from serrun_send import SerrunTransfer
from video import FFmpegCapture, VIDEO_SIZE

RX_BUFFER_CAP = 256 * 1024  # capped ring buffer for serial_read/expect
STALL_SECONDS = 1.5
FPS_WINDOW = 2.0
EXPECT_POLL_INTERVAL = 0.05


class OdysseyCore:
    def __init__(self, device=None, demo=False):
        self._rx_buf = bytearray()
        self._rx_total = 0       # total bytes ever received (absolute offset space)
        self._rx_discarded = 0   # bytes trimmed off the front of _rx_buf so far
        self._frame_times = deque(maxlen=200)

        # Listeners fire synchronously on whichever thread produced the
        # data (the serial reader thread for incoming bytes, the caller's
        # thread for outgoing). The Qt console widget must marshal these
        # onto the GUI thread itself (e.g. via a Signal) rather than
        # touching widgets directly from here.
        self._console_listeners = []
        self._frame_listeners = []

        self._busy = False

        self.serial = SerialLink(on_data=self._on_serial_data)
        self.transfer = SerrunTransfer(send_fn=self.serial.send)
        self.capture = FFmpegCapture(device=device, demo=demo,
                                      on_frame=self._on_frame, on_busy=self._on_busy)

    def start(self):
        self.capture.start()

    def shutdown(self):
        self.capture.stop()
        self.serial.close()

    # ---- console rendering hook (used by the Qt console widget) ----

    def add_console_listener(self, fn):
        """fn(data: bytes, source: str, is_protocol: bool) is called for
        every chunk of serial traffic. source is "device" for incoming
        bytes, or "agent" for bytes a control client (odyctl/MCP) sent --
        the GUI never routes its own keystrokes through this, so there is
        no double-render to guard against.
        """
        self._console_listeners.append(fn)

    def _notify_console(self, data, source, is_protocol):
        for fn in self._console_listeners:
            fn(data, source, is_protocol)

    # ---- serial connection management ----

    def connect(self, port=None, baud=None):
        if port is None:
            ports = list_ports()
            if not ports:
                raise RuntimeError("no /dev/ttyUSB* device found")
            port = ports[0]
        self.serial.open(port, baud or DEFAULT_BAUD)

    def disconnect(self):
        self.serial.close()

    def set_baud(self, baud):
        self.serial.set_baud(baud)

    def set_rts(self, value):
        self.serial.set_rts(value)
        return self.serial.get_rts()

    def list_ports(self):
        return list_ports()

    # ---- serial data: send / read / expect ----

    def _on_serial_data(self, chunk):
        is_protocol = self.transfer.feed_data(chunk)
        self._rx_total += len(chunk)
        self._rx_buf.extend(chunk)
        overflow = len(self._rx_buf) - RX_BUFFER_CAP
        if overflow > 0:
            del self._rx_buf[:overflow]
            self._rx_discarded += overflow
        self._notify_console(chunk, "device", is_protocol)

    def serial_read(self, since=None):
        """Bytes received after absolute offset `since` (defaults to
        everything still held in the ring buffer), plus the new cursor
        to pass as `since` on the next call.
        """
        base = self._rx_discarded
        if since is None:
            since = base
        start = max(since, base) - base
        data = bytes(self._rx_buf[start:])
        return data, self._rx_total

    def serial_send(self, data, expect=None, timeout=5.0, source="agent"):
        if not self.serial.is_open:
            raise RuntimeError("not connected")
        if isinstance(data, str):
            data = data.encode("utf-8")
        start_cursor = self._rx_total
        self.serial.send(data)
        self._notify_console(data, source, False)
        if expect is None:
            return {"queued": len(data)}
        return self._wait_for(expect, start_cursor, timeout)

    def serial_expect(self, pattern, timeout=5.0, since=None):
        start_cursor = self._rx_total if since is None else since
        return self._wait_for(pattern, start_cursor, timeout)

    def _wait_for(self, pattern, since, timeout):
        pattern_bytes = pattern.encode("utf-8") if isinstance(pattern, str) else pattern
        deadline = time.time() + timeout
        while True:
            data, _ = self.serial_read(since)
            idx = data.find(pattern_bytes)
            if idx != -1:
                matched = data[:idx + len(pattern_bytes)]
                return {"matched": True, "data": matched.decode("utf-8", "replace")}
            if time.time() > deadline:
                return {"matched": False, "data": data.decode("utf-8", "replace")}
            time.sleep(EXPECT_POLL_INTERVAL)

    # ---- file transfer ----

    def start_send_file(self, path):
        """Non-blocking: arms the transfer and returns immediately. The
        GUI drives it forward via its own 500ms poll timer (transfer.poll()
        plus transfer.state/.sent/.total for the progress bar); used
        directly by send_file()'s blocking wait below for control clients.
        """
        if not self.serial.is_open:
            raise RuntimeError("not connected")
        self.transfer.start(path)

    def send_file(self, path):
        self.start_send_file(path)
        while self.transfer.active:
            self.transfer.poll()
            time.sleep(EXPECT_POLL_INTERVAL)
        if self.transfer.state == "done":
            return {"ok": True, "sent": self.transfer.sent, "total": self.transfer.total}
        return {"ok": False, "error": self.transfer.error}

    # ---- video capture ----

    def add_frame_listener(self, fn):
        """fn(buf: bytes) is called with each raw RGB24 frame -- used by
        the Qt video pane to display frames as they arrive. Runs on the
        capture thread; the GUI must marshal it via a Qt signal.
        """
        self._frame_listeners.append(fn)

    def _on_frame(self, buf):
        self._frame_times.append(time.time())
        for fn in self._frame_listeners:
            fn(buf)

    def _on_busy(self):
        self._busy = True

    def retry_capture(self):
        self._busy = False
        self.capture.start()

    def capture_state(self):
        if self._busy:
            return "busy"
        if not self.capture.running:
            return "offline"
        if self.capture.last_frame_time is None:
            return "starting"
        if time.time() - self.capture.last_frame_time > STALL_SECONDS:
            return "stalled"
        return "live"

    def fps(self):
        now = time.time()
        cutoff = now - FPS_WINDOW
        recent = [t for t in self._frame_times if t >= cutoff]
        if len(recent) < 2:
            return 0.0
        return (len(recent) - 1) / (recent[-1] - recent[0])

    def screencap(self):
        """Latest frame as PNG bytes, at native resolution -- the Odyssey
        renders text, so downscaling would defeat the point of looking.
        """
        state = self.capture_state()
        if state != "live":
            raise RuntimeError(f"capture is {state}, no current frame available")
        frame = self.capture.last_frame
        w, h = VIDEO_SIZE
        # QImage wraps this buffer rather than copying it, so `frame`
        # (captured by the closure) must outlive the QImage -- it does,
        # since save() below runs before this local frame is dropped.
        image = QImage(frame, w, h, w * 3, QImage.Format_RGB888)
        qba = QByteArray()
        qbuf = QBuffer(qba)
        qbuf.open(QIODevice.WriteOnly)
        image.save(qbuf, "PNG")
        qbuf.close()
        return bytes(qba)

    # ---- status ----

    def status(self):
        return {
            "connected": self.serial.is_open,
            "port": self.serial.port,
            "baud": self.serial.baud,
            "cts": self.serial.get_cts(),
            "rts": self.serial.get_rts(),
            "capture_state": self.capture_state(),
            "fps": round(self.fps(), 1),
            "transfer_active": self.transfer.active,
        }
