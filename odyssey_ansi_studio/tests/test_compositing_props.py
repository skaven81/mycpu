"""
Adversarial model tests: property-style compositing, off-canvas layers,
merge_down / flatten corner cases, from_dict degradation, history
interleaving, and JSON round-trip idempotency.

New file (QA hardening pass, Phases 0-2).  Named for its single most
important subject -- the compositing invariant -- but also the home for the
other model-level adversarial cases, since the QA brief only sanctions two
new test files.
"""

import json
import random

import pytest

from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.history import CellEditCommand, History
from studio.model.layers import BlankLayer, BoxLayer, Layer, TextLayer


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

def _brute_composite(doc):
    """Independent reference compositor.

    For each (col, row) walk layers top -> bottom; the first *visible* layer
    with a cell there supplies glyph+attr (masked to a byte).  Deliberately
    does NOT call Document.composite / composite_cell.
    """
    w, h = doc.width, doc.height
    char = bytearray(w * h)
    color = bytearray(w * h)
    for row in range(h):
        for col in range(w):
            for layer in reversed(doc.layers):
                if not layer.visible:
                    continue
                cell = layer.cells.get((col - layer.offx, row - layer.offy))
                if cell is not None:
                    off = row * w + col
                    char[off] = cell.glyph & 0xFF
                    color[off] = cell.attr & 0xFF
                    break
    return bytes(char), bytes(color)


def _random_layer(rng, name):
    layer = BlankLayer(name=name)
    # offsets that regularly push cells off every edge
    layer.offx = rng.randint(-8, 66)
    layer.offy = rng.randint(-8, 62)
    layer.visible = rng.random() > 0.25
    n_cells = rng.randint(0, 40)
    for _ in range(n_cells):
        lc = rng.randint(-4, 68)
        lr = rng.randint(-4, 64)
        layer.cells[(lc, lr)] = Cell(rng.randint(0, 255), rng.randint(0, 255))
    return layer


# --------------------------------------------------------------------------
# property-style compositing
# --------------------------------------------------------------------------

def test_composite_matches_brute_force_reference():
    rng = random.Random(0xC0FFEE)
    for _ in range(50):
        doc = Document()
        for i in range(rng.randint(2, 5)):
            doc.add_layer(_random_layer(rng, f"L{i}"))
        got = doc.composite()
        assert got == _brute_composite(doc)
        # planes are exactly one byte per cell
        assert len(got[0]) == doc.width * doc.height
        assert len(got[1]) == doc.width * doc.height


def test_composite_cell_matches_planes():
    rng = random.Random(1234)
    doc = Document()
    for i in range(4):
        doc.add_layer(_random_layer(rng, f"L{i}"))
    char, color = doc.composite()
    for row in range(doc.height):
        for col in range(doc.width):
            off = row * doc.width + col
            c = doc.composite_cell(col, row)
            if c is None:
                assert char[off] == 0 and color[off] == 0
            else:
                assert char[off] == c.glyph & 0xFF
                assert color[off] == c.attr & 0xFF


# --------------------------------------------------------------------------
# off-canvas layers
# --------------------------------------------------------------------------

def test_layer_wholly_and_partly_off_canvas():
    doc = Document()
    # wholly off the left/top
    far = BlankLayer(name="far", offx=-200, offy=-200)
    far.set_local(0, 0, Cell(0x41, 0x0F))
    far.set_local(5, 5, Cell(0x42, 0x0F))
    # straddling the right/bottom edges
    edge = BlankLayer(name="edge", offx=60, offy=57)
    for lc in range(8):
        for lr in range(8):
            edge.set_local(lc, lr, Cell(0x23, 0x30))
    doc.add_layer(far)
    doc.add_layer(edge)

    char, color = doc.composite()  # must not raise
    assert len(char) == doc.width * doc.height

    # only the in-bounds part of `edge` shows
    for row in range(doc.height):
        for col in range(doc.width):
            off = row * doc.width + col
            inside_edge = 60 <= col < 64 and 57 <= row < 60
            if inside_edge:
                assert char[off] == 0x23 and color[off] == 0x30
            else:
                assert char[off] == 0 and color[off] == 0

    # negative-offset cells never appear
    assert doc.composite().count(b"\x41") == 0


def test_offsets_pushing_past_last_row_col():
    doc = Document()
    layer = BlankLayer(name="p")
    layer.set_local(0, 0, Cell(0x58, 0x2A))
    doc.add_layer(layer)
    layer.offx, layer.offy = 63, 59
    char, _ = doc.composite()
    assert char[59 * 64 + 63] == 0x58
    # one cell past the corner -> nothing, no raise
    layer.offx, layer.offy = 64, 60
    char, color = doc.composite()
    assert char == bytes(doc.width * doc.height)
    assert color == bytes(doc.width * doc.height)


# --------------------------------------------------------------------------
# merge_down
# --------------------------------------------------------------------------

