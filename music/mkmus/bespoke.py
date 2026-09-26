#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Bespoke line-based note format parser for mkmus.py.

One note per line, whitespace-separated fields: PITCH DURATION [comment...]
  PITCH:    scientific pitch notation (C4, A#3, Bb5, ...) or 'z'/'Z' for rest.
  DURATION: /N, a fraction of a whole note (/4 = quarter, /8 = eighth, ...).
  Everything after DURATION, to end of line, is the (optional) comment.
  A newline is appended to each non-empty comment so the player, which
  prints comments verbatim, shows one per line.
Blank lines and lines starting with '#' are ignored.
"""

import re

from notes import Note
from freq import pitch_to_freq

_LINE_RE = re.compile(r"^(?P<pitch>\S+)\s+/(?P<denom>\d+)(?:\s+(?P<comment>.*))?$")


class ParseError(Exception):
    """A bespoke-format source line could not be parsed."""


def parse_bespoke(text: str) -> list:
    """Parse bespoke line format text into a list of Note objects."""
    notes = []
    for lineno, raw in enumerate(text.splitlines(), start=1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        m = _LINE_RE.match(stripped)
        if not m:
            raise ParseError(f"line {lineno}: malformed note line {raw!r}")
        pitch_tok = m.group("pitch")
        denom = int(m.group("denom"))
        if denom <= 0:
            raise ParseError(f"line {lineno}: duration denominator must be a "
                              f"positive integer, got /{denom}")
        comment = m.group("comment") or ""
        if comment:
            comment += "\n"  # the player prints comments verbatim; one per line
        if pitch_tok in ("z", "Z"):
            note_freq = None
        else:
            try:
                note_freq = pitch_to_freq(pitch_tok)
            except ValueError as e:
                raise ParseError(f"line {lineno}: {e}") from e
        beats = 4.0 / denom
        notes.append(Note(freq=note_freq, beats=beats, comment=comment, line=lineno))
    return notes
