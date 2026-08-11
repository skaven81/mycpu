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


_ACC_SEMITONES = {"^^": 2, "^": 1, "__": -2, "_": -1, "=": 0}

_NOTE_TOKEN_RE = re.compile(
    r'(?P<comment>%.*)'
    r'|(?P<chord>"[^"]*")'
    r'|(?P<rej_chord>\[(?!\|))'
    r'|(?P<rej_grace>\{)'
    r'|(?P<rej_tuplet>\(\d)'
    r'|(?P<rej_broken>[><])'
    r'|(?P<bar>\|\]|\[\||\|\||:\||\|:|\|)'
    r"|(?P<note>(?:\^\^|\^|__|_|=)?[A-Ga-gzZ][,']*[0-9]*/*[0-9]*-?)"
    r'|(?P<ws>\s+)'
)

_NOTE_DECOMP_RE = re.compile(
    r"^(?P<acc>\^\^|\^|__|_|=)?"
    r"(?P<letter>[A-Ga-gzZ])"
    r"(?P<marks>[,']*)"
    r"(?P<len>[0-9]*/*[0-9]*)"
    r"(?P<tie>-)?$"
)

_SEMITONE = {"c": 0, "d": 2, "e": 4, "f": 5, "g": 7, "a": 9, "b": 11}


def _tokenize_body_line(text: str, line: int) -> list:
    """Split one already-header-stripped ABC body line into ('bar', None)
    and ('note', raw_token) tuples. Chord annotations and %-comments are
    dropped; chords, grace notes, tuplets, and broken rhythm are hard
    parse errors naming the line."""
    pos = 0
    tokens = []
    while pos < len(text):
        m = _NOTE_TOKEN_RE.match(text, pos)
        if not m:
            raise ParseError(f"line {line}: unrecognized ABC syntax near {text[pos:pos+10]!r}")
        kind = m.lastgroup
        if kind == "rej_chord":
            raise ParseError(f"line {line}: chords ('[...]') are not supported")
        if kind == "rej_grace":
            raise ParseError(f"line {line}: grace notes ('{{...}}') are not supported")
        if kind == "rej_tuplet":
            raise ParseError(f"line {line}: tuplets ('(3' etc.) are not supported")
        if kind == "rej_broken":
            raise ParseError(f"line {line}: broken rhythm ('>' / '<') is not supported")
        if kind in ("comment", "chord", "ws"):
            pos = m.end()
            continue
        if kind == "bar":
            tokens.append(("bar", None))
        elif kind == "note":
            tokens.append(("note", m.group("note")))
        pos = m.end()
    return tokens


def _parse_note_length_frac(token: str, line: int) -> Fraction:
    m = re.match(r"^(\d+)?(/+)?(\d+)?$", token)
    if not m:
        raise ParseError(f"line {line}: invalid note length {token!r}")
    numer_s, slashes, denom_s = m.groups()
    numer = int(numer_s) if numer_s else 1
    if not slashes:
        return Fraction(numer, 1)
    denom = int(denom_s) if denom_s else 2 ** len(slashes)
    return Fraction(numer, denom)


def _tokens_to_notes(tokens: list, unit_length: Fraction, key_accidentals: dict, line: int) -> list:
    """Convert one line's tokens into Note objects, tracking bar-scoped
    accidentals (reset at each bar-line token) and merging tied notes."""
    notes = []
    bar_accidentals = {}
    pending_tie = None
    for kind, value in tokens:
        if kind == "bar":
            bar_accidentals = {}
            continue
        m = _NOTE_DECOMP_RE.match(value)
        if not m:
            raise ParseError(f"line {line}: invalid note token {value!r}")
        acc = m.group("acc")
        letter = m.group("letter")
        marks = m.group("marks")
        length_tok = m.group("len")
        tie = m.group("tie") is not None
        length_frac = _parse_note_length_frac(length_tok, line) * unit_length
        beats = float(length_frac) * 4.0

        if letter in ("z", "Z"):
            note_freq = None
        else:
            is_lower = letter.islower()
            base = 72 if is_lower else 60
            base += _SEMITONE[letter.lower()]
            base += 12 * marks.count("'") - 12 * marks.count(",")
            acc_key = (letter.upper(), base)
            if acc is not None:
                semitone_adj = _ACC_SEMITONES[acc]
                bar_accidentals[acc_key] = semitone_adj
            elif acc_key in bar_accidentals:
                semitone_adj = bar_accidentals[acc_key]
            else:
                semitone_adj = key_accidentals.get(letter.upper(), 0)
            note_freq = midi_to_freq(base + semitone_adj)

        if pending_tie is not None:
            if note_freq is not None and pending_tie.freq == note_freq:
                pending_tie.beats += beats
                if tie:
                    continue
                notes.append(pending_tie)
                pending_tie = None
                continue
            notes.append(pending_tie)
            pending_tie = None

        new_note = Note(freq=note_freq, beats=beats, comment="", line=line)
        if tie:
            pending_tie = new_note
        else:
            notes.append(new_note)
    if pending_tie is not None:
        notes.append(pending_tie)
    return notes
