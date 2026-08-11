import struct
import pytest

from mkmus import detect_and_parse, build_records, insert_repeat_gaps, main, MkmusError
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


def test_insert_repeat_gaps_adds_silence_between_same_pitch_notes():
    notes = [Note(freq=440.0, beats=1.0, comment="a", line=1),
             Note(freq=440.0, beats=1.0, comment="b", line=2)]
    result = insert_repeat_gaps(notes, 10.0)
    assert len(result) == 3
    assert result[0] is notes[0]
    assert result[1].freq is None
    assert result[1].beats == pytest.approx(0.10)
    assert result[1].line == 2
    assert result[2] is notes[1]


def test_insert_repeat_gaps_zero_percent_is_a_no_op():
    notes = [Note(freq=440.0, beats=1.0, comment="a", line=1),
             Note(freq=440.0, beats=1.0, comment="b", line=2)]
    result = insert_repeat_gaps(notes, 0.0)
    assert result == notes


def test_insert_repeat_gaps_different_pitch_no_gap():
    notes = [Note(freq=440.0, beats=1.0, comment="a", line=1),
             Note(freq=493.88, beats=1.0, comment="b", line=2)]
    result = insert_repeat_gaps(notes, 10.0)
    assert len(result) == 2


def test_insert_repeat_gaps_skips_consecutive_rests():
    notes = [Note(freq=None, beats=1.0, comment="", line=1),
             Note(freq=None, beats=1.0, comment="", line=2)]
    result = insert_repeat_gaps(notes, 10.0)
    assert len(result) == 2


def test_insert_repeat_gaps_three_same_pitch_notes_gets_two_gaps():
    notes = [Note(freq=440.0, beats=1.0, comment="a", line=1),
             Note(freq=440.0, beats=1.0, comment="b", line=2),
             Note(freq=440.0, beats=1.0, comment="c", line=3)]
    result = insert_repeat_gaps(notes, 10.0)
    assert len(result) == 5
    assert [n.freq for n in result] == [440.0, None, 440.0, None, 440.0]


def test_main_default_repeat_gap_inserts_silence_record(tmp_path):
    text = "A4 /4 one\nA4 /4 two\n"
    src = tmp_path / "song.txt"
    src.write_text(text)
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    assert len(data) == 3 * 16 + 16  # 2 real notes + 1 gap + terminator
    divisor, duration, comment = struct.unpack(">HH12s", data[16:32])
    # default --repeat-gap 10 -> round(0.10 * (60/120) * 32768) = 1638
    assert divisor == 0
    assert duration == 1638


def test_main_repeat_gap_zero_matches_prior_no_gap_behavior(tmp_path):
    text = "A4 /4 one\nA4 /4 two\n"
    src = tmp_path / "song.txt"
    src.write_text(text)
    out = tmp_path / "song.MUS"
    rc = main(["--repeat-gap", "0", "-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    assert len(data) == 2 * 16 + 16


def test_main_negative_repeat_gap_clean_error(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    out = tmp_path / "song.MUS"
    rc = main(["--repeat-gap", "-5", "-o", str(out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "repeat-gap" in captured.err
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


def test_main_bespoke_zero_denominator_clean_error(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("C4 /0 boom\n")
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "line 1" in captured.err
    assert not out.exists()


def test_main_abc_zero_note_length_denominator_clean_error(tmp_path, capsys):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:t\nK:C\nC1/0\n")
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "line" in captured.err
    assert not out.exists()


def test_main_abc_zero_unit_length_clean_error(tmp_path, capsys):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:t\nK:C\nL:1/0\nCDEF\n")
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "line" in captured.err
    assert not out.exists()


def test_main_zero_tempo_clean_error(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    out = tmp_path / "song.MUS"
    rc = main(["--tempo", "0", "-o", str(out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "tempo" in captured.err
    assert not out.exists()


def test_main_bad_output_dir_clean_error(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    bad_out = tmp_path / "nonexistentdir" / "x.MUS"
    rc = main(["-o", str(bad_out), str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "cannot write" in captured.err
    assert not bad_out.exists()


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
