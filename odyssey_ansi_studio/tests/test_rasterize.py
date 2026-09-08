"""Box / Text rasterizers + the GeneratedLayer regenerate / divergence logic."""

import pytest

from studio.io.cp437 import BOX_STYLES
from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BoxLayer, TextLayer, layer_from_dict
from studio.model.rasterize import (
    LABEL_FLAIRS, rasterize_box, rasterize_text, wrap_text,
)


# --------------------------------------------------------------------------
# box
# --------------------------------------------------------------------------

@pytest.mark.parametrize("style", list(BOX_STYLES))
def test_box_corners_and_edges_for_every_style(style):
    s = BOX_STYLES[style]
    cells = rasterize_box({"style": style, "w": 6, "h": 4, "box_attr": 0x0F})
    assert cells[(0, 0)].glyph == s["tl"]
    assert cells[(5, 0)].glyph == s["tr"]
    assert cells[(0, 3)].glyph == s["bl"]
    assert cells[(5, 3)].glyph == s["br"]
    assert cells[(2, 0)].glyph == s["h"] and cells[(3, 3)].glyph == s["h"]
    assert cells[(0, 2)].glyph == s["v"] and cells[(5, 1)].glyph == s["v"]
    # interior is NULL by default
    assert (2, 2) not in cells
    # every cell carries the chosen attr
    assert all(c.attr == 0x0F for c in cells.values())


def test_box_interior_space_and_fill():
    sp = rasterize_box({"w": 5, "h": 5, "interior": "space", "box_attr": 0x03})
    assert sp[(2, 2)] == Cell(0x20, 0x03)
    fl = rasterize_box({"w": 5, "h": 5, "interior": "fill",
                        "fill_glyph": 0xB1, "fill_attr": 0x14})
    assert fl[(2, 2)] == Cell(0xB1, 0x14)
    assert fl[(1, 1)] == Cell(0xB1, 0x14)


def test_box_title_and_footer_placement_and_alignment():
    c = rasterize_box({"w": 20, "h": 5, "title": "HELLO", "title_align": "left",
                       "footer": "END", "footer_align": "right"})
    # title sits on row 0, inset by 2, with a leading pad space
    assert c[(2, 0)].glyph == ord(" ")
    assert "".join(chr(c[(3 + i, 0)].glyph) for i in range(5)) == "HELLO"
    # footer on the bottom row, right-aligned: " END " ends at col w-2
    assert "".join(chr(c[(20 - 1 - 5 + i, 4)].glyph) for i in range(5)) == " END "


def test_box_title_centered():
    c = rasterize_box({"w": 21, "h": 3, "title": "MID", "title_align": "center"})
    # " MID " is 5 wide, centered in 21 -> start col 8
    assert "".join(chr(c[(8 + i, 0)].glyph) for i in range(5)) == " MID "


def test_box_line_flair_uses_style_matched_junction_glyphs():
    # single box: ┤ (0xB4) left of the text, ├ (0xC3) right of it
    c = rasterize_box({"style": "single", "w": 20, "h": 3, "title": "MENU",
                       "title_align": "left", "title_flair": "line"})
    s = BOX_STYLES["single"]
    # ── ┤ M E N U ├ ──  : flair flush on the border, one space to the text
    seq = [c[(x, 0)].glyph for x in range(2, 10)]
    assert seq == [s["t_right"], ord(" "), *map(ord, "MENU"),
                   ord(" "), s["t_left"]]

    # double box: the flair follows the heavier weight -> ╣ ╠
    d = rasterize_box({"style": "double", "w": 20, "h": 3, "title": "MENU",
                       "title_flair": "line"})
    d0 = [d[(x, 0)].glyph for x in range(20) if (x, 0) in d]
    assert BOX_STYLES["double"]["t_right"] in d0        # ╣
    assert BOX_STYLES["double"]["t_left"] in d0         # ╠


def test_box_symbol_flair_is_one_glyph_each_side():
    c = rasterize_box({"w": 22, "h": 4, "footer": "OK", "footer_align": "center",
                       "footer_flair": "braces", "footer_attr": 0x2A})
    row = "".join(chr(c[(x, 3)].glyph) for x in range(22) if (x, 3) in c)
    assert "{ OK }" in row
    braces = [cell for (x, y), cell in c.items() if y == 3
              and chr(cell.glyph) in "{}"]
    assert len(braces) == 2 and all(cell.attr == 0x2A for cell in braces)


def test_box_flair_dropped_when_no_room():
    # narrow box: even a one-glyph flair won't fit, fall back to a plain label
    c = rasterize_box({"w": 8, "h": 3, "title": "HI", "title_flair": "square"})
    row0 = "".join(chr(c[(x, 0)].glyph) for x in range(1, 7) if (x, 0) in c)
    assert "HI" in row0 and "[" not in row0


def test_label_flairs_table_shape():
    assert LABEL_FLAIRS["none"] is None
    assert LABEL_FLAIRS["line"] == "line"
    assert LABEL_FLAIRS["braces"] == ("{", "}")
    assert LABEL_FLAIRS["guillemets"] == ("«", "»")


