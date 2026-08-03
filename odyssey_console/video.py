"""FFmpegCapture -- raw-frame video capture via an ffmpeg subprocess.

Reuses the exact v4l2/mjpeg pipeline /raid/odyssey-video.sh already proves
works against this capture adapter, but pipes raw RGB24 frames to Python
instead of opening ffplay's own window -- ffplay binds keys like space/p
to pause/seek, which is what makes it "freeze" when it has focus. Piping
frames out sidesteps that outright rather than working around ffplay's
keymap.

Format, size and framerate are module constants, not options: the capture
adapter is fixed hardware, so a one-line edit here beats maintaining a
CLI-flags surface for something that isn't expected to change.
"""

import subprocess
import threading
import time

VIDEO_SIZE = (640, 480)
INPUT_FORMAT = "mjpeg"
FRAMERATE = 60
FRAME_BYTES = VIDEO_SIZE[0] * VIDEO_SIZE[1] * 3  # rgb24

RESTART_DELAY = 2.0  # fixed delay after an unexpected ffmpeg exit; no backoff schedule

BUSY_MARKER = b"Device or resource busy"


def _build_cmd(device):
    w, h = VIDEO_SIZE
    return [
        "ffmpeg", "-hide_banner", "-loglevel", "error",
        "-f", "v4l2",
        "-input_format", INPUT_FORMAT,
        "-video_size", f"{w}x{h}",
        "-framerate", str(FRAMERATE),
        "-fflags", "nobuffer", "-flags", "low_delay",
        "-i", device,
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-",
    ]


def _build_demo_cmd():
    w, h = VIDEO_SIZE
    return [
        "ffmpeg", "-hide_banner", "-loglevel", "error",
        "-re",  # pace output to the declared rate; lavfi otherwise emits as fast as the CPU allows
        "-f", "lavfi", "-i", f"testsrc2=size={w}x{h}:rate=30",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-",
    ]


class FFmpegCapture:
    """Runs ffmpeg as a subprocess, reads exactly one frame's worth of
    bytes at a time, and hands each to on_frame. Restarts automatically
    on unexpected exit; on_busy fires when the device is already in use
    (e.g. by ffplay) so the caller can offer a Retry action.
    """

    def __init__(self, device=None, demo=False, on_frame=None, on_status=None, on_busy=None):
        self.device = device
        self.demo = demo
        self._on_frame = on_frame
        self._on_status = on_status  # on_status(str) -- "starting"/"running"/"stopped"
        self._on_busy = on_busy
        self.last_frame = None  # newest raw RGB24 bytes, for screencap
        self.last_frame_time = None
        self.frame_count = 0
        self._proc = None
        self._thread = None
        self._stderr_thread = None
        self._stop = threading.Event()

    @property
    def running(self):
        return self._thread is not None and self._thread.is_alive()

    def start(self):
        self.stop()
        self._stop.clear()
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()

    def stop(self):
        self._stop.set()
        if self._proc is not None:
            self._proc.terminate()
        if self._thread is not None:
            self._thread.join(timeout=3)
        self._proc = None
        self._thread = None

    def _status(self, s):
        if self._on_status is not None:
            self._on_status(s)

    def _run_loop(self):
        while not self._stop.is_set():
            self._status("starting")
            cmd = _build_demo_cmd() if self.demo else _build_cmd(self.device)
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            self._proc = proc
            stderr_buf = bytearray()
            stderr_thread = threading.Thread(
                target=self._drain_stderr, args=(proc, stderr_buf), daemon=True)
            stderr_thread.start()

            self._status("running")
            self._read_frames(proc)

            proc.wait()
            stderr_thread.join(timeout=1)
            self._proc = None

            if self._stop.is_set():
                self._status("stopped")
                return

            if BUSY_MARKER in stderr_buf and self._on_busy is not None:
                self._on_busy()
                self._status("stopped")
                return  # wait for an explicit restart via the Retry action

            self._status("stopped")
            time.sleep(RESTART_DELAY)

    def _read_frames(self, proc):
        while not self._stop.is_set():
            buf = self._read_exact(proc.stdout, FRAME_BYTES)
            if buf is None:
                return  # ffmpeg exited or pipe closed
            self.last_frame = buf
            self.last_frame_time = time.time()
            self.frame_count += 1
            if self._on_frame is not None:
                self._on_frame(buf)

    @staticmethod
    def _read_exact(pipe, n):
        chunks = []
        remaining = n
        while remaining > 0:
            chunk = pipe.read(remaining)
            if not chunk:
                return None
            chunks.append(chunk)
            remaining -= len(chunk)
        return b"".join(chunks)

    def _drain_stderr(self, proc, buf):
        while True:
            chunk = proc.stderr.read(4096)
            if not chunk:
                return
            buf.extend(chunk)
