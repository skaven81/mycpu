#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Bounded ABC v2.1 subset parser for mkmus.py.

Named abcnotation.py (not abc.py) deliberately: the stdlib has a module
named 'abc' (Abstract Base Classes), and os/util/music/ sits on sys.path
for both direct execution and tests, so 'abc.py' here would shadow it.
"""

import re
from dataclasses import dataclass, field
from fractions import Fraction

from notes import Note
from freq import midi_to_freq


class ParseError(Exception):
    """An ABC source line used an unsupported or malformed construct."""


def detect_format(text: str) -> str:
    """Return 'abc' if any of the first 5 non-blank lines is an X: header,
    else 'bespoke'."""
    lines = [ln for ln in text.splitlines() if ln.strip()][:5]
    for ln in lines:
        if re.match(r"^X:\s*\d+", ln.strip()):
            return "abc"
    return "bespoke"


_SHARP_ORDER = "FCGDAEB"
_FLAT_ORDER = "BEADGCF"

_MAJOR_KEY_SHARPS = {
    "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7,
    "F": -1, "Bb": -2, "Eb": -3, "Ab": -4, "Db": -5, "Gb": -6, "Cb": -7,
}

_MINOR_TO_MAJOR = {
    "A": "C", "E": "G", "B": "D", "F#": "A", "C#": "E", "G#": "B", "D#": "F#",
    "D": "F", "G": "Bb", "C": "Eb", "F": "Ab", "Bb": "Db", "Eb": "Gb", "Ab": "Cb",
}

_MODE_RE = re.compile(r"^([A-Ga-g])(#|b)?\s*(maj|major|min|minor|m)?$", re.IGNORECASE)


def key_signature_accidentals(key_field: str, line: int) -> dict:
    """Parse a K: field value ('D', 'Bbm', 'F#maj', 'Ador', ...) into a
    {LETTER: semitone_adjustment} default-accidental map. Raises
    ParseError for anything other than a plain major/minor key (modal
    keys like 'Dmix'/'Ador' are explicitly unsupported)."""
    stripped = key_field.strip()
    key_token = stripped.split()[0] if stripped else ""
    if key_token.upper() in ("", "NONE"):
        return {}
    m = _MODE_RE.match(key_token)
    if not m:
        raise ParseError(f"line {line}: unsupported key signature {key_field!r} "
                          f"(only major/minor keys are supported)")
    letter = m.group(1).upper()
    accidental = m.group(2) or ""
    mode = (m.group(3) or "").lower()
    tonic = letter + accidental
    if mode in ("m", "min", "minor"):
        if tonic not in _MINOR_TO_MAJOR:
            raise ParseError(f"line {line}: unsupported minor key {key_field!r}")
        major = _MINOR_TO_MAJOR[tonic]
    else:
        major = tonic
    if major not in _MAJOR_KEY_SHARPS:
        raise ParseError(f"line {line}: unsupported key signature {key_field!r}")
    n = _MAJOR_KEY_SHARPS[major]
    accidentals = {}
    if n > 0:
        for letter in _SHARP_ORDER[:n]:
            accidentals[letter] = 1
    elif n < 0:
        for letter in _FLAT_ORDER[:-n]:
            accidentals[letter] = -1
    return accidentals


def parse_unit_length(field: str, line: int) -> Fraction:
    """Parse an L: field value ('1/8') into a Fraction."""
    m = re.match(r"^\s*(\d+)/(\d+)\s*$", field)
    if not m:
        raise ParseError(f"line {line}: invalid L: field {field!r}")
    return Fraction(int(m.group(1)), int(m.group(2)))


def parse_tempo(field: str, line: int) -> float:
    """Parse a Q: field value ('120' or '1/4=120', '1/8=240', ...) into
    quarter-note BPM."""
    stripped = field.strip()
    m = re.match(r"^(\d+)/(\d+)\s*=\s*(\d+(?:\.\d+)?)$", stripped)
    if m:
        unit = Fraction(int(m.group(1)), int(m.group(2)))
        bpm_of_unit = float(m.group(3))
        return bpm_of_unit * float(unit) * 4.0
    m = re.match(r"^(\d+(?:\.\d+)?)$", stripped)
    if m:
        return float(m.group(1))
    raise ParseError(f"line {line}: invalid Q: field {field!r}")
