"""
`CellInspector` -- the right-dock panel that reads and edits one cell.

Two modes on the same widget:

  * **hover** -- `show_hover()` fills the read-only labels from whatever cell is
    under the pointer; the edit row stays disabled.
  * **selected** -- the Cell-Edit / Select tool calls `select()` with a
    (col, row) on the active layer.  The edit row lights up; `Apply` emits
    `applied(glyph, attr)` and `Set NULL` emits `cleared()`.  The main window
    turns those into a `CellEditCommand` on the active layer so the edit is
    undoable like any brush stroke.

Glyph field accepts ``0x41`` / ``65`` / a single character (mapped through
CP437).  Attr field accepts ``0x1F`` / ``31``; the Blink and Cursor checkboxes
own bits 0x80 / 0x40 and are OR-ed in on Apply.
"""

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QColor, QPixmap
from PySide6.QtWidgets import (
    QCheckBox, QGridLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit,
    QPushButton, QVBoxLayout, QWidget,
)

from studio.io.cp437 import UNICODE_TO_CP437, glyph_name
from studio.model.palette import attr_blink, attr_cursor, attr_to_rgb


def parse_glyph(text):
    """``0x41`` / ``65`` / ``A`` -> int 0..255, or None if unparseable."""
    s = text.strip()
    if not s:
        return None
    if len(s) == 1 and not s.isdigit():
        if s in UNICODE_TO_CP437:
            return UNICODE_TO_CP437[s]
        return ord(s) & 0xFF
    try:
        return int(s, 0) & 0xFF
    except ValueError:
        return None


def parse_attr(text):
    """``0x1F`` / ``31`` -> int 0..255 (bits 6/7 ignored here), or None."""
    s = text.strip()
    if not s:
        return None
    try:
        return int(s, 0) & 0xFF
    except ValueError:
        return None


