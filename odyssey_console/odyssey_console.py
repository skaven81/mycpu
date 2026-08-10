#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["PySide6>=6.6", "pyserial>=3.5"]
# ///
"""odyssey_console.py -- lab-PC video + serial console for the Odyssey.

Replaces two flaky, disconnected tools with one window: ffplay-based
video (/raid/odyssey-video.sh), which "freezes" if you press any key
while it has focus because ffplay binds space/p to pause/seek, and
GTKterm, which mishandles RTS/CTS with this USB-to-RS232 adapter.

Every capability here is also reachable through the control socket
(control_server.py) via odyctl or mcp_server.py -- this window is one
client of OdysseyCore, not a special one. --headless runs the same
OdysseyCore and control socket with no window at all, for scripted use
(e.g. `make serial`, see os/tools/serial_send.py) -- nothing in the
headless path needs Qt's event loop, since core.send_file() already
polls its own transfer state to completion internally.
"""

import argparse
import glob
import signal
import sys
import threading
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from PySide6.QtCore import QObject, QSettings, QSize, Qt, QTimer, Signal
from PySide6.QtGui import QImage, QPixmap
from PySide6.QtWidgets import (
    QApplication, QCheckBox, QComboBox, QFileDialog, QHBoxLayout, QLabel,
    QMainWindow, QMessageBox, QProgressBar, QPushButton, QSplitter,
    QVBoxLayout, QWidget,
)

from console import (
    ConsoleView, DEFAULT_ENTER_MODE, DEFAULT_RX_CR_MODE, DEFAULT_RX_LF_MODE, LINE_ENDING_MODES,
)
from control_server import ControlServer
from core import OdysseyCore
from serial_link import BAUD_RATES, DEFAULT_BAUD
from video import VIDEO_SIZE

POLL_INTERVAL_MS = 500

STATE_COLOR = {"live": "#33cc33", "stalled": "#dddd33", "starting": "#888888",
               "offline": "#888888", "busy": "#dd3333"}
LED_ON = "#33cc33"
LED_OFF = "#666666"


def first_video_device():
    devices = sorted(glob.glob("/dev/video*"))
    return devices[0] if devices else None


class CoreBridge(QObject):
    """Marshals OdysseyCore's background-thread callbacks onto the GUI
    thread. Qt automatically queues a signal emitted from a foreign
    thread when the receiving slot lives on the GUI thread, so this is
    the entire thread-safety story -- no manual locking needed here.
    """
    frame_ready = Signal(bytes)
    console_data = Signal(bytes, str, bool)
    shutdown_requested = Signal()


