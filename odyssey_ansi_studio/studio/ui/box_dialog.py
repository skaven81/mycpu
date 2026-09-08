"""
`BoxDialog` -- create or re-edit a Box layer's parameters.

Modal.  `result_params()` returns a full parameter dict (merged over
`rasterize.BOX_DEFAULTS`) ready for `BoxLayer(params=...)` /
`BoxLayer.set_params(**...)` + `regenerate()`.  Re-opening it on an existing
layer pre-fills every field -- layers stay editable for the life of the
document.

The border, title and footer each get their own `AttrField` (the shared modal
color picker); the title and footer can also carry BBS-style "flair"
(``--| TITLE |--`` and friends -- see `rasterize.LABEL_FLAIRS`).
"""

from PySide6.QtWidgets import (
    QCheckBox, QComboBox, QDialog, QDialogButtonBox, QFormLayout, QLineEdit,
    QSpinBox, QVBoxLayout,
)

from studio.io.cp437 import BOX_STYLES
from studio.model.rasterize import BOX_DEFAULTS, LABEL_FLAIRS
from studio.ui.ink_dialog import AttrField

_ALIGN = ["left", "center", "right"]
_INTERIOR = ["none", "space", "fill"]
_FLAIRS = list(LABEL_FLAIRS)


def _hex_spin(value, lo=0, hi=255):
    s = QSpinBox()
    s.setRange(lo, hi)
    s.setDisplayIntegerBase(16)
    s.setPrefix("0x")
    s.setValue(int(value))
    return s


class BoxDialog(QDialog):
    def __init__(self, params=None, parent=None, *, window_title="Box layer",
                 ink=None, document=None):
        super().__init__(parent)
        self.setWindowTitle(window_title)
        self.setModal(True)
        p = {**BOX_DEFAULTS, **(dict(params) if params else {})}
        if params is None and ink is not None:
            ink = int(ink) & 0xFF               # new layer inherits the current ink
            p["box_attr"] = ink
            p["fill_attr"] = ink

        box_attr = int(p["box_attr"]) & 0xFF
        title_attr = int(p["title_attr"] if p["title_attr"] is not None
                         else box_attr) & 0xFF
        footer_attr = int(p["footer_attr"] if p["footer_attr"] is not None
                          else box_attr) & 0xFF
        fill_attr = int(p["fill_attr"] if p["fill_attr"] is not None
                        else box_attr) & 0xFF

        form = QFormLayout()

        self.cb_style = QComboBox()
        self.cb_style.addItems(list(BOX_STYLES))
        self.cb_style.setCurrentText(p["style"] if p["style"] in BOX_STYLES
                                     else "single")
        form.addRow("Line style", self.cb_style)

        self.sp_w = QSpinBox(); self.sp_w.setRange(1, 64); self.sp_w.setValue(int(p["w"]))
        self.sp_h = QSpinBox(); self.sp_h.setRange(1, 60); self.sp_h.setValue(int(p["h"]))
        form.addRow("Width", self.sp_w)
        form.addRow("Height", self.sp_h)

        self.sp_box_attr = AttrField(box_attr, title="Border color",
                                     document=document)
        form.addRow("Border color", self.sp_box_attr)

        self.ed_title = QLineEdit(p["title"])
        self.cb_title_align = QComboBox(); self.cb_title_align.addItems(_ALIGN)
        self.cb_title_align.setCurrentText(p["title_align"])
        self.cb_title_flair = QComboBox(); self.cb_title_flair.addItems(_FLAIRS)
        self.cb_title_flair.setCurrentText(p.get("title_flair", "none"))
        self.title_attr = AttrField(title_attr, title="Title color",
                                    document=document)
        form.addRow("Title", self.ed_title)
        form.addRow("Title align", self.cb_title_align)
        form.addRow("Title flair", self.cb_title_flair)
        form.addRow("Title color", self.title_attr)

        self.ed_footer = QLineEdit(p["footer"])
        self.cb_footer_align = QComboBox(); self.cb_footer_align.addItems(_ALIGN)
        self.cb_footer_align.setCurrentText(p["footer_align"])
        self.cb_footer_flair = QComboBox(); self.cb_footer_flair.addItems(_FLAIRS)
        self.cb_footer_flair.setCurrentText(p.get("footer_flair", "none"))
        self.footer_attr = AttrField(footer_attr, title="Footer color",
                                     document=document)
        form.addRow("Footer", self.ed_footer)
        form.addRow("Footer align", self.cb_footer_align)
        form.addRow("Footer flair", self.cb_footer_flair)
        form.addRow("Footer color", self.footer_attr)

        self.cb_interior = QComboBox(); self.cb_interior.addItems(_INTERIOR)
        self.cb_interior.setCurrentText(p["interior"])
        form.addRow("Interior", self.cb_interior)

        self.sp_fill_glyph = _hex_spin(p["fill_glyph"])
        form.addRow("Fill glyph", self.sp_fill_glyph)
        self.sp_fill_attr = AttrField(fill_attr, title="Fill color",
                                      document=document)
        form.addRow("Fill color", self.sp_fill_attr)

        self.chk_shadow = QCheckBox("Drop shadow")
        self.chk_shadow.setChecked(bool(p["shadow"]))
        form.addRow("", self.chk_shadow)

        box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        box.accepted.connect(self.accept)
        box.rejected.connect(self.reject)

        root = QVBoxLayout(self)
        root.addLayout(form)
        root.addWidget(box)

    def result_params(self) -> dict:
        return {
            "style": self.cb_style.currentText(),
            "w": self.sp_w.value(),
            "h": self.sp_h.value(),
            "box_attr": self.sp_box_attr.value(),
            "title": self.ed_title.text(),
            "title_align": self.cb_title_align.currentText(),
            "title_flair": self.cb_title_flair.currentText(),
            "title_attr": self.title_attr.value(),
            "footer": self.ed_footer.text(),
            "footer_align": self.cb_footer_align.currentText(),
            "footer_flair": self.cb_footer_flair.currentText(),
            "footer_attr": self.footer_attr.value(),
            "interior": self.cb_interior.currentText(),
            "fill_glyph": self.sp_fill_glyph.value(),
            "fill_attr": self.sp_fill_attr.value(),
            "shadow": self.chk_shadow.isChecked(),
            "shadow_attr": BOX_DEFAULTS["shadow_attr"],
        }
