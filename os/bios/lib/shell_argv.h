// Get the nth argument string pointer from the shell's argv array.
// Input: AL = index n (0-based; 0 = command name).
// Returns: A = argv[n] string address, or 0x0000 if n >= argc.
// Only valid when called from a SYSTEM.ODY built-in command dispatched
// by :parse_and_run_command.
extern char *shell_get_argv_n(uint8_t n);