class MainWindow(QMainWindow):
    def __init__(self, device=None, demo=False, preselect_port=None):
        super().__init__()
        self.setWindowTitle("Odyssey Console")
        self.settings = QSettings("odyssey", "odyssey_console")

        self.core = OdysseyCore(device=device, demo=demo)
        self._transfer_ui_active = False
        self.bridge = CoreBridge()
        self.core.add_frame_listener(lambda buf: self.bridge.frame_ready.emit(buf))
        self.core.add_console_listener(
            lambda data, source, is_protocol: self.bridge.console_data.emit(data, source, is_protocol))
        self.bridge.frame_ready.connect(self._on_frame)
        self.bridge.console_data.connect(self._on_console_data)
        self.bridge.shutdown_requested.connect(self.close)

        self._build_ui()
        self._restore_settings()

        self.poll_timer = QTimer(self)
        self.poll_timer.setInterval(POLL_INTERVAL_MS)
        self.poll_timer.timeout.connect(self._poll)
        self.poll_timer.start()

        self.control_server = ControlServer(
            self.core, on_shutdown=lambda: self.bridge.shutdown_requested.emit())
        try:
            self.control_server.start()
        except RuntimeError as e:
            # Degrade gracefully, matching the MCP server's "not running"
            # story in reverse: the window still works for local video and
            # serial control, it just isn't reachable by odyctl/MCP until
            # whatever already owns the socket is stopped.
            self.control_server = None
            QMessageBox.warning(self, "Odyssey Console", str(e))

        self.core.start()
        self._refresh_ports()
        if preselect_port:
            idx = self.port_combo.findText(preselect_port)
            if idx < 0:
                self.port_combo.insertItem(0, preselect_port)
                idx = 0
            self.port_combo.setCurrentIndex(idx)

    # ---- UI construction ----

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        outer = QVBoxLayout(central)

        splitter = QSplitter(Qt.Orientation.Horizontal)
        outer.addWidget(splitter)

        # Console on the left, video on the right: the lab display is wider
        # than it is tall, and the video needs the width far more than the
        # console does -- a vertical split left the video pane crunched down
        # to a sliver even maximized.
        self.console_pane = console_pane = QWidget()
        console_layout = QVBoxLayout(console_pane)

        row1 = QHBoxLayout()
        self.collapse_button = QPushButton("◀")
        self.collapse_button.setFixedWidth(24)
        self.collapse_button.setToolTip("Hide serial console")
        self.collapse_button.clicked.connect(self._on_collapse_clicked)
        self.port_combo = QComboBox()
        self.refresh_button = QPushButton("⟳")
        self.refresh_button.setFixedWidth(28)
        self.refresh_button.clicked.connect(self._refresh_ports)
        self.baud_combo = QComboBox()
        for b in BAUD_RATES:
            self.baud_combo.addItem(str(b), b)
        self.baud_combo.setCurrentIndex(BAUD_RATES.index(DEFAULT_BAUD))
        self.connect_button = QPushButton("Connect")
        self.connect_button.clicked.connect(self._on_connect_clicked)
        self.send_file_button = QPushButton("Send File…")
        self.send_file_button.clicked.connect(self._on_send_file_clicked)
        row1.addWidget(self.collapse_button)
        row1.addWidget(self.port_combo, stretch=1)
        row1.addWidget(self.refresh_button)
        row1.addWidget(self.baud_combo)
        row1.addWidget(self.connect_button)
        row1.addWidget(self.send_file_button)
        console_layout.addLayout(row1)

        row2 = QHBoxLayout()
        self.cts_label = QLabel("CTS ●")
        self.rts_label = QLabel("RTS ●")
        self.rts_toggle = QPushButton("RTS")
        self.rts_toggle.setCheckable(True)
        self.rts_toggle.clicked.connect(self._on_rts_toggle)
        self.clear_button = QPushButton("Clear")
        self.clear_button.clicked.connect(lambda: self.console.clear_console())
        row2.addWidget(self.cts_label)
        row2.addWidget(self.rts_label)
        row2.addWidget(self.rts_toggle)
        row2.addStretch()
        row2.addWidget(self.clear_button)
        console_layout.addLayout(row2)

        row3 = QHBoxLayout()
        self.echo_checkbox = QCheckBox("Echo")
        self.echo_checkbox.toggled.connect(self._on_echo_toggled)
        self.enter_combo = QComboBox()
        for mode in LINE_ENDING_MODES:
            self.enter_combo.addItem(mode, mode)
        self.enter_combo.currentIndexChanged.connect(self._on_enter_mode_changed)
        self.rx_lf_combo = QComboBox()
        for mode in LINE_ENDING_MODES:
            self.rx_lf_combo.addItem(mode, mode)
        self.rx_lf_combo.currentIndexChanged.connect(self._on_rx_lf_mode_changed)
        self.rx_cr_combo = QComboBox()
        for mode in LINE_ENDING_MODES:
            self.rx_cr_combo.addItem(mode, mode)
        self.rx_cr_combo.currentIndexChanged.connect(self._on_rx_cr_mode_changed)
        row3.addWidget(self.echo_checkbox)
        row3.addStretch()
        row3.addWidget(QLabel("Enter sends:"))
        row3.addWidget(self.enter_combo)
        row3.addWidget(QLabel("Received LF:"))
        row3.addWidget(self.rx_lf_combo)
        row3.addWidget(QLabel("Received CR:"))
        row3.addWidget(self.rx_cr_combo)
        console_layout.addLayout(row3)

        self.transfer_bar = QProgressBar()
        self.transfer_bar.setVisible(False)
        console_layout.addWidget(self.transfer_bar)

        self.console = ConsoleView()
        self.console.byte_typed.connect(self._on_key_typed)
        console_layout.addWidget(self.console, stretch=1)

        splitter.addWidget(console_pane)
        self.splitter = splitter

        video_pane = QWidget()
        video_layout = QVBoxLayout(video_pane)
        top_row = QHBoxLayout()
        self.expand_button = QPushButton("▶")
        self.expand_button.setFixedWidth(24)
        self.expand_button.setToolTip("Show serial console")
        self.expand_button.setVisible(False)
        self.expand_button.clicked.connect(self._on_expand_clicked)
        self.status_label = QLabel("● OFFLINE")
        self.fps_label = QLabel("")
        self.retry_button = QPushButton("Retry")
        self.retry_button.clicked.connect(lambda: self.core.retry_capture())
        top_row.addWidget(self.expand_button)
        top_row.addWidget(QLabel("Odyssey"))
        top_row.addWidget(self.status_label)
        top_row.addWidget(self.fps_label)
        top_row.addStretch()
        top_row.addWidget(self.retry_button)
        video_layout.addLayout(top_row)

        self.video_label = QLabel()
        self.video_label.setMinimumSize(QSize(320, 240))
        self.video_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.video_label.setStyleSheet("background-color: #000;")
        video_layout.addWidget(self.video_label, stretch=1)
        splitter.addWidget(video_pane)

        # Video gets twice the console's share of the initial width --
        # it's the pane that was starved before.
        splitter.setStretchFactor(0, 1)
        splitter.setStretchFactor(1, 2)

    # ---- video ----

    def _on_frame(self, buf):
        w, h = VIDEO_SIZE
        image = QImage(buf, w, h, w * 3, QImage.Format.Format_RGB888)
        pix = QPixmap.fromImage(image).scaled(
            self.video_label.size(), Qt.AspectRatioMode.KeepAspectRatio,
            Qt.TransformationMode.SmoothTransformation)
        self.video_label.setPixmap(pix)

    # ---- console / serial ----

    def _on_key_typed(self, data):
        # Goes straight to SerialLink, bypassing core.serial_send(), which
        # also notifies console listeners -- typed keys are already shown
        # via the Echo checkbox, so routing through there would double-render.
        if not self.core.serial.is_open:
            return
        try:
            self.core.serial.send(data)
        except RuntimeError:
            pass

    def _on_console_data(self, data, source, is_protocol):
        if source == "device":
            self.console.feed_device(data, is_protocol=is_protocol)
        elif source == "agent":
            self.console.feed_agent(data)

    def _on_echo_toggled(self, checked):
        self.console.echo_enabled = checked
        self.settings.setValue("echo", checked)

    def _on_collapse_clicked(self):
        # Remember the console's width so re-expanding restores it instead
        # of whatever arbitrary split the splitter picks on its own.
        self._console_pane_width = self.splitter.sizes()[0]
        self.console_pane.setVisible(False)
        self.expand_button.setVisible(True)
        self.settings.setValue("console_collapsed", True)

    def _on_expand_clicked(self):
        self.console_pane.setVisible(True)
        self.expand_button.setVisible(False)
        width = getattr(self, "_console_pane_width", None)
        if width:
            total = sum(self.splitter.sizes())
            self.splitter.setSizes([width, max(total - width, 0)])
        self.settings.setValue("console_collapsed", False)

    def _on_enter_mode_changed(self, index):
        mode = self.enter_combo.itemData(index)
        self.console.enter_mode = mode
        self.settings.setValue("enter_mode", mode)

    def _on_rx_lf_mode_changed(self, index):
        mode = self.rx_lf_combo.itemData(index)
        self.console.rx_lf_mode = mode
        self.settings.setValue("rx_lf_mode", mode)

    def _on_rx_cr_mode_changed(self, index):
        mode = self.rx_cr_combo.itemData(index)
        self.console.rx_cr_mode = mode
        self.settings.setValue("rx_cr_mode", mode)

    def _refresh_ports(self):
        current = self.port_combo.currentText()
        self.port_combo.clear()
        for p in self.core.list_ports():
            self.port_combo.addItem(p)
        if current:
            idx = self.port_combo.findText(current)
            if idx >= 0:
                self.port_combo.setCurrentIndex(idx)

    def _on_connect_clicked(self):
        if self.core.serial.is_open:
            self.core.disconnect()
            self.connect_button.setText("Connect")
            return
        port = self.port_combo.currentText() or None
        baud = self.baud_combo.currentData()
        try:
            self.core.connect(port=port, baud=baud)
        except (RuntimeError, OSError) as e:
            QMessageBox.warning(self, "Odyssey Console", str(e))
            return
        self.connect_button.setText("Disconnect")
        self.settings.setValue("port", port)
        self.settings.setValue("baud", baud)

    def _on_rts_toggle(self, checked):
        if not self.core.serial.is_open:
            self.rts_toggle.setChecked(not checked)
            return
        self.core.set_rts(checked)

    def _on_send_file_clicked(self):
        if not self.core.serial.is_open:
            QMessageBox.warning(self, "Odyssey Console", "Connect to a serial port first.")
            return
        if self.core.transfer.active:
            QMessageBox.warning(self, "Odyssey Console", "A transfer is already in progress.")
            return
        path, _ = QFileDialog.getOpenFileName(self, "Send .ODY file", "", "Odyssey binaries (*.ODY *.ody)")
        if path:
            self._begin_transfer(path)

    def _begin_transfer(self, path):
        try:
            self.core.start_send_file(path)
        except (RuntimeError, ValueError, OSError) as e:
            QMessageBox.warning(self, "Odyssey Console", str(e))
            return
        self._transfer_ui_active = True
        self.console.setEnabled(False)
        self.transfer_bar.setVisible(True)
        self.transfer_bar.setRange(0, self.core.transfer.total)
        self.transfer_bar.setValue(0)

    # ---- polling: fps/status/CTS-RTS/transfer progress, all on one timer ----

    def _poll(self):
        status = self.core.status()

        state = status["capture_state"]
        self.status_label.setText(f"● {state.upper()}")
        self.status_label.setStyleSheet(f"color: {STATE_COLOR.get(state, '#888888')};")
        self.fps_label.setText(f"{status['fps']:.1f} fps" if state == "live" else "")

        self.cts_label.setStyleSheet(f"color: {LED_ON if status['cts'] else LED_OFF};")
        self.rts_label.setStyleSheet(f"color: {LED_ON if status['rts'] else LED_OFF};")
        self.rts_toggle.setChecked(status["rts"])

        if self.core.transfer.active:
            self.core.transfer.poll()
            self.transfer_bar.setValue(self.core.transfer.sent)
        elif self._transfer_ui_active:
            self._finish_transfer_ui()

    def _finish_transfer_ui(self):
        self._transfer_ui_active = False
        self.transfer_bar.setVisible(False)
        self.console.setEnabled(True)
        if self.core.transfer.state == "failed":
            QMessageBox.warning(self, "Odyssey Console", f"Transfer failed: {self.core.transfer.error}")

    # ---- settings persistence ----

    def _restore_settings(self):
        geometry = self.settings.value("geometry")
        if geometry is not None:
            self.restoreGeometry(geometry)
        self.echo_checkbox.setChecked(self.settings.value("echo", False, type=bool))
        baud = self.settings.value("baud", DEFAULT_BAUD, type=int)
        if baud in BAUD_RATES:
            self.baud_combo.setCurrentIndex(BAUD_RATES.index(baud))

        enter_mode = self.settings.value("enter_mode", DEFAULT_ENTER_MODE, type=str)
        if enter_mode not in LINE_ENDING_MODES:
            enter_mode = DEFAULT_ENTER_MODE
        self.enter_combo.setCurrentIndex(LINE_ENDING_MODES.index(enter_mode))
        self.console.enter_mode = enter_mode

        rx_lf_mode = self.settings.value("rx_lf_mode", DEFAULT_RX_LF_MODE, type=str)
        if rx_lf_mode not in LINE_ENDING_MODES:
            rx_lf_mode = DEFAULT_RX_LF_MODE
        self.rx_lf_combo.setCurrentIndex(LINE_ENDING_MODES.index(rx_lf_mode))
        self.console.rx_lf_mode = rx_lf_mode

        rx_cr_mode = self.settings.value("rx_cr_mode", DEFAULT_RX_CR_MODE, type=str)
        if rx_cr_mode not in LINE_ENDING_MODES:
            rx_cr_mode = DEFAULT_RX_CR_MODE
        self.rx_cr_combo.setCurrentIndex(LINE_ENDING_MODES.index(rx_cr_mode))
        self.console.rx_cr_mode = rx_cr_mode

        if self.settings.value("console_collapsed", False, type=bool):
            # Deferred: at this point in __init__ the window hasn't been
            # resized to its real geometry yet, so the splitter's sizes()
            # would reflect a default pre-layout width, not a usable one.
            QTimer.singleShot(0, self._on_collapse_clicked)

    def closeEvent(self, event):
        self.settings.setValue("geometry", self.saveGeometry())
        if self.control_server is not None:
            self.control_server.stop()
        self.core.shutdown()
        super().closeEvent(event)


def parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--demo", action="store_true",
                    help="synthetic test pattern instead of real capture hardware")
    p.add_argument("--device", default=None, help="v4l2 device (default: first /dev/video*)")
    p.add_argument("--port", default=None,
                    help="preselect a serial port not matched by /dev/ttyUSB* (e.g. a pty for testing)")
    p.add_argument("--headless", action="store_true",
                    help="no window: video capture + control socket only, for scripted use")
    return p.parse_args()


def run_headless(args):
    device = args.device or (None if args.demo else first_video_device())
    core = OdysseyCore(device=device, demo=args.demo)
    core.start()

    stop_event = threading.Event()
    server = ControlServer(core, on_shutdown=stop_event.set)
    try:
        server.start()
    except RuntimeError as e:
        sys.exit(f"odyssey_console: {e}")
    print(f"Odyssey Console (headless) listening on {server.socket_path}", flush=True)

    signal.signal(signal.SIGTERM, lambda signum, frame: stop_event.set())
    signal.signal(signal.SIGINT, lambda signum, frame: stop_event.set())
    stop_event.wait()

    server.stop()
    core.shutdown()


def main():
    args = parse_args()
    if args.headless:
        run_headless(args)
        return
    app = QApplication(sys.argv)
    device = args.device or (None if args.demo else first_video_device())
    win = MainWindow(device=device, demo=args.demo, preselect_port=args.port)
    win.resize(1400, 800)  # wider than tall, matching the side-by-side layout
    win.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
