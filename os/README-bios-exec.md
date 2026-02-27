# BIOS Exec Loop - Program Interface Reference

## Overview

The BIOS exec loop is the primary execution manager for the Odyssey OS.  It is
responsible for loading, launching, and cleaning up all ODY executables,
including the system shell (SYSTEM.ODY).

The loop runs forever:

1. Inspect the IPC block (global variables in BIOS ROM space)
2. If the IPC block names a valid program, load and run it
3. Otherwise, find and run SYSTEM.ODY (the fallback)
4. After the program returns, clean up memory and repeat

Programs **do not** directly load or execute other programs.  Instead, they
fill in the IPC block and then return normally.  The BIOS exec loop sees the
request on the next iteration and handles the load.

---

## The IPC Block

These are global variables declared in the BIOS.  Their addresses are exported
in `bios.sym` and are accessible from any ODY executable or assembly file that
links against the BIOS.

```
$exec_dirent_ptr   (word)  Pointer to a malloc'd fat16_dirent for the next
                           program to run.  Set to 0x0000 when there is no
                           pending execution request.

$exec_fsh_ptr      (word)  Pointer to the fs_handle (drive) that the dirent
                           was found on.  Must be set whenever exec_dirent_ptr
                           is set.

$exec_argc         (byte)  Argument count for the next program.  May be 0.

$exec_argv_ptr     (word)  Pointer to a malloc'd argv array.  The array
                           contains exec_argc word-sized pointers to
                           malloc'd, null-terminated strings.  Set to 0x0000
                           when there are no arguments.
```

**The IPC block is owned by the BIOS exec loop.**  The BIOS reads and clears
it at the top of every iteration.  Programs write to it just before returning.
Do not write to the IPC block and then continue executing for any significant
time - there is no synchronization, and the values should be considered
consumed as soon as the program exits.

---

## Requesting Execution of Another Program

To ask the BIOS to run a program after you exit:

### Step 1 - Obtain the dirent

Use `fat16_pathfind` to locate the target binary.  On success it returns a
pointer to a **malloc'd** copy of the `fat16_dirent` struct and also leaves the
matching `fs_handle` pointer on the heap.

```asm
LDI_C .target_path          # e.g. "/SYS/HEXDUMP.ODY\0"
CALL :heap_push_C
CALL :fat16_pathfind
CALL :heap_pop_A            # A = dirent pointer (or 0x00xx / 0x01xx on error)
                            # validate AH here before continuing
CALL :heap_pop_C            # fs_handle ptr in C (below dirent on heap)
```

Check for errors before proceeding with the second pop: `AH == 0x00` means not found, `AH == 0x01`
means ATA error.  Any other value for `AH` is a valid malloc address.

### Step 2 - Write to the IPC block

```asm
# Store dirent pointer
ALUOP_ADDR %A%+%AH% $exec_dirent_ptr
ALUOP_ADDR %A%+%AL% $exec_dirent_ptr+1

# Store fs_handle pointer (C still holds it from step 1)
ALUOP_ADDR %C%+%CH% $exec_fsh_ptr
ALUOP_ADDR %C%+%CL% $exec_fsh_ptr+1
```

### Step 3 - Build the argv array (optional)

If you want to pass arguments, allocate a contiguous array of `argc` word-sized
pointers, where each pointer refers to a separate malloc'd, null-terminated
string.  The array itself is also malloc'd.

```asm
# Example: argc=2, argv=["hexdump", "/SYS/FILE.TXT"]
#
# Allocate array: 2 entries * 2 bytes/entry = 4 bytes → 1 block
LDI_AL 1
CALL :malloc_blocks         # A = array address
ALUOP_ADDR %A%+%AH% $exec_argv_ptr
ALUOP_ADDR %A%+%AL% $exec_argv_ptr+1

# Copy each argument string into its own malloc block and store the pointer
# ... (use :strlen + :malloc_blocks + :strcpy for each token) ...

ST $exec_argc 2
```

The BIOS will free the argv strings and the array itself after the launched
program returns.  **Do not free them yourself** before exiting.

If you have no arguments to pass, leave `$exec_argv_ptr` at `0x0000` and
`$exec_argc` at `0x00`.  The BIOS will still push `argc=0` and `argv=NULL` to
the heap for the launched program.

### Step 4 - Return

Simply return from your program normally.  The BIOS exec loop regains control
and handles everything from there.

```asm
# Assembly: push return code, then RET
LDI_A 0x0000               # exit code 0
CALL :heap_push_A
RET

# C: just return from main()
return 0;
```

---

## Receiving argc and argv

**The BIOS always pushes `argc` and `argv` to the heap before executing any
ODY binary**, including SYSTEM.ODY on startup.  All programs receive these
values, whether they use them or not.

### C programs

Declare `main` with the standard prototype:

```c
int main(int argc, char **argv);
```

