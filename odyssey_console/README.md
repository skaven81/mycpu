# Odyssey Console

A single window for driving the Odyssey from the lab PC: a live video pane
and a raw serial console, replacing two tools that didn't work well:

- **`/raid/odyssey-video.sh`** (ffplay) "freezes" if you press any key
  while it has focus. That's not a bug in the script — ffplay binds
  `space`/`p` to pause and other letters to seek/filter toggles, and there's
  no way to turn its keymap off. This app pipes raw frames out of ffmpeg
  instead of opening ffplay's own window, so there's no keymap to collide
  with.
- **GTKterm** mishandles RTS/CTS with this USB-to-RS232 adapter. `pyserial`
  drives it correctly, so this app is built on that instead.

Every capability here — watching the screen, typing at the console, pushing
a build, changing baud — is also reachable through a local control socket,
so scripts (`odyctl`) and agents (`mcp_server.py`) can do anything a human
can do at the window.

This is a single-purpose, single-consumer tool: it talks to the one
Odyssey that exists, through one fixed USB-RS232 adapter and one fixed
capture adapter. It isn't meant to generalize beyond that.

## Quick start

```
./odyssey_console.py                 # real hardware: first /dev/video*, /dev/ttyUSB*
./odyssey_console.py --demo          # synthetic test pattern, no capture hardware needed
./odyssey_console.py --device /dev/video1
./odyssey_console.py --port /dev/pts/4   # e.g. a pty, for testing without the adapter
```

No install step: `uv run` resolves PySide6 and pyserial from the script's
own PEP 723 header the first time you run it (a one-time ~250MB download).

## Using the window

**Video pane.** Shows the live capture, scaled to fit. The status line
reads `● LIVE`, `● STALLED` (no frame in the last 1.5s), or `● OFFLINE`,
plus a rolling FPS figure — that number is the proof frames are actually
arriving, since the Odyssey's screen is legitimately static most of the
time. If the capture device is busy (e.g. something else still has it
open), a **Retry** button appears.

**Serial console.** Type into it like a real terminal — every keystroke is
sent immediately (not line-buffered), Enter sends CR. `Ctrl+A`–`Ctrl+Z`
send `0x01`–`0x1A`. `Ctrl+Shift+C` copies your selection and `Ctrl+Shift+V`
pastes-and-sends, which leaves plain `Ctrl+C`/`Ctrl+V` free to send
`0x03`/`0x16` like a real terminal would.

It renders true CR/LF semantics, not a normalized version: LF starts a new
line, and CR alone returns to column 0 and starts overwriting — this is
what makes in-place progress output from the Odyssey render correctly
instead of smearing down the log.

