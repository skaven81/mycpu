#!/usr/bin/env python3

import sys
from four_bit_alu import FourBitALU

alu = FourBitALU(high=True)

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
            print("cinMSB: ", end='')
            sys.stdout.flush()
            cin_msb = int(sys.stdin.readline(), 16)
            print("cinLSB: ", end='')
            sys.stdout.flush()
            cin_lsb = int(sys.stdin.readline(), 16)

            alu.input['a'] = a
            alu.input['b'] = b
            alu.input['cin_lsb'] = cin_lsb
            alu.input['cin_msb'] = cin_msb

            alu.compute(op)
            print(f"a={a:01x}    b={b:01x}    cin_lsb={cin_lsb} cin_msb={cin_msb} => {alu.output['result']:01x}       cout_msb={alu.output['cout_msb']} cout_lsb={alu.output['cout_lsb']} e={alu.output['equal']} z={alu.output['zero']}")
            print(f"a={a:04b} b={b:04b} cin_lsb={cin_lsb} cin_msb={cin_msb} => {alu.output['result']:04b}")

        except KeyboardInterrupt:
            op = 0

