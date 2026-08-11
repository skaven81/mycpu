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


def _resolve_tokens(tokens, unit_length, key_accidentals, bar_accidentals, pending_tie, line):
    """The one place note/rest/accidental/tie resolution logic lives.
    bar_accidentals and pending_tie (a 1-element list used as a mutable
    box) are owned by the caller, so state can be threaded across
    multiple calls -- e.g. across a tune's several body lines."""
    notes = []
    for kind, value in tokens:
        if kind == "bar":
            bar_accidentals.clear()
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

        if pending_tie[0] is not None:
            prev = pending_tie[0]
            if note_freq is not None and prev.freq == note_freq:
                prev.beats += beats
                if tie:
                    continue
                notes.append(prev)
                pending_tie[0] = None
                continue
            notes.append(prev)
            pending_tie[0] = None

        new_note = Note(freq=note_freq, beats=beats, comment="", line=line)
        if tie:
            pending_tie[0] = new_note
        else:
            notes.append(new_note)
    return notes


def _tokens_to_notes(tokens: list, unit_length: Fraction, key_accidentals: dict, line: int) -> list:
    """Single-line convenience wrapper (what Task 7's tests call directly):
    fresh bar-accidental and tie state for this one call only."""
    bar_accidentals = {}
    pending_tie = [None]
    notes = _resolve_tokens(tokens, unit_length, key_accidentals, bar_accidentals, pending_tie, line)
    if pending_tie[0] is not None:
        notes.append(pending_tie[0])
    return notes


def _parse_body_line_notes(text, unit_length, key_accidentals, bar_accidentals, pending_tie, line):
    """Multi-line entry point used by parse_abc: tokenizes one body line
    and resolves it against caller-owned, cross-line accidental/tie state."""
    tokens = _tokenize_body_line(text, line)
    return _resolve_tokens(tokens, unit_length, key_accidentals, bar_accidentals, pending_tie, line)


@dataclass
class AbcTune:
    number: int
    title: str
    notes: list
    tempo_bpm: float = None


_HEADER_RE = re.compile(r"^([A-Za-z]):\s?(.*)$")


def parse_abc(text: str) -> list:
    """Parse an ABC file into one AbcTune per X: header found."""
    lines = text.splitlines()
    tunes = []
    i = 0
    n = len(lines)
    while i < n:
        m = re.match(r"^X:\s*(\d+)", lines[i].strip())
        if not m:
            i += 1
            continue
        tune_number = int(m.group(1))
        title = ""
        unit_length = Fraction(1, 8)
        key_accidentals = {}
        tempo_bpm = None
        i += 1

        # Header block: X:, T:, K:, L:, Q: (and other unrecognized header
        # letters, silently ignored) up to and including K:.
        saw_key = False
        while i < n and not saw_key:
            stripped = lines[i].strip()
            if not stripped:
                i += 1
                continue
            hm = _HEADER_RE.match(stripped)
            if not hm or hm.group(1) == "X":
                break
            letter, value = hm.group(1), hm.group(2)
            if letter == "T":
                title = value.strip()
            elif letter == "K":
                key_accidentals = key_signature_accidentals(value, i + 1)
                saw_key = True
            elif letter == "L":
                unit_length = parse_unit_length(value, i + 1)
            elif letter == "Q":
                tempo_bpm = parse_tempo(value, i + 1)
            elif letter == "V":
                raise ParseError(f"line {i + 1}: multiple voices ('V:') are not supported")
            i += 1

        body_notes = []
        bar_accidentals = {}
        pending_tie = [None]
        while i < n:
            stripped = lines[i].strip()
            if re.match(r"^X:\s*\d+", stripped):
                break
            lineno = i + 1
            i += 1
            if not stripped:
                continue
            wm = re.match(r"^w:\s?(.*)$", stripped)
            if wm:
                syllables = wm.group(1).split()
                sounding = [nn for nn in body_notes if nn.freq is not None]
                for note, syll in zip(sounding, syllables):
                    note.comment = syll.rstrip("-")
                continue
            hm = _HEADER_RE.match(stripped)
            if hm and hm.group(1) in "TKLQV":
                letter, value = hm.group(1), hm.group(2)
                if letter == "V":
                    raise ParseError(f"line {lineno}: multiple voices ('V:') are not supported")
                if letter == "T":
                    continue
                if letter == "K":
                    key_accidentals = key_signature_accidentals(value, lineno)
                    continue
                if letter == "L":
                    unit_length = parse_unit_length(value, lineno)
                    continue
                if letter == "Q":
                    tempo_bpm = parse_tempo(value, lineno)
                    continue
            body_notes.extend(
                _parse_body_line_notes(stripped, unit_length, key_accidentals,
                                        bar_accidentals, pending_tie, lineno)
            )
        if pending_tie[0] is not None:
            body_notes.append(pending_tie[0])

        tunes.append(AbcTune(number=tune_number, title=title, notes=body_notes,
                              tempo_bpm=tempo_bpm))
    if not tunes:
        raise ParseError("no X: tune header found in ABC file")
    return tunes
