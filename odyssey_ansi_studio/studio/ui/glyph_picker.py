"""
`GlyphPicker` -- choose the current CP437 glyph and the document's font bank.

WHAT
    * a font-bank combo (the 16 swappable ROM banks) + a hint that the bank is
      a *document* property set on the hardware by DIP switches;
    * a 16x16 grid of the current bank's glyphs, rendered from the real ROM;
    * a search box: ``0x41`` / ``65`` / a name fragment ("heart", "block") /
      a literal character filters the grid;
    * a recent-glyphs strip.

    Picking a glyph emits `glyphChosen(code)`.  Changing the bank emits
    `bankChanged(index)` -- the owner writes it to `document.font_bank`; the
    grid re-renders but **no cell data changes** (bank is a pure render-time
    lookup).

WHY
    Cell glyph codes are bank-independent: switching banks must never rewrite
    the document, only how it is drawn.  Keeping the picker's grid a function
    of ``(bank, search)`` and emitting a plain int keeps that guarantee
    obvious.
"""

from PySide6.QtCore import QSize, Qt, Signal
from PySide6.QtGui import QIcon, QPixmap
from PySide6.QtWidgets import (
    QComboBox, QGridLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit,
    QScrollArea, QSizePolicy, QToolButton, QVBoxLayout, QWidget,
)

from studio.io.cp437 import CP437_TO_UNICODE, glyph_name
from studio.io.fontrom import BANKS, GLYPH_COUNT

_GLYPH_RGB = (210, 210, 210)
_RECENT_MAX = 14
#: quick-pick block glyphs: solid, dark/medium/light shade, and space (clear).
_QUICK_BLOCKS = [(0xDB, "█"), (0xB2, "▓"), (0xB1, "▒"), (0xB0, "░"), (0x20, "space")]


def _glyph_icon(bank, code, rgb=_GLYPH_RGB, px=22):
    img = bank.glyph_image(code, rgb)
    pm = QPixmap.fromImage(img).scaled(px, px, Qt.KeepAspectRatio,
                                       Qt.FastTransformation)
    return QIcon(pm)


def _match(code, query):
    """True if glyph `code` matches the search `query` (already lowercased)."""
    if not query:
        return True
    q = query.strip()
    try:
        return code == int(q, 0)
    except ValueError:
        pass
    if len(q) == 1 and CP437_TO_UNICODE[code] == q:
        return True
    return q in glyph_name(code).lower()


