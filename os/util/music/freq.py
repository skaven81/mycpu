#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Frequency-string parsing and equal-temperament pitch/MIDI/frequency math."""

import re

_FREQ_RE = re.compile(
    r'^\s*(?P<num>[0-9]*\.?[0-9]+)\s*(?P<suffix>Hz|kHz|k|MHz|M)?\s*$',
    re.IGNORECASE,
)

_SUFFIX_MULTIPLIERS = {
    '': 1.0,
    'hz': 1.0,
    'k': 1e3,
    'khz': 1e3,
    'm': 1e6,
    'mhz': 1e6,
}


def parse_frequency(s: str) -> float:
    """Parse a frequency string ('1843200', '1.8432MHz', '1843.2k',
    '32.768kHz') into a value in Hz. Raises ValueError on unparseable input."""
    m = _FREQ_RE.match(s)
    if not m:
        raise ValueError(f"invalid frequency: {s!r}")
    suffix = (m.group('suffix') or '').lower()
    return float(m.group('num')) * _SUFFIX_MULTIPLIERS[suffix]


_SEMITONE = {'c': 0, 'd': 2, 'e': 4, 'f': 5, 'g': 7, 'a': 9, 'b': 11}
_PITCH_RE = re.compile(r'^([A-Ga-g])([#b]?)(-?\d+)$')


def pitch_to_midi(pitch: str) -> int:
    """Parse scientific pitch notation ('C4', 'A#3', 'Bb5') into a MIDI
    note number (C4 = 60). Raises ValueError on unparseable input."""
    m = _PITCH_RE.match(pitch)
    if not m:
        raise ValueError(f"invalid pitch: {pitch!r}")
    letter, accidental, octave = m.group(1).lower(), m.group(2), int(m.group(3))
    semitone = _SEMITONE[letter]
    if accidental == '#':
        semitone += 1
    elif accidental == 'b':
        semitone -= 1
    return (octave + 1) * 12 + semitone


def midi_to_freq(midi: int, a4_freq: float = 440.0) -> float:
    """Equal-temperament frequency for a MIDI note number (A4 = midi 69)."""
    return a4_freq * (2.0 ** ((midi - 69) / 12.0))


def pitch_to_freq(pitch: str, a4_freq: float = 440.0) -> float:
    """Scientific pitch notation directly to equal-temperament frequency."""
    return midi_to_freq(pitch_to_midi(pitch), a4_freq)
