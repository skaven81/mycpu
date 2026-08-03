#!/usr/bin/env python3
"""serial_send - send an .ODY binary to a waiting `serrun` on the Odyssey.

Companion to os/util/serrun/ (the Odyssey-side receiver): invoked via
`make serial` from any program's build directory instead of `make sdcard`.

This is a thin client of the Odyssey Console control socket
(odyssey_console/control_server.py) -- the SERODY protocol itself is
implemented exactly once, in odyssey_console/serrun_send.py, not
reimplemented here. If no Odyssey Console instance (GUI or headless) is
already running, one is started headless automatically and left running,
so the next `make serial` reuses it instead of paying startup cost again.

Requires: nothing beyond the Python 3 standard library. Starting the
headless server (if needed) requires `uv` on PATH, same as running
odyssey_console.py directly.
"""

import argparse
import json
import os
import socket
import subprocess
import sys
import tempfile
import threading
import time

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ODYSSEY_CONSOLE_DIR = os.path.join(REPO_ROOT, "odyssey_console")
ODYSSEY_CONSOLE_ENTRY = os.path.join(ODYSSEY_CONSOLE_DIR, "odyssey_console.py")

STARTUP_TIMEOUT = 15.0
STATUS_POLL_INTERVAL = 1.0


def parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("file", metavar="FILE.ODY", help=".ODY file to send")
    p.add_argument("--port", default="/dev/ttyUSB0",
                   help="serial device (default: /dev/ttyUSB0)")
    p.add_argument("-b", "--baud", type=int, default=115200,
                   help="baud rate (default: 115200)")
    return p.parse_args()


def default_socket_path():
    override = os.environ.get("ODYSSEY_CONSOLE_SOCKET")
    if override:
        return override
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir:
        return os.path.join(runtime_dir, "odyssey-console.sock")
    return f"/tmp/odyssey-console-{os.getuid()}.sock"


def call(sock_path, cmd, args=None, timeout=10):
    """One newline-delimited JSON request/response -- same wire protocol
    as odyctl and mcp_server.py. Raises on any failure, including the
    socket not existing at all.
    """
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(timeout)
    s.connect(sock_path)
    try:
        f = s.makefile("rwb")
        f.write((json.dumps({"cmd": cmd, "args": args or {}}) + "\n").encode("utf-8"))
        f.flush()
        line = f.readline()
    finally:
        s.close()
    if not line:
        raise RuntimeError("connection closed with no response")
    resp = json.loads(line)
    if not resp.get("ok"):
        raise RuntimeError(resp.get("error", "unknown error"))
    return resp


def is_server_running(sock_path):
    try:
        call(sock_path, "status", timeout=2)
        return True
    except OSError:
        return False


def start_headless_server(sock_path):
    print("serial_send: no Odyssey Console running -- starting one headless...")
    log_path = os.path.join(tempfile.gettempdir(), f"odyssey-console-headless-{os.getuid()}.log")
    env = os.environ.copy()
    env["ODYSSEY_CONSOLE_SOCKET"] = sock_path
    with open(log_path, "ab") as log:
        proc = subprocess.Popen(
            [ODYSSEY_CONSOLE_ENTRY, "--headless"],
            cwd=ODYSSEY_CONSOLE_DIR, env=env,
            stdout=log, stderr=subprocess.STDOUT,
            start_new_session=True,  # survives this script's own process exiting
        )
    deadline = time.time() + STARTUP_TIMEOUT
    while time.time() < deadline:
        if proc.poll() is not None:
            sys.exit(f"serial_send: headless Odyssey Console exited immediately "
                      f"(code {proc.returncode}) -- see {log_path}")
        if is_server_running(sock_path):
            print("serial_send: headless Odyssey Console is up.")
            return
        time.sleep(0.3)
    sys.exit(f"serial_send: timed out waiting for the headless Odyssey Console to "
              f"start -- see {log_path}")


def ensure_connected(sock_path, port, baud):
    status = call(sock_path, "status")
    if status["connected"] and status["port"] == port and status["baud"] == baud:
        return
    if status["connected"]:
        call(sock_path, "disconnect")
    call(sock_path, "connect", {"port": port, "baud": baud})
    print(f"serial_send: connected to {port} @ {baud}")


def send_file(sock_path, path):
    """Runs send_file (which blocks server-side until the Odyssey
    responds) on a background thread so this script can poll status in
    the meantime and give some sign of life -- the wait for the Odyssey
    to show up is unbounded, same as the old serial_send.py's rendezvous.
    """
    outcome = {}

    def worker():
        try:
            outcome["result"] = call(sock_path, "send_file", {"path": path}, timeout=None)
        except Exception as e:
            outcome["error"] = e

    t = threading.Thread(target=worker, daemon=True)
    t.start()

    print("serial_send: waiting for Odyssey (serrun)...")
    announced_sending = False
    while t.is_alive():
        t.join(timeout=STATUS_POLL_INTERVAL)
        if not t.is_alive():
            break
        try:
            st = call(sock_path, "status", timeout=5)
        except OSError:
            continue
        if st.get("transfer_active") and not announced_sending:
            print("serial_send: Odyssey connected; sending...")
            announced_sending = True

    if "error" in outcome:
        sys.exit(f"serial_send: {outcome['error']}")
    return outcome["result"]


def main():
    args = parse_args()

    if not os.path.isfile(args.file):
        sys.exit(f"serial_send: {args.file}: no such file")

    sock_path = default_socket_path()
    if not is_server_running(sock_path):
        start_headless_server(sock_path)

    ensure_connected(sock_path, args.port, args.baud)
    result = send_file(sock_path, os.path.abspath(args.file))
    print(f"serial_send: sent {result['sent']} bytes; Odyssey confirmed receipt.")


if __name__ == "__main__":
    main()
