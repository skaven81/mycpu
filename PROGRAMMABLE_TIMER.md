# Programmable Timer (PTMR) -  Odyssey Peripheral Reference

## Overview

The programmable timer peripheral is built around an Intel 82C54-compatible
CMOS programmable interval timer. It provides three independent 16-bit
countdown timers, each with a software-selectable clock source. All three
timers share a single IRQ line (IRQ2). The peripheral occupies addresses
in the `0xC400-0xC4FF` range.

The timer is intended for three primary use cases:

- **General-purpose countdowns** (Mode 0): one-shot delays, timeouts, and
  task scheduling. The ISR reloads the counter each time, allowing the
  interval to be varied between firings.
- **Periodic fixed-rate interrupts** (Mode 2): audio sample mixing, frame
  pacing, or any workload requiring a stable interrupt rate. The counter
  reloads itself in hardware with zero jitter.
- **Software profiling**: a counter running in Mode 0 at a high-frequency
  clock source can be read at any time using the Counter Latch Command,
  yielding elapsed time with microsecond or sub-microsecond resolution
  without requiring an interrupt.

---

## Register Map

| Address | Macro | R/W | Description |
|---------|-------|-----|-------------|
| `0xC480` | `%ptmr_counter0%` | R/W | 82C54 Counter 0 |
| `0xC481` | `%ptmr_counter1%` | R/W | 82C54 Counter 1 |
| `0xC482` | `%ptmr_counter2%` | R/W | 82C54 Counter 2 |
| `0xC483` | `%ptmr_ctrl_write%` | W | 82C54 Control Word / Read-Back Command |
| `0xC440` | `%ptmr_clk_sel%` | W | Clock source selection register |
| `0xC408` | `%ptmr_clr_t2_irq%` | W | Clear IRQ latch, Timer 2 only |
| `0xC410` | `%ptmr_clr_t1_irq%` | W | Clear IRQ latch, Timer 1 only |
| `0xC420` | `%ptmr_clr_t0_irq%` | W | Clear IRQ latch, Timer 0 only |
| `0xC438` | `%ptmr_clr_all_irq%` | W | Clear IRQ latches, all timers |
| `0xC4A0` | `%ptmr_counter0_clr_t0%` | W | 82C54 Counter 0 + clear Timer 0 IRQ latch |
| `0xC491` | `%ptmr_counter1_clr_t1%` | W | 82C54 Counter 1 + clear Timer 1 IRQ latch |
| `0xC48A` | `%ptmr_counter2_clr_t2%` | W | 82C54 Counter 2 + clear Timer 2 IRQ latch |
| `0xC4BB` | `%ptmr_isr_fastpath%` | W | 82C54 Control Word + clear all IRQ latches |

IRQ clear bits are decoded directly from address lines A5 (Timer 0), A4 (Timer
1), and A3 (Timer 2) within the `0xC400-0xC4FF` page. These bits are additive
offsets that may be combined with any other address in the page. Any
combination of clear bits may be asserted in a single bus cycle. The data value
written is always ignored for IRQ latch clears; only the address lines matter.

---

## Clock Source Selection Register (`0xC440`)

A write-only 8-bit register. Bits `[1:0]` select the clock source for
Timer 0; bits `[3:2]` for Timer 1; bits `[5:4]` for Timer 2. Bits `[7:6]`
are unused.

| Code   | Source               | Frequency  | Tick Period | Max Range (16-bit) |
|--------|----------------------|------------|-------------|--------------------|
| `0b00` | Dedicated oscillator | 1.8432 MHz | ~543 ns 	   | ~35.6 ms           |
| `0b01` | RTC crystal          | 32.768 kHz | ~30.5 µs   | ~2.0 s             |
| `0b10` | Dedicated oscillator | 1.000 MHz  | 1.000 µs   | ~65.5 ms           |
| `0b11` | System clock         | ~2.2 MHz   | ~455 ns     | ~29.8 ms           |

The clock source for each timer is independent. All three timers may run
from different sources simultaneously.

The register is not readable. Software is responsible for tracking the
current configuration.

