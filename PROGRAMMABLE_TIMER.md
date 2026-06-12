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
| `0xC404` | `%ptmr_irqlatch%` |  R   | Timer IRQ latch readout (MSB=timer2, D6=timer1, D5=timer0) |
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

IRQ clear bits are decoded directly from address lines A5 (Timer 0), A4 (Timer
1), and A3 (Timer 2) within the `0xC400-0xC4FF` page. These bits are additive
offsets that may be combined with any other address in the page. Any
combination of clear bits may be asserted in a single bus cycle. The clear is
triggered by the address lines alone; the bus cycle direction does not matter
(a `LD_TD` is just as effective as a `ST`) and any data on the bus is ignored.

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

1. On ISR entry, read the IRQ latch status (0xC404)
2. Inspect the latched status bits to determine which timers were
   active *at ISR entry*.
3. Clear the IRQ latches **only for those timers that were observed
   active**. Do not clear latches for timers whose OUT bit was not set.
4. Service the active timers.
5. Return. If a timer fired between step 1 and step 3, its latch is
   still set, `/IRQ2` remains asserted, and the CPU re-enters the ISR
   immediately.

**Clearing a latch that was not observed active risks silently dropping an
interrupt.** If Timer 1 fires between when the IRQ latch status byte is read
and when an indiscriminate "clear all" is issued, that firing is lost.
Per-timer conditional clearing is the only safe pattern.

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

`OUT` (D7) is not a reliable way of determining which timer fired to enter the ISR.
Instead, use the IRQ latch read-back byte at 0xC404. This reads out the state of the
IRQ latch flip-flops directly, avoiding issues with e.g. mode 2 timers resetting the
state of OUT to low before the ISR has a chance to read-out the status byte.

---

## IRQ Latch Clear Interleaving

Because IRQ latch clear bits are decoded directly from address lines A5, A4,
and A3 independently of all other address decoding, any read or write bus cycle
in the `0xC400-0xC4FF` page can simultaneously clear one or more IRQ latches at
no extra cost. When no other access is needed, `LD_TD %ptmr_clr_tN_irq%` (5
cycles, TD is volatile and discarded) is the cheapest standalone latch clear --
one cycle faster than `ST %ptmr_clr_tN_irq% 0x00`. The clear offset macros are
designed to be added to any other PTMR address:

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

---

## Assembly Macros

Defined in `asm_macros`

---

## Shutdown: Idling Timers

Writing a control word for a given timer resets the counter and drives OUT to
its mode-specific idle state immediately (no CLK pulse required).  Mode 0 idle:
OUT low. Mode 2 idle: OUT high (counting halted until a count is written).

To idle safely, write a Mode 0 control word to all counters.  Do not write a
count value; the counter waits indefinitely.  Mask interrupts to prevent the
OUT transition from triggering IRQ2.

```asm
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
