"""
`MainWindow` -- the application shell around the editing canvas.

WHAT
    A `QMainWindow` with the full chrome: menu bar (File / Edit / View / Layer /
    Export / Help), a left tool rail, a left "Ink & Glyph" dock, a right
    "Layers & Inspector" dock, the central `CanvasView`, and a status bar.

    Live as of Phase 3: the paint tools (pencil, eraser, line, rectangle,
    ellipse, flood fill, gradient, recolor, eyedropper, move-layer, cell-edit),
    undo / redo, a working cell inspector, and a minimal ink chooser (64-color
    grid + R/G/B + blink/cursor + a glyph quick-strip).  Save / load / export
    and all the view toggles are from Phase 2.

WHY
    The window owns no model logic.  It holds the current ink, a `History`, a
    `ToolContext` / `ToolController`, and wires widgets to `Document` +
    `CanvasView`.  Tools mutate the active layer through the context; the
    window just redraws and tracks the dirty flag.
"""

import os

from PySide6.QtCore import Qt, QSettings
from PySide6.QtGui import QAction, QActionGroup, QKeySequence
from PySide6.QtWidgets import (
    QDockWidget, QFileDialog, QGroupBox, QHBoxLayout, QInputDialog, QLabel,
    QMainWindow, QMessageBox, QScrollArea, QToolBar, QToolButton,
    QVBoxLayout, QWidget,
)

from studio.io.fontrom import BANKS, FontRom
from studio.io.project_file import (
    OAS_EXT, ProjectFileError, load_project, read_assets, save_project,
)
from studio.model.cell import Cell
from studio.model.document import new_blank_document
from studio.model.layers import ImageLayer
from studio.model.history import CellEditCommand, History
from studio.model.palette import attr_blink, attr_cursor, attr_to_rgb
from studio.io.cp437 import glyph_name
from studio.tools import TOOL_ORDER, ToolContext, ToolController, build_tools
from studio.ui.appicon import app_icon
from studio.ui.canvas_view import CanvasView
from studio.ui.toolicons import tool_icon
from studio.ui.cell_inspector import CellInspector
from studio.ui.export_dialog import ExportAnsDialog
from studio.ui.glyph_picker import GlyphPicker
from studio.ui.layers_panel import LayersPanel
from studio.ui.palette_panel import PalettePanel

_RECENT_KEY = "recentFiles"
_RECENT_MAX = 8
_OAS_FILTER = f"Odyssey ANSI Studio project (*{OAS_EXT})"

_TOOL_SHORTCUT = {
    "select": "S", "cell-edit": "C", "move-layer": "V", "pencil": "B",
    "eraser": "E", "line": "L", "rectangle": "R", "ellipse": "O",
    "flood-fill": "G", "gradient": "D", "recolor": "K", "eyedropper": "I",
}

_KIND_TAG = {"blank": "cells", "box": "box", "text": "text", "image": "image"}

#: left tool rail, grouped into logical sections separated by a horizontal rule
_RAIL_SECTIONS = [
    ("Cells", ["select", "cell-edit", "recolor", "move-layer"]),
    ("Draw", ["pencil", "eraser", "line", "rectangle", "ellipse",
              "flood-fill", "gradient"]),
]
#: one-shot "new layer" buttons at the foot of the rail (aliases for Layer > New).
#: "blank" is here for parity with the Layers panel's "Add ▾" menu.
_NEW_LAYER_TOOLS = [
    ("box", "New Box Layer…"),
    ("text", "New Text Layer…"),
    ("image", "New Image Layer…"),
    ("blank", "New Blank Layer"),
]


