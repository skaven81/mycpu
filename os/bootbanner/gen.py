#!/usr/bin/env python3
# Odyssey boot-banner ANSI-art mockups.
#
# Cell model == hardware model: one CP437 glyph + one 6-bit fg color per
# cell, black background, 64-column grid. Two outputs per direction:
#   *.ans            UTF-8 truecolor, forced black bg -> faithful preview
#                    of the RGB222 palette when `cat`ed in a terminal.
#   *.chr / *.clr    64-wide hex dumps: CP437 codes for 0x4000, color
#                    bytes for 0x5000. This is the blit-straight-to-VRAM
#                    form. Also bundled into banners.h.

import os
from collections import deque

W = 64
ESC = "\x1b"
RESET = f"{ESC}[0m"
BG = f"{ESC}[40m"


def fg(rgb):
    r, g, b = rgb
    return f"{ESC}[38;2;{r};{g};{b}m"


# ---- RGB222 palette picks (channel levels 0/85/170/255) --------------
WHITE, GREY, DGREY = (255, 255, 255), (170, 170, 170), (85, 85, 85)

PRISM = [                    # ROYGBIV across O D Y S S E Y
    (255, 0, 0),             # O  red     0x30
    (255, 170, 0),           # D  orange  0x38
    (255, 255, 0),           # Y  yellow  0x3c
    (0, 255, 0),             # S  green   0x0c
    (0, 0, 255),             # S  blue    0x03
    (85, 0, 170),            # E  indigo  0x12
    (170, 0, 255),           # Y  violet  0x23
]
# Synthwave bevel: hot-magenta lit face -> purple body -> deep-violet shade
CH_HI, CH_BODY, CH_LOW, CH_SH = (255,85,255), (170,0,255), (85,0,170), (85,0,85)
PH_HI, PH_MID, PH_HALO = (85,255,85), (0,170,0), (0,85,0)
NP_FRAME, NP_TAB = (255,255,255), (0,255,255)

FULL, LOWER, UPPER, LIGHT, MED, DARK = "█▄▀░▒▓"

CP437 = {
    " ": 0x20, "█": 0xDB, "▄": 0xDC, "▀": 0xDF, "░": 0xB0, "▒": 0xB1, "▓": 0xB2,
    "═": 0xCD, "║": 0xBA, "╔": 0xC9, "╗": 0xBB, "╚": 0xC8, "╝": 0xBC,
    "╡": 0xB5, "╞": 0xC6,
}
# ASCII caption glyphs pass straight through
for _o in range(0x20, 0x7F):
    CP437.setdefault(chr(_o), _o)


