"""
Odyssey 64-color palette, RGB quantisation, and color-attribute helpers.

WHAT
    The Odyssey stores one color byte per cell in the color plane (0x5000):

        bit 7  BLINK
        bit 6  CURSOR      (an editor artifact -- masked out on export)
        bits [5:4]  red    index 0..3
        bits [3:2]  green  index 0..3
        bits [1:0]  blue   index 0..3

    Each channel index maps to an intensity in LEVELS = [0, 85, 170, 255].
    There is no background color.

WHY
    `PALETTE` / `rgb_to_odyssey` / `odyssey_to_rgb` are lifted verbatim (in
    behavior) from odyssey_video/palette.py so image import and this editor
    quantise identically.  The attr-byte split/join helpers and the ANSI-16
    table are new: the GUI needs to move fluidly between "a color byte", "an
    (R,G,B) triple", "three 0..3 sliders", and "an SGR code" without each
    call site re-deriving the bit layout.

    ANSI16 pairs come from the terminal's SGR handling (see TERMINAL.md and
    assembler/asm_macros %ansi_*%): SGR 30-37 / 90-97 each name one specific
    RGB222 color byte.  They are exact, not approximate -- every attr byte
    in ANSI16 round-trips through attr_to_rgb to the pure RGB222 value.
"""

LEVELS = [0, 85, 170, 255]

# All 64 Odyssey colors as (R, G, B) tuples, indexed by the 6-bit color code.
# code = (r_idx << 4) | (g_idx << 2) | b_idx
PALETTE = [
    (LEVELS[(code >> 4) & 3], LEVELS[(code >> 2) & 3], LEVELS[code & 3])
    for code in range(64)
]

# Named attr-byte bits.
BLINK_BIT = 0x80
CURSOR_BIT = 0x40
RGB_MASK = 0x3F


def rgb_to_odyssey(r, g, b):
    """Convert an RGB triple to the nearest 6-bit Odyssey color code.

    Each channel is quantised independently by rounding to the nearest of the
    four levels.  Matches odyssey_video.palette.rgb_to_odyssey exactly.
    """
    r_idx = min(3, round(r / 85))
    g_idx = min(3, round(g / 85))
    b_idx = min(3, round(b / 85))
    return (r_idx << 4) | (g_idx << 2) | b_idx


def odyssey_to_rgb(code):
    """Convert a color code (or full attr byte) to an (R, G, B) tuple.

    Blink / cursor bits are ignored -- only the low 6 bits select the color.
    """
    return PALETTE[code & RGB_MASK]


# --- attr-byte split / join -------------------------------------------------

def attr_blink(a) -> bool:
    """True if the BLINK bit (0x80) is set."""
    return bool(a & BLINK_BIT)


def attr_cursor(a) -> bool:
    """True if the CURSOR bit (0x40) is set (editor artifact; masked on export)."""
    return bool(a & CURSOR_BIT)


def attr_rgb_idx(a):
    """Return (r_idx, g_idx, b_idx), each 0..3, from an attr byte."""
    return ((a >> 4) & 3, (a >> 2) & 3, a & 3)


def make_attr(r_idx, g_idx, b_idx, blink=False, cursor=False) -> int:
    """Build an attr byte from three 0..3 channel indices plus flag bits."""
    a = ((r_idx & 3) << 4) | ((g_idx & 3) << 2) | (b_idx & 3)
    if blink:
        a |= BLINK_BIT
    if cursor:
        a |= CURSOR_BIT
    return a


def attr_to_rgb(a):
    """(R, G, B) intensity triple for an attr byte, ignoring blink/cursor."""
    r_idx, g_idx, b_idx = attr_rgb_idx(a)
    return (LEVELS[r_idx], LEVELS[g_idx], LEVELS[b_idx])


def with_blink(a, on) -> int:
    """Return `a` with the BLINK bit forced on or off."""
    return (a | BLINK_BIT) if on else (a & ~BLINK_BIT & 0xFF)


def with_cursor(a, on) -> int:
    """Return `a` with the CURSOR bit forced on or off."""
    return (a | CURSOR_BIT) if on else (a & ~CURSOR_BIT & 0xFF)


# --- ANSI-16 <-> attr byte -----------------------------------------------

# attr byte -> (SGR code, human name).  These are the 16 colors the Odyssey
# terminal's SGR 30-37 / 90-97 select; each is an exact RGB222 color byte.
ANSI16 = {
    0x00: (30, "black"),
    0x20: (31, "red"),
    0x08: (32, "green"),
    0x24: (33, "yellow"),
    0x02: (34, "blue"),
    0x22: (35, "magenta"),
    0x0a: (36, "cyan"),
    0x2a: (37, "white"),
    0x15: (90, "bright black"),
    0x35: (91, "bright red"),
    0x1d: (92, "bright green"),
    0x3d: (93, "bright yellow"),
    0x17: (94, "bright blue"),
    0x37: (95, "bright magenta"),
    0x1f: (96, "bright cyan"),
    0x3f: (97, "bright white"),
}

# SGR code -> (attr byte, name).
ANSI16_BY_SGR = {sgr: (attr, name) for attr, (sgr, name) in ANSI16.items()}


def _dist2(a, b):
    """Squared Euclidean distance between two RGB triples."""
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def nearest_ansi16(attr) -> int:
    """Snap an attr byte to the closest of the 16 ANSI colors.

    Match is by RGB distance over the 16-color set (per-channel nearest is
    equivalent here since the set is small).  The BLINK bit is preserved; the
    CURSOR bit is dropped.
    """
    target = attr_to_rgb(attr)
    best = min(ANSI16, key=lambda code: _dist2(attr_to_rgb(code), target))
    return best | (attr & BLINK_BIT)
