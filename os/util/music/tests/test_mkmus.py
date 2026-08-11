import struct
import pytest

from mkmus import detect_and_parse, build_records, main, MkmusError
from notes import Note, note_to_divisor, note_to_duration_ticks
from mus_writer import TERMINATOR, encode_record
from bespoke import parse_bespoke
from abcnotation import parse_abc


def test_detect_and_parse_bespoke():
    notes, tempo = detect_and_parse("A4 /4 hi\n", tune_arg=None)
    assert len(notes) == 1
    assert tempo is None


def test_detect_and_parse_tune_arg_invalid_for_bespoke():
    with pytest.raises(MkmusError, match="only valid for ABC"):
        detect_and_parse("A4 /4 hi\n", tune_arg=1)


def test_detect_and_parse_single_tune_abc_ignores_missing_tune_arg():
    text = "X:1\nT:T\nK:C\nCDEF\n"
    notes, tempo = detect_and_parse(text, tune_arg=None)
    assert len(notes) == 4


def test_detect_and_parse_multi_tune_requires_tune_arg():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    with pytest.raises(MkmusError, match="multiple tunes"):
        detect_and_parse(text, tune_arg=None)


def test_detect_and_parse_multi_tune_selects_requested_tune():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    notes, tempo = detect_and_parse(text, tune_arg=2)
    assert len(notes) == 4
    assert notes[0].freq is not None


def test_detect_and_parse_unknown_tune_number():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    with pytest.raises(MkmusError, match="not found"):
        detect_and_parse(text, tune_arg=99)


def test_build_records_basic():
    notes = [Note(freq=440.0, beats=1.0, comment="hi", line=1)]
    warnings = []
    records = build_records(notes, 1843200.0, 32768.0, 120.0, warnings)
    divisor, duration, comment = struct.unpack(">HH12s", records[0])
    assert divisor == 4189
    assert duration == 16384
    assert comment == b"hi" + b"\0" * 10
    assert warnings == []


def test_build_records_out_of_range_raises_mkmus_error():
    notes = [Note(freq=10_000_000.0, beats=1.0, comment="", line=5)]
    with pytest.raises(MkmusError, match="line 5"):
        build_records(notes, 1843200.0, 32768.0, 120.0, [])


def test_build_records_long_comment_warns():
    notes = [Note(freq=440.0, beats=1.0, comment="this is a very long comment", line=2)]
    warnings = []
    build_records(notes, 1843200.0, 32768.0, 120.0, warnings)
    assert len(warnings) == 1
    assert "line 2" in warnings[0]


def test_main_writes_mus_file(tmp_path):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\nz /8\n")
    out = tmp_path / "song.MUS"
    rc = main(["--tone-freq", "1843200", "--beat-freq", "32768",
               "-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    assert data.endswith(TERMINATOR)
    assert len(data) == 2 * 16 + 16  # 2 notes + terminator


def test_main_default_output_name(tmp_path, monkeypatch):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    monkeypatch.chdir(tmp_path)
    rc = main([str(src)])
    assert rc == 0
    assert (tmp_path / "SONG.MUS").exists()


def test_main_dry_run_writes_nothing(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    out = tmp_path / "song.MUS"
    rc = main(["--dry-run", "-o", str(out), str(src)])
    assert rc == 0
    assert not out.exists()
    captured = capsys.readouterr()
    assert "divisor=4189" in captured.out


def test_main_tune_required_for_multi_tune_file_exits_nonzero(tmp_path, capsys):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n")
    rc = main([str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "multiple tunes" in captured.err


def test_main_tempo_flag_overrides_abc_q_field(tmp_path):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:T\nK:C\nQ:1/4=60\nC\n")
    out = tmp_path / "song.MUS"
    rc = main(["--tempo", "120", "-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    divisor, duration, comment = struct.unpack(">HH12s", data[:16])
    # unit length default 1/8 -> beats=0.5; at 120 BPM: round(0.5*0.5*32768)=8192
    assert duration == 8192


def test_main_conversion_error_writes_no_partial_file(tmp_path):
    src = tmp_path / "song.txt"
    src.write_text("C4 /1000000 hi\n")  # absurd duration -> out of range
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc != 0
    assert not out.exists()


def _expected_bytes(parsed_notes, tone_freq, beat_freq, tempo):
    out = b""
    for note in parsed_notes:
        divisor = note_to_divisor(note.freq, tone_freq, note.line)
        duration = note_to_duration_ticks(note.beats, tempo, beat_freq, note.line)
        out += encode_record(divisor, duration, note.comment, note.line)
    return out + TERMINATOR


def test_end_to_end_bespoke_exact_bytes(tmp_path):
    text = "A4 /4 hello\nz /8\nC4 /4 world\n"
    src = tmp_path / "tune.txt"
    src.write_text(text)
    out = tmp_path / "tune.MUS"

    rc = main(["-o", str(out), str(src)])
    assert rc == 0

    expected = _expected_bytes(parse_bespoke(text), 1843200.0, 32768.0, 120.0)
    assert out.read_bytes() == expected


def test_end_to_end_abc_exact_bytes(tmp_path):
    text = "X:1\nT:Tune\nK:C\nL:1/8\nQ:1/4=100\nCDEF|GABc\nw:do re mi fa sol la ti do\n"
    src = tmp_path / "tune.abc"
    src.write_text(text)
    out = tmp_path / "tune.MUS"

    rc = main(["-o", str(out), str(src)])
    assert rc == 0

    tune = parse_abc(text)[0]
    expected = _expected_bytes(tune.notes, 1843200.0, 32768.0, tune.tempo_bpm)
    assert out.read_bytes() == expected