def color_byte(rgb):
    r, g, b = rgb
    return ((r // 85) << 4) | ((g // 85) << 2) | (b // 85)


# ---- 7x7 bold block font (used by chrome / phosphor / nameplate) -----
FONT = {
    "O": [".#####.", "##...##", "##...##", "##...##", "##...##", "##...##", ".#####."],
    "D": ["######.", "##...##", "##...##", "##...##", "##...##", "##...##", "######."],
    "Y": ["##...##", "##...##", ".##.##.", "..###..", "..###..", "..###..", "..###.."],
    "S": [".######", "##.....", "##.....", ".#####.", ".....##", ".....##", "######."],
    "E": ["#######", "##.....", "##.....", "######.", "##.....", "##.....", "#######"],
}
WORD = "ODYSSEY"
LW, LH, GAP = 7, 7, 1
LEFT = (W - (len(WORD) * LW + (len(WORD) - 1) * GAP)) // 2

# ---- 7-wide x 14-px ODYSSEY font: rasterized then drawn half-height
#      with ▀/▄/█ so curves and the Y diagonal get 2x vertical detail.
#      Flat -- no shadow, no extrusion.
FONT2 = {
    "O": ["..###..", ".#####.", "##...##", "##...##", "##...##", "##...##", "##...##",
          "##...##", "##...##", "##...##", "##...##", "##...##", ".#####.", "..###.."],
    "D": ["#####..", "######.", "##...##", "##...##", "##...##", "##...##", "##...##",
          "##...##", "##...##", "##...##", "##...##", "##...##", "######.", "#####.."],
    "Y": ["##...##", "##...##", "##...##", ".##.##.", ".##.##.", "..###..", "..###..",
          "..###..", "..###..", "..###..", "..###..", "..###..", "..###..", "..###.."],
    "S": [".#####.", "#######", "##.....", "##.....", "##.....", "##.....", ".#####.",
          ".#####.", ".....##", ".....##", ".....##", ".....##", "#######", ".#####."],
    "E": ["#######", "#######", "##.....", "##.....", "##.....", "##.....", "######.",
          "######.", "##.....", "##.....", "##.....", "##.....", "#######", "#######"],
}

# ---- "WIRE WRAP" heading: 6px-tall font, drawn half-height with
#      ▀/▄/█ half-blocks -> 3 char rows, on a black background ----------
WW_FONT = {
    "W": ["#...#", "#...#", "#...#", "#.#.#", "##.##", ".#.#."],
    "I": ["###", ".#.", ".#.", ".#.", ".#.", "###"],
    "R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..##"],
    "E": ["#####", "#....", "#....", "####.", "#....", "#####"],
    "A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#"],
    "P": ["####.", "#...#", "#...#", "####.", "#....", "#...."],
}
WW_TEXT = "WIRE WRAP"
WW_PX = 6                      # pixel rows
WW_CH = WW_PX // 2             # -> 3 character rows
WW_SP = 4                     # inter-word gap: 4 keeps WIRE anchored at col 7
                              # (2-col gap to the left wedge) while nudging
                              # WRAP one col right so its gap to the right
                              # wedge is also 2 -- heading spans cols 7..56,
                              # dead centre on the 64-wide canvas.


def place_ww():
    """Half-block render of the centered heading -> (char_row, col, glyph)."""
    wid = {k: len(v[0]) for k, v in WW_FONT.items()}
    total = sum((WW_SP if ch == " " else wid[ch]) + 1 for ch in WW_TEXT) - 1
    grid = [[False] * W for _ in range(WW_PX)]
    x = (W - total) // 2
    for ch in WW_TEXT:
        if ch == " ":
            x += WW_SP + 1
            continue
        for r, line in enumerate(WW_FONT[ch]):
            for cc, p in enumerate(line):
                if p == "#":
                    grid[r][x + cc] = True
        x += wid[ch] + 1
    cells = []
    for cr in range(WW_CH):
        for c in range(W):
            top, bot = grid[cr * 2][c], grid[cr * 2 + 1][c]
            g = FULL if top and bot else UPPER if top else LOWER if bot else None
            if g:
                cells.append((cr, c, g))
    return cells


def placed_mask():
    g = [[-1] * W for _ in range(LH)]
    for li, ch in enumerate(WORD):
        x0 = LEFT + li * (LW + GAP)
        for r in range(LH):
            for c in range(LW):
                if FONT[ch][r][c] == "#":
                    g[r][x0 + c] = li
    return g


def blank_row():
    return [(" ", DGREY) for _ in range(W)]


def put_text(row, s, color):
    x = (W - len(s)) // 2
    for i, chx in enumerate(s):
        row[x + i] = (chx, color)


def flood_outside(lit, H):
    """BFS from the canvas border over non-lit cells; letter counters,
    being enclosed by lit pixels, stay unreached."""
    out = [[False] * W for _ in range(H)]
    dq = deque()

    def seed(r, c):
        if not lit[r][c] and not out[r][c]:
            out[r][c] = True
            dq.append((r, c))

    for r in range(H):
        seed(r, 0); seed(r, W - 1)
    for c in range(W):
        seed(0, c); seed(H - 1, c)
    while dq:
        r, c = dq.popleft()
        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nr, nc = r + dr, c + dc
            if 0 <= nr < H and 0 <= nc < W and not lit[nr][nc] and not out[nr][nc]:
                out[nr][nc] = True
                dq.append((nr, nc))
    return out


