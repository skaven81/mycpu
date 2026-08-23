/* readline flags byte (AH input to :readline) */
#define RL_ECHO      0x01   /* echo typed characters to the screen */
#define RL_KEYBOARD  0x02   /* accept input from the physical keyboard */
#define RL_UART      0x04   /* accept input from the UART (serial) link */

/* readline(buf, maxlen, flags) -> AH:AL packed as (status << 8) | length.
 * status: 0 = Enter, 1 = Ctrl+C abort. length: chars written to buf,
 * excluding the null terminator buf is always left null-terminated with.
 * maxlen counts the null terminator (buffer size, not max text length). */
extern uint16_t readline(char *buf, uint8_t maxlen, uint8_t flags);
