# TERMINAL.md -- BIOS Terminal I/O Guide

A working reference for the BIOS terminal **output** and **input** subsystem,
for anyone about to write an Odyssey program (`.ody`, asm or C) that talks to
the screen or reads a line of input.

Scope: what the subsystem does today, and how to call it correctly. Edge-case
semantics and internal state-machine details live in the header comments of the
individual library files, which are named inline throughout -- read those when
you need the fine print.

Library files, all under `os/bios/lib/`:

| Area | Source | C header |
|---|---|---|
| Character/string output, `$term_flags` | `terminal_output.asm` | `terminal_output.h` |
| ANSI/CSI escape parser, SGR color | `terminal_ansi.asm` | (none) |
| Cursor position + visibility | `cursor.asm` | `cursor.h` |
| Full-screen clear | `clearscreen.asm` | `clearscreen.h` |
| `printf`/`sprintf` formatting | `sprintf.asm` | `sprintf.h` |
| Line editor | `terminal_input.asm` | `terminal_input.h` |
| Raw keyboard input | `keyboard.asm` | `keyboard.h` |
| Raw serial input | `uart.asm` | `uart.h` |

---

## Display model

- **64 columns x 60 rows** of 8x8 CP437 glyphs on a 640x480 VGA frame.
- Two parallel framebuffers in dual-port SRAM, both plain-speed main memory:
  - **character plane** -- `%display_chars%` (0x4000), one byte per cell,
    row-major. Cell (row, col) is at offset `row*64 + col` (0x4000..0x4EFF).
  - **color plane** -- `%display_color%` (0x5000), one byte per cell, same
    layout (0x5000..0x5EFF).
- **Color byte format** (`[BLINK 0x80][CURSOR 0x40][R 2b][G 2b][B 2b]`):

  | bit 7 | bit 6 | bits 5-4 | bits 3-2 | bits 1-0 |
  |---|---|---|---|---|
  | BLINK | CURSOR | red level (0-3) | green level (0-3) | blue level (0-3) |

  64 selectable colors (6-bit RGB, four levels per channel). **No hardware
  background color. No reverse video.** The CURSOR bit paints the cursor block
  in that cell -- leave it to the cursor functions; do not set it in text.
  BLINK makes the cell blink; OR `0x80` into any color byte.

- Handy color bytes (the ANSI bright set): `0x3f` white, `0x00` black,
  `0x30` red, `0x0c` green, `0x03` blue, `0x3c` yellow, `0x0f` cyan,
  `0x33` magenta, `0x15` grey. Named `%white%`/`%red%`/... macros are in
  `assembler/asm_macros`.

---

## Output functions

`terminal_output.asm` / `terminal_output.h`.

| Function | Inputs | Notes |
|---|---|---|
| `:putchar` | `AL` = char | Writes at the cursor and advances. Honors `$term_flags` (control chars, ANSI, edge behavior). Writes the color plane too when `$term_render_color` is set. All registers preserved. |
| `:putchar_raw` | `AL` = char | Character-plane write + advance only. No control-char handling, no ANSI, no color. |
| `:print` | `C` = ptr to null-terminated string | Feeds each byte through `:putchar`. Erases the old cursor block first and re-syncs it at the end position, so text drawn with `:print` keeps the visible cursor correct. Flushes a half-finished escape sequence (string ended after `ESC` or mid-CSI) as literal glyphs. |
| `:print_raw` | `C` = ptr | Maximum-throughput bulk path: character plane only, no control chars / ANSI / color; handles column wrap and bottom-edge scroll; syncs the cursor once at the end. |
| `:printf` | `C` = fmt ptr; args on the heap | `:sprintf` into a private 128-byte buffer (127 chars max), then `:print`. Output therefore goes through the control-char / ANSI path. |
| `:sprintf` | `D` = dest buf, `C` = fmt ptr; args on the heap | Formats into `D`; `C` and `D` unchanged on return. |
| `:clear_screen` | `AH` = fill char (usually `0x00`), `AL` = fill color (usually `0x3f`) | Fills both planes. Does not move the cursor. |
| `:term_scroll` | -- | Scrolls the whole display up one row, blanks the new bottom row. Does not touch the cursor. `:putchar` calls this for you at the bottom edge; direct calls are rare. |

