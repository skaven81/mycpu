#!/usr/bin/env python3

import sys
from eight_bit_alu import EightBitALU

alu = EightBitALU()

while(True):
    print("*** All inputs in hexadecimal ***")
    print("op (0 to exit):", end='')
    sys.stdout.flush()
    op = int(sys.stdin.readline(), 16)
    if(op <= 0):
        sys.exit()

    while(op > 0):
        try:
            print(f"**alu op 0x{op:02x}**")
            print("A: ", end='')
            sys.stdout.flush()
            a = int(sys.stdin.readline(), 16)
            print("B: ", end='')
            sys.stdout.flush()
            b = int(sys.stdin.readline(), 16)
            print("cin: ", end='')
            sys.stdout.flush()
            cin = int(sys.stdin.readline(), 16)

            result, overflow, equal, zero = alu.compute(op, a, b, cin)
            print(f"a={a:02x}       b={b:02x}       cin={cin} => {result:02x}       o={overflow} e={equal} z={zero}")
            print(f"a={a:08b} b={b:08b} cin={cin} => {result:08b}")

            assert 0 <= result <= 0xff
            assert 0 <= overflow <= 1
            if a == b:
                assert equal == 1
            else:
                assert equal == 0
            if result == 0:
                assert zero == 1
            else:
                assert zero == 0
        except AssertionError:
            print(f"Failure at op={op:02x} a={a:01x} b={b:01x} cin={cin}")
            raise
        except KeyboardInterrupt:
            op = 0

