"""
Font-ROM loader: the Odyssey's 16 selectable 8x8 CP437 font banks.

WHAT
    The Odyssey renders each cell through one of 16 font banks (a DIP-switch /
    ``font_bank`` selector).  On real hardware the ROM is the concatenation of
    16 ``.F08`` files per ``bitmapfont/build_font_rom.sh``; slots 8..15 repeat
    0..7.  Each ``.F08`` is **2048 bytes = 256 glyphs x 8 rows, row-major**.

    NOTE ON BIT ORDER: the Phase-1 brief said "LSB = leftmost pixel", but the
    int10h ``.F08`` files use the standard VGA text-mode packing -- **bit 7
    (MSB) is the leftmost pixel**.  Verified against CGA.F08: glyph 0x4C ('L')
    only renders as an 'L' with MSB-left.  We render MSB-left.

    * ``BANKS``          -- the canonical 16-entry bank table
                           (``{"index", "name", "path"}``; ``path`` is relative
                           to the repo's ``bitmapfont/`` directory).
    * ``parse_f08(data)``-- pure helper: 2048 bytes -> ``list[bytes]`` of 256
                           eight-byte glyph rasters.  No Qt; QA tests it headless.
    * ``FontRom``        -- resolves ``bitmapfont/`` and loads/caches banks.
    * ``Bank``           -- one loaded bank: raw glyph bytes plus a per
                           ``(code, rgb)`` cache of 8x8 ``QImage`` tiles the
                           canvas blits.

WHY
    The canvas paints from real hardware fonts so a design previews exactly as
    it will look on the Odyssey.  Banks load lazily (a bank is only read the
    first time it is selected) and glyph tiles are cached because the canvas
    re-blits the same handful of glyph/color combinations thousands of times.
"""

import os
from pathlib import Path

from PySide6.QtGui import QColor, QImage

__all__ = ["BANKS", "parse_f08", "FontRom", "Bank"]

GLYPH_COUNT = 256
GLYPH_H = 8
GLYPH_W = 8
F08_SIZE = GLYPH_COUNT * GLYPH_H  # 2048

# The canonical slot assignment from bitmapfont/build_font_rom.sh.  Names are
# the trailing comments there; paths are relative to bitmapfont/.  Slots 8..15
# repeat 0..7 verbatim.
_BASE_BANKS = [
    ("IBM PC CGA", "int10h/FONTS/PC-IBM/CGA.F08"),
    ("IBM PC CGA - Thin", "int10h/FONTS/PC-IBM/CGA-TH.F08"),
    ("Compaq Thin", "int10h/FONTS/SYSTEM/CMPQDOS6/TH-CP437.F08"),
    ("IBM PC Convertible", "int10h/FONTS/PC-IBM/PCCONV.F08"),
    ("Kaypro 2000", "int10h/FONTS/PC-OTHER/KPRO2K.F08"),
    ("Toshiba Satellite", "int10h/FONTS/PC-OTHER/TOSH-SAT.F08"),
    ("Eagle Spirit CGA alt2 (sci-fi)", "int10h/FONTS/PC-OTHER/EAGLE2.F08"),
    ("Eagle Spirit CGA alt3 (fantasy)", "int10h/FONTS/PC-OTHER/EAGLE3.F08"),
]

BANKS = [
    {"index": i, "name": _BASE_BANKS[i % 8][0], "path": _BASE_BANKS[i % 8][1]}
    for i in range(16)
]


def parse_f08(data: bytes) -> list[bytes]:
    """Split a 2048-byte ``.F08`` blob into 256 eight-byte glyph rasters.

    Row-major; the returned bytes are exactly as stored (bit 7 = leftmost
    pixel).  Raises ``ValueError`` on any length other than 2048.
    """
    if len(data) != F08_SIZE:
        raise ValueError(
            f"expected a {F08_SIZE}-byte .F08 blob, got {len(data)} bytes"
        )
    return [bytes(data[i * GLYPH_H:(i + 1) * GLYPH_H]) for i in range(GLYPH_COUNT)]


def _resolve_bitmapfont_dir(repo_root=None) -> Path:
    """Locate the repo's ``bitmapfont/`` directory.

    Order: explicit ``repo_root`` arg, then ``$ODYSSEY_REPO_ROOT``, then a walk
    up from this file looking for a ``bitmapfont/`` sibling.
    """
    if repo_root is None:
        repo_root = os.environ.get("ODYSSEY_REPO_ROOT")
    if repo_root:
        return Path(repo_root).expanduser() / "bitmapfont"
    here = Path(__file__).resolve()
    for parent in here.parents:
        cand = parent / "bitmapfont"
        if cand.is_dir():
            return cand
    # Last-ditch guess: <repo>/odyssey_ansi_studio/studio/io/fontrom.py
    return here.parents[3] / "bitmapfont"


class Bank:
    """One loaded font bank: 256 raw glyph rasters + a cached tile renderer."""

    def __init__(self, name: str, glyphs: list[bytes]):
        self.name = name
        self._glyphs = glyphs
        self._image_cache: dict[tuple[int, tuple[int, int, int]], QImage] = {}

    def glyph_bits(self, code: int) -> bytes:
        """The raw 8 bytes for CP437 ``code`` (row-major, bit 7 = leftmost)."""
        return self._glyphs[code & 0xFF]

    def glyph_image(self, code: int, rgb) -> QImage:
        """An 8x8 ARGB32-premultiplied tile: lit pixels ``rgb``, rest transparent.

        Cached per ``(code, rgb)`` -- the canvas paints these over black.
        """
        rgb = (int(rgb[0]), int(rgb[1]), int(rgb[2]))
        key = (code & 0xFF, rgb)
        img = self._image_cache.get(key)
        if img is None:
            img = self._render(key[0], rgb)
            self._image_cache[key] = img
        return img

    def _render(self, code: int, rgb) -> QImage:
        img = QImage(GLYPH_W, GLYPH_H, QImage.Format_ARGB32_Premultiplied)
        img.fill(0)  # fully transparent
        color = QColor(rgb[0], rgb[1], rgb[2])
        bits = self._glyphs[code]
        for row in range(GLYPH_H):
            byte = bits[row]
            if not byte:
                continue
            for x in range(GLYPH_W):
                if (byte >> (7 - x)) & 1:   # bit 7 = leftmost pixel
                    img.setPixelColor(x, row, color)
        return img


class FontRom:
    """Lazily loads and caches the 16 font banks from ``bitmapfont/``."""

    def __init__(self, repo_root=None):
        self.bitmapfont_dir = _resolve_bitmapfont_dir(repo_root)
        self._bank_cache: dict[int, Bank] = {}

    def load_bank(self, index: int) -> Bank:
        """Return bank ``index`` (0..15), reading the ``.F08`` file once.

        Raises ``FileNotFoundError`` naming the expected path when the asset is
        missing; callers may fall back to :meth:`blank_bank`.
        """
        index = int(index) & 0x0F
        cached = self._bank_cache.get(index)
        if cached is not None:
            return cached
        spec = BANKS[index]
        path = self.bitmapfont_dir / spec["path"]
        if not path.is_file():
            raise FileNotFoundError(
                f"font bank {index} ({spec['name']}): expected .F08 at {path}"
            )
        glyphs = parse_f08(path.read_bytes())
        bank = Bank(spec["name"], glyphs)
        self._bank_cache[index] = bank
        return bank

    @staticmethod
    def blank_bank(name: str = "(blank)") -> Bank:
        """An all-zero bank so the app still starts when assets are missing."""
        return Bank(name, [b"\x00" * GLYPH_H for _ in range(GLYPH_COUNT)])