### printf / sprintf format specifiers

From `sprintf.asm`:

| Spec | Meaning | Heap arg |
|---|---|---|
| `%%` | literal `%` | -- |
| `%c` | raw byte, inserted as-is | byte |
| `%2` | byte as 8 binary digits | byte |
| `%b` | BCD byte, low nibble only, one decimal digit | byte |
| `%B` | BCD byte, two decimal digits | byte |
| `%x` | byte as two hex digits | byte |
| `%X` | word as four hex digits | word |
| `%u` | byte as unsigned decimal (0-255) | byte |
| `%U` | word as unsigned decimal (0-65535) | word |
| `%d` | byte as signed decimal (-128..127) | byte |
| `%D` | word as signed decimal (-32768..32767) | word |
| `%s` | word pointer to a null-terminated string, copied in | word |

**Push args in reverse order** -- the value for the *last* specifier is pushed
first. Byte specifiers consume one heap byte, word specifiers (`%X %U %D %s`)
consume a heap word:

```asm
CALL :heap_push_BL             # value for the 3rd specifier (%x)
CALL :heap_push_AL             # 2nd specifier (%x)
CALL :heap_push_AH             # 1st specifier (%x)
LDI_C .fmt
CALL :printf
.fmt "0x%x%x: 0x%x\n\0"
```

### Newline, auto-wrap, scroll

- The cursor advances one cell per printed glyph.
- **Right edge** (advancing past column 63): by default, wrap to column 0 of
  the next row.
- **Bottom edge** (advancing past row 59): by default, `:term_scroll` the whole
  screen up one line; the cursor stays on row 59.
- `$term_flags` bits 2-5 change both edge behaviors (see below).

### Control-character handling

`:putchar` acts on these (not `:putchar_raw` / `:print_raw`, and not when raw
mode -- `$term_flags` bit 0 -- is set, where they print as glyphs):

| Byte | Key | Effect |
|---|---|---|
| `0x08` | Backspace | Cursor left one. If not already at column 0, delete the char before the cursor and shift the rest of the line left. No line-join at column 0. |
| `0x0a` | LF | Move to column 0 of the next row (wrap/scroll per flags) -- i.e. behaves as CR+LF. |
| `0x0d` | CR | Move to column 0 of the current row. |
| `0x7f` | Delete | Delete the char under the cursor, shifting the line tail left. Cursor unmoved. |

Every other byte, including `0x09` (tab) and `0x00`, and all of `0x80-0xff`,
prints as its CP437 glyph.

### Output-state globals

`terminal_output.asm`. From C, declare them yourself:
`extern uint8_t term_flags, term_render_color, term_current_color;`

**`$term_flags`** -- one control byte, `0x00` is the default fast path.

| Bit | Mask | Name | Effect when set |
|---|---|---|---|
| 0 | `0x01` | raw | BS/DEL/CR/LF print as glyphs instead of being handled |
| 1 | `0x02` | ansi | `ESC` starts an escape sequence fed to the CSI parser |
| 2 | `0x04` | nowrap | at the right edge, stay at column 63 instead of wrapping |
| 3 | `0x08` | nonl | at the right edge, do not advance to the next row |
| 4 | `0x10` | noscroll | at the bottom row, overwrite in place instead of scrolling |
| 5 | `0x20` | wraptop | with `noscroll`, wrap back to row 0 instead of clamping at row 59 |

**`$term_render_color`** -- when nonzero, `:putchar`/`:print`/`:printf` write
`$term_current_color` into the color plane for every character. When zero, only
the character plane is touched and existing colors are left alone.

**`$term_current_color`** -- the color byte written while rendering is on.

Turn ANSI mode on / off:

```asm
ST $term_flags 0x02            # ANSI on, all other bits default
ST $term_flags 0x00            # back to the fast path
```
```c
term_flags |= 0x02;            /* or &= ~0x02 to turn off */
```

Set a color with no escape sequences at all:

