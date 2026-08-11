import pytest
from fractions import Fraction
from abcnotation import (
    ParseError,
    key_signature_accidentals,
    parse_unit_length,
    parse_tempo,
    detect_format,
)


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
