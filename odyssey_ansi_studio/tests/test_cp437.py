"""CP437 table completeness, round-trip, and box-style sanity."""

from studio.io.cp437 import (
    BOX_CORE_KEYS,
    BOX_STYLES,
    CP437_TO_UNICODE,
    GLYPH_NAMES,
    UNICODE_TO_CP437,
    glyph_name,
    is_control_glyph,
)


def test_table_length_is_256():
    assert len(CP437_TO_UNICODE) == 256


def test_ascii_range_is_identity():
    for c in range(0x20, 0x7F):
        assert CP437_TO_UNICODE[c] == chr(c)


def test_reverse_roundtrip_for_unique_chars():
    from collections import Counter

    counts = Counter(CP437_TO_UNICODE)
    for c in range(256):
        ch = CP437_TO_UNICODE[c]
        if counts[ch] == 1:
            assert UNICODE_TO_CP437[ch] == c, (c, repr(ch))


def test_reverse_map_covers_every_char():
    for ch in CP437_TO_UNICODE:
        assert ch in UNICODE_TO_CP437


def test_known_glyphs():
    assert CP437_TO_UNICODE[0xDB] == "█"  # full block
    assert CP437_TO_UNICODE[0xB0] == "░"  # light shade
    assert CP437_TO_UNICODE[0x7F] == "⌂"  # house
    assert CP437_TO_UNICODE[0x00] == "\x00"  # NUL position


def test_glyph_name_fallback():
    assert glyph_name(0x20) == "space"
    assert glyph_name(0xDB) == "full block"
    # a code with no explicit name -> hex label
    assert glyph_name(0x41) == "0x41"
    for code, name in GLYPH_NAMES.items():
        assert glyph_name(code) == name


def test_box_styles_have_core_keys_and_valid_codes():
    assert BOX_CORE_KEYS == ("tl", "tr", "bl", "br", "h", "v")
    for style_name, members in BOX_STYLES.items():
        for key in BOX_CORE_KEYS:
            assert key in members, (style_name, key)
        for key, code in members.items():
            assert isinstance(code, int) and 0 <= code <= 255, (style_name, key, code)


def test_box_styles_include_named_sets():
    for name in ("single", "double", "single_h_double_v",
                 "double_h_single_v", "block"):
        assert name in BOX_STYLES
    assert BOX_STYLES["single"]["tl"] == 0xDA
    assert BOX_STYLES["double"]["tl"] == 0xC9
    assert set(BOX_STYLES["block"].values()) == {0xDB}


def test_is_control_glyph():
    assert is_control_glyph(0x00)
    assert is_control_glyph(0x1F)
    assert is_control_glyph(0x7F)
    assert not is_control_glyph(0x20)
    assert not is_control_glyph(0xDB)