```asm
ST $term_current_color 0x30    # bright red
ST $term_render_color 0x01     # start writing the color plane
```

Every later `:print` / `:putchar` then paints red until you change or zero
these bytes.

---

## Color control -- three ways

### 1. ANSI SGR (only when `$term_flags` bit 1 is set)

Interpreted only while ANSI mode is on; otherwise `ESC` prints as a glyph.
Parser and the 16-color lookup table (`.sgr_color_table`) are in
`terminal_ansi.asm`.

| Sequence | Effect |
|---|---|
| `ESC[30m` .. `ESC[37m` | the 8 standard (dim) foreground colors |
| `ESC[90m` .. `ESC[97m` | the 8 bright foreground colors |
| `ESC[0m` / `ESC[39m` | reset to white, blink off |
| `ESC[1m` | bold: push every channel that is at level 2 up to level 3 |
| `ESC[22m` | normal: pull every channel at level 3 back to level 2 |
| `ESC[5m` | blink on (color bit `0x80`) |
| `ESC[25m` | blink off |

Multiple codes in one sequence work; a deferred bold/normal is applied last, so
`ESC[1;31m` and `ESC[31;1m` both give light red. A 16-color code or `ESC[0m`
also switches `$term_render_color` on; blink and bold/normal alone do not.

**No background color, no reverse, no underline/italic** -- those codes are
accepted and silently ignored. `38;5;n` and `38;2;r;g;b` (and the `48;`
background forms) are parsed as valid grammar, then the whole sequence is
discarded with no effect.

### 2. `ESC[<v>p` -- Odyssey-native (non-standard)

`v` is a decimal number 0-255 written **straight into `$term_current_color`**,
and color rendering is enabled. Reaches all 64 colors plus the BLINK (`0x80`)
and CURSOR (`0x40`) bits with no masking -- the inline equivalent of a direct
color-plane write.

- `ESC[p` and `ESC[0p` set color `0x00` (black). This is **not** a reset
  (contrast `ESC[0m`).
- `v > 255` makes the sequence flush as literal text, like any oversized
  parameter.
- Setting the CURSOR bit this way leaves a stray cursor block that ordinary
  cursor moves will not clean up -- avoid unless deliberate.

`ESC` (0x1b) cannot be written with a string escape; put it on a data line as a
byte and split the string:

```asm
.redline 0x1b "[48p RED " 0x1b "[0m done\0"   # 48 -> color 0x30 (bright red)
```

### 3. Direct

Set `$term_current_color` + `$term_render_color` as shown above, or write
`%display_color%` cells yourself at `row*64 + col`. No ANSI mode required. This
is the right path for full-screen UIs and games that bypass `:putchar`/`:print`
entirely. See `terminal_output.asm` for the `$term_flags` / `$term_render_color`
contract.

---

## Cursor control

`cursor.asm` / `cursor.h`. State globals (all `byte` unless noted):
`$crsr_row` (0-59), `$crsr_col` (0-63), `$crsr_on` (visibility 0/1),
`$crsr_addr_chars` / `$crsr_addr_color` (word -- cached framebuffer pointers),
`$crsr_saved_row` / `$crsr_saved_col`.

Movement functions update **position state only** -- they do not repaint the
cursor block. `:cursor_on` / `:cursor_off` / `:cursor_display_sync` are what
paint or erase it; `:print` / `:printf` erase-then-resync around their output.
If you move the cursor with the functions below and want the block to follow,
call `:cursor_display_sync` afterward.

| Function | Inputs | Effect |
|---|---|---|
| `:cursor_init` | -- | reset to (0,0), cursor on, pointers to top-left. Does not paint. |
| `:cursor_off` | -- | clear the on flag and erase the block now |
| `:cursor_on` | -- | set the on flag and paint the block now |
| `:cursor_display_sync` | -- | repaint/erase the block at the current position per `$crsr_on` |
| `:cursor_goto_rowcol` | `AH` = row, `AL` = col | move to (row, col), position state only |
| `:cursor_goto_addr` | `A` = offset 0-3839 (top nibble ignored) | move to that linear cell |
| `:cursor_left` / `_right` / `_up` / `_down` | -- | single step, clamped to the screen, position state only |
| `:cursor_save` | -- | copy row/col into the saved slots (backs ANSI `ESC[s`) |
| `:cursor_restore` | -- | move back to the saved row/col (backs ANSI `ESC[u`); (0,0) if never saved |
| `:cursor_conv_rowcol` | `AH` = row, `AL` = col | returns `A` = 12-bit framebuffer offset |
| `:cursor_conv_addr` | `A` = offset | returns `AH` = row, `AL` = col |