The 1.8432 MHz source was chosen because it is an integer multiple of many
standard baud rates (9600, 19200, 38400, 57600, 115200), making it suitable for
bit-banging serial streams in software. But it is also nearly 2x faster than
the 1.000 MHz source, so it can be used for higher-resolution timing work as
well.  But For general timing work requiring simple count arithmetic, prefer
the 1.000 MHz source.

---

## Interrupt Architecture

Each timer's OUT signal is connected to the CLK input of a dedicated
74HC74 D-type flip-flop, with D tied to Vcc. A rising edge on OUT
latches a logic high into the flip-flop, asserting that timer's IRQ
latch. The Q outputs of all three flip-flops are combined through a
3-input NOR gate whose output drives the Odyssey's active-low `/IRQ2`
line.

`/IRQ2` is asserted (low) whenever one or more IRQ latches are set.
It remains asserted until software explicitly clears all set latches.

**IRQ latches are set by hardware (OUT rising edge) and cleared only by
software.** They are not self-clearing. An ISR that returns without
clearing a latch will immediately re-enter.

### Race Condition Handling

The ISR must be written to handle the case where a second timer fires
during execution of the handler for a first timer. The correct pattern
is:

1. On ISR entry, issue a Read-Back status command to latch the current
   OUT state of all three counters.
2. Inspect the latched status bytes to determine which timers were
   active *at ISR entry*.
3. Clear the IRQ latches **only for those timers that were observed
   active**. Do not clear latches for timers whose OUT bit was not set.
4. Service the active timers.
5. Return. If a timer fired between step 1 and step 3, its latch is
   still set, `/IRQ2` remains asserted, and the CPU re-enters the ISR
   immediately.

**Clearing a latch that was not observed active risks silently dropping
an interrupt.** If Timer 1 fires between when its status byte is read
(OUT=0) and when an indiscriminate "clear all" is issued, that firing
is lost. Per-timer conditional clearing is the only safe pattern.

---

## Supported Timer Modes

The 82C54 supports six counter modes. Only two are supported and tested
on the Odyssey:

### Mode 0 - Interrupt on Terminal Count

OUT is initially low after the control word is written. The counter
decrements on each CLK pulse. When the count reaches zero, OUT goes
high. The **rising edge** of OUT is what triggers the IRQ latch; the
subsequent state of OUT is irrelevant to interrupt handling.

The ISR **must** reload the counter to re-arm the timer for the next
firing. Writing a new count causes OUT to go low immediately (on the
first byte of a two-byte write), which does not trigger the IRQ latch
since the latch is edge-triggered on the rising transition only. The
next terminal count will produce a new rising edge and a new interrupt.
The reload value may differ each time, enabling variable-interval
scheduling.

An initial count of N causes OUT to go high after N+1 CLK pulses
following the count write.

**Use for**: one-shot delays, variable-interval scheduling, profiling.

### Mode 2 - Rate Generator

OUT is initially high. When the count decrements to 1, OUT goes low
for exactly one CLK pulse, then returns high. The counter reloads its
initial value automatically and the cycle repeats indefinitely.

The IRQ latch is triggered by the **rising edge** of OUT -- that is, the
transition from low back to high at the end of the one-CLK-wide pulse,
not the falling edge at the start of the pulse. For an initial count of
N, the interrupt fires exactly N CLK cycles after the previous firing.
When calculating intervals or counting events, note that the interrupt
arrives one CLK pulse after OUT first went low: the period is N cycles,
not N-1.

The ISR does **not** need to reload the counter. Period jitter is zero:
the reload is performed in hardware independent of ISR latency.

**Use for**: fixed-rate periodic interrupts, PCM audio sample mixing.

### Unsupported Modes

Modes 1, 3, 4, and 5 are not supported. Mode 3 produces a square wave
whose OUT transitions twice per period, causing the IRQ latch to fire
on both edges. Modes 1 and 5 require hardware GATE triggering. Mode 4
produces a single-CLK-wide strobe with no latching behavior.

All GATE inputs are tied to Vcc. The GATE signal cannot be controlled
by software.

---

## Control Word Format

Written to `0xC483`. Selects counter, read/write format, and mode.

```
  D7  D6  D5  D4  D3  D2  D1  D0
 SC1 SC0 RW1 RW0  M2  M1  M0 BCD
```

