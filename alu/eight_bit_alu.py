from four_bit_alu import FourBitALU

# To construct an 8-bit ALU from the four-bit ALUs:
#  * op is connected to both ALUs (bits 14-10)
#  * cin is connected to the high ALU's cin_msb (bit 9), and the low ALU's cin_lsb (bit 8)
#  * high ALU's cout_msb maps to overflow
#  * high ALU's cout_lsb maps to low ALU's cin_msb
#  * low ALU's cout_msb maps to high ALU's cin_lsb
#  * low ALU's cout_lsb is disconnected

class EightBitALU():
    def __init__(self):
        self.low = FourBitALU(high=False)
        self.high = FourBitALU(high=True)
    
    def compute(self, op, a, b, cin=0):
        self.high.input['a'] = (a & 0xf0) >> 4
        self.low.input['a']  = a & 0x0f
        self.high.input['b'] = (b & 0xf0) >> 4
        self.low.input['b']  = b & 0x0f

        # Set up cin input that goes to both msb on high ALU
        # and lsb on low ALU.
        self.low.input['cin_lsb'] = cin
        self.low.input['cin_msb'] = 0
        self.high.input['cin_lsb'] = 0
        self.high.input['cin_msb'] = cin

        # Run initial computation; the low ALU may have a cout_msb
        # that needs to feed to the high ALU's lsb, or the high ALU
        # may have a cout_lsb that needs to feed to the low ALU's msb.
        self.low.compute(op)
        self.high.compute(op)

        # Cross-feed the high and low bits
        self.low.input['cin_msb'] = self.high.output['cout_lsb']
        self.high.input['cin_lsb'] = self.low.output['cout_msb']

        # Recompute with the new values
        self.low.compute(op)
        self.high.compute(op)

        result = (self.high.output['result'] << 4) | self.low.output['result']
        overflow = self.high.output['cout_msb']
        equal = self.high.output['equal'] & self.low.output['equal']
        zero = self.high.output['zero'] & self.low.output['zero']

        return (result, overflow, equal, zero)

