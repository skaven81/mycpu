"""Document compositing, layer offsets, merge/flatten, and serialization."""

from studio.model.cell import Cell
from studio.model.document import (
    HEIGHT,
    PLANE_SIZE,
    WIDTH,
    Document,
    new_blank_document,
)
from studio.model.layers import BlankLayer


def test_dimensions():
    assert WIDTH == 64 and HEIGHT == 60
    assert PLANE_SIZE == 3840


def test_empty_doc_composites_to_zero_planes():
    doc = new_blank_document()
    char_plane, color_plane = doc.composite()
    assert len(char_plane) == 3840 and len(color_plane) == 3840
    assert char_plane == bytes(3840)
    assert color_plane == bytes(3840)


def _two_layer_doc():
    doc = Document()
    bottom = BlankLayer(name="bottom")
    bottom.set(0, 0, Cell(ord("B"), 0x30))
    bottom.set(1, 0, Cell(ord("X"), 0x0C))
    top = BlankLayer(name="top")
    top.set(0, 0, Cell(ord("T"), 0x03))
    doc.add_layer(bottom)
    doc.add_layer(top)  # top is last -> on top
    return doc


def test_layer_order_top_wins_per_cell():
    doc = _two_layer_doc()
    assert doc.composite_cell(0, 0) == Cell(ord("T"), 0x03)  # top overrides
    assert doc.composite_cell(1, 0) == Cell(ord("X"), 0x0C)  # only bottom
    assert doc.composite_cell(5, 5) is None

    char_plane, color_plane = doc.composite()
    assert char_plane[0] == ord("T") and color_plane[0] == 0x03
    assert char_plane[1] == ord("X") and color_plane[1] == 0x0C
    assert char_plane[2] == 0 and color_plane[2] == 0


def test_invisible_layer_does_not_contribute():
    doc = _two_layer_doc()
    doc.layers[-1].visible = False
    assert doc.composite_cell(0, 0) == Cell(ord("B"), 0x30)


def test_layer_offset_shifts_contribution():
    doc = Document()
    layer = BlankLayer(name="a")
    layer.set(0, 0, Cell(ord("Q"), 0x2A))
    doc.add_layer(layer)
    assert doc.composite_cell(0, 0) == Cell(ord("Q"), 0x2A)

    layer.translate(3, 2)
    assert doc.composite_cell(0, 0) is None
    assert doc.composite_cell(3, 2) == Cell(ord("Q"), 0x2A)
    # local cell data is untouched by the move
    assert layer.get_local(0, 0) == Cell(ord("Q"), 0x2A)


def test_merge_down_preserves_composite():
    doc = _two_layer_doc()
    before = doc.composite()
    doc.merge_down(1)
    assert len(doc.layers) == 1
    assert doc.composite() == before


def test_merge_down_offsets_respected():
    doc = Document()
    lower = BlankLayer(name="lower")
    lower.set(10, 10, Cell(ord("L"), 0x11))
    upper = BlankLayer(name="upper")
    upper.set(0, 0, Cell(ord("U"), 0x22))
    upper.translate(20, 20)  # U now lives at doc (20,20)
    doc.add_layer(lower)
    doc.add_layer(upper)
    before = doc.composite()
    doc.merge_down(1)
    assert doc.composite() == before
    assert doc.layers[0].get(20, 20) == Cell(ord("U"), 0x22)
    assert doc.layers[0].get(10, 10) == Cell(ord("L"), 0x11)


def test_flatten_preserves_composite():
    doc = _two_layer_doc()
    before = doc.composite()
    flat = doc.flatten()
    assert len(doc.layers) == 1 and doc.layers[0] is flat
    assert doc.composite() == before
    # empty cells stayed NULL, not spaces
    assert (2, 0) not in flat.cells


def test_to_from_dict_roundtrip_is_lossless():
    doc = _two_layer_doc()
    doc.font_bank = 5
    doc.project_palette = [{"name": "ink", "attr": 0x3F}, {"name": "shadow", "attr": 0x15}]
    doc.active_layer_index = 1

    d = doc.to_dict()
    clone = Document.from_dict(d)

    assert clone.to_dict() == d
    assert clone.composite() == doc.composite()
    assert clone.font_bank == 5
    assert clone.project_palette == doc.project_palette
    assert clone.active_layer_index == 1


