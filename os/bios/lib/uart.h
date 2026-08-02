// Non-blocking read of one byte from the UART receive buffer. Returns
// 0x00 if the buffer was empty -- use uart_bufsize() first to tell an
// empty buffer apart from a genuine received 0x00 byte.
extern uint8_t uart_readbuf(void);

// Number of bytes currently in the UART receive buffer (0-255).
extern uint8_t uart_bufsize(void);

// Blocking write of one byte to the UART; waits for the transmit-complete
// flag before returning.
extern void uart_sendchar(uint8_t c);
