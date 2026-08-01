---
name: ody-io
description: Wire Wrap Odyssey memory map, peripherals, I/O, and storage reference. Use when working with memory addresses, peripheral registers, _SLOW peripheral access, interrupts, video/color output, extended memory paging, FAT16 disk access, ODY executable format, printf format specifiers, color codes, or keyboard flags.
version: 2.0.0
---

# Odyssey Memory Map, I/O, and Storage Reference

## _SLOW opcodes for peripheral access

Some peripherals gate their /RD and /WR strobes on stretched instruction
timing and silently return/write garbage with regular loads and stores. The
`_SLOW` instruction variants exist for this:
`LD_SLOW_PUSH @addr`, `ST_SLOW @addr $data`, `ST_SLOW_POP @addr`,
`LDA_{A,B,C,D}_SLOW_PUSH`, `STA_{A,B,C,D}_SLOW_POP`,
`ALUOP_ADDR_SLOW $op @addr`, `ALUOP_PUSH_SLOW $op`.

**Rule of thumb: ALL peripheral access (0xC000-0xC7FF) should use `_SLOW`
instructions.** It is correct for every address (the shell's peek/poke do
exactly this) and only costs a few extra cycles. The reality is that only
certain peripherals strictly need it -- the UART and ATA definitely do,
while the BIOS libraries access the keyboard, RTC/timer, page registers,
and 82C54 with regular instructions. When in doubt, follow existing code,
especially the BIOS library for that peripheral.

To write an ALU/register value to a `_SLOW` peripheral, prefer the single
instruction `ALUOP_ADDR_SLOW %A%+%AL% %uart_tbr%` over an
`ALUOP_PUSH`+`ST_SLOW_POP` pair. RAM above 0xC7FF (buffers, D/E windows,
heap) is normal-speed.

## Use the named peripheral macros, not raw addresses

`assembler/asm_macros` defines `%name%` constants for every peripheral
register and bit mask -- always use them instead of hex literals:

| Group | Examples |
|-------|----------|
| Video | `%display_chars%` (0x4000), `%display_color%` (0x5000), `%cursor%`, `%blink%` |
| Colors | `%white% %red% %green% %blue% %cyan% %magenta% %yellow%`, dark `%dred%`-style, `%ansi_*%` |
| IRQ vectors | `%IRQ0addr%`..`%IRQ7addr%` (0x5F00..0x5F0E) |
| Keyboard | `%kb_key%`, `%kb_keyflags%`, `%kb_keyflag_{BREAK,CTRL,ALT,FUNCTION,SHIFT,NUMLOCK,CAPSLOCK,SCROLLLOCK}%` |
| RTC/timer | `%tmr_clk_{sec,min,hr,day,date,month,year}%`, `%tmr_alarm_*%`, `%tmr_wdog_*%`, `%tmr_ctrl_{a,b,c}%`, `%tmr_sram_*%`, masks |
| UART | `%uart_{tbr,rbr,ucr,usr,mcr,brsr,msr}%` + bit masks (`%uart_usr_DR%`, `%uart_ucr_8n1%`, `%uart_brsr_9600%`, ...) |
| Prog. timer | `%ptmr_base%`, `%ptmr_counter{0,1,2}%`, `%ptmr_clr_*%`, `%ptmr_ctrl_*%` (82C54) |
| Ext. memory | `%d_page%` (0xC200), `%e_page%` (0xC201) |
| ATA | `%ata_{data,err,numsec,lba0..lba3,cmd_stat,lowreg}%`, `%ata_cmd_*%`, `%ata_err_*%` |

Grep `assembler/asm_macros` for the full list (~240 peripheral/constant
macros with per-bit comments).

## Memory Map

```
0x0000-0x3EFF  Program ROM (16 KiB)
0x4000-0x4EFF  Framebuffer characters (64x60 grid)
0x4F00-0x4FFF  Hidden framebuffer (global variables)
0x5000-0x5EFF  Framebuffer color (1 byte/char)
0x5F00-0x5F0F  Interrupt vector table (8 x 16-bit)
0x5F10-0x5FFF  Hidden framebuffer (global variables)
0x6000-0xBEFF  ~24 KiB dynamic RAM (malloc region)
0xBF00-0xBFFF  256 bytes CPU hardware stack
0xC000-0xC7FF  Peripheral registers (memory-mapped I/O)
0xC800-0xCAFF  768 bytes expanded RAM global assembly arrays
0xCB00-0xCBFF  256 bytes expanded RAM UART circular buffer
0xCC00-0xCCFF  256 bytes expanded RAM keyboard circular buffer
0xCD00-0xCFFF  768 bytes expanded RAM (free/future use)
0xD000-0xDFFF  Extended RAM D-page window (4 KiB)
0xE000-0xEFFF  Extended RAM E-page window (4 KiB)
0xF000-0xFFEF  ~4 KiB expanded RAM heap/software stack
0xFFF0-0xFFFE  Unallocated
0xFFFF          Reserved (idle bus)
```

