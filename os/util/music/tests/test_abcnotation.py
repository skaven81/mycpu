import pytest
from fractions import Fraction
from abcnotation import (
    ParseError,
    key_signature_accidentals,
    parse_unit_length,
    parse_tempo,
    detect_format,
    _tokenize_body_line,
    _tokens_to_notes,
)
from freq import midi_to_freq


def test_key_c_major_no_accidentals():
    assert key_signature_accidentals("C", line=1) == {}


def test_key_d_major_two_sharps():
    assert key_signature_accidentals("D", line=1) == {"F": 1, "C": 1}


def test_key_f_major_one_flat():
    assert key_signature_accidentals("F", line=1) == {"B": -1}


def test_key_bb_major_two_flats():
    assert key_signature_accidentals("Bb", line=1) == {"B": -1, "E": -1}


def test_key_a_minor_same_as_c_major():
    assert key_signature_accidentals("Am", line=1) == {}


def test_key_e_minor_same_as_g_major():
    assert key_signature_accidentals("Em", line=1) == {"F": 1}


def test_key_trailing_clef_annotation_ignored():
    assert key_signature_accidentals("D bass", line=1) == {"F": 1, "C": 1}


def test_key_modal_rejected():
    with pytest.raises(ParseError, match=r"line 4"):
        key_signature_accidentals("Dmix", line=4)


def test_key_unsupported_letter_rejected():
    with pytest.raises(ParseError, match=r"line 1"):
        key_signature_accidentals("Hmaj", line=1)


def test_parse_unit_length_eighth():
    assert parse_unit_length("1/8", line=1) == Fraction(1, 8)


def test_parse_unit_length_quarter():
    assert parse_unit_length("1/4", line=1) == Fraction(1, 4)


def test_parse_unit_length_invalid():
    with pytest.raises(ParseError, match=r"line 2"):
        parse_unit_length("eighth", line=2)


def test_parse_tempo_bare_number():
    assert parse_tempo("120", line=1) == 120.0


def test_parse_tempo_fraction_equals_number():
    assert parse_tempo("1/4=120", line=1) == 120.0


def test_parse_tempo_eighth_equals_number():
    # an eighth note at 240/min == a quarter note at 120/min
    assert parse_tempo("1/8=240", line=1) == pytest.approx(120.0)


def test_parse_tempo_invalid():
    with pytest.raises(ParseError, match=r"line 3"):
        parse_tempo("fast", line=3)


def test_detect_format_abc():
    text = "X:1\nT:Test\nK:C\nABC\n"
    assert detect_format(text) == "abc"


def test_detect_format_bespoke():
    text = "A4 /4 hello\nC4 /8\n"
    assert detect_format(text) == "bespoke"


def test_detect_format_bespoke_when_x_header_is_not_near_top():
    # a bespoke file that happens to have a comment line mentioning X: later
    # should still be treated as bespoke since it isn't in the first 5 lines
    text = "\n".join(["# c" + str(i) for i in range(6)] + ["X:1"])
    assert detect_format(text) == "bespoke"


def test_tokenize_body_line_notes_and_bar():
    tokens = _tokenize_body_line("CDE|F", line=1)
    assert tokens == [
        ("note", "C"), ("note", "D"), ("note", "E"),
        ("bar", None), ("note", "F"),
    ]


def test_tokenize_body_line_skips_comment_and_chord_annotation():
    tokens = _tokenize_body_line('C "Cmaj7" D % trailing comment', line=1)
    assert tokens == [("note", "C"), ("note", "D")]


def test_tokenize_body_line_rejects_chord():
    with pytest.raises(ParseError, match=r"line 2"):
        _tokenize_body_line("[CEG]", line=2)


def test_tokenize_body_line_rejects_grace_note():
    with pytest.raises(ParseError, match=r"line 3"):
        _tokenize_body_line("{c}D", line=3)


def test_tokenize_body_line_rejects_tuplet():
    with pytest.raises(ParseError, match=r"line 4"):
        _tokenize_body_line("(3CDE", line=4)


def test_tokenize_body_line_rejects_broken_rhythm():
    with pytest.raises(ParseError, match=r"line 5"):
        _tokenize_body_line("C>D", line=5)


def test_tokens_to_notes_plain_pitch_no_key():
    tokens = _tokenize_body_line("C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert len(notes) == 1
    assert notes[0].freq == midi_to_freq(60)  # uppercase C = MIDI 60
    assert notes[0].beats == pytest.approx(0.5)  # 1/8 whole note * 4


def test_tokens_to_notes_lowercase_is_one_octave_up():
    tokens = _tokenize_body_line("c", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(72)


def test_tokens_to_notes_octave_marks():
    tokens = _tokenize_body_line("C,c'", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(48)   # C, = one octave below C
    assert notes[1].freq == midi_to_freq(84)   # c' = one octave above c


def test_tokens_to_notes_rest():
    tokens = _tokenize_body_line("z2", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq is None
    assert notes[0].beats == pytest.approx(1.0)  # 2 * 1/8 whole * 4


def test_tokens_to_notes_length_modifiers():
    tokens = _tokenize_body_line("C2 C/2 C3/2 C//", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 4), {}, line=1)
    # unit length 1/4 -> beats = multiplier * 1/4 * 4 = multiplier
    assert [n.beats for n in notes] == [2.0, 0.5, 1.5, 0.25]


def test_tokens_to_notes_explicit_accidental_applies():
    tokens = _tokenize_body_line("^C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)  # C sharp


def test_tokens_to_notes_bar_scoped_accidental_carries_within_bar():
    tokens = _tokenize_body_line("^C C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)
    assert notes[1].freq == midi_to_freq(61)  # still sharp, same bar


def test_tokens_to_notes_bar_line_resets_accidental():
    tokens = _tokenize_body_line("^C | C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)
    assert notes[1].freq == midi_to_freq(60)  # natural again after the bar


def test_tokens_to_notes_key_signature_default_applies():
    key_acc = key_signature_accidentals("D", line=1)  # F#, C#
    tokens = _tokenize_body_line("F C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), key_acc, line=1)
    assert notes[0].freq == midi_to_freq(66)  # F# by key signature
    assert notes[1].freq == midi_to_freq(61)  # C# by key signature


def test_tokens_to_notes_explicit_natural_overrides_key():
    key_acc = key_signature_accidentals("D", line=1)  # F#, C#
    tokens = _tokenize_body_line("=F", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), key_acc, line=1)
    assert notes[0].freq == midi_to_freq(65)  # forced natural F


def test_tokens_to_notes_tie_merges_same_pitch():
    tokens = _tokenize_body_line("C-C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 4), {}, line=1)
    assert len(notes) == 1
    assert notes[0].beats == pytest.approx(2.0)