def test_to_from_json_roundtrip():
    doc = _two_layer_doc()
    clone = Document.from_json(doc.to_json())
    assert clone.composite() == doc.composite()
    assert clone.to_dict() == doc.to_dict()


def test_from_dict_rejects_unknown_schema():
    import pytest

    with pytest.raises(ValueError):
        Document.from_dict({"schema": 99, "layers": []})


def test_layer_subclass_survives_roundtrip():
    from studio.model.layers import BoxLayer, TextLayer

    doc = Document()
    box = BoxLayer(name="frame", params={"style": "double", "w": 10, "h": 4})
    txt = TextLayer(name="caption", text="hello\nworld", rect=(2, 2, 8, 3))
    doc.add_layer(box)
    doc.add_layer(txt)
    clone = Document.from_dict(doc.to_dict())
    assert isinstance(clone.layers[0], BoxLayer)
    # params now carry the full default set; the set values survive
    assert clone.layers[0].params["style"] == "double"
    assert clone.layers[0].params["w"] == 10
    assert clone.layers[0].params["h"] == 4
    assert clone.layers[0].params == doc.layers[0].params
    assert isinstance(clone.layers[1], TextLayer)
    assert clone.layers[1].text == "hello\nworld"
    assert clone.layers[1].rect == (2, 2, 8, 3)


# ==========================================================================
# Layer groups (display + visibility)
# ==========================================================================

def test_group_hides_members_from_composite():
    from studio.model.layers import BlankLayer
    doc = Document()
    a = BlankLayer(name="a"); a.set_local(0, 0, Cell(0x41, 0x0F))
    b = BlankLayer(name="b"); b.set_local(1, 0, Cell(0x42, 0x0F))
    doc.add_layer(a); doc.add_layer(b)
    doc.set_layer_group(1, "hud")
    assert doc.composite_cell(1, 0).glyph == 0x42

    doc.set_group_visible("hud", False)
    assert doc.composite_cell(1, 0) is None          # member hidden
    assert doc.composite_cell(0, 0).glyph == 0x41    # ungrouped layer unaffected
    ch, _clr = doc.composite()
    assert ch[1] == 0x00

    doc.set_group_visible("hud", True)
    assert doc.composite_cell(1, 0).glyph == 0x42


def test_group_roundtrips_through_to_dict():
    from studio.model.layers import BlankLayer
    doc = Document()
    for nm in ("a", "b", "c"):
        doc.add_layer(BlankLayer(name=nm))
    doc.set_layer_group(0, "grp")
    doc.set_layer_group(2, "grp")
    doc.set_group_visible("grp", False)
    doc.set_group_collapsed("grp", True)

    clone = Document.from_dict(doc.to_dict())
    assert [l.group for l in clone.layers] == ["grp", None, "grp"]
    assert clone.groups["grp"] == {"visible": False, "collapsed": True}
    assert clone.to_dict() == doc.to_dict()


def test_prune_drops_empty_group_and_ungroup_clears():
    from studio.model.layers import BlankLayer
    doc = Document()
    doc.add_layer(BlankLayer(name="a")); doc.add_layer(BlankLayer(name="b"))
    doc.set_layer_group(0, "g")
    doc.set_layer_group(1, "g")
    doc.set_layer_group(0, None)
    assert doc.layers[0].group is None
    assert "g" in doc.groups                          # b still in it
    doc.set_layer_group(1, None)
    assert doc.groups == {}                           # pruned


def test_rename_group():
    from studio.model.layers import BlankLayer
    doc = Document()
    doc.add_layer(BlankLayer(name="a")); doc.set_layer_group(0, "old")
    doc.set_group_collapsed("old", True)
    doc.rename_group("old", "new")
    assert doc.layers[0].group == "new"
    assert doc.groups["new"]["collapsed"] is True
    assert "old" not in doc.groups