def test_box_title_truncated_to_fit():
    c = rasterize_box({"w": 8, "h": 3, "title": "TOOLONGTITLE"})
    row0 = "".join(chr(c[(x, 0)].glyph) for x in range(1, 7)
                   if (x, 0) in c and c[(x, 0)].glyph != BOX_STYLES["single"]["h"])
    assert "TOOLONG" not in row0            # clipped to w-4 == 4 chars


def test_box_shadow_sits_outside_the_frame():
    c = rasterize_box({"w": 4, "h": 3, "shadow": True})
    assert (4, 1) in c and (1, 3) in c     # right column, bottom row
    assert (0, 0) in c and c[(0, 0)].glyph == BOX_STYLES["single"]["tl"]


def test_box_degenerate_sizes():
    assert set(rasterize_box({"w": 1, "h": 4})) == {(0, 0), (0, 1), (0, 2), (0, 3)}
    assert set(rasterize_box({"w": 3, "h": 1})) == {(0, 0), (1, 0), (2, 0)}


# --------------------------------------------------------------------------
# text
# --------------------------------------------------------------------------

def test_wrap_greedy_word_wrap():
    assert wrap_text("the quick brown fox", 9) == ["the quick", "brown fox"]


def test_wrap_hard_splits_overlong_word():
    assert wrap_text("supercalifragilistic", 6) == \
        ["superc", "alifra", "gilist", "ic"]


def test_wrap_keeps_explicit_newlines():
    assert wrap_text("a\nb c d", 3) == ["a", "b c", "d"]


def test_wrap_disabled_passes_lines_through():
    assert wrap_text("a very long line indeed", 5, wrap=False) == \
        ["a very long line indeed"]


def test_rasterize_text_alignment_and_clip():
    c = rasterize_text({"text": "hi", "w": 6, "h": 2, "align": "right"})
    # "hi" right-aligned in width 6 -> cols 4,5
    assert c[(4, 0)].glyph == ord("h") and c[(5, 0)].glyph == ord("i")
    # spaces are transparent by default
    c2 = rasterize_text({"text": "a b", "w": 6, "h": 1})
    assert (1, 0) not in c2
    # opaque paints the space
    c3 = rasterize_text({"text": "a b", "w": 6, "h": 1, "opaque": True})
    assert c3[(1, 0)] == Cell(ord(" "), 0x0F)


def test_rasterize_text_height_clip():
    c = rasterize_text({"text": "l1\nl2\nl3\nl4", "w": 4, "h": 2})
    assert max(r for _c, r in c) == 1      # only 2 rows survive


# --------------------------------------------------------------------------
# GeneratedLayer machinery
# --------------------------------------------------------------------------

def test_box_layer_regenerate_populates_cells():
    b = BoxLayer(name="f", params={"w": 6, "h": 4})
    assert b.cells == {}
    b.regenerate()
    assert b.cells[(0, 0)].glyph == BOX_STYLES["single"]["tl"]
    assert b.manual_edits() is False


def test_manual_edit_detection_and_resize():
    b = BoxLayer(name="f", params={"w": 6, "h": 4})
    b.regenerate()
    b.set_local(2, 2, Cell(0x40, 0x2A))       # hand edit in the interior
    assert b.manual_edits() is True
    b.regenerate()                            # re-rasterize wins
    assert b.manual_edits() is False
    assert (2, 2) not in b.cells

    b.resize(10, 6)
    b.regenerate()
    assert b.params["w"] == 10
    assert b.cells[(9, 0)].glyph == BOX_STYLES["single"]["tr"]


def test_text_layer_roundtrip_keeps_params_and_detects_hand_edit(tmp_path):
    t = TextLayer(name="cap", offx=3, offy=4, text="alpha beta gamma",
                  rect=(3, 4, 7, 4))
    t.regenerate()
    clean = layer_from_dict(t.to_dict())
    assert isinstance(clean, TextLayer)
    assert clean.text == "alpha beta gamma"
    assert clean.rect == (3, 4, 7, 4)
    assert clean.manual_edits() is False

    t.set_local(0, 3, Cell(0x2A, 0x0F))
    dirty = layer_from_dict(t.to_dict())
    assert dirty.manual_edits() is True       # divergence survives save/load


def test_text_layer_reword_and_regenerate():
    t = TextLayer(name="cap", text="one two", rect=(0, 0, 10, 3))
    t.regenerate()
    first = dict(t.cells)
    t.text = "wholly different words here"
    t.regenerate()
    assert t.cells != first
    assert t.manual_edits() is False


def test_generated_layer_composites_like_any_layer():
    doc = Document()
    box = BoxLayer(name="frame", offx=1, offy=1, params={"w": 5, "h": 4})
    box.regenerate()
    doc.add_layer(box)
    ch, _clr = doc.composite()
    off = 1 * doc.width + 1
    assert ch[off] == BOX_STYLES["single"]["tl"]