C surface (`cursor.h`): `cursor_init`, `cursor_off`, `cursor_on`,
`cursor_save`, `cursor_restore`. No `goto` / `conv` wrapper -- call
`:cursor_goto_rowcol` from a hand-written `.asm` helper if C needs positioning.

### ANSI cursor and erase sequences (ANSI mode on)

| Sequence | Effect |
|---|---|
| `ESC[<n>A` / `B` / `C` / `D` | move up / down / right / left `n` cells (default 1), clamped to the screen |
| `ESC[<r>;<c>H` or `ESC[<r>;<c>f` | move to row `r`, col `c` (1-based; a missing parameter is 1) |
| `ESC[s` / `ESC[u` | save / restore cursor position |
| `ESC[?25h` / `ESC[?25l` | cursor visible / hidden |
| `ESC[2J` | clear the whole screen (fill char `0x00`, fill color = current color if rendering is on, else white) |

`ESC[K` (erase line) and the partial-screen erase modes `ESC[0J` / `ESC[1J`
are accepted as valid grammar but do nothing.

---

## Screen clear

`:clear_screen` -- `AH` = fill character (usually `0x00`), `AL` = fill color
(usually `0x3f` = white). Fills both framebuffers; does not move the cursor.
`clearscreen.asm` / `clearscreen.h`. C: `clear_screen(char ch, uint8_t color)`.

---

## Input

### `:readline` -- line editor

`terminal_input.asm` / `terminal_input.h`.

**Inputs**

| Reg | Meaning |
|---|---|
| `C` | pointer to the caller's buffer |
| `AL` | buffer size in bytes, **including** the null terminator |
| `AH` | flags: bit 0 (`0x01`) echo typed characters; bit 1 (`0x02`) accept keyboard input; bit 2 (`0x04`) accept UART/serial input |

OR bits 1 and 2 to accept either source. Passing neither bit 1 nor bit 2 spins
in the poll loop forever (a caller bug, not a detected error).

**Outputs**

| Reg | Meaning |
|---|---|
| `AL` | number of characters entered (0 on an empty line or Ctrl+C) |
| `AH` | status: 0 = Enter, 1 = Ctrl+C abort |

The buffer at `C` is always left null-terminated. All registers other than
`A` are preserved.

**C:** `readline(char *buf, uint8_t maxlen, uint8_t flags)` returns a
`uint16_t` packed as `(status << 8) | length`; mask and shift it apart. Flag
macros `RL_ECHO` (0x01), `RL_KEYBOARD` (0x02), `RL_UART` (0x04).

Notes:

- A UART byte carries no key-modifier info, so Ctrl+C is only recognized from
  the physical keyboard; a raw `0x03` over serial is an ordinary ignored
  control byte.
- Not reentrant -- one `:readline` at a time (it shares state with the rest of
  the terminal library).
- If input scrolls the screen, cursor repositioning past that point is
  unreliable (known limitation -- see the file header).

**Line-editing keys** (keyboard):

| Key | Action |
|---|---|
| Left / Right | move within the line |
| Home / End | jump to start / end |
| Backspace | delete the char before the cursor |
| Delete | delete the char under the cursor |
| Up / Down | history recall (only when enabled -- see below) |
| Enter | finish, status 0 |
| Ctrl+C | abort, status 1, returned string empty |

Printable `0x20-0x7e` are inserted at the cursor (always insert mode -- there
is no overwrite mode). Other control codes are ignored.

