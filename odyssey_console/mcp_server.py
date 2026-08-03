#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["mcp>=1.2,<2"]
# ///
"""mcp_server.py -- MCP bridge to the Odyssey Console control socket.

An MCP stdio server is spawned by its own client as a subprocess, but
odyssey_console.py already holds the serial port and capture device
open -- neither opens twice. So this cannot be the process that talks to
hardware; it's a thin client of the control socket instead, exactly like
odyctl. Every tool here mirrors something a human can do at the window.

Needs neither PySide6 nor pyserial, so it starts fast and stays usable
for diagnosing the socket even when the much heavier GUI app isn't
running -- in that case every tool below fails with a clear message
rather than hanging, since a stuck MCP server is worse than one that
fails fast.
"""

import base64
import json
import os
import socket

from mcp.server.fastmcp import FastMCP, Image


def default_socket_path():
    override = os.environ.get("ODYSSEY_CONSOLE_SOCKET")
    if override:
        return override
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir:
        return os.path.join(runtime_dir, "odyssey-console.sock")
    return f"/tmp/odyssey-console-{os.getuid()}.sock"


SOCKET_PATH = default_socket_path()
NOT_RUNNING_MSG = ("Odyssey Console is not running -- start it with "
                    "./odyssey_console.py (see odyssey_console/README.md)")


class NotRunning(Exception):
    pass


def call(cmd, args=None):
    """Send one newline-delimited JSON command to the control socket and
    return its result dict, or raise on failure. Same wire protocol as
    odyctl -- see control_server.py.
    """
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(10)
    try:
        sock.connect(SOCKET_PATH)
    except OSError as e:
        raise NotRunning(str(e)) from e
    try:
        f = sock.makefile("rwb")
        f.write((json.dumps({"cmd": cmd, "args": args or {}}) + "\n").encode("utf-8"))
        f.flush()
        line = f.readline()
    finally:
        sock.close()
    if not line:
        raise NotRunning("connection closed with no response")
    resp = json.loads(line)
    if not resp.get("ok"):
        raise RuntimeError(resp.get("error", "unknown error"))
    return resp


def _tool_call(cmd, args=None):
    try:
        return call(cmd, args)
    except NotRunning:
        raise RuntimeError(NOT_RUNNING_MSG) from None


mcp = FastMCP("odyssey-console")


@mcp.tool()
def odyssey_status() -> dict:
    """Connection, capture and transfer status: port, baud, CTS/RTS line
    state, video capture state (live/stalled/offline/busy), fps, and
    whether a file transfer is in progress."""
    return _tool_call("status")


@mcp.tool()
def odyssey_list_ports() -> dict:
    """List available /dev/ttyUSB* serial devices."""
    return _tool_call("list_ports")


@mcp.tool()
def odyssey_connect(port: str | None = None, baud: int | None = None) -> dict:
    """Open the serial port. Defaults to the first /dev/ttyUSB* device
    found and 9600 baud if not given."""
    return _tool_call("connect", {"port": port, "baud": baud})


@mcp.tool()
def odyssey_disconnect() -> dict:
    """Close the serial port."""
    return _tool_call("disconnect")


@mcp.tool()
def odyssey_set_baud(baud: int) -> dict:
    """Reopen the serial port at a new baud rate. Note: serrun does not
    change the Odyssey's own UART speed -- this must match whatever
    `setserial` last set on the Odyssey side."""
    return _tool_call("set_baud", {"baud": baud})


@mcp.tool()
def odyssey_set_rts(value: bool) -> dict:
    """Drive the RTS line. With hardware flow control enabled (the
    default), the kernel driver also manages RTS itself, so a manual
    toggle may be overridden or only transient -- the returned value is
    always a true ioctl read-back, not just an echo of the request."""
    return _tool_call("set_rts", {"value": value})


@mcp.tool()
def odyssey_retry_capture() -> dict:
    """Retry video capture after a busy-device error (e.g. after freeing
    up the capture device that something else had open)."""
    return _tool_call("retry_capture")


@mcp.tool()
def odyssey_shutdown() -> dict:
    """Stop the running Odyssey Console (GUI or headless), releasing the
    serial port and capture device. Use this instead of asking the user
    to find and kill a process -- e.g. before starting a fresh headless
    instance for a build/transfer task."""
    return _tool_call("shutdown")


@mcp.tool()
def odyssey_serial_send(text: str | None = None, hex_data: str | None = None,
                         expect: str | None = None, timeout: float = 5.0) -> dict:
    """Send bytes to the Odyssey over the open serial port -- give either
    text (sent as UTF-8) or hex_data (e.g. "4f4b" for "OK"), not both. If
    expect is given, blocks until that substring appears in the reply or
    the timeout elapses, returning what was matched -- this is the
    primitive for "send a command, wait for the prompt" without a
    poll-sleep loop racing the device."""
    args = {"hex": hex_data} if hex_data is not None else {"text": text or ""}
    if expect is not None:
        args["expect"] = expect
        args["timeout"] = timeout
    return _tool_call("serial_send", args)


@mcp.tool()
def odyssey_serial_read(since: int | None = None) -> dict:
    """Read bytes received since the last read (or since an explicit
    absolute `since` offset). Returns {"data": ..., "since": <new cursor>}."""
    return _tool_call("serial_read", {"since": since} if since is not None else {})


@mcp.tool()
def odyssey_serial_expect(pattern: str, timeout: float = 5.0, since: int | None = None) -> dict:
    """Block until `pattern` appears in incoming serial data, or time out.
    Returns {"matched": bool, "data": <what was seen>}."""
    args = {"pattern": pattern, "timeout": timeout}
    if since is not None:
        args["since"] = since
    return _tool_call("serial_expect", args)


@mcp.tool()
def odyssey_send_file(path: str) -> dict:
    """Send a .ODY binary to a waiting `serrun` on the Odyssey over the
    open serial port (the SERODY protocol). Blocks until the transfer
    completes or fails; baud must already match what `setserial` set on
    the Odyssey side."""
    return _tool_call("send_file", {"path": path})


@mcp.tool()
def odyssey_screencap() -> Image:
    """Capture the current Odyssey video frame at native resolution (no
    downscaling -- the Odyssey renders text, so legibility matters).
    Fails with the capture state named (e.g. "stalled") if there is no
    current live frame."""
    resp = _tool_call("screencap")
    png = base64.b64decode(resp["png_base64"])
    return Image(data=png, format="png")


if __name__ == "__main__":
    mcp.run(transport="stdio")
