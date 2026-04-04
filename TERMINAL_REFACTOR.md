# Terminal I/O Refactor -- Architecture Document

This document describes the current state of the Odyssey's terminal I/O subsystem,
its problems, and the proposed next-generation architecture. It serves as the
specification for implementation.

---

## Part 1: Current State Analysis

### 1.1 Terminal Output -- Current Architecture

**Files**: `os/bios/lib/terminal_output.asm`, `os/bios/lib/cursor.asm`,
`os/bios/lib/sprintf.asm`, `os/bios/lib/clearscreen.asm`

**Function inventory**:

| Function | File:Line | Purpose |
|---|---|---|
| `:putchar` | terminal_output.asm:29 | Single char output with control char handling (BS, DEL, CR, LF) |
| `:putchar_direct` | terminal_output.asm:114 | Single char output, no control char handling |
| `:print` | terminal_output.asm:296 | String output with `@`-color codes and optional raw mode |
| `:printf` | terminal_output.asm:522 | Formatted output via sprintf into 128-byte temp buffer, then print |
| `:term_scroll` | terminal_output.asm:540 | Scroll display up one line (chars + colors + marks) |
| `.term_strcpy` | terminal_output.asm:135 | Copy chars+colors in framebuffer (used by BS/DEL) |
| `.cursor_right_scroll` | terminal_output.asm:187 | Move cursor right, scroll if at edge |
| `.cursor_down_scroll` | terminal_output.asm:213 | Move cursor down, scroll if at bottom |
| `:sprintf` | sprintf.asm:22 | Format string into buffer (8 format specifiers) |
| `:clear_screen` | clearscreen.asm:11 | Fill char+color framebuffers |

**Control variables** (4 separate bytes):

- `$term_color_enabled` -- enables `@`-code parsing in `:print`
- `$term_render_color` -- enables writing color bytes after each char
- `$term_current_color` -- the color byte to write
- `$term_print_raw` -- when set, `:print` uses `:putchar_direct` instead of `:putchar`

**Data flow**: `printf` -> `sprintf` into `$printf_buf` (128 bytes) -> `:print` ->
`:putchar` per character -> framebuffer write + cursor advance.

**Color system**: Custom `@`-code syntax (`@37` = bright white, `@x1f` = hex color,
`@r` = reset). NOT ANSI. Color byte is 6-bit RGB (2 bits per channel) + cursor bit
(0x40) + blink bit (0x80).

#### Current output problems

1. **Bug in no-color raw path** (terminal_output.asm:499-502): When `$term_print_raw`
   is non-zero, `putchar_direct` is called but then falls through to ALSO call
   `putchar`, printing each character twice. The color path (line 469) correctly has
   `JMP .print_it_putchar_done` but the no-color path is missing it.

2. **Four separate control variables** instead of a unified flags byte. Each one
   requires a separate `LD` + `ALUOP_FLAGS` check. The common case (color off, raw
   off) still pays the cost of checking `$term_print_raw` every character.

3. **No configurable wrap/scroll behavior**. Right-edge wrapping always triggers
   scroll-if-needed. Bottom-edge always scrolls. No way to stop at edge or wrap
   without scroll.

4. **No ANSI/VT escape sequence support**. The custom `@`-color system works but is
   non-standard. Programs that want VT100 behavior (e.g. serial terminal, cursor
   positioning from escape codes) must implement their own parser. The console
   utility's VT220 support is incomplete and not reusable.

5. **Heavy register save/restore overhead**. `:putchar` pushes/pops 8 registers (AH,
   AL, BH, BL, CH, CL, DH, DL) on EVERY character. `:putchar_direct` is lighter
   (only DH, DL) but can't handle control chars. There's no middle ground.

6. **`:print` checks `$term_print_raw` per character** even in the no-color fast path
   (lines 495-498). This means even the "fast" path has a load + flags check +
   conditional jump per character that could be avoided.

7. **`:putchar` BS/DEL use `.term_strcpy`** which copies chars one-by-one until it
   hits a null. On a line with many characters to the right of the cursor, this is
   very slow. Also copies color bytes in lockstep, which is unnecessary for simple
   backspace operations in most cases.

8. **Scroll is expensive**: `:term_scroll` copies 3840 bytes of chars + 3840 bytes of
   colors + updates 32 marks. This is unavoidable given the architecture, but it means
   scroll-heavy output (e.g. `cat` of a long file) is visibly slow.

9. **`$printf_buf` is only 128 bytes**. Long formatted strings will silently overflow.

---

### 1.2 Cursor Management -- Current Architecture

**File**: `os/bios/lib/cursor.asm`

**State variables** (6 bytes + 64 bytes marks):