## Peripherals

| Address | Peripheral |
|---------|------------|
| 0xC000-0xC001 | PS/2 Keyboard (0xC000=key, 0xC001=flags) |
| 0xC080-0xC0FF | RTC/Timer DS1511Y (BCD-encoded values) |
| 0xC100-0xC1FF | UART 82C52 (data, ctrl/status, modem ctrl, baud/modem status) |
| 0xC200-0xC2FF | Extended RAM page registers (even=D-page, odd=E-page) |
| 0xC300-0xC30F | ATA CS0/CS1 registers |
| 0xC310-0xC31F | ATA high byte latch (write hi first, lo write triggers 16-bit ATA write) |

## Interrupts

8-line priority encoder. IRQ saves PC and D register to stack. RETI restores status flag backup.

| IRQ | Vector | Source |
|-----|--------|--------|
| 1 | 0x5F02 | Keyboard |
| 2 | 0x5F04 | Programmable timer (82C54, all three counters) |
| 3 | 0x5F06 | RTC timer (DS1511Y) |
| 4 | 0x5F08 | UART modem status |
| 5 | 0x5F0A | UART data ready |

IRQ 0/6/7 reserved (IRQ0 highest priority, IRQ7 lowest).

**ISR contract**: an ISR behaves like any other function -- it must save
and restore EVERY register it touches before `RETI` (flags are covered by
the status backup bits + RETI). ISRs must never call heap functions or
anything else that executes `UMASKINT`. Install a handler by writing its
address to the vector (`ST16 %IRQ2addr% :my_isr`).

## Video

640x480 VGA, 64x60 character grid (8x8 chars, CP437 font). Dual-port SRAM: chars at 0x4000-0x4EFF, color at 0x5000-0x5EFF. Color byte: `[BLINK][CURSOR][Rfg][Gfg][Bfg][Rbg][Gbg][Bbg]` (64 colors + blink + cursor).

## Extended Memory

1 MiB (two 512 KiB AS6C4008), accessed via two 4 KiB windows. D-window: 0xD000, page register at 0xC200 (even). E-window: 0xE000, page register at 0xC201 (odd). Physical = (page << 12) | (addr & 0x0FFF). Pages 0x000-0x7FF reserved for malloc ledger.

## FAT16

Read-only FAT16 over ATA (PIO mode). Drives `0:` and `1:` (master/slave). 512-byte sectors, 28-bit LBA. 8.3 filenames (max 8-char command names).

## ODY Executable Format

| Offset | Content |
|--------|---------|
| 0-2 | Magic: `ODY` |
| 3 | Flags (2 bits: memory target) |
| 4-5 | Count of relocation entries (16-bit) |
| 6+ | N x 16-bit relocation offsets, then raw machine code |

Loader adds base address to each relocation offset. CALL targets to ROM functions are absolute (not relocated).

## printf Format Specifiers

`%%` literal, `%c` char, `%2` binary, `%b`/`%B` BCD (1/2 digits), `%x`/`%X` hex (byte/word), `%u`/`%U` unsigned decimal (byte/word), `%d`/`%D` signed decimal (byte/word), `%s` string pointer.

## Color Codes (`:print` strings)

`@[shade:0-3][color:0-7]` (0=blk 1=blu 2=grn 3=cyn 4=red 5=mag 6=yel 7=wht), `@x[hex]` raw, `@b/@B` blink off/on, `@c/@C` cursor off/on, `@r` reset.

## Keyboard Flags (0xC001)

`0x01` BREAK, `0x02` CTRL, `0x04` ALT, `0x08` FUNCTION, `0x10` SHIFT, `0x20` NUMLOCK, `0x40` CAPSLOCK, `0x80` SCROLLLOCK.
