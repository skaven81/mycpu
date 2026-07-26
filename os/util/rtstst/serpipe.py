#!/usr/bin/env python3
"""serpipe - send file(s) over a serial port and display transmission progress.

For each file a progress bar is shown.  If CTS is deasserted (remote asked us
to pause), "PAUSE" appears in red next to the bar.  Any bytes received from
the remote are printed below the progress area so full-duplex can be verified
while a large transfer is in progress.

Defaults to 9600,n,8,1 with RTS/CTS hardware flow control.

RTS is expected to remain asserted at all times.  A warning is printed to
STDERR if RTS drops, because a cheapo USB-to-RS232 adapter (and/or GTKterm)
has been observed dropping RTS after the first transmitted character for no
obvious reason.  This script exists to determine whether that behaviour is a
GTKterm quirk or a true device bug: run it with the same adapter and watch
whether the same RTS-drops-after-first-char symptom appears here.
"""

import argparse
import fcntl
import os
import struct
import sys
import termios
import threading
import time

import serial
from rich.columns import Columns
from rich.console import Console
from rich.progress import (
    BarColumn,
    FileSizeColumn,
    Progress,
    TaskProgressColumn,
    TextColumn,
    TimeRemainingColumn,
    TransferSpeedColumn,
)
from rich.text import Text

PARITY = {
    "n": serial.PARITY_NONE,
    "e": serial.PARITY_EVEN,
    "o": serial.PARITY_ODD,
    "m": serial.PARITY_MARK,
    "s": serial.PARITY_SPACE,
}

STOPBITS = {
    "1": serial.STOPBITS_ONE,
    "1.5": serial.STOPBITS_ONE_POINT_FIVE,
    "2": serial.STOPBITS_TWO,
}

BYTESIZE = {
    5: serial.FIVEBITS,
    6: serial.SIXBITS,
    7: serial.SEVENBITS,
    8: serial.EIGHTBITS,
}

# Chunk size for TX.  Small enough that Ctrl+C is responsive even when
# write() is blocked waiting for CTS.
TX_CHUNK = 256


def parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("files", nargs="+", metavar="FILE",
                   help="file(s) to transmit")
    p.add_argument("--port", default="/dev/ttyUSB0",
                   help="serial device (default: /dev/ttyUSB0)")
    p.add_argument("-b", "--baud", type=int, default=9600,
                   help="baud rate (default: 9600)")
    p.add_argument("-p", "--parity", choices=list(PARITY), default="n",
                   help="parity: n/e/o/m/s (default: n)")
    p.add_argument("-s", "--stopbits", choices=list(STOPBITS), default="1",
                   help="stop bits: 1/1.5/2 (default: 1)")
    p.add_argument("-d", "--databits", type=int, choices=list(BYTESIZE), default=8,
                   help="data bits: 5/6/7/8 (default: 8)")
    p.add_argument("-f", "--flow", choices=["rtscts", "xonxoff", "none"],
                   default="rtscts",
                   help="flow control (default: rtscts)")
    return p.parse_args()


def read_modem_bits(fd):
    """Return the raw TIOCM modem-control bitmask for the given fd."""
    packed = fcntl.ioctl(fd, termios.TIOCMGET, struct.pack("I", 0))
    return struct.unpack("I", packed)[0]


def tx_worker(ser, filepath, progress, task_id, stop_event):
    """Transmit one file in TX_CHUNK-sized writes.  Runs in its own thread.

    write() naturally blocks when CRTSCTS flow control pauses the UART
    (kernel TX buffer full because CTS is deasserted).  The small chunk size
    keeps Ctrl+C latency bounded once CTS is reasserted.
    """
    try:
        with open(filepath, "rb") as f:
            while not stop_event.is_set():
                chunk = f.read(TX_CHUNK)
                if not chunk:
                    break
                ser.write(chunk)
                progress.advance(task_id, len(chunk))
    except Exception as exc:
        progress.console.print(f"[red]TX error on {filepath}: {exc}[/red]")
    finally:
        progress.stop_task(task_id)