- `$crsr_row`, `$crsr_col` -- current position
- `$crsr_addr_chars`, `$crsr_addr_color` -- cached 16-bit framebuffer addresses
- `$crsr_on` -- visibility flag
- `$crsr_marks` -- 64 bytes for 32 bookmarks (2 bytes each, 12-bit offset + flags)

**Movement functions**: `cursor_left`, `cursor_right`, `cursor_up`, `cursor_down` --
each calls `.cursor_move_real` which validates bounds and calls `cursor_goto_addr`.

**Goto functions**: `cursor_goto_addr` (from offset), `cursor_goto_rowcol` (from
row/col). Both:

1. Clear cursor bit at old position
2. Update `$crsr_addr_chars`, `$crsr_addr_color`, `$crsr_row`, `$crsr_col`
3. Set cursor bit at new position via `cursor_display_sync`

**Conversion functions**: `cursor_conv_rowcol` (row/col -> 12-bit offset),
`cursor_conv_addr` (offset -> row/col). These do bit manipulation to handle the
64-column layout.

#### Current cursor problems

1. **Movement is always bounds-checked against full screen**. There's no concept of a
   "region" or "window" -- cursor movement is always validated against 0x4000-0x4EFF.
   This makes it impossible to constrain cursor movement to a sub-region (e.g. an
   input field, a scrollable pane).

2. **Every goto call does cursor_display_sync** which reads the color byte, modifies
   the cursor bit, and writes it back. This is 5+ instructions per cursor move even
   when the cursor is off.

3. **The marks system is deeply entangled** with cursor management (64 bytes of RAM,
   scroll adjustment, shift operations). Marks serve double duty as input boundaries
   AND as a primitive history mechanism. This conflation makes both use cases worse.

4. **Single-step movement is indirect**: `cursor_right` pushes AL, loads 1, calls
   `.cursor_move_real`. `.cursor_move_real` pushes 6 registers, sign-extends the
   8-bit offset, does 16-bit addition, validates two bounds, calls `cursor_goto_addr`
   (which pushes 6 more registers, clears old cursor, computes new addresses, sets
   new cursor), then pops 6 registers. A single `cursor_right` call involves ~50+
   instructions and ~12 stack operations.

---

### 1.3 Terminal Input -- Current Architecture

**File**: `os/bios/lib/terminal_input.asm`

**The `:input` function** (lines 27-336):

- Installs buffered keyboard IRQ handler
- Saves current cursor position as mark 0 and mark 1
- Polls keyboard buffer in a tight loop
- Handles: BS, DEL, left/right arrows, Home, End, Insert toggle, Ctrl+C, Enter
- Returns with marks 0 and 1 set to input boundaries
- Caller must call `cursor_mark_getstring()` to extract the string from the framebuffer

**The marks-as-input-buffer design**:

- Text is stored directly in the framebuffer at 0x4000-0x4EFF
- Mark 0 = start of input, Mark 1 = end of input
- Editing (insert, delete, backspace) directly manipulates framebuffer bytes
- No separate input buffer exists during editing
- After Enter, the shell allocates a buffer and copies the string out via
  `cursor_mark_getstring()`

**The shell's consumption path** (`os/system/30-read_command.asm`):

1. Call `:input` (returns via marks)
2. Print newline
3. `calloc_segments(1)` -- allocate 128-byte input buffer
4. `calloc_blocks(4)` -- allocate 64-byte argv array
5. Check mark 0 == mark 1 (empty input)
6. `cursor_mark_getstring(mark0, mark1, buffer)` -- copy framebuffer to buffer
7. `strsplit(buffer, ' ', argv)` -- tokenize

#### Current input problems

1. **Framebuffer-as-scratchpad is fundamentally flawed**:
   - Display and data storage are coupled: scrolling the screen corrupts active input
   - Input length is implicitly limited by framebuffer geometry (can't exceed visible
     area)
   - Multi-line input wrapping creates complex framebuffer offset math
   - No null termination during editing
   - Extracting the string requires a separate copy step after input completes

2. **No return value**: `:input` returns nothing. The caller must know about the marks
   system and call `cursor_mark_getstring()`. This leaks implementation details into
   every consumer.

3. **No command history**: The mark shifting mechanism (`cursor_shift_marks`) was
   intended for history but was never implemented (TODO on lines 19-20). The marks
   architecture is poorly suited for history anyway -- it stores screen positions,
   not strings.

4. **No echo control**: Can't suppress character display (needed for password entry).

5. **No maximum length enforcement**: Input continues until Enter or the edge of the
   framebuffer.

6. **No callback/hook mechanism**: Can't customize key handling (e.g. tab completion).

7. **Backspace loop is O(n)**: Deleting a character requires copying all characters
   from the current position to mark 1, one byte at a time (lines 152-161). On a long
   input line this is visible.

8. **IRQ1 vector manipulation**: `:input` saves/restores the IRQ1 vector to install
   the buffered handler. This is fragile -- if the caller already has the buffered
   handler installed, this save/restore is unnecessary overhead.

