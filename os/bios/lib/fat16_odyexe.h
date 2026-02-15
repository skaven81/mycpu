// Inspect a loaded binary to check if it's a valid ODY executable.
// Returns 0xff if not ODY; otherwise returns the ODY flag byte.
extern uint8_t fat16_inspect_ody(void *addr);

// Relocate an ODY executable loaded at addr.
// Rewrites addresses in the binary to be absolute based on load address.
// Returns pointer to first byte of the program (past the ODY header).
extern uint16_t fat16_localize_ody(void *addr);
