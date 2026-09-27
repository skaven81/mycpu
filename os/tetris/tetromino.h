#pragma once

#include <types.h>

#define O_TYPE 0
#define I_TYPE 1
#define T_TYPE 2
#define S_TYPE 3
#define Z_TYPE 4
#define J_TYPE 5
#define L_TYPE 6

typedef struct {
    uint8_t x;
    uint8_t y;
} coordinate_t;

typedef struct {
    coordinate_t position;
    uint8_t type;
    uint8_t type_idx;
    char type_char;
    uint8_t rot_id;
    uint8_t color;
} tetromino_t;

tetromino_t *spawn_tetromino(uint8_t type);

void fill_bag(void);
tetromino_t *draw_tetromino(void);

void _rotate_tetromino_cw(tetromino_t *t);
void _rotate_tetromino_ccw(tetromino_t *t);
