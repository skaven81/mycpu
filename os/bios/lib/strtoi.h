#include "types.h"

// Convert null-terminated string to a 16-bit signed integer.
// Auto-detects base: "0x..." = hex, "-N" = signed decimal, "N" = unsigned decimal.
// Negative decimal inputs ("-N") are returned as 2's complement.
// Returns the converted value, or 0x0000 on failure.
// If flags is non-NULL, writes the status code: 0x00=success, 0x01=overflow,
// 0x02=invalid character, 0x04=empty string.
extern int16_t strtoi(char *str, uint8_t *flags);

// Convert null-terminated string to an 8-bit signed integer.
// Same base auto-detection as strtoi. Negative decimal inputs are returned as 2's complement.
// Returns 0x00 on failure.
// If flags is non-NULL, writes the same status codes as strtoi.
extern int8_t strtoi8(char *str, uint8_t *flags);
