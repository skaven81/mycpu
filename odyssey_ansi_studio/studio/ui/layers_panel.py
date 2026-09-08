"""
`LayersPanel` -- the full layer stack UI.

WHAT
    A list (top layer first) with a visibility and a lock toggle per row, plus
    a button row: add Blank / Box / Text, duplicate, delete, merge-down,
    flatten-all, move up / down, rename.  Box and Text rows are re-editable --
    double-click (or "Edit…") re-opens their dialog; the layer keeps its
    parameters for the life of the document and re-rasterizes on accept.  If a
    generated layer has been hand-edited with the drawing tools, the panel
    warns before the re-rasterize discards those edits (but "layers are
    mutable" wins if the user confirms).

    Structural changes emit `structureChanged`; selecting a row emits
    `activeChanged(index)`.  The panel mutates the `Document` directly; the
    owner redraws and sets the dirty flag.
"""

from PySide6.QtCore import QSize, Qt, Signal
from PySide6.QtGui import QFontMetrics, QPainter
from PySide6.QtWidgets import (
    QDialog, QGridLayout, QGroupBox, QHBoxLayout, QInputDialog, QLabel,
    QListWidget, QListWidgetItem, QMenu, QMessageBox, QPushButton, QSizePolicy,
    QToolButton, QVBoxLayout, QWidget,
)

from studio.model.layers import BlankLayer, BoxLayer, GeneratedLayer, TextLayer
from studio.ui.box_dialog import BoxDialog
from studio.ui.text_layer_edit import TextLayerDialog
from studio.ui.toolicons import layer_lock_icon, layer_vis_icon

_KIND_TAG = {"blank": "cells", "box": "box", "text": "text", "image": "image"}


class _ElidedLabel(QLabel):
    """A QLabel that shows an ellipsis when its text is wider than the widget,
    so a long layer name never forces the row wider than the dock."""

    def __init__(self, text=""):
        super().__init__(text)
        self._full = text
        self.setMinimumWidth(16)
        # Maximum: sit at the natural text width, but let the row layout shrink
        # (and thus elide) us when it runs out of room -- no stretch, so a short
        # name butts straight up against the kind tag with no gap.
        self.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Preferred)

    def setText(self, text):
        self._full = text
        super().setText(text)
        self.update()

    def minimumSizeHint(self):
        h = super().minimumSizeHint()
        return QSize(24, h.height())

    def paintEvent(self, _e):
        p = QPainter(self)
        fm = QFontMetrics(self.font())
        txt = fm.elidedText(self._full, Qt.ElideRight, self.width())
        p.drawText(self.rect(), int(self.alignment()) | Qt.AlignVCenter, txt)


