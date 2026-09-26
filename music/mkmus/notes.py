#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Shared Note type and divisor/duration conversion math for mkmus.py."""

from dataclasses import dataclass
from typing import Optional


class ConversionError(Exception):
    """A note's computed divisor or duration falls outside 1..65535."""


@dataclass
class Note:
    freq: Optional[float]   # None => rest/silence
    beats: float            # duration in quarter-note beats (quarter = 1.0)
    comment: str
    line: int                # source line number, for error messages
    bar: int = 0             # ABC bar index (bar lines seen before this note)


def note_to_divisor(freq: Optional[float], tone_freq: float, line: int) -> int:
    """0 for a rest. Otherwise round(tone_freq / freq), hard error if the
    result falls outside 1..65535 (0 and out-of-range are both reserved)."""
    if freq is None:
        return 0
    divisor = round(tone_freq / freq)
    if not (1 <= divisor <= 65535):
        raise ConversionError(
            f"line {line}: computed divisor {divisor} out of range 1..65535"
        )
    return divisor


def note_to_duration_ticks(beats: float, tempo: float, beat_freq: float, line: int) -> int:
    """round(beats * (60/tempo) * beat_freq), hard error if the result
    falls outside 1..65535. Applies to every note including rests -- a
    rest still occupies time, and duration must never round to 0 or it
    would be indistinguishable from the end-of-song sentinel."""
    ticks = round(beats * (60.0 / tempo) * beat_freq)
    if not (1 <= ticks <= 65535):
        raise ConversionError(
            f"line {line}: computed duration {ticks} out of range 1..65535"
        )
    return ticks
