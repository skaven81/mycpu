"""ConsoleView -- a read-only, char-at-a-time serial terminal widget.

Deliberately not a full ANSI terminal emulator: it implements exactly the
two control characters that matter for readable serial output (LF, CR)
plus backspace, and renders everything else as a dimmed hex escape. That
covers what the Odyssey's BIOS and utilities actually emit.
"""

from PySide6.QtCore import Qt, QTimer, Signal
from PySide6.QtGui import QColor, QFont, QFontDatabase, QGuiApplication, QTextCursor
from PySide6.QtWidgets import QPlainTextEdit

FLUSH_INTERVAL_MS = 30  # coalesces incoming chunks; per-byte repaints would thrash at 115200
MAX_SCROLLBACK_BLOCKS = 5000
ENTER_BYTE = b"\r"  # module constant -- one line to change if the Odyssey ever wants LF

BG = "#000000"
FG_DEVICE = "#dddddd"
FG_AGENT = "#5599dd"
FG_PROTOCOL = "#777777"
FG_CONTROL = "#666666"

_STYLE_COLOR = {"device": FG_DEVICE, "agent": FG_AGENT, "protocol": FG_PROTOCOL}


class ConsoleView(QPlainTextEdit):
    """Renders true terminal CR/LF semantics rather than normalizing them:
    LF starts a new line; CR alone returns to column 0 and enters
    overwrite mode so following printable bytes *replace* what's there --
    this is what makes in-place progress output from the Odyssey render
    correctly instead of smearing down the log. \\r\\n therefore needs no
    special case at all: CR parks at column 0 having overwritten nothing,
    then LF breaks the line, which is exactly one clean new line.
    """

    byte_typed = Signal(bytes)  # a key the user pressed, ready to send

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setReadOnly(True)
        self.setUndoRedoEnabled(False)
        self.setMaximumBlockCount(MAX_SCROLLBACK_BLOCKS)
        self._apply_style()
        self.echo_enabled = False
        self._overwrite = False
        self._pending = []
        # A detached cursor, deliberately never synced to self.textCursor():
        # the visible/selection cursor belongs to the user (e.g. mid-copy),
        # while this one tracks where the next incoming byte gets written.
        # Editing the document through it doesn't disturb a user selection.
        self._write_cursor = QTextCursor(self.document())
        self._write_cursor.movePosition(QTextCursor.MoveOperation.End)
        self._flush_timer = QTimer(self)
        self._flush_timer.setInterval(FLUSH_INTERVAL_MS)
        self._flush_timer.timeout.connect(self._flush_pending)
        self._flush_timer.start()

    def _apply_style(self):
        font = QFontDatabase.systemFont(QFontDatabase.SystemFont.FixedFont)
        for family in ("DejaVu Sans Mono", "Monospace"):
            if family in QFontDatabase.families():
                font = QFont(family)
                break
        font.setStyleHint(QFont.StyleHint.Monospace)
        self.setFont(font)
        self.setStyleSheet(f"QPlainTextEdit {{ background-color: {BG}; color: {FG_DEVICE}; "
                            f"border: none; }}")

    # ---- incoming data (called from the GUI thread only -- the core's
    # background-thread listener must marshal through a Qt signal first) ----

    def feed_device(self, data, is_protocol=False):
        self._pending.append((data, "protocol" if is_protocol else "device"))

    def feed_agent(self, data):
        self._pending.append((data, "agent"))

    def clear_console(self):
        self.clear()
        self._overwrite = False
        self._write_cursor = QTextCursor(self.document())

    def _flush_pending(self):
        if not self._pending:
            return
        pending, self._pending = self._pending, []
        at_bottom = self._is_at_bottom()
        for data, kind in pending:
            self._render(self._write_cursor, data, kind)
        if at_bottom:
            self._scroll_to_bottom()

    def _is_at_bottom(self):
        sb = self.verticalScrollBar()
        return sb.value() >= sb.maximum() - 2

    def _scroll_to_bottom(self):
        sb = self.verticalScrollBar()
        sb.setValue(sb.maximum())

    def _render(self, cursor, data, kind):
        fmt = cursor.charFormat()
        fmt.setForeground(QColor(_STYLE_COLOR[kind]))
        cursor.setCharFormat(fmt)
        for b in data:
            if b == 0x0A:  # LF -- new line
                cursor.movePosition(QTextCursor.MoveOperation.EndOfBlock)
                cursor.insertBlock()
                self._overwrite = False
            elif b == 0x0D:  # CR -- column 0, enter overwrite mode
                cursor.movePosition(QTextCursor.MoveOperation.StartOfBlock)
                self._overwrite = True
            elif b == 0x08:  # backspace
                if cursor.positionInBlock() > 0:
                    cursor.movePosition(QTextCursor.MoveOperation.PreviousCharacter,
                                         QTextCursor.MoveMode.KeepAnchor)
                    cursor.removeSelectedText()
            elif 0x20 <= b <= 0x7E:
                self._put_char(cursor, chr(b))
                cursor.setCharFormat(fmt)  # selection-replace above can pick up a stale format
            else:
                dim = cursor.charFormat()
                dim.setForeground(QColor(FG_CONTROL))
                cursor.setCharFormat(dim)
                cursor.insertText(f"⟨{b:02X}⟩")
                cursor.setCharFormat(fmt)

    def _put_char(self, cursor, ch):
        if self._overwrite:
            block = cursor.block()
            if cursor.positionInBlock() < block.length() - 1:
                cursor.movePosition(QTextCursor.MoveOperation.NextCharacter,
                                     QTextCursor.MoveMode.KeepAnchor)
                cursor.insertText(ch)
                return
        cursor.insertText(ch)

    # ---- outgoing keystrokes ----

    def keyPressEvent(self, event):
        data = self._encode_key_event(event)
        if data is None:
            return
        self.byte_typed.emit(data)
        if self.echo_enabled:
            self.feed_device(data)
        event.accept()

    def _encode_key_event(self, event):
        key = event.key()
        mods = event.modifiers()

        # Ctrl+Shift+C copies and Ctrl+Shift+V pastes-and-sends, leaving
        # plain Ctrl+C/Ctrl+V free to send 0x03/0x16 like a real terminal.
        if (mods & Qt.KeyboardModifier.ControlModifier) and (mods & Qt.KeyboardModifier.ShiftModifier):
            if key == Qt.Key.Key_C:
                self.copy()
                return None
            if key == Qt.Key.Key_V:
                text = QGuiApplication.clipboard().text()
                return text.encode("utf-8", "ignore") if text else None

        if key in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            return ENTER_BYTE
        if key == Qt.Key.Key_Backspace:
            return b"\x08"
        if key == Qt.Key.Key_Tab:
            return b"\x09"
        if key == Qt.Key.Key_Escape:
            return b"\x1b"

        if (mods & Qt.KeyboardModifier.ControlModifier) and Qt.Key.Key_A <= key <= Qt.Key.Key_Z:
            return bytes([key - Qt.Key.Key_A + 1])

        text = event.text()
        if text and 0x20 <= ord(text[0]) <= 0x7E:
            return text.encode("ascii", "ignore")
        return None