9. **Keyboard buffer is tiny**: 7 keystrokes max (14 bytes at 0xBE00). Fast typists
   can overflow it.

---

## Part 2: Proposed Architecture

### 2.1 Design Principles

1. **Zero = fast path**: `$term_flags == 0x00` represents the common case (ctrl chars
   on, ANSI off, wrap+newline, scroll). A single `ALUOP_FLAGS` + `JNZ` is all it
   costs to confirm we're on the fast path. Non-default features SET bits.

2. **ANSI replaces @-codes**: Drop the custom `@`-code color system entirely. ANSI
   escape sequences become the sole embedded color mechanism. If DOS systems on an
   8 MHz 8088 could do ANSI.SYS faster than the BIOS, we can make a lean ANSI parser
   that performs well on the Odyssey.

3. **Buffer-based input**: Input editing happens in a RAM buffer. The framebuffer is a
   display target, not a data store.

4. **Clean API boundaries**: Functions return values, not side effects. Callers don't
   need to know about internal mechanisms.

5. **Color sync is mandatory**: Scrolling, text movement, and all framebuffer
   operations MUST update both 0x4xxx (chars) and 0x5xxx (colors) together, regardless
   of whether color rendering is active. Programs that write color bytes directly must
   see predictable behavior when the terminal scrolls or moves text.

### 2.2 Terminal Output -- Proposed Design

#### 2.2.1 Unified terminal flags byte

Replace the four separate control variables with a single `$term_flags` byte, designed
so that **0x00 is the common/fast case**:

```
$term_flags byte layout:

  bit 0: Raw mode (1=disable ctrl char handling, 0=ctrl chars ON) [default 0]
  bit 1: ANSI mode (1=enable ANSI escape parser, 0=ANSI OFF) [default 0]
  bit 2: Right-edge: no-wrap (1=stay at col 63, 0=wrap to col 0) [default 0]
  bit 3: Right-edge: no-newline (1=stay on current row, 0=drop to next row) [default 0]
  bit 4: Bottom-edge: no-scroll (1=don't scroll, 0=scroll up) [default 0]
  bit 5: Bottom-edge: wrap-to-top (1=wrap cursor to row 0, 0=don't wrap) [default 0]
  bit 6: (reserved)
  bit 7: (reserved)
```

**Default value**: `0x00` = ctrl chars on, ANSI off, right-edge wrap+newline,
bottom-edge scroll.

The right-edge and bottom-edge behaviors use independent property bits rather than
encoded multi-bit fields. This allows any combination and avoids awkward two-bit
decoding. The combination of properties defines behavior:

**Right-edge combinations** (bits 2-3):

| no-wrap | no-newline | Behavior |
|---------|------------|----------|
| 0 | 0 | Wrap to col 0 + drop to next row (DEFAULT -- normal terminal) |
| 0 | 1 | Wrap to col 0 of same row (typewriter carriage return) |
| 1 | 0 | Stay at col 63, drop to next row (column-locked) |
| 1 | 1 | Stay at col 63, same row (stop -- chars overwrite in place) |

**Bottom-edge combinations** (bits 4-5):

| no-scroll | wrap-to-top | Behavior |
|-----------|-------------|----------|
| 0 | 0 | Scroll screen up, new line at bottom (DEFAULT -- normal terminal) |
| 0 | 1 | (unusual: scroll then wrap -- treat as scroll only) |
| 1 | 0 | Stop at bottom row (chars overwrite in place) |
| 1 | 1 | Wrap cursor to row 0, col 0 (screen-wrap, no scroll) |

**Fast path optimization**: In `:putchar`, the first thing after writing the character
is:

```asm
LD_AL $term_flags
ALUOP_FLAGS %A%+%AL%
JNZ .putchar_check_flags      # any non-default behavior? handle it
# ... fast path: default wrap+newline+scroll behavior inline ...
```

When `$term_flags == 0x00`, this is 3 instructions to confirm we're on the fast path.
All the ctrl-char checking, ANSI parsing, and non-default wrap behavior is behind the
`JNZ` branch.

#### 2.2.2 Restructured output functions

**`:putchar`** -- the workhorse, optimized for the common case:

```
Input: AL = character
Fast path ($term_flags == 0x00):
  1. Check for ctrl chars (0x08, 0x7f, 0x0d, 0x0a) -- 4 comparisons
  2. Write AL to framebuffer at cursor position
  3. If $term_render_color: write $term_current_color to color framebuffer
  4. Advance cursor with default wrap+newline+scroll behavior

Slow path ($term_flags != 0x00):
  1. If bit 0 clear (ctrl chars on): check for ctrl chars
     If bit 0 set (raw): skip ctrl char checks
  2. If bit 1 set (ANSI on):
     - If $ansi_state != 0: feed AL to ANSI state machine, return
     - If AL == 0x1b (ESC): set $ansi_state = 1, return
  3. Write AL to framebuffer
  4. If $term_render_color: write $term_current_color to color framebuffer
  5. Advance cursor using flag-driven wrap/scroll logic
```

