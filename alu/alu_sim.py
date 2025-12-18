#!/usr/bin/env python3
import sys
import math
from eight_bit_alu import EightBitALU

alu = EightBitALU()

def signed(byte):
    return byte if byte < 128 else byte - 256

for op in range(0x20):
   print(f"8-bit op 0x{op:02x}")
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

                    if op == 0x00: # zero
                        assert result == 0
                        assert overflow == 0
                    elif op == 0x01: # one
                        assert result == 1
                        assert overflow == 0
                    elif op == 0x02: # -1
                        assert result == 0xff
                        assert overflow == 0
                    elif op == 0x03: # A + cin
                        assert result == (a + cin) & 0xff
                        assert overflow == (0 if a+cin<256 else 1)
                    elif op == 0x04: # B + cin
                        assert result == (b + cin) & 0xff
                        assert overflow == (0 if b+cin<256 else 1)
                    elif op == 0x05: # A+B+cin unsigned
                        assert result == (a + b + cin) & 0xff
                        assert overflow == (1 if a+b+cin>255 else 0)
                    elif op == 0x06: # A-B-cin unsigned
                        assert result == (a - b - cin) & 0xff
                        assert overflow == (1 if a-b-cin<0 else 0)
                    elif op == 0x07: # B-A-cin unsigned
                        assert result == (b - a - cin) & 0xff
                        assert overflow == (1 if b-a-cin<0 else 0)
                    elif op == 0x08: # A-1-cin unsigned
                        assert result == (a - 1 - cin) & 0xff
                        assert overflow == (1 if a-1-cin<0 else 0)
                    elif op == 0x09: # B-1-cin unsigned
                        assert result == (b - 1 - cin) & 0xff
                        assert overflow == (1 if b-1-cin<0 else 0)
                    elif op == 0x0a: # set/clear Amsb
                        if cin:
                            assert (result & 0x80) == 0x80
                            assert result == (a | 0x80)
                        else:
                            assert (result & 0x80) == 0x00
                            assert result == (a & 0x7f)
                        assert overflow == 0
                    if op == 0x0b: # A+B signed
                        expected_result = signed(b) + signed(a) + cin
                        if expected_result < -128 or expected_result > 127:
                            assert overflow == 1
                        else:
                            assert overflow == 0
                            assert expected_result == signed(result)
                    elif op == 0x0c: # A-B signed
                        expected_result = signed(a) - signed(b) - cin
                        if expected_result < -128 or expected_result > 127:
                            assert overflow == 1
                        else:
                            assert expected_result == signed(result)
                            assert overflow == 0
                    elif op == 0x0d: # B-A signed
                        expected_result = signed(b) - signed(a) - cin
                        if expected_result < -128 or expected_result > 127:
                            assert overflow == 1
                        else:
                            assert expected_result == signed(result)
                            assert overflow == 0
                    elif op == 0x0e: # -A signed
                        expected_result = -1 * signed(a)
                        if expected_result < -128 or expected_result > 127:
                            assert overflow == 1
                        else:
                            assert expected_result == signed(result)
                            assert overflow == 0
                    elif op == 0x0f: # -B signed
                        expected_result = -1 * signed(b)
                        if expected_result < -128 or expected_result > 127:
                            assert overflow == 1
                        else:
                            assert expected_result == signed(result)
                            assert overflow == 0
                    elif op == 0x10: # ~A
                        assert result == (~a & 0xff)
                        assert overflow == 0
                    elif op == 0x11: # ~B
                        assert result == (~b & 0xff)
                        assert overflow == 0
                    elif op == 0x12: # A&B
                        assert result == (a&b) & 0xff
                        assert overflow == 0
                    elif op == 0x13: # A|B
                        assert result == (a|b) & 0xff
                        assert overflow == 0
                    elif op == 0x14: # A^B
                        assert result == (a^b) & 0xff
                        assert overflow == 0
                    elif op == 0x15: # A&~B
                        assert result == (a&~b) & 0xff
                        assert overflow == 0
                    elif op == 0x16: # B&~A
                        assert result == (b&~a) & 0xff
                        assert overflow == 0
                    elif op == 0x17: # Amsb
                        expected_result = a & 0x80
                        assert expected_result == result
                        assert overflow == 0
                    elif op == 0x18: # Bmsb
                        expected_result = b & 0x80
                        assert expected_result == result
                        assert overflow == 0
                    elif op == 0x19: # A<<1 + cin
                        expected = ((a&0xff) << 1) + cin
                        assert result == expected & 0xff
                        assert overflow == (1 if expected > 255 else 0)
                    elif op == 0x1a: # A>>1
                        expected = ((a&0xfe) >> 1) | (0x80 if cin else 0x00)
                        assert result == expected
                        assert overflow == 0
                    elif op == 0x1b: # B<<1 + cin
                        expected = ((b&0xff) << 1) + cin
                        assert result == expected & 0xff
                        assert overflow == (1 if expected > 255 else 0)
                    elif op == 0x1c: # B>>1
                        expected = ((b&0xfe) >> 1) | (0x80 if cin else 0x00)
                        assert result == expected
                        assert overflow == 0
                    elif op == 0x1d: # A*2+cin (signed)
                        if -64 <= signed(a) < 0:
                            assert signed(result) == (abs(signed(a)) * -2) + cin
                            assert overflow == 0
                        elif 0 <= signed(a) <= 63:
                            assert signed(result) == (abs(signed(a)) * 2) + cin
                            assert overflow == 0
                        else:
                            assert overflow == 1
                    elif op == 0x1e: # A/2 (signed)
                        assert signed(result) == math.floor(signed(a) / 2)
                        assert overflow == 0
                    elif op == 0x1f: # Amsb ^ Bmsb
                        expected_result = (a & 0x80) ^ (b & 0x80)
                        assert expected_result == result
                        assert overflow == 0

                except AssertionError:
                    print(f"Failure at op=0x{op:02x} a=0x{a:02x} b=0x{b:02x} cin={cin}: result=0x{result:x} o={overflow} e={equal} z={zero}")
                    print(f"           Signed: a={signed(a)} b={signed(b)} cin={cin}: result={signed(result)} o={overflow} e={equal} z={zero}")
                    raise
