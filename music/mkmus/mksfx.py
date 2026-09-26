#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""mksfx.py -- generate sound effects for the Odyssey music player.

A sound effect is just a short song: the same 16-byte .MUS records that
os/lib/music_player.asm plays, authored in milliseconds and Hz instead of
beats and tempo. Each .sfx source file is one effect, named after the
file's basename.

Output modes:
  mksfx.py -o sfx_bank a.sfx b.sfx   sfx_bank.asm + sfx_bank.h, a bank of
                                     effects to link into an ODY
  mksfx.py --mus a.sfx b.sfx         A.MUS, B.MUS (audition with `music`)
  mksfx.py --dry-run a.sfx           print each step

Source format (one command per line, '#' starts a comment):
  tone PITCH MS                 PITCH: note name (C6, F#5) or Hz (880, 1.2k)
  rest MS
  sweep FROM TO MS STEP_MS      pitch-linear glide in STEP_MS steps
  repeat N                      repeat the commands up to 'end' N times
  end
"""

import argparse
import os
import re
import struct
import sys
from dataclasses import dataclass
from typing import Optional

from freq import parse_frequency, pitch_to_freq
from mus_writer import encode_record, write_mus, TERMINATOR
from notes import ConversionError, note_to_divisor

TONE_FREQ = 1843200.0       # Timer 1 clock (tone divisor)
BEAT_FREQ = 32768.0         # Timer 2 clock (step duration)
MIN_STEP_MS = 2.0           # below this the ISR cost dominates
MAX_EFFECTS = 128           # :sfx_get doubles the id in 8 bits


class SfxError(Exception):
    """A user-facing error in a .sfx source or on the command line."""


@dataclass
class Step:
    freq: Optional[float]   # None => rest
    ms: float
    line: int


@dataclass
class Effect:
    name: str               # identifier: lowercase letters, digits, '_'
    steps: list
    records: list           # encoded 16-byte records (no terminator)


def parse_pitch(s: str, line: int) -> float:
    """Note name (scientific pitch notation) or a frequency in Hz."""
    try:
        return pitch_to_freq(s)
    except ValueError:
        pass
    try:
        f = parse_frequency(s)
    except ValueError:
        raise SfxError(f"line {line}: invalid pitch {s!r} (note name or Hz)")
    if f <= 0:
        raise SfxError(f"line {line}: frequency must be positive")
    return f


def parse_ms(s: str, line: int) -> float:
    try:
        ms = float(s)
    except ValueError:
        raise SfxError(f"line {line}: invalid duration {s!r} (milliseconds)")
    if ms <= 0:
        raise SfxError(f"line {line}: duration must be positive")
    return ms


def sweep_steps(f_from: float, f_to: float, ms: float, step_ms: float, line: int) -> list:
    """Pitch-linear glide: equal ratios between consecutive steps, first
    step at f_from, last at f_to. The step count is ms/step_ms rounded
    (at least 1); the total length is exactly ms."""
    n = max(1, round(ms / step_ms))
    each = ms / n
    if n == 1:
        return [Step(f_from, each, line)]
    return [Step(f_from * (f_to / f_from) ** (i / (n - 1)), each, line)
            for i in range(n)]


def parse_sfx(text: str) -> list:
    """Parse .sfx source text into a flat list of Steps."""
    # Stack of (step list, repeat count, 'repeat' line) for open repeat blocks
    stack = [([], 1, 0)]
    for lineno, raw in enumerate(text.splitlines(), start=1):
        words = raw.split('#', 1)[0].split()
        if not words:
            continue
        cmd, args = words[0].lower(), words[1:]
        want = {'tone': 2, 'rest': 1, 'sweep': 4, 'repeat': 1, 'end': 0}
        if cmd not in want:
            raise SfxError(f"line {lineno}: unknown command {words[0]!r}")
        if len(args) != want[cmd]:
            raise SfxError(f"line {lineno}: '{cmd}' takes {want[cmd]} argument(s)")
        out = stack[-1][0]
        if cmd == 'tone':
            out.append(Step(parse_pitch(args[0], lineno), parse_ms(args[1], lineno), lineno))
        elif cmd == 'rest':
            out.append(Step(None, parse_ms(args[0], lineno), lineno))
        elif cmd == 'sweep':
            out.extend(sweep_steps(parse_pitch(args[0], lineno), parse_pitch(args[1], lineno),
                                   parse_ms(args[2], lineno), parse_ms(args[3], lineno),
                                   lineno))
        elif cmd == 'repeat':
            try:
                count = int(args[0])
            except ValueError:
                count = 0
            if count < 1:
                raise SfxError(f"line {lineno}: repeat count must be a positive integer")
            stack.append(([], count, lineno))
        else:  # end
            if len(stack) == 1:
                raise SfxError(f"line {lineno}: 'end' without 'repeat'")
            body, count, _ = stack.pop()
            stack[-1][0].extend(body * count)
    if len(stack) > 1:
        raise SfxError(f"line {stack[-1][2]}: 'repeat' without 'end'")
    steps = stack[0][0]
    if not steps:
        raise SfxError("no tone/rest/sweep commands")
    return steps


def step_to_record(step: Step, warn) -> bytes:
    """Encode one step as a 16-byte .MUS record with an empty comment."""
    try:
        divisor = note_to_divisor(step.freq, TONE_FREQ, step.line)
    except ConversionError as e:
        raise SfxError(str(e)) from e
    ticks = max(1, round(step.ms * BEAT_FREQ / 1000.0))
    if ticks > 65535:
        raise SfxError(f"line {step.line}: duration {step.ms:g} ms is over the "
                       f"{65535 * 1000 / BEAT_FREQ:.0f} ms limit")
    if step.ms < MIN_STEP_MS:
        warn(f"line {step.line}: {step.ms:g} ms step is under {MIN_STEP_MS:g} ms "
             "(each step costs an interrupt)")
    if step.freq is not None and step.ms < 500.0 / step.freq:
        warn(f"line {step.line}: {step.ms:g} ms step is shorter than half a period "
             f"of {step.freq:.0f} Hz (the pitch change may not be heard)")
    return encode_record(divisor, ticks, "", step.line)


def effect_name(path: str) -> str:
    stem = os.path.splitext(os.path.basename(path))[0].lower()
    return re.sub(r'[^a-z0-9_]', '_', stem)


def load_effect(path: str, warn) -> Effect:
    try:
        with open(path) as f:
            text = f.read()
    except OSError as e:
        raise SfxError(f"cannot read {path}: {e}") from e
    try:
        steps = parse_sfx(text)
        records = [step_to_record(s, lambda m: warn(f"{path}: {m}")) for s in steps]
    except SfxError as e:
        raise SfxError(f"{path}: {e}") from e
    return Effect(effect_name(path), steps, records)


def _hex_bytes(data: bytes) -> str:
    return ' '.join(f'0x{b:02x}' for b in data)


def bank_asm(effects: list, bank: str) -> str:
    """Assembly source: every effect's records, an address table, and
    :sfx_get (id -> record pointer)."""
    out = [
        "# vim: syntax=asm-mycpu",
        f"# {bank}.asm - sound effect bank, GENERATED by music/mkmus/mksfx.py.",
        "# Do not edit; change the .sfx sources and rebuild.",
        "#",
        "# Each effect is a short .MUS song (16-byte records, all-zero",
        "# terminator). Play one with music_play(sfx_get(ID), 0, NULL, NULL).",
        "",
        "####",
        "# sfx_get - look up a sound effect by id",
        "#",
        "# C: void *sfx_get(uint8_t id);",
        "#",
        "# To use:",
        "#  1. Push the effect id byte (SFX_* in the generated header)",
        "#  2. Call the function",
        "#  3. Pop the effect's record address word",
        "# Side effects: none (all registers preserved). The id is not",
        "# range-checked.",
        ":sfx_get",
        "ALUOP_PUSH %A%+%AH%",
        "ALUOP_PUSH %A%+%AL%",
        "ALUOP_PUSH %B%+%BH%",
        "ALUOP_PUSH %B%+%BL%",
        "PUSH_DH",
        "PUSH_DL",
        "CALL :heap_pop_AL               # AL = id",
        "LDI_AH 0x00",
        "ALUOP_AL %A<<1%+%AL%            # A = id * 2 (id < 128)",
        "LDI_B .sfx_table",
        "ALUOP16O_B %ALU16_A+B%          # B = &table[id]",
        "ALUOP_DH %B%+%BH%",
        "ALUOP_DL %B%+%BL%",
        "LDA_D_AH                        # table entries are big-endian",
        "INCR_D",
        "LDA_D_AL",
        "CALL :heap_push_A",
        "POP_DL",
        "POP_DH",
        "POP_BL",
        "POP_BH",
        "POP_AL",
        "POP_AH",
        "RET",
        "",
        ".sfx_table " + ' '.join(f".sfx_{e.name}" for e in effects),
    ]
    for e in effects:
        out.append("")
        out.append(f"# {e.name}: {len(e.steps)} steps, {sum(s.ms for s in e.steps):g} ms")
        for i, (step, rec) in enumerate(zip(e.steps, e.records)):
            label = f".sfx_{e.name}" if i == 0 else f".sfx_{e.name}_{i}"
            what = "rest" if step.freq is None else f"{step.freq:.0f} Hz"
            out.append(f"{label} {_hex_bytes(rec)}   # {what}, {step.ms:.4g} ms")
        out.append(f".sfx_{e.name}_end {_hex_bytes(TERMINATOR)}")
    return '\n'.join(out) + '\n'


def bank_header(effects: list, bank: str) -> str:
    out = [
        "#pragma once",
        "",
        "#include <types.h>",
        "",
        f"// {bank}.h - sound effect bank, GENERATED by music/mkmus/mksfx.py.",
        "// Do not edit; change the .sfx sources and rebuild.",
        "//",
        "// Play an effect with the music player (it stops any playing music):",
        "//   music_play(sfx_get(SFX_NAME), 0, NULL, NULL);",
        "",
    ]
    width = max(len(e.name) for e in effects)
    for i, e in enumerate(effects):
        out.append(f"#define SFX_{e.name.upper():<{width}} {i}")
    out += [
        "",
        "// Address of an effect's records (the id is not range-checked).",
        "extern void *sfx_get(uint8_t id);",
    ]
    return '\n'.join(out) + '\n'


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        prog="mksfx.py",
        description="Generate Odyssey sound effects (.MUS records) from .sfx sources.",
    )
    parser.add_argument("inputs", nargs="+", help=".sfx source files, one effect each")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("-o", "--output", metavar="BANK",
                      help="write BANK.asm and BANK.h containing every effect")
    mode.add_argument("--mus", action="store_true",
                      help="write NAME.MUS per effect in the current directory")
    mode.add_argument("--dry-run", action="store_true",
                      help="print each effect's steps without writing files")
    args = parser.parse_args(argv)

    warnings = []
    try:
        effects = [load_effect(p, warnings.append) for p in args.inputs]
        seen = set()
        for e in effects:
            if e.name in seen:
                raise SfxError(f"duplicate effect name {e.name!r}")
            seen.add(e.name)
        if len(effects) > MAX_EFFECTS:
            raise SfxError(f"too many effects ({len(effects)} > {MAX_EFFECTS})")
    except SfxError as e:
        print(f"mksfx.py: {e}", file=sys.stderr)
        return 1
    for w in dict.fromkeys(warnings):   # repeat blocks re-warn per copy
        print(f"mksfx.py: warning: {w}", file=sys.stderr)

    try:
        if args.dry_run:
            for e in effects:
                print(f"{e.name}:")
                for step, rec in zip(e.steps, e.records):
                    divisor, ticks = struct.unpack(">HH", rec[:4])
                    hz = "rest" if step.freq is None else f"{step.freq:8.1f} Hz"
                    print(f"  line {step.line:3}: {hz:>11} {step.ms:7.2f} ms  "
                          f"divisor={divisor:5} ticks={ticks}")
        elif args.mus:
            for e in effects:
                write_mus(e.name.upper() + ".MUS", e.records)
        else:
            bank = os.path.basename(args.output)
            with open(args.output + ".asm", "w") as f:
                f.write(bank_asm(effects, bank))
            with open(args.output + ".h", "w") as f:
                f.write(bank_header(effects, bank))
    except OSError as e:
        print(f"mksfx.py: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