**`:putchar_raw`** -- absolute minimum overhead, no flags, no checks:

```
Input: AL = character
Behavior: Write AL to framebuffer at cursor position, advance cursor
one position right. No ctrl chars, no ANSI, no color, no flag checks.
Replaces :putchar_direct.
```

**`:print`** -- string output, dramatically simplified:

```
Input: C = null-terminated string address
Behavior: Loop calling :putchar for each character. That's it.
No @-code parsing. Color handling happens inside putchar via ANSI
sequences when ANSI mode is enabled ($term_flags bit 1).
```

The current `:print` is ~215 lines of assembly with complex `@`-code parsing. The new
`:print` is essentially:

```asm
:print
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL
.print_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .print_done
CALL :putchar
INCR_C
JMP .print_loop
.print_done
CALL :cursor_display_sync    # show cursor at final position
POP_CL
POP_CH
POP_AL
RET
```

**`:print_raw`** -- raw string output with no per-character flag checks:

```
Input: C = null-terminated string address
Behavior: Loop calling :putchar_raw for each character. No ctrl chars,
no ANSI, no color. Maximum throughput for bulk character output (e.g.
raw file display, framebuffer painting).
```

**`:printf`** -- unchanged interface. Still uses sprintf into `$printf_buf` (128
bytes), then calls `:print`. The 128-byte limit is documented but not changed.

**`:term_scroll`** -- simplified. Still copies 3840 bytes chars + 3840 bytes colors
(always both regions in lockstep), but no longer calls `cursor_scroll_marks` (marks
are removed).

#### 2.2.3 ANSI escape sequence state machine

##### State variables

```
$ansi_state       byte     -- parser state:
                              0 = normal (not in escape sequence)
                              1 = ESC received, waiting for '['
                              2 = CSI received ('['), accumulating params
$ansi_param_buf   8 bytes  -- numeric parameter values (up to 4 params x 2 bytes)
$ansi_param_count byte     -- number of parameters parsed so far
$ansi_accum       word     -- current parameter being accumulated (before ';' or letter)
$ansi_private     byte     -- private mode indicator (for ESC [ ? sequences)
$ansi_seq_buf     16 bytes -- raw characters buffered since ESC (for error recovery)
$ansi_seq_len     byte     -- number of characters in $ansi_seq_buf
$crsr_saved_row   byte     -- saved cursor row (for ESC[s / ESC[u)
$crsr_saved_col   byte     -- saved cursor col
```

##### Supported CSI sequences

```
ESC [ <n> A           Cursor up n rows (default n=1)
ESC [ <n> B           Cursor down n rows (default n=1)
ESC [ <n> C           Cursor right n columns (default n=1)
ESC [ <n> D           Cursor left n columns (default n=1)
ESC [ <row> ; <col> H Cursor absolute position (1-based; default 1;1)
ESC [ <row> ; <col> f Same as H
ESC [ 0 J             Clear from cursor to end of screen
ESC [ 1 J             Clear from start of screen to cursor
ESC [ 2 J             Clear entire screen
ESC [ 0 K             Clear from cursor to end of line
ESC [ 1 K             Clear from start of line to cursor
ESC [ 2 K             Clear entire line
ESC [ <n> m           SGR: set graphics rendition (see color mapping below)
ESC [ s               Save cursor position
ESC [ u               Restore cursor position
ESC [ ? 25 h          Show cursor
ESC [ ? 25 l          Hide cursor
```

##### ANSI-to-Odyssey color mapping (SGR)

The Odyssey video hardware supports **foreground color only**. There is no separate
background color, and there is no "reverse video" mode. The color byte controls the
foreground color of each character cell.

**Foreground colors** (SGR 30-37, 90-97) set `$term_current_color` bits 0-5:

```
SGR     Name           Odyssey byte
30      Black          0x00
31      Red            0x20            (shade 2 red)
32      Green          0x08            (shade 2 green)
33      Yellow         0x28            (shade 2 red + green)
34      Blue           0x02            (shade 2 blue)
35      Magenta        0x22            (shade 2 red + blue)
36      Cyan           0x0a            (shade 2 green + blue)
37      White          0x2a            (shade 2 all channels)

90      Dark Gray      0x15            (shade 1 all channels)
91      Light Red      0x30            (shade 3 red)
92      Light Green    0x0c            (shade 3 green)
93      Light Yellow   0x3c            (shade 3 red + green)
94      Light Blue     0x03            (shade 3 blue)
95      Light Magenta  0x33            (shade 3 red + blue)
96      Light Cyan     0x0f            (shade 3 green + blue)
97      Light White    0x3f            (shade 3 all channels)
```