# ---- A: Prism Sweep --------------------------------------------
WW_BODY = (0, 255, 255)     # bright cyan
WW_TOP = (255, 255, 255)    # white highlight on the heading's top char row
WW_FLAIR = (255, 0, 255)    # bright magenta BBS gradient wedges
BLACK = (0, 0, 0)

GAP2 = 1                    # ODYSSEY letter spacing
# Metric centre of the 55-col word on a 64-col canvas is col 4.5; the fat
# round O vs the thin pointy trailing Y also make the word visually
# left-heavy. Bias one col right (col 5) so it reads optically centred and
# lines up with the heading.
LEFT2 = (W - (len(WORD) * LW + (len(WORD) - 1) * GAP2)) // 2 + 1


def prism():
    TOP = WW_CH + 1                        # first ODYSSEY char row
    H = TOP + 7 + 1                        # heading, gap, 7 letter rows, pad
    SUB = H * 2
    canvas = [[(" ", BLACK) for _ in range(W)] for _ in range(H)]

    # --- "WIRE WRAP" heading: half-block glyphs on black ---
    for cr, c, g in place_ww():
        canvas[cr][c] = (g, WW_TOP if cr == 0 else WW_BODY)
    for r in range(WW_CH):                 # BBS chrome-end gradient wedges
        for i, g in enumerate((LIGHT, MED, DARK, FULL)):        # ░▒▓█  ->
            canvas[r][1 + i] = (g, WW_FLAIR)
        for i, g in enumerate((FULL, DARK, MED, LIGHT)):        # <-  █▓▒░
            canvas[r][W - 5 + i] = (g, WW_FLAIR)

    # --- ODYSSEY: flat. Rasterize the 14-px font into a 2x-vertical grid,
    #     then fold each sub-pixel pair to █ / ▀ / ▄ in the letter colour. ---
    ink = [[None] * W for _ in range(SUB)]
    base = TOP * 2
    x = LEFT2
    for li, ch in enumerate(WORD):
        for r, line in enumerate(FONT2[ch]):
            for cc, p in enumerate(line):
                if p == "#":
                    ink[base + r][x + cc] = PRISM[li]
        x += LW + GAP2
    for cr in range(H):
        for c in range(W):
            t, b = ink[cr * 2][c], ink[cr * 2 + 1][c]
            if t and b:
                canvas[cr][c] = (FULL, t)
            elif t:
                canvas[cr][c] = (UPPER, t)
            elif b:
                canvas[cr][c] = (LOWER, b)
    return canvas


# ---- B: Chrome Bevel -------------------------------------------------
def chrome():
    m = placed_mask()
    H = LH + 4
    canvas = [blank_row() for _ in range(H)]
    lit = [[False] * W for _ in range(H)]
    for r in range(LH):
        for c in range(W):
            if m[r][c] >= 0:
                lit[r + 1][c] = True
    out = flood_outside(lit, H)
    # one coherent drop shadow: whole silhouette offset +1,+1
    for r in range(H):
        for c in range(W):
            if lit[r][c]:
                continue
            if r > 0 and c > 0 and lit[r - 1][c - 1] and out[r][c]:
                canvas[r][c] = (LIGHT, CH_SH)
    for r in range(LH):
        for c in range(W):
            if m[r][c] < 0:
                continue
            top = r == 0 or m[r - 1][c] < 0
            left = c == 0 or m[r][c - 1] < 0
            bot = r == LH - 1 or m[r + 1][c] < 0
            right = c == W - 1 or m[r][c + 1] < 0
            if top or left:
                canvas[r + 1][c] = (FULL, CH_HI)
            elif bot or right:
                canvas[r + 1][c] = (DARK, CH_LOW)
            else:
                canvas[r + 1][c] = (FULL, CH_BODY)
    cap = blank_row(); put_text(cap, "ODYSSEY  OS  v1.0", GREY)
    canvas += [blank_row(), cap]
    return canvas