| Field | Bits | Value | Meaning |
|-------|------|-------|---------|
| SC    | 7:6  | `00`  | Select Counter 0 |
|       |      | `01`  | Select Counter 1 |
|       |      | `10`  | Select Counter 2 |
|       |      | `11`  | Read-Back Command |
| RW    | 5:4  | `00`  | Counter Latch Command |
|       |      | `01`  | Read/Write LSB only |
|       |      | `10`  | Read/Write MSB only |
|       |      | `11`  | Read/Write LSB then MSB |
| M     | 3:1  | `000` | Mode 0 |
|       |      | `010` | Mode 2 |
| BCD   | 0    | `0`   | Counter is treated as binary (0) or BCD (1) |

Writing a control word immediately resets the selected counter and
drives OUT to its mode-specific idle state. No CLK pulse is required.
The counter does not begin counting until the initial count is written.

**Caution**: if OUT transitions from low to high as a result of writing
a control word (e.g., when switching from Mode 0 after a terminal count
to any mode whose idle state is high), that rising edge will trigger the
IRQ latch and assert `/IRQ2`. To avoid entering the ISR mid-setup, mask
interrupts before writing the control word and initial count. After
setup is complete, clear the IRQ latch for the affected timer, then
unmask interrupts.

**Always use LSB-then-MSB (`RW=11`) unless the count is guaranteed to
fit in 8 bits.** Writing only LSB zeros the MSB; writing only MSB zeros
the LSB.

---

## Read-Back Command

The Read-Back command latches the count and/or status of one or more
counters simultaneously. It is the preferred method for reading counters
that are actively counting, as it freezes the value atomically.

Written to `0xC483`:

```
  D7  D6    D5     D4    D3   D2   D1  D0
   1   1  /CNT  /STAT  CNT2 CNT1 CNT0   0
```

`/CNT` and `/STAT` are **active low**: set to 0 to latch that
information. Counter select bits D3:D1 are active high.

After issuing a Read-Back command, read each selected counter's address.
If both count and status were latched, the **first read returns the
status byte**; subsequent reads return the latched count (LSB first if
RW=11).

### Status Byte Format

```
  D7       D6    D5  D4  D3  D2  D1  D0
 OUT  NULLCNT  RW1 RW0  M2  M1  M0 BCD
```

| Bit           | Meaning |
|---------------|---------|
| D7 (OUT)      | Current state of OUT pin. 1 = timer has fired and latch is pending. |
| D6 (NULLCNT)  | 1 = written count not yet transferred to counting element. |
| D5:D0         | Programmed mode, as written in last control word. |

`OUT` (D7) is the MSB. After loading the status byte into a register,
use `ALUOP_FLAGS %Amsb%+%AL%` (or `%Bmsb%+%BL%`) to test this bit
without requiring a mask value in a peer register. Z=0 indicates the
timer fired; Z=1 indicates it did not.

---

## IRQ Latch Clear Interleaving

Because IRQ latch clear bits are decoded directly from address lines
A5, A4, and A3 independently of all other address decoding, any bus
cycle in the `0xC400-0xC4FF` page can simultaneously clear one or more
IRQ latches at no extra cost. The clear offset macros are designed to
be added to any other PTMR address:

| Macro            | Value    | IRQ latches cleared |
|------------------|----------|---------------------|
| `%ptmr_clr_t0%`  | `0x0020` | Timer 0 (A5)        |
| `%ptmr_clr_t1%`  | `0x0010` | Timer 1 (A4)        |
| `%ptmr_clr_t2%`  | `0x0008` | Timer 2 (A3)        |
| `%ptmr_clr_all%` | `0x0038` | All three timers    |

Combined-operation addresses with their macros:

| Address  | Macro                           | Operation |
|----------|---------------------------------|-----------|
| `0xC4A0` | `%ptmr_counter0_clr_t0%`        | 82C54 Counter 0 + clear Timer 0 latch |
| `0xC491` | `%ptmr_counter1_clr_t1%`        | 82C54 Counter 1 + clear Timer 1 latch |
| `0xC48A` | `%ptmr_counter2_clr_t2%`        | 82C54 Counter 2 + clear Timer 2 latch |
| `0xC478` | `%ptmr_clk_sel%+%ptmr_clr_all%` | Clock mux register + clear all IRQ latches |
| `0xC438` | `%ptmr_clr_all_irq%`            | Clear all IRQ latches, no other effect |