def test_merge_down_different_offsets_overlap_upper_wins():
    doc = Document()
    lower = BlankLayer(name="lower", offx=2, offy=1)
    upper = BlankLayer(name="upper", offx=-3, offy=4)
    # both contribute a cell at doc (10, 10)
    lower.set(10, 10, Cell(ord("L"), 0x11))
    upper.set(10, 10, Cell(ord("U"), 0x22))
    lower.set(11, 10, Cell(ord("l"), 0x13))   # lower-only
    upper.set(12, 10, Cell(ord("u"), 0x24))   # upper-only
    doc.add_layer(lower)
    doc.add_layer(upper)

    before = doc.composite()
    doc.merge_down(1)

    assert len(doc.layers) == 1
    assert doc.composite() == before                 # composite unchanged
    merged = doc.layers[0]
    assert merged.get(10, 10) == Cell(ord("U"), 0x22)  # upper won the overlap
    assert merged.get(11, 10) == Cell(ord("l"), 0x13)
    assert merged.get(12, 10) == Cell(ord("u"), 0x24)
    assert merged.offx == 2 and merged.offy == 1       # lower keeps its origin


@pytest.mark.parametrize("bad", [0, -1])
def test_merge_down_zero_or_negative_raises(bad):
    doc = Document()
    doc.add_layer(BlankLayer(name="a"))
    doc.add_layer(BlankLayer(name="b"))
    with pytest.raises(IndexError):
        doc.merge_down(bad)


def test_merge_down_at_len_raises():
    doc = Document()
    doc.add_layer(BlankLayer(name="a"))
    doc.add_layer(BlankLayer(name="b"))
    with pytest.raises(IndexError):
        doc.merge_down(len(doc.layers))
    with pytest.raises(IndexError):
        doc.merge_down(len(doc.layers) + 3)


# --------------------------------------------------------------------------
# flatten
# --------------------------------------------------------------------------

def test_flatten_empty_doc():
    doc = Document()
    flat = doc.flatten()          # no layers at all -- must not raise
    assert doc.layers == [flat]
    assert flat.cells == {}
    assert doc.composite() == (bytes(doc.width * doc.height),) * 2


def test_flatten_one_layer_doc():
    doc = Document()
    layer = BlankLayer(name="only")
    layer.set(1, 1, Cell(0x41, 0x0F))
    layer.set(2, 3, Cell(0x42, 0x30))
    doc.add_layer(layer)
    before = doc.composite()
    flat = doc.flatten()
    assert len(doc.layers) == 1
    assert doc.composite() == before
    assert flat.cells == {(1, 1): Cell(0x41, 0x0F), (2, 3): Cell(0x42, 0x30)}


def test_flatten_drops_invisible_top_layers_cells():
    doc = Document()
    base = BlankLayer(name="base")
    base.set(0, 0, Cell(ord("B"), 0x30))
    base.set(1, 0, Cell(ord("C"), 0x30))
    top = BlankLayer(name="top", visible=False)
    top.set(0, 0, Cell(ord("T"), 0x03))   # hidden -> must not survive flatten
    top.set(5, 5, Cell(ord("X"), 0x03))   # hidden, base has nothing here
    doc.add_layer(base)
    doc.add_layer(top)

    before = doc.composite()
    flat = doc.flatten()
    assert doc.composite() == before
    assert flat.get(0, 0) == Cell(ord("B"), 0x30)   # base showed through
    assert (5, 5) not in flat.cells                  # hidden-only cell gone
    assert flat.get(1, 0) == Cell(ord("C"), 0x30)


# --------------------------------------------------------------------------
# Document.from_dict degradation
# --------------------------------------------------------------------------

def test_from_dict_missing_layers_key():
    doc = Document.from_dict({"schema": 1})
    assert doc.layers == []
    assert doc.width == 64 and doc.height == 60


def test_from_dict_missing_project_palette():
    doc = Document.from_dict({"schema": 1, "layers": []})
    assert doc.project_palette == []


def test_from_dict_unknown_kind_degrades_to_blank_keeping_cells():
    d = {
        "schema": 1,
        "layers": [{
            "kind": "hologram",
            "name": "weird",
            "offx": 3, "offy": 4,
            "cells": [[1, 1, 0x41, 0x0F], [2, 2, 0x42, 0x30]],
        }],
    }
    doc = Document.from_dict(d)
    (layer,) = doc.layers
    assert type(layer) is BlankLayer
    assert layer.name == "weird"
    assert layer.offx == 3 and layer.offy == 4
    assert layer.get_local(1, 1) == Cell(0x41, 0x0F)
    assert layer.get_local(2, 2) == Cell(0x42, 0x30)


