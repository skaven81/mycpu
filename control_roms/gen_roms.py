#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

import binascii

class ControlSignal:
    @classmethod
    def match_header(cls, line):
        return bool(re.match("\(([a-zA-Z/]+)\)", line))

    def __init__(self, line):
        m = re.match("\(([a-zA-Z/]+)\)\s+([0-9]+)\s+([0-9]+)\s+0x([0-9a-fA-F]{2})", line)
        if m:
            self.signal = m.group(1)
            self.default = int(m.group(2))
            self.romid = int(m.group(3))
            self.mask = int(m.group(4), 16)
        else:
            raise SyntaxError("ERROR: {} line {} looks like a control signal, but does not match regex".format(fileinput.filename(), fileinput.filelineno()))

    def get_binmask(self):
        return bin(self.mask).lstrip('0b').zfill(8)

    def __str__(self):
        return "Signal {:6} default {} ROM {} mask 0x{:02x}/0b{:08b}".format(self.signal, self.default, self.romid, self.mask, self.mask)


class Macro:
    @classmethod
    def match_header(cls, line):
        return bool(re.match("\{(\S+)\}", line))

    def __init__(self, lines):
        header = lines.pop(0)
        m = re.match("\{(\S+)\}", header)
        if m:
            self.name = m.group(1)
        else:
            raise SyntaxError("ERROR: {} line {} looks like a macro, but does not match regex".format(fileinput.filename(), fileinput.filelineno()))
        self.signals = { }
        for signal in lines:
            signal, i, i = signal.partition('#') # strip comments
            signal = signal.rstrip()
            signal, i, val = signal.partition('=')
            if val:
                self.signals[signal] = int(val)
            else:
                self.signals[signal] = -1 # toggle

    def __str__(self):
        signal_str = [ ]
        for s in sorted(self.signals):
            if self.signals[s] == -1:
                signal_str.append(s)
            else:
                signal_str.append("{}={}".format(s, self.signals[s]))
        return "Macro {}: {}".format(self.name, " ".join(signal_str))

class Opcode:
    @classmethod
    def match_header(cls, line):
        return bool(re.match("\[(0x[0-9a-fA-F]{2})\]", line))

    def __init__(self, lines):
        header = lines.pop(0)
        m = re.match("\[(\S+)\]\s+(\S+)\s*(.*)", header)
        if m:
            self.code = int(m.group(1), 16)
            self.name = m.group(2)
            self.args = m.group(3).split(' ')
        else:
            raise SyntaxError("ERROR: {} line {} looks like an opcode, but does not match regex".format(fileinput.filename(), fileinput.filelineno()))
        self.micro_ops = [ ]
        for seq in lines:
            seq, i, i = seq.partition('#') # strip comments
            seq = seq.rstrip()
            if not seq:
                continue
            m = re.match("([xfFzZeE]+)\s+([0-9a-fA-F])\s+(.*)", seq)
            if m:
                uop = {
                    "sequence": int(m.group(2), 16),
                    "signals": set(m.group(3).split(' ')),
                    "zero": None,
                    "equal": None,
                    "over": None,
                }
                for f in m.group(1):
                    if f == 'x':
                        continue
                    elif f == 'z':
                        uop["zero"] = False
                    elif f == 'Z':
                        uop["zero"] = True
                    elif f == 'e':
                        uop["equal"] = False
                    elif f == 'E':
                        uop["equal"] = True
                    elif f == 'f':
                        uop["over"] = False
                    elif f == 'F':
                        uop["over"] = True
                self.micro_ops.append(uop)
            else:
                raise SyntaxError("ERROR: {} line {} looks like a micro-op, but does not match regex".format(fileinput.filename(), fileinput.filelineno()))

    @classmethod
    def flag_str(cls, uop):
        ret = ""
        if uop["zero"] is True:
            ret += "Z"
        if uop["zero"] is False:
            ret += "z"
        if uop["equal"] is True:
            ret += "E"
        if uop["equal"] is False:
            ret += "e"
        if uop["over"] is True:
            ret += "F"
        if uop["over"] is False:
            ret += "f"
        if len(ret) == 0:
            ret += "x"
        return ret

    def get_uop(self, sequence, zero, equal, over):
        for uop in self.micro_ops:
            if uop["sequence"] != sequence:
                continue
            if (uop["zero"] is True and not zero) or (uop["zero"] is False and zero):
                continue
            if (uop["equal"] is True and not equal) or (uop["equal"] is False and equal):
                continue
            if (uop["over"] is True and not over) or (uop["over"] is False and over):
                continue
            return uop

    def __str__(self):
        ret = "Opcode 0x{:02x}: {} {}".format(self.code, self.name, " ".join(self.args))
        for op in self.micro_ops:
            ret += "\n  {:>3} {:1x} {}".format(self.flag_str(op), op['sequence'], ' '.join(op['signals']))
        return ret

if __name__ == "__main__":
    import sys
    import fileinput
    import re

    # Read STDIN, or the file(s) specified on the command line, 
    # and create control signal, macro, and opcode objects
    control_signals = { }
    macros = { }
    opcodes = { }
    datain = fileinput.input()
    while True:
        try:
            line = next(datain)
        except StopIteration:
            break
        line, i, i = line.partition('#') # strip comments
        line = line.rstrip()
        if not line:
            continue

        #####
        # Control signal
        if ControlSignal.match_header(line):
            ctrl = ControlSignal(line)
            print(ctrl)
            control_signals[ctrl.signal] = ctrl

        #####
        # Macro
        if Macro.match_header(line):
            macro_lines = list()
            while True:
                macro_lines.append(line)
                try:
                    line = next(datain)
                except StopIteration:
                    break
                line = line.rstrip()
                if not line:
                    break
                line, i, i = line.partition('#') # strip comments
            macro = Macro(macro_lines)
            print(macro)
            macros[macro.name] = macro

        #####
        # Opcode
        if Opcode.match_header(line):
            opcode_lines = list()
            while True:
                opcode_lines.append(line)
                try:
                    line = next(datain)
                except StopIteration:
                    break
                line = line.rstrip()
                if not line:
                    break
                line, i, i = line.partition('#') # strip comments
            opcode = Opcode(opcode_lines)
            print(opcode)
            opcodes[opcode.code] = opcode

    #####
    # Data is loaded, now enumerate all 32k signal combinations
    for opcode_num in range(0, 3): #XXX 256 when ready
        if opcode_num in opcodes:
            opcode = opcodes[opcode_num]
        else:
            opcode = opcodes[0] # NOP by default
        print("### {} ###".format(opcode.name))
        print("  {:2} {:3} {:1} {:8} {:8}".format("OP", "F=0", "#", "ROM0","ROM1"))
        for flag_num in range(0, 8):
            flag_zero = bool(flag_num & 0b001)
            flag_equal = bool(flag_num & 0b010)
            flag_over = bool(flag_num & 0b100)
            for sequence_num in range(0, 16):
                uop = opcode.get_uop(sequence=sequence_num, zero=flag_zero, equal=flag_equal, over=flag_over)
                if uop:
                    print("0x{:02x} {:03b} {:1x} {:08b} {:08b} # {}".format(opcode_num, flag_num, sequence_num, 0, 0, uop['signals']))
