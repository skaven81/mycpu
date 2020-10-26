#!/usr/bin/env python3
import sys
from eight_bit_alu import EightBitALU

alu = EightBitALU()

for op in range(0x20):
    print(f"\n8-bit op 0x{op:02x}")
    for cin in range(2):
        for a in range(0x100):
            for b in range(0x100):
                try:
                    result, overflow, equal, zero = alu.compute(op, a, b, cin)
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
                if(a == 0x8f and b == 0x92):
                    print(f"a={a:02x} b={b:02x} cin={cin} => {result:02x} o={overflow} e={equal} z={zero}")
                    print(f"a={a:08b} b={b:08b} cin={cin} => {result:08b} o={overflow} e={equal} z={zero}")