class GlyphPicker(QGroupBox):
    glyphChosen = Signal(int)
    bankChanged = Signal(int)

    def __init__(self, fontrom, parent=None):
        super().__init__("Glyph", parent)
        self._fontrom = fontrom
        self._bank_index = 0
        self._bank = None
        self._current = 0xDB
        self._ink_rgb = _GLYPH_RGB
        self._recent = []
        self._buttons = {}

        root = QVBoxLayout(self)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(4)

        row = QHBoxLayout()
        row.addWidget(QLabel("Bank"))
        self.combo = QComboBox()
        for spec in BANKS:
            self.combo.addItem(f"{spec['index']} — {spec['name']}")
        # Let the combo shrink with the dock instead of forcing a wide panel
        # (bank names are long); the popup still shows the full name.
        self.combo.setSizeAdjustPolicy(QComboBox.AdjustToMinimumContentsLengthWithIcon)
        self.combo.setMinimumContentsLength(6)
        self.combo.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Fixed)
        self.combo.currentIndexChanged.connect(self._on_combo)
        row.addWidget(self.combo, 1)
        root.addLayout(row)

        # ---- current-glyph indicator: the selected glyph, big, in the ink
        # color, framed; plus quick-pick block buttons.
        cur = QHBoxLayout()
        self._preview = QLabel()
        self._preview.setFixedSize(44, 44)
        self._preview.setAlignment(Qt.AlignCenter)
        self._preview.setFrameShape(QLabel.Box)
        self._preview.setLineWidth(2)
        cur.addWidget(self._preview)
        self._preview_lbl = QLabel("0xDB")
        self._preview_lbl.setWordWrap(True)
        self._preview_lbl.setMinimumWidth(1)
        cur.addWidget(self._preview_lbl, 1)
        for code, txt in _QUICK_BLOCKS:
            qb = QToolButton()
            qb.setText(txt)
            qb.setToolTip(f"0x{code:02X}  {glyph_name(code)}")
            qb.clicked.connect(lambda _c=False, cc=code: self.choose(cc))
            cur.addWidget(qb)
        root.addLayout(cur)

        self.hint = QLabel(
            "Bank is a document property (set by DIP switches on the machine). "
            "Switching re-renders every cell; it never changes cell data.")
        self.hint.setWordWrap(True)
        self.hint.setEnabled(False)
        root.addWidget(self.hint)

        self.search = QLineEdit()
        self.search.setPlaceholderText("search: 0x41 / 65 / heart / ░")
        self.search.setClearButtonEnabled(True)
        self.search.textChanged.connect(self._apply_filter)
        root.addWidget(self.search)

        # 16-wide glyph grid: compact cells so all 16 columns fit the (clamped)
        # dock width -- it scrolls vertically only, never sideways.
        self._grid_w = QWidget()
        self._grid = QGridLayout(self._grid_w)
        self._grid.setSpacing(1)
        self._grid.setContentsMargins(0, 0, 0, 0)
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        scroll.setWidget(self._grid_w)
        scroll.setMinimumHeight(200)
        root.addWidget(scroll, 1)

        self._now = QLabel("glyph 0xDB")
        self._now.setWordWrap(True)
        self._now.setMinimumWidth(1)
        root.addWidget(self._now)

        rc = QGroupBox("Recent")
        self._recent_row = QHBoxLayout(rc)
        self._recent_row.setContentsMargins(4, 2, 4, 2)
        self._recent_row.setSpacing(2)
        self._recent_row.addStretch(1)
        root.addWidget(rc)

        self.set_bank(0)

    # ------------------------------------------------------------- bank
    def bank_index(self):
        return self._bank_index

    def set_bank(self, index):
        """Load `index` and rebuild the grid.  Does not emit `bankChanged`."""
        index = int(index) & 0x0F
        self._bank_index = index
        try:
            self._bank = self._fontrom.load_bank(index)
        except FileNotFoundError:
            self._bank = self._fontrom.blank_bank()
        self.combo.blockSignals(True)
        self.combo.setCurrentIndex(index)
        self.combo.blockSignals(False)
        self._rebuild_grid()
        self._refresh_recent_strip()
        self._paint_now()

    def _on_combo(self, index):
        self.set_bank(index)
        self.bankChanged.emit(self._bank_index)

    # ------------------------------------------------------------- grid
    def _rebuild_grid(self):
        while self._grid.count():
            w = self._grid.takeAt(0).widget()
            if w is not None:
                w.deleteLater()
        self._buttons = {}
        for code in range(GLYPH_COUNT):
            b = QToolButton()
            b.setCheckable(True)
            b.setAutoRaise(True)
            b.setFixedSize(18, 18)
            b.setIconSize(QSize(16, 16))
            b.setIcon(_glyph_icon(self._bank, code, _GLYPH_RGB, 16))
            b.setToolTip(f"0x{code:02X} ({code})  {glyph_name(code)}")
            b.clicked.connect(lambda _c=False, cc=code: self.choose(cc))
            self._grid.addWidget(b, code // 16, code % 16)
            self._buttons[code] = b
        self._apply_filter(self.search.text())
        self._highlight()

    def _apply_filter(self, text):
        q = (text or "").lower()
        for code, b in self._buttons.items():
            b.setVisible(_match(code, q))

    # ------------------------------------------------------------- pick
    def current_glyph(self):
        return self._current

    def set_current_glyph(self, code):
        """External update: highlight, add to recent, do not emit."""
        self._current = int(code) & 0xFF
        self._push_recent(self._current)
        self._highlight()
        self._paint_now()

    def set_ink_rgb(self, rgb):
        """The current ink color changed -- repaint the indicator in it."""
        self._ink_rgb = tuple(int(v) for v in rgb)
        self._highlight()
        self._paint_now()
        self._refresh_recent_strip()

    def choose(self, code):
        self.set_current_glyph(code)
        self.glyphChosen.emit(self._current)

    def _css_rgb(self):
        r, g, b = self._ink_rgb
        return f"rgb({r},{g},{b})"

    def _highlight(self):
        border = f"QToolButton {{ border: 2px solid {self._css_rgb()}; }}"
        for code, b in self._buttons.items():
            b.blockSignals(True)
            sel = (code == self._current)
            b.setChecked(sel)
            b.setStyleSheet(border if sel else "")
            b.blockSignals(False)

    def _paint_now(self):
        name = glyph_name(self._current)
        self._now.setText(f"glyph 0x{self._current:02X}  {name}")
        self._preview_lbl.setText(f"0x{self._current:02X}  {name}")
        if self._bank is not None:
            img = self._bank.glyph_image(self._current, self._ink_rgb)
            pm = QPixmap.fromImage(img).scaled(40, 40, Qt.KeepAspectRatio,
                                               Qt.FastTransformation)
            self._preview.setPixmap(pm)
        self._preview.setStyleSheet(
            f"QLabel {{ border: 2px solid {self._css_rgb()}; background: #000; }}")

    # ------------------------------------------------------------- recent
    def _push_recent(self, code):
        if code in self._recent:
            self._recent.remove(code)
        self._recent.insert(0, code)
        del self._recent[_RECENT_MAX:]
        self._refresh_recent_strip()

    def _refresh_recent_strip(self):
        while self._recent_row.count():
            item = self._recent_row.takeAt(0)
            w = item.widget()
            if w is not None:
                w.deleteLater()
        for code in self._recent:
            b = QToolButton()
            b.setAutoRaise(True)
            b.setIcon(_glyph_icon(self._bank, code, self._ink_rgb, 18))
            b.setToolTip(f"0x{code:02X}  {glyph_name(code)}")
            b.clicked.connect(lambda _c=False, cc=code: self.choose(cc))
            self._recent_row.addWidget(b)
        self._recent_row.addStretch(1)
