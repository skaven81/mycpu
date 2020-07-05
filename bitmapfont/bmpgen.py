#!/usr/bin/env python3

from PIL import Image
import numpy
from pprint import pprint
import struct

def mk_np_array(arr):
    rows = list()
    for r in arr:
        cols = list()
        for bit in r:
            cols.append(255 if bit else 0)
        rows.append(cols)
    
    return numpy.array(rows, dtype=numpy.uint8)


font = list()

# 0x00 NUL
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))

# 0x01 1  [white smiley]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))

# 0x02 2  [black smiley]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x03 3  [heart]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x04 4  [diamond]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x05 5  [clubs]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x06 6  [spade]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x07 7  [dot]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x08 8  [inverted dot]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x09 9  [circle]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0a 10 [inverted circle]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0b 11 [male]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0c 12 [female]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0d 13 [music note]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0e 14 [double music note]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x0f 15 [splat]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x10 16 [triangle pointing right]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x11 17 [triangle pointing left]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x12 18 [double vertical arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x13 19 [double exclamation point]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x14 20 [paragraph marker]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x15 21 [section marker]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x16 22 [heavy dash]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x17 23 [double vertical arrow, underlined]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x18 24 [up arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x19 25 [down arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1a 26 [right arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1b 27 [left arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1c 28 [tab marker]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1d 29 [double horizontal arrow]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1e 30 [triangle pointing up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x1f 31 [triangle pointing down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x20 32 [space]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x21 33 !
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x22 34 "
font.append(mk_np_array([
                map(int, "0 0 1 0 1 0 0 0".split(' ')),
                map(int, "0 0 1 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x23 35 #
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 1 1 1 1 1 1 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 1 1 1 1 1 1 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x24 36 $
font.append(mk_np_array([
                map(int, "0 0 0 1 0 1 0 0".split(' ')),
                map(int, "0 0 1 1 1 1 1 1".split(' ')),
                map(int, "0 1 0 1 0 1 0 0".split(' ')),
                map(int, "0 0 1 1 1 1 1 0".split(' ')),
                map(int, "0 0 0 1 0 1 0 1".split(' ')),
                map(int, "0 1 1 1 1 1 1 0".split(' ')),
                map(int, "0 0 0 1 0 1 0 0".split(' ')),
            ]))


# 0x25 37 %
font.append(mk_np_array([
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 1 0 1 0 0 1 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 1 0 0 1 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 1".split(' ')),
                map(int, "0 0 0 0 0 0 1 0".split(' ')),
            ]))


# 0x26 38 &
font.append(mk_np_array([
                map(int, "0 0 1 1 1 1 0 0".split(' ')),
                map(int, "0 1 0 0 0 0 1 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 1 0 0 0 0".split(' ')),
                map(int, "0 1 0 0 1 0 1 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 1 1 1 0 1".split(' ')),
            ]))


# 0x27 39 '
font.append(mk_np_array([
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x28 40 (
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 1 0".split(' ')),
                map(int, "0 0 0 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 1 0".split(' ')),
            ]))


# 0x29 41 )
font.append(mk_np_array([
                map(int, "0 1 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 1 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2a 42 *
font.append(mk_np_array([
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 1 0 1 0 1 0".split(' ')),
                map(int, "0 0 0 1 1 1 0 0".split(' ')),
                map(int, "0 0 0 1 1 1 0 0".split(' ')),
                map(int, "0 0 1 0 1 0 1 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2b 43 +
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 1 1 1 1 1 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2c 44 ,
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 0 0 0".split(' ')),
                map(int, "0 1 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2d 45 -
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 1 1 1 1 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2e 46 .
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 1 1 0 0 0 0 0".split(' ')),
                map(int, "0 1 1 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x2f 47 /
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x30 48 0
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x31 49 1
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x32 50 2
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x33 51 3
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x34 52 4
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x35 53 5
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x36 54 6
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x37 55 7
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x38 56 8
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x39 57 9
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3a 58 :
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3b 59 ;
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3c 60 <
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3d 61 =
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3e 62 >
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x3f 63 ?
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x40 64 @
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x41 65 A
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 1 1 0 0 0".split(' ')),
                map(int, "0 0 1 0 0 1 0 0".split(' ')),
                map(int, "0 1 1 1 1 1 1 0".split(' ')),
                map(int, "0 1 0 0 0 0 1 0".split(' ')),
                map(int, "0 1 0 0 0 0 1 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x42 66 B
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 1 1 1 1 0 0 0".split(' ')),
                map(int, "0 1 0 0 0 1 0 0".split(' ')),
                map(int, "0 1 1 1 1 0 0 0".split(' ')),
                map(int, "0 1 0 0 0 1 0 0".split(' ')),
                map(int, "0 1 1 1 1 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x43 67 C
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x44 68 D
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x45 69 E
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x46 70 F
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x47 71 G
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x48 72 H
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x49 73 I
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4a 74 J
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4b 75 K
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4c 76 L
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4d 77 M
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4e 78 N
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x4f 79 O
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x50 80 P
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x51 81 Q
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x52 82 R
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x53 83 S
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x54 84 T
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x55 85 U
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x56 86 V
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x57 87 W
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x58 88 X
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x59 89 Y
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5a 90 Z
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5b 91 [
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5c 92 \
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5d 93 ]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5e 94 ^
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x5f 95 _
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x60 96 `
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x61 97 a
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x62 98 b
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x63 99 c
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x64 100 d
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x65 101 e
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x66 102 f
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x67 103 g
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x68 104 h
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x69 105 i
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6a 106 j
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6b 107 k
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6c 108 l
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6d 109 m
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6e 110 n
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x6f 111 o
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x70 112 p
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x71 113 q
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x72 114 r
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x73 115 s
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x74 116 t
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x75 117 u
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x76 118 v
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x77 119 w
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x78 120 x
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x79 121 y
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7a 122 z
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7b 123 {
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7c 124 |
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7d 125 }
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7e 126 ~
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x7f 127 DEL
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))



# 0x80 128 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x81 129 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x82 130 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x83 131 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x84 132 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x85 133 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x86 134 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x87 135 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x88 136 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x89 137 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8a 138 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8b 139 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8c 140 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8d 141 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8e 142 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x8f 143 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x90 144 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x91 145 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x92 146 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x93 147 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x94 148 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x95 149 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x96 150 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x97 151 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x98 152 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x99 153 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9a 154 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9b 155 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9c 156 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9d 157 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9e 158 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0x9f 159 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa0 160 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa1 161 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa2 162 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa3 163 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa4 164 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa5 165 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa6 166 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa7 167 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa8 168 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xa9 169 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xaa 170 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xab 171 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xac 172 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xad 173 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xae 174 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xaf 175 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb0 176 [light shade]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb1 177 [medium shade]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb2 178 [dark shade]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb3 179 [box single vertical]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb4 180 [box single vertical + single left]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb5 181 [box single vertical + double left]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb6 182 [box double vertical + single left]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb7 183 [box single top right corner to double down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb8 184 [box double top right corner to single down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xb9 185 [box double vertical + double left]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xba 186 [box double vertical]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xbb 187 [box double top right corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xbc 188 [box double bot right corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xbd 189 [box single bot right corner to double up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xbe 190 [box double bot right corner to single up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xbf 191 [box single top right corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc0 192 [box single bot left corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc1 193 [box single horiz + single up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc2 194 [box single horiz + single down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc3 195 [box single vertical + single right]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc4 196 [box single horiz]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc5 197 [box single cross]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc6 198 [box single vertical + double right]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc7 199 [box double vertical + single right]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc8 200 [box double bot left corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xc9 201 [box double top right corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xca 202 [box double horiz + double up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xcb 203 [box double horiz + double down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xcc 204 [box double vertical + double right]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xcd 205 [box double horiz]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xce 206 [box double cross]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xcf 207 [box double horiz + single up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd0 208 [box single horiz + double up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd1 209 [box double horiz + single down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd2 210 [box single horiz + double down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd3 211 [box single bot left corner to single up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd4 212 [box double bot left corner to double up]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd5 213 [box double top left corner single down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd6 214 [box single top left corner to double down]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd7 215 [box double vertical + single horiz]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd8 216 [box single vertical + double horiz]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xd9 217 [box single bot right corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xda 218 [box single top left corner]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xdb 219 [full block]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xdc 220 [lower half block]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xdd 221 [left half block]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xde 222 [right half block]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xdf 223 [upper half block]
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe0 224 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe1 225 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe2 226 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe3 227 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe4 228 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe5 229 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe6 230 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe7 231 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe8 232 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xe9 233 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xea 234 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xeb 235 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xec 236 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xed 237 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xee 238 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xef 239 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf0 240 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf1 241 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf2 242 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf3 243 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf4 244 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf5 245 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf6 246 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf7 247 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf8 248 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xf9 249 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xfa 250 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xfb 251 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xfc 252 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xfd 253 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))


# 0xfe 254 
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))

# 0xff 255
font.append(mk_np_array([
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
                map(int, "0 0 0 0 0 0 0 0".split(' ')),
            ]))

# 16x16 grid of characters
graph = Image.new(mode='L', size=(128, 128))

row = 0
col = 0
for chararr in font:
    char = Image.fromarray(chararr, mode='L')
    graph.paste(char, (col, row))
    col = col + 8
    if col >= 128:
        col = 0
        row = row + 8

graph.convert('1').resize((1024,1024)).convert('RGB').show()
