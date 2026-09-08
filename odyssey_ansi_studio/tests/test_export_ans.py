"""Odyssey-native `.ANS` export: exact-byte goldens, coalescing, warnings."""

import random
import re

import pytest

from studio.io.export_ans import ExportResult, ansi_preview_text, export_ans
from studio.model.cell import Cell, is_control_glyph
from studio.model.document import Document
from studio.model.layers import BlankLayer

HOME = b"\x1b[H"


def _doc(cells):
    """A 64x60 doc with one blank layer; `cells` is {(col,row): Cell}."""
    doc = Document()
    layer = BlankLayer(name="L")
    for (col, row), cell in cells.items():
        layer.set_local(col, row, cell)
    doc.add_layer(layer)
    return doc


def _strip_escapes(data: bytes) -> bytes:
    return re.sub(rb"\x1b\[[0-9]*[Hp]", b"", data)


def test_single_cell_trimmed_golden():
    doc = _doc({(0, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[15p" + b"A"
    assert res.byte_count == len(res.data)
    assert res.rows_emitted == 1
    assert res.warnings == []


def test_horizontal_run_one_escape():
    doc = _doc({
        (0, 0): Cell(0x41, 0x0F),
        (1, 0): Cell(0x42, 0x0F),
        (2, 0): Cell(0x43, 0x0F),
    })
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[15p" + b"ABC"
    assert res.data.count(b"\x1b[15p") == 1


def test_attr_change_midrun_two_escapes():
    doc = _doc({
        (0, 0): Cell(0x41, 0x0F),
        (1, 0): Cell(0x42, 0x0C),
        (2, 0): Cell(0x43, 0x0C),
    })
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[15p" + b"A" + b"\x1b[12p" + b"BC"
    assert len(re.findall(rb"\x1b\[[0-9]+p", res.data)) == 2


def test_blink_bit_kept_in_v():
    doc = _doc({(0, 0): Cell(0x41, 0x8C)})  # blink set, no cursor
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[140p" + b"A"


def test_cursor_bit_masked_out_of_v():
    doc = _doc({(0, 0): Cell(0x41, 0x4F)})  # 0x4F -> 0x0F after masking 0x40
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[15p" + b"A"


def test_empty_document_is_home_only():
    res = export_ans(Document(), trim_trailing_blanks=True)
    assert res.data == HOME
    assert res.byte_count == 3
    assert res.rows_emitted == 0
    assert res.warnings == []


def test_no_trim_emits_full_plane():
    doc = _doc({(0, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=False)
    assert res.rows_emitted == 60
    # exactly one glyph byte per screen cell
    assert len(_strip_escapes(res.data)) == 64 * 60
    # home + first attr + switch-to-black, nothing more
    assert res.data.startswith(HOME + b"\x1b[15p" + b"A" + b"\x1b[0p" + b" ")


def test_control_glyph_warning_fires():
    doc = _doc({(2, 1): Cell(0x01, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert (2, 1, 1) in res.warnings
    assert len(res.warnings) == 1


def test_row_separator_count_matches_rows_emitted():
    doc = _doc({(0, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=False, row_separator=b"\r\n")
    assert res.rows_emitted == 60
    assert res.data.count(b"\r\n") == 60
    assert res.data.endswith(b"\r\n")


def test_row_separator_with_trim():
    doc = _doc({(0, 0): Cell(0x41, 0x0F), (5, 2): Cell(0x42, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True, row_separator=b"\n")
    # last non-blank is row 2 -> 3 rows emitted -> 3 separators
    assert res.rows_emitted == 3
    assert res.data.count(b"\n") == 3


def test_no_contributor_exports_space_black():
    # a gap between two set cells on the same row must become a space at attr 0
    doc = _doc({(0, 0): Cell(0x41, 0x0F), (2, 0): Cell(0x43, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    # A, then switch to black for the gap space, then back to 15 for C
    assert res.data == HOME + b"\x1b[15pA" + b"\x1b[0p " + b"\x1b[15pC"


def test_painted_nul_glyph_becomes_space_no_warning():
    doc = _doc({(0, 0): Cell(0x00, 0x25), (1, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    # NUL cell collapses to a space at attr 0 (its 0x25 attr is unrepresentable)
    assert res.data == HOME + b"\x1b[0p " + b"\x1b[15pA"
    assert res.warnings == []


def test_ansi_preview_text_shows_escapes():
    doc = _doc({(0, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    txt = ansi_preview_text(res)
    assert "\x1b" not in txt
    assert txt == "␛[H␛[15pA"


def test_returns_export_result_type():
    res = export_ans(Document())
    assert isinstance(res, ExportResult)
    assert isinstance(res.data, bytes)


# ==========================================================================
# QA hardening pass (Phase 2) -- appended adversarial cases.
# ==========================================================================

def _decode_ans(data: bytes):
    """Parse a no-separator `.ANS` stream into (list_of_v, [(v, glyph), ...]).

    Relies on the stream containing no glyph byte == 0x1B (the caller keeps
    random glyphs in 0x20..0xFF); that ambiguity is *why* the exporter warns
    on control glyphs.
    """
    assert data[:3] == HOME, data[:8]
    i = 3
    emitted_vs = []
    cells = []
    cur = None
    while i < len(data):
        if data[i] == 0x1B:
            assert data[i + 1] == 0x5B, data[i:i + 4]      # ESC [
            j = i + 2
            while j < len(data) and 0x30 <= data[j] <= 0x39:
                j += 1
            assert data[j] == 0x70, data[i:j + 1]          # 'p'
            n = int(data[i + 2:j])
            emitted_vs.append(n)
            cur = n
            i = j + 1
        else:
            cells.append((cur, data[i]))
            i += 1
    return emitted_vs, cells


def _random_doc(rng):
    doc = Document()
    for li in range(rng.randint(1, 3)):
        layer = BlankLayer(name=f"L{li}")
        layer.offx = rng.randint(-3, 6)
        layer.offy = rng.randint(-3, 4)
        for _ in range(rng.randint(1, 60)):
            lc = rng.randint(0, 66)
            lr = rng.randint(0, 30)
            glyph = rng.randint(0x20, 0xFF)   # keep 0x1B out of the stream
            attr = rng.randint(0, 0xFF)       # cursor bit may be set
            layer.cells[(lc, lr)] = Cell(glyph, attr)
        doc.add_layer(layer)
    return doc


def test_run_length_invariant_property():
    rng = random.Random(0xA115)
    for _ in range(40):
        doc = _random_doc(rng)
        res = export_ans(doc, trim_trailing_blanks=True)
        data = res.data

        # (a) starts with ESC[H
        assert data.startswith(HOME)

        emitted_vs, cells = _decode_ans(data)

        # (b) every ESC[<n>p is in range and differs from the previous one
        assert all(0 <= n <= 255 for n in emitted_vs)
        assert all(a != b for a, b in zip(emitted_vs, emitted_vs[1:]))
        if cells:
            assert cells[0][0] is not None       # first cell always sets v

        # (c) stripping escapes yields exactly the emitted glyph bytes
        stripped = re.sub(rb"\x1b\[[0-9]*[Hp]", b"", data)
        assert stripped == bytes(g for _v, g in cells)
        assert len(cells) <= doc.width * doc.height

        # (d) reconstructed planes == composite() over the emitted region
        char_plane, color_plane = doc.composite()
        for off, (v, glyph) in enumerate(cells):
            cc = char_plane[off]
            if cc == 0x00:
                assert glyph == 0x20 and v == 0x00
            else:
                assert glyph == cc
                assert v == (color_plane[off] & 0xBF)

        # rows_emitted is the ceil of the emitted cell count
        exp_rows = (len(cells) + doc.width - 1) // doc.width
        assert res.rows_emitted == exp_rows


def test_trim_last_nonblank_exactly_at_row_end():
    doc = _doc({(63, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.rows_emitted == 1
    _vs, cells = _decode_ans(res.data)
    assert len(cells) == 64
    assert cells[-1] == (0x0F, 0x41)
    assert all(g == 0x20 and v == 0x00 for v, g in cells[:63])


def test_trim_last_nonblank_at_index_zero():
    doc = _doc({(0, 0): Cell(0x41, 0x0F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[15p" + b"A"
    assert res.rows_emitted == 1


def test_trim_only_far_corner_cell_set():
    doc = _doc({(63, 59): Cell(0x2A, 0x1F)})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.rows_emitted == 60
    _vs, cells = _decode_ans(res.data)
    assert len(cells) == 64 * 60
    assert cells[-1] == (0x1F, 0x2A)
    assert all(g == 0x20 and v == 0x00 for v, g in cells[:-1])


def test_all_blank_doc_trims_to_home_only():
    doc = _doc({})
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME
    assert res.rows_emitted == 0


def test_row_separator_crlf_count_and_terminator():
    rng = random.Random(99)
    doc = _random_doc(rng)
    res = export_ans(doc, trim_trailing_blanks=True, row_separator=b"\r\n")
    assert res.rows_emitted >= 1
    assert res.data.count(b"\r\n") == res.rows_emitted
    assert res.data.endswith(b"\r\n")


def test_blink_and_cursor_in_same_byte_exports_v_0x85():
    doc = _doc({(0, 0): Cell(0x41, 0xC5)})   # blink 0x80 | cursor 0x40 | 0x05
    res = export_ans(doc, trim_trailing_blanks=True)
    assert res.data == HOME + b"\x1b[133p" + b"A"   # 0xC5 & 0xBF == 0x85 == 133
    vs, _cells = _decode_ans(res.data)
    assert vs == [0x85]


def test_warnings_are_row_major_and_cover_every_control_cell_once():
    cells = {
        (10, 5): Cell(0x1F, 0x0F),
        (2, 5): Cell(0x07, 0x0F),
        (40, 1): Cell(0x00, 0x0F),   # NUL -> collapses to space, NOT a warning
        (3, 1): Cell(0x7F, 0x0F),
        (0, 9): Cell(0x0D, 0x0F),
        (63, 5): Cell(0x41, 0x0F),   # printable, no warning
    }
    res = export_ans(_doc(cells), trim_trailing_blanks=True)
    # row-major (row, then col); the NUL cell is absent
    assert res.warnings == [
        (3, 1, 0x7F),
        (2, 5, 0x07),
        (10, 5, 0x1F),
        (0, 9, 0x0D),
    ]
    # every control-glyph cell appears exactly once
    coords = [(c, r) for (c, r, _g) in res.warnings]
    assert len(coords) == len(set(coords))
    for (c, r, g) in res.warnings:
        assert is_control_glyph(g)


# ==========================================================================
# Portable 16-color export (export_ans16)
# ==========================================================================

from studio.io.export_ans import export_ans16   # noqa: E402
from studio.model.palette import ANSI16          # noqa: E402


def test_ans16_starts_home_and_uses_sgr_not_p_escape():
    doc = _doc({(0, 0): Cell(0x41, 0x2A), (1, 0): Cell(0x42, 0x20)})
    res = export_ans16(doc)
    assert res.data.startswith(HOME)
    assert b"p" not in res.data.replace(b"\x1b[H", b"")   # no ESC[<v>p
    assert b"\x1b[0m" in res.data
    # 0x2A == white == SGR 37, 0x20 == red == SGR 31
    assert b"\x1b[37m" in res.data and b"\x1b[31m" in res.data
    assert b"A" in res.data and b"B" in res.data


def test_ans16_snaps_offpalette_color_to_nearest():
    # 0x15 is exact "bright black"; a near color should snap to the same SGR.
    doc = _doc({(0, 0): Cell(0xDB, 0x15)})
    res = export_ans16(doc)
    assert f"[{ANSI16[0x15][0]}m".encode() in res.data


def test_ans16_blink_emits_sgr5_and_warns_on_control_glyph():
    doc = _doc({(0, 0): Cell(0x03, 0x20 | 0x80)})   # blinking heart
    res = export_ans16(doc, trim_trailing_blanks=True)
    assert b"\x1b[5m" in res.data
    assert res.warnings == [(0, 0, 0x03)]


def test_ans16_row_separator_default_is_crlf():
    doc = _doc({(0, 0): Cell(0x41, 0x2A)})
    res = export_ans16(doc)
    assert res.data.endswith(b"\r\n")        # a separator trails every row
    assert res.rows_emitted == 1


# ==========================================================================
# null_mode: how empty cells are written
# ==========================================================================

from studio.io.export_ans import NULL_MODES   # noqa: E402


def test_null_mode_space_is_the_default_and_unchanged():
    doc = _doc({(0, 0): Cell(0x41, 0x2A)})
    a = export_ans(doc)
    b = export_ans(doc, null_mode="space")
    assert a.data == b.data
    assert b"\x1b[H" in a.data


def test_null_mode_null_writes_zero_bytes_for_empties():
    doc = _doc({(2, 0): Cell(0x41, 0x2A)})
    r = export_ans(doc, null_mode="null", trim_trailing_blanks=False)
    body = r.data[len(HOME):]
    # first two cells are empty -> two 0x00 glyph bytes before the 'A'
    assert body.startswith(b"\x1b[0p\x00\x00")  # attr 0 set once, then two NULs


def test_null_mode_block_writes_black_full_blocks():
    doc = _doc({(2, 0): Cell(0x41, 0x2A)})
    r = export_ans(doc, null_mode="block", trim_trailing_blanks=False)
    body = r.data[len(HOME):]
    assert body.startswith(b"\x1b[0p\xdb\xdb")   # two 0xDB blocks, attr 0


def test_null_mode_transparent_skips_with_cursor_control():
    doc = _doc({(3, 0): Cell(0x41, 0x2A), (10, 0): Cell(0x43, 0x2A),
                (1, 1): Cell(0x42, 0x20)})
    r = export_ans(doc, null_mode="transparent")
    # exact stream: absolute row position, cursor-forward over empties, then glyph
    assert r.data == (
        # row 0: home, skip 3, set attr, 'A', skip 6, re-assert attr, 'C'
        b"\x1b[1;1H\x1b[3C\x1b[42pA\x1b[6C\x1b[42pC"
        # row 1: home to row 2, skip 1, set attr, 'B'
        + b"\x1b[2;1H\x1b[1C\x1b[32pB"
    )
    assert not r.data.startswith(HOME)                   # no ESC[H in transparent mode


def test_null_mode_rejects_unknown():
    import pytest
    with pytest.raises(ValueError):
        export_ans(_doc({}), null_mode="bogus")
    assert set(NULL_MODES) == {"space", "null", "block", "transparent"}
