"""
Image import -- crop + scale a PNG/JPG down to Odyssey character cells.

WHAT
    `convert(image, params)` returns a sparse ``{(local_col, local_row): Cell}``
    grid (origin 0,0).  The Odyssey has one glyph + one color per cell and no
    background, so conversion is: crop -> LANCZOS-scale to `cols` x `rows` ->
    per-cell nearest-64 color -> a glyph chosen by the mode:

      * ``"blocks"``    -- solid full block for every non-dark cell.
      * ``"shades"``    -- a ``" ░▒▓█"`` ramp keyed to cell luminance.
      * ``"halfblock"`` -- sample two sub-rows per cell; ``▀`` / ``▄`` / ``█``
                           and the color of the lit half (doubles the
                           effective vertical resolution for lit pixels).

    Cells darker than `dark_threshold` are left NULL (transparent) so an
    imported logo drops cleanly onto whatever is beneath it.

WHY
    Deterministic and dependency-light (Pillow + numpy, both already in the
    PEP 723 header).  `ImportParams` round-trips through the `.oas` so an
    `ImageLayer` can re-quantise from the embedded source after the user
    tweaks the crop or the target size -- layers stay mutable.
"""

from __future__ import annotations

import hashlib
import io
from dataclasses import dataclass

import numpy as np
from PIL import Image

from studio.model.cell import Cell
from studio.model.palette import PALETTE, rgb_to_odyssey

MATCHES = ("rgb", "oklab")
_PALETTE_OKLAB = None

#: space, light shade, medium shade, dark shade, full block
SHADE_RAMP = (0x20, 0xB0, 0xB1, 0xB2, 0xDB)
FULL_BLOCK = 0xDB
UPPER_HALF = 0xDF
LOWER_HALF = 0xDC

MODES = ("blocks", "shades", "halfblock")
_LUMA = np.array([0.299, 0.587, 0.114], dtype=np.float32)


@dataclass
class ImportParams:
    cols: int = 32
    rows: int = 16
    crop: tuple | None = None          # (x, y, w, h) in source pixels
    mode: str = "shades"
    dark_threshold: int = 24           # 0..255 luminance; <= -> NULL cell
    levels: int = 4                    # posterize: bands per channel, 2..4
    dither: bool = False              # Floyd-Steinberg error diffusion
    match: str = "rgb"               # color match: "rgb" (per-channel) | "oklab"

    def to_dict(self) -> dict:
        return {
            "cols": int(self.cols),
            "rows": int(self.rows),
            "crop": list(self.crop) if self.crop else None,
            "mode": self.mode,
            "dark_threshold": int(self.dark_threshold),
            "levels": int(self.levels),
            "dither": bool(self.dither),
            "match": self.match,
        }

    @classmethod
    def from_dict(cls, d) -> "ImportParams":
        d = d or {}
        crop = d.get("crop")
        return cls(
            cols=int(d.get("cols", 32)),
            rows=int(d.get("rows", 16)),
            crop=tuple(crop) if crop else None,
            mode=d.get("mode", "shades"),
            dark_threshold=int(d.get("dark_threshold", 24)),
            levels=int(d.get("levels", 4)),
            dither=bool(d.get("dither", False)),
            match=d.get("match", "rgb"),
        )


# --- loading / assets --------------------------------------------------

def load_image(path) -> Image.Image:
    """Open `path` and return it as an RGB `PIL.Image`."""
    img = Image.open(path)
    return img.convert("RGB") if img.mode != "RGB" else img


def image_from_bytes(blob: bytes) -> Image.Image:
    img = Image.open(io.BytesIO(blob))
    return img.convert("RGB") if img.mode != "RGB" else img


def png_bytes(img: Image.Image) -> bytes:
    buf = io.BytesIO()
    img.convert("RGB").save(buf, format="PNG")
    return buf.getvalue()


def source_ref(blob: bytes) -> str:
    """The ``assets/`` basename for a source blob: ``<sha256hex>.png``."""
    return hashlib.sha256(blob).hexdigest() + ".png"


# --- conversion ------------------------------------------------------

def _prepared(img: Image.Image, params: ImportParams) -> Image.Image:
    if img.mode != "RGB":
        img = img.convert("RGB")
    if params.crop:
        x, y, w, h = (int(v) for v in params.crop)
        x = max(0, min(x, img.width - 1))
        y = max(0, min(y, img.height - 1))
        w = max(1, min(w, img.width - x))
        h = max(1, min(h, img.height - y))
        img = img.crop((x, y, x + w, y + h))
    return img


def clamp_crop(crop, src_w, src_h):
    """Clamp a ``(x, y, w, h)`` crop rect into ``src_w`` x ``src_h``."""
    x, y, w, h = (int(v) for v in crop)
    x = max(0, min(x, src_w - 1))
    y = max(0, min(y, src_h - 1))
    w = max(1, min(w, src_w - x))
    h = max(1, min(h, src_h - y))
    return (x, y, w, h)