def test_from_dict_out_of_range_glyph_attr_behavior():
    """DOCUMENTS CURRENT BEHAVIOR -- see findings report.

    Layer.from_dict does no range check: a glyph/attr > 255 is stored
    verbatim on the Cell and survives a to_dict round-trip.  The only thing
    that clamps it is composite() (`& 0xFF`).  If input validation is added
    later this test should be updated.
    """
    d = {
        "schema": 1,
        "layers": [{
            "kind": "blank", "name": "L",
            "cells": [[0, 0, 999, 777], [1, 0, -5, -1]],
        }],
    }
    doc = Document.from_dict(d)
    layer = doc.layers[0]
    # stored verbatim (no clamp / mask / reject)
    assert layer.get_local(0, 0) == Cell(999, 777)
    assert layer.get_local(1, 0) == Cell(-5, -1)
    # round-trips stably
    assert Document.from_dict(doc.to_dict()).to_dict() == doc.to_dict()
    # composite is the only thing that masks to a byte
    char, color = doc.composite()
    assert char[0] == 999 & 0xFF and color[0] == 777 & 0xFF
    assert char[1] == (-5) & 0xFF and color[1] == (-1) & 0xFF


@pytest.mark.parametrize("payload", [[], "x", 5, 3.5, True, None])
def test_from_dict_non_object_raises_valueerror(payload):
    with pytest.raises(ValueError):
        Document.from_dict(payload)


# --------------------------------------------------------------------------
# history
# --------------------------------------------------------------------------

def test_cell_edit_command_none_transitions_roundtrip_exactly():
    doc = Document()
    layer = BlankLayer(name="L")
    layer.set_local(4, 4, Cell(ord("k"), 0x20))     # pre-existing
    doc.add_layer(layer)
    snapshot = dict(layer.cells)

    changes = {
        (1, 1): (None, Cell(ord("N"), 0x0F)),           # create
        (4, 4): (Cell(ord("k"), 0x20), None),           # delete existing
        (2, 2): (None, Cell(ord("M"), 0x30)),           # create
    }
    hist = History(doc)
    hist.push(CellEditCommand(0, changes))
    assert layer.get_local(1, 1) == Cell(ord("N"), 0x0F)
    assert (4, 4) not in layer.cells
    assert layer.get_local(2, 2) == Cell(ord("M"), 0x30)

    assert hist.undo()
    assert layer.cells == snapshot                      # byte-exact restore

    assert hist.redo()
    assert (4, 4) not in layer.cells
    assert layer.get_local(1, 1) == Cell(ord("N"), 0x0F)


def test_interleaved_undo_redo_push_truncates_redo():
    doc = Document()
    doc.add_layer(BlankLayer(name="L"))
    layer = doc.layers[0]
    hist = History(doc)

    def edit(coord, glyph):
        old = layer.get_local(*coord)
        new = Cell(glyph, 0x0F)
        hist.push(CellEditCommand(0, {coord: (old, new)}))

    edit((0, 0), 1)
    edit((1, 0), 2)
    edit((2, 0), 3)
    assert hist.undo() and hist.undo()                  # back to just (0,0)=1
    assert layer.get_local(0, 0) == Cell(1, 0x0F)
    assert layer.get_local(1, 0) is None
    assert hist.can_redo()

    edit((3, 0), 9)                                     # new push kills redo
    assert not hist.can_redo()
    assert not hist.redo()
    assert layer.get_local(3, 0) == Cell(9, 0x0F)

    # unwind everything that is still undoable
    assert hist.undo()                                  # undo (3,0)
    assert hist.undo()                                  # undo (0,0)
    assert layer.cells == {}
    assert not hist.undo()


# --------------------------------------------------------------------------
# JSON round-trip idempotency
# --------------------------------------------------------------------------

def _rich_doc():
    doc = Document(font_bank=7)
    blank = BlankLayer(name="bg", offx=1, offy=-2)
    blank.set_local(0, 0, Cell(0x41, 0x0F))
    blank.set_local(9, 3, Cell(0xDB, 0x30))
    blank.set_local(-1, -1, Cell(0x2E, 0x08))
    box = BoxLayer(name="frame", params={"style": "double", "w": 8, "h": 4})
    box.set_local(0, 0, Cell(0xC9, 0x2A))
    text = TextLayer(name="cap", text="hi\nthere", rect=(0, 0, 12, 3))
    text.set_local(1, 0, Cell(ord("h"), 0x3F))
    for lyr in (blank, box, text):
        doc.add_layer(lyr)
    doc.project_palette = [{"name": "ink", "attr": 0x3F}, {"name": "sh", "attr": 0x15}]
    doc.active_layer_index = 1
    return doc


def test_to_json_from_json_is_byte_stable():
    doc = _rich_doc()
    j1 = doc.to_json()
    j2 = Document.from_json(j1).to_json()
    j3 = Document.from_json(j2).to_json()
    assert j1 == j2 == j3


def test_to_json_from_json_is_byte_stable_with_indent():
    doc = _rich_doc()
    j1 = doc.to_json(indent=2, sort_keys=True)
    j2 = Document.from_json(j1).to_json(indent=2, sort_keys=True)
    assert j1 == j2
    # and the parsed structure is identical
    assert json.loads(j1) == json.loads(j2)