`%ptmr_isr_fastpath%` (`0xC4BB`) is useful when an ISR can safely clear
all three latches unconditionally -- for example when only one timer is
active and re-entry within a single ISR execution is impossible. Writing
a Read-Back status command to this address simultaneously latches the
status of all three counters and clears all three IRQ flip-flops in one
bus cycle:

```asm
ST %ptmr_isr_fastpath% %ptmr_rb_status_all%
```

For ISRs where multiple timers may be active simultaneously, use the
per-timer conditional clear pattern in the ISR example below: read all
status bytes first, then clear only latches for timers observed active.
This prevents clearing a latch for a timer that fired after the status
read but before the clear, which would silently drop that interrupt.

---

## Assembly Macros

Defined in `asm_macros`. All macros prefixed `%ptmr_`.

### Address Bases

```
%ptmr_base%             0xC400   ; base: IRQ clear only, no other effect
%ptmr_base_ctrl%        0xC480   ; base: 82C54 register access (A7)
%ptmr_base_clksel%      0xC440   ; base: clock mux register (A6)
```

### IRQ Latch Clear Offsets

These are additive offsets onto any PTMR base address. OR or add them
to any address in `0xC400–0xC4FF` to clear the corresponding latch(es)
as part of that bus cycle.

```
%ptmr_clr_t0%           0x0020   ; A5: clear Timer 0 IRQ latch
%ptmr_clr_t1%           0x0010   ; A4: clear Timer 1 IRQ latch
%ptmr_clr_t2%           0x0008   ; A3: clear Timer 2 IRQ latch
%ptmr_clr_all%          0x0038   ; A5|A4|A3: clear all IRQ latches
```

### Composed Addresses

```
; 82C54 register access (no IRQ clear)
%ptmr_counter0%         %ptmr_base_ctrl%+0x00   ; 0xC480
%ptmr_counter1%         %ptmr_base_ctrl%+0x01   ; 0xC481
%ptmr_counter2%         %ptmr_base_ctrl%+0x02   ; 0xC482
%ptmr_ctrl_write%       %ptmr_base_ctrl%+0x03   ; 0xC483
%ptmr_ctrl_read%        %ptmr_base_ctrl%+0x03   ; 0xC483
%ptmr_clk_sel%          %ptmr_base_clksel%       ; 0xC440

; IRQ clear only (no 82C54 access)
%ptmr_clr_t0_irq%       %ptmr_base%+%ptmr_clr_t0%              ; 0xC420
%ptmr_clr_t1_irq%       %ptmr_base%+%ptmr_clr_t1%              ; 0xC410
%ptmr_clr_t2_irq%       %ptmr_base%+%ptmr_clr_t2%              ; 0xC408
%ptmr_clr_all_irq%      %ptmr_base%+%ptmr_clr_all%             ; 0xC438

; Combined 82C54 counter access + matching IRQ latch clear
%ptmr_counter0_clr_t0%  %ptmr_base_ctrl%+0x00+%ptmr_clr_t0%   ; 0xC4A0
%ptmr_counter1_clr_t1%  %ptmr_base_ctrl%+0x01+%ptmr_clr_t1%   ; 0xC491
%ptmr_counter2_clr_t2%  %ptmr_base_ctrl%+0x02+%ptmr_clr_t2%   ; 0xC48A

; Combined 82C54 control register + clear all IRQ latches
%ptmr_isr_fastpath%     %ptmr_base_ctrl%+0x03+%ptmr_clr_all%  ; 0xC4BB
```

### Clock Source Selection Bytes

OR together one value per timer and write to `%ptmr_clk_sel%`.

