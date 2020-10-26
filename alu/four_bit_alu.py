# Pin mappings:
#
# ALU Input:
#   0-3: A (4 bits)
#   4-7: B (4 bits)
#     8: cin_lsb
#     9: cin_msb
# 10-14: op (5 bits)
#    15: unused
#
# ALU Output:
#   0-3: result (4 bits)
#     4: cout_lsb
#     5: cout_msb
#     6: A == B
#     7: result == 0

class FourBitALU():
    def __init__(self, high=False):
        self.high = high
        self.input = {
            "a": 0x0,
            "b": 0x0,
            "cin_lsb": 0b0,
            "cin_msb": 0b0,
        }
        self.output = {
            "result": 0x0,
            "cout_lsb": 0b0,
            "cout_msb": 0b0,
            "equal": 0b0,
            "zero": 0b0,
        }
    def compute(self, op):
        assert 0 <= self.input['a'] <= 0xf
        assert 0 <= self.input['b'] <= 0xf
        assert 0 <= self.input['cin_lsb'] <= 1
        assert 0 <= self.input['cin_msb'] <= 1
        assert 0 <= op <= 0x1f

        self.output['cout_lsb'] = 0b0
        self.output['cout_msb'] = 0b0
        self.output['zero'] = 0b0
        self.output['equal'] = 0b0

        ### Identity
        # 00: zero
        if op == 0x00:
            self.output['result'] = 0x0
        # 01: one
        if op == 0x01:
            if self.high:
                self.output['result'] = 0x0
            else:
                self.output['result'] = 0x1
        # 02: negative one: 0xff in 2's complement
        if op == 0x02:
            self.output['result'] = 0xf
        # 03: A + Cin_lsb (identity, or increment A if Cin_lsb is set)
        if op == 0x03:
            self.output['result']   = self.input['a'] + self.input['cin_lsb']
        # 04: B + Cin_lsb (identity, or increment B if Cin_lsb is set)
        if op == 0x04:
            self.output['result']   = self.input['b'] + self.input['cin_lsb']

        ### Arithmetic
        # 05: A + B + Cin_lsb
        if op == 0x05:
            self.output['result']   = self.input['a'] + self.input['b'] + self.input['cin_lsb']
        # 06: A - B - Cin_lsb
        # 07: B - A - Cin_lsb
        # 08: A - 1 - Cin_lsb
        # 09: B - 1 - Cin_lsb
        if 0x06 <= op <= 0x09:
            if op == 0x06 or op == 0x08:
                lhs = self.input['a']
                rhs = self.input['b']
            if op == 0x07 or op == 0x09:
                lhs = self.input['b']
                rhs = self.input['a']
            if op == 0x08 or op == 0x09:
                if self.high:
                    rhs = 0x0
                else:
                    rhs = 0x1

            # If the subtraction will result in a rollover,
            # set the cout_msb flag, which the high ALU will
            # see as cin_lsb, and note a carry operation.
            # If the high ALU sets cout_msb, that sets the
            # overflow flag, which is reasonable for noting
            # that the subtraction resulted in a rollover.
            if rhs > lhs:
                # flag the upstream ALU that a carry happened
                self.output['cout_msb'] = 1
                # apply the carry
                lhs += 0x10
            if self.input['cin_lsb'] == 1:
                # downstream signaled a carry for us, so lhs
                # needs to be decremented
                lhs -= 1
                if lhs < 0:
                    # rollover
                    lhs = lhs + 0x10
                    # set overflow
                    self.output['cout_msb'] = 1
            self.output['result'] = lhs - rhs
            if self.output['result'] < 0:
                # rollover
                self.output['result'] += 0x10
                # set overflow
                self.output['cout_msb'] = 1

        ### Display operation helpers (cursor + blink bit manipulation)
        # 0a: A 0x80 bit = Cin_msb (set/clear blink)
        if op == 0x0a:
            if self.high:
                if self.input['cin_lsb'] == 1:
                    self.output['result'] = (self.input['a'] | 0x8)
                else:
                    self.output['result'] = (self.input['a'] & ~0x8)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']
        # 0b: A 0x80 bit toggle (toggle blink)
        if op == 0x0b:
            if self.high:
                self.output['result'] = (self.input['a'] ^ 0x8)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']
        # 0c: A 0x40 bit = Cin_msb (set/clear cursor)
        if op == 0x0c:
            if self.high:
                if self.input['cin_lsb'] == 1:
                    self.output['result'] = (self.input['a'] | 0x4)
                else:
                    self.output['result'] = (self.input['a'] & ~0x4)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']
        # 0d: A 0x40 bit toggle (toggle cursor)
        if op == 0x0d:
            if self.high:
                self.output['result'] = (self.input['a'] ^ 0x4)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']
        # 0e: A 0xc0 bits = Cin_msb (set/clear blink+cursor)
        if op == 0x0e:
            if self.high:
                if self.input['cin_lsb'] == 1:
                    self.output['result'] = (self.input['a'] | 0xc)
                else:
                    self.output['result'] = (self.input['a'] & ~0xc)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']
        # 0f: A 0xc0 bits toggle (toggle blink+cursor)
        if op == 0x0f:
            if self.high:
                self.output['result'] = (self.input['a'] ^ 0xc)
            else:
                self.output['result'] = self.input['a']
                self.output['cout_msb'] = self.input['cin_lsb']

        ### Logic
        # 10: NOT A
        if op == 0x10:
            self.output['result'] = ~self.input['a']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 11: NOT B
        if op == 0x11:
            self.output['result'] = ~self.input['b']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 12: A AND B
        if op == 0x12:
            self.output['result'] = self.input['a'] & self.input['b']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 13: A OR B
        if op == 0x13:
            self.output['result'] = self.input['a'] | self.input['b']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 14: A XOR B
        if op == 0x14:
            self.output['result'] = self.input['a'] ^ self.input['b']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 15: A AND NOT B (for performing bit clear)
        if op == 0x15:
            self.output['result'] = self.input['a'] & ~self.input['b']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 16: B AND NOT A (for performing bit clear)
        if op == 0x16:
            self.output['result'] = self.input['b'] & ~self.input['a']
            if self.output['result'] < 0:
                self.output['result'] = (self.output['result'] + 2**4) & 0xf
        # 17: popcount(A) (but distributed across nybbles)
        if op == 0x17:
            count = 0
            mask = 0x1
            for idx in range(4):
                if self.input['a'] & mask:
                    count += 1
                mask = mask << 1
            self.output['result'] = count
        # 18: popcount(B) (but distributed across nybbles)
        if op == 0x18:
            count = 0
            mask = 0x1
            for idx in range(4):
                if self.input['b'] & mask:
                    count += 1
                mask = mask << 1
            self.output['result'] = count

        ### Logical shifting
        # 19: A << 1 (new LSB set by cin_lsb)
        if op == 0x19:
            self.output['result'] = (self.input['a'] << 1) + self.input['cin_lsb']
        # 1a: A >> 1 (new MSB set by cin_msb)
        if op == 0x1a:
            self.output['result'] = (self.input['a'] >> 1) + (self.input['cin_msb'] << 3)
            self.output['cout_lsb'] = (self.input['a'] & 0x1)
        # 1b: B << 1 (new LSB set by cin_lsb)
        if op == 0x1b:
            self.output['result'] = (self.input['b'] << 1) + self.input['cin_lsb']
        # 1c: B >> 1 (new MSB set by cin_msb)
        if op == 0x1c:
            self.output['result'] = (self.input['b'] >> 1) + (self.input['cin_msb'] << 3)
            self.output['cout_lsb'] = (self.input['b'] & 0x1)

        ### Arithmetic shifting (preserves MSB in high ALU)
        # 1d: A << 1
        if op == 0x1d:
            if self.high:
                a_val = self.input['a'] & 0x7
                a_sign = self.input['a'] & 0x8
                shifted = (a_val << 1) + self.input['cin_lsb']
                self.output['result'] = shifted & 0x7 | a_sign
                self.output['cout_msb'] = (shifted & 0x8) >> 3
            else:
                shifted = (self.input['a'] << 1) + self.input['cin_lsb']
                self.output['result'] = shifted & 0xf
                self.output['cout_msb'] = (shifted & 0x10) >> 4
        # 1e: A >> 1
        if op == 0x1e:
            if self.high:
                a_val = self.input['a'] & 0x7
                a_sign = self.input['a'] & 0x8
                shifted = (a_val >> 1) | (self.input['cin_msb'] << 3)
                self.output['result'] = shifted & 0x7 | a_sign
                self.output['cout_lsb'] = a_val & 0x1
            else:
                shifted = (self.input['a'] >> 1) | (self.input['cin_lsb'] << 4)
                self.output['result'] = shifted & 0xf
                self.output['cout_lsb'] = self.input['a'] & 0x1

        # 1f: undefined (zero)
        if op == 0x1f:
            self.output['result'] = 0x0
        
        # Normalize the result to four bits and set cout_msb if overflow
        if self.output['result'] > 0xf:
            self.output['cout_msb'] = 0b1
            self.output['result'] = self.output['result'] & 0xf

        # Zero flag
        if self.output['result'] == 0x0:
            self.output['zero'] = 0b1
        # Equal flag
        if self.input['a'] == self.input['b']:
            self.output['equal'] = 0b1

        assert 0 <= self.output['result'] <= 0xf
        assert 0 <= self.output['cout_lsb'] <= 1
        assert 0 <= self.output['cout_msb'] <= 1
        assert 0 <= self.output['zero'] <= 1
        assert 0 <= self.output['equal'] <= 1

