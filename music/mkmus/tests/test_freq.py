import pytest
from freq import parse_frequency, pitch_to_midi, midi_to_freq, pitch_to_freq


def test_parse_frequency_bare_hz():
    assert parse_frequency("1843200") == 1843200.0


def test_parse_frequency_mhz_suffix():
    assert parse_frequency("1.8432MHz") == 1843200.0


def test_parse_frequency_k_suffix_no_hz():
    assert parse_frequency("1843.2k") == 1843200.0


def test_parse_frequency_khz_suffix():
    assert parse_frequency("32.768kHz") == pytest.approx(32768.0)


def test_parse_frequency_invalid():
    with pytest.raises(ValueError):
        parse_frequency("not-a-frequency")


def test_pitch_to_midi_middle_c():
    assert pitch_to_midi("C4") == 60


def test_pitch_to_midi_a4():
    assert pitch_to_midi("A4") == 69


def test_pitch_to_midi_sharp():
    assert pitch_to_midi("A#3") == 58


def test_pitch_to_midi_flat():
    assert pitch_to_midi("Bb5") == 82


def test_pitch_to_midi_invalid():
    with pytest.raises(ValueError):
        pitch_to_midi("H4")


def test_midi_to_freq_a4():
    assert midi_to_freq(69) == 440.0


def test_midi_to_freq_c4():
    assert midi_to_freq(60) == pytest.approx(261.6255653, rel=1e-6)


def test_pitch_to_freq_a4():
    assert pitch_to_freq("A4") == 440.0
