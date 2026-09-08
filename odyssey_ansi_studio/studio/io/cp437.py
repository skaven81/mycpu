"""
CP437 <-> Unicode tables, glyph names, and box-drawing style sets.

WHAT
    `CP437_TO_UNICODE` -- a 256-tuple mapping every CP437 byte code to the
    Unicode character it renders as on an IBM-PC-style code page 437:
      * 0x00-0x1F  the classic control-position pictographs (smiley, hearts,
                   arrows, ...); 0x00 maps to U+0000.
      * 0x20-0x7E  plain ASCII.
      * 0x7F       the "house" glyph.
      * 0x80-0xFF  the DOS high range: accented Latin, box drawing, blocks,
                   Greek, maths symbols.
    `UNICODE_TO_CP437` -- the reverse map (first CP437 code wins; every
    canonical CP437 character is distinct, so all 256 are represented).

    `GLYPH_NAMES` / `glyph_name(code)` -- short human labels for the glyph
    picker, with good coverage of the shade/box/block range and a
    `"0xNN"` fallback.

    `BOX_STYLES` -- named line-drawing sets (corner + edge + junction CP437
    *byte codes*, not Unicode) for the box-layer tool.

WHY
    The editor stores CP437 codes (that is what the hardware wants), but the
    GUI needs to show real glyphs and let the user search by name, and the
    box tool needs ready-made corner/junction sets.  Seeded from the partial
    table in os/bootbanner/gen.py, completed to the canonical 256 entries.
"""

from studio.model.cell import is_control_glyph  # canonical def; re-exported

__all__ = [
    "CP437_TO_UNICODE",
    "UNICODE_TO_CP437",
    "GLYPH_NAMES",
    "glyph_name",
    "BOX_STYLES",
    "is_control_glyph",
]

# --- the 256-entry code -> Unicode table ---------------------------------

# 0x00-0x1F: control-position pictographs (0x00 -> U+0000).
_CONTROL_PICTOGRAPHS = (
    "\x00☺☻♥♦♣♠•"
    "◘○◙♂♀♪♫☼"
    "►◄↕‼¶§▬↨"
    "↑↓→←∟↔▲▼"
)

# 0x20-0x7E: identical to ASCII.
_ASCII = "".join(chr(c) for c in range(0x20, 0x7F))

# 0x7F-0xFF: "house" then the DOS high range.
_HIGH = (
    "⌂"                                              # 0x7F
    "Çüéâäàåç"     # 0x80-0x87
    "êëèïîìÄÅ"     # 0x88-0x8F
    "ÉæÆôöòûù"     # 0x90-0x97
    "ÿÖÜ¢£¥₧ƒ"     # 0x98-0x9F
    "áíóúñÑªº"     # 0xA0-0xA7
    "¿⌐¬½¼¡«»"     # 0xA8-0xAF
    "░▒▓│┤╡╢╖"     # 0xB0-0xB7
    "╕╣║╗╝╜╛┐"     # 0xB8-0xBF
    "└┴┬├─┼╞╟"     # 0xC0-0xC7
    "╚╔╩╦╠═╬╧"     # 0xC8-0xCF
    "╨╤╥╙╘╒╓╫"     # 0xD0-0xD7
    "╪┘┌█▄▌▐▀"     # 0xD8-0xDF
    "αßΓπΣσµτ"     # 0xE0-0xE7
    "ΦΘΩδ∞φε∩"     # 0xE8-0xEF
    "≡±≥≤⌠⌡÷≈"     # 0xF0-0xF7
    "°∙·√ⁿ²■ "     # 0xF8-0xFF
)

CP437_TO_UNICODE = tuple(_CONTROL_PICTOGRAPHS + _ASCII + _HIGH)
assert len(CP437_TO_UNICODE) == 256, len(CP437_TO_UNICODE)

# Reverse map: first (lowest) CP437 code wins on any collision.
UNICODE_TO_CP437 = {}
for _code, _char in enumerate(CP437_TO_UNICODE):
    UNICODE_TO_CP437.setdefault(_char, _code)


# --- glyph names -------------------------------------------------------

