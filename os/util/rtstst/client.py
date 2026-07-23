#!/usr/bin/env python3
"""
Interactive RTS/CTS test tool for the PC side of the Odyssey UART link.
Mirrors os/util/rtstest on the Odyssey so you can drive/observe each
side independently before connecting them together.

Usage:
    python3 rts_cts_test.py /dev/ttyUSB0

Commands (press Enter after each):
    r  - toggle RTS output
    q  - quit

Continuously prints live CTS (input) and RTS (output) state.

Requires: pip install pyserial
"""

import sys
import time
import threading

try:
    import serial
except ImportError:
    print("This script requires pyserial: pip install pyserial")
    sys.exit(1)


def status_line(ser: "serial.Serial") -> str:
    cts = ser.cts   # True = CTS asserted (line high per RS232 mark/space
                     # convention as decoded by pyserial -- see note below)
    rts = ser.rts   # last commanded RTS output state
    return f"CTS(in): {'1' if cts else '0'}   RTS(out): {'1' if rts else '0'}"


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <serial-port>")
        sys.exit(1)

    port = sys.argv[1]
    ser = serial.Serial(port, baudrate=9600, rtscts=False)
    # rtscts=False here is intentional: we want MANUAL control of RTS,
    # not the driver auto-managing it. We toggle ser.rts ourselves and
    # just observe ser.cts. Turn rtscts=True back on later for the real
    # flow-controlled transfer test.

    ser.rts = False  # start deasserted; toggle with 'r'

    print(f"Opened {port}. RTS starts deasserted.")
    print("Commands: r=toggle RTS, q=quit")
    print(status_line(ser))

    stop = threading.Event()

    def poller():
        last = None
        while not stop.is_set():
            line = status_line(ser)
            if line != last:
                print(line)
                last = line
            time.sleep(0.1)

    t = threading.Thread(target=poller, daemon=True)
    t.start()

    try:
        while True:
            cmd = input().strip().lower()
            if cmd == "q":
                break
            elif cmd == "r":
                ser.rts = not ser.rts
                print(f"  -- RTS toggled to {'1' if ser.rts else '0'} --")
            else:
                print("Unknown command. r=toggle RTS, q=quit")
    except (KeyboardInterrupt, EOFError):
        pass
    finally:
        stop.set()
        t.join(timeout=0.5)
        ser.close()
        print("Closed port.")


if __name__ == "__main__":
    main()
