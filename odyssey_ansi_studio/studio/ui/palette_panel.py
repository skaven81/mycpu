"""
`InkChooser` -- the one widget the whole app uses to choose a color byte, plus
`InkPickerDialog`, the modal wrapper around it.

WHAT
    `InkChooser` is:
    * a 64-button grid of every Odyssey color;
    * a 16-button ANSI quick strip (the exact SGR 30-37 / 90-97 bytes);
    * R / G / B 0..3 sliders + Blink / Cursor toggles that compose the byte;
    * a current-ink readout (swatch + ``attr 0xNN  #RRGGBB``) with a
      "Pick..." screen-eyedropper button;
    * the **project palette**: named colors stored on the `Document`
      (`doc.project_palette`, a list of ``{"name", "attr"}``), add / remove /
      rename, click a row to load it as the ink.

    Picking anywhere emits `inkChosen(attr)`.  Editing the project palette
    mutates `doc.project_palette` in place and emits `projectPaletteChanged`.

    `PalettePanel` is a thin alias kept for the main-window right dock.
    `InkPickerDialog` embeds an `InkChooser` in an OK / Cancel modal for the
    layer dialogs -- same widget, same project palette, but its picks stay
    local (they never touch the main window's ink).

WHY
    The color byte, an (R,G,B) triple, three sliders and an SGR code are four
    views of one value; keeping the conversions here (via
    `studio.model.palette`) means no call site re-derives the bit layout.  The
    project palette lives on the document so it round-trips through `.oas`
    untouched.  One implementation, used both in the dock and every modal, so
    the two can never drift apart.
"""

from PySide6.QtCore import QSize, Qt, Signal
from PySide6.QtGui import QColor, QIcon, QPixmap
from PySide6.QtWidgets import (
    QAbstractItemView, QCheckBox, QDialog, QDialogButtonBox, QGridLayout,
    QGroupBox, QHBoxLayout, QLabel, QLayout, QListWidget, QListWidgetItem,
    QPushButton, QSlider, QToolButton, QVBoxLayout, QWidget,
)

from studio.model.palette import (
    ANSI16, PALETTE, attr_rgb_idx, attr_to_rgb, make_attr,
)
from studio.ui.toolicons import tool_icon

_ANSI_ORDER = [0x00, 0x20, 0x08, 0x24, 0x02, 0x22, 0x0A, 0x2A,
               0x15, 0x35, 0x1D, 0x3D, 0x17, 0x37, 0x1F, 0x3F]


def _swatch_icon(rgb, size=16):
    pm = QPixmap(size, size)
    pm.fill(QColor(*rgb))
    return QIcon(pm)


