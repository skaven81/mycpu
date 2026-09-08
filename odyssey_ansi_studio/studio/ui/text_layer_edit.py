"""
`TextLayerDialog` -- create or re-edit a Text layer's parameters.

Modal.  `result_params()` returns a full parameter dict (merged over
`rasterize.TEXT_DEFAULTS`); the text and the window size stay editable
forever, and the layer re-rasterizes on accept.
"""

from PySide6.QtWidgets import (
    QCheckBox, QComboBox, QDialog, QDialogButtonBox, QFormLayout,
    QPlainTextEdit, QSpinBox, QVBoxLayout,
)

from studio.model.rasterize import TEXT_DEFAULTS
from studio.ui.ink_dialog import AttrField

_ALIGN = ["left", "center", "right"]


class TextLayerDialog(QDialog):
    def __init__(self, params=None, parent=None, *, window_title="Text layer",
                 ink=None, document=None):
        super().__init__(parent)
        self.setWindowTitle(window_title)
        self.setModal(True)
        p = {**TEXT_DEFAULTS, **(dict(params) if params else {})}
        if params is None and ink is not None:
            p["text_attr"] = int(ink) & 0xFF   # new layer inherits the current ink
        r = p.get("rect")
        if r:
            p["w"], p["h"] = int(r[2]), int(r[3])

        self.ed_text = QPlainTextEdit(p["text"])
        self.ed_text.setMinimumSize(320, 140)

        form = QFormLayout()
        self.sp_w = QSpinBox(); self.sp_w.setRange(1, 64); self.sp_w.setValue(int(p["w"]))
        self.sp_h = QSpinBox(); self.sp_h.setRange(1, 60); self.sp_h.setValue(int(p["h"]))
        form.addRow("Window width", self.sp_w)
        form.addRow("Window height", self.sp_h)

        self.cb_align = QComboBox(); self.cb_align.addItems(_ALIGN)
        self.cb_align.setCurrentText(p["align"])
        form.addRow("Align", self.cb_align)

        self.chk_wrap = QCheckBox("Word wrap at the window edge")
        self.chk_wrap.setChecked(bool(p["wrap"]))
        self.chk_opaque = QCheckBox("Opaque (spaces hide layers below)")
        self.chk_opaque.setChecked(bool(p["opaque"]))
        form.addRow("", self.chk_wrap)
        form.addRow("", self.chk_opaque)

        self.attr_field = AttrField(p["text_attr"], title="Text color",
                                    document=document)
        form.addRow("Text color", self.attr_field)

        box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        box.accepted.connect(self.accept)
        box.rejected.connect(self.reject)

        root = QVBoxLayout(self)
        root.addWidget(self.ed_text)
        root.addLayout(form)
        root.addWidget(box)

    def result_params(self) -> dict:
        return {
            "text": self.ed_text.toPlainText(),
            "w": self.sp_w.value(),
            "h": self.sp_h.value(),
            "align": self.cb_align.currentText(),
            "wrap": self.chk_wrap.isChecked(),
            "opaque": self.chk_opaque.isChecked(),
            "text_attr": self.attr_field.value(),
        }
