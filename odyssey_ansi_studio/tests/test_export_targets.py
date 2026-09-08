"""Raw-binary / C-header / ASM export targets."""

import re

import pytest

from studio.io.export_targets import export_asm, export_binary, export_c_header
from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BlankLayer


def _doc():
    d = Document()
    lyr = BlankLayer(name="a")
    lyr.set_local(0, 0, Cell(0x41, 0x2A))
    lyr.set_local(1, 0, Cell(0xDB, 0x30 | 0x40))   # cursor bit set
    lyr.set_local(3, 2, Cell(0x07, 0x80))          # blink
    d.add_layer(lyr)
    return d


def test_binary_split_layout_lengths_and_content():
    d = _doc()
    blob = export_binary(d)
    n = d.width * d.height
    assert len(blob) == 2 * n
    char_plane, color_plane = blob[:n], blob[n:]
    assert char_plane[0] == 0x41
    assert char_plane[1] == 0xDB
    assert char_plane[2 * d.width + 3] == 0x07
    # cursor bit masked out of the color plane, blink kept
    assert color_plane[1] == 0x30
    assert color_plane[2 * d.width + 3] == 0x80


def test_binary_interleaved_layout():
    d = _doc()
    blob = export_binary(d, layout="interleaved")
    assert len(blob) == 2 * d.width * d.height
    assert blob[0] == 0x41 and blob[1] == 0x2A         # cell 0: char, color
    assert blob[2] == 0xDB and blob[3] == 0x30         # cell 1, cursor masked


def test_binary_keeps_cursor_when_asked():
    d = _doc()
    n = d.width * d.height
    blob = export_binary(d, mask_cursor=False)
    assert blob[n + 1] == (0x30 | 0x40)


def test_binary_rejects_bad_layout():
    with pytest.raises(ValueError):
        export_binary(_doc(), layout="nope")


def test_c_header_shape_and_values():
    src = export_c_header(_doc(), name="my screen")
    assert "#define MY_SCREEN_W 64" in src
    assert "#define MY_SCREEN_H 60" in src
    assert "static const unsigned char my_screen_chr[3840] = {" in src
    assert "static const unsigned char my_screen_clr[3840] = {" in src
    assert "#ifndef MY_SCREEN_H" in src and "#endif" in src
    # exactly 3840 byte literals per array
    chr_block = src.split("my_screen_chr[3840] = {")[1].split("};")[0]
    assert len(re.findall(r"0x[0-9A-F]{2}", chr_block)) == 3840
    assert "0x41" in chr_block
    clr_block = src.split("my_screen_clr[3840] = {")[1].split("};")[0]
    assert "0x40" not in clr_block            # cursor masked


def test_c_header_ident_sanitised_leading_digit():
    src = export_c_header(Document(), name="9lives")
    assert "_9lives_chr" in src


def test_asm_labels_and_byte_count():
    src = export_asm(_doc(), name="hud")
    lines = [l for l in src.splitlines() if l.startswith(":")]
    assert lines[0].startswith(":hud_chr ")
    assert lines[1].startswith(":hud_clr ")
    chr_bytes = lines[0].split()[1:]
    clr_bytes = lines[1].split()[1:]
    assert len(chr_bytes) == len(clr_bytes) == 3840
    assert all(re.fullmatch(r"0x[0-9a-f]{2}", b) for b in chr_bytes)
    assert chr_bytes[0] == "0x41"
    assert clr_bytes[1] == "0x30"             # cursor masked


def test_asm_short_name_still_valid_label():
    src = export_asm(Document(), name="x")
    # `_chr` is appended, so `:x_chr` clears the assembler's 4-char minimum
    assert re.search(r"^:x_chr ", src, re.M)
    assert re.search(r"^:x_clr ", src, re.M)


def test_empty_document_exports_are_all_zero():
    d = Document()
    assert export_binary(d) == b"\x00" * (2 * d.width * d.height)
    assert export_c_header(d).count("0x00") == 2 * d.width * d.height


# ==========================================================================
# null_mode for the fixed-size plane formats
# ==========================================================================

def test_binary_null_mode_space_and_block_replace_empty_char_byte():
    d = Document()
    lyr = BlankLayer(name="a"); lyr.set_local(0, 0, Cell(0x41, 0x0F))
    d.add_layer(lyr)
    n = d.width * d.height
    default = export_binary(d)                     # null_mode="null"
    assert default[1] == 0x00                      # empty char stays 0
    spaced = export_binary(d, null_mode="space")
    assert spaced[0] == 0x41 and spaced[1] == 0x20
    assert spaced[n:] == default[n:]               # color plane unchanged
    blocked = export_binary(d, null_mode="block")
    assert blocked[1] == 0xDB


def test_c_and_asm_honour_null_mode():
    d = Document()
    d.add_layer(BlankLayer(name="a"))
    c = export_c_header(d, name="s", null_mode="space")
    chr_block = c.split("s_chr[3840] = {")[1].split("};")[0]
    assert "0x20" in chr_block and "0x00" not in chr_block
    a = export_asm(d, name="s", null_mode="block")
    chr_line = [l for l in a.splitlines() if l.startswith(":s_chr")][0]
    assert set(chr_line.split()[1:]) == {"0xdb"}
