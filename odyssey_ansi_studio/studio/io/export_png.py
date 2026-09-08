"""
PNG export -- render the composited document to a pixel image.

Each cell is drawn as its 8x8 CP437 glyph (from the document's font bank)
tinted to the cell's 6-bit RGB color on black -- exactly what the Odyssey
would show.  `scale` enlarges with nearest-neighbor so pixels stay crisp.
With ``show_blink=False`` blink cells are rendered black (their "off" phase).
"""

import io

from PIL import Image

from studio.model.palette import attr_blink, odyssey_to_rgb

_CELL = 8


def render_image(doc, fontrom, *, scale=1, show_blink=True) -> Image.Image:
    char_plane, color_plane = doc.composite()
    w, h = doc.width, doc.height
    try:
        bank = fontrom.load_bank(doc.font_bank)
    except FileNotFoundError:
        bank = fontrom.blank_bank()

    img = Image.new("RGB", (w * _CELL, h * _CELL), (0, 0, 0))
    px = img.load()
    for row in range(h):
        for col in range(w):
            off = row * w + col
            glyph = char_plane[off]
            if glyph == 0x00:
                continue
            attr = color_plane[off]
            if not show_blink and attr_blink(attr):
                continue
            rgb = odyssey_to_rgb(attr)
            bits = bank.glyph_bits(glyph)          # 8 bytes, bit 7 = leftmost
            x0, y0 = col * _CELL, row * _CELL
            for r in range(_CELL):
                b = bits[r]
                if not b:
                    continue
                for c in range(_CELL):
                    if b & (0x80 >> c):
                        px[x0 + c, y0 + r] = rgb

    if scale and scale != 1:
        img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    return img


def export_png(doc, fontrom, *, scale=1, show_blink=True) -> bytes:
    buf = io.BytesIO()
    render_image(doc, fontrom, scale=scale, show_blink=show_blink).save(buf, "PNG")
    return buf.getvalue()
