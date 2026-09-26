# Odyssey music

This directory holds the song sources and the host-side converter that turns them into `.MUS` files. Those files are played through the piezo speaker by `MUSIC.ODY` (`os/util/music/`) and by any program that links the background player library `os/lib/music_player.asm`.

```
make            # build every NAME.MUS from NAME.abc / NAME.txt, and sfx/NAME.MUS from sfx/NAME.sfx
make sdcard     # copy all of those .MUS files to /media/skaven/ODYSSEY/MUSIC
make test       # run the converter's unit tests (sets up mkmus/.venv with uv)
make clean
```

On the Odyssey:

```
cd music
music twinkle.mus
```

## Songs

| Source         | Output         | Notes                                          |
|----------------|----------------|------------------------------------------------|
| `amazgrac.abc` | `AMAZGRAC.MUS` | Amazing Grace, verse 1 with lyrics             |
| `odetojoy.abc` | `ODETOJOY.MUS` | Ode to Joy, no lyrics                          |
| `silentnt.abc` | `SILENTNT.MUS` | Silent Night, verse 1 with lyrics              |
| `tetris.txt`   | `TETRIS.MUS`   | Tetris theme (Korobeiniki), no comments: the reference "no comments" song |
| `twinkle.abc`  | `TWINKLE.MUS`  | Twinkle, Twinkle Little Star with lyrics       |

## Adding a song

1. Drop a `NAME.abc` or `NAME.txt` file here. `NAME` becomes the FAT16 8.3 name on the SD card (`NAME.MUS`, uppercased), so it must be **at most 8 characters**. Use only letters, digits, `-` and `_`. The Makefile rejects longer names.
2. For ABC input, set the tempo with a `Q:` header. For bespoke input, which has no tempo field, add a per-target line to the Makefile. The default is 120 quarter-note BPM.
   ```make
   NAME.MUS: MKMUS_FLAGS += --tempo 150
   ```
3. Run `make`, then `make sdcard` (or copy the file over by hand).

The player loads only the first 4096 bytes of a file. That is 255 notes plus the terminator. Inserted repeat gaps (see below) count as notes.

## Source formats

`mkmus/mkmus.py` treats the input as ABC if an `X:` header appears in its first five non-blank lines. Otherwise it reads the input as the bespoke format.

### Bespoke format (`.txt`)

The file has one note per line: `PITCH DURATION [comment]`.

```
# lines starting with '#' and blank lines are ignored
E5 /4 Hello
B4 /8
z  /4          <- rest
```

- `PITCH` is scientific pitch notation (`C4`, `A#3`, `Bb5`), or `z` for a rest.
- `DURATION` is `/N`, a fraction of a whole note: `/4` is a quarter, `/8` an eighth, and so on.
- The comment is everything after the duration.

### ABC notation (`.abc`)

This is a bounded subset of ABC v2.1:

- **Headers:** `X:` (tune number), `T:`, `M:`, `L:`, `Q:`, `K:`. `K:` accepts only major and minor keys; modal keys are rejected.
- **Pitch:** notes `A-G a-g`, octave marks `,` and `'`, and bar-scoped accidentals `^ ^^ _ __ =`.
- **Rests:** `z` and `Z`.
- **Length and ties:** length modifiers (`2`, `/2`, `3/2`). Ties (`-`) join same-pitch notes into one note.
- **Ignored:** bar lines and `%` comments. Quoted chord symbols (`"G7"`) are skipped.
- **Rejected with an error:** chords `[CEG]`, grace notes `{}`, tuplets `(3`, broken rhythm `>` `<`, and extra voices `V:`.
- **Multiple tunes:** a file with several `X:` tunes needs `--tune N`.

## Comments and lyrics

Each note record carries a comment of up to 11 characters; longer comments are truncated with a warning. When a note starts, the player hands its comment to the program, and `MUSIC.ODY` prints it **verbatim**, adding nothing. Any spacing or line breaks must therefore be part of the comment. mkmus adds them for you:

- **Bespoke files:** the comment is the rest of the line, and mkmus appends a newline, so each comment prints on its own line.
- **ABC files:** comments come from `w:` lyric lines and are formatted as running text, **one line per bar**. Syllable hyphens are dropped (`Twin-kle` prints as `Twinkle`) and a space follows each word. A newline follows the last word of each bar. A word belongs to the bar its first syllable starts in, so a word that crosses a bar line ends its starting line.

Each `w:` line assigns syllables, in order, to the sounding notes that follow the previous `w:` line. Rests and tied continuation notes get no syllable. The standard alignment symbols are supported:

| Symbol | Meaning                                                           |
|--------|-------------------------------------------------------------------|
| space  | separates words                                                   |
| `-`    | separates syllables within a word                                 |
| `_`    | holds the previous syllable over one more note (melisma)          |
| `*`    | skips a note                                                      |
| `~`    | joins words onto a single note                                    |
| `\-`   | a literal hyphen                                                  |
| `\|`   | ignored (syllables are not re-aligned at bar lines)               |

