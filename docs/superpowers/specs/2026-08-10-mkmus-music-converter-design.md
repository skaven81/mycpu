# mkmus.py — .MUS music file converter

Date: 2026-08-10
Status: Approved (pending spec review)

## Purpose

`os/util/music/MUSIC.ODY` (built earlier in this session) plays a song by
reading 16-byte note records out of an extended-memory page loaded from a
`.MUS` file:

```
offset 0x00  divisor   (16-bit, big-endian; 0x0000 = silence)
offset 0x02  duration  (16-bit, big-endian; 32.768kHz ticks)
offset 0x04  comment   (12 bytes, null-terminated)
```

A record with `divisor == 0x0000 AND duration == 0x0000` marks end of song.

This project adds `os/util/music/mkmus.py`, a host-side Python CLI that
generates `.MUS` files from human-writable input, so songs don't have to be
hand-assembled as raw bytes.

## Input formats

The script accepts two input formats and auto-detects which one a file uses
(presence of an ABC `X:` header line near the top of the file selects ABC;
otherwise the file is treated as the bespoke line format).

### Bespoke line format

One note per line, whitespace-separated fields:

```
PITCH DURATION [comment text...]
```

- `PITCH`: scientific pitch notation, e.g. `C4`, `A#3`, `Bb5`.
- Rest: literal `z` in the pitch column (matches ABC's rest symbol, so the
  two formats share one rest token).
- `DURATION`: `/N`, a fraction of a whole note (`/4` = quarter note = 1
  beat, `/8` = eighth = 0.5 beat, `/16` = sixteenth = 0.25 beat, etc.),
  matching standard music-engraving fraction notation and ABC's own `L:`
  convention.
- Everything after the duration field, to end of line, is the comment
  (may be empty).
- Blank lines and lines starting with `#` are ignored.

### ABC notation (bounded subset of ABC v2.1)

Chosen because it is an established, decades-old plain-text standard for
monophonic/folk tune transcription with large public-domain tune
collections (abcnotation.com, thesession.org) — using it means real tunes
can be fed in directly instead of hand-transcribed.

Because the target hardware is a single square-wave channel, this is a
**deliberately bounded subset**, not full ABC:

**Supported:**
- Headers: `X:` (tune number, selects among multiple tunes with `--tune`),
  `T:` (title, shown when multiple tunes require `--tune`), `K:` (key
  signature — major/minor keys only — sets default accidentals), `L:`
  (unit note length), `Q:` (tempo; overridden by `--tempo` if the flag is
  given), `w:` (lyrics line, mapped one-syllable-per-note to the note's
  comment field).
- Body: pitch letters `A-G a-g`; octave marks `,` and `'`; accidentals
  `^ ^^ _ __ =` (bar-scoped: an accidental applies to all later notes of
  the same pitch/octave within the same bar, per standard ABC semantics);
  rests `z Z`; note-length modifiers (bare integer multiplier, `/divisor`,
  combined forms like `3/2`); ties (`-`) merging two same-pitch notes into
  one longer note; bar lines (all forms) and `%` end-of-line comments,
  ignored structurally; quoted guitar-chord annotations (`"Cmaj7"`) skipped
  silently (they are accompaniment hints, not notes).

**Explicitly rejected** (hard error naming the line, not silently
mishandled): chords `[CEG]`, additional voices (`V:` beyond the implicit
single voice), grace notes `{..}`, triplets/tuplets (`(3` etc.), broken
rhythm markers (`>` `<`), modal keys (`Dmix`, `Ador`, etc.).

## CLI

```
mkmus.py [options] INPUT_FILE

--tone-freq FREQ   Tone generator base clock (default 1.8432MHz).
                    Accepts bare Hz or suffixed forms: 1843200, 1.8432MHz, 1843.2k
--beat-freq FREQ   Beat/duration timer base clock (default 32.768kHz).
                    Same accepted forms as --tone-freq.
--tempo BPM         Tempo in quarter-note beats per minute (default 120).
                    Always overrides an ABC file's own Q: field when given.
--tune N            Select tune N from a multi-tune ABC file (by X: number).
                    Required (script lists found tunes and exits) if the
                    file contains more than one X: tune. Invalid for the
                    bespoke format.
-o, --output PATH   Output .MUS path (default: INPUT stem, uppercased, + .MUS,
                    matching this repo's FAT16-8.3-style naming e.g. MUSIC.ODY).
--dry-run           Print the parsed note table (pitch, freq, divisor,
                    duration ticks, comment) without writing a file.
```

## Conversion math

- Pitch → frequency: equal temperament, A4 = 440Hz, via MIDI note number
  (`freq = 440 * 2**((midi_num - 69) / 12)`).
- Frequency → divisor (82C54 mode 3, output = clock / N):
  `divisor = round(tone_freq / note_freq)`.
- Duration fraction → beat timer ticks: a duration fraction is "of a whole
  note," so beats = `fraction * 4` (quarter note = 1 beat, the standard BPM
  convention):
  `duration_ticks = round(fraction * 4 * (60 / tempo) * beat_freq)`.
- Both `divisor` and `duration_ticks` must land in `1..65535` (0 is reserved
  for "silence"/end-of-song). A note computing outside that range is a hard
  error identifying the note and line — never silently clamped or wrapped.
- Comments longer than 11 characters are truncated to fit the 12-byte
  null-terminated field, with a warning to stderr identifying the line.

## Output format

For each note record, in order: divisor (big-endian u16), duration
(big-endian u16), comment (ASCII, null-padded/truncated to 12 bytes).
After the last note, one all-zero 16-byte terminator record. This is a
byte-for-byte match to what `MUSIC.ODY`'s `.play_next_note` reads.

## Error handling

- All parse/validation errors reference the offending input line number and
  token; the script exits non-zero and writes nothing (no partial `.MUS`
  file on failure).
- A multi-tune ABC file without `--tune` prints the found tune numbers and
  titles and exits, asking the user to pick one.
- Unsupported ABC constructs (see rejected list above) are a hard parse
  error, not a best-effort guess.

## Testing

`os/util/music/tests/test_mkmus.py`, using `pytest` (matching the existing
`odyssey_video/tests/` convention in this repo). Coverage:
- Frequency→divisor and duration→ticks math against hand-computed values
  (e.g. A4/440Hz at the default 1.8432MHz tone clock → divisor 4189).
- Bespoke-format parsing, including `z` rests and comment text.
- ABC parsing: octave marks, accidentals (including bar-scoping), ties,
  key-signature default accidentals, `w:` lyric-to-comment mapping.
- Multi-tune-file-requires-`--tune` gate.
- Comment truncation warning.
- Range-validation hard errors (divisor/duration outside `1..65535`).
- Rejection of each explicitly-unsupported ABC construct.
- One end-to-end test per input format asserting the exact output bytes
  (including the terminator record) for a small known tune.

## Out of scope

- Full ABC v2.1 (multi-voice, chords, ornaments, grace notes, tuplets,
  modal keys) — doesn't map onto one square-wave channel.
- Non-equal-temperament tunings.
- Reading/writing MIDI, MusicXML, or any format other than the two above.
- A GUI or interactive mode.
