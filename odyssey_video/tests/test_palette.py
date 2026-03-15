import pytest
from palette import PALETTE, rgb_to_odyssey, odyssey_to_rgb


def test_palette_size():
    assert len(PALETTE) == 64


def test_black():
    assert rgb_to_odyssey(0, 0, 0) == 0x00


def test_white():
    assert rgb_to_odyssey(255, 255, 255) == 0x3F


def test_red():
    assert rgb_to_odyssey(255, 0, 0) == 0x30


def test_bright_cyan():
    # cyan = 0 red, max green, max blue
    assert rgb_to_odyssey(0, 255, 255) == 0x0F


def test_roundtrip():
    for code in range(64):
        r, g, b = odyssey_to_rgb(code)
        result = rgb_to_odyssey(r, g, b)
        assert result == code, f"Roundtrip failed for code {code:#04x}: got {result:#04x}"


def test_boundary_42_vs_43():
    # 42 rounds to 0 (42/85 = 0.494 -> round to 0)
    # 43 rounds to 1 (43/85 = 0.506 -> round to 1)
    assert rgb_to_odyssey(42, 0, 0) == 0x00
    assert rgb_to_odyssey(43, 0, 0) == 0x10


def test_boundary_127_vs_128():
    # 127/85 = 1.494 -> round to 1
    # 128/85 = 1.506 -> round to 2
    assert rgb_to_odyssey(127, 0, 0) == 0x10
    assert rgb_to_odyssey(128, 0, 0) == 0x20


def test_boundary_212_vs_213():
    # 212/85 = 2.494 -> round to 2
    # 213/85 = 2.506 -> round to 3
    assert rgb_to_odyssey(212, 0, 0) == 0x20
    assert rgb_to_odyssey(213, 0, 0) == 0x30
