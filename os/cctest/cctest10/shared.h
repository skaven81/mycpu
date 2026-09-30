// Globals shared between main.c and globals.c.  Both files include this, so
// globals.c also exercises the header pattern: extern declaration first,
// then the definition in the same file.
#ifndef CCTEST10_SHARED_H
#define CCTEST10_SHARED_H

#include "types.h"

struct Pair { uint8_t a; uint16_t b; };

extern uint16_t shared_word;
extern uint8_t  shared_byte;
extern uint8_t  shared_arr[4];
extern struct Pair shared_pair;
extern char    *shared_msg;
extern uint16_t shared_uninit;

uint16_t globals_get_word(void);
void     globals_set_word(uint16_t v);
uint16_t globals_arr_sum(void);
uint8_t  globals_get_file_local(void);
uint8_t  globals_bump_counter(void);

#endif