def _srgb_to_oklab(rgb):
    """`rgb` array (..., 3) in 0..255 -> OKLab (..., 3)."""
    c = np.asarray(rgb, dtype=np.float64) / 255.0
    lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    r, g, b = lin[..., 0], lin[..., 1], lin[..., 2]
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l_, m_, s_ = np.cbrt(l), np.cbrt(m), np.cbrt(s)
    return np.stack([
        0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
    ], axis=-1)


def _palette_oklab():
    global _PALETTE_OKLAB
    if _PALETTE_OKLAB is None:
        _PALETTE_OKLAB = _srgb_to_oklab(np.array(PALETTE, dtype=np.float64))
    return _PALETTE_OKLAB


def _nearest_oklab(rgb) -> int:
    """0..63 palette code closest to `rgb` (a length-3 sequence) in OKLab."""
    lab = _srgb_to_oklab(np.asarray(rgb, dtype=np.float64))
    d = np.sum((_palette_oklab() - lab) ** 2, axis=1)
    return int(np.argmin(d))


def _matcher(match):
    if match == "oklab":
        return _nearest_oklab
    return lambda px: rgb_to_odyssey(int(px[0]), int(px[1]), int(px[2]))


def _reduce(arr, levels, dither):
    """Posterize `arr` (float32 HxWx3, 0..255) to `levels` bands per channel,
    optionally with Floyd-Steinberg error diffusion."""
    levels = max(2, min(4, int(levels)))
    if levels == 4 and not dither:
        return arr
    step = 255.0 / (levels - 1)
    h, w = arr.shape[:2]
    work = arr.astype(np.float32).copy()
    for y in range(h):
        for x in range(w):
            old = work[y, x].copy()
            q = np.clip(np.round(old / step), 0, levels - 1) * step
            work[y, x] = q
            if dither:
                err = old - q
                if x + 1 < w:
                    work[y, x + 1] += err * (7.0 / 16.0)
                if y + 1 < h:
                    if x > 0:
                        work[y + 1, x - 1] += err * (3.0 / 16.0)
                    work[y + 1, x] += err * (5.0 / 16.0)
                    if x + 1 < w:
                        work[y + 1, x + 1] += err * (1.0 / 16.0)
    return np.clip(work, 0.0, 255.0)


def convert(img: Image.Image, params: ImportParams) -> dict:
    """Return ``{(col, row): Cell}`` for the imported image."""
    cols = max(1, int(params.cols))
    rows = max(1, int(params.rows))
    mode = params.mode if params.mode in MODES else "shades"
    thr = float(params.dark_threshold)

    src = _prepared(img, params)
    vf = 2 if mode == "halfblock" else 1
    # BOX for the half-block path so each cell half is a clean average of its
    # source band; LANCZOS keeps the single-sample modes crisp.
    resample = Image.BOX if mode == "halfblock" else Image.LANCZOS
    scaled = src.resize((cols, rows * vf), resample)
    arr = np.asarray(scaled, dtype=np.float32).reshape(rows * vf, cols, 3)
    arr = _reduce(arr, params.levels, params.dither)
    lum = arr @ _LUMA
    match = _matcher(params.match if params.match in MATCHES else "rgb")

    cells: dict = {}

    if mode == "halfblock":
        for r in range(rows):
            top, bot = arr[2 * r], arr[2 * r + 1]
            tl, bl = lum[2 * r], lum[2 * r + 1]
            for c in range(cols):
                lit_t, lit_b = tl[c] > thr, bl[c] > thr
                if not lit_t and not lit_b:
                    continue
                if lit_t and lit_b:
                    g, rgb = FULL_BLOCK, (top[c] + bot[c]) * 0.5
                elif lit_t:
                    g, rgb = UPPER_HALF, top[c]
                else:
                    g, rgb = LOWER_HALF, bot[c]
                cells[(c, r)] = Cell(g, match(rgb))
        return cells

    for r in range(rows):
        for c in range(cols):
            L = float(lum[r, c])
            if L <= thr:
                continue
            px = arr[r, c]
            attr = match(px)
            if mode == "blocks":
                g = FULL_BLOCK
            else:  # shades
                idx = min(len(SHADE_RAMP) - 1,
                          int(L / 256.0 * len(SHADE_RAMP)))
                g = SHADE_RAMP[idx]
                if g == 0x20:
                    continue
            cells[(c, r)] = Cell(g, attr)
    return cells


def fit_cells(src_w, src_h, max_cols=64, max_rows=60):
    """Suggest a `(cols, rows)` that keeps the source aspect ratio and fits.

    Cells are ~1:1 on the Odyssey's 8x8 grid, so this is a plain
    aspect-preserving box fit.
    """
    if src_w <= 0 or src_h <= 0:
        return (max_cols, max_rows)
    scale = min(max_cols / src_w, max_rows / src_h)
    cols = max(1, min(max_cols, round(src_w * scale)))
    rows = max(1, min(max_rows, round(src_h * scale)))
    return (cols, rows)
