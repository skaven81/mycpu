"""
`AttrField` -- the inline color control the Box / Text layer dialogs embed:
an ``0x``-prefixed value, a live swatch, and a "Pick..." button that opens the
shared modal color picker (`InkPickerDialog`, i.e. the very same `InkChooser`
the main window's Ink panel is built from, project palette included).

`InkDialog` is kept as an alias of `InkPickerDialog` for older call sites.
"""

from PySide6.QtCore import QSize, Signal
from PySide6.QtGui import QColor
from PySide6.QtWidgets import QDialog, QHBoxLayout, QLabel, QPushButton, QSpinBox, QWidget

from studio.model.palette import odyssey_to_rgb
from studio.ui.palette_panel import InkPickerDialog

# Back-compat alias: the standalone modal picker used to live here.
InkDialog = InkPickerDialog


def _qcolor(attr):
    r, g, b = odyssey_to_rgb(attr)
    return QColor(r, g, b)


class AttrField(QWidget):
    """An inline color value: `0x`-prefixed spin box + swatch + "Pick...".

    ``document`` (optional) is forwarded to the picker so it shows -- and can
    extend -- the same project palette as the main Ink panel.
    """

    changed = Signal(int)

    def __init__(self, value=0x0F, parent=None, *, document=None,
                 allow_blink=True, title="Pick a color"):
        super().__init__(parent)
        self._title = title
        self._document = document
        self._allow_blink = allow_blink        # accepted for call-site compat

        self.sp = QSpinBox()
        self.sp.setRange(0, 255)
        self.sp.setDisplayIntegerBase(16)
        self.sp.setPrefix("0x")
        self.sp.setValue(int(value) & 0xFF)
        self.sp.valueChanged.connect(self._on_spin)

        self.sw = QLabel()
        self.sw.setFixedSize(24, 20)
        self.sw.setAutoFillBackground(True)

        self.btn = QPushButton("Pick…")
        self.btn.clicked.connect(self._open_dialog)

        lay = QHBoxLayout(self)
        lay.setContentsMargins(0, 0, 0, 0)
        lay.setSpacing(4)
        lay.addWidget(self.sp)
        lay.addWidget(self.sw)
        lay.addWidget(self.btn)
        lay.addStretch(1)
        self._paint_swatch()

    def set_document(self, document):
        self._document = document

    def _paint_swatch(self):
        pal = self.sw.palette()
        pal.setColor(self.sw.backgroundRole(), _qcolor(self.sp.value()))
        self.sw.setPalette(pal)

    def _on_spin(self, _v):
        self._paint_swatch()
        self.changed.emit(self.value())

    def _open_dialog(self):
        got = InkPickerDialog.get_attr(self, self.sp.value(), title=self._title,
                                       document=self._document)
        if got is not None:
            self.sp.setValue(got)

    def value(self) -> int:
        return self.sp.value() & 0xFF

    def setValue(self, v):
        self.sp.setValue(int(v) & 0xFF)

    def sizeHint(self):
        return QSize(220, 24)
