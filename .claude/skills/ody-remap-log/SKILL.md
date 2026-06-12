---
name: ody-remap-log
description: Remaps Wire Wrap Odyssey assembler.log file offsets to actual RAM addresses. Use this skill whenever the user wants to translate an Odyssey assembler.log from zero-indexed file offsets to real memory addresses, has trace output showing where instructions actually executed in RAM, or is trying to cross-reference a crash address or trace output against the assembler listing. Triggers on phrases like "remap the log", "fix assembler.log addresses", "translate log offsets to RAM", "the log doesn't match my trace", or when the user has a RAM address from a trace and wants to find it in the log.
---

## Background

The Odyssey assembler log has **two sections with different address spaces**, both of which need remapping with different offsets:

**1. Incomplete assembly (INFO lines)** -- code-relative addresses, starting from 0x0000 for the first instruction. This is the metadata-rich section showing opcode names, label targets, and relocation rewrites:

```
INFO:root:0003 01 CALL     <-- .start_mark    <- space after addr (opcode listing)
INFO:root:003a: hi>:argv_init->28             <- colon after addr (relocation log)
```

**2. Final assembly (bare lines)** -- file-relative addresses, starting from 0x0000 for the first byte of the ODY file (including the variable-length header). This is the raw byte dump:

```
0000 4f # Magic string 'O'
003d 01 # CALL <-- .start_mark
```

The same instruction appears in both sections at **different addresses** because the final assembly addresses include the ODY header (magic bytes + rewrite table), while the INFO addresses do not. The header size is variable (depends on the number of relocation entries) and must be derived from the file itself.

When the ODY file loads into RAM, the entire file is placed at a contiguous load address. This means:
- `RAM address = INFO address + info_offset`
- `RAM address = file address + final_offset`
- `final_offset = info_offset - header_size`

## Steps

### 1. Locate the assembler.log

If the path is clear from context (the user just built a program, there is only one assembler.log nearby, or they pasted log content), use that path. Otherwise ask.

### 2. Determine the address space of the user's mappings

**Default: assume INFO/code-relative addresses.** The user does not need to say anything special.

Only treat the mappings as final assembly (file-relative) addresses if the user explicitly says so -- phrases like "final assembly offset", "file offset", or "byte dump address" indicate this.

If unclear, state your assumption: "I'm treating these as incomplete assembly (code-relative) addresses. If you meant final assembly (file-relative) addresses, let me know."

### 3. Collect address mappings

Ask for at least one mapping, encourage two:

> "I need at least one mapping: the RAM address where a known instruction actually ran, and that instruction's address in the assembler.log.
>
> By default I treat the log address as an **incomplete assembly (INFO section)** address -- the code-relative value shown on INFO:root: lines.
>
> Format: `RAM_address log_address` (hex, 0x prefix optional)
> Example: `0xb98d 0003` means the instruction at INFO address 0003 is actually at RAM 0xb98d.
>
> Two mappings are better -- they let me verify consistency. One is enough."

Accept flexible input: with/without `0x`, uppercase/lowercase, spaces or `->` or `=` as separator.

### 4. Compute offsets

Parse each mapping into `(ram_addr, log_addr)` integers and compute the primary offset:

```
primary_offset = ram_addr - log_addr
```

**Validate consistency** if two or more mappings are given:
- If all agree: proceed.
- If they disagree: **stop and warn the user**. Show each mapping and its computed offset. This means a log address or trace value is wrong. Ask which to trust.

**Derive the header size** from the final assembly section by reading the rewrite count at file offsets 0x0004-0x0005 (always present in any ODY file):

```python
import re

with open(log_path, 'r') as f:
    lines = f.readlines()

hi_byte = lo_byte = None
for line in lines:
    if re.match(r'^0004 ', line):
        hi_byte = int(line.split()[1], 16)
    if re.match(r'^0005 ', line):
        lo_byte = int(line.split()[1], 16)
    if hi_byte is not None and lo_byte is not None:
        break

rewrite_count = (hi_byte << 8) | lo_byte
header_size = 6 + 2 * rewrite_count   # magic(3) + flags(1) + count(2) + table(2*N)
```

**Compute both offsets** from the primary offset and header size:

| User gave | Then... |
|-----------|---------|
| INFO address | `info_offset = primary_offset`; `final_offset = info_offset - header_size` |
| file address | `final_offset = primary_offset`; `info_offset = final_offset + header_size` |

Report the derived values as a sanity check:
```
Header size:       0x003a (26 rewrite entries)
INFO offset:      +0xb98a  (code-relative -> RAM)
Final asm offset: +0xb950  (file-relative -> RAM)
Load address:      0xb950  (where the ODY file sits in RAM)
```

### 5. Confirm output destination

Ask whether to overwrite in place or write to a new file. Default: overwrite in place (it is a build artifact).

### 6. Rewrite the log

Apply `info_offset` to INFO lines and `final_offset` to bare lines:

```python
import re

log_path = "PATH_FROM_USER"
out_path = "SAME_OR_NEW"
info_offset  = INFO_OFFSET    # integer
final_offset = FINAL_OFFSET   # integer

with open(log_path, 'r') as f:
    lines = f.readlines()

pat_info_reloc = re.compile(r'^(INFO:root:)([0-9a-f]{4})(: .*)$')
pat_info_asm   = re.compile(r'^(INFO:root:)([0-9a-f]{4})( .*)$')
pat_final      = re.compile(r'^()([0-9a-f]{4})( .*)$')

out = []
info_count = final_count = 0
for line in lines:
    stripped = line.rstrip('\n')
    m = pat_info_reloc.match(stripped) or pat_info_asm.match(stripped)
    if m:
        new_addr = (int(m.group(2), 16) + info_offset) & 0xffff
        out.append('{}{:04x}{}\n'.format(m.group(1), new_addr, m.group(3)))
        info_count += 1
        continue
    m = pat_final.match(stripped)
    if m:
        new_addr = (int(m.group(2), 16) + final_offset) & 0xffff
        out.append('{:04x}{}\n'.format(new_addr, m.group(3)))
        final_count += 1
        continue
    out.append(line)

with open(out_path, 'w') as f:
    f.writelines(out)

print(f"INFO lines remapped:      {info_count} (offset +0x{info_offset & 0xffff:04x})")
print(f"Final asm lines remapped: {final_count} (offset +0x{final_offset & 0xffff:04x})")
```

### 7. Report anchor verification

After writing, grep for the expected RAM addresses from the user's mappings and show matching lines from both sections:

```
Header size:       0x003a (26 rewrite entries)
INFO offset:      +0xb98a
Final asm offset: +0xb950
Load address:      0xb950

Anchor check:
  INFO:root:b98d 01 CALL <-- .PTMRTEST_start_prog_mark   [expected b98d OK]
        b98d 01 # CALL <-- .PTMRTEST_start_prog_mark     [expected b98d OK]
  INFO:root:bbc5 01 CALL <-- .PTMRTEST_end_prog_mark     [expected bbc5 OK]
        bbc5 01 # CALL <-- .PTMRTEST_end_prog_mark       [expected bbc5 OK]

INFO lines remapped:      661
Final asm lines remapped: 633
```

Showing both sections for each anchor confirms that both offsets are correct.
