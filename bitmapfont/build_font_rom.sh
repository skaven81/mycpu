#!/bin/bash

FONTS=()

FONTS+=(int10h/FONTS/PC-IBM/CGA.F08)                 # slot 0 - IBM PC CGA
FONTS+=(int10h/FONTS/PC-IBM/CGA-TH.F08)              # slot 1 - IBM PC CGA - Thin
FONTS+=(int10h/FONTS/SYSTEM/CMPQDOS6/TH-CP437.F08)   # slot 2 - Compaq Thin
FONTS+=(int10h/FONTS/PC-IBM/PCCONV.F08)              # slot 3 - IBM PC Convertible
FONTS+=(int10h/FONTS/PC-OTHER/KPRO2K.F08)            # slot 4 - Kaypro 2000
FONTS+=(int10h/FONTS/PC-OTHER/TOSH-SAT.F08)          # slot 5 - Toshiba Satellite
FONTS+=(int10h/FONTS/PC-OTHER/EAGLE2.F08)            # slot 6 - Eagle Spirit CGA alt2 (sci-fi)
FONTS+=(int10h/FONTS/PC-OTHER/EAGLE3.F08)            # slot 7 - Eagle Spirit CGA alt3 (fantasy)
# repeated for future character/sprite glyph mods
FONTS+=(int10h/FONTS/PC-IBM/CGA.F08)                 # slot 8 - IBM PC CGA
FONTS+=(int10h/FONTS/PC-IBM/CGA-TH.F08)              # slot 9 - IBM PC CGA - Thin
FONTS+=(int10h/FONTS/SYSTEM/CMPQDOS6/TH-CP437.F08)   # slot a - Compaq Thin
FONTS+=(int10h/FONTS/PC-IBM/PCCONV.F08)              # slot b - IBM PC Convertible
FONTS+=(int10h/FONTS/PC-OTHER/KPRO2K.F08)            # slot c - Kaypro 2000
FONTS+=(int10h/FONTS/PC-OTHER/TOSH-SAT.F08)          # slot d - Toshiba Satellite
FONTS+=(int10h/FONTS/PC-OTHER/EAGLE2.F08)            # slot e - Eagle Spirit CGA alt2 (sci-fi)
FONTS+=(int10h/FONTS/PC-OTHER/EAGLE3.F08)            # slot f - Eagle Spirit CGA alt3 (fantasy)

set -x
cat ${FONTS[@]} > int10fonts.hex
