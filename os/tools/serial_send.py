#!/usr/bin/env python3
"""serial_send - send an .ODY binary to a waiting `serrun` on the Odyssey.

Companion to os/util/serrun/ (the Odyssey-side receiver): invoked via
`make serial` from any program's build directory instead of `make sdcard`.
Waits for the Odyssey to announce itself, sends a small header (8.3
filename + size), streams the file, and waits for a completion marker.

The Odyssey is the active side (it "connects out" by sending SERODY
repeatedly); this script is passive from the moment it starts, so it
works whichever side the user starts first -- if `serrun` was already
running and retrying, the very next retry is picked up as soon as this
script opens the port.

Requires: pip install pyserial click
Defaults to 115200,n,8,1 with RTS/CTS hardware flow control -- make sure
the Odyssey's current UART speed (set via the `setserial` utility) matches
--baud, since serrun does not change the baud rate itself.
"""

import argparse
import fcntl
import os
import struct
import sys
import termios
import threading
import time

try:
    import serial
except ImportError:
    sys.exit("serial_send: this script requires pyserial: pip install pyserial")

try:
    import click
except ImportError:
    sys.exit("serial_send: this script requires click: pip install click")

# Wire protocol tokens -- see os/README-bios-exec.md's direct-exec section
# and os/util/serrun/main.c for the Odyssey-side half of this protocol.
SERODY_TOKEN = b"SERODY"
OK_TOKEN = b"OK"
DONE_TOKEN = b"DONE"
FAIL_TOKEN = b"FAIL"

# Chunk size for TX. Small enough that Ctrl+C is responsive even when
# write() is blocked waiting for CTS (matches os/util/rtstst/serpipe.py).
TX_CHUNK = 256

# How long to wait for SERODY, and for DONE after the last byte, before
# giving up. These are wall-clock timeouts (unlike serrun's spin-count
# retry loop, the PC side has a real clock available).
RENDEZVOUS_TIMEOUT = None  # wait forever for the Odyssey by default
COMPLETION_TIMEOUT = 5.0


def parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("file", metavar="FILE.ODY", help=".ODY file to send")
    p.add_argument("--port", default="/dev/ttyUSB0",
                   help="serial device (default: /dev/ttyUSB0)")
    p.add_argument("-b", "--baud", type=int, default=115200,
                   help="baud rate (default: 115200)")
    return p.parse_args()


def read_modem_bits(fd):
    """Return the raw TIOCM modem-control bitmask for the given fd."""
    packed = fcntl.ioctl(fd, termios.TIOCMGET, struct.pack("I", 0))
    return struct.unpack("I", packed)[0]


def to_8_3_field(filename):
    """Encode a filename as the 12-byte wire name field: 8-byte
    space-padded name + 3-byte space-padded extension + 1 reserved byte.
    """
    base = os.path.basename(filename)
    name, ext = os.path.splitext(base)
    ext = ext.lstrip(".")
    if len(name) > 8 or len(ext) > 3:
        sys.exit(f"serial_send: {filename!r} is not a valid 8.3 filename")
    name_bytes = name.upper().encode("ascii").ljust(8)
    ext_bytes = ext.upper().encode("ascii").ljust(3)
    return name_bytes + ext_bytes + b"\x00"


def scan_for_token(buf, token):
    """Return True and trim buf up to and including token if token is
    present; buf is capped so it can't grow unboundedly while waiting.
    """
    idx = buf.find(token)
    if idx == -1:
        if len(buf) > 64:
            del buf[:-32]
        return False
    del buf[:idx + len(token)]
    return True


def wait_for_token(ser, token, timeout, label):
    """Poll for `token` to appear in the incoming stream. Returns True on
    success, False on timeout (only meaningful when timeout is not None).
    """
    buf = bytearray()
    start = time.time()
    while True:
        chunk = ser.read(256)
        if chunk:
            buf.extend(chunk)
            if scan_for_token(buf, token):
                return True
        if timeout is not None and (time.time() - start) > timeout:
            return False
        time.sleep(0.02)


def rendezvous(ser):
    click.echo("Waiting for Odyssey (serrun)...")
    if not wait_for_token(ser, SERODY_TOKEN, RENDEZVOUS_TIMEOUT, "SERODY"):
        sys.exit("serial_send: timed out waiting for SERODY")
    ser.write(OK_TOKEN)
    click.echo("Odyssey connected.")


def tx_worker(ser, data, state, stop_event):
    pos = 0
    total = len(data)
    try:
        while pos < total and not stop_event.is_set():
            chunk = data[pos:pos + TX_CHUNK]
            ser.write(chunk)
            pos += len(chunk)
            state["sent"] = pos
    finally:
        state["done"] = True


def send_file(ser, fd, path):
    with open(path, "rb") as f:
        data = f.read()
    size = len(data)
    if size > 0xFFFF:
        sys.exit(f"serial_send: {path} is too large ({size} bytes, max 65535)")

    name_field = to_8_3_field(path)
    header = name_field + struct.pack(">H", size)
    ser.write(header)

    display_name = (name_field[:8].rstrip(b" ") + b"." + name_field[8:11].rstrip(b" ")).decode("ascii")

    state = {"sent": 0, "done": False, "paused": False}
    stop_event = threading.Event()
    start_time = time.time()

    with click.progressbar(length=size, label=display_name,
                            item_show_func=lambda x: x or "") as bar:
        t = threading.Thread(target=tx_worker, args=(ser, data, state, stop_event), daemon=True)
        t.start()
        last_sent = 0
        try:
            while not state["done"]:
                bits = read_modem_bits(fd)
                cts_on = bool(bits & termios.TIOCM_CTS)
                sent = state["sent"]
                elapsed = max(time.time() - start_time, 0.001)
                rate_kb = (sent / 1024.0) / elapsed
                status = f"{rate_kb:.1f} KB/s"
                if not cts_on:
                    status += "  [PAUSE]"
                if sent > last_sent:
                    bar.update(sent - last_sent, current_item=status)
                    last_sent = sent
                else:
                    bar.update(0, current_item=status)
                time.sleep(0.05)
        except KeyboardInterrupt:
            stop_event.set()
            t.join()
            sys.exit("serial_send: interrupted")
        t.join()
        sent = state["sent"]
        if sent > last_sent:
            bar.update(sent - last_sent)

    elapsed = max(time.time() - start_time, 0.001)
    rate_kb = (size / 1024.0) / elapsed
    click.echo(f"Sent {size} bytes in {elapsed:.1f}s ({rate_kb:.1f} KB/s)")

    buf = bytearray()
    start = time.time()
    while True:
        chunk = ser.read(256)
        if chunk:
            buf.extend(chunk)
            if scan_for_token(buf, FAIL_TOKEN):
                sys.exit("serial_send: Odyssey reported an invalid ODY file")
            if scan_for_token(buf, DONE_TOKEN):
                click.echo("Odyssey confirmed receipt; program is starting.")
                return
        if (time.time() - start) > COMPLETION_TIMEOUT:
            click.echo("serial_send: warning: no confirmation from Odyssey "
                       "within timeout (transfer may still have succeeded)",
                       err=True)
            return
        time.sleep(0.02)


def main():
    args = parse_args()

    if not os.path.isfile(args.file):
        sys.exit(f"serial_send: {args.file}: no such file")

    ser = serial.Serial(
        port=args.port,
        baudrate=args.baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        rtscts=True,
        timeout=0,      # non-blocking reads
    )
    fd = ser.fileno()
    ser.rts = True

    try:
        rendezvous(ser)
        send_file(ser, fd, args.file)
    finally:
        ser.close()


if __name__ == "__main__":
    main()
