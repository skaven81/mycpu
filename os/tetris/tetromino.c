#include "tetromino.h"
#include <malloc.h>
#include <rand.h>

uint8_t color_lookup[7] = {
    0x3d, // O_TYPE yellow
    0x1a, // I_TYPE cyan
    0x26, // T_TYPE purple
    0x19, // S_TYPE green
    0x30, // Z_TYPE red
    0x16, // J_TYPE blue
    0x38  // L_TYPE orange
};

char type_char_lookup[7] = {
    'O',
    'I',
    'T',
    'S',
    'Z',
    'J',
    'L'
};


/* Indexed [(type << 2) | rot_idx][cell] -- the compiler supports at most 2
   array dimensions, so the type and rotation axes are flattened into one. */
coordinate_t tetrominoes[28][4] = {
    /* O_TYPE
       - - - -   - - - -   - - - -   - - - -
       - $ $ -   - $ $ -   - $ $ -   - $ $ -
       - $ $ -   - $ $ -   - $ $ -   - $ $ -
       - - - -   - - - -   - - - -   - - - -
    */
    { {1,1}, {2,1}, {1,2}, {2,2} },
    { {1,1}, {2,1}, {1,2}, {2,2} },
    { {1,1}, {2,1}, {1,2}, {2,2} },
    { {1,1}, {2,1}, {1,2}, {2,2} },

    /* I_TYPE
       - - - -   - - $ -   - - - -   - $ - -
       $ $ $ $   - - $ -   - - - -   - $ - -
       - - - -   - - $ -   $ $ $ $   - $ - -
       - - - -   - - $ -   - - - -   - $ - -
    */
    { {0,1}, {1,1}, {2,1}, {3,1} },
    { {2,0}, {2,1}, {2,2}, {2,3} },
    { {0,2}, {1,2}, {2,2}, {3,2} },
    { {1,0}, {1,1}, {1,2}, {1,3} },

    /* T_TYPE
       - $ - -   - $ - -   - - - -   - $ - -
       $ $ $ -   - $ $ -   $ $ $ -   $ $ - -
       - - - -   - $ - -   - $ - -   - $ - -
       - - - -   - - - -   - - - -   - - - -
    */
    { {1,0}, {0,1}, {1,1}, {2,1} },
    { {1,0}, {1,1}, {2,1}, {1,2} },
    { {0,1}, {1,1}, {2,1}, {1,2} },
    { {1,0}, {0,1}, {1,1}, {1,2} },

    /* S_TYPE
       - $ $ -   - $ - -   - - - -   $ - - -
       $ $ - -   - $ $ -   - $ $ -   $ $ - -
       - - - -   - - $ -   $ $ - -   - $ - -
       - - - -   - - - -   - - - -   - - - -
    */
    { {1,0}, {2,0}, {0,1}, {1,1} },
    { {1,0}, {1,1}, {2,1}, {2,2} },
    { {1,1}, {2,1}, {0,2}, {1,2} },
    { {0,0}, {0,1}, {1,1}, {1,2} },

    /* Z_TYPE
       $ $ - -   - - $ -   - - - -   - $ - -
       - $ $ -   - $ $ -   $ $ - -   $ $ - -
       - - - -   - $ - -   - $ $ -   $ - - -
       - - - -   - - - -   - - - -   - - - -
    */
    { {0,0}, {1,0}, {1,1}, {2,1} },
    { {2,0}, {1,1}, {2,1}, {1,2} },
    { {0,1}, {1,1}, {1,2}, {2,2} },
    { {1,0}, {0,1}, {1,1}, {0,2} },

    /* J_TYPE
       $ - - -   - $ $ -   - - - -   - $ - -
       $ $ $ -   - $ - -   $ $ $ -   - $ - -
       - - - -   - $ - -   - - $ -   $ $ - -
       - - - -   - - - -   - - - -   - - - -
    */
    { {0,0}, {0,1}, {1,1}, {2,1} },
    { {1,0}, {2,0}, {1,1}, {1,2} },
    { {0,1}, {1,1}, {2,1}, {2,2} },
    { {1,0}, {1,1}, {0,2}, {1,2} },

    /* L_TYPE
       - - $ -   - $ - -   - - - -   $ $ - -
       $ $ $ -   - $ - -   $ $ $ -   - $ - -
       - - - -   - $ $ -   $ - - -   - $ - -
       - - - -   - - - -   - - - -   - - - -
    */
    { {2,0}, {0,1}, {1,1}, {2,1} },
    { {1,0}, {1,1}, {1,2}, {2,2} },
    { {0,1}, {1,1}, {2,1}, {0,2} },
    { {0,0}, {1,0}, {1,1}, {1,2} }
};

uint8_t tetromino_bag[7];
uint8_t bag_idx = 255;

/* Spawns a new tetromino of the given type. Allocates
   memory for the struct and returns a pointer to it.
   The tetromino memory will need to be freed once it
   is locked. */
tetromino_t *spawn_tetromino(uint8_t type) {
    tetromino_t *new_tetromino;
    new_tetromino = (tetromino_t *)calloc_blocks(0); // 0->1 blocks = 16 bytes
    new_tetromino->position.x = 0;
    new_tetromino->position.y = 0;
    new_tetromino->type = type;
    new_tetromino->type_char = type_char_lookup[type];
    new_tetromino->color = color_lookup[type];
    new_tetromino->rot_id = 0;
    new_tetromino->type_idx = type << 2;
    return new_tetromino;
}

/* Fill a bag with randomly selected tetrominoes. Only
   one of each tetromino is placed in the bag. */
void fill_bag() {
    uint8_t tetromino_type;
    // start with bag full of sentinels
    for(tetromino_type = 0; tetromino_type <= 6; tetromino_type++) {
        tetromino_bag[tetromino_type] = 255;
    }
    for(tetromino_type = 0; tetromino_type <= 6; tetromino_type++) {
        // generate random number between 0 and 7 (0b111), but 7 is invalid
        // (6 is the highest index), and retry until we land on an empty slot.
        // Note || is bitwise and not short-circuiting in the Odyssey compiler;
        // that's fine here since both sides are 0/1, and the stray read of
        // tetromino_bag[7] when bag_idx is 7 is harmless.
        do {
            bag_idx = rand8() & 7;
        } while(bag_idx == 7 || tetromino_bag[bag_idx] != 255);
        tetromino_bag[bag_idx] = tetromino_type;
    }
    bag_idx = 6;
}

/* Draw a tetromino from the bag.  Returns null if the bag is empty */
tetromino_t *draw_tetromino() {
    tetromino_t *new_tetromino;
    if(bag_idx == 255) {
        return NULL;
    }
    new_tetromino = spawn_tetromino(tetromino_bag[bag_idx]);
    bag_idx--; // rolls over to 255 after zero
    return new_tetromino;
}

/* Rotate a tetromino. This only updates the rot_id and type_idx
   in the tetromino, it does not perform collision detection. */
void _rotate_tetromino_cw(tetromino_t *t) {
    t->rot_id = ((t->rot_id + 1) & 3);
    t->type_idx = (t->type << 2) | t->rot_id;
}
void _rotate_tetromino_ccw(tetromino_t *t) {
    t->rot_id = ((t->rot_id - 1) & 3);
    t->type_idx = (t->type << 2) | t->rot_id;
}