class LayersPanel(QGroupBox):
    structureChanged = Signal()
    activeChanged = Signal(int)

    def __init__(self, fontrom=None, parent=None):
        super().__init__("Layers", parent)
        self._doc = None
        self._fontrom = fontrom
        self._populating = False
        self._ink_attr = 0x0F           # mirrors MainWindow ink; new layers inherit it

        root = QVBoxLayout(self)
        root.setContentsMargins(6, 6, 6, 6)
        root.setSpacing(4)

        self.list = QListWidget()
        self.list.setSelectionMode(QListWidget.ExtendedSelection)
        self.list.setTextElideMode(Qt.ElideRight)
        self.list.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.list.setMinimumWidth(1)
        self.list.currentRowChanged.connect(self._row_changed)
        self.list.itemDoubleClicked.connect(lambda _i: self.edit_selected())
        root.addWidget(self.list, 1)

        self.btn_add = QToolButton()
        self.btn_add.setText("Add ▾")
        self.btn_add.setPopupMode(QToolButton.InstantPopup)
        menu = QMenu(self.btn_add)
        menu.addAction("Blank layer", self.add_blank)
        menu.addAction("Box layer…", self.add_box)
        menu.addAction("Text layer…", self.add_text)
        menu.addAction("Image layer…", self.add_image)
        self.btn_add.setMenu(menu)

        self.btn_edit = QPushButton("Edit…")
        self.btn_edit.clicked.connect(self.edit_selected)
        self.btn_dup = QPushButton("Dup")
        self.btn_dup.clicked.connect(self.duplicate_selected)
        self.btn_del = QPushButton("Del")
        self.btn_del.clicked.connect(self.delete_selected)
        self.btn_up = QPushButton("▲")
        self.btn_up.clicked.connect(lambda: self.move_selected(+1))
        self.btn_down = QPushButton("▼")
        self.btn_down.clicked.connect(lambda: self.move_selected(-1))
        self.btn_merge = QPushButton("Merge ↓")
        self.btn_merge.clicked.connect(self.merge_down_selected)
        self.btn_flat = QPushButton("Flatten")
        self.btn_flat.clicked.connect(self.flatten_all)
        self.btn_rename = QPushButton("Rename")
        self.btn_rename.clicked.connect(self.rename_selected)

        self.btn_group = QToolButton()
        self.btn_group.setText("Group ▾")
        self.btn_group.setPopupMode(QToolButton.InstantPopup)
        gm = QMenu(self.btn_group)
        gm.addAction("Group selected…", self.group_selected)
        gm.addAction("Ungroup selected", self.ungroup_selected)
        gm.addSeparator()
        gm.addAction("Toggle group visibility", self.toggle_group_visibility)
        gm.addAction("Collapse / expand group", self.toggle_group_collapsed)
        self.btn_group.setMenu(gm)

        # A 4-column grid so the button cluster wraps instead of forcing the
        # whole dock wide enough for one long row.
        grid = QGridLayout()
        grid.setSpacing(2)
        buttons = [self.btn_add, self.btn_edit, self.btn_dup, self.btn_del,
                   self.btn_up, self.btn_down, self.btn_merge, self.btn_flat,
                   self.btn_rename, self.btn_group]
        for i, w in enumerate(buttons):
            w.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Fixed)
            w.setMinimumWidth(1)
            grid.addWidget(w, i // 4, i % 4)
        root.addLayout(grid)

    # ------------------------------------------------------------- document
    def set_document(self, doc):
        self._doc = doc
        self.refresh()

    def set_ink(self, attr):
        """Track the main window's current ink so a new Box / Text layer starts
        from it instead of a fixed default."""
        self._ink_attr = int(attr) & 0xFF

    def resizeEvent(self, e):
        super().resizeEvent(e)
        self._fit_rows()

    def _fit_rows(self):
        """Clamp every row to the list viewport width so the kind tag stays on
        screen and long names elide instead of forcing a scroll bar."""
        vpw = self.list.viewport().width()
        if vpw <= 0:
            return
        for r in range(self.list.count()):
            it = self.list.item(r)
            rw = self.list.itemWidget(it)
            if rw is None:
                continue
            h = rw.sizeHint().height()
            it.setSizeHint(QSize(vpw, h))
            rw.setMaximumWidth(vpw)

    def selected_index(self):
        it = self.list.currentItem()
        return it.data(Qt.UserRole) if it is not None else -1

    def _select_index(self, idx):
        for r in range(self.list.count()):
            if self.list.item(r).data(Qt.UserRole) == idx:
                self.list.setCurrentRow(r)
                return

    def refresh(self):
        self._populating = True
        self.list.clear()
        doc = self._doc
        if doc is None:
            self._populating = False
            return
        n = len(doc.layers)
        header_done = set()
        for idx in range(n - 1, -1, -1):
            layer = doc.layers[idx]
            g = getattr(layer, "group", None)
            if g is not None and doc.groups.get(g, {}).get("collapsed"):
                if g in header_done:
                    continue
                header_done.add(g)
                self._add_group_header(idx, g)
                continue
            self._add_layer_row(idx, layer, g)

        self._populating = False
        self._select_index(doc.active_layer_index)
        self._fit_rows()

    def _add_group_header(self, member_idx, name):
        doc = self._doc
        members = doc.group_layers(name)
        vis = doc.groups.get(name, {}).get("visible", True)
        rw = QWidget()
        h = QHBoxLayout(rw)
        h.setContentsMargins(2, 1, 2, 1)
        h.setSpacing(4)

        expand = QToolButton()
        expand.setText("▸")
        expand.setToolTip("Expand group")
        expand.clicked.connect(lambda: self._set_group_collapsed(name, False))

        gvis = QToolButton()
        gvis.setCheckable(True)
        gvis.setChecked(vis)
        gvis.setAutoRaise(True)
        gvis.setToolTip("Group visibility")
        gvis.setIcon(layer_vis_icon(vis))
        gvis.toggled.connect(lambda on: self._set_group_visible(name, on))

        lbl = QLabel(f"‹{name}›  ({len(members)} layer{'s' if len(members) != 1 else ''})")
        f = lbl.font(); f.setBold(True); lbl.setFont(f)

        h.addWidget(expand)
        h.addWidget(gvis)
        h.addWidget(lbl, 1)

        it = QListWidgetItem()
        it.setSizeHint(rw.sizeHint())
        it.setData(Qt.UserRole, member_idx)
        self.list.addItem(it)
        self.list.setItemWidget(it, rw)

    def _add_layer_row(self, idx, layer, group):
        doc = self._doc
        rw = QWidget()
        h = QHBoxLayout(rw)
        h.setContentsMargins(2, 1, 2, 1)
        h.setSpacing(4)

        vis = QToolButton()
        vis.setCheckable(True)
        vis.setChecked(layer.visible)
        vis.setAutoRaise(True)
        vis.setToolTip("Hide layer" if layer.visible else "Show layer")
        vis.setIcon(layer_vis_icon(layer.visible))
        vis.toggled.connect(
            lambda on, ly=layer, b=vis: self._on_vis_toggled(ly, on, b))

        lock = QToolButton()
        lock.setCheckable(True)
        lock.setChecked(layer.locked)
        lock.setAutoRaise(True)
        lock.setToolTip("Unlock layer" if layer.locked else "Lock layer")
        lock.setIcon(layer_lock_icon(layer.locked))
        lock.toggled.connect(
            lambda on, ly=layer, b=lock: self._on_lock_toggled(ly, on, b))

        name = _ElidedLabel(("    " if group else "") + layer.name)
        if group is not None and not doc.group_visible(layer):
            name.setEnabled(False)
        rw._name_label = name
        tag_txt = f"[{_KIND_TAG.get(layer.kind, 'cells')}]"
        if group:
            tag_txt += f" ‹{group}›"
        tag = QLabel(tag_txt)
        tag.setEnabled(False)
        if isinstance(layer, GeneratedLayer) and layer.manual_edits():
            tag.setText(tag.text() + " *")
            tag.setToolTip("hand-edited since last rasterize")

        h.addWidget(vis)
        h.addWidget(lock)
        h.addWidget(name)
        h.addWidget(tag)
        h.addStretch(1)

        # collapse toggle on the topmost member of a group
        if group and doc.group_layers(group) and idx == doc.group_layers(group)[-1]:
            coll = QToolButton()
            coll.setText("▾")
            coll.setToolTip("Collapse group")
            coll.clicked.connect(lambda _c=False, gn=group:
                                 self._set_group_collapsed(gn, True))
            h.addWidget(coll)

        it = QListWidgetItem()
        it.setSizeHint(rw.sizeHint())
        it.setData(Qt.UserRole, idx)
        self.list.addItem(it)
        self.list.setItemWidget(it, rw)

    def _on_vis_toggled(self, layer, on, btn):
        btn.setIcon(layer_vis_icon(on))
        btn.setToolTip("Hide layer" if on else "Show layer")
        self._set_visible(layer, on)

    def _on_lock_toggled(self, layer, on, btn):
        btn.setIcon(layer_lock_icon(on))
        btn.setToolTip("Unlock layer" if on else "Lock layer")
        layer.locked = bool(on)

    # ------------------------------------------------------------- groups
    def _selected_indices(self):
        out = {it.data(Qt.UserRole) for it in self.list.selectedItems()}
        out = {i for i in out if isinstance(i, int) and 0 <= i < len(self._doc.layers)}
        if not out and self.selected_index() >= 0:
            out = {self.selected_index()}
        return sorted(out)

    def _current_group(self):
        i = self.selected_index()
        if self._doc is not None and 0 <= i < len(self._doc.layers):
            return getattr(self._doc.layers[i], "group", None)
        return None

    def group_selected(self):
        idxs = self._selected_indices()
        if self._doc is None or not idxs:
            return
        seed = self._doc.layers[idxs[-1]].group or "Group"
        name, ok = QInputDialog.getText(self, "Group layers", "Group name:", text=seed)
        if not ok or not name.strip():
            return
        for i in idxs:
            self._doc.set_layer_group(i, name.strip())
        self.refresh()
        self.structureChanged.emit()

    def ungroup_selected(self):
        if self._doc is None:
            return
        changed = False
        for i in self._selected_indices():
            if getattr(self._doc.layers[i], "group", None) is not None:
                self._doc.set_layer_group(i, None)
                changed = True
        if changed:
            self.refresh()
            self.structureChanged.emit()

    def toggle_group_visibility(self):
        g = self._current_group()
        if g is None:
            QMessageBox.information(self, "No group",
                                   "Select a layer that belongs to a group.")
            return
        cur = self._doc.groups.get(g, {}).get("visible", True)
        self._set_group_visible(g, not cur)

    def toggle_group_collapsed(self):
        g = self._current_group()
        if g is None:
            return
        cur = self._doc.groups.get(g, {}).get("collapsed", False)
        self._set_group_collapsed(g, not cur)

    def _set_group_visible(self, name, on):
        self._doc.set_group_visible(name, on)
        self.refresh()
        self.structureChanged.emit()

    def _set_group_collapsed(self, name, on):
        self._doc.set_group_collapsed(name, on)
        self.refresh()

    # ------------------------------------------------------------- signals
    def _row_changed(self, _row):
        if self._populating:
            return
        idx = self.selected_index()
        if idx >= 0 and self._doc is not None:
            self._doc.active_layer_index = idx
            self.activeChanged.emit(idx)

    def _set_visible(self, layer, on):
        layer.visible = bool(on)
        self.structureChanged.emit()

    # ------------------------------------------------------------- add
    def _add(self, layer):
        self._doc.add_layer(layer)          # selects the new layer
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(self._doc.active_layer_index)

    def add_blank(self):
        if self._doc is None:
            return
        n = sum(1 for l in self._doc.layers if l.kind == "blank") + 1
        self._add(BlankLayer(name=f"Layer {n}"))

    def add_box(self):
        if self._doc is None:
            return
        dlg = BoxDialog(parent=self, ink=self._ink_attr, document=self._doc)
        if dlg.exec() != QDialog.Accepted:
            return
        layer = BoxLayer(name="Box", params=dlg.result_params())
        layer.offx, layer.offy = 4, 4
        layer.regenerate()
        self._add(layer)

    def add_text(self):
        if self._doc is None:
            return
        dlg = TextLayerDialog(parent=self, ink=self._ink_attr, document=self._doc)
        if dlg.exec() != QDialog.Accepted:
            return
        p = dlg.result_params()
        layer = TextLayer(name="Text", params=p, rect=(0, 0, p["w"], p["h"]))
        layer.offx, layer.offy = 6, 6
        layer.regenerate()
        self._add(layer)

    def add_image(self):
        if self._doc is None or self._fontrom is None:
            return
        from studio.ui.image_import_dialog import ImageImportDialog
        dlg = ImageImportDialog(self._fontrom, self._doc.font_bank, parent=self)
        if dlg.exec() != QDialog.Accepted:
            return
        layer = dlg.result_layer()
        if layer is None:
            return
        layer.offx, layer.offy = 2, 2
        self._add(layer)

    # ------------------------------------------------------------- edit
    def edit_selected(self):
        idx = self.selected_index()
        if self._doc is None or not (0 <= idx < len(self._doc.layers)):
            return
        layer = self._doc.layers[idx]
        if isinstance(layer, BoxLayer):
            dlg = BoxDialog(layer.params, parent=self, window_title="Edit box layer",
                            document=self._doc)
        elif isinstance(layer, TextLayer):
            dlg = TextLayerDialog(layer.params, parent=self,
                                  window_title="Edit text layer",
                                  document=self._doc)
        else:
            QMessageBox.information(
                self, "Not editable",
                "Only Box and Text layers have parameters to edit. "
                "Blank layers are drawn directly.")
            return
        if dlg.exec() != QDialog.Accepted:
            return
        if layer.manual_edits():
            keep = QMessageBox.warning(
                self, "Overwrite hand edits?",
                f"Layer '{layer.name}' has been edited with the drawing tools "
                "since it was last generated. Re-applying the layer settings "
                "will discard those edits.\n\nProceed?",
                QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
            if keep != QMessageBox.Yes:
                return
        layer.params.update(dlg.result_params())
        r = layer.params.get("rect")
        if r is not None:
            layer.params["rect"] = [r[0], r[1], layer.params["w"], layer.params["h"]]
        layer.regenerate()
        self.refresh()
        self.structureChanged.emit()

    # ------------------------------------------------------------- stack ops
    def duplicate_selected(self):
        idx = self.selected_index()
        if self._doc is None or not (0 <= idx < len(self._doc.layers)):
            return
        clone = self._doc.layers[idx].copy()
        clone.name = clone.name + " copy"
        self._doc.add_layer(clone, at=idx + 1)
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(self._doc.active_layer_index)

    def delete_selected(self):
        idx = self.selected_index()
        if self._doc is None or len(self._doc.layers) <= 1:
            return
        if not (0 <= idx < len(self._doc.layers)):
            return
        self._doc.remove_layer(idx)
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(self._doc.active_layer_index)

    def move_selected(self, direction):
        """direction: +1 = up the stack (towards the top), -1 = down."""
        idx = self.selected_index()
        if self._doc is None:
            return
        to = idx + (1 if direction > 0 else -1)
        if not (0 <= idx < len(self._doc.layers)) or not (0 <= to < len(self._doc.layers)):
            return
        self._doc.move_layer(idx, to)
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(to)

    def merge_down_selected(self):
        idx = self.selected_index()
        if self._doc is None or not (1 <= idx < len(self._doc.layers)):
            QMessageBox.information(
                self, "Cannot merge",
                "Select a layer with another layer beneath it.")
            return
        self._doc.merge_down(idx)
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(self._doc.active_layer_index)

    def flatten_all(self):
        if self._doc is None or len(self._doc.layers) <= 1:
            return
        if QMessageBox.question(
                self, "Flatten all layers?",
                "Combine every layer into a single blank layer? "
                "This cannot be undone.",
                QMessageBox.Yes | QMessageBox.No, QMessageBox.No) != QMessageBox.Yes:
            return
        self._doc.flatten()
        self.refresh()
        self.structureChanged.emit()
        self.activeChanged.emit(0)

    def rename_selected(self):
        idx = self.selected_index()
        if self._doc is None or not (0 <= idx < len(self._doc.layers)):
            return
        layer = self._doc.layers[idx]
        new, ok = QInputDialog.getText(self, "Rename layer", "Name:",
                                       text=layer.name)
        if ok and new.strip():
            layer.name = new.strip()
            self.refresh()
            self.structureChanged.emit()