# ---- C: CRT Phosphor ----------------------------------------------
def phosphor():
    m = placed_mask()
    H = LH + 2
    canvas = [blank_row() for _ in range(H)]
    lit = [[False] * W for _ in range(H)]
    for r in range(LH):
        for c in range(W):
            if m[r][c] >= 0:
                lit[r + 1][c] = True
    out = flood_outside(lit, H)
    for rr in range(H):
        for cc in range(W):
            if lit[rr][cc] or not out[rr][cc]:
                continue
            if any(0 <= rr + dr < H and 0 <= cc + dc < W and lit[rr + dr][cc + dc]
                   for dr in (-1, 0, 1) for dc in (-1, 0, 1)):
                canvas[rr][cc] = (LIGHT, PH_HALO)
    for r in range(LH):
        for c in range(W):
            if m[r][c] >= 0:
                canvas[r + 1][c] = (FULL, PH_HI if r % 2 == 0 else PH_MID)
    cap = blank_row(); put_text(cap, "ODYSSEY  OS  v1.0", PH_MID)
    canvas.append(cap)
    return canvas


# ---- D: Box-Rule Nameplate --------------------------------------
def nameplate():
    m = placed_mask()
    TOP = 3
    H = TOP + LH + 2
    canvas = [blank_row() for _ in range(H)]
    for c in range(W):
        canvas[0][c] = ("═", NP_FRAME)
        canvas[H - 1][c] = ("═", NP_FRAME)
    for r in range(1, H - 1):
        canvas[r][0] = canvas[r][W - 1] = ("║", NP_FRAME)
    canvas[0][0] = ("╔", NP_FRAME); canvas[0][W - 1] = ("╗", NP_FRAME)
    canvas[H - 1][0] = ("╚", NP_FRAME); canvas[H - 1][W - 1] = ("╝", NP_FRAME)
    tab = "╡ ODYSSEY OS v1.0 ╞"
    x = (W - len(tab)) // 2
    for i, chx in enumerate(tab):
        canvas[0][x + i] = (chx, NP_FRAME if chx in "╡╞" else NP_TAB)
    for r in range(LH):
        for c in range(W):
            if m[r][c] >= 0:
                canvas[TOP + r][c] = (FULL, PRISM[m[r][c]])   # rainbow fill
    return canvas


DIRS = [
    ("prism",     "A · Prism Sweep",        prism),
    ("chrome",    "B · Synthwave Bevel",    chrome),
    ("phosphor",  "C · CRT Phosphor",       phosphor),
    ("nameplate", "D · Rainbow Nameplate",  nameplate),
]


def serialize(rows):
    out = [RESET, "\n"]
    for row in rows:
        line, cur = [BG], None
        for chx, color in row:
            if chx == " ":
                line.append(" "); continue
            if color != cur:
                line.append(fg(color)); cur = color
            line.append(chx)
        line.append(RESET + "\n")
        out.append("".join(line))
    out.append(RESET + "\n")
    return "".join(out)


def hexdump(rows, kind):
    lines = []
    for row in rows:
        vals = []
        for chx, color in row:
            if kind == "chr":
                vals.append(CP437.get(chx, 0x20))
            else:
                vals.append(0x00 if chx == " " else color_byte(color))
        lines.append(" ".join(f"{v:02X}" for v in vals))
    return "\n".join(lines) + "\n"


