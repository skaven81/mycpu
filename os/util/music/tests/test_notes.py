import pytest
from notes import Note, ConversionError, note_to_divisor, note_to_duration_ticks


def test_note_to_divisor_hand_computed_a4():
    # A4 (440Hz) at the default 1.8432MHz tone clock -> divisor 4189
    assert note_to_divisor(440.0, 1843200.0, line=1) == 4189


def test_note_to_divisor_rest_is_zero():
    assert note_to_divisor(None, 1843200.0, line=1) == 0


def test_note_to_divisor_out_of_range_too_high():
    # freq so low the divisor overflows 65535
    with pytest.raises(ConversionError, match=r"line 3"):
        note_to_divisor(1.0, 1843200.0 * 100, line=3)


def test_note_to_divisor_out_of_range_zero():
    # freq so high the divisor rounds to 0 (reserved for rests)
    with pytest.raises(ConversionError, match=r"line 7"):
        note_to_divisor(10_000_000.0, 1843200.0, line=7)


def test_note_to_duration_ticks_quarter_note_120bpm():
    # quarter note (beats=1.0) at 120 BPM, default 32.768kHz beat clock
    assert note_to_duration_ticks(1.0, 120.0, 32768.0, line=1) == 16384


def test_note_to_duration_ticks_out_of_range_zero():
    with pytest.raises(ConversionError, match=r"line 9"):
        note_to_duration_ticks(0.0001, 500.0, 32768.0, line=9)


def test_note_to_duration_ticks_out_of_range_too_high():
    with pytest.raises(ConversionError, match=r"line 2"):
        note_to_duration_ticks(1000.0, 30.0, 1_000_000.0, line=2)


def test_note_dataclass_fields():
    n = Note(freq=440.0, beats=1.0, comment="hi", line=1)
    assert (n.freq, n.beats, n.comment, n.line) == (440.0, 1.0, "hi", 1)