```
%ptmr_clk_tmr0_18M%     0b00000000   ; Timer 0: 1.8432 MHz
%ptmr_clk_tmr0_32k%     0b00000001   ; Timer 0: 32.768 kHz
%ptmr_clk_tmr0_10M%     0b00000010   ; Timer 0: 1.000 MHz
%ptmr_clk_tmr0_sys%     0b00000011   ; Timer 0: system clock
%ptmr_clk_tmr1_18M%     0b00000000   ; Timer 1: 1.8432 MHz
%ptmr_clk_tmr1_32k%     0b00000100   ; Timer 1: 32.768 kHz
%ptmr_clk_tmr1_10M%     0b00001000   ; Timer 1: 1.000 MHz
%ptmr_clk_tmr1_sys%     0b00001100   ; Timer 1: system clock
%ptmr_clk_tmr2_18M%     0b00000000   ; Timer 2: 1.8432 MHz
%ptmr_clk_tmr2_32k%     0b00010000   ; Timer 2: 32.768 kHz
%ptmr_clk_tmr2_10M%     0b00100000   ; Timer 2: 1.000 MHz
%ptmr_clk_tmr2_sys%     0b00110000   ; Timer 2: system clock
```

### Composed Control Words

```
; Counter select (bits 7:6) -- combine with RW and mode fields
%ptmr_cw_sel_t0%        0b00000000   ; SC=00, Counter 0
%ptmr_cw_sel_t1%        0b01000000   ; SC=01, Counter 1
%ptmr_cw_sel_t2%        0b10000000   ; SC=10, Counter 2

; Latch command (RW=00) -- OR with counter select to latch that counter
%ptmr_cw_latch%         0b00000000   ; RW=00, Counter Latch Command

; Full control words: counter select | RW=11 (LSB+MSB) | mode | binary
%ptmr_cw_t0_mode0%      0b00110000   ; Counter 0, Mode 0, LSB+MSB, binary
%ptmr_cw_t1_mode0%      0b01110000   ; Counter 1, Mode 0, LSB+MSB, binary
%ptmr_cw_t2_mode0%      0b10110000   ; Counter 2, Mode 0, LSB+MSB, binary
%ptmr_cw_t0_mode2%      0b00110100   ; Counter 0, Mode 2, LSB+MSB, binary
%ptmr_cw_t1_mode2%      0b01110100   ; Counter 1, Mode 2, LSB+MSB, binary
%ptmr_cw_t2_mode2%      0b10110100   ; Counter 2, Mode 2, LSB+MSB, binary
%ptmr_cw_t0_mode0_lo%   0b00010000   ; Counter 0, Mode 0, LSB only, binary
%ptmr_cw_t1_mode0_lo%   0b01010000   ; Counter 1, Mode 0, LSB only, binary
%ptmr_cw_t2_mode0_lo%   0b10010000   ; Counter 2, Mode 0, LSB only, binary
```

### Read-Back Commands

```
%ptmr_rb_status_all%    0b11101110   ; latch status, all three counters
%ptmr_rb_both_all%      0b11001110   ; latch count+status, all counters
%ptmr_rb_status_t0%     0b11100010   ; latch status, Timer 0 only
%ptmr_rb_status_t1%     0b11100100   ; latch status, Timer 1 only
%ptmr_rb_status_t2%     0b11101000   ; latch status, Timer 2 only
```

### Status Byte Masks

```
%ptmr_stat_out%         0b10000000   ; D7: OUT pin state
%ptmr_stat_nullcnt%     0b01000000   ; D6: count not yet loaded
%ptmr_stat_mode_mask%   0b00001110   ; D3:D1: programmed mode
%ptmr_stat_mode0%       0b00000000   ; mode field value for Mode 0
%ptmr_stat_mode2%       0b00000100   ; mode field value for Mode 2
```

---

## Programming Sequences

### Mode 0: One-Shot Countdown

```asm
# Configure Timer 0 for a 1ms delay using 1MHz clock.
# Interrupt fires once; ISR must reload to repeat.
# Mask interrupts during setup to prevent spurious IRQ2 entry.
#
# The clock selection register controls all three timers simultaneously.
# Writing %ptmr_clk_tmr0_10M% alone would zero the clock selections for
# Timer 1 and Timer 2. Instead, maintain a global variable $ptmr_clk_cfg
# that tracks the current register state, and OR in the new field before
# writing. Example assumes Timer 1 and Timer 2 are already configured.

VAR global byte $ptmr_clk_cfg   ; shadow of clock selection register

MASKINT
LD_AL $ptmr_clk_cfg              # load current clock config
LDI_BL 0b11111100                # mask off Timer 0 bits [1:0]
ALUOP_AL %A&B%+%AL%+%BL%
LDI_BL %ptmr_clk_tmr0_10M%      # OR in new Timer 0 selection
ALUOP_AL %A|B%+%AL%+%BL%
ST $ptmr_clk_cfg AL              # update shadow
ST %ptmr_clk_sel% AL             # write to hardware

ST %ptmr_ctrl_write% %ptmr_cw_t0_mode0% # Mode 0, LSB+MSB; OUT goes low
ST %ptmr_counter0% 0xE8                  # count LSB (1000 = 0x03E8)
ST %ptmr_counter0_clr_t0% 0x03
  # counter 0 MSB committed to 82C54 and Timer 0 IRQ latch cleared
  # in one bus cycle; counting begins immediately after this write
UMASKINT
# IRQ2 fires in ~1ms
```

