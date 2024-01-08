uint8_t scancode_to_ascii[] = {
    0x00, //                0x00
    0x00, //                0x01
    0x00, //                0x02
    0x00, //                0x03
    0x00, //                0x04
    0x00, //                0x05
    0x00, //                0x06
    '1',  // SC3_f1         tx07
    0x1b, // SC3_escape     0x08
    0x00, //                0x09
    0x00, //                0x0a
    0x00, //                0x0b
    0x00, //                0x0c
    0x09, // SC3_tab        0x0d
    '`',  // SC3_openQuote  0x0e
    '2',  // SC3_f2         0x0f
    0x00, //                0x10
    0x00, // SC3_leftCtrl   0x11
    0x00, // SC3_leftShift  0x12
    0x00, //                0x13
    0x00, // SC3_capsLock   0x14
    'q',  // SC3_q          0x15
    '1',  // SC3_1          0x16
    '3',  // SC3_f3         0x17
    0x00, //                0x18
    0x00, // SC3_leftAlt    0x19
    'z',  // SC3_z          0x1a
    's',  // SC3_s          0x1b
    'a',  // SC3_a          0x1c
    'w',  // SC3_w          0x1d
    '2',  // SC3_2          0x1e
    '4',  // SC3_f4         0x1f
    0x00, //                0x20
    'c',  // SC3_c          0x21
    'x',  // SC3_x          0x22
    'd',  // SC3_d          0x23
    'e',  // SC3_e          0x24
    '4',  // SC3_4          0x25
    '3',  // SC3_3          0x26
    '5',  // SC3_f5         0x27
    0x00, //                0x28
    ' ',  // SC3_space      0x29
    'v',  // SC3_v          0x2a
    'f',  // SC3_f          0x2b
    't',  // SC3_t          0x2c
    'r',  // SC3_r          0x2d
    '5',  // SC3_5          0x2e
    '6',  // SC3_f6         0x2f
    0x00, //                0x30
    'n',  // SC3_n          0x31
    'b',  // SC3_b          0x32
    'h',  // SC3_h          0x33
    'g',  // SC3_g          0x34
    'y',  // SC3_y          0x35
    '6',  // SC3_6          0x36
    '7',  // SC3_f7         0x37
    0x00, //                0x38
    0x00, // SC3_rightAlt   0x39
    'm',  // SC3_m          0x3a
    'j',  // SC3_j          0x3b
    'u',  // SC3_u          0x3c
    '7',  // SC3_7          0x3d
    '8',  // SC3_8          0x3e
    '8',  // SC3_f8         0x3f
    0x00, //                0x40
    ',',  // SC3_comma      0x41
    'k',  // SC3_k          0x42
    'i',  // SC3_i          0x43
    'o',  // SC3_o          0x44
    '0',  // SC3_0          0x45
    '9',  // SC3_9          0x46
    '9',  // SC3_f9         0x47
    0x00, //                0x48
    '.',  // SC3_period     0x49
    '/',  // SC3_slash      0x4a
    'l',  // SC3_l          0x4b
    ';',  // SC3_semicolon  0x4c
    'p',  // SC3_p          0x4d
    '-',  // SC3_dash       0x4e
    '0',  // SC3_f10        0x4f
    0x00, //                0x50
    0x00, //                0x51
    0x27, // SC3_apostrophe 0x52
    0x00, //                0x53
    '[',  // SC3_openSquareBracket   0x54
    '=',  // SC3_equal      0x55
    '!',  // SC3_f11        0x56
    0x17, // SC3_printScreen 0x57
    0x00, // SC3_rightCtrl  0x58
    0x00, // SC3_rightShift  0x59
    0x0d, // SC3_enter      0x5a
    ']',  // SC3_closeSquareBracket   0x5b
    0x5c, // SC3_backslash  0x5c
    0x00, //                0x5d
    '@',  // SC3_f12        0x5e
    0x00, // SC3_scrollLock    0x5f
    0x11, // SC3_downArrow  0x60
    0x13, // SC3_leftArrow  0x61
    0x10, // SC3_pause      0x62
    0x12, // SC3_upArrow    0x63
    0x7f, // SC3_delete     0x64
    0x1e, // SC3_end        0x65
    0x08, // SC3_backspace  0x66
    0x0f, // SC3_insert     0x67
    0x00, //                0x68
    0x1e, // SC3_keypad1    0x69 (end)
    0x14, // SC3_rightArrow 0x6a
    0x13, // SC3_keypad4    0x6b (left arrow)
    0x02, // SC3_keypad7    0x6c (home)
    0x0c, // SC3_pageDown   0x6d
    0x02, // SC3_home       0x6e
    0x0b, // SC3_pageUp     0x6f
    0x0f, // SC3_keypad0    0x70 (insert)
    0x7f, // SC3_keypadPeriod 0x71 (del)
    0x11, // SC3_keypad2    0x72 (down arrow)
    '5',  // SC3_keypad5    0x73
    0x14, // SC3_keypad6    0x74 (right arrow)
    0x18, // SC3_keypad8    0x75 (up arrow)
    0x00, // SC3_numLock    0x76
    '/',  // SC3_keypadSlash 0x77
    0x00, //                0x78
    0x0d, // SC3_keypadEnter 0x79
    0x0c, // SC3_keypad3    0x7a (page down)
    0x00, //                0x7b
    '+',  // SC3_keypadPlus 0x7c
    0x0b, // SC3_keypad9    0x7d (page up)
    '*',  // SC3_keypadAsterisk   0x7e
    0x00, //                0x7f
    0x00, //                0x80
    0x00, //                0x81
    0x00, //                0x82
    0x00, //                0x83
    '-',  // keypadDash     0x84
    0x00, //                0x85
    0x00, //                0x86
    0x00, //                0x87
    0x00, //                0x88
    0x00, //                0x89
    0x00, //                0x8a
    0x03, // SC3_leftGui    0x8b
    0x03, // SC3_rightGui   0x8c
    0x04, // SC3_menu       0x8d
    0x00, //                0x8e
    0x00, //                0x8f
};

