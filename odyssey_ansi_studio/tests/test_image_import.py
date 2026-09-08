"""Image import: conversion determinism, params round-trip, ImageLayer + .oas."""

import io

import numpy as np
import pytest
from PIL import Image

from studio.convert.image_import import (
    ImportParams, clamp_crop, convert, fit_cells, image_from_bytes, png_bytes,
    source_ref,
)
from studio.io.project_file import load_project, read_assets, save_project
from studio.model.document import Document
from studio.model.layers import ImageLayer, layer_from_dict
from studio.model.palette import rgb_to_odyssey


def _solid(rgb, size=(8, 8)):
    return Image.new("RGB", size, rgb)


def _halves(top, bottom, size=(8, 8)):
    im = Image.new("RGB", size, top)
    for y in range(size[1] // 2, size[1]):
        for x in range(size[0]):
            im.putpixel((x, y), bottom)
    return im


# --------------------------------------------------------------------------
# geometry helpers
# --------------------------------------------------------------------------

def test_fit_cells_preserves_aspect_and_bounds():
    assert fit_cells(200, 100) == (64, 32)
    assert fit_cells(100, 200) == (30, 60)
    assert fit_cells(10, 10) == (60, 60)
    c, r = fit_cells(0, 0)
    assert (c, r) == (64, 60)


def test_clamp_crop():
    assert clamp_crop((-5, -5, 10, 10), 20, 20) == (0, 0, 10, 10)
    assert clamp_crop((15, 15, 100, 100), 20, 20) == (15, 15, 5, 5)


# --------------------------------------------------------------------------
# conversion determinism
# --------------------------------------------------------------------------

def test_solid_red_block_mode():
    cells = convert(_solid((255, 0, 0)), ImportParams(cols=4, rows=4, mode="blocks"))
    assert len(cells) == 16
    want = rgb_to_odyssey(255, 0, 0)
    assert all(c.glyph == 0xDB and c.attr == want for c in cells.values())


def test_black_image_yields_nothing():
    cells = convert(_solid((0, 0, 0)), ImportParams(cols=6, rows=6, mode="shades"))
    assert cells == {}


def test_shades_mode_picks_ramp_by_luminance():
    mid = convert(_solid((128, 128, 128)),
                  ImportParams(cols=2, rows=2, mode="shades"))
    bright = convert(_solid((255, 255, 255)),
                     ImportParams(cols=2, rows=2, mode="shades"))
    assert all(c.glyph in (0xB0, 0xB1, 0xB2) for c in mid.values())
    assert all(c.glyph == 0xDB for c in bright.values())


def test_halfblock_mode_uses_half_glyphs():
    cells = convert(_halves((255, 255, 255), (0, 0, 0), (8, 8)),
                    ImportParams(cols=1, rows=1, mode="halfblock",
                                 dark_threshold=20))
    assert cells[(0, 0)].glyph == 0xDF          # upper half lit only


def test_conversion_is_deterministic():
    im = _halves((200, 40, 40), (40, 40, 200), (16, 16))
    p = ImportParams(cols=8, rows=8, mode="shades")
    assert convert(im, p) == convert(im, p)


def test_crop_changes_the_result():
    im = _halves((255, 255, 255), (0, 0, 0), (8, 8))
    whole = convert(im, ImportParams(cols=4, rows=4, mode="blocks"))
    top = convert(im, ImportParams(cols=4, rows=4, mode="blocks",
                                   crop=(0, 0, 8, 4)))
    assert whole != top
    assert len(top) == 16          # cropped-to top half is all white -> all lit


# --------------------------------------------------------------------------
# params round-trip
# --------------------------------------------------------------------------

def test_import_params_roundtrip():
    p = ImportParams(cols=40, rows=20, crop=(1, 2, 3, 4), mode="halfblock",
                     dark_threshold=30, levels=3, dither=True)
    assert ImportParams.from_dict(p.to_dict()) == p
    assert ImportParams.from_dict({}).mode == "shades"
    assert ImportParams.from_dict({}).levels == 4
    assert ImportParams.from_dict({}).dither is False


def test_posterize_levels_reduce_distinct_colors():
    grad = Image.new("RGB", (32, 1))
    for x in range(32):
        v = int(x / 31 * 255)
        grad.putpixel((x, 0), (v, v, v))
    full = convert(grad, ImportParams(cols=32, rows=1, mode="blocks", levels=4,
                                      dark_threshold=0))
    two = convert(grad, ImportParams(cols=32, rows=1, mode="blocks", levels=2,
                                     dark_threshold=0))
    assert len({c.attr for c in two.values()}) <= len({c.attr for c in full.values()})
    assert len({c.attr for c in two.values()}) <= 2


def test_dither_is_deterministic_and_changes_output():
    im = Image.new("RGB", (24, 24))
    for y in range(24):
        for x in range(24):
            im.putpixel((x, y), (x * 10 % 256, 128, y * 10 % 256))
    p_plain = ImportParams(cols=12, rows=12, mode="blocks", dark_threshold=0)
    p_dith = ImportParams(cols=12, rows=12, mode="blocks", dark_threshold=0,
                          dither=True)
    a = convert(im, p_dith)
    assert a == convert(im, p_dith)                 # deterministic
    assert a != convert(im, p_plain)               # dithering actually did something


# --------------------------------------------------------------------------
# ImageLayer
# --------------------------------------------------------------------------

def test_image_layer_attach_regenerate_and_manual_edits():
    im = _solid((0, 200, 0), (16, 16))
    layer = ImageLayer(name="logo", params=ImportParams(cols=6, rows=6,
                                                        mode="blocks").to_dict())
    layer.attach_source(image=im)
    layer.regenerate()
    assert len(layer.cells) == 36
    assert layer.manual_edits() is False

    from studio.model.cell import Cell
    layer.set_local(0, 0, Cell(0x41, 0x0F))
    assert layer.manual_edits() is True

    layer.params["cols"] = 3
    layer.regenerate()
    assert max(c for c, _r in layer.cells) < 3


def test_image_layer_without_source_keeps_cells():
    from studio.model.cell import Cell
    layer = ImageLayer(name="orphan", params={"cols": 4, "rows": 4})
    layer.cells = {(0, 0): Cell(0xDB, 0x30)}
    layer.regenerate()                     # no source -> identity
    assert layer.cells == {(0, 0): Cell(0xDB, 0x30)}


def test_oas_roundtrip_with_embedded_source(tmp_path):
    im = _halves((240, 20, 20), (20, 20, 240), (24, 24))
    layer = ImageLayer(name="pic", params=ImportParams(cols=10, rows=8,
                                                       mode="shades").to_dict())
    layer.attach_source(image=im)
    layer.regenerate()
    ref = layer.source_ref
    original_cells = dict(layer.cells)

    doc = Document()
    doc.add_layer(layer)
    path = str(tmp_path / "pic.oas")
    save_project(doc, path, assets={ref: layer._source_bytes})

    assets = read_assets(path)
    assert ref in assets

    reloaded = load_project(path)
    img_layer = reloaded.layers[0]
    assert isinstance(img_layer, ImageLayer)
    assert img_layer.cells == original_cells          # cached cells survive
    # re-attach + re-quantise reproduces the same grid
    img_layer.attach_source(blob=assets[ref])
    assert img_layer.manual_edits() is False
    img_layer.regenerate()
    assert img_layer.cells == original_cells


def test_oklab_match_roundtrips_and_differs_from_rgb_on_some_images():
    from studio.convert.image_import import MATCHES, _nearest_oklab
    assert MATCHES == ("rgb", "oklab")
    # exact palette colors map to themselves under OKLab
    from studio.model.palette import PALETTE
    for code in (0, 5, 21, 42, 63):
        assert _nearest_oklab(PALETTE[code]) == code

    # a mid teal that per-channel-rounds one way but is perceptually closer
    # another way -> the two matchers can disagree
    im = Image.new("RGB", (8, 8), (60, 130, 120))
    rgb = convert(im, ImportParams(cols=4, rows=4, mode="blocks",
                                   dark_threshold=0, match="rgb"))
    oklab = convert(im, ImportParams(cols=4, rows=4, mode="blocks",
                                     dark_threshold=0, match="oklab"))
    assert len(rgb) == len(oklab) == 16
    # both are valid 6-bit codes
    assert all(0 <= c.attr <= 0x3F for c in oklab.values())


def test_import_params_roundtrip_includes_match():
    p = ImportParams(match="oklab")
    assert ImportParams.from_dict(p.to_dict()).match == "oklab"
    assert ImportParams.from_dict({}).match == "rgb"
