#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

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

    def get_masked_value(self, val):
        """
        The mask should be all zeroes with some contiguous ones
        inside.  The number of zeroes to the right of the ones
        is how many times the value needs to be shifted left.

        mask = 0b00111000

        Three zeroes to the right of the ones, so shift the value
        left three times:

        1 << 3 => 0b00001000
        2 << 3 => 0b00010000
        3 << 3 => 0b00011000
        """
        shift = 7 - self.get_binmask().rfind('1')
        return val << shift

    def __str__(self):
        return "Signal {:6} default {}/0b{:08b} ROM {} mask 0x{:02x}/0b{:08b}".format(self.signal, self.default, self.get_masked_value(self.default), self.romid, self.mask, self.mask)

class RomByte:
    def __init__(self, id):
        self.id = id
        self.signals = dict()

    def add_signal(self, signal):
        if signal.romid != self.id:
            raise ValueError("ERROR: Cannot add signal for ROM ID {} to RomByte with ID {}".format(signal.romid, self.id))
        self.signals[signal.signal] = signal

    def get_default_byte(self):
        byte = 0
        for s in self.signals.values():
            byte = byte | s.get_masked_value(s.default)
        return byte

    def get_byte(self, override_signals):
        byte = self.get_default_byte()
        for override_signal_name, override_signal_value in override_signals.items():
            if override_signal_name not in self.signals:
                raise SyntaxError("ERROR: Attempt to assert undefined signal {} in ROM {}".format(override_signal_name, self.id))
            if override_signal_value == -1:
                # This only works for Boolean values
                if self.signals[override_signal_name].get_binmask().count("1") != 1:
                    raise SyntaxError("ERROR: attempt to use toggle for multi-bit signal {} in ROM {}".format(override_signal_name, self.id))
                # toggle the default
                if self.signals[override_signal_name].default == 0:
                    byte = byte | self.signals[override_signal_name].get_masked_value(1)
                else:
                    byte = byte & ~self.signals[override_signal_name].get_masked_value(1)
            else:
                # reset the signal's bits
                byte = byte & (~self.signals[override_signal_name].mask)
                # set the new value
                byte = byte | (self.signals[override_signal_name].get_masked_value(override_signal_value))
        return byte

    def __str__(self):
        ret = "RomByte {}: default ".format(self.id)
        ret += "0b{:08b}".format(self.get_default_byte())
        ret += " "
        ret += " ".join(["{}={}".format(s.signal, s.default) for s in self.signals.values()])
        return ret

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
            if not signal:
                continue
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
                    "macros": set(m.group(3).split(' ')),
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
        matches = [ ]
        for uop in self.micro_ops:
            if uop["sequence"] != sequence:
                continue
            if (uop["zero"] is True and not zero) or (uop["zero"] is False and zero):
                continue
            if (uop["equal"] is True and not equal) or (uop["equal"] is False and equal):
                continue
            if (uop["over"] is True and not over) or (uop["over"] is False and over):
                continue
            matches.append(uop)
        if len(matches) > 1:
            raise SyntaxError("ERROR: Opcode {} has multiple uops that match sequence {} with flags {}".format(self.name, sequence, self.flag_str(matches[0])))
        elif len(matches) == 1:
            return matches[0]
        else:
            return None

    def __str__(self):
        ret = "Opcode 0x{:02x}: {} {}".format(self.code, self.name, " ".join(self.args))
        for op in self.micro_ops:
            ret += "\n  {:>3} {:1x} {}".format(self.flag_str(op), op['sequence'], ' '.join(op['macros']))
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
    # Create a mapping between macros and signals
    macro_map = { }
    for m in macros.values():
        macro_map[m.name] = { }
        for signal_name, signal_value in m.signals.items():
            if signal_name not in control_signals:
                raise SyntaxError("ERROR: Macro {} refers to undefined signal {}".format(m.name, signal_name))
            macro_map[m.name][signal_name] = signal_value

    #####
    # Instantiate our RomByte objects
    rombytes = [ RomByte(0), RomByte(1) ]
    for signal in control_signals.values():
        rombytes[signal.romid].add_signal(signal)
    for r in rombytes:
        print(r)

    #####
    # Final data for each ROM
    roms = [ list() for i in rombytes ]

    #####
    # Enumerate all 32k input signal combinations
    for opcode_num in range(0, 256):
        if opcode_num in opcodes:
            opcode = opcodes[opcode_num]
        else:
            opcode = opcodes[0] # NOP by default
        if((opcode.name == "NOP" and opcode_num == 0) or (opcode.name != "NOP")):
            print("### {} ###".format(opcode.name))
            print("  {:2} {:3} {:1} {:8} {:8}".format("OP", "F=0", "#", "ROM0","ROM1"))
        found_uops = dict()
        for flag_num in range(0, 8):
            flag_zero = bool(flag_num & 0b001)
            flag_equal = bool(flag_num & 0b010)
            flag_over = bool(flag_num & 0b100)
            for sequence_num in range(0, 16):
                # get_uop will raise an exception if multiple uops match this combination
                uop = opcode.get_uop(sequence=sequence_num, zero=flag_zero, equal=flag_equal, over=flag_over)
                op_signals = [ dict() for i in rombytes ]
                if uop:
                    found_uops[sequence_num] = True
                    for m in uop['macros']:
                        if m not in macro_map:
                            raise SyntaxError("ERROR: micro-op uses macro {} that does not exist".format(s))
                        for signal_name, signal_value in macro_map[m].items():
                            signal = control_signals[signal_name]
                            op_signals[signal.romid][signal_name] = signal_value
                    if((opcode.name == "NOP" and opcode_num == 0) or (opcode.name != "NOP")):
                        print("0x{:02x} {:03b} {:1x} {:08b} {:08b} # {} => {}".format(opcode_num, flag_num, sequence_num,
                                rombytes[0].get_byte(op_signals[0]), rombytes[1].get_byte(op_signals[1]),
                                uop['macros'], op_signals))
                for romidx in range(0, len(rombytes)):
                    roms[romidx].append(rombytes[romidx].get_byte(op_signals[romidx]))
        # Sanity check that every opcode has contiguous
        # sequence numbers, without any skipped codes
        expected_seq = 0
        for found_seq_num in sorted([ *found_uops.keys() ]):
            if found_seq_num != expected_seq:
                raise SyntaxError("ERROR: Missing sequence number {} in opcode {}".format(expected_seq, opcode.name))
            expected_seq += 1

    # Sanity check that we computed all 32k combinations
    for romidx in range(0, len(roms)):
        if(len(roms[romidx]) != 32768):
            raise ValueError("ROM {} has length other than 32k".format(romidx))

    # Write hex files
    for romidx in range(0, len(roms)):
        filename = "control_rom_{}.hex".format(romidx)
        print("Writing {}".format(filename))
        with open(filename, mode='wb') as fh:
            fh.write(bytes(roms[romidx]))

