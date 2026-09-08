"""PNG export: renders the composite to pixels via the font ROM."""

import io

import pytest
from PIL import Image

from studio.io.export_png import export_png, render_image
from studio.io.fontrom import FontRom
from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BlankLayer
from studio.model.palette import odyssey_to_rgb


@pytest.fixture(scope="module")
def rom():
    return FontRom()


def _doc():
    d = Document()
    lyr = BlankLayer(name="a")
    lyr.set_local(0, 0, Cell(0xDB, 0x30))          # full block, red
    lyr.set_local(5, 5, Cell(0x41, 0x0C))          # 'A', bright red
    lyr.set_local(9, 9, Cell(0xDB, 0x3F | 0x80))   # blinking white block
    d.add_layer(lyr)
    return d


def test_render_image_size_and_full_block_pixels(rom):
    img = render_image(_doc(), rom, scale=1)
    assert img.size == (64 * 8, 60 * 8)
    # a full block cell fills its whole 8x8 with the quantised color
    red = odyssey_to_rgb(0x30)
    assert all(img.getpixel((x, y)) == red for x in range(8) for y in range(8))
    # empty cell stays black
    assert img.getpixel((8 * 20, 8 * 20)) == (0, 0, 0)


def test_scale_is_nearest_neighbor(rom):
    img = render_image(_doc(), rom, scale=4)
    assert img.size == (64 * 32, 60 * 32)
    red = odyssey_to_rgb(0x30)
    assert img.getpixel((10, 10)) == red      # still solid inside the scaled block


def test_show_blink_false_hides_blink_cells(rom):
    on = render_image(_doc(), rom, scale=1, show_blink=True)
    off = render_image(_doc(), rom, scale=1, show_blink=False)
    x, y = 9 * 8 + 3, 9 * 8 + 3
    assert on.getpixel((x, y)) != (0, 0, 0)
    assert off.getpixel((x, y)) == (0, 0, 0)


def test_export_png_returns_valid_png_bytes(rom):
    blob = export_png(_doc(), rom, scale=2)
    assert blob[:8] == b"\x89PNG\r\n\x1a\n"
    reopened = Image.open(io.BytesIO(blob))
    assert reopened.size == (64 * 16, 60 * 16)
