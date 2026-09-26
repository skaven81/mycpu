import struct

import pytest

from mksfx import (
    SfxError, Step, bank_asm, bank_header, effect_name, load_effect, main,
    parse_sfx, step_to_record, sweep_steps,
)
from mus_writer import TERMINATOR


def unpack(rec):
    return struct.unpack(">HH12s", rec)


def test_tone_and_rest():
    steps = parse_sfx("tone A4 10\nrest 5\ntone 1k 2.5  # trailing comment\n")
    assert [(s.freq, s.ms, s.line) for s in steps] == [
        (440.0, 10.0, 1), (None, 5.0, 2), (1000.0, 2.5, 3)]


def test_comments_and_blank_lines_ignored():
    assert len(parse_sfx("# header\n\n   \ntone C5 10\n")) == 1


def test_sweep_endpoints_and_count():
    steps = sweep_steps(400.0, 1600.0, 100.0, 4.0, line=1)
    assert len(steps) == 25
    assert steps[0].freq == pytest.approx(400.0)
    assert steps[-1].freq == pytest.approx(1600.0)
    assert sum(s.ms for s in steps) == pytest.approx(100.0)
    # pitch-linear: constant ratio between steps
    ratios = [b.freq / a.freq for a, b in zip(steps, steps[1:])]
    assert max(ratios) == pytest.approx(min(ratios))


def test_sweep_single_step():
    steps = sweep_steps(500.0, 900.0, 3.0, 10.0, line=1)
    assert [(s.freq, s.ms) for s in steps] == [(500.0, 3.0)]


def test_repeat_and_nesting():
    text = "repeat 2\n tone C5 1\n repeat 3\n  tone D5 1\n end\nend\ntone E5 1\n"
    names = [round(s.freq) for s in parse_sfx(text)]
    c, d, e = 523, 587, 659
    assert names == [c, d, d, d, c, d, d, d, e]


@pytest.mark.parametrize("text, msg", [
    ("", "no tone"),
    ("beep C5 10", "unknown command"),
    ("tone C5", "takes 2"),
    ("tone H5 10", "invalid pitch"),
    ("tone C5 0", "positive"),
    ("rest -3", "positive"),
    ("repeat 0\nend", "positive integer"),
    ("repeat 2\ntone C5 1", "without 'end'"),
    ("end", "without 'repeat'"),
])
def test_parse_errors(text, msg):
    with pytest.raises(SfxError, match=msg):
        parse_sfx(text)


def test_record_layout_and_tick_rounding():
    warnings = []
    rec = step_to_record(Step(440.0, 10.0, 1), warnings.append)
    assert unpack(rec) == (round(1843200 / 440), round(327.68), b"\0" * 12)
    assert warnings == []


def test_rest_record_and_minimum_tick():
    warnings = []
    rec = step_to_record(Step(None, 0.001, 1), warnings.append)
    assert unpack(rec)[:2] == (0, 1)
    assert any("under" in w for w in warnings)


def test_half_period_warning():
    warnings = []
    step_to_record(Step(100.0, 3.0, 7), warnings.append)   # half period = 5 ms
    assert any("half a period" in w and "line 7" in w for w in warnings)


def test_duration_too_long():
    with pytest.raises(SfxError, match="limit"):
        step_to_record(Step(440.0, 3000.0, 1), lambda m: None)


def test_divisor_out_of_range():
    with pytest.raises(SfxError, match="divisor"):
        step_to_record(Step(10.0, 50.0, 1), lambda m: None)


def test_effect_name():
    assert effect_name("sfx/Line-Clear.sfx") == "line_clear"


def _bank(tmp_path):
    (tmp_path / "zap.sfx").write_text("tone C6 10\nrest 5\n")
    (tmp_path / "blip.sfx").write_text("tone A5 20\n")
    return [load_effect(str(tmp_path / n), lambda m: None) for n in ("zap.sfx", "blip.sfx")]


def test_bank_asm(tmp_path):
    asm = bank_asm(_bank(tmp_path), "sfx_bank")
    assert ":sfx_get" in asm
    assert ".sfx_table .sfx_zap .sfx_blip" in asm
    assert "\n.sfx_zap 0x" in asm and "\n.sfx_zap_1 0x00 0x00 " in asm
    term = " ".join(["0x00"] * 16)
    assert f".sfx_zap_end {term}" in asm and f".sfx_blip_end {term}" in asm


def test_bank_header(tmp_path):
    h = bank_header(_bank(tmp_path), "sfx_bank")
    assert "#define SFX_ZAP  0" in h
    assert "#define SFX_BLIP 1" in h
    assert "extern void *sfx_get(uint8_t id);" in h


def test_main_mus_output(tmp_path, monkeypatch):
    (tmp_path / "zap.sfx").write_text("tone C6 10\n")
    monkeypatch.chdir(tmp_path)
    assert main(["--mus", "zap.sfx"]) == 0
    data = (tmp_path / "ZAP.MUS").read_bytes()
    assert len(data) == 32 and data[16:] == TERMINATOR


def test_main_bank_output(tmp_path):
    (tmp_path / "zap.sfx").write_text("tone C6 10\n")
    out = tmp_path / "bank"
    assert main(["-o", str(out), str(tmp_path / "zap.sfx")]) == 0
    assert (tmp_path / "bank.asm").exists() and (tmp_path / "bank.h").exists()


def test_main_duplicate_names(tmp_path, capsys):
    (tmp_path / "a").mkdir()
    (tmp_path / "zap.sfx").write_text("tone C6 10\n")
    (tmp_path / "a" / "zap.sfx").write_text("tone C6 10\n")
    assert main(["--dry-run", str(tmp_path / "zap.sfx"), str(tmp_path / "a" / "zap.sfx")]) == 1
    assert "duplicate" in capsys.readouterr().err
