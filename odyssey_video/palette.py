"""
Odyssey 64-color palette and quantization.

Color byte format: bits [5:4]=red, [3:2]=green, [1:0]=blue
Each channel: 0=0, 1=85, 2=170, 3=255
"""

LEVELS = [0, 85, 170, 255]

# All 64 Odyssey colors as (R, G, B) tuples, indexed by color code.
# Code = (r_idx << 4) | (g_idx << 2) | b_idx
PALETTE = [
    (LEVELS[(code >> 4) & 3], LEVELS[(code >> 2) & 3], LEVELS[code & 3])
    for code in range(64)
]


def rgb_to_odyssey(r, g, b):
    """
    Convert an RGB triple to the nearest Odyssey color code byte.
    Quantizes each channel independently via rounding to nearest level.
    """
    r_idx = min(3, round(r / 85))
    g_idx = min(3, round(g / 85))
    b_idx = min(3, round(b / 85))
    return (r_idx << 4) | (g_idx << 2) | b_idx


def odyssey_to_rgb(code):
    """
    Convert an Odyssey color code byte to an (R, G, B) tuple.
    """
    return PALETTE[code & 0x3F]
