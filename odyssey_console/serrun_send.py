"""SerrunTransfer -- feed-bytes state machine for the SERODY protocol.

Wire format (verified against os/util/serrun/main.c, the Odyssey-side
receiver): the Odyssey repeats "SERODY" until the PC replies "OK", then
the PC sends a 14-byte header (12-byte 8.3 name field + 2-byte
big-endian size) followed by the raw file, and waits for "DONE" or
"FAIL". This is the single implementation of that protocol -- the
original standalone os/tools/serial_send.py (which validated the wire
format against os/util/serrun/main.c in the first place) is now a thin
client of the control socket built on this module, rather than a second
implementation of the same handshake.

A standalone script can afford a blocking read loop because it owns the
whole process. Here SerialLink's reader thread already owns the port and
dispatches every incoming chunk to callbacks, so this has to be something
that *consumes* bytes handed to it rather than a loop that pulls them --
feed_data() is that consumer.
"""

import os
import time

SERODY_TOKEN = b"SERODY"
OK_TOKEN = b"OK"
DONE_TOKEN = b"DONE"
FAIL_TOKEN = b"FAIL"

COMPLETION_TIMEOUT = 5.0

STATE_IDLE = "idle"
STATE_WAIT_SERODY = "wait_serody"
STATE_WAIT_COMPLETE = "wait_complete"
STATE_DONE = "done"
STATE_FAILED = "failed"


def to_8_3_field(filename):
    """Encode a filename as the 12-byte wire name field: 8-byte
    space-padded name + 3-byte space-padded extension + 1 reserved byte.
    """
    base = os.path.basename(filename)
    name, ext = os.path.splitext(base)
    ext = ext.lstrip(".")
    if len(name) > 8 or len(ext) > 3:
        raise ValueError(f"{filename!r} is not a valid 8.3 filename")
    name_bytes = name.upper().encode("ascii").ljust(8)
    ext_bytes = ext.upper().encode("ascii").ljust(3)
    return name_bytes + ext_bytes + b"\x00"


def scan_for_token(buf, token):
    """Return True and trim buf up to and including token if present; buf
    is capped so it can't grow unboundedly while waiting.
    """
    idx = buf.find(token)
    if idx == -1:
        if len(buf) > 64:
            del buf[:-32]
        return False
    del buf[:idx + len(token)]
    return True


class SerrunTransfer:
    """One file transfer at a time (not reentrant -- start() raises if a
    transfer is already active). Feed it incoming serial bytes via
    feed_data(); call poll() periodically and independently of incoming
    data so the completion timeout can fire even if the Odyssey never
    replies at all.
    """

    def __init__(self, send_fn):
        """send_fn(data, on_progress=None) queues bytes for transmission
        -- SerialLink.send matches this signature directly.
        """
        self._send = send_fn
        self.state = STATE_IDLE
        self.error = None
        self.sent = 0
        self.total = 0
        self.display_name = None
        self._buf = bytearray()
        self._data = b""
        self._header = b""
        self._complete_deadline = None

    @property
    def active(self):
        return self.state in (STATE_WAIT_SERODY, STATE_WAIT_COMPLETE)

    def start(self, path):
        if self.active:
            raise RuntimeError("a transfer is already in progress")
        with open(path, "rb") as f:
            data = f.read()
        if len(data) > 0xFFFF:
            raise ValueError(f"{path} is too large ({len(data)} bytes, max 65535)")
        name_field = to_8_3_field(path)
        self.display_name = (name_field[:8].rstrip(b" ") + b"." +
                              name_field[8:11].rstrip(b" ")).decode("ascii")
        self._header = name_field + len(data).to_bytes(2, "big")
        self._data = data
        self.total = len(data)
        self.sent = 0
        self.error = None
        self._buf.clear()
        self.state = STATE_WAIT_SERODY

    def cancel(self):
        self.state = STATE_IDLE
        self._buf.clear()

    def feed_data(self, chunk):
        """Feed bytes read from the serial port. Returns True if the
        transfer consumed this chunk as protocol traffic -- the caller
        typically also mirrors these bytes to the console, dimmed.
        """
        if self.state == STATE_WAIT_SERODY:
            self._buf.extend(chunk)
            if scan_for_token(self._buf, SERODY_TOKEN):
                self._send(OK_TOKEN)
                self._send(self._header)
                self._send(self._data, on_progress=self._on_progress)
                self._buf.clear()
                self.state = STATE_WAIT_COMPLETE
                self._complete_deadline = time.time() + COMPLETION_TIMEOUT
            return True
        if self.state == STATE_WAIT_COMPLETE:
            self._buf.extend(chunk)
            if scan_for_token(self._buf, FAIL_TOKEN):
                self.state = STATE_FAILED
                self.error = "Odyssey reported an invalid ODY file"
            elif scan_for_token(self._buf, DONE_TOKEN):
                self.state = STATE_DONE
            return True
        return False

    def poll(self):
        """Call on a timer independent of incoming data -- if the Odyssey
        never replies, no more feed_data() calls will ever arrive to
        notice the deadline has passed.
        """
        if (self.state == STATE_WAIT_COMPLETE and
                time.time() > self._complete_deadline):
            self.state = STATE_FAILED
            self.error = ("no confirmation from Odyssey within timeout "
                           "(transfer may still have succeeded)")

    def _on_progress(self, sent, total):
        self.sent = sent
