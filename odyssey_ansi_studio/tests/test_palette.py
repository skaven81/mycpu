"""Palette / attr-byte tests: quantisation round-trips and ANSI-16 exactness."""

from studio.model import palette
from studio.model.palette import (
    ANSI16,
    ANSI16_BY_SGR,
    LEVELS,
    PALETTE,
    attr_rgb_idx,
    attr_to_rgb,
    make_attr,
    nearest_ansi16,
    odyssey_to_rgb,
    rgb_to_odyssey,
    with_blink,
    with_cursor,
)


def test_palette_has_64_entries():
    assert len(PALETTE) == 64
    assert LEVELS == [0, 85, 170, 255]


def test_rgb_odyssey_roundtrip_on_all_64():
    for code in range(64):
        r, g, b = PALETTE[code]
        assert rgb_to_odyssey(r, g, b) == code
        assert odyssey_to_rgb(code) == (r, g, b)


def test_known_colors():
    assert rgb_to_odyssey(255, 255, 255) == 0x3F
    assert rgb_to_odyssey(0, 0, 0) == 0x00
    assert rgb_to_odyssey(255, 0, 0) == 0x30


def test_odyssey_to_rgb_ignores_flag_bits():
    assert odyssey_to_rgb(0x3F | 0x80 | 0x40) == (255, 255, 255)


def test_ansi16_attr_to_rgb_matches_pure_rgb222():
    for attr, (sgr, name) in ANSI16.items():
        # attr_to_rgb must equal the pure RGB222 lookup for the same low 6 bits
        assert attr_to_rgb(attr) == PALETTE[attr & 0x3F], (hex(attr), name)
        # and the SGR reverse map must agree
        rev_attr, rev_name = ANSI16_BY_SGR[sgr]
        assert rev_attr == attr and rev_name == name


def test_ansi16_is_16_distinct_entries():
    assert len(ANSI16) == 16
    assert len(ANSI16_BY_SGR) == 16
    assert len(set(ANSI16.values())) == 16


def test_make_attr_attr_rgb_idx_are_inverse():
    for r in range(4):
        for g in range(4):
            for b in range(4):
                a = make_attr(r, g, b)
                assert attr_rgb_idx(a) == (r, g, b)
                assert a == (r << 4) | (g << 2) | b


def test_make_attr_flag_bits():
    a = make_attr(1, 2, 3, blink=True, cursor=True)
    assert a & 0x80 and a & 0x40
    assert attr_rgb_idx(a) == (1, 2, 3)
    assert palette.attr_blink(a) and palette.attr_cursor(a)


def test_with_blink_with_cursor_toggle_only_their_bit():
    a = 0x2A
    assert with_blink(a, True) == 0xAA
    assert with_blink(0xAA, False) == 0x2A
    assert with_cursor(a, True) == 0x6A
    assert with_cursor(0x6A, False) == 0x2A


def test_nearest_ansi16_is_identity_on_the_16_and_keeps_blink():
    for attr in ANSI16:
        assert nearest_ansi16(attr) == attr
        assert nearest_ansi16(attr | 0x80) == attr | 0x80


def test_nearest_ansi16_snaps_offpalette_color():
    # (85,85,85) bright-black is an exact ANSI-16 color (0x15).
    assert nearest_ansi16(0x15) == 0x15
    # A color not in the 16-set still resolves to one of them.
    assert nearest_ansi16(0x19) in ANSI16
