"""Headless tests for the .F08 font-ROM loader."""

import pytest

from studio.io.fontrom import BANKS, FontRom, parse_f08


def test_parse_f08_shape():
    data = bytes(range(256)) * 8  # 2048 bytes
    glyphs = parse_f08(data)
    assert len(glyphs) == 256
    assert all(isinstance(g, bytes) and len(g) == 8 for g in glyphs)
    assert glyphs[0] == data[0:8]
    assert glyphs[1] == data[8:16]
    assert glyphs[255] == data[255 * 8:256 * 8]


@pytest.mark.parametrize("bad", [b"", b"\x00" * 100, b"\x00" * 2047, b"\x00" * 4096])
def test_parse_f08_rejects_wrong_length(bad):
    with pytest.raises(ValueError):
        parse_f08(bad)


def test_banks_table():
    assert len(BANKS) == 16
    assert [b["index"] for b in BANKS] == list(range(16))
    assert BANKS[0]["name"] == "IBM PC CGA"
    assert BANKS[7]["name"].startswith("Eagle Spirit")
    # slots 8..15 repeat 0..7
    for i in range(8):
        assert BANKS[i + 8]["path"] == BANKS[i]["path"]
        assert BANKS[i + 8]["name"] == BANKS[i]["name"]


def test_blank_bank_is_all_zero():
    bank = FontRom.blank_bank()
    assert bank.name == "(blank)"
    assert bank.glyph_bits(0x41) == b"\x00" * 8
    assert bank.glyph_bits(0xFF) == b"\x00" * 8


def test_missing_bank_raises_named_error(tmp_path):
    rom = FontRom(repo_root=str(tmp_path))  # no bitmapfont/ under here
    with pytest.raises(FileNotFoundError) as exc:
        rom.load_bank(0)
    assert "CGA.F08" in str(exc.value)


def test_load_real_bank_if_assets_present():
    rom = FontRom()
    try:
        bank = rom.load_bank(0)
    except FileNotFoundError:
        pytest.skip("bitmapfont assets not present in this checkout")
    assert bank.name == "IBM PC CGA"
    bits = bank.glyph_bits(0x41)  # 'A'
    assert len(bits) == 8
    assert any(bits), "glyph 'A' should have lit pixels"
    # cached tile
    img = bank.glyph_image(0x41, (255, 0, 0))
    assert img.width() == 8 and img.height() == 8
    assert bank.glyph_image(0x41, (255, 0, 0)) is img  # per (code, rgb) cache
    assert rom.load_bank(0) is bank  # bank cache
