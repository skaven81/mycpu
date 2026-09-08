"""
Adversarial edge-case tests for studio.io.cp437 and studio.io.fontrom.

New file (QA hardening pass, Phases 0-2).
"""

import pytest

from studio.io.cp437 import BOX_STYLES, CP437_TO_UNICODE, UNICODE_TO_CP437
from studio.io.fontrom import BANKS, F08_SIZE, FontRom, parse_f08


# --------------------------------------------------------------------------
# cp437: box styles are real box glyphs, and the reverse map is a true
# inverse over every code any box style uses.
# --------------------------------------------------------------------------

# Unicode we expect for the four corners of the two primary styles -- a spot
# check that the codes really are corner glyphs, not "some byte in range".
_CORNER_EXPECT = {
    ("single", "tl"): "┌",  # U+250C BOX DRAWINGS LIGHT DOWN AND RIGHT
    ("single", "tr"): "┐",
    ("single", "bl"): "└",
    ("single", "br"): "┘",
    ("double", "tl"): "╔",
    ("double", "tr"): "╗",
    ("double", "bl"): "╚",
    ("double", "br"): "╝",
}

# Unicode blocks that count as "sensible" for a line-drawing set member.
_BOX_DRAWING = range(0x2500, 0x2580)   # box drawing
_BLOCK_ELEMENTS = range(0x2580, 0x25A0)  # block elements (block style uses U+2588)


def test_box_style_corners_are_corner_glyphs():
    for (style, key), want in _CORNER_EXPECT.items():
        code = BOX_STYLES[style][key]
        assert CP437_TO_UNICODE[code] == want, (style, key, hex(code))


def test_every_box_style_member_is_a_box_or_block_glyph():
    for style, members in BOX_STYLES.items():
        for key, code in members.items():
            assert 0 <= code <= 255, (style, key, code)
            uni = CP437_TO_UNICODE[code]
            cp = ord(uni)
            assert cp in _BOX_DRAWING or cp in _BLOCK_ELEMENTS, (
                style, key, hex(code), uni
            )


def test_unicode_to_cp437_is_true_inverse_on_box_glyphs():
    for style, members in BOX_STYLES.items():
        for key, code in members.items():
            uni = CP437_TO_UNICODE[code]
            assert UNICODE_TO_CP437[uni] == code, (style, key, hex(code), uni)


# --------------------------------------------------------------------------
# fontrom.parse_f08 length handling
# --------------------------------------------------------------------------

@pytest.mark.parametrize("n", [0, 1, 2047, 2049, 4096])
def test_parse_f08_rejects_non_2048(n):
    with pytest.raises(ValueError):
        parse_f08(b"\x00" * n)


def test_parse_f08_exactly_2048_returns_256x8():
    data = bytes((i * 7) & 0xFF for i in range(F08_SIZE))
    glyphs = parse_f08(data)
    assert len(glyphs) == 256
    assert all(len(g) == 8 for g in glyphs)
    assert b"".join(glyphs) == data


# --------------------------------------------------------------------------
# fontrom.FontRom / Bank
# --------------------------------------------------------------------------

def _rom_or_skip():
    rom = FontRom()
    try:
        rom.load_bank(0)
    except FileNotFoundError:
        pytest.skip("bitmapfont/*.F08 assets not present in this checkout")
    return rom


def test_load_bank_caches_same_object():
    rom = _rom_or_skip()
    first = rom.load_bank(1)
    second = rom.load_bank(1)
    assert first is second


def test_bank_index_wraps_mod_16():
    rom = _rom_or_skip()
    for i in range(16):
        assert rom.load_bank(i) is rom.load_bank(i + 16)
        assert rom.load_bank(i) is rom.load_bank(i + 160)


def test_bank_index_wraps_even_without_assets():
    # index 16 must resolve to slot 0's asset path, not raise IndexError
    rom = FontRom(repo_root="/no/such/place/at/all")
    with pytest.raises(FileNotFoundError) as ei:
        rom.load_bank(16)
    assert "CGA.F08" in str(ei.value)          # slot 0's file
    assert BANKS[0]["name"] in str(ei.value)


def test_blank_bank_glyph_bits_all_zero_for_every_index():
    bank = FontRom.blank_bank()
    for x in list(range(256)) + [256, 257, 511, -1]:
        assert bank.glyph_bits(x) == b"\x00" * 8


def test_bogus_repo_root_raises_filenotfound_naming_the_path():
    rom = FontRom(repo_root="/definitely/not/a/real/repo")
    with pytest.raises(FileNotFoundError) as ei:
        rom.load_bank(0)
    msg = str(ei.value)
    assert "/definitely/not/a/real/repo/bitmapfont" in msg
    assert msg.rstrip().endswith("CGA.F08")


def test_blank_bank_glyph_image_is_transparent():
    # guarded implicitly by the suite's QT_QPA_PLATFORM=offscreen
    bank = FontRom.blank_bank()
    img = bank.glyph_image(0x41, (255, 0, 0))
    assert img.width() == 8 and img.height() == 8
    assert all(img.pixelColor(x, y).alpha() == 0
               for x in range(8) for y in range(8))
    # cached per (code, rgb)
    assert bank.glyph_image(0x41, (255, 0, 0)) is img
    assert bank.glyph_image(0x41, (0, 255, 0)) is not img