### Mode 2: Fixed-Rate Periodic

```asm
# Configure Timer 1 for 8kHz periodic interrupt using 1MHz clock.
# Count = 1000000 / 8000 = 125. ISR does not reload.
# IRQ fires on the rising edge of OUT (end of the one-CLK-wide low pulse).
#
# As with Mode 0 setup, use the $ptmr_clk_cfg shadow variable to update
# only Timer 1's clock field without clobbering Timer 0 or Timer 2.

MASKINT
LD_AL $ptmr_clk_cfg              # load current clock config
LDI_BL 0b11110011                # mask off Timer 1 bits [3:2]
ALUOP_AL %A&B%+%AL%+%BL%
LDI_BL %ptmr_clk_tmr1_10M%      # OR in new Timer 1 selection
ALUOP_AL %A|B%+%AL%+%BL%
ST $ptmr_clk_cfg AL
ST %ptmr_clk_sel% AL

ST %ptmr_ctrl_write% %ptmr_cw_t1_mode2% # Mode 2, LSB+MSB; OUT goes high
ST %ptmr_counter1% 0x7D                  # count LSB (125 = 0x007D)
ST %ptmr_counter1_clr_t1% 0x00
  # counter 1 MSB (zero) committed to 82C54 and Timer 1 IRQ latch cleared
  # in one bus cycle; counting begins immediately after this write
UMASKINT
# IRQ2 fires every 125us indefinitely
```

### Profiling: Micro-op and Elapsed Time Measurement

The system clock source makes the timer directly useful for profiling:
because each timer tick corresponds to one micro-op executed by the CPU,
the counted value is independent of clock frequency. If the system clock
changes, the micro-op count between start and latch remains accurate.
This is the correct source for profiling code paths by instruction cost.

For measuring wall-clock elapsed time, the 1.000 MHz source gives 1µs
per tick with a ~65ms range. The 32.768 kHz source gives ~30.5µs per
tick with a ~2s range, suitable for coarser spans. Note that timer setup
and readback each require several micro-ops; sub-10-µs measurements are
not meaningful.

```asm
# Profile a code region by micro-op count using Timer 2.
# System clock source: 1 tick = 1 micro-op, clock-speed independent.
# The counter counts down; elapsed = 0xFFFF - latched_count.
# Profiling counter will assert IRQ2 if it reaches zero (~65535 micro-ops
# at system clock); mask interrupts or install a no-op handler if needed.

MASKINT
LD_AL $ptmr_clk_cfg
LDI_BL 0b11001111                # mask off Timer 2 bits [5:4]
ALUOP_AL %A&B%+%AL%+%BL%
LDI_BL %ptmr_clk_tmr2_sys%      # OR in system clock for Timer 2
ALUOP_AL %A|B%+%AL%+%BL%
ST $ptmr_clk_cfg AL
ST %ptmr_clk_sel% AL

ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0% # Mode 0, LSB+MSB
ST %ptmr_counter2% 0xFF                  # count LSB (0xFFFF)
ST %ptmr_counter2% 0xFF                  # count MSB; counting begins
ST %ptmr_clr_t2_irq% 0x00               # clear any latch set during setup
UMASKINT

# --- code under measurement ---

# Latch count atomically without disturbing the counter
# Counter Latch Command for Timer 2: SC=10, RW=00, M=000, BCD=0
ST %ptmr_ctrl_write% 0b10000000   ; = %ptmr_cw_sel_t2% | %ptmr_cw_latch%

# Read latched count LSB then MSB
LD_AL %ptmr_counter2%             # LSB of remaining count
# ... save AL ...
LD_AL %ptmr_counter2%             # MSB of remaining count
# elapsed micro-ops = 0xFFFF - (MSB:LSB)
```

