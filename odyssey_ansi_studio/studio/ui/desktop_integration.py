"""
First-run desktop integration (Linux / XDG).

GNOME Shell on Wayland -- and most Wayland shells -- ignore ``setWindowIcon()``
for the dock / task bar; they match a running window to an installed
``.desktop`` file by its ``app_id`` and take the icon from there.  Without one,
the window shows the generic "executable" placeholder.

`ensure_desktop_integration()` writes, into the user's ``XDG_DATA_HOME``:

  * ``applications/odyssey-ansi-studio.desktop`` -- ``StartupWMClass`` and the
    basename both equal the ``app_id`` the app sets
    (``QApplication.setDesktopFileName("odyssey-ansi-studio")``), so the live
    window binds to this entry;
  * ``icons/hicolor/<size>/apps/odyssey-ansi-studio.png`` for a range of sizes,
    rendered from :func:`studio.ui.appicon.app_icon`.

It is idempotent and best-effort: it rewrites only when the content would
change, and every failure is swallowed -- desktop integration must never stop
the app starting.  Remove the two paths above to undo it.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

APP_ID = "odyssey-ansi-studio"
_ICON_SIZES = (16, 24, 32, 48, 64, 128, 256)


def _data_home() -> Path:
    xdg = os.environ.get("XDG_DATA_HOME")
    if xdg:
        return Path(xdg)
    return Path.home() / ".local" / "share"


def _entry_path() -> str:
    """Absolute path to the launcher script (has a ``uv run`` shebang)."""
    argv0 = sys.argv[0] if sys.argv and sys.argv[0] else "odyssey_ansi_studio.py"
    return os.path.realpath(argv0)


def _desktop_text() -> str:
    exe = _entry_path()
    return (
        "[Desktop Entry]\n"
        "Type=Application\n"
        "Version=1.0\n"
        "Name=Odyssey ANSI Studio\n"
        "GenericName=Text-mode Graphics Editor\n"
        "Comment=Design TUIs and ANSI art for the Wire Wrap Odyssey\n"
        f"Exec={_shell_quote(exe)} %F\n"
        f"TryExec={_shell_quote(exe)}\n"
        f"Icon={APP_ID}\n"
        "Terminal=false\n"
        "Categories=Graphics;2DGraphics;\n"
        f"StartupWMClass={APP_ID}\n"
        "StartupNotify=true\n"
        "MimeType=application/x-odyssey-ansi-studio;\n"
    )


def _shell_quote(s: str) -> str:
    if s and all(c.isalnum() or c in "@%+=:,./-_" for c in s):
        return s
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _write_if_changed(path: Path, data: bytes) -> bool:
    try:
        if path.exists() and path.read_bytes() == data:
            return False
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_bytes(data)
        tmp.replace(path)
        return True
    except OSError:
        return False


def _render_icons(base: Path) -> bool:
    try:
        from studio.ui.appicon import app_icon
        from PySide6.QtCore import QSize
    except Exception:                        # noqa: BLE001
        return False
    icon = app_icon()
    wrote = False
    for sz in _ICON_SIZES:
        pm = icon.pixmap(QSize(sz, sz))
        if pm.isNull():
            continue
        img = pm.toImage()
        from PySide6.QtCore import QBuffer, QByteArray
        buf = QBuffer()
        buf.open(QBuffer.WriteOnly)
        if not img.save(buf, "PNG"):
            continue
        dest = base / f"{sz}x{sz}" / "apps" / f"{APP_ID}.png"
        wrote |= _write_if_changed(dest, bytes(buf.data()))
    return wrote


def _refresh_caches(data_home: Path) -> None:
    apps = str(data_home / "applications")
    hicolor = str(data_home / "icons" / "hicolor")
    for cmd in (["update-desktop-database", apps],
                ["gtk-update-icon-cache", "-q", "-t", "-f", hicolor]):
        exe = shutil.which(cmd[0])
        if not exe:
            continue
        try:
            subprocess.run([exe, *cmd[1:]], check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           timeout=10)
        except (OSError, subprocess.SubprocessError):
            pass


def ensure_desktop_integration(force: bool = False) -> "Path | None":
    """Install (or refresh) the ``.desktop`` file + icons.  Returns the
    ``.desktop`` path if anything was written, else ``None``.  Never raises."""
    if sys.platform != "linux":
        return None
    try:
        data_home = _data_home()
        desktop = data_home / "applications" / f"{APP_ID}.desktop"

        # _write_if_changed no-ops when the bytes match, so this both installs
        # on first run and keeps Exec= current if the repo directory moves.
        changed = _write_if_changed(desktop, _desktop_text().encode("utf-8"))
        changed |= _render_icons(data_home / "icons" / "hicolor")
        if changed or force:
            _refresh_caches(data_home)
        return desktop if (changed or force) else None
    except Exception:                        # noqa: BLE001 - integration is optional
        return None
