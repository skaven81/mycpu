"""
Qt GUI layer for Odyssey ANSI Studio.

This package is a thin view over ``studio.model`` -- widgets carry no editing
logic in Phase 1 (the canvas is read-only).  ``theme_icon`` lives here rather
than in the entry-point script so widget modules can import it without pulling
in ``odyssey_ansi_studio`` (which runs as ``__main__``).
"""

from PySide6.QtGui import QIcon
from PySide6.QtWidgets import QApplication, QStyle

__all__ = ["theme_icon"]


def theme_icon(name: str, fallback_sp: "QStyle.StandardPixmap") -> QIcon:
    """A themed icon by freedesktop ``name``, falling back to a Qt standard icon.

    ``QIcon.fromTheme`` returns a null icon on platforms/themes without the
    named icon (common on the offscreen platform and on minimal desktops); in
    that case fall back to ``style().standardIcon(fallback_sp)``.
    """
    icon = QIcon.fromTheme(name)
    if icon.isNull():
        app = QApplication.instance()
        style = app.style() if app is not None else None
        if style is not None:
            icon = style.standardIcon(fallback_sp)
    return icon