To check the alignment before building, run `python3 mkmus/mkmus.py --dry-run song.abc`, which prints every note with its comment.

## Converter options

```
mkmus/mkmus.py [--tempo BPM] [--repeat-gap PCT] [--tune N]
               [--tone-freq F] [--beat-freq F] [-o OUT] [--dry-run] INPUT
```

- `--tempo` sets quarter-note BPM. It overrides the ABC `Q:` header. The default is 120.
- `--repeat-gap` inserts a short rest between consecutive notes of the same pitch, so repeated notes sound separate. The value is a percentage of a quarter-note beat; the default is 10, and 0 disables it.
- `--tone-freq` and `--beat-freq` set the timer clocks: 1.8432 MHz for Timer 1 tone generation and 32.768 kHz for Timer 2 note duration. Change them only if the hardware changes.

A single note's duration must fit in 65535 ticks of the 32.768 kHz clock, which is just under 2 seconds. A very long held note at a slow tempo fails with "duration out of range". Raise the tempo or split the note with a rest.

## Sound effects

A sound effect is just a short song. It uses the same `.MUS` records and plays through the same `music_play` call, but it is authored in milliseconds and Hz instead of beats and tempo. Changing the tone every few milliseconds gives sweeps, chirps and arpeggios. The piezo is monophonic: starting an effect stops whatever was playing, and it does not resume.

Tempo plays no part. A record's duration is raw 32.768 kHz Timer 2 ticks (1 ms is about 33 ticks, 1 tick is 30.5 µs), so millisecond steps work directly.

### `.sfx` source format

Each `.sfx` file is one effect, named after its basename (letters, digits and `_`; at most 8 characters if you want a `.MUS` for it). There is one command per line, and `#` starts a comment:

```
tone  C6   8              # PITCH MS: note name (C6, F#5, Bb4) or Hz (880, 1.2k)
rest       4              # MS of silence
sweep 300  1500  120  4   # FROM TO MS STEP_MS: glide in STEP_MS steps
repeat 3                  # repeat everything up to 'end' N times (nestable)
  tone E6 15
  tone G6 15
end
```

- `sweep` is pitch-linear: consecutive steps have equal frequency ratios, so it sounds even. It starts exactly at FROM, ends exactly at TO, and its total length is exactly MS.
- Nothing is inserted between steps; there are no repeat gaps.
- Durations round to whole ticks, with a minimum of 1.
- A step over about 2 s, or a pitch outside about 28 Hz to 1.8 MHz, is an error.

Examples are in `sfx/`. Preview any effect with `python3 mkmus/mksfx.py --dry-run sfx/laser.sfx`.

### Step length: keep it at 3 ms or more

Every step costs one Timer 2 interrupt, with interrupts masked while the handler runs. With `status = NULL` that is about 230 CPU cycles (counted from the microcode), or about 0.12 ms at 2 MHz. So:

- **1 ms steps** take about 12% of the CPU while the effect plays. **3–5 ms steps** cost 2–4% and still sound smooth, and mksfx warns below 2 ms.
- Each step also runs slightly long by that interrupt latency. This does not matter for effects.
- **A pitch change waits for the current half-cycle** of the tone. That keeps glides click-free, but a step shorter than half the tone's period is not heard (at 200 Hz a half-cycle is 2.5 ms). mksfx warns about these steps.
- Sub-millisecond "noise" (random pitch hopping) is not practical.

### Auditioning

`make` builds each `sfx/NAME.sfx` into `sfx/NAME.MUS`, and `make sdcard` copies them into `MUSIC/` with the songs, so you can try one on the machine:

```
music laser.mus
```

### Using effects in a program

A program embeds its effects as a bank:

```
python3 path/to/music/mkmus/mksfx.py -o sfx_bank sfx/*.sfx
```

This writes two files:
- `sfx_bank.asm`: the records for each effect, plus `:sfx_get`, which maps an id to the address of that effect's records.
- `sfx_bank.h`: an `SFX_<NAME>` id for each effect (numbered in command-line order), plus the `sfx_get` prototype.

Put both in the build directory next to the `music_player` symlinks, then:

```c
#include "music_player.h"
#include "sfx_bank.h"

music_play(sfx_get(SFX_LASER), 0, NULL, NULL);   // one-shot; stops any music
```

- Pass `status = NULL`. That skips the per-note comment copy, which is the most expensive part of each step.
- Pass a `loop_count` pointer instead of `NULL` if you need to know when the effect has finished: it becomes 1.
- To bring background music back after an effect, call `music_play` on the song again. It starts from the beginning.

## .MUS file format

The file is a sequence of 16-byte records, ending with an all-zero record:

| Offset | Size | Field                                                       |
|--------|------|-------------------------------------------------------------|
| 0      | 2    | Timer 1 divisor, big-endian (`round(1843200 / freq)`); 0 = rest |
| 2      | 2    | Timer 2 duration in 32.768 kHz ticks, big-endian; never 0   |
| 4      | 12   | comment, ASCII, null-padded (at most 11 characters)         |

For playback from your own code, see `os/lib/music_player.h`.