class InkChooser(QGroupBox):
    inkChosen = Signal(int)              # composed attr byte 0..255
    projectPaletteChanged = Signal()
    screenColorRequested = Signal()      # user clicked "Pick from screen…"

    def __init__(self, parent=None, *, title="Ink"):
        super().__init__(title, parent)
        self._doc = None
        self._attr = 0x0F
        self._loading = False

        root = QVBoxLayout(self)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(6)

        _SW = 24        # swatch edge, px

        # ---- 64 colors.  Fixed-size grid so widening the dock never spreads
        # the swatches out.
        grid_w = QWidget()
        grid = QGridLayout(grid_w)
        grid.setSpacing(1)
        grid.setContentsMargins(0, 0, 0, 0)
        grid.setSizeConstraint(QLayout.SetFixedSize)
        for idx, rgb in enumerate(PALETTE):
            b = QToolButton()
            b.setFixedSize(_SW, _SW)
            b.setAutoRaise(True)
            b.setIcon(_swatch_icon(rgb, _SW - 2))
            b.setIconSize(QSize(_SW - 2, _SW - 2))
            b.setToolTip(f"{idx:02d}  #{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}  "
                         f"attr 0x{idx:02X}")
            b.clicked.connect(lambda _c=False, i=idx: self._pick_rgb(i))
            grid.addWidget(b, idx // 8, idx % 8)
        root.addWidget(grid_w, 0, Qt.AlignLeft)

        # ---- ANSI-16 quick picks -- two rows of eight
        strip_w = QWidget()
        strip = QGridLayout(strip_w)
        strip.setSpacing(1)
        strip.setContentsMargins(0, 2, 0, 0)
        strip.setSizeConstraint(QLayout.SetFixedSize)
        for i, code in enumerate(_ANSI_ORDER):
            sgr, name = ANSI16[code]
            b = QToolButton()
            b.setFixedSize(_SW, _SW)
            b.setAutoRaise(True)
            b.setIcon(_swatch_icon(attr_to_rgb(code), _SW - 2))
            b.setIconSize(QSize(_SW - 2, _SW - 2))
            b.setToolTip(f"SGR {sgr} — {name}  (attr 0x{code:02X})")
            b.clicked.connect(lambda _c=False, cc=code: self._pick_exact(cc))
            strip.addWidget(b, i // 8, i % 8)
        root.addWidget(strip_w, 0, Qt.AlignLeft)

        # ---- R/G/B sliders (0..3) -- drag to change the color; a value label
        # on the right shows the current channel level.
        self._sliders = {}
        self._slider_vals = {}
        for name in ("R", "G", "B"):
            row = QHBoxLayout()
            lab = QLabel(name)
            lab.setFixedWidth(14)
            row.addWidget(lab)
            s = QSlider(Qt.Horizontal)
            s.setRange(0, 3)
            s.setPageStep(1)
            s.setSingleStep(1)
            s.setTickPosition(QSlider.TicksBelow)
            s.setTickInterval(1)
            s.setMinimumHeight(22)
            s.valueChanged.connect(self._compose_from_controls)
            row.addWidget(s, 1)
            vlab = QLabel("0")
            vlab.setFixedWidth(12)
            row.addWidget(vlab)
            root.addLayout(row)
            self._sliders[name] = s
            self._slider_vals[name] = vlab

        flags = QHBoxLayout()
        self.cb_blink = QCheckBox("Blink")
        self.cb_cursor = QCheckBox("Cursor")
        self.cb_blink.toggled.connect(self._compose_from_controls)
        self.cb_cursor.toggled.connect(self._compose_from_controls)
        flags.addWidget(self.cb_blink)
        flags.addWidget(self.cb_cursor)
        flags.addStretch(1)
        root.addLayout(flags)

        readout = QHBoxLayout()
        self._swatch = QLabel()
        self._swatch.setFixedSize(40, 20)
        self._hex = QLabel("attr 0x0F  #000000")
        self.btn_eyedrop = QToolButton()
        self.btn_eyedrop.setIcon(tool_icon("eyedropper"))
        self.btn_eyedrop.setText("Pick…")
        self.btn_eyedrop.setToolButtonStyle(Qt.ToolButtonTextBesideIcon)
        self.btn_eyedrop.setToolTip(
            "Pick from screen — sample a color anywhere on screen (any app) and "
            "match it to an Odyssey color")
        self.btn_eyedrop.clicked.connect(self.screenColorRequested)
        readout.addWidget(self._swatch)
        readout.addWidget(self._hex, 1)
        readout.addWidget(self.btn_eyedrop)
        root.addLayout(readout)

        # ---- project palette
        pp = QGroupBox("Project palette")
        pl = QVBoxLayout(pp)
        pl.setContentsMargins(6, 4, 6, 6)
        self.pp_list = QListWidget()
        self.pp_list.setEditTriggers(QAbstractItemView.DoubleClicked
                                     | QAbstractItemView.EditKeyPressed)
        self.pp_list.setMaximumHeight(120)
        self.pp_list.itemClicked.connect(self._pp_row_clicked)
        self.pp_list.itemChanged.connect(self._pp_row_renamed)
        pl.addWidget(self.pp_list)

        btns = QHBoxLayout()
        self.btn_add = QPushButton("Add")
        self.btn_del = QPushButton("Remove")
        self.btn_add.setToolTip("Add the current ink as a named color")
        self.btn_add.clicked.connect(self._pp_add)
        self.btn_del.clicked.connect(self._pp_remove)
        btns.addWidget(self.btn_add)
        btns.addWidget(self.btn_del)
        btns.addStretch(1)
        pl.addLayout(btns)
        root.addWidget(pp)

        self._sync_controls()

    # ------------------------------------------------------------- document
    def set_document(self, doc):
        self._doc = doc
        self._rebuild_pp_list()

    # ------------------------------------------------------------- ink API
    def current_ink(self) -> int:
        return self._attr

    def set_ink(self, attr):
        """External update (eyedropper / inspector): sync, do not re-emit."""
        self._attr = int(attr) & 0xFF
        self._sync_controls()

    def hide_screen_pick(self):
        """Drop the "Pick..." screen-eyedropper button (used when the chooser is
        embedded somewhere a screen sample makes no sense)."""
        self.btn_eyedrop.hide()

    # ------------------------------------------------------------- picking
    def _pick_rgb(self, idx):
        # keep the current blink/cursor bits, swap the 6-bit color
        self._attr = (self._attr & 0xC0) | (idx & 0x3F)
        self._sync_controls()
        self.inkChosen.emit(self._attr)

    def _pick_exact(self, code):
        self._attr = (self._attr & 0xC0) | (code & 0x3F)
        self._sync_controls()
        self.inkChosen.emit(self._attr)

    def _compose_from_controls(self, *_):
        if self._loading:
            return
        self._attr = make_attr(
            self._sliders["R"].value(),
            self._sliders["G"].value(),
            self._sliders["B"].value(),
            blink=self.cb_blink.isChecked(),
            cursor=self.cb_cursor.isChecked(),
        )
        self._paint_readout()
        self.inkChosen.emit(self._attr)

    def _sync_controls(self):
        self._loading = True
        r, g, b = attr_rgb_idx(self._attr)
        for name, val in (("R", r), ("G", g), ("B", b)):
            self._sliders[name].setValue(val)
            self._slider_vals[name].setText(str(val))
        self.cb_blink.setChecked(bool(self._attr & 0x80))
        self.cb_cursor.setChecked(bool(self._attr & 0x40))
        self._loading = False
        self._paint_readout()

    def _paint_readout(self):
        rgb = attr_to_rgb(self._attr)
        for name, val in zip(("R", "G", "B"), attr_rgb_idx(self._attr)):
            self._slider_vals[name].setText(str(val))
        pm = QPixmap(40, 20)
        pm.fill(QColor(*rgb))
        self._swatch.setPixmap(pm)
        tags = []
        if self._attr & 0x80:
            tags.append("blink")
        if self._attr & 0x40:
            tags.append("cursor")
        suffix = ("  " + "+".join(tags)) if tags else ""
        self._hex.setText(
            f"attr 0x{self._attr:02X}  #{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}{suffix}")

    # ---------------------------------------------------- project palette
    def _palette(self):
        return self._doc.project_palette if self._doc is not None else None

    def _rebuild_pp_list(self):
        self._loading = True
        self.pp_list.clear()
        for entry in (self._palette() or []):
            self._append_pp_item(entry.get("name", "color"),
                                 int(entry.get("attr", 0)) & 0xFF)
        self._loading = False

    def _append_pp_item(self, name, attr):
        it = QListWidgetItem(name)
        it.setIcon(_swatch_icon(attr_to_rgb(attr), 12))
        it.setData(Qt.UserRole, attr)
        it.setToolTip(f"attr 0x{attr:02X}")
        it.setFlags(it.flags() | Qt.ItemIsEditable)
        self.pp_list.addItem(it)

    def _pp_add(self):
        pal = self._palette()
        if pal is None:
            return
        name = f"color {len(pal) + 1}"
        pal.append({"name": name, "attr": self._attr})
        self._loading = True
        self._append_pp_item(name, self._attr)
        self._loading = False
        self.pp_list.setCurrentRow(self.pp_list.count() - 1)
        self.projectPaletteChanged.emit()

    def _pp_remove(self):
        pal = self._palette()
        row = self.pp_list.currentRow()
        if pal is None or not (0 <= row < len(pal)):
            return
        del pal[row]
        self._loading = True
        self.pp_list.takeItem(row)
        self._loading = False
        self.projectPaletteChanged.emit()

    def _pp_row_clicked(self, item):
        attr = item.data(Qt.UserRole)
        if attr is None:
            return
        self._attr = int(attr) & 0xFF
        self._sync_controls()
        self.inkChosen.emit(self._attr)

    def _pp_row_renamed(self, item):
        if self._loading:
            return
        pal = self._palette()
        row = self.pp_list.row(item)
        if pal is None or not (0 <= row < len(pal)):
            return
        pal[row]["name"] = item.text()
        self.projectPaletteChanged.emit()


class PalettePanel(InkChooser):
    """The `InkChooser` as the main window's right-dock "Ink" panel.

    A named subclass so existing imports / isinstance checks keep working; all
    behavior lives in `InkChooser`.
    """


class InkPickerDialog(QDialog):
    """Modal color picker: an `InkChooser` + OK / Cancel.

    Shares the document's project palette (pass `document=`) but its picks are
    self-contained -- nothing here emits into the main window's ink.  Use
    `InkPickerDialog.get_attr(...)` for the one-call form.
    """

    projectPaletteChanged = Signal()

    def __init__(self, initial=0x0F, parent=None, *, title="Pick a color",
                 document=None, allow_screen_pick=True):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.setModal(True)

        self.chooser = InkChooser(title="")
        if document is not None:
            self.chooser.set_document(document)
        self.chooser.set_ink(int(initial) & 0xFF)
        self.chooser.projectPaletteChanged.connect(self.projectPaletteChanged)
        if allow_screen_pick:
            self.chooser.screenColorRequested.connect(self._pick_screen)
        else:
            self.chooser.hide_screen_pick()

        box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        box.accepted.connect(self.accept)
        box.rejected.connect(self.reject)

        root = QVBoxLayout(self)
        root.setContentsMargins(8, 8, 8, 8)
        root.addWidget(self.chooser)
        root.addWidget(box)

    def selected_attr(self) -> int:
        return self.chooser.current_ink() & 0xFF

    def _pick_screen(self):
        from studio.ui.screen_pick import pick_screen_color
        pick_screen_color(self, self._screen_sampled)

    def _screen_sampled(self, qcolor):
        from studio.ui.color_match_dialog import OdysseyColorDialog
        dlg = OdysseyColorDialog(qcolor, parent=self)
        if dlg.exec():
            cur = self.chooser.current_ink()
            self.chooser.set_ink((cur & 0xC0) | dlg.chosen_attr())

    @staticmethod
    def get_attr(parent, initial, *, title="Pick a color", document=None):
        """Run the dialog modally.  Returns the chosen attr byte, or None if
        the user cancelled."""
        dlg = InkPickerDialog(initial, parent, title=title, document=document)
        if dlg.exec() != QDialog.Accepted:
            return None
        return dlg.selected_attr()