**Supported SGR attributes**:

```
0       Reset          Set color to 0x3f (white), clear blink, enable render
1       Bold           Upgrade current color from shade-2 to shade-3
5       Blink          Set blink bit (0x80) in $term_current_color
22      Normal         Remove bold (downgrade shade-3 to shade-2)
25      Blink off      Clear blink bit (0x80)
```

**Ignored SGR codes** (silently discarded, no output):

```
2       Dim            (no effect -- hardware has no dim mode)
3       Italic         (no effect -- hardware has no italic)
4       Underline      (no effect -- hardware has no underline)
7       Reverse        (no effect -- hardware cannot swap fg/bg)
8       Hidden         (no effect)
9       Strikethrough  (no effect)
21-29   Various resets (ignored except 22, 25 as listed above)
38      Extended fg    (256-color/truecolor -- not supported)
39      Default fg     (treated as reset to white)
40-47   Background     (ignored -- hardware has no background color)
48      Extended bg    (ignored)
49      Default bg     (ignored)
100-107 Bright bg      (ignored)
```

Multiple SGR parameters in a single sequence (e.g. `ESC[1;31m` for bold red) are
supported -- each parameter is processed in order.

##### ANSI parser error handling

The parser must handle three cases cleanly:

**1. Valid and supported sequences**: Execute the action, discard the buffered
sequence characters. Nothing is printed to the screen from the escape sequence itself.

**2. Valid but unsupported sequences** (e.g. `ESC[6n` device status report, `ESC[4h`
insert mode, or any recognized CSI sequence with a valid final byte but unsupported
semantics): Silently discard the entire sequence. Nothing is printed to the screen.
The parser resets to state 0 (normal).

A "valid" CSI sequence is defined as: `ESC [ <optional '?'> <zero or more digits and
semicolons> <final byte in 0x40-0x7E range>`. Any sequence matching this grammar is
valid, even if the specific command is not implemented.

**3. Invalid sequences** (malformed escape sequences that don't match valid CSI
grammar): Flush the raw buffered characters to the screen via `:putchar_raw` and reset
the parser to state 0. This ensures the user sees what was actually sent, rather than
having characters silently swallowed.

Invalid conditions include:
- `ESC` followed by a character other than `[` (not a CSI sequence)
- `ESC [` followed by a character that is not a digit, semicolon, `?`, or valid final
  byte (0x40-0x7E)
- Parameter buffer overflow (more than 4 parameters or parameter value > 255)
- Sequence buffer overflow (`$ansi_seq_buf` full before final byte received)

**4. String ends mid-sequence**: If a null terminator is encountered while the ANSI
parser is in a non-zero state (mid-escape-sequence), the parser must flush its
buffered characters to the screen and reset to state 0. The `:print` function's loop
termination on null must check `$ansi_state` and trigger this flush if needed. This
prevents a truncated escape sequence from leaving the parser in a stuck state.

To support error recovery, the parser maintains `$ansi_seq_buf` (16 bytes) which
records the raw characters received since the initial ESC. On any error condition,
these buffered characters are printed to the screen using `:putchar_raw` (bypassing
the ANSI parser to avoid re-triggering), then the parser resets.

#### 2.2.4 Color rendering control

Two state variables remain (not part of `$term_flags`):

```
$term_render_color   byte  -- 0=don't write colors with each char, nonzero=write
$term_current_color  byte  -- color byte to write when render_color is active
```

These are NOT feature flags -- they're runtime state. `$term_render_color` controls
whether putchar writes a color byte alongside each character. Programs can set
`$term_current_color` directly without enabling ANSI mode:

```asm
ST $term_render_color 0x01
ST $term_current_color %green%
CALL :print                         # all chars will be green
ST $term_render_color 0x00          # stop overriding colors
```

When ANSI mode is on, SGR escape sequences set these variables automatically. When
ANSI mode is off, programs set them directly if needed.

**Invariant**: All framebuffer operations (scroll, clear, text movement via BS/DEL)
ALWAYS update both the char region (0x4xxx) and color region (0x5xxx) in lockstep.
This is true regardless of `$term_render_color`. The render_color flag only controls
whether NEW characters get a color byte written -- it does NOT affect preservation of
existing color data during scroll, clear, or text-shift operations. If a program writes
color bytes directly to the 0x5xxx region, those colors will scroll and move correctly
along with their associated characters.

### 2.3 Cursor Management -- Proposed Changes

#### 2.3.1 Optimized cursor advance for putchar

New internal function `.cursor_advance` replaces the heavy
`cursor_right` -> `.cursor_move_real` -> `cursor_goto_addr` chain for the most common
case (putchar advancing one position):