The C compiler's standard calling convention handles the rest.  `argc` and
`argv` are available as normal parameters.  `argv[0]` is conventionally the
command name as the user typed it.  `argv[argc]` is guaranteed to be `NULL`.

When launched from SYSTEM.ODY, `argc` is at least 1 (`argv[0]` is the command
name).  When launched as the fallback (i.e., SYSTEM.ODY itself), `argc` is 0
and `argv` is `NULL`.

**Do not free `argv` or any `argv[i]` string.**  The BIOS owns that memory and
will free it after your program exits.

### Assembly programs

The BIOS pushes in this order (C reverse-parameter convention):

```
heap (top, most recently pushed)
  ┌─────────────────────────────┐
  │  argc  (2 bytes, high then  │  ← popped first
  │         low, 16-bit int)    │
  ├─────────────────────────────┤
  │  argv  (2 bytes, word ptr)  │  ← popped second
  └─────────────────────────────┘
heap (bottom)
```

To receive them in assembly:

```asm
:my_program_entry
CALL :heap_pop_A            # A = argc (16-bit)
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%           # save argc in D for safekeeping
CALL :heap_pop_A            # A = argv pointer
```

If your program does not use argc/argv, you must still consume them to keep the
heap in a consistent state for the return code push:

```asm
CALL :heap_pop_word         # discard argc
CALL :heap_pop_word         # discard argv
```

---

## Returning an Exit Code

**Every program must push a 16-bit exit code to the heap before returning.**
The BIOS pops this value immediately after `CALL_D` returns.  The value is
currently ignored, but future versions of the OS will use it (e.g., for shell
conditionals or error reporting).  Failing to push a return code will corrupt
the heap pop and trigger the BIOS heap-underflow warning.

### C programs

Just `return` from `main()` with an integer:

```c
return 0;   // success
return 1;   // generic failure
```

The C compiler automatically pushes the return value to the heap at function
exit.

### Assembly programs

Push a 16-bit value before `RET`:

```asm
LDI_A 0x0000               # exit code 0 = success
CALL :heap_push_A
RET
```

### Exit code conventions (reserved for future use)

| Value | Meaning |
|-------|---------|
| 0x0000 | Success |
| 0x0001 | Generic failure |
| 0x00FF | Abnormal exit / caught error |

---

## Program Chaining

Any ODY executable - not just SYSTEM.ODY - can request the BIOS to run another
program after it exits.  The mechanism is identical: fill the IPC block and
return.

**After the chained program exits, the BIOS always returns to the default
behavior**: it checks the IPC block again.  If the chained program also set the
IPC block, the next program in the chain runs.  If not, SYSTEM.ODY restarts.
There is no way to "return" to the program that initiated the chain; control
always flows forward through the exec loop.

Typical chain:

```
SYSTEM.ODY → [exits, IPC set] → BIOS loads MYPROG.ODY
MYPROG.ODY → [exits, IPC clear] → BIOS loads SYSTEM.ODY
```

A program can also hand off to another program with its own argument list:

```
MYPROG.ODY → [exits, IPC set to VIEWER.ODY with args] → BIOS loads VIEWER.ODY
VIEWER.ODY → [exits, IPC clear] → BIOS loads SYSTEM.ODY
```

---

## Memory Ownership Summary

| Resource | Allocated by | Freed by |
|----------|-------------|----------|
| Program binary | BIOS exec loop | BIOS exec loop (after program returns) |
| `fat16_dirent` in IPC block | Program requesting exec | BIOS exec loop (after loading) |
| `argv` array (`$exec_argv_ptr`) | Program requesting exec | BIOS exec loop (after launched program returns) |
| `argv[i]` strings | Program requesting exec | BIOS exec loop (after launched program returns) |
| Any other malloc'd memory | Program | Program (before returning, or leak) |

The BIOS exec loop does **not** perform a general malloc audit between
iterations.  Memory that a program allocates and does not free is leaked until
the system is rebooted.

---

## BIOS Resilience Behavior

The exec loop is written to survive common program bugs:

- **Heap underflow/overflow**: after a program returns, the BIOS validates that
  `$heap_ptr >= 0xB000`.  If not, it prints a warning and calls `heap_init()`
  before continuing.  The return code pop may produce a garbage value, but the
  subsequent `heap_init()` at the top of the next iteration restores a clean
  state regardless.

- **Invalid IPC block**: `$exec_dirent_ptr` is range-checked against the malloc
  region (0x6000–0xAFFF) before use.  A value outside this range is treated as
  "no request", and the BIOS falls back to SYSTEM.ODY.

- **SYSTEM.ODY not found**: the BIOS prints an error and halts.  There is no
  recovery from a missing shell binary.

- **Program does not return** (e.g., `HLT`): the BIOS never regains control.
  The system is effectively halted.  This is expected behavior for fatal errors.
