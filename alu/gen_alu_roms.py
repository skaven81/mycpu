#!/usr/bin/env python3
import sys
from four_bit_alu import FourBitALU

alu_high = FourBitALU(high=True)
alu_low  = FourBitALU(high=False)

rom_high = [0 for i in range(0x8000)]
rom_low = [0 for i in range(0x8000)]

print("Generating ROM data")
for addr in range(0x8000):
    a =         (addr & 0b000000000001111) >> 0
    b =         (addr & 0b000000011110000) >> 4
    cin_lsb =   (addr & 0b000000100000000) >> 8
    cin_msb =   (addr & 0b000001000000000) >> 9
    op =        (addr & 0b111110000000000) >> 10
    assert 0x0 <= a <= 0xf
    assert 0x0 <= b <= 0xf
    assert 0 <= cin_lsb <= 1
    assert 0 <= cin_msb <= 1
    assert 0x0 <= op <= 0x1f
    alu_high.input = {
        "a": a,
        "b": b,
        "cin_msb": cin_msb,
        "cin_lsb": cin_lsb
    }
    alu_low.input = {
        "a": a,
        "b": b,
        "cin_msb": cin_msb,
        "cin_lsb": cin_lsb
    }
    alu_high.compute(op)
    alu_low.compute(op)

    rom_high[addr] = (alu_high.output["zero"] << 7) | \
                     (alu_high.output["equal"] << 6) | \
                     (alu_high.output["cout_msb"] << 5) | \
                     (alu_high.output["cout_lsb"] << 4) | \
                     alu_high.output["result"]
    assert 0x00 <= rom_high[addr] <= 0xff
    print("rom_high[{:04x}] = {:02x}".format(addr, rom_high[addr]))
    rom_low[addr] =  (alu_low.output["zero"] << 7) | \
                     (alu_low.output["equal"] << 6) | \
                     (alu_low.output["cout_msb"] << 5) | \
                     (alu_low.output["cout_lsb"] << 4) | \
                     alu_low.output["result"]
    assert 0x00 <= rom_low[addr] <= 0xff
    print("rom_low[{:04x}] =  {:02x}".format(addr, rom_low[addr]))

print("Writing alu_high.hex")
with open("alu_high.hex", mode='wb') as fh:
    fh.write(bytes(rom_high))

print("Writing alu_low.hex")
with open("alu_low.hex", mode='wb') as fh:
    fh.write(bytes(rom_low))