For wall-clock elapsed time, substitute `%ptmr_clk_tmr2_10M%` (1µs/tick)
or `%ptmr_clk_tmr2_32k%` (~30.5µs/tick) and multiply accordingly.

### ISR: Determine Which Timer(s) Fired

```asm
:ptmr_isr
# Latch status of all three counters atomically.
# Do NOT clear IRQ latches yet.
ST %ptmr_ctrl_write% %ptmr_rb_status_all%

# Read status bytes. OUT bit (D7) indicates which timers fired.
# Clear the IRQ latch only for timers observed active.
# Timers firing after the status read will retain their latches.

LD_AL %ptmr_counter0%          # Timer 0 status byte
ALUOP_FLAGS %Amsb%+%AL%        # Z=0 means OUT=1, timer 0 fired
JZ .ptmr_isr_check_t1
ST %ptmr_clr_t0_irq% 0x00      # clear Timer 0 IRQ latch
CALL :ptmr_t0_handler

.ptmr_isr_check_t1
LD_AL %ptmr_counter1%          # Timer 1 status byte
ALUOP_FLAGS %Amsb%+%AL%
JZ .ptmr_isr_check_t2
ST %ptmr_clr_t1_irq% 0x00      # clear Timer 1 IRQ latch
CALL :ptmr_t1_handler

.ptmr_isr_check_t2
LD_AL %ptmr_counter2%          # Timer 2 status byte
ALUOP_FLAGS %Amsb%+%AL%
JZ .ptmr_isr_done
ST %ptmr_clr_t2_irq% 0x00      # clear Timer 2 IRQ latch
CALL :ptmr_t2_handler

.ptmr_isr_done
# Any timer that fired after its status was read still has its
# IRQ latch set. /IRQ2 will remain asserted and the CPU re-enters
# this ISR immediately after RETI.
RETI
```

### Shutdown: Idle All Timers

```asm
# Writing a control word resets the counter and drives OUT to its
# mode-specific idle state immediately (no CLK pulse required).
# Mode 0 idle: OUT low. Mode 2 idle: OUT high (counting halted
# until a count is written).
#
# To idle safely, write a Mode 0 control word to all counters.
# Do not write a count value; the counter waits indefinitely.
# Mask interrupts to prevent the OUT transition from triggering IRQ2.

MASKINT
ST %ptmr_ctrl_write% %ptmr_cw_t0_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%
ST %ptmr_clr_all_irq% 0x00              # clear any pending IRQ latches
UMASKINT
```

---

## Usage Notes

**Clock source register is write-only and affects all three timers**: the
register at `0xC440` cannot be read back. To update one timer's clock
source without disturbing the others, maintain a global shadow variable
(e.g. `$ptmr_clk_cfg`) that mirrors the last value written. Read the
shadow, mask off the target timer's two bits, OR in the new selection,
write both the shadow and the hardware register. All programming sequence
examples above follow this pattern.

**Initialization order**: always write the control word before writing
the count. Writing a count without a preceding control word produces
undefined behavior.

**Two-byte counts**: when using LSB+MSB mode, the two count bytes must
be written in consecutive instructions with no intervening access to the
same counter from any other context (including ISRs). Mask interrupts
if necessary.

**Counter readback without latch**: reading a counter address directly
while it is actively counting may return a transitional value. Always
use the Counter Latch Command or Read-Back Command for accurate reads.

**NULLCNT bit**: after writing a count, the count is not immediately
active in the counting element (CE). Check `%ptmr_stat_nullcnt%` in
the status byte if timing accuracy from the very first CLK pulse is
required. For most uses this is not necessary.

**Power-on state**: the 82C54 is undefined at power-on. All three
counters must be programmed with a control word before use. The shutdown
sequence above is suitable as an initialization step.

**Clock source register**: the clock source register (`0xC440`) is not
readable and has no defined power-on state. Software must write this
register before programming any counter.

**IRQ2 and the DS1511Y RTC**: IRQ2 is dedicated to the programmable
timer peripheral. The DS1511Y watchdog/RTC uses IRQ3. These are
independent and do not share an IRQ line.