def main():
    args = parse_args()

    # Verify all files exist before opening the port.
    for path in args.files:
        if not os.path.isfile(path):
            sys.exit(f"serpipe: {path}: no such file")

    ser = serial.Serial(
        port=args.port,
        baudrate=args.baud,
        bytesize=BYTESIZE[args.databits],
        parity=PARITY[args.parity],
        stopbits=STOPBITS[args.stopbits],
        rtscts=(args.flow == "rtscts"),
        xonxoff=(args.flow == "xonxoff"),
        timeout=0,      # non-blocking reads
    )

    fd = ser.fileno()

    # Assert RTS and remember the initial state for change detection.
    ser.rts = True
    rts_was_on = bool(read_modem_bits(fd) & termios.TIOCM_RTS)
    if not rts_was_on:
        print("WARNING: RTS is not asserted after opening port", file=sys.stderr)

    stop_event = threading.Event()

    # Shared CTS state; written by the monitor loop, read by the status column.
    cts_state = {"on": True}

    console = Console()

    progress = Progress(
        TextColumn("[bold]{task.fields[fname]}[/bold]"),
        BarColumn(bar_width=40),
        TaskProgressColumn(),
        FileSizeColumn(),
        TransferSpeedColumn(),
        TimeRemainingColumn(),
        TextColumn("{task.fields[pause_tag]}"),
        console=console,
        refresh_per_second=10,
    )

    with progress:
        # Queue up a task per file (all visible from the start).
        tasks = []
        for path in args.files:
            size = os.path.getsize(path)
            tid = progress.add_task(
                description="",
                fname=os.path.basename(path),
                pause_tag="",
                total=size,
            )
            tasks.append((path, tid))

        # Start TX threads sequentially: wait for one to finish before the next.
        # Each thread is started while the progress context is live so the bar
        # updates are visible.
        try:
            for path, tid in tasks:
                t = threading.Thread(target=tx_worker,
                                     args=(ser, path, progress, tid, stop_event),
                                     daemon=True)
                t.start()

                # While this file's TX thread is running: poll for RX data,
                # watch CTS, and watch RTS.
                while t.is_alive():
                    # --- RX: drain whatever the serial port has for us ---
                    ser.timeout = 0
                    rx = ser.read(4096)
                    if rx:
                        # Print received bytes as a hex dump + printable ASCII
                        # side-by-side so binary data is still readable.
                        _print_rx(progress.console, rx)

                    # --- CTS: update pause indicator ---
                    bits = read_modem_bits(fd)
                    cts_on = bool(bits & termios.TIOCM_CTS)
                    if cts_on != cts_state["on"]:
                        cts_state["on"] = cts_on
                        #if not cts_on:
                        #    progress.console.print(
                        #        "[yellow]CTS deasserted — remote asked us to pause[/yellow]"
                        #    )
                        #else:
                        #    progress.console.print(
                        #        "[green]CTS reasserted — resuming[/green]"
                        #    )
                    pause_tag = "" if cts_on else "[bold red]PAUSE[/bold red]"
                    progress.update(tid, pause_tag=pause_tag)

                    # --- RTS: warn on unexpected drop ---
                    rts_on = bool(bits & termios.TIOCM_RTS)
                    if rts_on != rts_was_on:
                        if not rts_on:
                            progress.console.print(
                                "[bold red]WARNING: RTS dropped —"
                                " adapter bug confirmed, not GTKterm-specific[/bold red]"
                            )
                        else:
                            progress.console.print(
                                "[yellow]NOTICE: RTS re-asserted[/yellow]"
                            )
                        rts_was_on = rts_on

                    time.sleep(0.05)    # ~20 Hz poll

                t.join()

                # Drain any final RX bytes that arrived right as TX finished.
                time.sleep(0.1)
                rx = ser.read(4096)
                if rx:
                    _print_rx(progress.console, rx)

        except KeyboardInterrupt:
            stop_event.set()
            progress.console.print("[yellow]Interrupted.[/yellow]")

    ser.close()


def _print_rx(console, data: bytes):
    """Print received bytes as a hex dump with a printable ASCII column."""
    width = 16
    lines = []
    for i in range(0, len(data), width):
        row = data[i:i + width]
        hex_part = " ".join(f"{b:02x}" for b in row)
        asc_part = "".join(chr(b) if 0x20 <= b < 0x7F else "." for b in row)
        lines.append(f"  [cyan]{i:04x}[/cyan]  {hex_part:<{width*3}}  {asc_part}")
    block = "\n".join(lines)
    console.print(f"[bold green]<< RX {len(data)} byte(s):[/bold green]\n{block}")


if __name__ == "__main__":
    main()