class CellInspector(QGroupBox):
    applied = Signal(int, int)     # glyph, attr  (write to active layer @ selection)
    cleared = Signal()            # set the selected cell to NULL

    def __init__(self, parent=None):
        super().__init__("Cell Inspector", parent)
        self._sel = None          # (col, row) or None

        root = QVBoxLayout(self)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(6)

        # ---- read-only facts
        facts = QGridLayout()
        facts.setHorizontalSpacing(6)
        facts.setVerticalSpacing(2)
        self.l_pos = QLabel("—")
        self.l_char = QLabel("—")
        self.l_attr = QLabel("—")
        self.l_flags = QLabel("—")
        self.l_layer = QLabel("—")
        self.sw = QLabel()
        self.sw.setFixedSize(24, 14)
        self._set_swatch(None)
        for i, (name, w) in enumerate([
            ("cell", self.l_pos), ("char", self.l_char), ("attr", self.l_attr),
            ("flags", self.l_flags), ("layer", self.l_layer),
        ]):
            facts.addWidget(QLabel(name), i, 0)
            facts.addWidget(w, i, 1)
        facts.addWidget(self.sw, 2, 2)
        root.addLayout(facts)

        # ---- edit row
        self.edit_box = QWidget()
        eb = QGridLayout(self.edit_box)
        eb.setContentsMargins(0, 0, 0, 0)
        eb.setHorizontalSpacing(6)
        eb.setVerticalSpacing(3)

        self.ed_glyph = QLineEdit()
        self.ed_glyph.setPlaceholderText("0x41 / 65 / A")
        self.ed_attr = QLineEdit()
        self.ed_attr.setPlaceholderText("0x0F / 15")
        self.cb_blink = QCheckBox("Blink")
        self.cb_cursor = QCheckBox("Cursor")
        eb.addWidget(QLabel("glyph"), 0, 0)
        eb.addWidget(self.ed_glyph, 0, 1, 1, 2)
        eb.addWidget(QLabel("attr"), 1, 0)
        eb.addWidget(self.ed_attr, 1, 1, 1, 2)
        flags_row = QHBoxLayout()
        flags_row.addWidget(self.cb_blink)
        flags_row.addWidget(self.cb_cursor)
        flags_row.addStretch(1)
        eb.addLayout(flags_row, 2, 0, 1, 3)

        btns = QHBoxLayout()
        self.btn_apply = QPushButton("Apply")
        self.btn_null = QPushButton("Set NULL")
        self.btn_apply.clicked.connect(self._emit_apply)
        self.btn_null.clicked.connect(self._emit_clear)
        self.ed_glyph.returnPressed.connect(self._emit_apply)
        self.ed_attr.returnPressed.connect(self._emit_apply)
        btns.addWidget(self.btn_apply)
        btns.addWidget(self.btn_null)
        btns.addStretch(1)
        eb.addLayout(btns, 3, 0, 1, 3)

        root.addWidget(self.edit_box)
        self.hint = QLabel("Pick the Cell Edit tool and click a cell to edit it.")
        self.hint.setWordWrap(True)
        self.hint.setEnabled(False)
        root.addWidget(self.hint)

        self._set_editable(False)

    # ------------------------------------------------------------------ state
    def selection(self):
        return self._sel

    def _set_swatch(self, attr):
        pm = QPixmap(24, 14)
        if attr is None:
            pm.fill(QColor(0, 0, 0, 0))
        else:
            pm.fill(QColor(*attr_to_rgb(attr)))
        self.sw.setPixmap(pm)

    def _set_editable(self, on):
        self.edit_box.setVisible(on)
        self.hint.setVisible(not on)

    @staticmethod
    def _flags_text(attr):
        if attr is None:
            return "—"
        parts = []
        if attr_blink(attr):
            parts.append("blink")
        if attr_cursor(attr):
            parts.append("cursor")
        return "+".join(parts) if parts else "none"

    def _fill_facts(self, col, row, cell, layer_name):
        self.l_pos.setText(f"{col},{row}" if col is not None else "—")
        if cell is None:
            self.l_char.setText("—")
            self.l_attr.setText("—")
            self.l_flags.setText("—")
            self._set_swatch(None)
        else:
            self.l_char.setText(f"0x{cell.glyph:02X}  {glyph_name(cell.glyph)}")
            self.l_attr.setText(f"0x{cell.attr:02X}")
            self.l_flags.setText(self._flags_text(cell.attr))
            self._set_swatch(cell.attr)
        self.l_layer.setText(layer_name or "—")

    # ---------------------------------------------------------------- hover
    def show_hover(self, col, row, cell, layer_name):
        """Read-only update from the pointer.  Ignored while a cell is selected
        so the user's in-progress edit values are not clobbered."""
        if self._sel is not None:
            return
        self._fill_facts(col, row, cell, layer_name)

    # --------------------------------------------------------------- select
    def select(self, col, row, cell, layer_name):
        self._sel = (col, row)
        self._fill_facts(col, row, cell, layer_name)
        if cell is None:
            self.ed_glyph.setText("")
            self.ed_attr.setText("0x0F")
            self.cb_blink.setChecked(False)
            self.cb_cursor.setChecked(False)
        else:
            self.ed_glyph.setText(f"0x{cell.glyph:02X}")
            self.ed_attr.setText(f"0x{cell.attr & 0x3F:02X}")
            self.cb_blink.setChecked(attr_blink(cell.attr))
            self.cb_cursor.setChecked(attr_cursor(cell.attr))
        self._set_editable(True)
        self.ed_glyph.setFocus()
        self.ed_glyph.selectAll()

    def clear_selection(self):
        self._sel = None
        self._set_editable(False)

    # ----------------------------------------------------------------- emit
    def _compose_attr(self):
        base = parse_attr(self.ed_attr.text())
        if base is None:
            return None
        base &= 0x3F
        if self.cb_blink.isChecked():
            base |= 0x80
        if self.cb_cursor.isChecked():
            base |= 0x40
        return base

    def _emit_apply(self):
        if self._sel is None:
            return
        glyph = parse_glyph(self.ed_glyph.text())
        attr = self._compose_attr()
        if glyph is None or attr is None:
            self.l_flags.setText("bad glyph/attr")
            return
        self.applied.emit(glyph, attr)

    def _emit_clear(self):
        if self._sel is None:
            return
        self.cleared.emit()

    def set_glyph_preview(self, code):
        """Called when the current ink glyph changes -- offer it as a default."""
        if self._sel is not None and not self.ed_glyph.text().strip():
            self.ed_glyph.setText(f"0x{code:02X}")
