import pytest
from PIL import Image

from color_converter import image_to_color_frame
from common import DISPLAY_W


def make_solid(width, height, color):
    """Create a solid-color PIL Image."""
    return Image.new("RGB", (width, height), color)


def test_output_size_4x3():
    # 480x360 -> proportional height = round(360*64/480) = 48
    img = make_solid(480, 360, (128, 128, 128))
    result = image_to_color_frame(img)
    assert len(result) == DISPLAY_W * 48  # 3072


def test_output_size_16x9():
    # 640x360 -> proportional height = round(360*64/640) = round(36) = 36
    img = make_solid(640, 360, (128, 128, 128))
    result = image_to_color_frame(img)
    assert len(result) == DISPLAY_W * 36  # 2304


def test_multiple_of_128():
    for (w, h) in [(480, 360), (640, 360), (1280, 720), (320, 240)]:
        img = make_solid(w, h, (100, 100, 100))
        result = image_to_color_frame(img)
        assert len(result) % 128 == 0, f"{w}x{h} -> {len(result)} not multiple of 128"


def test_black_image():
    img = make_solid(480, 360, (0, 0, 0))
    result = image_to_color_frame(img)
    assert all(b == 0x00 for b in result)


def test_white_image():
    img = make_solid(480, 360, (255, 255, 255))
    result = image_to_color_frame(img)
    assert all(b == 0x3F for b in result)


def test_red_image():
    img = make_solid(480, 360, (255, 0, 0))
    result = image_to_color_frame(img)
    assert all(b == 0x30 for b in result)


def test_no_letterboxing():
    # 4:3 source (480x360) should produce height=48, not 60
    img = make_solid(480, 360, (50, 50, 50))
    result = image_to_color_frame(img)
    # 3072 / 64 = 48 (not padded to 3840 for height 60)
    assert len(result) == DISPLAY_W * 48


def test_explicit_height_override():
    img = make_solid(640, 480, (0, 255, 0))
    result = image_to_color_frame(img, height=32)
    assert len(result) == DISPLAY_W * 32  # 2048