**Command history (opt-in).** Up/Down recall previous lines only when
`$rl_history_buf` is nonzero. The caller owns that buffer and its bookkeeping
globals (`$rl_history_capacity`, `$rl_history_entry_sz`, ...); `:readline`
never allocates or frees it. Left at 0 (the default), Up/Down do nothing. In
practice only the SYSTEM.ODY shell sets this up. Details in the
`terminal_input.asm` header.

### Lower-level character input

`:readline` polls these; call them directly for a custom input loop. Neither
read blocks -- spin on the `*_bufsize` call, or do other work between polls.

**Keyboard** (`keyboard.asm` / `keyboard.h`):

| Function | Result |
|---|---|
| `:kb_bufsize` | `AL` = keystrokes waiting (0 = empty) |
| `:kb_readbuf` | `AH` = key flags, `AL` = character; both `0x00` if the buffer was empty |

Key flags: `0x01` BREAK (key-release), `0x02` CTRL, `0x04` ALT, `0x08`
FUNCTION, `0x10` SHIFT, `0x20` NUMLOCK, `0x40` CAPSLOCK, `0x80` SCROLLLOCK.
In C, `kb_readbuf()` returns a `uint16_t` (flags in the high byte, char low).

**UART / serial** (`uart.asm` / `uart.h`):

| Function | Result / effect |
|---|---|
| `:uart_bufsize` | `AL` = bytes waiting in the receive buffer (0-255) |
| `:uart_readbuf` | `AL` = one received byte (`0x00` if empty -- check bufsize first) |
| `:uart_sendchar` | `AL` = byte to transmit; blocks until sent |

Select a line rate with one of the `:uart_init_<rate>_8n1` calls
(1200 .. 115200) before use.

---

## C-callable surface

| Header | Functions |
|---|---|
| `terminal_output.h` | `printf`, `print`, `print_raw`, `putchar`, `putchar_raw` |
| `cursor.h` | `cursor_init`, `cursor_off`, `cursor_on`, `cursor_save`, `cursor_restore` |
| `clearscreen.h` | `clear_screen(char, uint8_t color)` |
| `terminal_input.h` | `readline(char*, uint8_t, uint8_t)` + `RL_ECHO`/`RL_KEYBOARD`/`RL_UART` |
| `keyboard.h` | `kb_readbuf()`, `KB_KEYFLAG_BREAK` |
| `uart.h` | `uart_readbuf()`, `uart_bufsize()`, `uart_sendchar()` |

The output-state bytes have no header -- declare
`extern uint8_t term_flags, term_render_color, term_current_color;` to reach
them. The `ody-c` skill's header table is the master index and carries the
include-order rules.

---

## Worked recipe -- a bordered, colored panel (asm)

```asm
# vim: syntax=asm-mycpu
# panel - draw a cyan title panel on a cleared screen

:main
CALL :heap_pop_word            # discard argc
CALL :heap_pop_word            # discard argv

LDI_AH 0x00                    # clear screen: fill char 0x00 ...
LDI_AL 0x00                    # ... fill color 0x00 (black)
CALL :clear_screen

ST $term_render_color 0x01     # write the color plane alongside each char
ST $term_current_color 0x0f    # 0x0f = bright cyan

LDI_AH 0x08                    # row 8
LDI_AL 0x14                    # col 20
CALL :cursor_goto_rowcol
LDI_C .top_row
CALL :print

LDI_AH 0x09
LDI_AL 0x14
CALL :cursor_goto_rowcol
LDI_C .mid_row
CALL :print

LDI_AH 0x0a
LDI_AL 0x14
CALL :cursor_goto_rowcol
LDI_C .bot_row
CALL :print

CALL :cursor_off              # hide the block left sitting mid-screen

LDI_A 0x0000                  # 16-bit exit code -- required by the ABI
CALL :heap_push_A
RET

.top_row "+------------------+\0"
.mid_row "|  ODYSSEY ONLINE  |\0"
.bot_row "+------------------+\0"
```

Each `:print` re-syncs the cursor block at its end position, so the single
`:cursor_off` at the end is enough to leave a clean screen. Validate with
`assembler/asmcheck.sh panel.asm`.