- **CTS**/**RTS** LEDs show live modem-control line state (a real ioctl
  read-back, not a cached value — `pyserial`'s own RTS property is
  write-only, so this reads it directly).
- The **RTS** button drives the line manually. With hardware flow control
  enabled (the default), the kernel driver also manages RTS on its own, so
  a manual toggle may be overridden or only transient — this is expected,
  not a bug, and only fully deterministic with `rtscts` off.
- **Echo** renders your own keystrokes locally as you type them.
- **Clear** empties the console.
- **Send File…** runs the SERODY handshake with a waiting `serrun` on the
  Odyssey (the same protocol as `os/tools/serial_send.py` / `make serial`),
  showing a progress bar. It's passive — it works whether you start it
  before or after `serrun` is already retrying on the Odyssey side. Baud
  must already match whatever `setserial` last set on the Odyssey, since
  `serrun` doesn't change it.

The port dropdown only lists `/dev/ttyUSB*` devices, matching this app's
one supported adapter; `--port` can preselect anything else (used for
testing against a pty).

## `odyctl` — command-line client

Talks to the same control socket the GUI does. Useful for scripting, and
for debugging the socket or the MCP server by hand — no framework
involved, just JSON.

```
./odyctl status
./odyctl list-ports
./odyctl connect --port /dev/ttyUSB0 --baud 9600
./odyctl send 'HELLO' --expect 'OK' --timeout 5
./odyctl send '4F4B' --hex
./odyctl read                     # bytes since your last read
./odyctl expect 'READY' --timeout 10
./odyctl send-file build/PROGRAM.ODY
./odyctl screencap /tmp/shot.png
./odyctl set-baud 115200
./odyctl set-rts on
./odyctl shutdown                 # stop the running instance (GUI or headless) cleanly
```

`odyctl` requires nothing beyond the Python 3 standard library.

## Agent control via MCP

`mcp_server.py` bridges the same control socket to the Model Context
Protocol. An MCP stdio server is spawned as a subprocess by its own
client, but this app already holds the serial port and capture device
open — neither opens twice — so the MCP server can't be the process that
touches hardware. It's a thin client of the socket instead, exactly like
`odyctl`, which is also the tool to use when a `odyssey_*` MCP call isn't
doing what you expect.

Register it with Claude Code:

```
claude mcp add odyssey-console -- /net/geofront/raid/mycpu2/odyssey_console/mcp_server.py
```

This isn't committed as a repo-level `.mcp.json` on purpose: that would
auto-load the server for every Claude Code session opened in this repo,
and every tool call would error until `odyssey_console.py` happens to be
running. Registering it yourself (globally, or per-project) means it's
there when you want it.

If `odyssey_console.py` isn't running, every `odyssey_*` tool fails fast
with a message telling you to start it, rather than hanging.

Tools: `odyssey_status`, `odyssey_screencap` (returns a native-resolution
PNG as an inline image — no downscaling, since the Odyssey renders text),
`odyssey_serial_send` (text or hex, with optional `expect`/`timeout` so
"send a command, wait for the prompt" is one call instead of a poll loop),
`odyssey_serial_read`, `odyssey_serial_expect`, `odyssey_send_file`,
`odyssey_set_baud`, `odyssey_set_rts`, `odyssey_connect`,
`odyssey_disconnect`, `odyssey_list_ports`, `odyssey_retry_capture`,
`odyssey_shutdown`.

Bytes an agent sends render in the console in a distinct dim colour, so
it's always visible what the agent did.

## The control socket

A Unix domain socket at `$XDG_RUNTIME_DIR/odyssey-console.sock` (falling
back to `/tmp/odyssey-console-$UID.sock`), mode `0600`, speaking
newline-delimited JSON — one `{"cmd": ..., "args": {...}}` in, one
`{"ok": true, ...}` or `{"ok": false, "error": "..."}` back per line.
Readable by hand with `nc -U`.

Anything running as your user can drive the hardware through this socket.
That's the right tradeoff for a lab PC, but it's worth knowing rather than
discovering. There is no remote/network access to it at all.

Set `ODYSSEY_CONSOLE_SOCKET` to point everything (the app, `odyctl`,
`mcp_server.py`) at a non-default path — mainly useful for running tests
without touching a real running instance's socket.

## Troubleshooting

**"Device or resource busy"** on the video pane means something else
(ffplay, another instance of this app, ...) still has the capture device
open. Close it and click **Retry**.

**GTKterm doesn't work with this adapter** — that's exactly why this app
exists; use it or `odyctl`/pyserial-based tooling instead.

**RTS toggle doesn't seem to do anything** — expected with hardware flow
control on; see the CTS/RTS note above.

**A file transfer times out with no `DONE`** — the transfer may still
have completed on the Odyssey; the warning is conservative. Check the
Odyssey's screen/console output to confirm.

## Layout

| File | What it is |
|---|---|
| `odyssey_console.py` | the GUI app — entry point |
| `core.py` | `OdysseyCore` — the whole capability surface (capture + serial + transfer) |
| `video.py` | ffmpeg-subprocess video capture |
| `serial_link.py` | pyserial port management, RTS/CTS |
| `serrun_send.py` | the SERODY file-transfer protocol |
| `console.py` | the serial terminal widget |
| `control_server.py` | the Unix-socket control API |
| `mcp_server.py` | MCP bridge to the control socket |
| `odyctl` | CLI client for the control socket |

Only `odyssey_console.py` and `mcp_server.py` have external dependencies
(declared inline via PEP 723 — no venv, no lockfile). `core.py` and
everything below it in the table is plain Python plus PySide6/pyserial,
importable and testable without a display (see the pty- and
`--demo`-based tests used to build this).
