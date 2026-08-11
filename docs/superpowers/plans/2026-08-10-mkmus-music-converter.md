# mkmus.py Music Converter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `os/util/music/mkmus.py`, a host-side Python CLI that reads either a bespoke line-based note format or a bounded subset of ABC notation and emits a `.MUS` binary file that `os/util/music/MUSIC.ODY` can play.

**Architecture:** A small pipeline of flat (non-package) modules living next to `music.asm` in `os/util/music/`: `freq.py` (frequency-string and pitch/MIDI/frequency math), `notes.py` (the shared `Note` type and the divisor/duration conversion math), `mus_writer.py` (binary record encoding), `bespoke.py` and `abcnotation.py` (the two input-format parsers, both producing `list[Note]`), and `mkmus.py` (argparse CLI that auto-detects format, dispatches to the right parser, resolves tempo, converts notes to records, and writes the file). Tests live in `os/util/music/tests/`, one test file per module, using `pytest` — matching the `odyssey_video/tests/` convention already in this repo (flat modules, `conftest.py` inserting the parent dir onto `sys.path`, no package `__init__.py` at the module level).

**Tech Stack:** Python 3.10+, stdlib only (`argparse`, `re`, `struct`, `dataclasses`, `fractions`, `os`, `sys`). `pytest` for tests, installed into a local `.venv` (mirroring `odyssey_video/`), never added as a runtime dependency of `mkmus.py` itself.

## Global Constraints

These apply to every task below; copied verbatim in spirit from `docs/superpowers/specs/2026-08-10-mkmus-music-converter-design.md`.