# Short labels aimed at the glyph picker / search box.  Not exhaustive:
# focused on shades, box drawing, blocks, and a few common symbols.  Anything
# absent falls through `glyph_name` to a "0xNN" hex label.
GLYPH_NAMES = {
    0x00: "null",
    0x07: "bullet",
    0x09: "circle",
    0x0f: "sun",
    0x10: "triangle right",
    0x11: "triangle left",
    0x18: "arrow up",
    0x19: "arrow down",
    0x1a: "arrow right",
    0x1b: "arrow left",
    0x1e: "triangle up",
    0x1f: "triangle down",
    0x20: "space",
    0x7f: "house",
    0xb0: "light shade",
    0xb1: "medium shade",
    0xb2: "dark shade",
    0xb3: "line v",
    0xb4: "tee left",
    0xb5: "tee left (double h)",
    0xb6: "tee left (double v)",
    0xb7: "corner tr (double v)",
    0xb8: "corner tr (double h)",
    0xb9: "tee left double",
    0xba: "line v double",
    0xbb: "corner tr double",
    0xbc: "corner br double",
    0xbd: "corner br (double h)",
    0xbe: "corner br (double v)",
    0xbf: "corner tr",
    0xc0: "corner bl",
    0xc1: "tee up",
    0xc2: "tee down",
    0xc3: "tee right",
    0xc4: "line h",
    0xc5: "cross",
    0xc6: "tee right (double h)",
    0xc7: "tee right (double v)",
    0xc8: "corner bl double",
    0xc9: "corner tl double",
    0xca: "tee up double",
    0xcb: "tee down double",
    0xcc: "tee right double",
    0xcd: "line h double",
    0xce: "cross double",
    0xcf: "tee up (double h)",
    0xd0: "tee up (double v)",
    0xd1: "tee down (double h)",
    0xd2: "tee down (double v)",
    0xd3: "corner bl (double v)",
    0xd4: "corner bl (double h)",
    0xd5: "corner tl (double h)",
    0xd6: "corner tl (double v)",
    0xd7: "cross (double v)",
    0xd8: "cross (double h)",
    0xd9: "corner br",
    0xda: "corner tl",
    0xdb: "full block",
    0xdc: "lower half block",
    0xdd: "left half block",
    0xde: "right half block",
    0xdf: "upper half block",
    0xf8: "degree",
    0xfe: "small square",
    0xff: "no-break space",
}


def glyph_name(code: int) -> str:
    """Short label for a CP437 code; `"0xNN"` when we have no name for it."""
    return GLYPH_NAMES.get(code, f"0x{code:02X}")


# --- box-drawing style sets --------------------------------------------

# Each set: the 6 core members `tl tr bl br h v`, plus the 5 junction members
# `t_left t_right t_up t_down cross`.  Values are CP437 byte codes.
BOX_STYLES = {
    # ┌ ┐ └ ┘ ─ │  + junctions ├ ┤ ┴ ┬ ┼
    "single": {
        "tl": 0xDA, "tr": 0xBF, "bl": 0xC0, "br": 0xD9, "h": 0xC4, "v": 0xB3,
        "t_left": 0xC3, "t_right": 0xB4, "t_up": 0xC1, "t_down": 0xC2,
        "cross": 0xC5,
    },
    # ╔ ╗ ╚ ╝ ═ ║  + junctions ╠ ╣ ╩ ╦ ╬
    "double": {
        "tl": 0xC9, "tr": 0xBB, "bl": 0xC8, "br": 0xBC, "h": 0xCD, "v": 0xBA,
        "t_left": 0xCC, "t_right": 0xB9, "t_up": 0xCA, "t_down": 0xCB,
        "cross": 0xCE,
    },
    # ╓ ╖ ╙ ╜ ─ ║  (single horizontals, double verticals)
    "single_h_double_v": {
        "tl": 0xD6, "tr": 0xB7, "bl": 0xD3, "br": 0xBD, "h": 0xC4, "v": 0xBA,
        "t_left": 0xC7, "t_right": 0xB6, "t_up": 0xD0, "t_down": 0xD2,
        "cross": 0xD7,
    },
    # ╒ ╕ ╘ ╛ ═ │  (double horizontals, single verticals)
    "double_h_single_v": {
        "tl": 0xD5, "tr": 0xB8, "bl": 0xD4, "br": 0xBE, "h": 0xCD, "v": 0xB3,
        "t_left": 0xC6, "t_right": 0xB5, "t_up": 0xCF, "t_down": 0xD1,
        "cross": 0xD8,
    },
    # solid block for every position
    "block": {
        "tl": 0xDB, "tr": 0xDB, "bl": 0xDB, "br": 0xDB, "h": 0xDB, "v": 0xDB,
        "t_left": 0xDB, "t_right": 0xDB, "t_up": 0xDB, "t_down": 0xDB,
        "cross": 0xDB,
    },
}

# The 6 members every style is guaranteed to define.
BOX_CORE_KEYS = ("tl", "tr", "bl", "br", "h", "v")