# ------------------------------------------------------------------------
# Compressed boot-sector build.  Target: <= 448 bytes so the whole thing
# fits the FAT16 bootstrap code area of sector 0.  The boot hook checks
# bytes 0..2 for 'ODY' and, if present, relocates + CALLs this; it RETs
# once the banner is painted.
#
# SELF-CONTAINED: no CALL/JMP leaves this code, no BIOS symbols, no heap,
# no VARs.  memfill / memcpy are inlined as the local .fill / .copy
# helpers, so the loader needs no symbol table to place it.  The caller
# owns setup (screen is already clear on entry) and teardown (cursor
# re-init happens after we RET); registers are ours to trash.
#
# Representation:
#   .glut  4    2-bit glyph code -> CP437 byte:  0x20 0xdc 0xdf 0xdb
#   .wpat  6    heading chrome-wedge shade run:  b0 b1 b2 b2 b1 b0
#   .roys  7    ODYSSEY per-letter colour, one byte each (ROYGBIV)
#   .gmap  192  12 rows x 16 bytes; each byte = four cells, 2 bits/cell
#               (cell k in bits 2k..2k+1), code = glut index.  fb rows
#               0..11 in order -- every cell is written, no clear needed.
#
# The colour plane is painted with four .fill runs (heading magenta, then
# the white/cyan mid-spans) plus a seven-run .fill loop rebuilding the
# ODYSSEY colour band from .roys; a self-overlapping .copy then replicates
# that band down fb rows 5..10.  The glyph plane is unpacked cell by cell
# through .glut.  Finally the wedge shade glyphs (b0/b1/b2) overwrite the
# solid blocks at each heading-wedge end.
# ------------------------------------------------------------------------

GLUT = [0x20, 0xDC, 0xDF, 0xDB]              # code 0..3 -> glyph
WPAT = [0xB0, 0xB1, 0xB2, 0xB2, 0xB1, 0xB0]  # wedge shades: L run then R run
GCODE = {0x20: 0, 0xDC: 1, 0xDF: 2, 0xDB: 3, 0xB0: 3, 0xB1: 3, 0xB2: 3}
FB_ROWS = list(range(12))                     # all 12 fb rows -> .gmap (192 B)
CBND_LO, CBND_HI = 4, 59                      # .cbnd stores colband[4:59] (55 B)
WEDGE_COLOR_COLS = {1, 2, 3, 4, 59, 60, 61, 62}

