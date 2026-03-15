"""
Color frame converter for Odyssey video.

Converts PIL Images to Odyssey color frames: one byte per character cell,
using the 64-color palette (2 bits per RGB channel).
"""

import numpy as np
from PIL import Image

from common import DISPLAY_W, DISPLAY_H, compute_frame_height, pad_frame


def image_to_color_frame(img, height=None):
    """
    Convert a PIL Image to an Odyssey color frame (raw bytes).

    Scales the image to DISPLAY_W wide and 'height' tall (preserving aspect
    ratio if height is not given), quantizes each pixel to the Odyssey 64-color
    palette, and returns the result padded to a multiple of FRAME_ALIGN.

    Args:
        img: PIL Image object (any mode; will be converted to RGB).
        height: Output height in cells. If None, computed from source aspect
                ratio via compute_frame_height(). Must be even.

    Returns:
        bytes: Raw frame data, length is a multiple of 128.
    """
    if img.mode != "RGB":
        img = img.convert("RGB")

    src_w, src_h = img.size
    if height is None:
        height = compute_frame_height(src_w, src_h)

    scaled = img.resize((DISPLAY_W, height), Image.LANCZOS)

    arr = np.array(scaled, dtype=np.uint8)  # shape: (height, 64, 3)

    # Quantize each channel: round(channel / 85), clamped to [0, 3]
    quantized = np.clip(np.round(arr / 85.0).astype(np.uint8), 0, 3)

    r = quantized[:, :, 0]
    g = quantized[:, :, 1]
    b = quantized[:, :, 2]

    codes = ((r << 4) | (g << 2) | b).astype(np.uint8)
    frame = codes.flatten().tobytes()
    return pad_frame(frame)
