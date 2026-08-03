"""ControlServer -- Unix-socket control surface over OdysseyCore.

Newline-delimited JSON in, one JSON object back per line. Deliberately
not JSON-RPC: this keeps odyctl and mcp_server.py stdlib-simple and the
wire trivially readable by hand (e.g. with `nc -U`).

An MCP stdio server is spawned by its own client as a subprocess, but the
app already holds the serial port and capture device open and neither
opens twice -- so this socket is the real API, and MCP/odyctl are both
just clients of it.
"""

import base64
import json
import os
import socket
import threading
import time


def default_socket_path():
    override = os.environ.get("ODYSSEY_CONSOLE_SOCKET")
    if override:
        return override
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir:
        return os.path.join(runtime_dir, "odyssey-console.sock")
    return f"/tmp/odyssey-console-{os.getuid()}.sock"


def _decode_payload(args):
    if "hex" in args:
        return bytes.fromhex(args["hex"])
    return args.get("text", "").encode("utf-8")


class ControlServer:
    """Listens on a Unix socket and dispatches newline-delimited JSON
    commands to an OdysseyCore. Each connection runs on its own thread
    and tracks its own serial-read cursor, starting from the moment it
    connected -- a single running core, but each client's "what's new"
    is independent of every other client's.
    """

    def __init__(self, core, socket_path=None, on_shutdown=None):
        self.core = core
        self.socket_path = socket_path or default_socket_path()
        self._on_shutdown = on_shutdown
        self._sock = None
        self._accept_thread = None
        self._stop = threading.Event()
        # Deliberately server-global, not per-connection: odyctl opens a
        # fresh connection for every single invocation, so a cursor tied
        # to the connection would forget everything between two calls --
        # exactly the backlog loss the cursor exists to prevent. A shared
        # position matches the "single consumer" assumption directly:
        # realistically one human or agent is reading the stream at a time.
        self._read_pos = 0
        self._read_pos_lock = threading.Lock()

    def start(self):
        if os.path.exists(self.socket_path):
            if self._has_live_listener(self.socket_path):
                raise RuntimeError(
                    f"another Odyssey Console instance is already running at "
                    f"{self.socket_path} -- stop it first (`odyctl shutdown`) "
                    f"or point this one at a different ODYSSEY_CONSOLE_SOCKET")
            os.unlink(self.socket_path)  # stale: leftover from an unclean exit
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.bind(self.socket_path)
        os.chmod(self.socket_path, 0o600)
        sock.listen(4)
        self._sock = sock
        self._stop.clear()
        self._accept_thread = threading.Thread(target=self._accept_loop, daemon=True)
        self._accept_thread.start()

    @staticmethod
    def _has_live_listener(path):
        """True if something is actively listening at path.

        A bind conflict used to be resolved by silently unlinking and
        stealing the path -- which orphans whatever was there before: it
        keeps running, keeps holding the hardware, and becomes forever
        unreachable by any new client, discoverable only via `ss`/`/proc`
        forensics. Connecting first tells stale (no listener, safe to
        reclaim) apart from live (must not steal) before touching anything.
        """
        probe = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        probe.settimeout(1)
        try:
            probe.connect(path)
            return True
        except OSError:
            return False
        finally:
            probe.close()

    def stop(self):
        self._stop.set()
        if self._sock is not None:
            self._sock.close()
        if os.path.exists(self.socket_path):
            os.unlink(self.socket_path)

    def _accept_loop(self):
        while not self._stop.is_set():
            try:
                conn, _ = self._sock.accept()
            except OSError:
                return
            threading.Thread(target=self._handle_conn, args=(conn,), daemon=True).start()

    def _handle_conn(self, conn):
        with conn:
            conn_file = conn.makefile("rwb")
            while not self._stop.is_set():
                line = conn_file.readline()
                if not line:
                    return
                try:
                    req = json.loads(line)
                except json.JSONDecodeError as e:
                    self._send(conn_file, {"ok": False, "error": f"invalid JSON: {e}"})
                    continue
                self._dispatch(req, conn_file)

    def _send(self, conn_file, obj):
        conn_file.write((json.dumps(obj) + "\n").encode("utf-8"))
        conn_file.flush()

    def _dispatch(self, req, conn_file):
        cmd = req.get("cmd")
        args = req.get("args") or {}
        try:
            result = self._run_cmd(cmd, args)
            self._send(conn_file, {"ok": True, **(result or {})})
        except Exception as e:
            self._send(conn_file, {"ok": False, "error": str(e)})
            return
        if cmd == "shutdown":
            # Tear down on a separate thread, after the ack above has had
            # a moment to actually reach the client -- calling stop()
            # inline here would be tearing down the very socket this
            # response is being written through.
            threading.Thread(target=self._deferred_shutdown, daemon=True).start()

    def _deferred_shutdown(self):
        time.sleep(0.2)
        if self._on_shutdown is not None:
            self._on_shutdown()

    def _run_cmd(self, cmd, args):
        core = self.core
        if cmd == "status":
            return core.status()
        if cmd == "list_ports":
            return {"ports": core.list_ports()}
        if cmd == "connect":
            core.connect(port=args.get("port"), baud=args.get("baud"))
            return {}
        if cmd == "disconnect":
            core.disconnect()
            return {}
        if cmd == "set_baud":
            core.set_baud(args["baud"])
            return {}
        if cmd == "set_rts":
            return {"rts": core.set_rts(args["value"])}
        if cmd == "serial_send":
            data = _decode_payload(args)
            return core.serial_send(data, expect=args.get("expect"),
                                     timeout=args.get("timeout", 5.0))
        if cmd == "serial_read":
            explicit_since = args.get("since")
            with self._read_pos_lock:
                since = self._read_pos if explicit_since is None else explicit_since
                data, new_pos = core.serial_read(since=since)
                if explicit_since is None:
                    self._read_pos = new_pos
            return {"data": data.decode("utf-8", "replace"), "since": new_pos}
        if cmd == "serial_expect":
            return core.serial_expect(args["pattern"], timeout=args.get("timeout", 5.0),
                                       since=args.get("since"))
        if cmd == "send_file":
            return core.send_file(args["path"])
        if cmd == "screencap":
            png = core.screencap()
            return {"png_base64": base64.b64encode(png).decode("ascii")}
        if cmd == "retry_capture":
            core.retry_capture()
            return {}
        if cmd == "shutdown":
            return {}  # actual teardown happens in _deferred_shutdown, after this acks
        raise ValueError(f"unknown command: {cmd!r}")