ASM_BODY = """# vim: syntax=asm-mycpu
# prismban - compressed Wire Wrap Odyssey boot banner (<=448 B, boot-sector fit).
# Generated by gen.py -- do not hand-edit; edit the generator.
#
# SELF-CONTAINED: no CALL/JMP outside this file's own code, no BIOS
# symbols, no heap, no VARs.  The only control transfer in/out is the
# entry (caller CALLs the first byte) and the final RET.  memfill/memcpy
# are the local .fill/.copy helpers below.
#
# Boot-sequence contract -- the caller does setup and teardown:
#   * the screen is already cleared when we are entered
#   * we only paint the framebuffer: glyph plane 0x4000, colour 0x5000
#   * cursor positioning / re-init is the caller's job after we RET
#   * registers are ours to trash; nothing is passed in or out
#
# Table layout (bytes): .glut 4  .wpat 6  .roys 7  .gmap 192.
# Every framebuffer cell in fb rows 0..11 is written, so no clear needed.

:main
# ---- colour plane -> 0x5000 ----------------------------------------
# Heading rows 0-2: paint the whole span magenta first (that colours the
# chrome wedges at cols 0-4 / 59-63), then repaint the middle cols 5-58
# white (row 0) / cyan (rows 1-2).  fb rows 3 and 11 are never written
# here -- every glyph there is a space, so their colour bytes don't show.
LDI_C 0x5000
LDI_AH 0x33
LDI_AL 0xbf
CALL .fill                             # fb rows 0-2 = magenta
LDI_C 0x5005
LDI_AH 0x3f
LDI_AL 0x35
CALL .fill                             # fb row 0 cols 5-58 = white
LDI_C 0x5045
LDI_AH 0x0f
LDI_AL 0x35
CALL .fill                             # fb row 1 cols 5-58 = cyan
LDI_C 0x5085
LDI_AL 0x35
CALL .fill                             # fb row 2 cols 5-58 = cyan (AH kept)
# fb row 4 colour band: seven 7-wide ROYGBIV runs, 1-col gaps left clear.
# Starts at col 5 (0x5105) to match LEFT2 -- keep in sync with gen.py.
LDI_C 0x5105
LDI_D .roys
LDI_BH 0x07
.cbld
LDA_D_AH
INCR_D
LDI_AL 0x06
CALL .fill                             # 7 cells of this letter's colour
INCR_C                                 # step over the 1-col gap
ALUOP_BH %B-1%+%BH%
JNZ .cbld
LDI_C 0x5100
LDI_D 0x5140
LDI_AL 0xff
CALL .copy                            # replicate 256 B (fb rows 5-8)
LDI_AL 0x7f
CALL .copy                            # replicate 128 B (fb rows 9-10)

# ---- glyph plane -> 0x4000 ---------------------------------------
LDI_C 0x4000
LDI_D .gmap
.p1lp
LDA_D_AH                               # AH = four packed 2-bit codes
INCR_D
CALL .cell                           # expands them to [C]..[C+3]
MOV_CH_AL
LDI_BL 0x43
ALUOP_FLAGS %A-B%+%AL%+%BL%            # C past the last fb row?
JNE .p1lp

# ---- heading chrome wedges: shade glyphs ------------------------
LDI_D 0x4001                           # fb row 0, col 1
LDI_BH 0x03                            # three heading rows
.wgrw
LDI_C .wpat
MEMCPY_C_D
MEMCPY_C_D
MEMCPY_C_D                             # cols 1-3  <- b0 b1 b2
INCR8_D
INCR8_D
INCR8_D
INCR8_D
INCR8_D
INCR8_D
INCR8_D                               # D: col 4 -> col 60
MEMCPY_C_D
MEMCPY_C_D
MEMCPY_C_D                             # cols 60-62 <- b2 b1 b0
INCR_D
INCR_D                                 # D -> next row, col 1
ALUOP_BH %B-1%+%BH%                    # row countdown (B-side decrement)
JNZ .wgrw

RET

# ---- .cell: unpack AH (four 2-bit codes) to four glyphs at [C] ----
.cell
LDI_BL 0x03
ALUOP_AL %A&B%+%AH%+%BL%               # AL = code
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A>>1%+%AH%                   # shift next code down
ALUOP_PUSH %A%+%AH%                    # stash remaining codes
LDI_AH 0x00
LDI_B .glut
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH%
LDA_B_AL                               # AL = glut[code]  (16-bit index, page-safe)
POP_AH                                 # restore remaining codes
ALUOP_ADDR_C %A%+%AL%                  # store glyph
INCR_C
MOV_CL_AL
LDI_BL 0x03
ALUOP_FLAGS %A&B%+%AL%+%BL%            # back to a 4-cell boundary?
JNZ .cell
RET

# ---- .fill: [C..C+AL] <- AH, one byte at a time.  On return C is one
#      past the last byte written; AH, B and D are unchanged (DL is
#      saved/restored), AL is consumed.  This is :memfill's inner loop.
.fill
PUSH_DL
ALUOP_DL %A%+%AH%                      # fill byte -> DL (faster to loop on)
.fill_loop
STA_C_DL
INCR_C
ALUOP_AL %A-1%+%AL%
JNO .fill_loop
POP_DL
RET

# ---- .copy: [C..] -> [D..] for AL+1 bytes, one byte at a time.  C and
#      D are left one past the range; AL is consumed; TD is clobbered.
#      Ascending byte order, so a self-overlapping range acts as a
#      pattern replicate.  This is :memcpy's inner loop.
.copy
MEMCPY_C_D
ALUOP_AL %A-1%+%AL%
JNO .copy
RET
"""


def _row_bytes(rows, fb):
    out = []
    for k in range(0, W, 4):
        b = 0
        for j in range(4):
            b |= GCODE[CP437.get(rows[fb][k + j][0], 0x20)] << (2 * j)
        out.append(b)
    return out