```
.cursor_advance
  Increment $crsr_addr_chars and $crsr_addr_color (16-bit increment)
  Increment $crsr_col
  If $crsr_col < 64: done (fast exit)
  If $crsr_col == 64: handle right-edge via $term_flags bits 2-3
    Default (both 0): set col=0, increment row, check bottom-edge
      Bottom-edge default (both 0): if row==60, scroll and set row=59
```

No bounds checking against the full screen on every character -- the column check
(< 64) is sufficient for the fast path. No `cursor_display_sync` -- deferred to
caller.

This reduces the per-character cursor advance from ~50+ instructions to ~10-15
instructions on the fast path (no wrap needed).

#### 2.3.2 Cursor display sync optimization

Split cursor movement from cursor display:

- `cursor_left/right/up/down` and `cursor_goto_*` update position state only (no
  `cursor_display_sync` call)
- `cursor_display_sync` is called explicitly by `:print` (once, at the end), by
  `:readline` (when idle), and by programs that need the cursor visible
- `cursor_on` / `cursor_off` still call `cursor_display_sync` immediately (they're
  explicit visibility requests)

#### 2.3.3 Remove marks entirely

Remove from cursor.asm:

- `$crsr_marks` (64 bytes RAM)
- `$input_flags` (1 byte RAM -- insert/overwrite moves to readline)
- `:cursor_save_mark`, `:cursor_save_mark_offset`, `:cursor_save_mark_rowcol`
- `:cursor_get_mark`
- `:cursor_clear_mark`
- `:cursor_mark_left`, `:cursor_mark_right`, `:cursor_mark_up`, `:cursor_mark_down`
- `:cursor_mark_move`
- `:cursor_mark_getstring`
- `:cursor_scroll_marks`
- `:cursor_shift_marks`

This frees ~65 bytes of RAM and ~500+ bytes of ROM. `:term_scroll` loses the
`CALL :cursor_scroll_marks` at the end, making every scroll faster.

