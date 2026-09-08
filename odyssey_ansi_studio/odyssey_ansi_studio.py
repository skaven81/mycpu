#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["PySide6>=6.6", "Pillow>=9.0", "numpy>=1.21", "jeepney>=0.8"]
# ///
"""
Odyssey ANSI Studio -- a layer-based text-mode graphics editor for the
Wire Wrap Odyssey computer.

WHAT
    A Linux desktop app for designing rich TUIs and ANSI art targeting the
    Odyssey's 64x60 character display (one CP437 glyph + one 6-bit RGB color
    per cell, no background color, optional blink bit).  Every box / text
    window / imported image is its own *layer*; layers carry a sparse cell
    grid plus an (x, y) offset, never interact, and compose top-down (the
    topmost layer with a non-NULL glyph for a cell wins glyph *and* color).
    Designs are saved in a layer-preserving project format and *exported* to
    Odyssey-consumable formats (v1: the native `ESC[<v>p` .ANS form).

WHY
    Hand-authoring VRAM dumps (see os/bootbanner/gen.py) or driving the
    terminal escape-by-escape is slow and error-prone.  A direct-manipulation
    editor that speaks the hardware's exact cell model -- and keeps the
    "empty != space" distinction the compositor depends on -- makes building
    these screens practical.

STATUS -- v1 complete + follow-ups
    Canvas opens at 2x with a cyan 64x60 boundary frame, off-canvas overflow
    bars, and a NULL-cell checkerboard toggle; `.oas` save/load (with embedded
    image sources); exports -- native `ESC[<v>p` `.ANS`, portable 16-color
    `.ANS`, raw split/interleaved binary, C header, ASM data, PNG -- each with a
    choice of how to store empty cells (space / NULL / black block / transparent
    cursor-skip); a grouped tool rail with horizontal rules -- cells
    (select / cell-edit / recolor / move-layer), draw (pencil, eraser, line,
    rectangle, ellipse, flood fill, gradient), and one-shot new-layer buttons
    (box / text / image / blank); the select / move tools show the active
    layer's boundary on the canvas with drag handles that resize box / text /
    image layers in place; a click-to-edit cell inspector and undo/redo; the
    Ink panel's "Pick..." button samples a color anywhere on screen via the
    desktop's native picker (xdg-desktop-portal, with a frozen-overlay X11
    fallback) and matches it to an Odyssey color in a split-screen dialog that
    opens with the nearest color already suggested; on
    first launch an XDG `.desktop` entry + icon set is written to
    `~/.local/share` so the task bar shows the app icon (`--install-desktop`
    forces it, `--no-desktop-integration` skips it); a palette panel (64 colors
    + a two-row ANSI-16 strip + interactive R/G/B + a named project palette) and
    glyph picker (per-bank grid, search, an ink-colored current-glyph indicator,
    block quick-picks, 16-bank selector); Blank / Box / Text / Image layers with
    re-editable Box/Text dialogs (a new layer inherits the current ink; every
    color field -- border / fill / distinct title + footer -- opens the shared
    ink picker; box titles/footers take a one-glyph flair each side -- the
    style-matched line junction, e.g. |- TEXT -|, or literal { } [ ] ( ) etc.),
    OKLab-or-RGB image import
    (interactive crop, posterize, dithering), an eye / padlock toggle per row;
    layer groups (hide/collapse); duplicate, delete, reorder, merge-down,
    flatten.  `--demo` exercises every render path.
    `--selftest [--shot PATH]` builds the window headlessly, renders one frame,
    optionally writes a screenshot, prints "ok" and exits -- used by CI and the
    phase verify step.

    Run the test suite:
        QT_QPA_PLATFORM=offscreen uv run --extra dev pytest tests/ -q
"""

import argparse
import signal
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))


def build_arg_parser() -> argparse.ArgumentParser:
    """Construct the CLI parser.

    Its own function so later phases can grow real options (device / open a
    file / theme) around the GUI bootstrap without reshaping `main`.
    """
    parser = argparse.ArgumentParser(
        prog="odyssey_ansi_studio",
        description="Layer-based text-mode graphics editor for the Wire Wrap Odyssey.",
    )
    parser.add_argument(
        "--demo",
        action="store_true",
        help="load a bundled sample document on start",
    )
    parser.add_argument(
        "--selftest",
        action="store_true",
        help="build the window, render one frame, print 'ok', exit 0 (no event loop)",
    )
    parser.add_argument(
        "--shot",
        metavar="PATH",
        default=None,
        help="with --selftest: save the rendered canvas to PATH (PNG)",
    )
    parser.add_argument(
        "--install-desktop",
        action="store_true",
        help="(re)write the XDG .desktop file + icons so the task bar shows the "
             "app icon, then exit (needed on Wayland, where setWindowIcon is "
             "ignored by the shell)",
    )
    parser.add_argument(
        "--no-desktop-integration",
        action="store_true",
        help="do not touch ~/.local/share on launch",
    )
    return parser


def theme_icon(name, fallback_sp):
    """A themed `QIcon` by freedesktop `name`, falling back to a Qt standard icon.

    Thin re-export of `studio.ui.theme_icon` so the helper is reachable from
    the entry point as the plan specifies; the implementation lives in
    `studio/ui/__init__.py` so widget modules can use it without importing this
    script (which runs as `__main__`).
    """
    from studio.ui import theme_icon as _impl
    return _impl(name, fallback_sp)


def main(argv=None) -> int:
    """Parse args, start Qt, show the main window (or run `--selftest`)."""
    args = build_arg_parser().parse_args(argv)

    from PySide6.QtWidgets import QApplication

    from studio.model.document import new_blank_document
    from studio.ui import demo as demo_mod
    from studio.ui.appicon import app_icon
    from studio.ui.desktop_integration import ensure_desktop_integration
    from studio.ui.main_window import MainWindow

    app = QApplication(sys.argv[:1])        # icons need a QGuiApplication first
    app.setApplicationName("Odyssey ANSI Studio")
    app.setApplicationDisplayName("Odyssey ANSI Studio")
    app.setDesktopFileName("odyssey-ansi-studio")
    app.setWindowIcon(app_icon())

    if args.install_desktop:
        path = ensure_desktop_integration(force=True)
        print(f"desktop entry: {path}" if path
              else "desktop integration unavailable on this platform")
        return 0

    if not args.selftest and not args.no_desktop_integration:
        ensure_desktop_integration()        # first-run XDG entry + icons; best-effort

    use_demo = args.demo or args.selftest
    document = demo_mod.demo_document() if use_demo else new_blank_document()

    win = MainWindow(document)
    if use_demo:
        win.canvas.set_demo_selection(demo_mod.DEMO_SELECTION)
        win.canvas.set_caret(demo_mod.DEMO_CARET)
        win.preview_cell(*demo_mod.DEMO_CARET)
    win.show()

    if args.selftest:
        win.canvas.refresh()
        app.processEvents()
        if args.shot:
            pix = win.canvas.grab()
            ok = pix.save(args.shot)
            print(f"shot {'written' if ok else 'FAILED'}: {args.shot}")
        print("ok")
        return 0

    signal.signal(signal.SIGTERM, lambda *_: app.quit())
    signal.signal(signal.SIGINT, lambda *_: app.quit())
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