class MainWindow(QMainWindow):
    """The Odyssey ANSI Studio main window."""

    def __init__(self, document, parent=None, settings=None):
        super().__init__(parent)
        # Open big enough to show the whole 64x60 grid at the canvas's 2x
        # default (1024x960 px of content + rulers) alongside both docks;
        # `showEvent` grows this further if the first layout still clips the
        # canvas (clamped to the screen).
        self.resize(1680, 1120)
        self.setMinimumSize(1100, 760)
        self._sized_once = False
        self.setWindowIcon(app_icon())

        self._settings = settings or QSettings("odyssey", "ansi-studio")
        self._path = None
        self._dirty = False

        self.document = document
        self.fontrom = FontRom()
        self.canvas = CanvasView(self.fontrom)
        self.setCentralWidget(self.canvas)

        # current ink
        self._ink_glyph = 0xDB
        self._ink_attr = 0x0F
        self.palette_panel = PalettePanel()
        self.glyph_picker = GlyphPicker(self.fontrom)
        self.layers_panel = LayersPanel(self.fontrom)

        # undo/redo + tools
        self.history = History(document)
        self._tools = build_tools()
        self._ctx = ToolContext(
            document, self.history,
            get_glyph=self._current_glyph,
            get_attr=self._current_attr,
            set_glyph=self._set_ink_glyph,
            set_attr=self._set_ink_attr,
            on_change=self._after_edit,
            on_status=self._tool_status,
            on_select=self._select_cell_for_inspector,
        )
        self._controller = ToolController(self._ctx, self._tools["select"])
        self.canvas.set_controller(self._controller)

        self._selected_layer_index = document.active_layer_index
        self._selected_cell = None

        self._build_tool_rail()
        self._build_left_dock()
        self._build_right_dock()
        self._build_status_bar()
        self._build_menus()
        self.resizeDocks([self.dock_ink, self.dock_layers], [360, 360],
                         Qt.Horizontal)

        self.canvas.cellHovered.connect(self._on_cell_hovered)
        self.canvas.zoomChanged.connect(self._on_zoom_changed)
        self.palette_panel.inkChosen.connect(self._on_ink_chosen)
        self.palette_panel.projectPaletteChanged.connect(self.mark_dirty)
        self.palette_panel.screenColorRequested.connect(self._pick_screen_color)
        self.glyph_picker.glyphChosen.connect(self._on_glyph_chosen)
        self.glyph_picker.bankChanged.connect(self._set_font_bank)

        self._load_document(document)
        self.canvas.set_frame_editing(True)   # default tool is Select
        self._rebuild_recent_menu()
        self.palette_panel.set_ink(self._ink_attr)
        self.layers_panel.set_ink(self._ink_attr)
        self.glyph_picker.set_ink_rgb(attr_to_rgb(self._ink_attr))
        self.glyph_picker.set_current_glyph(self._ink_glyph)
        self._set_clean()

    # ---- current ink accessors (given to the ToolContext) -----------------

    def _current_glyph(self):
        return self._ink_glyph

    def _current_attr(self):
        return self._ink_attr

    # ------------------------------------------------------- dirty / title

    def mark_dirty(self):
        if not self._dirty:
            self._dirty = True
            self.setWindowModified(True)

    def _set_clean(self):
        self._dirty = False
        self.setWindowModified(False)
        self._update_title()

    def _update_title(self):
        base = os.path.basename(self._path) if self._path else "Untitled"
        self.setWindowTitle(f"{base}[*] — Odyssey ANSI Studio")

    def is_dirty(self):
        return self._dirty

    def current_path(self):
        return self._path

    # ------------------------------------------------------------------ rail

    def _build_tool_rail(self):
        rail = QToolBar("Tools", self)
        rail.setObjectName("tool_rail")
        rail.setMovable(False)
        rail.setFloatable(False)
        rail.setContextMenuPolicy(Qt.PreventContextMenu)
        rail.setOrientation(Qt.Vertical)
        self.addToolBar(Qt.LeftToolBarArea, rail)
        self.tool_rail = rail

        labels = {k: l for k, l, _i, _im in TOOL_ORDER}
        self._tool_group = QActionGroup(self)
        self._tool_group.setExclusive(True)
        self._tool_actions = {}

        def make_tool_action(key, *, on_rail=True):
            act = QAction(tool_icon(key), labels.get(key, key.title()), self)
            act.setCheckable(True)
            act.setData(key)
            tip = labels.get(key, key.title())
            sc = _TOOL_SHORTCUT.get(key)
            if sc:
                act.setShortcut(QKeySequence(sc))
                act.setShortcutContext(Qt.WindowShortcut)
                tip = f"{tip}  ({sc})"
            act.setToolTip(tip)
            self._tool_group.addAction(act)
            if on_rail:
                rail.addAction(act)
            else:
                self.addAction(act)          # keep the shortcut live
            self._tool_actions[key] = act
            return act

        for si, (_title, keys) in enumerate(_RAIL_SECTIONS):
            if si:
                rail.addSeparator()
            for key in keys:
                act = make_tool_action(key)
                if key == "select":
                    act.setChecked(True)

        # Eyedropper is a real tool but lives on the Ink panel, not the rail.
        make_tool_action("eyedropper", on_rail=False)

        self._tool_group.triggered.connect(
            lambda a: self._on_tool_selected(a.data()))

        # ---- one-shot "new layer" buttons (aliases for Layer > New) --------
        rail.addSeparator()
        new_layer_slots = {
            "box": self.layers_panel.add_box,
            "text": self.layers_panel.add_text,
            "image": self.layers_panel.add_image,
            "blank": self.layers_panel.add_blank,
        }
        for key, label in _NEW_LAYER_TOOLS:
            act = QAction(tool_icon(key), label, self)
            act.setToolTip(label)
            act.triggered.connect(
                lambda _c=False, s=new_layer_slots[key]: s())
            rail.addAction(act)
            self._tool_actions[key] = act

    def _on_tool_selected(self, key):
        tool = self._tools.get(key)
        if tool is None:
            return
        self._controller.set_tool(tool)
        self.canvas.set_frame_editing(key in ("select", "move-layer"))
        label = next((l for k, l, _i, _im in TOOL_ORDER if k == key), key)
        self.tool_panel.setTitle(f"Tool: {label}")
        if key not in ("cell-edit", "select"):
            self.inspector.clear_selection()
            self._selected_cell = None
            self.canvas.set_caret(None)
        self._populate_tool_panel(key)
        self.statusBar().showMessage(f"{label} tool", 2000)

    def _populate_tool_panel(self, key):
        lay = self._tool_panel_body
        while lay.count():
            w = lay.takeAt(0).widget()
            if w is not None:
                w.deleteLater()

        if key == "gradient":
            grad = self._tools["gradient"]
            row = QHBoxLayout()
            self._grad_end_lbl = QLabel(f"fade-to  0x{grad.end_attr:02X}")
            b_ink = QToolButton(); b_ink.setText("= ink")
            b_blk = QToolButton(); b_blk.setText("= black")
            b_ink.clicked.connect(lambda: self._set_gradient_end(self._ink_attr))
            b_blk.clicked.connect(lambda: self._set_gradient_end(0x00))
            row.addWidget(self._grad_end_lbl, 1)
            row.addWidget(b_ink)
            row.addWidget(b_blk)
            w = QWidget(); w.setLayout(row)
            lay.addWidget(w)
            hint = QLabel("Drag from the start color toward the fade-to color. "
                          "Ctrl = fill blocks instead of recoloring.")
            hint.setWordWrap(True); hint.setEnabled(False)
            lay.addWidget(hint)
        else:
            hint = QLabel("Drag on the canvas to draw. Esc cancels a shape.")
            hint.setWordWrap(True); hint.setEnabled(False)
            lay.addWidget(hint)

    def _set_gradient_end(self, attr):
        self._tools["gradient"].end_attr = int(attr) & 0xFF
        if hasattr(self, "_grad_end_lbl"):
            self._grad_end_lbl.setText(f"fade-to  0x{int(attr) & 0xFF:02X}")

    # ------------------------------------------------------------- left dock

    def _build_left_dock(self):
        # Left tool area: glyph picker, the hover readout, and -- at the
        # bottom -- the cell inspector.
        dock = QDockWidget("Glyph & Cell", self)
        dock.setObjectName("dock_ink")
        dock.setMinimumWidth(240)
        dock.setMaximumWidth(420)
        self.dock_ink = dock

        self.inspector = CellInspector()
        self.inspector.applied.connect(self._inspector_apply)
        self.inspector.cleared.connect(self._inspector_clear)

        scroll = QScrollArea(dock)
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        body = QWidget()
        col = QVBoxLayout(body)
        col.setContentsMargins(6, 6, 6, 6)
        col.setSpacing(8)

        col.addWidget(self.glyph_picker, 1)
        col.addWidget(self._build_readout_group())
        col.addWidget(self.inspector)

        scroll.setWidget(body)
        dock.setWidget(scroll)
        self.addDockWidget(Qt.LeftDockWidgetArea, dock)

    def _build_readout_group(self):
        box = QGroupBox("Readout")
        lay = QVBoxLayout(box)
        self._readout = QLabel("hover the canvas…")
        self._readout.setTextFormat(Qt.PlainText)
        self._readout.setWordWrap(False)
        f = self._readout.font()
        f.setStyleHint(f.StyleHint.Monospace)
        f.setFamily("monospace")
        self._readout.setFont(f)
        lay.addWidget(self._readout)
        return box

    # ---- ink plumbing ---------------------------------------------------
    #
    # The PalettePanel and GlyphPicker own their own widgets and keep their
    # own copy of the value in sync; these methods just mirror the canonical
    # `_ink_*` the ToolContext reads.

    def _set_ink_attr(self, attr):
        """External setter (eyedropper): update state + the panel, no echo."""
        self._ink_attr = int(attr) & 0xFF
        self.palette_panel.set_ink(self._ink_attr)
        self.glyph_picker.set_ink_rgb(attr_to_rgb(self._ink_attr))
        self.layers_panel.set_ink(self._ink_attr)

    def _set_ink_glyph(self, code):
        self._ink_glyph = int(code) & 0xFF
        self.glyph_picker.set_current_glyph(self._ink_glyph)
        self.inspector.set_glyph_preview(self._ink_glyph)

    def _on_ink_chosen(self, attr):
        """The palette panel reports a user pick (panel already updated)."""
        self._ink_attr = int(attr) & 0xFF
        self.glyph_picker.set_ink_rgb(attr_to_rgb(self._ink_attr))
        self.layers_panel.set_ink(self._ink_attr)

    def _on_glyph_chosen(self, code):
        self._ink_glyph = int(code) & 0xFF
        self.inspector.set_glyph_preview(self._ink_glyph)

    # ---- screen eyedropper -------------------------------------------

    def _pick_screen_color(self):
        """"Pick…" on the Ink panel: sample a pixel anywhere on screen, then
        match it to an Odyssey color."""
        from studio.ui.screen_pick import pick_screen_color
        self.statusBar().showMessage(
            "Click any pixel on screen to sample its color  (Esc cancels)…", 5000)
        pick_screen_color(self, self._match_screen_color)

    def _match_screen_color(self, qcolor):
        from studio.ui.color_match_dialog import OdysseyColorDialog
        dlg = OdysseyColorDialog(qcolor, current_attr=self._ink_attr & 0x3F,
                                 parent=self)
        if not dlg.exec():
            return
        attr = dlg.chosen_attr()
        # keep the current blink / cursor bits, swap in the matched color
        self._set_ink_attr((self._ink_attr & 0xC0) | attr)
        self.statusBar().showMessage(f"Ink set to Odyssey 0x{attr:02X}", 3000)

    # ------------------------------------------------------------ right dock

    def _build_right_dock(self):
        # Right tool area: the Ink panel on top, then the layer stack, then
        # the selected tool's options.
        dock = QDockWidget("Ink & Layers", self)
        dock.setObjectName("dock_layers")
        dock.setMinimumWidth(260)
        dock.setMaximumWidth(420)
        self.dock_layers = dock

        scroll = QScrollArea(dock)
        scroll.setWidgetResizable(True)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        body = QWidget()
        col = QVBoxLayout(body)
        col.setContentsMargins(6, 6, 6, 6)
        col.setSpacing(8)

        col.addWidget(self.palette_panel)

        self.layers_panel.structureChanged.connect(self._on_layers_changed)
        self.layers_panel.activeChanged.connect(self._on_active_layer_changed)
        col.addWidget(self.layers_panel, 1)

        self.tool_panel = QGroupBox("Tool: Select")
        self._tool_panel_body = QVBoxLayout(self.tool_panel)
        empty = QLabel("Drag on the canvas to draw. Esc cancels a shape.")
        empty.setWordWrap(True)
        empty.setEnabled(False)
        self._tool_panel_body.addWidget(empty)
        col.addWidget(self.tool_panel)
        col.addStretch(0)

        scroll.setWidget(body)
        dock.setWidget(scroll)
        self.addDockWidget(Qt.RightDockWidgetArea, dock)

    def _on_layers_changed(self):
        """Structural change from LayersPanel: redraw, dirty, resync."""
        self.canvas.refresh()
        self.mark_dirty()
        # a layer dialog's shared color picker may have appended project colors
        self.palette_panel.set_document(self.document)
        self._selected_layer_index = self.document.active_layer_index
        if self._selected_cell is not None:
            self._select_cell_for_inspector(*self._selected_cell)

    def _on_active_layer_changed(self, idx):
        self._selected_layer_index = idx
        self.canvas.viewport().update()      # redraw the active-layer frame
        if self._selected_cell is not None:
            self._select_cell_for_inspector(*self._selected_cell)

    def _selected_layer(self):
        i = self.document.active_layer_index
        if 0 <= i < len(self.document.layers):
            return self.document.layers[i]
        return None

    def _toggle_selected_layer_visible(self):
        layer = self._selected_layer()
        if layer is not None:
            layer.visible = not layer.visible
            self.layers_panel.refresh()
            self.canvas.refresh()
            self.mark_dirty()

    def _toggle_selected_layer_lock(self):
        layer = self._selected_layer()
        if layer is not None:
            layer.locked = not layer.locked
            self.layers_panel.refresh()
            self.mark_dirty()

    # ---- cell inspector wiring ------------------------------------------

    def _active_layer(self):
        d = self.document
        i = d.active_layer_index
        return d.layers[i] if 0 <= i < len(d.layers) else None

    def _select_cell_for_inspector(self, col, row):
        self._selected_cell = (col, row)
        self.canvas.set_caret((col, row))
        layer = self._active_layer()
        cell = layer.get(col, row) if layer is not None else None
        name = layer.name if layer is not None else "—"
        self.inspector.select(col, row, cell, name)

    def _inspector_apply(self, glyph, attr):
        self._write_selected_cell(Cell(int(glyph) & 0xFF, int(attr) & 0xFF))

    def _inspector_clear(self):
        self._write_selected_cell(None)

    def _write_selected_cell(self, new_cell):
        if self._selected_cell is None:
            return
        layer = self._active_layer()
        if layer is None:
            QMessageBox.information(self, "No layer", "There is no active layer.")
            return
        if layer.locked:
            QMessageBox.information(
                self, "Layer locked",
                f"Layer '{layer.name}' is locked. Unlock it to edit cells.")
            return
        col, row = self._selected_cell
        lc, lr = col - layer.offx, row - layer.offy
        old = layer.get_local(lc, lr)
        if old == new_cell:
            return
        self.history.push(
            CellEditCommand(self.document.active_layer_index,
                            {(lc, lr): (old, new_cell)}))
        self._after_edit()

    # ---- edit lifecycle ------------------------------------------------

    def _after_edit(self):
        """A committed edit (tool stroke, inspector, undo, redo)."""
        self.canvas.refresh()
        self.mark_dirty()
        self._sync_undo_actions()
        hov = self.canvas.hovered_cell()
        if hov is not None:
            self._on_cell_hovered(hov[0], hov[1],
                                  self.document.composite_cell(*hov))
        if self._selected_cell is not None and self.inspector.selection():
            layer = self._active_layer()
            cell = layer.get(*self._selected_cell) if layer is not None else None
            name = layer.name if layer is not None else "—"
            self.inspector.select(self._selected_cell[0], self._selected_cell[1],
                                  cell, name)

    def _tool_status(self, message):
        self.statusBar().showMessage(message, 4000)

    def _undo(self):
        if self.history.undo():
            self._after_edit()

    def _redo(self):
        if self.history.redo():
            self._after_edit()

    def _sync_undo_actions(self):
        self.act_undo.setEnabled(self.history.can_undo())
        self.act_redo.setEnabled(self.history.can_redo())

    # ----------------------------------------------------------- status bar

    def _build_status_bar(self):
        sb = self.statusBar()

        def lbl(text=""):
            w = QLabel(text)
            w.setMinimumWidth(1)
            return w

        self.sb_pos = lbl("—,—")
        self.sb_char_addr = lbl("0x4000")
        self.sb_attr_addr = lbl("0x5000")
        self.sb_char = lbl("char —")
        self.sb_attr = lbl("attr —")
        self.sb_flags = lbl("—")
        for w in (self.sb_pos, self.sb_char_addr, self.sb_attr_addr,
                  self.sb_char, self.sb_attr, self.sb_flags):
            sb.addWidget(w)
            sb.addWidget(QLabel("·"))

        self.btn_zoom_out = QToolButton()
        self.btn_zoom_out.setText("−")
        self.btn_zoom_out.clicked.connect(self.canvas.zoom_out)
        self.lbl_zoom = QLabel("×1")
        self.btn_zoom_in = QToolButton()
        self.btn_zoom_in.setText("+")
        self.btn_zoom_in.clicked.connect(self.canvas.zoom_in)

        self.btn_blink = QToolButton()
        self.btn_blink.setText("Blink")
        self.btn_blink.setCheckable(True)
        self.btn_blink.setChecked(True)
        self.btn_blink.toggled.connect(self._set_blink_preview)

        self.btn_grid = QToolButton()
        self.btn_grid.setText("Grid")
        self.btn_grid.setCheckable(True)
        self.btn_grid.setChecked(False)
        self.btn_grid.toggled.connect(self._set_grid)

        self.btn_trans = QToolButton()
        self.btn_trans.setText("NULL")
        self.btn_trans.setToolTip("Show transparent / NULL cells as a checkerboard")
        self.btn_trans.setCheckable(True)
        self.btn_trans.setChecked(False)
        self.btn_trans.toggled.connect(self._set_transparency)

        for w in (self.btn_zoom_out, self.lbl_zoom, self.btn_zoom_in,
                  self.btn_blink, self.btn_grid, self.btn_trans):
            sb.addPermanentWidget(w)

    # --------------------------------------------------------------- menus

    def _build_menus(self):
        mb = self.menuBar()

        # ---- File
        m_file = mb.addMenu("&File")
        act_new = QAction("&New", self)
        act_new.setShortcut(QKeySequence.New)
        act_new.triggered.connect(self._file_new)
        m_file.addAction(act_new)

        act_open = QAction("&Open…", self)
        act_open.setShortcut(QKeySequence.Open)
        act_open.triggered.connect(self._file_open)
        m_file.addAction(act_open)

        self.m_recent = m_file.addMenu("Open &Recent")

        act_save = QAction("&Save", self)
        act_save.setShortcut(QKeySequence.Save)
        act_save.triggered.connect(self._file_save)
        m_file.addAction(act_save)

        act_save_as = QAction("Save &As…", self)
        act_save_as.setShortcut(QKeySequence.SaveAs)
        act_save_as.triggered.connect(self._file_save_as)
        m_file.addAction(act_save_as)

        m_file.addSeparator()
        act_quit = QAction("&Quit", self)
        act_quit.setShortcut(QKeySequence("Ctrl+Q"))
        act_quit.triggered.connect(self.close)
        m_file.addAction(act_quit)

        # ---- Edit
        m_edit = mb.addMenu("&Edit")
        self.act_undo = QAction("&Undo", self)
        self.act_undo.setShortcut(QKeySequence.Undo)
        self.act_undo.triggered.connect(self._undo)
        self.act_redo = QAction("&Redo", self)
        self.act_redo.setShortcut(QKeySequence.Redo)
        self.act_redo.triggered.connect(self._redo)
        self.act_undo.setEnabled(False)
        self.act_redo.setEnabled(False)
        m_edit.addAction(self.act_undo)
        m_edit.addAction(self.act_redo)
        m_edit.addSeparator()
        for text, sc in (("Cu&t", QKeySequence.Cut), ("&Copy", QKeySequence.Copy),
                         ("&Paste", QKeySequence.Paste), ("&Delete", None),
                         ("Select &All", QKeySequence.SelectAll)):
            a = QAction(text, self)
            if sc is not None:
                a.setShortcut(sc)
            a.setEnabled(False)
            m_edit.addAction(a)

        # ---- View
        m_view = mb.addMenu("&View")
        a_zin = QAction("Zoom &In", self)
        a_zin.setShortcuts([QKeySequence("Ctrl+="), QKeySequence("Ctrl++")])
        a_zin.triggered.connect(self.canvas.zoom_in)
        a_zout = QAction("Zoom &Out", self)
        a_zout.setShortcut(QKeySequence("Ctrl+-"))
        a_zout.triggered.connect(self.canvas.zoom_out)
        a_z100 = QAction("Zoom &100%", self)
        a_z100.setShortcut(QKeySequence("Ctrl+0"))
        a_z100.triggered.connect(self.canvas.zoom_reset)
        a_fit = QAction("&Fit to Window", self)
        a_fit.setShortcut(QKeySequence("Ctrl+9"))
        a_fit.triggered.connect(self.canvas.fit_to_window)
        for a in (a_zin, a_zout, a_z100, a_fit):
            m_view.addAction(a)
        m_view.addSeparator()

        self.act_show_grid = QAction("Show &Grid", self)
        self.act_show_grid.setCheckable(True)
        self.act_show_grid.setChecked(False)
        self.act_show_grid.toggled.connect(self._set_grid)
        self.act_show_rulers = QAction("Show &Rulers", self)
        self.act_show_rulers.setCheckable(True)
        self.act_show_rulers.setChecked(True)
        self.act_show_rulers.toggled.connect(self._set_rulers)
        self.act_blink_preview = QAction("&Blink Preview", self)
        self.act_blink_preview.setCheckable(True)
        self.act_blink_preview.setChecked(True)
        self.act_blink_preview.toggled.connect(self._set_blink_preview)
        self.act_show_trans = QAction("Show &Transparency", self)
        self.act_show_trans.setCheckable(True)
        self.act_show_trans.setChecked(False)
        self.act_show_trans.toggled.connect(self._set_transparency)
        for a in (self.act_show_grid, self.act_show_rulers, self.act_blink_preview,
                  self.act_show_trans):
            m_view.addAction(a)
        m_view.addSeparator()

        m_panels = m_view.addMenu("&Panels")
        m_panels.addAction(self.dock_ink.toggleViewAction())
        m_panels.addAction(self.dock_layers.toggleViewAction())
        m_toolbars = m_view.addMenu("&Toolbars")
        m_toolbars.addAction(self.tool_rail.toggleViewAction())

        # ---- Layer
        m_layer = mb.addMenu("&Layer")
        m_new = m_layer.addMenu("&New")
        lp = self.layers_panel
        for text, slot in (("&Blank", lp.add_blank), ("Bo&x…", lp.add_box),
                           ("&Text…", lp.add_text), ("&Image…", lp.add_image)):
            a = QAction(text, self)
            a.triggered.connect(lambda _c=False, s=slot: s())
            m_new.addAction(a)

        for text, slot in (("&Edit Layer…", lp.edit_selected),
                           ("D&uplicate", lp.duplicate_selected),
                           ("&Delete", lp.delete_selected),
                           ("&Merge Down", lp.merge_down_selected),
                           ("&Flatten All", lp.flatten_all),
                           ("Move &Up", lambda: lp.move_selected(+1)),
                           ("Move &Down", lambda: lp.move_selected(-1)),
                           ("&Rename…", lp.rename_selected)):
            a = QAction(text, self)
            a.triggered.connect(lambda _c=False, s=slot: s())
            m_layer.addAction(a)
        m_layer.addSeparator()

        m_bank = m_layer.addMenu("&Font Bank")
        self._bank_group = QActionGroup(self)
        self._bank_group.setExclusive(True)
        self._bank_actions = []
        for spec in BANKS:
            a = QAction(f"{spec['index']} — {spec['name']}", self)
            a.setCheckable(True)
            a.triggered.connect(
                lambda _checked, i=spec["index"]: self._set_font_bank(i))
            self._bank_group.addAction(a)
            m_bank.addAction(a)
            self._bank_actions.append(a)
        m_layer.addSeparator()

        a_tv = QAction("Toggle &Visibility", self)
        a_tv.triggered.connect(self._toggle_selected_layer_visible)
        a_tl = QAction("Toggle &Lock", self)
        a_tl.triggered.connect(self._toggle_selected_layer_lock)
        m_layer.addAction(a_tv)
        m_layer.addAction(a_tl)

        # ---- Export
        m_export = mb.addMenu("E&xport")
        a_ans = QAction("Export .ANS…", self)
        a_ans.triggered.connect(self._export_ans)
        m_export.addAction(a_ans)
        a_ans16 = QAction("Export portable 16-color .ANS…", self)
        a_ans16.triggered.connect(lambda: self._export_data("ans16"))
        m_export.addAction(a_ans16)
        m_export.addSeparator()
        for text, kind in (("Raw binary (split planes)…", "bin-split"),
                           ("Raw binary (interleaved)…", "bin-inter"),
                           ("C header…", "c"),
                           ("ASM data…", "asm"),
                           ("PNG image…", "png")):
            a = QAction(text, self)
            a.triggered.connect(lambda _c=False, k=kind: self._export_data(k))
            m_export.addAction(a)

        # ---- Help
        m_help = mb.addMenu("&Help")
        a_about = QAction("&About", self)
        a_about.triggered.connect(self._about)
        m_help.addAction(a_about)

    # ---------------------------------------------------------- File actions

    def _guard_unsaved(self) -> bool:
        if not self._dirty:
            return True
        choice = QMessageBox.warning(
            self, "Unsaved changes",
            "The current document has unsaved changes. Save them first?",
            QMessageBox.Save | QMessageBox.Discard | QMessageBox.Cancel,
            QMessageBox.Save,
        )
        if choice == QMessageBox.Save:
            return self._file_save()
        return choice == QMessageBox.Discard

    def _file_new(self):
        if not self._guard_unsaved():
            return
        self._load_document(new_blank_document())
        self._path = None
        self._set_clean()

    def _file_open(self):
        if not self._guard_unsaved():
            return
        path, _ = QFileDialog.getOpenFileName(
            self, "Open project", "", _OAS_FILTER)
        if path:
            self._open_path(path)

    def _open_path(self, path) -> bool:
        try:
            doc = load_project(path)
        except ProjectFileError as exc:
            QMessageBox.critical(self, "Open failed", str(exc))
            return False
        self._load_document(doc)
        self._reattach_assets(path)
        self._path = path
        self._set_clean()
        self._push_recent(path)
        return True

    def _collect_assets(self) -> dict:
        """``{sha256hex.png: bytes}`` for every image layer carrying its source."""
        out = {}
        for lyr in self.document.layers:
            if isinstance(lyr, ImageLayer) and getattr(lyr, "_source_bytes", None):
                out[lyr.source_ref] = lyr._source_bytes
        return out

    def _reattach_assets(self, path):
        """Give loaded image layers their source pixels back from ``assets/``."""
        try:
            assets = read_assets(path)
        except Exception:  # noqa: BLE001 - a missing bundle is not fatal
            return
        for lyr in self.document.layers:
            if isinstance(lyr, ImageLayer) and lyr.source_ref in assets:
                try:
                    lyr.attach_source(blob=assets[lyr.source_ref])
                except Exception:  # noqa: BLE001
                    pass

    def _file_save(self) -> bool:
        if self._path is None:
            return self._file_save_as()
        try:
            save_project(self.document, self._path, assets=self._collect_assets())
        except Exception as exc:  # noqa: BLE001 -- surfaced to the user
            QMessageBox.critical(self, "Save failed", str(exc))
            return False
        self._set_clean()
        self._push_recent(self._path)
        return True

    def _file_save_as(self) -> bool:
        path, _ = QFileDialog.getSaveFileName(
            self, "Save project as", self._path or "", _OAS_FILTER)
        if not path:
            return False
        if not path.lower().endswith(OAS_EXT):
            path += OAS_EXT
        try:
            save_project(self.document, path, assets=self._collect_assets())
        except Exception as exc:  # noqa: BLE001 -- surfaced to the user
            QMessageBox.critical(self, "Save failed", str(exc))
            return False
        self._path = path
        self._set_clean()
        self._push_recent(path)
        return True

    # ---- recent files -------------------------------------------------

    def _recent_files(self) -> list:
        val = self._settings.value(_RECENT_KEY, [])
        if isinstance(val, str):
            val = [val] if val else []
        return [str(p) for p in (val or [])]

    def _write_recent(self, items):
        self._settings.setValue(_RECENT_KEY, items[:_RECENT_MAX])
        self._rebuild_recent_menu()

    def _push_recent(self, path):
        path = os.path.abspath(path)
        items = [p for p in self._recent_files() if p != path]
        items.insert(0, path)
        self._write_recent(items)

    def _remove_recent(self, path):
        path = os.path.abspath(path)
        self._write_recent([p for p in self._recent_files() if p != path])

    def _clear_recent(self):
        self._write_recent([])

    def _rebuild_recent_menu(self):
        self.m_recent.clear()
        items = self._recent_files()
        self.m_recent.setEnabled(bool(items))
        for path in items:
            act = QAction(path, self)
            act.triggered.connect(lambda _c=False, p=path: self._open_recent(p))
            self.m_recent.addAction(act)
        if items:
            self.m_recent.addSeparator()
            clear = QAction("Clear Recent", self)
            clear.triggered.connect(self._clear_recent)
            self.m_recent.addAction(clear)

    def _open_recent(self, path):
        if not os.path.exists(path):
            QMessageBox.warning(
                self, "File not found",
                f"{path}\n\nIt has been removed from the recent list.")
            self._remove_recent(path)
            return
        if not self._guard_unsaved():
            return
        self._open_path(path)

    # ---- export -----------------------------------------------------

    def _export_ans(self):
        ExportAnsDialog(self.document, self).exec()

    def _export_data(self, kind):
        from studio.io.export_ans import export_ans16
        from studio.io.export_png import export_png
        from studio.io.export_targets import (
            export_asm, export_binary, export_c_header,
        )
        base = os.path.splitext(os.path.basename(self._path or "screen"))[0] or "screen"
        png_scale = 3
        if kind == "png":
            png_scale, ok = QInputDialog.getInt(
                self, "PNG scale", "Pixels per source pixel:", 3, 1, 16)
            if not ok:
                return
        nm = "space"          # how empty cells are stored
        if kind in ("bin-split", "bin-inter", "c", "asm", "ans16"):
            labels = ["space (0x20)", "NULL (0x00)", "black block (0xDB)",
                      "transparent (ANSI cursor-skip / 0x00 for binary)"]
            keys = ["space", "null", "block", "transparent"]
            choice, ok = QInputDialog.getItem(
                self, "Empty cells", "How to store cells no layer fills:",
                labels, 0, False)
            if not ok:
                return
            nm = keys[labels.index(choice)]
        spec = {
            "bin-split": ("Raw binary (*.bin)", ".bin",
                          lambda: export_binary(self.document, layout="split",
                                                null_mode=nm)),
            "bin-inter": ("Raw binary (*.bin)", ".bin",
                          lambda: export_binary(self.document, layout="interleaved",
                                                null_mode=nm)),
            "c": ("C header (*.h)", ".h",
                  lambda: export_c_header(self.document, name=base, null_mode=nm)),
            "asm": ("ASM data (*.asm)", ".asm",
                    lambda: export_asm(self.document, name=base, null_mode=nm)),
            "ans16": ("ANSI text (*.ans)", ".ans",
                      lambda: export_ans16(self.document, null_mode=nm).data),
            "png": ("PNG image (*.png)", ".png",
                    lambda: export_png(self.document, self.fontrom, scale=png_scale)),
        }[kind]
        flt, ext, build = spec
        path, _ = QFileDialog.getSaveFileName(
            self, "Export", (self._path_dir() + base + ext), flt)
        if not path:
            return
        if not os.path.splitext(path)[1]:
            path += ext
        try:
            payload = build()
            mode = "wb" if isinstance(payload, bytes) else "w"
            with open(path, mode) as fh:
                fh.write(payload)
        except Exception as exc:  # noqa: BLE001 -- surfaced to the user
            QMessageBox.critical(self, "Export failed", str(exc))
            return
        self.statusBar().showMessage(f"Exported {os.path.basename(path)}", 4000)

    def _path_dir(self):
        return (os.path.dirname(self._path) + os.sep) if self._path else ""

    # ---- quit guard -----------------------------------------------------

    def closeEvent(self, event):
        if self._guard_unsaved():
            event.accept()
        else:
            event.ignore()

    def createPopupMenu(self):
        # Suppress the right-click "hide/show toolbars & docks" menu -- the
        # rail is fixed; panel visibility is on View > Panels.
        return None

    def showEvent(self, event):
        super().showEvent(event)
        if not self._sized_once:
            self._sized_once = True
            self._grow_to_show_canvas()

    def _grow_to_show_canvas(self):
        """After the first layout, if the canvas viewport still clips the whole
        64x60 grid at 2x, grow the window by exactly the shortfall (clamped to
        the screen) and recentre it."""
        from PySide6.QtGui import QGuiApplication

        vp = self.canvas.viewport().size()
        need = self.canvas.content_pixel_size()
        grow_w = max(0, need.width() - vp.width() + 4)
        grow_h = max(0, need.height() - vp.height() + 4)
        if not (grow_w or grow_h):
            return
        screen = QGuiApplication.primaryScreen()
        if screen is None:
            return
        avail = screen.availableGeometry()
        w = min(self.width() + grow_w, avail.width())
        h = min(self.height() + grow_h, avail.height())
        self.resize(w, h)
        fg = self.frameGeometry()
        fg.moveCenter(avail.center())
        self.move(fg.topLeft())

    # ------------------------------------------------------------- actions

    def _about(self):
        QMessageBox.about(
            self, "About Odyssey ANSI Studio",
            "Odyssey ANSI Studio\n\n"
            "A layer-based text-mode graphics editor for the Wire Wrap Odyssey: "
            "64x60 cells, one CP437 glyph and one 6-bit color per cell, no "
            "background.\n\n"
            "Projects save as .oas; export targets the Odyssey-native "
            "ESC[<v>p .ANS form.",
        )

    def _set_font_bank(self, index):
        """Bank is a document property; switching only re-renders."""
        idx = int(index) & 0x0F
        changed = idx != self.document.font_bank
        self.document.font_bank = idx
        self._sync_font_bank_actions()
        if self.glyph_picker.bank_index() != idx:
            self.glyph_picker.set_bank(idx)
        self.canvas.refresh()
        if changed:
            self.mark_dirty()

    def _sync_font_bank_actions(self):
        idx = self.document.font_bank & 0x0F
        a = self._bank_actions[idx]
        a.blockSignals(True)
        a.setChecked(True)
        a.blockSignals(False)

    def _set_blink_preview(self, on):
        on = bool(on)
        self.canvas.set_blink_preview(on)
        for w in (self.act_blink_preview, self.btn_blink):
            w.blockSignals(True)
            w.setChecked(on)
            w.blockSignals(False)

    def _set_grid(self, on):
        on = bool(on)
        self.canvas.set_show_grid(on)
        for w in (self.act_show_grid, self.btn_grid):
            w.blockSignals(True)
            w.setChecked(on)
            w.blockSignals(False)

    def _set_transparency(self, on):
        on = bool(on)
        self.canvas.set_show_transparency(on)
        for w in (self.act_show_trans, self.btn_trans):
            w.blockSignals(True)
            w.setChecked(on)
            w.blockSignals(False)

    def _set_rulers(self, on):
        on = bool(on)
        self.canvas.set_show_rulers(on)
        self.act_show_rulers.blockSignals(True)
        self.act_show_rulers.setChecked(on)
        self.act_show_rulers.blockSignals(False)

    def _on_zoom_changed(self, z):
        self.lbl_zoom.setText(f"×{z}")

    # ---------------------------------------------------------- hover wiring

    @staticmethod
    def _flag_text(attr):
        if attr is None:
            return "—"
        parts = []
        if attr_blink(attr):
            parts.append("blink")
        if attr_cursor(attr):
            parts.append("cursor")
        return "+".join(parts) if parts else "none"

    def _owning_layer_name(self, col, row):
        for layer in reversed(self.document.layers):
            if layer.visible and layer.get(col, row) is not None:
                return layer.name
        return "—"

    def preview_cell(self, col, row):
        cell = self.document.composite_cell(col, row)
        self._on_cell_hovered(col, row, cell)

    def _on_cell_hovered(self, col, row, cell):
        off = row * self.document.width + col
        char_addr = 0x4000 + off
        attr_addr = 0x5000 + off

        if cell is None:
            char_txt = "—"
            attr_txt = "—"
            flags = "—"
        else:
            char_txt = f"0x{cell.glyph:02X} {glyph_name(cell.glyph)}"
            attr_txt = f"0x{cell.attr:02X}"
            flags = self._flag_text(cell.attr)

        self.sb_pos.setText(f"{col},{row}")
        self.sb_char_addr.setText(f"0x{char_addr:04X}")
        self.sb_attr_addr.setText(f"0x{attr_addr:04X}")
        self.sb_char.setText(f"char {char_txt}")
        self.sb_attr.setText(f"attr {attr_txt}")
        self.sb_flags.setText(flags)

        self._readout.setText("\n".join([
            f"plane  0x{char_addr:04X}",
            f"attr   0x{attr_addr:04X}",
            f"cell   {col},{row}  (off {off})",
            f"char   {char_txt}",
            f"attr   {attr_txt}",
            f"flags  {flags}",
        ]))

        self.inspector.show_hover(
            col, row, cell, self._owning_layer_name(col, row))

    # ----------------------------------------------------------- doc swap

    def _load_document(self, document):
        self.document = document
        self.history = History(document)
        self._ctx.document = document
        self._ctx.history = self.history
        self._controller.set_tool(self._controller.tool or self._tools["select"])
        self._selected_layer_index = document.active_layer_index
        self._selected_cell = None
        self.inspector.clear_selection()
        self.canvas.set_caret(None)
        self.canvas.set_document(document)
        self._sync_font_bank_actions()
        self.glyph_picker.set_bank(document.font_bank & 0x0F)
        self.palette_panel.set_document(document)
        self.layers_panel.set_document(document)
        self._sync_undo_actions()
        if self.canvas.bank_error():
            self.statusBar().showMessage(
                "Font assets not found — rendering with a blank bank. "
                + self.canvas.bank_error(), 8000)