Add to cursor.asm (for ANSI ESC[s / ESC[u support):

- `$crsr_saved_row`, `$crsr_saved_col` (2 bytes RAM)
- `:cursor_save` and `:cursor_restore` (simple save/load of row+col, ~20 bytes ROM)

### 2.4 Terminal Input -- Proposed Design

#### 2.4.1 Buffer-based readline

Replace `:input` with `:readline` -- a buffer-based line editor.

```
:readline
# Read a line of input from the user with line editing support.
#
# Inputs:
#   C = pointer to caller-supplied input buffer
#   AL = buffer size (max characters, including null terminator)
#   AH = readline flags byte:
#     bit 0: echo (1=echo chars to screen, 0=silent/password mode)
#     bits 1-7: reserved
#
# Outputs:
#   AL = number of characters entered (0 for empty/Ctrl+C)
#   AH = status (0=normal Enter, 1=Ctrl+C abort)
#   Buffer at C is filled with null-terminated input string
#
# History:
#   If the global variable $rl_history_buf is non-zero, readline enables
#   command history via up/down arrows. The caller is responsible for
#   allocating and managing the history buffer. Readline reads from and
#   writes to it but does not allocate or free it.
#
# Side effects:
#   Cursor is moved to end of input, then to next line
#   If echo is on, input is displayed at the current cursor position
#   If history is enabled and input is non-empty, input is appended
#   to the history buffer
```

**Key design decisions**:

1. **Caller owns the input buffer**: The caller allocates and passes in the buffer. No
   malloc inside readline.

2. **Returns a real value**: AL = length, AH = status, buffer at C is null-terminated.
   No marks, no post-processing.

3. **Echo is a flag**: When echo is on, readline uses `:putchar` for display. When off,
   the buffer is edited silently. The caller can implement custom echo (e.g. printing
   `*` for each character) by setting echo off and handling display externally.

4. **Editing uses the buffer**: Insert, delete, backspace all operate on the RAM
   buffer. Display is updated to match.

5. **Insert/overwrite state** lives inside readline (local to the function), not in a
   global variable.

#### 2.4.2 Display synchronization

**Incremental updates** for common operations:

- Regular character typed: putchar it, advance cursor
- Backspace: cursor left, reprint from cursor position to end of buffer, clear the
  trailing character position
- Delete: reprint from cursor to end of buffer, clear trailing character
- Left/right arrow: move cursor only (buffer unchanged)
- Home/End: move cursor only

**Full-line repaint** for complex operations:

- History recall (up/down arrow): clear current display, reprint full history entry
- Any case where incremental update would be more complex than a full repaint

The starting cursor position is recorded when readline begins, so repaint always knows
where to start.

#### 2.4.3 Command history -- caller-managed

History is entirely managed by the caller. Readline accesses it through global
variables:

```
$rl_history_buf       word  -- pointer to history buffer (0x0000 = no history)
$rl_history_capacity  byte  -- max number of entries the buffer can hold
$rl_history_count     byte  -- current number of entries stored
$rl_history_entry_sz  byte  -- bytes per entry (must match readline buffer size)
$rl_history_write_idx byte  -- next slot to write (circular index)
```

If `$rl_history_buf` is zero, history is disabled. The caller (e.g. SYSTEM.ODY's
shell) allocates the history buffer to whatever size it wants via malloc:

```asm
# Shell startup: allocate history for 16 entries x 128 bytes = 2048 bytes
LDI_AL 16                          # 16 segments = 2048 bytes
CALL :malloc_segments
ST16 $rl_history_buf A             # store pointer
ST $rl_history_capacity 16         # 16 entries
ST $rl_history_entry_sz 128        # 128 bytes per entry
ST $rl_history_count 0
ST $rl_history_write_idx 0
```

Readline behavior:

- On **Enter** with non-empty input: copy buffer to
  `history_buf[write_idx * entry_sz]`, increment write_idx (wrapping at capacity),
  increment count (capped at capacity)
- On **Up arrow**: load previous history entry into buffer, full repaint
- On **Down arrow**: load next history entry (or clear to empty if at newest), full
  repaint
- A temporary `$rl_history_browse_idx` tracks the current browse position during a
  single readline call

#### 2.4.4 Keyboard buffer

Out of scope for this project. The current 7-keystroke buffer remains unchanged.

### 2.5 C Headers and API Surface

#### 2.5.1 terminal.h (new unified header)

```c
/* --- Terminal output flags --- */
/* $term_flags: 0x00 = default (ctrl chars ON, ANSI OFF, wrap+newline, scroll) */
/* Set bits to CHANGE from default behavior. */
#define TERM_RAW          0x01   /* Disable ctrl char handling */
#define TERM_ANSI         0x02   /* Enable ANSI escape sequence parser */
#define TERM_NOWRAP_R     0x04   /* Right edge: don't wrap to col 0 */
#define TERM_NONEWLINE_R  0x08   /* Right edge: don't advance to next row */
#define TERM_NOSCROLL_B   0x10   /* Bottom edge: don't scroll */
#define TERM_WRAPTOP_B    0x20   /* Bottom edge: wrap cursor to top of screen */
#define TERM_DEFAULT      0x00   /* All defaults */

/* Output functions */
extern void term_set_flags(uint8_t flags);
extern uint8_t term_get_flags(void);
extern void putchar(char c);           /* Honors $term_flags */
extern void putchar_raw(char c);       /* Direct framebuffer write, no processing */
extern void print(char *str);          /* String output via putchar loop */
extern void print_raw(char *str);      /* String output via putchar_raw loop */
extern void printf(char *fmt, ...);    /* Formatted output (128-byte buffer) */

/* Cursor functions */
extern void cursor_init(void);
extern void cursor_on(void);
extern void cursor_off(void);
extern void cursor_up(void);
extern void cursor_down(void);
extern void cursor_left(void);
extern void cursor_right(void);
extern void cursor_goto(uint8_t row, uint8_t col);
extern void cursor_save(void);
extern void cursor_restore(void);

/* Screen functions */
extern void clear_screen(char fill_char, uint8_t color);

/* Color state (direct access to globals) */
extern uint8_t term_render_color;      /* 0=off, nonzero=write color with each char */
extern uint8_t term_current_color;     /* color byte to write */

/* --- Readline --- */
#define RL_ECHO    0x01

/* History is enabled by setting $rl_history_buf to a non-zero pointer. */
/* These are global variables managed by the caller: */
extern void *rl_history_buf;           /* 0x0000 = no history */
extern uint8_t rl_history_capacity;
extern uint8_t rl_history_count;
extern uint8_t rl_history_entry_sz;
extern uint8_t rl_history_write_idx;

extern uint8_t readline(char *buf, uint8_t maxlen, uint8_t flags);
/* Returns: length of input in AL, status in AH (0=Enter, 1=Ctrl+C) */
```

#### 2.5.2 ASM calling conventions

All functions follow the existing Odyssey conventions:

- Callee-save: all registers restored except documented return values
- Parameters via registers (preferred) or heap (for variadic)
- 16-bit pointers in C or D register
- 8-bit values in AL or AH

### 2.6 Migration and Compatibility

#### 2.6.1 What stays the same

- `printf` / `sprintf` format specifiers unchanged
- Framebuffer addresses (0x4000/0x5000) unchanged
- Color byte format (6-bit RGB + cursor + blink) unchanged
- `cursor_goto_rowcol` ASM interface unchanged (renamed to `cursor_goto` in C header)
- `putchar` semantics unchanged when `$term_flags == 0x00`
- All framebuffer operations keep chars and colors in sync

#### 2.6.2 What changes

- **`@`-color codes removed** from `:print`. Programs using `@37`, `@r`, etc. must
  migrate to either: (a) ANSI escape sequences with ANSI mode enabled via
  `$term_flags` bit 1, or (b) direct `$term_current_color` / `$term_render_color`
  manipulation.
- `:putchar_direct` renamed to `:putchar_raw`
- New `:print_raw` for maximum-throughput string output
- `:input` replaced by `:readline` (completely different interface and semantics)
- `$term_color_enabled`, `$term_print_raw` replaced by `$term_flags`
- `$crsr_marks` and all mark functions removed from BIOS
- Shell's `read_command` simplified: call readline with a buffer, get back a string
- Programs that set `$term_color_enabled` must now set `$term_flags` bit 1 and use
  ANSI escape codes for embedded colors
- Cursor movement functions no longer call `cursor_display_sync` automatically --
  callers that need the cursor visible must call `cursor_display_sync` explicitly

#### 2.6.3 @-code to ANSI migration reference

Programs currently using `@`-codes in strings need to convert to ANSI sequences.
Below is the mapping. All ANSI sequences require `$term_flags` bit 1 (ANSI mode)
to be set.

```
Old @-code    ANSI equivalent          Notes
----------    ---------------          -----
@@            @ (literal)              No change needed, just print '@'
@r            ESC[0m                   Reset to default color
@07           ESC[34m                  Blue shade 1 (approx, dark blue)
@17           ESC[34m                  Blue shade 1 (approx)
@27           ESC[34m                  Blue shade 2
@37           ESC[94m                  Blue shade 3 (bright blue)
@06           ESC[33m                  Yellow shade 1 (approx)
@26           ESC[33m                  Yellow shade 2
@36           ESC[93m                  Yellow shade 3 (bright yellow)
@01-@37       ESC[<n>m                 Map shade+color to nearest ANSI color
@xff          ESC[0m + direct write    No ANSI equivalent for arbitrary hex;
                                       use $term_current_color directly
@B            ESC[5m                   Blink on
@b            ESC[25m                  Blink off
@C            (no equivalent)          Cursor flag -- use cursor_on()
@c            (no equivalent)          Cursor flag -- use cursor_off()
```

For programs that need precise control over the 6-bit color space (e.g. color
gradients, specific shade levels), setting `$term_current_color` and
`$term_render_color` directly is the recommended approach. ANSI SGR provides a
convenient but approximate mapping.

#### 2.6.4 ROM space considerations

Rough estimates:

- **Removed**: marks system (~500 bytes ROM, ~65 bytes RAM), @-code parser in `:print`
  (~300 bytes ROM), old `:input` (~350 bytes ROM), 4 control variables replaced by 1
  flags byte (~3 bytes RAM), `cursor_scroll_marks` call in term_scroll
  = **~1150 bytes ROM freed, ~68 bytes RAM freed**
- **Added**: ANSI state machine (~500 bytes ROM, ~28 bytes RAM), `:readline` (~450
  bytes ROM), `:print_raw` (~30 bytes ROM), `.cursor_advance` (~60 bytes ROM), history
  globals (~6 bytes RAM), cursor save/restore (~20 bytes ROM),
  `cursor_display_sync` no longer auto-called (saves ROM in goto functions, ~-40
  bytes) = **~1020 bytes ROM added, ~34 bytes RAM added**
- **Net**: ~130 bytes ROM freed, ~34 bytes RAM freed

---

## Part 3: Resolved Design Decisions

1. **ANSI lives in ROM**. The @-code parser removal and marks removal frees enough
   space. The ANSI parser replaces @-codes as the sole color embedding mechanism.

2. **No background colors**. The Odyssey video hardware only supports foreground
   colors. ANSI background color codes (SGR 40-47, 100-107) are silently ignored.
   Reverse video (SGR 7) is also ignored. This is a hardware limitation, not a
   software choice.

3. **History buffer is caller-managed**. The caller (e.g. shell) allocates via malloc
   and sets global variables. Readline checks `$rl_history_buf != 0` to enable
   history. No history flag needed in the readline flags byte.

4. **Color bytes written by putchar** when `$term_render_color` is set. This is
   independent of ANSI mode -- programs can set `$term_current_color` directly.

5. **BS/DEL in putchar**: Backspace moves cursor left and shifts framebuffer text
   and color bytes left (same as today, minus mark tracking). Delete stays in place
   and shifts text+color left. Both always update chars and colors in lockstep.
   Readline handles its own buffer editing separately from putchar's framebuffer
   operations.

6. **Tab character**: Deferred to a future revision. Not included in initial
   implementation.

7. **Printf buffer**: Keep at 128 bytes for now. Document the limit clearly.

8. **Keyboard buffer**: Out of scope. No changes.

9. **ANSI parser error handling**: Invalid sequences flush buffered characters to
   screen. Valid but unsupported sequences are silently discarded. String termination
   mid-sequence triggers a flush and parser reset.
