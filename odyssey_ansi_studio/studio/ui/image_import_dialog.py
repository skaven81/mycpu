"""
`ImageImportDialog` -- bring a PNG/JPG in as an Image layer.

Pick a file, set a crop -- drag it right on the source preview *or* type
x/y/w/h (the two stay in sync) -- choose a target cell size and a mapping
mode, watch a live preview rendered with the real font ROM, and insert.  The
resulting `ImageLayer` carries the source bytes + `ImportParams`, so the layer
stays re-quantisable after insertion and the source round-trips in the `.oas`.
"""

from PySide6.QtCore import Qt
from PySide6.QtGui import QImage, QPixmap
from PySide6.QtWidgets import (
    QCheckBox, QComboBox, QDialog, QDialogButtonBox, QFileDialog, QFormLayout,
    QGroupBox, QHBoxLayout, QLabel, QMessageBox, QPushButton, QSlider,
    QSpinBox, QVBoxLayout, QWidget,
)

from studio.convert.image_import import (
    MATCHES, MODES, ImportParams, clamp_crop, convert, fit_cells, load_image,
)
from studio.model.layers import ImageLayer
from studio.model.palette import odyssey_to_rgb
from studio.ui.crop_view import CropView

_CELL = 8


class ImageImportDialog(QDialog):
    def __init__(self, fontrom, font_bank=0, path=None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Import image as layer")
        self.setModal(True)
        self._fontrom = fontrom
        self._font_bank = font_bank
        self._img = None
        self._cells = {}
        self._syncing = False

        root = QVBoxLayout(self)

        pick = QHBoxLayout()
        self.lbl_path = QLabel("(no file)")
        btn_browse = QPushButton("Browse…")
        btn_browse.clicked.connect(self._browse)
        pick.addWidget(self.lbl_path, 1)
        pick.addWidget(btn_browse)
        root.addLayout(pick)

        previews = QHBoxLayout()
        self.src_view = CropView()
        self.src_view.setMinimumSize(280, 280)
        self.src_view.cropChanged.connect(self._crop_from_view)
        self.out_view = QLabel("result")
        self.out_view.setFixedSize(280, 280)
        self.out_view.setAlignment(Qt.AlignCenter)
        self.out_view.setFrameShape(QLabel.Box)
        previews.addWidget(self.src_view, 1)
        previews.addWidget(self.out_view)
        root.addLayout(previews)

        form = QFormLayout()
        self.chk_whole = QCheckBox("Use the whole image")
        self.chk_whole.setChecked(True)
        self.chk_whole.toggled.connect(self._whole_toggled)
        form.addRow("", self.chk_whole)

        self.sp_cx = QSpinBox(); self.sp_cy = QSpinBox()
        self.sp_cw = QSpinBox(); self.sp_ch = QSpinBox()
        for s in (self.sp_cx, self.sp_cy, self.sp_cw, self.sp_ch):
            s.setRange(0, 1 << 16)
            s.setEnabled(False)
            s.valueChanged.connect(self._crop_from_spins)
        crop_row = QHBoxLayout()
        for lab, s in (("x", self.sp_cx), ("y", self.sp_cy),
                       ("w", self.sp_cw), ("h", self.sp_ch)):
            crop_row.addWidget(QLabel(lab)); crop_row.addWidget(s)
        cw = QWidget(); cw.setLayout(crop_row)
        form.addRow("Crop", cw)

        self.sp_cols = QSpinBox(); self.sp_cols.setRange(1, 64); self.sp_cols.setValue(32)
        self.sp_rows = QSpinBox(); self.sp_rows.setRange(1, 60); self.sp_rows.setValue(16)
        self.sp_cols.valueChanged.connect(self._recompute)
        self.sp_rows.valueChanged.connect(self._recompute)
        form.addRow("Columns", self.sp_cols)
        form.addRow("Rows", self.sp_rows)

        self.cb_mode = QComboBox(); self.cb_mode.addItems(MODES)
        self.cb_mode.setCurrentText("shades")
        self.cb_mode.currentTextChanged.connect(self._recompute)
        form.addRow("Mode", self.cb_mode)

        self.sl_thr = QSlider(Qt.Horizontal); self.sl_thr.setRange(0, 128)
        self.sl_thr.setValue(24)
        self.sl_thr.valueChanged.connect(self._recompute)
        form.addRow("Dark threshold", self.sl_thr)

        self.sp_levels = QSpinBox(); self.sp_levels.setRange(2, 4)
        self.sp_levels.setValue(4)
        self.sp_levels.valueChanged.connect(self._recompute)
        form.addRow("Posterize levels", self.sp_levels)

        self.chk_dither = QCheckBox("Floyd-Steinberg dithering")
        self.chk_dither.toggled.connect(self._recompute)
        form.addRow("", self.chk_dither)

        self.cb_match = QComboBox()
        self.cb_match.addItems(MATCHES)          # "rgb" / "oklab"
        self.cb_match.setCurrentText("rgb")
        self.cb_match.setToolTip("oklab = perceptual color match (slower, "
                                 "usually nicer)")
        self.cb_match.currentTextChanged.connect(self._recompute)
        form.addRow("Color match", self.cb_match)

        gb = QGroupBox("Conversion"); gb.setLayout(form)
        root.addWidget(gb)

        self.stats = QLabel("")
        root.addWidget(self.stats)

        self.box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        self.box.button(QDialogButtonBox.Ok).setText("Insert as layer")
        self.box.accepted.connect(self.accept)
        self.box.rejected.connect(self.reject)
        self.box.button(QDialogButtonBox.Ok).setEnabled(False)
        root.addWidget(self.box)

        if path:
            self._load(path)

    # ------------------------------------------------------------------
    def _browse(self):
        path, _ = QFileDialog.getOpenFileName(
            self, "Choose an image", "",
            "Images (*.png *.jpg *.jpeg *.bmp *.webp *.gif)")
        if path:
            self._load(path)

    def _load(self, path):
        try:
            self._img = load_image(path)
        except Exception as exc:  # noqa: BLE001 - shown to the user
            QMessageBox.critical(self, "Cannot open image", str(exc))
            return
        self.lbl_path.setText(path)
        w, h = self._img.size
        self._syncing = True
        self.sp_cx.setRange(0, w - 1); self.sp_cy.setRange(0, h - 1)
        self.sp_cw.setRange(1, w); self.sp_ch.setRange(1, h)
        self.sp_cx.setValue(0); self.sp_cy.setValue(0)
        self.sp_cw.setValue(w); self.sp_ch.setValue(h)
        cols, rows = fit_cells(w, h)
        self.sp_cols.setValue(cols); self.sp_rows.setValue(rows)
        self._syncing = False
        self.src_view.set_image(self._img)
        self.src_view.set_edit_enabled(not self.chk_whole.isChecked())
        self.box.button(QDialogButtonBox.Ok).setEnabled(True)
        self._recompute()

    def _crop_from_view(self, x, y, w, h):
        if self._syncing:
            return
        self._syncing = True
        self.sp_cx.setValue(x); self.sp_cy.setValue(y)
        self.sp_cw.setValue(w); self.sp_ch.setValue(h)
        self._syncing = False
        self._recompute()

    def _crop_from_spins(self, *_):
        if self._syncing:
            return
        self._syncing = True
        self.src_view.set_crop(self.sp_cx.value(), self.sp_cy.value(),
                               self.sp_cw.value(), self.sp_ch.value())
        self._syncing = False
        self._recompute()

    def _whole_toggled(self, whole):
        for s in (self.sp_cx, self.sp_cy, self.sp_cw, self.sp_ch):
            s.setEnabled(not whole)
        self.src_view.set_edit_enabled(not whole)
        if whole and self._img is not None:
            self._syncing = True
            self.sp_cx.setValue(0); self.sp_cy.setValue(0)
            self.sp_cw.setValue(self._img.width); self.sp_ch.setValue(self._img.height)
            self.src_view.set_crop(0, 0, self._img.width, self._img.height)
            self._syncing = False
        self._recompute()

    def _params(self) -> ImportParams:
        crop = None
        if not self.chk_whole.isChecked() and self._img is not None:
            crop = clamp_crop(
                (self.sp_cx.value(), self.sp_cy.value(),
                 self.sp_cw.value(), self.sp_ch.value()),
                self._img.width, self._img.height)
        return ImportParams(
            cols=self.sp_cols.value(), rows=self.sp_rows.value(),
            crop=crop, mode=self.cb_mode.currentText(),
            dark_threshold=self.sl_thr.value(),
            levels=self.sp_levels.value(), dither=self.chk_dither.isChecked(),
            match=self.cb_match.currentText())

    def _recompute(self, *_):
        if self._img is None:
            return
        params = self._params()
        self._cells = convert(self._img, params)
        self.stats.setText(
            f"{params.cols}x{params.rows} cells · {len(self._cells)} lit")
        self._render_preview(params)

    def _render_preview(self, params):
        try:
            bank = self._fontrom.load_bank(self._font_bank)
        except FileNotFoundError:
            bank = self._fontrom.blank_bank()
        w, h = params.cols * _CELL, params.rows * _CELL
        img = QImage(w, h, QImage.Format_ARGB32_Premultiplied)
        img.fill(Qt.black)
        from PySide6.QtGui import QPainter
        p = QPainter(img)
        for (c, r), cell in self._cells.items():
            p.drawImage(c * _CELL, r * _CELL,
                        bank.glyph_image(cell.glyph, odyssey_to_rgb(cell.attr)))
        p.end()
        self.out_view.setPixmap(QPixmap.fromImage(img).scaled(
            self.out_view.size(), Qt.KeepAspectRatio, Qt.FastTransformation))

    # ------------------------------------------------------------------
    def result_layer(self):
        """The `ImageLayer` to insert, or None if nothing was loaded."""
        if self._img is None:
            return None
        params = self._params()
        layer = ImageLayer(name="Image", params=params.to_dict())
        layer.attach_source(image=self._img)
        layer.cells = dict(self._cells)
        layer._raster_cache = dict(self._cells)
        return layer