- Every `.py` file: `#!/usr/bin/env python3` shebang (script entry points only) + `# vim: syntax=python ts=4 sts=4 sw=4 expandtab` modeline as the first (or first two) lines, matching `uart_clocks.py` / `odyssey_video/*.py`.
- Record format: divisor (big-endian u16), duration (big-endian u16), comment (12 bytes, null-padded/truncated ASCII) = 16 bytes/record. Terminator = 16 zero bytes.
- Divisor formula: `round(tone_freq / note_freq)`. Duration formula: `round(beats * (60/tempo) * beat_freq)`, where `beats` = fraction-of-a-whole-note × 4 (quarter note = 1 beat).
- Both divisor and duration (for real notes) must be in `1..65535`; a rest gets divisor `0` (not range-checked) but its duration is still range-checked like any other note's. Out-of-range is a hard error naming the line — never clamped.
- Comments longer than 11 characters are truncated to fit the 12-byte null-terminated field, with a warning to stderr naming the line.
- All parse/validation errors reference the offending line number; the script exits non-zero and writes nothing on failure (no partial `.MUS` file).
- Rest token is `z` (and ABC's `Z`) in both formats.
- `--tune N` is required (not optional/first-tune-wins) for multi-tune ABC files, and is invalid for the bespoke format.
- `--tempo`, when given, always overrides an ABC file's own `Q:` field.
- ABC supported: `X: T: K: L: Q: w:` headers (major/minor keys only for `K:`); pitch letters, octave marks `,`/`'`, accidentals `^ ^^ _ __ =` (bar-scoped per pitch+octave), rests `z Z`, note-length modifiers (`N`, `/N`, `N/M`, repeated `/`), ties `-`, all bar-line forms (ignored structurally), `%` comments (ignored), quoted chord annotations `"Cmaj7"` (skipped).
- ABC explicitly rejected (hard parse error naming the line): chords `[CEG]`, `V:` (additional voices), grace notes `{..}`, tuplets `(3` etc., broken rhythm `>`/`<`, modal keys (`Dmix`, `Ador`, etc.).
- Module name `abcnotation.py`, **not** `abc.py` — the stdlib has a module named `abc` (Abstract Base Classes) and `os/util/music/` sits on `sys.path` for both direct execution and tests, so `abc.py` here would shadow it repo-wide for any code importing this directory.
- No changes to `os/util/music/Makefile` or `music.asm` — `mkmus.py` is a separate host-side tool, not part of the ODY build.

---

## Task 1: Test environment scaffolding

**Files:**
- Create: `os/util/music/tests/__init__.py` (empty)
- Create: `os/util/music/tests/conftest.py`
- Create: `os/util/music/tests/test_smoke.py`

**Interfaces:**
- Produces: a working `pytest` invocation (`os/util/music/.venv/bin/pytest os/util/music/tests/ -v`) that later tasks build on. No production code yet.

- [ ] **Step 1: Create the venv and install pytest**

```bash
cd /net/geofront/raid/mycpu2/os/util/music
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install pytest
```

(`python3 -m venv` writes its own `.gitignore` containing `*` inside `.venv/`, so it is automatically excluded from git — no manual `.gitignore` edit needed, matching `odyssey_video/.venv`.)

- [ ] **Step 2: Write `conftest.py`**

```python
"""
Pytest configuration for os/util/music tests.
Adds the parent directory to sys.path so modules can be imported directly.
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
```

- [ ] **Step 3: Create empty `__init__.py`**

Empty file (matches `odyssey_video/tests/__init__.py`).

- [ ] **Step 4: Write a smoke test**

```python
def test_pytest_runs():
    assert 1 + 1 == 2
```

- [ ] **Step 5: Run it**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/ -v`
Expected: 1 passed.

- [ ] **Step 6: Commit**

```bash
git add os/util/music/tests/__init__.py os/util/music/tests/conftest.py os/util/music/tests/test_smoke.py
git commit -m "Add pytest scaffolding for os/util/music host tools"
```

---

## Task 2: `freq.py` — frequency strings and pitch/MIDI/frequency math

**Files:**
- Create: `os/util/music/freq.py`
- Test: `os/util/music/tests/test_freq.py`

**Interfaces:**
- Produces:
  - `parse_frequency(s: str) -> float` — parses `"1843200"`, `"1.8432MHz"`, `"1843.2k"`, `"32.768kHz"` into Hz; raises `ValueError` on bad input.
  - `pitch_to_midi(pitch: str) -> int` — parses `"C4"`, `"A#3"`, `"Bb5"` (scientific pitch notation, `C4` = MIDI 60) into a MIDI note number; raises `ValueError` on bad input.
  - `midi_to_freq(midi: int, a4_freq: float = 440.0) -> float` — equal-temperament frequency for a MIDI number.
  - `pitch_to_freq(pitch: str, a4_freq: float = 440.0) -> float` — `midi_to_freq(pitch_to_midi(pitch), a4_freq)`.

- [ ] **Step 1: Write the failing tests**

```python
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
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_freq.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'freq'`.

- [ ] **Step 3: Implement `freq.py`**

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_freq.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/freq.py os/util/music/tests/test_freq.py
git commit -m "Add frequency-string and pitch/MIDI/frequency math for mkmus.py"
```

---

## Task 3: `notes.py` — shared Note type and divisor/duration conversion math

**Files:**
- Create: `os/util/music/notes.py`
- Test: `os/util/music/tests/test_notes.py`

**Interfaces:**
- Consumes: nothing from earlier tasks (pure math + a dataclass).
- Produces:
  - `class ConversionError(Exception)`
  - `@dataclass class Note: freq: float | None; beats: float; comment: str; line: int` — `freq is None` marks a rest.
  - `note_to_divisor(freq: float | None, tone_freq: float, line: int) -> int` — `0` for a rest; otherwise `round(tone_freq / freq)`, range-checked `1..65535`, raising `ConversionError` naming `line` if out of range.
  - `note_to_duration_ticks(beats: float, tempo: float, beat_freq: float, line: int) -> int` — `round(beats * (60/tempo) * beat_freq)`, range-checked `1..65535`, raising `ConversionError` naming `line` if out of range.

- [ ] **Step 1: Write the failing tests**

```python
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
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_notes.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'notes'`.

- [ ] **Step 3: Implement `notes.py`**

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_notes.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/notes.py os/util/music/tests/test_notes.py
git commit -m "Add Note type and divisor/duration conversion math for mkmus.py"
```

---

## Task 4: `mus_writer.py` — binary record encoding and file writer

**Files:**
- Create: `os/util/music/mus_writer.py`
- Test: `os/util/music/tests/test_mus_writer.py`

**Interfaces:**
- Consumes: nothing from earlier tasks directly (works on plain `int`/`str` values, not `Note`).
- Produces:
  - `MAX_COMMENT_LEN = 11`
  - `TERMINATOR: bytes` — 16 zero bytes.
  - `encode_record(divisor: int, duration: int, comment: str, line: int, warn=None) -> bytes` — packs one 16-byte record (`>HH12s`); if `comment` exceeds `MAX_COMMENT_LEN` bytes it is truncated to fit and, if `warn` is given, `warn(message)` is called naming `line`.
  - `write_mus(path, records: list[bytes]) -> None` — writes each record in order followed by `TERMINATOR`.

- [ ] **Step 1: Write the failing tests**

```python
import struct
from mus_writer import encode_record, write_mus, TERMINATOR, MAX_COMMENT_LEN


def test_encode_record_basic():
    rec = encode_record(4189, 16384, "A4", line=1)
    assert rec == struct.pack(">HH12s", 4189, 16384, b"A4" + b"\0" * 10)
    assert len(rec) == 16


def test_encode_record_empty_comment():
    rec = encode_record(0, 8192, "", line=1)
    divisor, duration, comment = struct.unpack(">HH12s", rec)
    assert (divisor, duration, comment) == (0, 8192, b"\0" * 12)


def test_encode_record_truncates_long_comment_and_warns():
    warnings = []
    long_comment = "this comment is way too long"
    rec = encode_record(1, 1, long_comment, line=5, warn=warnings.append)
    divisor, duration, comment = struct.unpack(">HH12s", rec)
    assert comment == long_comment.encode("ascii")[:MAX_COMMENT_LEN].ljust(12, b"\0")
    assert len(warnings) == 1
    assert "line 5" in warnings[0]


def test_encode_record_exact_fit_no_warning():
    warnings = []
    eleven_chars = "12345678901"
    assert len(eleven_chars) == MAX_COMMENT_LEN
    encode_record(1, 1, eleven_chars, line=1, warn=warnings.append)
    assert warnings == []


def test_write_mus_appends_terminator(tmp_path):
    out = tmp_path / "TEST.MUS"
    records = [
        encode_record(4189, 16384, "A4", line=1),
        encode_record(0, 8192, "", line=2),
    ]
    write_mus(str(out), records)
    data = out.read_bytes()
    assert data == records[0] + records[1] + TERMINATOR


def test_write_mus_empty_song_is_just_terminator(tmp_path):
    out = tmp_path / "EMPTY.MUS"
    write_mus(str(out), [])
    assert out.read_bytes() == TERMINATOR
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_mus_writer.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'mus_writer'`.

- [ ] **Step 3: Implement `mus_writer.py`**

```python
#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Binary .MUS record encoding and file writer for mkmus.py."""

import struct

MAX_COMMENT_LEN = 11  # 12-byte field, must stay null-terminated
TERMINATOR = b"\0" * 16


def encode_record(divisor: int, duration: int, comment: str, line: int, warn=None) -> bytes:
    """Encode one 16-byte note record: divisor (u16 BE), duration (u16 BE),
    comment (12 bytes, null-padded/truncated ASCII). `warn`, if given, is
    called with a message when the comment must be truncated to fit."""
    comment_bytes = comment.encode("ascii", errors="replace")
    if len(comment_bytes) > MAX_COMMENT_LEN:
        if warn is not None:
            warn(f"line {line}: comment truncated to {MAX_COMMENT_LEN} characters")
        comment_bytes = comment_bytes[:MAX_COMMENT_LEN]
    comment_field = comment_bytes.ljust(12, b"\0")
    return struct.pack(">HH12s", divisor, duration, comment_field)


def write_mus(path, records: list) -> None:
    """Write a .MUS file: each 16-byte record in order, followed by the
    all-zero terminator record."""
    with open(path, "wb") as f:
        for rec in records:
            f.write(rec)
        f.write(TERMINATOR)
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_mus_writer.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/mus_writer.py os/util/music/tests/test_mus_writer.py
git commit -m "Add .MUS binary record encoding and file writer for mkmus.py"
```

---

## Task 5: `bespoke.py` — bespoke line-format parser

**Files:**
- Create: `os/util/music/bespoke.py`
- Test: `os/util/music/tests/test_bespoke.py`

**Interfaces:**
- Consumes: `Note` from `notes.py` (`notes.Note(freq, beats, comment, line)`), `freq.pitch_to_freq` from `freq.py`.
- Produces:
  - `class ParseError(Exception)`
  - `parse_bespoke(text: str) -> list` — returns `list[Note]`. Blank lines and lines starting with `#` are skipped. Each remaining line is `PITCH DURATION [comment...]`, whitespace-separated, `DURATION` is `/N`, `PITCH` of `z`/`Z` is a rest.

- [ ] **Step 1: Write the failing tests**

```python
import pytest
from bespoke import parse_bespoke, ParseError
from freq import pitch_to_freq


def test_parse_bespoke_basic_note():
    notes = parse_bespoke("A4 /4 hello\n")
    assert len(notes) == 1
    n = notes[0]
    assert n.freq == pitch_to_freq("A4")
    assert n.beats == 1.0
    assert n.comment == "hello"
    assert n.line == 1


def test_parse_bespoke_rest_lowercase_z():
    notes = parse_bespoke("z /8\n")
    assert notes[0].freq is None
    assert notes[0].beats == 0.5


def test_parse_bespoke_rest_uppercase_z():
    notes = parse_bespoke("Z /8\n")
    assert notes[0].freq is None


def test_parse_bespoke_no_comment():
    notes = parse_bespoke("C4 /4\n")
    assert notes[0].comment == ""


def test_parse_bespoke_comment_may_contain_spaces():
    notes = parse_bespoke("C4 /4 a whole sentence of comment\n")
    assert notes[0].comment == "a whole sentence of comment"


def test_parse_bespoke_skips_blank_and_comment_lines():
    text = "\n# a header comment\nA4 /4\n\n# trailing\nC4 /8 note\n"
    notes = parse_bespoke(text)
    assert len(notes) == 2
    assert notes[0].line == 3
    assert notes[1].line == 6


def test_parse_bespoke_duration_fractions():
    notes = parse_bespoke("A4 /4\nA4 /8\nA4 /16\n")
    assert [n.beats for n in notes] == [1.0, 0.5, 0.25]


def test_parse_bespoke_bad_pitch_raises_with_line():
    with pytest.raises(ParseError, match=r"line 1"):
        parse_bespoke("H9 /4\n")


def test_parse_bespoke_malformed_line_raises_with_line():
    with pytest.raises(ParseError, match=r"line 2"):
        parse_bespoke("A4 /4\nA4 nodenom\n")
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_bespoke.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'bespoke'`.

- [ ] **Step 3: Implement `bespoke.py`**

```python
#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Bespoke line-based note format parser for mkmus.py.

One note per line, whitespace-separated fields: PITCH DURATION [comment...]
  PITCH:    scientific pitch notation (C4, A#3, Bb5, ...) or 'z'/'Z' for rest.
  DURATION: /N, a fraction of a whole note (/4 = quarter, /8 = eighth, ...).
  Everything after DURATION, to end of line, is the (optional) comment.
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
        comment = m.group("comment") or ""
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_bespoke.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/bespoke.py os/util/music/tests/test_bespoke.py
git commit -m "Add bespoke line-format parser for mkmus.py"
```

---

## Task 6: `abcnotation.py` part A — header parsing (key signature, unit length, tempo)

**Files:**
- Create: `os/util/music/abcnotation.py`
- Test: `os/util/music/tests/test_abcnotation.py`

**Interfaces:**
- Produces (this task):
  - `class ParseError(Exception)`
  - `key_signature_accidentals(key_field: str, line: int) -> dict` — maps a `K:` value (`"D"`, `"Bbm"`, `"F#maj"`, `"Am"`, `"Dmix"` (rejected), ...) to a `{LETTER: semitone_adjustment}` map (`LETTER` uppercase `A`-`G`, adjustment `-1`/`0`/`1`); raises `ParseError` naming `line` for anything other than a plain major/minor key.
  - `parse_unit_length(field: str, line: int) -> Fraction` — parses an `L:` value (`"1/8"`) into a `fractions.Fraction`; raises `ParseError` naming `line` on bad input.
  - `parse_tempo(field: str, line: int) -> float` — parses a `Q:` value (`"120"` or `"1/4=120"`) into quarter-note BPM; raises `ParseError` naming `line` on bad input.
  - `detect_format(text: str) -> str` — `"abc"` if one of the first 5 non-blank lines is an `X:` header, else `"bespoke"`.

Later tasks (7, 8) add `AbcTune`, `parse_abc`, and the body tokenizer to this same file.

- [ ] **Step 1: Write the failing tests**

```python
import pytest
from fractions import Fraction
from abcnotation import (
    ParseError,
    key_signature_accidentals,
    parse_unit_length,
    parse_tempo,
    detect_format,
)


def test_key_c_major_no_accidentals():
    assert key_signature_accidentals("C", line=1) == {}


def test_key_d_major_two_sharps():
    assert key_signature_accidentals("D", line=1) == {"F": 1, "C": 1}


def test_key_f_major_one_flat():
    assert key_signature_accidentals("F", line=1) == {"B": -1}


def test_key_bb_major_two_flats():
    assert key_signature_accidentals("Bb", line=1) == {"B": -1, "E": -1}


def test_key_a_minor_same_as_c_major():
    assert key_signature_accidentals("Am", line=1) == {}


def test_key_e_minor_same_as_g_major():
    assert key_signature_accidentals("Em", line=1) == {"F": 1}


def test_key_trailing_clef_annotation_ignored():
    assert key_signature_accidentals("D bass", line=1) == {"F": 1, "C": 1}


def test_key_modal_rejected():
    with pytest.raises(ParseError, match=r"line 4"):
        key_signature_accidentals("Dmix", line=4)


def test_key_unsupported_letter_rejected():
    with pytest.raises(ParseError, match=r"line 1"):
        key_signature_accidentals("Hmaj", line=1)


def test_parse_unit_length_eighth():
    assert parse_unit_length("1/8", line=1) == Fraction(1, 8)


def test_parse_unit_length_quarter():
    assert parse_unit_length("1/4", line=1) == Fraction(1, 4)


def test_parse_unit_length_invalid():
    with pytest.raises(ParseError, match=r"line 2"):
        parse_unit_length("eighth", line=2)


def test_parse_tempo_bare_number():
    assert parse_tempo("120", line=1) == 120.0


def test_parse_tempo_fraction_equals_number():
    assert parse_tempo("1/4=120", line=1) == 120.0


def test_parse_tempo_eighth_equals_number():
    # an eighth note at 240/min == a quarter note at 120/min
    assert parse_tempo("1/8=240", line=1) == pytest.approx(120.0)


def test_parse_tempo_invalid():
    with pytest.raises(ParseError, match=r"line 3"):
        parse_tempo("fast", line=3)


def test_detect_format_abc():
    text = "X:1\nT:Test\nK:C\nABC\n"
    assert detect_format(text) == "abc"


def test_detect_format_bespoke():
    text = "A4 /4 hello\nC4 /8\n"
    assert detect_format(text) == "bespoke"


def test_detect_format_bespoke_when_x_header_is_not_near_top():
    # a bespoke file that happens to have a comment line mentioning X: later
    # should still be treated as bespoke since it isn't in the first 5 lines
    text = "\n".join(["# c" + str(i) for i in range(6)] + ["X:1"])
    assert detect_format(text) == "bespoke"
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'abcnotation'`.

- [ ] **Step 3: Implement the header-parsing part of `abcnotation.py`**

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/abcnotation.py os/util/music/tests/test_abcnotation.py
git commit -m "Add ABC header parsing (key/unit-length/tempo) for mkmus.py"
```

---

## Task 7: `abcnotation.py` part B — body tokenizer and note/rest/tie/accidental resolution

**Files:**
- Modify: `os/util/music/abcnotation.py` (append to the file from Task 6)
- Modify: `os/util/music/tests/test_abcnotation.py` (append)

**Interfaces:**
- Consumes: `key_signature_accidentals`, `parse_unit_length` from Task 6; `Note` from `notes.py`; `midi_to_freq` from `freq.py`.
- Produces:
  - `_tokenize_body_line(text: str, line: int) -> list` — internal; list of `("bar", None)` / `("note", raw_token_str)` tuples for one already-header-stripped body line. Raises `ParseError` naming `line` for chords `[`, grace notes `{`, tuplets `(3`, broken rhythm `>`/`<`, or any unrecognized character.
  - `_tokens_to_notes(tokens: list, unit_length: Fraction, key_accidentals: dict, line: int) -> list` — internal; converts one line's tokens into `list[Note]`, tracking bar-scoped accidentals and cross-token tie state (tie state does NOT reset at end of line — callers processing multiple lines must thread `pending_tie` themselves; for this task's tests, each call is a single self-contained line so no note is left tied off across the return boundary within a single test — Task 8 handles multi-line tune bodies by accumulating one `list[Note]` at a time per line, which is what the spec calls for and what real ABC tunes do since ties are conventionally resolved within held-note pairs that appear close together).

- [ ] **Step 1: Write the failing tests**

Append to `os/util/music/tests/test_abcnotation.py`:

```python
from abcnotation import _tokenize_body_line, _tokens_to_notes
from freq import midi_to_freq


def test_tokenize_body_line_notes_and_bar():
    tokens = _tokenize_body_line("CDE|F", line=1)
    assert tokens == [
        ("note", "C"), ("note", "D"), ("note", "E"),
        ("bar", None), ("note", "F"),
    ]


def test_tokenize_body_line_skips_comment_and_chord_annotation():
    tokens = _tokenize_body_line('C "Cmaj7" D % trailing comment', line=1)
    assert tokens == [("note", "C"), ("note", "D")]


def test_tokenize_body_line_rejects_chord():
    with pytest.raises(ParseError, match=r"line 2"):
        _tokenize_body_line("[CEG]", line=2)


def test_tokenize_body_line_rejects_grace_note():
    with pytest.raises(ParseError, match=r"line 3"):
        _tokenize_body_line("{c}D", line=3)


def test_tokenize_body_line_rejects_tuplet():
    with pytest.raises(ParseError, match=r"line 4"):
        _tokenize_body_line("(3CDE", line=4)


def test_tokenize_body_line_rejects_broken_rhythm():
    with pytest.raises(ParseError, match=r"line 5"):
        _tokenize_body_line("C>D", line=5)


def test_tokens_to_notes_plain_pitch_no_key():
    tokens = _tokenize_body_line("C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert len(notes) == 1
    assert notes[0].freq == midi_to_freq(60)  # uppercase C = MIDI 60
    assert notes[0].beats == pytest.approx(0.5)  # 1/8 whole note * 4


def test_tokens_to_notes_lowercase_is_one_octave_up():
    tokens = _tokenize_body_line("c", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(72)


def test_tokens_to_notes_octave_marks():
    tokens = _tokenize_body_line("C,c'", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(48)   # C, = one octave below C
    assert notes[1].freq == midi_to_freq(84)   # c' = one octave above c


def test_tokens_to_notes_rest():
    tokens = _tokenize_body_line("z2", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq is None
    assert notes[0].beats == pytest.approx(1.0)  # 2 * 1/8 whole * 4


def test_tokens_to_notes_length_modifiers():
    tokens = _tokenize_body_line("C2 C/2 C3/2 C//", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 4), {}, line=1)
    # unit length 1/4 -> beats = multiplier * 1/4 * 4 = multiplier
    assert [n.beats for n in notes] == [2.0, 0.5, 1.5, 0.25]


def test_tokens_to_notes_explicit_accidental_applies():
    tokens = _tokenize_body_line("^C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)  # C sharp


def test_tokens_to_notes_bar_scoped_accidental_carries_within_bar():
    tokens = _tokenize_body_line("^C C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)
    assert notes[1].freq == midi_to_freq(61)  # still sharp, same bar


def test_tokens_to_notes_bar_line_resets_accidental():
    tokens = _tokenize_body_line("^C | C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), {}, line=1)
    assert notes[0].freq == midi_to_freq(61)
    assert notes[1].freq == midi_to_freq(60)  # natural again after the bar


def test_tokens_to_notes_key_signature_default_applies():
    key_acc = key_signature_accidentals("D", line=1)  # F#, C#
    tokens = _tokenize_body_line("F C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), key_acc, line=1)
    assert notes[0].freq == midi_to_freq(66)  # F# by key signature
    assert notes[1].freq == midi_to_freq(61)  # C# by key signature


def test_tokens_to_notes_explicit_natural_overrides_key():
    key_acc = key_signature_accidentals("D", line=1)  # F#, C#
    tokens = _tokenize_body_line("=F", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 8), key_acc, line=1)
    assert notes[0].freq == midi_to_freq(65)  # forced natural F


def test_tokens_to_notes_tie_merges_same_pitch():
    tokens = _tokenize_body_line("C-C", line=1)
    notes = _tokens_to_notes(tokens, Fraction(1, 4), {}, line=1)
    assert len(notes) == 1
    assert notes[0].beats == pytest.approx(2.0)
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: FAIL — `ImportError: cannot import name '_tokenize_body_line'`.

- [ ] **Step 3: Append the tokenizer/resolver to `abcnotation.py`**

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/abcnotation.py os/util/music/tests/test_abcnotation.py
git commit -m "Add ABC body tokenizer and note/accidental/tie resolution for mkmus.py"
```

---

## Task 8: `abcnotation.py` part C — tune splitting, multi-tune, `w:` lyrics, `parse_abc`

**Files:**
- Modify: `os/util/music/abcnotation.py` (append to the file from Task 7)
- Modify: `os/util/music/tests/test_abcnotation.py` (append)

**Interfaces:**
- Consumes: everything from Tasks 6-7 in this same file.
- Produces:
  - `@dataclass class AbcTune: number: int; title: str; notes: list; tempo_bpm: float | None` (`notes` is `list[Note]`).
  - `parse_abc(text: str) -> list` — returns `list[AbcTune]`, one per `X:` header found. Raises `ParseError` (naming the line) for `V:` headers anywhere, or if no `X:` tune is found at all.

- [ ] **Step 1: Write the failing tests**

Append to `os/util/music/tests/test_abcnotation.py`:

```python
from abcnotation import AbcTune, parse_abc


_SIMPLE_TUNE = """X:1
T:Test Tune
K:C
L:1/8
Q:1/4=100
CDEF|GABc
"""


def test_parse_abc_single_tune_basics():
    tunes = parse_abc(_SIMPLE_TUNE)
    assert len(tunes) == 1
    tune = tunes[0]
    assert isinstance(tune, AbcTune)
    assert tune.number == 1
    assert tune.title == "Test Tune"
    assert tune.tempo_bpm == 100.0
    assert len(tune.notes) == 8
    assert tune.notes[0].freq == midi_to_freq(60)  # C
    assert tune.notes[-1].freq == midi_to_freq(72)  # c


def test_parse_abc_multiple_tunes():
    text = _SIMPLE_TUNE + "\nX:2\nT:Second\nK:G\nGABc\n"
    tunes = parse_abc(text)
    assert [t.number for t in tunes] == [1, 2]
    assert tunes[1].title == "Second"


def test_parse_abc_no_tempo_field_leaves_none():
    text = "X:1\nT:No Tempo\nK:C\nCDEF\n"
    tunes = parse_abc(text)
    assert tunes[0].tempo_bpm is None


def test_parse_abc_lyrics_line_maps_to_comments():
    text = "X:1\nT:Lyrics\nK:C\nCDEF\nw:one two three four\n"
    tunes = parse_abc(text)
    assert [n.comment for n in tunes[0].notes] == ["one", "two", "three", "four"]


def test_parse_abc_lyrics_skip_rests():
    text = "X:1\nT:Lyrics\nK:C\nCzDF\nw:one two three\n"
    tunes = parse_abc(text)
    comments = [n.comment for n in tunes[0].notes]
    assert comments[0] == "one"   # C
    assert comments[1] == ""      # z (rest, no lyric)
    assert comments[2] == "two"   # D
    assert comments[3] == "three" # F


def test_parse_abc_voice_header_rejected():
    text = "X:1\nT:Voices\nK:C\nV:1\nCDEF\n"
    with pytest.raises(ParseError, match=r"line 4"):
        parse_abc(text)


def test_parse_abc_no_tunes_raises():
    with pytest.raises(ParseError):
        parse_abc("this is not an ABC file at all\n")


def test_parse_abc_multibar_line_spans_lines_reset_by_bar_not_newline():
    text = "X:1\nT:Multi\nK:C\n^C C\nC\n"
    tunes = parse_abc(text)
    # accidental carries within the (unbarred) tune across the newline,
    # since only bar lines reset it
    freqs = [n.freq for n in tunes[0].notes]
    assert freqs == [midi_to_freq(61), midi_to_freq(61), midi_to_freq(61)]
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: FAIL — `ImportError: cannot import name 'AbcTune'`.

- [ ] **Step 3: Replace Task 7's `_tokens_to_notes` with a shared token-resolver, then append tune splitting and `parse_abc`**

`test_parse_abc_multibar_line_spans_lines_reset_by_bar_not_newline` requires bar-scoped accidental state (and tie state) to persist across a tune's body lines — only an actual bar-line token resets accidentals, never a newline. Task 7's `_tokens_to_notes` owned that state internally per call, which doesn't allow threading it across lines. Replace `_tokens_to_notes`'s body in place with the three functions below: `_resolve_tokens` holds the one real implementation of the per-token logic (identical to Task 7's version, but taking `bar_accidentals`/`pending_tie` as parameters instead of owning them); `_tokens_to_notes` becomes a thin single-line wrapper around it (so Task 7's own tests, which call it directly with fresh state each time, keep passing unchanged); and `_parse_body_line_notes` is the multi-line entry point `parse_abc` uses, tokenizing first and delegating to the same `_resolve_tokens`.

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_abcnotation.py -v`
Expected: all tests PASS (both Task 7's and Task 8's).

- [ ] **Step 5: Commit**

```bash
git add os/util/music/abcnotation.py os/util/music/tests/test_abcnotation.py
git commit -m "Add ABC tune splitting, multi-tune, w: lyrics, and parse_abc for mkmus.py"
```

---

## Task 9: `mkmus.py` — CLI orchestration

**Files:**
- Create: `os/util/music/mkmus.py`
- Test: `os/util/music/tests/test_mkmus.py`

**Interfaces:**
- Consumes: `freq.parse_frequency`; `bespoke.parse_bespoke`, `bespoke.ParseError`; `abcnotation.detect_format`, `abcnotation.parse_abc`, `abcnotation.ParseError`; `notes.note_to_divisor`, `notes.note_to_duration_ticks`, `notes.ConversionError`; `mus_writer.encode_record`, `mus_writer.write_mus`.
- Produces:
  - `class MkmusError(Exception)`
  - `detect_and_parse(text: str, tune_arg: int | None) -> tuple` — returns `(list[Note], tempo_bpm_or_None)`; raises `MkmusError` for parse errors, an unresolved multi-tune file, an unknown `--tune` number, or `--tune` given for a bespoke file.
  - `build_records(notes: list, tone_freq: float, beat_freq: float, tempo: float, warnings: list) -> list` — returns `list[bytes]`; raises `MkmusError` on out-of-range conversions; appends truncation-warning strings to `warnings`.
  - `main(argv=None) -> int` — the CLI entry point; returns a process exit code.

- [ ] **Step 1: Write the failing tests**

```python
import struct
import pytest

from mkmus import detect_and_parse, build_records, main, MkmusError
from notes import Note
from mus_writer import TERMINATOR


def test_detect_and_parse_bespoke():
    notes, tempo = detect_and_parse("A4 /4 hi\n", tune_arg=None)
    assert len(notes) == 1
    assert tempo is None


def test_detect_and_parse_tune_arg_invalid_for_bespoke():
    with pytest.raises(MkmusError, match="only valid for ABC"):
        detect_and_parse("A4 /4 hi\n", tune_arg=1)


def test_detect_and_parse_single_tune_abc_ignores_missing_tune_arg():
    text = "X:1\nT:T\nK:C\nCDEF\n"
    notes, tempo = detect_and_parse(text, tune_arg=None)
    assert len(notes) == 4


def test_detect_and_parse_multi_tune_requires_tune_arg():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    with pytest.raises(MkmusError, match="multiple tunes"):
        detect_and_parse(text, tune_arg=None)


def test_detect_and_parse_multi_tune_selects_requested_tune():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    notes, tempo = detect_and_parse(text, tune_arg=2)
    assert len(notes) == 4
    assert notes[0].freq is not None


def test_detect_and_parse_unknown_tune_number():
    text = "X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n"
    with pytest.raises(MkmusError, match="not found"):
        detect_and_parse(text, tune_arg=99)


def test_build_records_basic():
    notes = [Note(freq=440.0, beats=1.0, comment="hi", line=1)]
    warnings = []
    records = build_records(notes, 1843200.0, 32768.0, 120.0, warnings)
    divisor, duration, comment = struct.unpack(">HH12s", records[0])
    assert divisor == 4189
    assert duration == 16384
    assert comment == b"hi" + b"\0" * 10
    assert warnings == []


def test_build_records_out_of_range_raises_mkmus_error():
    notes = [Note(freq=10_000_000.0, beats=1.0, comment="", line=5)]
    with pytest.raises(MkmusError, match="line 5"):
        build_records(notes, 1843200.0, 32768.0, 120.0, [])


def test_build_records_long_comment_warns():
    notes = [Note(freq=440.0, beats=1.0, comment="this is a very long comment", line=2)]
    warnings = []
    build_records(notes, 1843200.0, 32768.0, 120.0, warnings)
    assert len(warnings) == 1
    assert "line 2" in warnings[0]


def test_main_writes_mus_file(tmp_path):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\nz /8\n")
    out = tmp_path / "song.MUS"
    rc = main(["--tone-freq", "1843200", "--beat-freq", "32768",
               "-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    assert data.endswith(TERMINATOR)
    assert len(data) == 2 * 16 + 16  # 2 notes + terminator


def test_main_default_output_name(tmp_path, monkeypatch):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    monkeypatch.chdir(tmp_path)
    rc = main([str(src)])
    assert rc == 0
    assert (tmp_path / "SONG.MUS").exists()


def test_main_dry_run_writes_nothing(tmp_path, capsys):
    src = tmp_path / "song.txt"
    src.write_text("A4 /4 hi\n")
    out = tmp_path / "song.MUS"
    rc = main(["--dry-run", "-o", str(out), str(src)])
    assert rc == 0
    assert not out.exists()
    captured = capsys.readouterr()
    assert "divisor=4189" in captured.out


def test_main_tune_required_for_multi_tune_file_exits_nonzero(tmp_path, capsys):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:First\nK:C\nCDEF\nX:2\nT:Second\nK:C\nGABc\n")
    rc = main([str(src)])
    assert rc != 0
    captured = capsys.readouterr()
    assert "multiple tunes" in captured.err


def test_main_tempo_flag_overrides_abc_q_field(tmp_path):
    src = tmp_path / "song.abc"
    src.write_text("X:1\nT:T\nK:C\nQ:1/4=60\nC\n")
    out = tmp_path / "song.MUS"
    rc = main(["--tempo", "120", "-o", str(out), str(src)])
    assert rc == 0
    data = out.read_bytes()
    divisor, duration, comment = struct.unpack(">HH12s", data[:16])
    # unit length default 1/8 -> beats=0.5; at 120 BPM: round(0.5*0.5*32768)=8192
    assert duration == 8192


def test_main_conversion_error_writes_no_partial_file(tmp_path):
    src = tmp_path / "song.txt"
    src.write_text("C4 /1000000 hi\n")  # absurd duration -> out of range
    out = tmp_path / "song.MUS"
    rc = main(["-o", str(out), str(src)])
    assert rc != 0
    assert not out.exists()
```

Note: `test_main_conversion_error_writes_no_partial_file` relies on `/1000000` being an invalid bespoke duration denominator producing a tiny fraction whose duration-ticks rounds to 0 (out of range) — `4.0/1000000` beats at 120 BPM/32768Hz rounds to 0 ticks, which `note_to_duration_ticks` rejects. (An earlier draft of this test used `/65536`, which actually rounds to 1 tick — a valid, in-range value — and would not have exercised the error path at all; caught during Task 9's implementation and corrected here.)

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_mkmus.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'mkmus'`.

- [ ] **Step 3: Implement `mkmus.py`**

```python
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
```

- [ ] **Step 4: Run to verify pass**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_mkmus.py -v`
Expected: all tests PASS.

- [ ] **Step 5: Make it executable and commit**

```bash
chmod +x os/util/music/mkmus.py
git add os/util/music/mkmus.py os/util/music/tests/test_mkmus.py
git commit -m "Add mkmus.py CLI: format auto-detect, tempo resolution, .MUS output"
```

---

## Task 10: End-to-end byte-exact output tests

**Files:**
- Modify: `os/util/music/tests/test_mkmus.py` (append)

**Interfaces:**
- Consumes: `main` from `mkmus.py`; `bespoke.parse_bespoke`; `abcnotation.parse_abc`; `notes.note_to_divisor`, `notes.note_to_duration_ticks`; `mus_writer.encode_record`, `mus_writer.TERMINATOR` — used to independently re-derive the expected byte sequence from the same lower-level functions Tasks 3-8 already unit-tested, so this test catches wiring bugs in `main()`'s pipeline without baking hand-computed magic numbers (already a source of an off-by-one in this plan's own drafting — see the Self-Review note below) into the test itself.
- Produces: two new tests providing the spec's required "one end-to-end test per input format asserting the exact output bytes (including the terminator record)."

- [ ] **Step 1: Write the failing tests**

Append to `os/util/music/tests/test_mkmus.py`:

```python
from bespoke import parse_bespoke
from abcnotation import parse_abc
from mus_writer import encode_record, TERMINATOR


def _expected_bytes(parsed_notes, tone_freq, beat_freq, tempo):
    out = b""
    for note in parsed_notes:
        divisor = note_to_divisor(note.freq, tone_freq, note.line)
        duration = note_to_duration_ticks(note.beats, tempo, beat_freq, note.line)
        out += encode_record(divisor, duration, note.comment, note.line)
    return out + TERMINATOR


def test_end_to_end_bespoke_exact_bytes(tmp_path):
    text = "A4 /4 hello\nz /8\nC4 /4 world\n"
    src = tmp_path / "tune.txt"
    src.write_text(text)
    out = tmp_path / "tune.MUS"

    rc = main(["-o", str(out), str(src)])
    assert rc == 0

    expected = _expected_bytes(parse_bespoke(text), 1843200.0, 32768.0, 120.0)
    assert out.read_bytes() == expected


def test_end_to_end_abc_exact_bytes(tmp_path):
    text = "X:1\nT:Tune\nK:C\nL:1/8\nQ:1/4=100\nCDEF|GABc\nw:do re mi fa sol la ti do\n"
    src = tmp_path / "tune.abc"
    src.write_text(text)
    out = tmp_path / "tune.MUS"

    rc = main(["-o", str(out), str(src)])
    assert rc == 0

    tune = parse_abc(text)[0]
    expected = _expected_bytes(tune.notes, 1843200.0, 32768.0, tune.tempo_bpm)
    assert out.read_bytes() == expected
```

- [ ] **Step 2: Run to verify failure**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/test_mkmus.py -v -k end_to_end`
Expected: FAIL initially only if `_expected_bytes` or an import is missing; if `mkmus.py` from Task 9 is already correct these may pass immediately on first run since no new production code is introduced by this task. If they pass immediately, that itself is the confirmation this task exists to provide — proceed to Step 4 without a Step 3 code change.

- [ ] **Step 3: No implementation changes expected**

This task adds tests only, re-using every function `mkmus.py` and its collaborators already provide. If a failure appears here, it means `main()`'s wiring (format dispatch, tempo resolution, or record assembly) diverges from calling the lower-level functions directly — fix `mkmus.py`'s `detect_and_parse`/`build_records`/`main` (from Task 9) to match, not this test.

- [ ] **Step 4: Run the full test suite to verify everything passes together**

Run: `os/util/music/.venv/bin/pytest os/util/music/tests/ -v`
Expected: all tests across all modules PASS.

- [ ] **Step 5: Commit**

```bash
git add os/util/music/tests/test_mkmus.py
git commit -m "Add end-to-end byte-exact output tests for mkmus.py"
```

---

## Self-Review

**1. Spec coverage:**
- Auto-detect bespoke/ABC → Task 6 (`detect_format`), wired in Task 9 (`detect_and_parse`). ✓
- Bespoke format (pitch, `z` rest, `/N` duration, comment, blank/`#` lines) → Task 5. ✓
- ABC supported subset (headers X/T/K/L/Q/w, pitches, octave marks, accidentals bar-scoped, rests, length modifiers, ties, bar lines, `%` comments, quoted chord annotations) → Tasks 6-8. ✓
- ABC rejected constructs (chords, V:, grace notes, tuplets, broken rhythm, modal keys) → Task 7 (tokenizer rejections) and Task 8 (`V:` rejection), each with its own test. ✓
- CLI flags `--tone-freq --beat-freq --tempo --tune -o/--output --dry-run` → Task 9. ✓
- Conversion math (divisor, duration, range validation 1..65535, hand-computed A4→4189 example) → Task 3, re-verified in Task 10's end-to-end tests. ✓
- Comment truncation + warning → Task 4, exercised again in Task 9. ✓
- Output format (BE u16 divisor/duration, 12-byte comment, terminator record) → Task 4. ✓
- Error handling (line-numbered errors, no partial file, multi-tune gate, unsupported-construct hard errors) → Tasks 5, 7, 8, 9. ✓
- Testing requirements list from the spec → mapped 1:1 onto Tasks 3-10 above; every bullet has at least one dedicated test.
- Out of scope items (full ABC generality, non-equal-temperament, other formats, GUI) → correctly never attempted by any task.

**2. Placeholder scan:** No `TBD`/`TODO` in any task; every step has literal, runnable code (test code and implementation code both written out in full, not described).

**3. Type consistency:** `Note(freq, beats, comment, line)` field names and order are identical everywhere they're constructed (`bespoke.py`, `abcnotation.py`) and everywhere they're read (`notes.py`'s conversion functions, `mkmus.py`'s `build_records`/`main`). `ParseError` is deliberately defined separately in `bespoke.py` and `abcnotation.py` (not shared) since `mkmus.py`'s `detect_and_parse` catches each module's own exception type by its own import path — this is intentional, not an inconsistency. `ConversionError` lives only in `notes.py` and is imported everywhere it's raised or caught.

**One correction made during this review:** an earlier draft of Task 8's Step 3 showed a first-pass implementation and then a second block replacing it, which is exactly the kind of ambiguity a fresh implementer shouldn't have to resolve. Rewrote it to present only the final code: `_resolve_tokens` holds the one real implementation, `_tokens_to_notes` (Task 7's per-line entry point, still called directly by Task 7's own tests) is a thin wrapper around it, and `_parse_body_line_notes` (the multi-line entry point `parse_abc` uses) is another thin wrapper — no draft-then-replace, no duplicate logic.

**Hand-computed values were independently checked, not assumed:** the A4/1.8432MHz → divisor 4189 example was re-run in Python during planning (`round(1843200/440) == 4189`), and a similarly-tempting hand computation for C4's divisor was caught as arithmetically wrong when checked the same way (mental math gave 7044, Python gives 7045) — which is precisely why Task 10's end-to-end tests derive their expected bytes from the already-unit-tested conversion functions instead of hardcoding a second, independently-typed set of magic numbers that could silently drift from the real math.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-10-mkmus-music-converter.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
