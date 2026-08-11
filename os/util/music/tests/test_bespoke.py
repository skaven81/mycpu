import pytest
from bespoke import parse_bespoke, ParseError
from freq import pitch_to_freq


def test_parse_bespoke_basic_note():
    notes = parse_bespoke("A4 /4 hello\n")
    assert len(notes) == 1
    n = notes[0]
    assert n.freq == pitch_to_freq("A4")
    assert n.beats == 1.0
    assert n.comment == "hello"
    assert n.line == 1


def test_parse_bespoke_rest_lowercase_z():
    notes = parse_bespoke("z /8\n")
    assert notes[0].freq is None
    assert notes[0].beats == 0.5


def test_parse_bespoke_rest_uppercase_z():
    notes = parse_bespoke("Z /8\n")
    assert notes[0].freq is None


def test_parse_bespoke_no_comment():
    notes = parse_bespoke("C4 /4\n")
    assert notes[0].comment == ""


def test_parse_bespoke_comment_may_contain_spaces():
    notes = parse_bespoke("C4 /4 a whole sentence of comment\n")
    assert notes[0].comment == "a whole sentence of comment"


def test_parse_bespoke_skips_blank_and_comment_lines():
    text = "\n# a header comment\nA4 /4\n\n# trailing\nC4 /8 note\n"
    notes = parse_bespoke(text)
    assert len(notes) == 2
    assert notes[0].line == 3
    assert notes[1].line == 6


def test_parse_bespoke_duration_fractions():
    notes = parse_bespoke("A4 /4\nA4 /8\nA4 /16\n")
    assert [n.beats for n in notes] == [1.0, 0.5, 0.25]


def test_parse_bespoke_bad_pitch_raises_with_line():
    with pytest.raises(ParseError, match=r"line 1"):
        parse_bespoke("H9 /4\n")


def test_parse_bespoke_malformed_line_raises_with_line():
    with pytest.raises(ParseError, match=r"line 2"):
        parse_bespoke("A4 /4\nA4 nodenom\n")
