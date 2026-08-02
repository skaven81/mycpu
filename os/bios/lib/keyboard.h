// Key-release flag bit, in the high byte of kb_readbuf()'s return value.
#define KB_KEYFLAG_BREAK 0x01

// Non-blocking read of one keyboard event. Returns a 16-bit value with
// the key flags in the high byte and the character in the low byte
// (0x0000 if the keyboard buffer was empty). KB_KEYFLAG_BREAK in the high
// byte marks a key-release event.
extern uint16_t kb_readbuf(void);