def emit_asm(rows):
    # verify the positional colour model the unpacker relies on
    band = [0] * W
    for c in range(W):
        for r in range(4, 11):
            v = 0x00 if rows[r][c][0] == " " else color_byte(rows[r][c][1])
            if v:
                band[c] = v
                break
    for r in range(12):
        for c in range(W):
            g, rgb = rows[r][c]
            if g == " ":
                continue
            v = color_byte(rgb)
            if r <= 2:
                want = 0x33 if (c <= 4 or c >= 59) else (0x3f if r == 0 else 0x0f)
            elif r in (3, 11):
                want = v
            else:
                want = band[c]
            assert v == want, f"colour model break at r{r} c{c}: {v:#x} != {want:#x}"

    # the unpacker rebuilds the colour band from 7 ROYGBIV run values; it
    # assumes cols 0..4 clear (LEFT2), then seven 7-wide runs each followed
    # by one clear gap col (5+7*8 = 61), then clear to the edge.  Assert that
    # shape -- the .cbld loop's LDI_C 0x5105 must match this start column.
    assert band[:5] == [0] * 5 and band[60:] == [0] * 4
    roys = []
    for i in range(7):
        run = band[5 + 8 * i: 5 + 8 * i + 7]
        assert len(set(run)) == 1 and run[0] != 0, run
        assert band[5 + 8 * i + 7] == 0
        roys.append(run[0])

    gmap = []
    for fb in FB_ROWS:
        gmap += _row_bytes(rows, fb)
    assert len(gmap) == 16 * len(FB_ROWS)

    def dl(label, vals):
        return label + " " + " ".join(f"0x{v:02x}" for v in vals) + "\n"

    out = [ASM_BODY, "\n",
           dl(".glut", GLUT),
           dl(".wpat", WPAT),
           dl(".roys", roys),
           dl(".gmap", gmap)]
    return "".join(out)


here = os.path.dirname(os.path.abspath(__file__))
allparts = [RESET, "\n"]
hdr = ["/* Odyssey boot banners -- blit .chr to 0x4000, .clr to 0x5000. */\n"]
for name, label, build in DIRS:
    rows = build()
    open(os.path.join(here, name + ".ans"), "w", encoding="utf-8").write(serialize(rows))
    chr_s = hexdump(rows, "chr"); clrs = hexdump(rows, "clr")
    open(os.path.join(here, name + ".chr"), "w").write(chr_s)
    open(os.path.join(here, name + ".clr"), "w").write(clrs)
    if name == "prism":
        n = len(clrs.split())
        assert n % W == 0 and n <= 60 * W, "banner must be whole rows, fit 0x4000 plane"
        open(os.path.join(here, "prismban.asm"), "w").write(emit_asm(rows))
    rowct = len(rows)
    hdr.append(f"\n/* {label} : {rowct} rows x 64 cols */\n")
    flat_c = [int(x, 16) for x in chr_s.split()]
    flat_k = [int(x, 16) for x in clrs.split()]
    hdr.append(f"const unsigned char {name}_chr[{len(flat_c)}] = {{"
               + ",".join(str(v) for v in flat_c) + "};\n")
    hdr.append(f"const unsigned char {name}_clr[{len(flat_k)}] = {{"
               + ",".join(str(v) for v in flat_k) + "};\n")
    lbl = f"{ESC}[38;2;120;120;120m-- {label} " + "-" * (W - len(label) - 4) + RESET + "\n"
    allparts += [lbl, serialize(rows)]

open(os.path.join(here, "preview-all.ans"), "w", encoding="utf-8").write("".join(allparts))
open(os.path.join(here, "banners.h"), "w").write("".join(hdr))

print("wrote per direction: .ans .chr .clr   + preview-all.ans + banners.h")
for name, _, _ in DIRS:
    p = os.path.join(here, name + ".ans")
    print(f"  {name:10s} {os.path.getsize(p):5d} b ans")
