"""
`ExportAnsDialog` -- the Export ▸ Export .ANS… dialog.

WHAT
    A small modal dialog over `studio.io.export_ans.export_ans`.  Two options
    (trim trailing blank cells; add CR/LF between rows for terminal preview), a
    live read-only preview of the escaped byte stream, a byte / row count that
    tracks the options, and -- when the composited document uses CP437 control
    codes -- a collapsible list of the offending cells.  "Save…" writes
    `result.data` verbatim as binary.

WHY
    The exporter is pure and headless; this is the only view concern.  It never
    mutates the document -- it composites a fresh copy each recompute.
"""

from PySide6.QtWidgets import (
    QCheckBox, QComboBox, QDialog, QDialogButtonBox, QFileDialog, QFormLayout,
    QGroupBox, QLabel, QListWidget, QMessageBox, QPlainTextEdit, QVBoxLayout,
)

from studio.io.export_ans import NULL_MODES, ansi_preview_text, export_ans

_NULL_LABELS = {
    "space": "space  (0x20, black)",
    "null": "NULL byte  (0x00)",
    "block": "black block  (0xDB)",
    "transparent": "transparent  (cursor-skip; shows what's underneath)",
}

_PREVIEW_CAP = 4000


class ExportAnsDialog(QDialog):
    """Modal Odyssey-native `.ANS` export dialog for a `Document`."""

    def __init__(self, document, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Export .ANS")
        self.setModal(True)
        self._document = document
        self.result_obj = None  # last ExportResult

        root = QVBoxLayout(self)

        self.chk_trim = QCheckBox("Trim trailing blank cells")
        self.chk_trim.setChecked(True)
        self.chk_newline = QCheckBox(
            "Add CR/LF between rows (for terminal preview)")
        self.chk_newline.setChecked(False)
        root.addWidget(self.chk_trim)
        root.addWidget(self.chk_newline)

        form = QFormLayout()
        self.cb_null = QComboBox()
        for m in NULL_MODES:
            self.cb_null.addItem(_NULL_LABELS[m], m)
        self.cb_null.currentIndexChanged.connect(self._recompute)
        form.addRow("Empty / transparent cells:", self.cb_null)
        root.addLayout(form)

        self.preview = QPlainTextEdit()
        self.preview.setReadOnly(True)
        self.preview.setLineWrapMode(QPlainTextEdit.NoWrap)
        f = self.preview.font()
        f.setStyleHint(f.StyleHint.Monospace)
        f.setFamily("monospace")
        self.preview.setFont(f)
        self.preview.setMinimumSize(520, 320)
        root.addWidget(self.preview, 1)

        self.lbl_stats = QLabel()
        root.addWidget(self.lbl_stats)

        self.warn_box = QGroupBox("Control-code warnings")
        self.warn_box.setCheckable(True)
        self.warn_box.setChecked(True)
        wv = QVBoxLayout(self.warn_box)
        self.warn_list = QListWidget()
        wv.addWidget(self.warn_list)
        self.warn_box.toggled.connect(self.warn_list.setVisible)
        self.warn_box.hide()
        root.addWidget(self.warn_box)

        bb = QDialogButtonBox(QDialogButtonBox.Cancel)
        self.btn_save = bb.addButton("Save…", QDialogButtonBox.AcceptRole)
        self.btn_save.clicked.connect(self._on_save)
        bb.rejected.connect(self.reject)
        root.addWidget(bb)

        self.chk_trim.toggled.connect(self._recompute)
        self.chk_newline.toggled.connect(self._recompute)
        self._recompute()

    # ---- API used by MainWindow / tests --------------------------------

    def export_result(self):
        """The most recent `ExportResult` (recomputed on every option change)."""
        return self.result_obj

    # ---- internals ----------------------------------------------------

    def _recompute(self, *_):
        sep = b"\r\n" if self.chk_newline.isChecked() else b""
        result = export_ans(
            self._document,
            trim_trailing_blanks=self.chk_trim.isChecked(),
            row_separator=sep,
            null_mode=self.cb_null.currentData(),
        )
        self.result_obj = result

        text = ansi_preview_text(result)
        if len(text) > _PREVIEW_CAP:
            text = text[:_PREVIEW_CAP] + "\n… (truncated)"
        self.preview.setPlainText(text)

        self.lbl_stats.setText(
            f"{result.byte_count} bytes · {result.rows_emitted} rows emitted")

        self.warn_list.clear()
        if result.warnings:
            self.warn_box.setTitle(
                f"{len(result.warnings)} cell(s) use CP437 control codes "
                "(0x00–0x1F/0x7F) that collide with terminal control "
                "characters:")
            for col, row, glyph in result.warnings:
                self.warn_list.addItem(f"{col},{row} → 0x{glyph:02X}")
            self.warn_box.show()
        else:
            self.warn_box.hide()

    def _on_save(self):
        if self.result_obj is None:
            self._recompute()
        path, _ = QFileDialog.getSaveFileName(
            self, "Export .ANS", "", "Odyssey ANSI (*.ans)")
        if not path:
            return
        if not path.lower().endswith(".ans"):
            path += ".ans"
        try:
            with open(path, "wb") as fh:
                fh.write(self.result_obj.data)
        except OSError as exc:
            QMessageBox.critical(self, "Export failed", str(exc))
            return
        self.accept()
