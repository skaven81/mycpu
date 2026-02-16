// Compare two strings. Returns negative if s1 < s2, positive if s1 > s2, zero if equal.
extern int8_t strcmp(char *s1, char *s2);

// Copy string from src to dest (until null). Does not write terminating null.
extern void strcpy(char *src, char *dest);

// Uppercase string from src to dest. Supports in-place (src == dest).
extern void strupper(char *src, char *dest);

// Prepend character ch at the beginning of string at str, shifting existing chars right.
extern void strprepend(char ch, char *str);

// Split string str on split_char. Allocates alloc_size blocks per token.
// Stores token pointers in array (null-terminated). Returns token count.
extern uint8_t strsplit(char split_char, uint8_t alloc_size, char *str, uint16_t *array);
