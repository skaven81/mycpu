"""SerialLink -- pyserial port management with RTS/CTS hardware flow control.

Settings validated against the real USB-to-RS232 adapter this app
targets: rtscts=True, 8N1, and an explicit ser.rts = True after open.
Writes go through a background thread and queue so a caller (including
the Qt GUI thread) never blocks on deasserted CTS itself -- only the
writer thread does.
"""

import fcntl
import glob
import queue
import struct
import termios
import threading

import serial

TX_CHUNK = 256  # keeps a single blocked write (waiting on CTS) short
READ_CHUNK = 4096
READER_POLL_TIMEOUT = 0.2  # bounds how long close() waits for the reader to notice

BAUD_RATES = [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
DEFAULT_BAUD = 9600


def list_ports():
    """Sorted /dev/ttyUSB* device paths -- the only adapter this app targets."""
    return sorted(glob.glob("/dev/ttyUSB*"))


def read_modem_bits(fd):
    """Raw TIOCM modem-control bitmask for an open serial fd.

    pyserial's ser.rts is write-only (it returns the last-requested value,
    not the real line state), so RTS readback needs this ioctl same as CTS.

    A pty has no real modem-control lines, so this ioctl raises ENOTTY on
    one -- returning "no bits set" rather than propagating that is what
    makes pty-based testing (this app's only off-hardware test method)
    possible at all. Real serial adapters always support TIOCMGET.
    """
    try:
        packed = fcntl.ioctl(fd, termios.TIOCMGET, struct.pack("I", 0))
    except OSError:
        return 0
    return struct.unpack("I", packed)[0]


class SerialLink:
    """Owns one open serial port: a reader thread delivering bytes to a
    callback, and a writer thread draining a queue of pending sends.
    """

    def __init__(self, on_data=None):
        self._on_data = on_data
        self.ser = None
        self.port = None
        self.baud = None
        self._write_q = None
        self._reader_thread = None
        self._writer_thread = None
        self._stop = threading.Event()

    @property
    def is_open(self):
        return self.ser is not None and self.ser.is_open

    def open(self, port, baud=DEFAULT_BAUD):
        self.close()
        ser = serial.Serial(
            port=port,
            baudrate=baud,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            rtscts=True,
            timeout=READER_POLL_TIMEOUT,
        )
        try:
            ser.rts = True
        except OSError:
            pass  # a pty (used for testing) doesn't support TIOCMBIS/BIC; real adapters do -- see read_modem_bits
        self.ser = ser
        self.port = port
        self.baud = baud
        self._write_q = queue.Queue()
        self._stop.clear()
        self._reader_thread = threading.Thread(target=self._reader_loop, daemon=True)
        self._writer_thread = threading.Thread(target=self._writer_loop, daemon=True)
        self._reader_thread.start()
        self._writer_thread.start()

    def close(self):
        self._stop.set()
        if self._write_q is not None:
            self._write_q.put(None)  # wake a blocked writer so it can see _stop
        if self._reader_thread is not None:
            self._reader_thread.join(timeout=2)
        if self._writer_thread is not None:
            self._writer_thread.join(timeout=2)
        if self.ser is not None:
            self.ser.close()
        self.ser = None
        self.port = None
        self.baud = None
        self._write_q = None
        self._reader_thread = None
        self._writer_thread = None

    def set_baud(self, baud):
        """Reopen the currently-open port at a new baud rate.

        serrun does not change the Odyssey's UART speed itself -- the
        caller is responsible for making sure it matches what `setserial`
        last set on the Odyssey side.
        """
        if not self.is_open:
            raise RuntimeError("not connected")
        port = self.port
        self.close()
        self.open(port, baud)

    def send(self, data, on_progress=None):
        """Queue bytes for transmission; returns immediately.

        If given, on_progress(bytes_sent, total_bytes) is called from the
        writer thread after each chunk goes out -- used by file transfers
        to report progress without duplicating the chunking logic.
        """
        if not self.is_open:
            raise RuntimeError("not connected")
        self._write_q.put((bytes(data), on_progress))

    def get_cts(self):
        if not self.is_open:
            return False
        return bool(read_modem_bits(self.ser.fileno()) & termios.TIOCM_CTS)

    def get_rts(self):
        if not self.is_open:
            return False
        return bool(read_modem_bits(self.ser.fileno()) & termios.TIOCM_RTS)

    def set_rts(self, value):
        if not self.is_open:
            raise RuntimeError("not connected")
        self.ser.rts = bool(value)

    def _reader_loop(self):
        while not self._stop.is_set():
            try:
                chunk = self.ser.read(READ_CHUNK)
            except (OSError, serial.SerialException):
                return
            if chunk and self._on_data is not None:
                self._on_data(chunk)

    def _writer_loop(self):
        while not self._stop.is_set():
            item = self._write_q.get()
            if item is None:
                continue
            data, on_progress = item
            total = len(data)
            pos = 0
            while pos < total and not self._stop.is_set():
                chunk = data[pos:pos + TX_CHUNK]
                try:
                    self.ser.write(chunk)
                except (OSError, serial.SerialException):
                    return
                pos += len(chunk)
                if on_progress is not None:
                    on_progress(pos, total)
