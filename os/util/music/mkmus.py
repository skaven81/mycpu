#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""mkmus.py -- generate .MUS music files for os/util/music/MUSIC.ODY.

Reads either the bespoke line format or a bounded subset of ABC notation
(auto-detected) and writes a .MUS file: a sequence of 16-byte note
records (divisor u16 BE, duration u16 BE, 12-byte comment) terminated by
an all-zero record, matching what MUSIC.ODY's .play_next_note reads.
"""

import argparse
import os
import struct
import sys

import abcnotation
import bespoke
from freq import parse_frequency
from mus_writer import encode_record, write_mus
from notes import ConversionError, note_to_divisor, note_to_duration_ticks


class MkmusError(Exception):
    """A user-facing error: bad input, bad flags, or a conversion that
    doesn't fit the record format. Always reported without a traceback."""


def detect_and_parse(text: str, tune_arg):
    """Auto-detect bespoke vs. ABC, parse, and resolve tune selection.
    Returns (list[Note], tempo_bpm_or_None)."""
    fmt = abcnotation.detect_format(text)
    if fmt == "abc":
        try:
            tunes = abcnotation.parse_abc(text)
        except abcnotation.ParseError as e:
            raise MkmusError(str(e)) from e
        if len(tunes) > 1:
            if tune_arg is None:
                lines = ["multiple tunes found in ABC file; select one with --tune N:"]
                for t in tunes:
                    lines.append(f"  X:{t.number}  T:{t.title}")
                raise MkmusError("\n".join(lines))
            selected = [t for t in tunes if t.number == tune_arg]
            if not selected:
                raise MkmusError(f"--tune {tune_arg} not found in ABC file")
            tune = selected[0]
        else:
            if tune_arg is not None and tunes[0].number != tune_arg:
                raise MkmusError(f"--tune {tune_arg} not found in ABC file")
            tune = tunes[0]
        return tune.notes, tune.tempo_bpm
    else:
        if tune_arg is not None:
            raise MkmusError("--tune is only valid for ABC input")
        try:
            return bespoke.parse_bespoke(text), None
        except bespoke.ParseError as e:
            raise MkmusError(str(e)) from e


def build_records(notes: list, tone_freq: float, beat_freq: float, tempo: float, warnings: list) -> list:
    """Convert each Note into an encoded 16-byte record, in order."""
    records = []
    for note in notes:
        try:
            divisor = note_to_divisor(note.freq, tone_freq, note.line)
            duration = note_to_duration_ticks(note.beats, tempo, beat_freq, note.line)
        except ConversionError as e:
            raise MkmusError(str(e)) from e
        records.append(
            encode_record(divisor, duration, note.comment, note.line,
                          warn=warnings.append)
        )
    return records


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        prog="mkmus.py",
        description="Generate a .MUS music file for MUSIC.ODY from a "
                     "bespoke or ABC-notation input file.",
    )
    parser.add_argument("input", help="input file (bespoke or ABC notation)")
    parser.add_argument("--tone-freq", default="1.8432MHz",
                         help="tone generator base clock (default 1.8432MHz)")
    parser.add_argument("--beat-freq", default="32.768kHz",
                         help="beat/duration timer base clock (default 32.768kHz)")
    parser.add_argument("--tempo", type=float, default=None,
                         help="tempo in quarter-note BPM (default 120, or the "
                              "ABC file's own Q: field if present)")
    parser.add_argument("--tune", type=int, default=None,
                         help="select tune N from a multi-tune ABC file")
    parser.add_argument("-o", "--output", default=None,
                         help="output .MUS path (default: INPUT stem, "
                              "uppercased, + .MUS)")
    parser.add_argument("--dry-run", action="store_true",
                         help="print the parsed note table without writing a file")
    args = parser.parse_args(argv)

    try:
        tone_freq = parse_frequency(args.tone_freq)
        beat_freq = parse_frequency(args.beat_freq)
    except ValueError as e:
        print(f"mkmus.py: {e}", file=sys.stderr)
        return 1

    try:
        with open(args.input, "r") as f:
            text = f.read()
    except OSError as e:
        print(f"mkmus.py: cannot read {args.input}: {e}", file=sys.stderr)
        return 1

    try:
        notes, abc_tempo = detect_and_parse(text, args.tune)
    except MkmusError as e:
        print(f"mkmus.py: {e}", file=sys.stderr)
        return 1

    if args.tempo is not None:
        tempo = args.tempo
    elif abc_tempo is not None:
        tempo = abc_tempo
    else:
        tempo = 120.0

    warnings = []
    try:
        records = build_records(notes, tone_freq, beat_freq, tempo, warnings)
    except MkmusError as e:
        print(f"mkmus.py: {e}", file=sys.stderr)
        return 1

    for w in warnings:
        print(f"mkmus.py: warning: {w}", file=sys.stderr)

    if args.dry_run:
        for note, rec in zip(notes, records):
            divisor, duration = struct.unpack(">HH", rec[:4])
            print(f"line {note.line}: freq={note.freq} divisor={divisor} "
                  f"duration={duration} comment={note.comment!r}")
        return 0

    if args.output:
        out_path = args.output
    else:
        stem = os.path.splitext(os.path.basename(args.input))[0]
        out_path = stem.upper() + ".MUS"

    write_mus(out_path, records)
    return 0


if __name__ == "__main__":
    sys.exit(main())
