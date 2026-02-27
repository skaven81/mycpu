// Allocate a 4 KiB extended memory page.
// Returns page number (1-255), or 0 if extended memory is full.
// No inputs. Result byte pushed to heap; handler pops it into return register.
extern uint8_t extmalloc(void);

// Free an extended memory page previously returned by extmalloc().
// Push page number (byte) to heap before calling.
extern void extfree(uint8_t page);

// Map a page into the D-window (0xD000-0xDFFF), saving the previous mapping.
// Push page number (byte) to heap before calling.
extern void extpage_d_push(uint8_t page);

// Restore the previous D-window mapping (undo extpage_d_push).
// No inputs. Returns the page number that was popped off the mapping stack.
extern uint8_t extpage_d_pop(void);

// Map a page into the E-window (0xE000-0xEFFF), saving the previous mapping.
// Push page number (byte) to heap before calling.
extern void extpage_e_push(uint8_t page);

// Restore the previous E-window mapping (undo extpage_e_push).
// No inputs. Returns the page number that was popped off the mapping stack.
extern uint8_t extpage_e_pop(void);
