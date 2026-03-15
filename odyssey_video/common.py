"""
Shared constants and utilities for Odyssey video frame generation.
"""

DISPLAY_W = 64
DISPLAY_H = 60
FRAME_ALIGN = 128


def compute_frame_height(src_w, src_h, display_w=DISPLAY_W):
    """
    Compute the output frame height for a given source resolution.

    Scales proportionally to display_w wide, rounds up to nearest even number
    so that display_w * height is divisible by FRAME_ALIGN (128).
    Result is clamped to [2, DISPLAY_H].
    """
    h = round(src_h * display_w / src_w)
    if h % 2 != 0:
        h += 1
    return max(2, min(h, DISPLAY_H))


def pad_frame(data):
    """
    Pad bytes to the next multiple of FRAME_ALIGN.
    No-op when already aligned.
    """
    remainder = len(data) % FRAME_ALIGN
    if remainder == 0:
        return data
    return data + b' ' * (FRAME_ALIGN - remainder)
