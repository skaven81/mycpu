#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

from gen_roms import Opcode
import fileinput
import re
import argparse
import logging
from pyparsing import Word, alphanums, nums, Regex, Literal, QuotedString, Or, And, Char, srange, printables, Optional, Combine, Group, StringStart, OneOrMore, oneOf
from pyparsing.exceptions import ParseException

parser = argparse.ArgumentParser(description='Assemble program ROM')
parser.add_argument('--opcodes', default='opcodes', help='File containing opcodes')
parser.add_argument('--verbose', '-v', action='count', default=0)
parser.add_argument('--macros', '-m', action='append', default=['asm_macros'])
parser.add_argument('source', help='Assembly source code')
parser.add_argument('output', help='Output .hex file, or - for STDOUT')
args = parser.parse_args()

if args.verbose == 0:
    logging.basicConfig(level=getattr(logging, 'WARNING'))
elif args.verbose == 1:
    logging.basicConfig(level=getattr(logging, 'INFO'))
elif args.verbose >= 2:
    logging.basicConfig(level=getattr(logging, 'DEBUG'))

logging.debug(args)

def twos_comp(val, bits):
    if (val & (1 << (bits - 1))) != 0:
        val = val - (1 << bits)
    return val

# Read the opcode data so we can parse the assembly
opcodes = { }
with open(args.opcodes, 'r') as fh:
    logging.info("Reading {} for opcodes".format(args.opcodes))
    while True:
        line = fh.readline()
        if not line:
            break
        line, i, i = line.partition('#') # strip comments
        line = line.rstrip()
        if not line:
            continue

        if Opcode.match_header(line):
            opcode_lines = list()
            while True:
                opcode_lines.append(line)
                line = fh.readline().rstrip()
                if not line:
                    break
                line, i, i = line.partition('#') # strip comments
            opcode = Opcode(opcode_lines)
            logging.debug(str(opcode).split('\n')[0])
            opcodes[opcode.name] = opcode

# Read any macros
asm_macros = { }
for macro_file in args.macros:
    logging.info("Reading {} for assembly macros".format(macro_file))
    with open(macro_file) as fh:
        while True:
            line = fh.readline()
            if not line:
                break
            line, i, i = line.partition('#') # strip comments
            line = line.rstrip()
            if not line:
                continue

            macro, value = line.split(maxsplit=1)
            asm_macros[macro] = value
            logging.debug("ASM Macro {} = {}".format(macro, value))

#####
# Generate the assembly parser based on the available opcodes
#####
# Hash-style comments
comment = Regex('#.*')
# Labels at the beginning of the line mark addresses, or can be used
# in places where a 16-bit word argument is required.
label = Word(".", alphanums+"_")
label.setName('label')
labeloffset = Word(".", alphanums+"_-+")
labeloffset.setName('labeloffset')
# Bytes can be represented in binary, hex, char, or a number (0-255 or -128-127)
binbyte = Combine(Literal('0b') + Char('01') * 8)
binbyte.setName('binbyte')
binbyte.setParseAction(lambda t: [int(t[0], 2)])
hexbyte = Combine(Literal('0x') + Char(srange("[0-9a-fA-F]")) * 2)
hexbyte.setName('hexbyte')
hexbyte.setParseAction(lambda t: [int(t[0], 16)])
chrbyte = QuotedString(quoteChar="'", unquoteResults=True)
chrbyte.setName('char')
chrbyte.setParseAction(lambda t: [ord(t[0])])
number = Word(nums+'-')
number.setName('number')
number.setParseAction(lambda t: [int(t[0])])
allbytes = binbyte | hexbyte | chrbyte | number
mathtoken = Combine(oneOf('+ - & |') + allbytes)
bytemathexpression = Combine(allbytes + OneOrMore(mathtoken))
bytemathexpression.setParseAction(lambda t: [eval(t[0])])
byte = bytemathexpression | allbytes
byte.setName('byte')
# Words can be represented in binary, hex, label, or number (0-65535 or -32768-32767)
binword = Combine(Literal('0b') + Char('01') * 16)
binword.setName('binword')
binword.setParseAction(lambda t: [int(t[0], 2)])
hexword = Combine(Literal('0x') + Char(srange("[0-9a-fA-F]")) * 4)
hexword.setName('hexword')
hexword.setParseAction(lambda t: [int(t[0], 16)])
allwords = binword | hexword | number
wordmathtoken = Combine(oneOf('+ - & |') + allwords)
wordmathexpression = Combine(allwords + OneOrMore(mathtoken))
wordmathexpression.setParseAction(lambda t: [eval(t[0])])
word = wordmathexpression | label | allwords
word.setName('word')
# Data can be represented as a label followed by a double-quoted string, or a series of bytes or words
data = label + (QuotedString(quoteChar='"', unquoteResults=True) | byte[1, ...] | word[1, ...])
data.setName('data')
# Opcodes are an opcode followed by some number of bytes and/or words
opcode_syntax = [ ]
for opcode in opcodes.values():
    op_grammar = Literal(opcode.name).setResultsName('opcode')
    arg_grammar = None
    for arg in opcode.args:
        if arg.startswith('$'):
            if arg_grammar:
                arg_grammar = arg_grammar + byte
            else:
                arg_grammar = byte
        elif arg.startswith('@'):
            if arg_grammar:
                arg_grammar = arg_grammar + word
            else:
                arg_grammar = word
        else:
            raise SyntaxError("Argument with unknown sigil: {}".format(arg))
    if arg_grammar:
        opcode_syntax.append(op_grammar + arg_grammar.setResultsName('args'))
    else:
        opcode_syntax.append(op_grammar)

opcode = Or(opcode_syntax)
# Grammar is all of this OR'd
grammar = StringStart() + ((data.setResultsName('data') ^ label.setResultsName('label') ^ opcode) + Optional(comment)) | Optional(comment)
logging.info("Generated grammar")
logging.debug(grammar)

#####
# Replace macros in the source
#####
logging.info("Replacing macros")
line_num = 0
source = [ ]
with open(args.source, 'r') as fh:
    while True:
        line = fh.readline()
        line_num += 1
        if not line:
            break
        line = line.rstrip()
        if not line:
            continue
        
        partline = [*line.partition('#')]
        splitline = partline[0].split(' ')
        newsplitline = [ *splitline ]
        for idx, token in enumerate(splitline[1:]):
            while True:
                foundmacro = False
                for m, v in asm_macros.items():
                    newtoken = token.replace(m, v)
                    if newtoken != token:
                        foundmacro = True
                        newsplitline[idx+1] = newtoken
                    token = newtoken
                if not foundmacro:
                    break

        oldline = ' '.join(splitline) + partline[1] + partline[2]
        newline = ' '.join(newsplitline) + partline[1] + partline[2]
        if newline != oldline:
            logging.debug("Line {}: [{}]->[{}]".format(line_num, oldline, newline))
        source.append((line_num, newline))

#####
# Parse the assembly
#####
logging.info("Parsing source")
asm_addr = 0
assembly = [ ]
labels = { }
label_addrs = { }
for line_num, line in source:
    logging.debug("{:3d}: IN:  {}".format(line_num, line))
    try:
        match = grammar.parseString(line, parseAll=True).asDict()
    except ParseException:
        print(f"ERROR on line {line_num}: {line}")
        raise
    logging.debug("{:3d}: OUT: {}".format(line_num, match))

    # comments will result in an empty dict
    if not match:
        continue

    # label: the next opcode/data/whatever will be associated with this label
    if 'label' in match:
        labels[match['label']] = len(assembly)
        label_addrs[len(assembly)] = match['label']
        logging.debug("{:4d} Label {} => 0x{:04x}".format(line_num, match['label'], len(assembly)))

    # data: assign a label and add some data to the assembly list
    if 'data' in match:
        labels[match['data'][0]] = len(assembly)
        label_addrs[len(assembly)] = match['data'][0]
        logging.debug("{:4d} Label {} => 0x{:04x} => {}".format(line_num, match['data'][0], len(assembly), match['data'][1]))
        match['data'][1] = match['data'][1].replace('\\n', '\n')
        match['data'][1] = match['data'][1].replace('\\r', '\t')
        match['data'][1] = match['data'][1].replace('\\0', '\0')
        for i in match['data'][1]:
            assembly.append({"val": ord(i), "msg": "{} {}".format(match['data'][0], i if ord(i) >= 32 else "\\{:02x}".format(ord(i))) })

    # opcode: machine instruction plus args
    if 'opcode' in match:
        opcode = opcodes[match['opcode']]
        asm = [ {"val": opcode.code, "msg": opcode.name} ]
        arg_description = [ ]
        if 'args' in match:
            if type(match['args']) is not list:
                match['args'] = [ match['args'] ]
            for op_arg, match_arg in zip(opcode.args, match['args']):
                if op_arg.startswith('$'):
                    # byte = binbyte | hexbyte | chrbyte | number
                    if type(match_arg) is str: # char
                        if len(match_arg) != 1:
                            raise SyntaxError("Line {}: argument {} must be a single character".format(line_num, op_arg))
                        asm.append({"val": ord(match_arg[0]), "msg": op_arg})
                        arg_description.append("{}('{}'->{:02x})".format(op_arg, match_arg[0], ord(match_arg[0])))
                    else: # number
                        if match_arg < -128 or match_arg > 255:
                            raise SyntaxError("Line {}: argument {} must be between -128 and 255".format(line_num, op_arg))
                        if match_arg < 0:
                            # convert negative numbers to two's complement
                            old_match_arg = match_arg
                            match_arg = int(match_arg % (1<<8))
                            logging.info("Line {}: argument {} converted to two's complement: {} -> {}".format(line_num, op_arg, old_match_arg, match_arg))
                        asm.append({"val": match_arg, "msg": op_arg})
                        arg_description.append("{}({}->{:02x})".format(op_arg, match_arg, match_arg))
                elif op_arg.startswith('@'):
                    # word = binword | hexword | label | number
                    if type(match_arg) is str:
                        if len(match_arg) > 1 and match_arg.startswith('.'):
                            # For the first pass we just put the label in, and will resolve
                            # it on the second pass.
                            arg_description.append("{}({})".format(op_arg, match_arg))
                            asm.append({"val": "high:{}".format(match_arg), "msg": "{} high".format(op_arg)})
                            asm.append({"val": "low:{}".format(match_arg), "msg": "{} low".format(op_arg)})
                        else:
                            raise SyntaxError("Line {}: argument {} is a string, but does not look like a label".format(line_num, op_arg))
                    else:
                        if match_arg < -32768 or match_arg > 65535:
                            raise SyntaxError("Line {}: argument {} must be between -32768 and 65535".format(line_num, op_arg))
                        if match_arg < 0:
                            # convert negative numbers to two's complement
                            old_match_arg = match_arg
                            match_arg = int(match_arg % (1<<16))
                            logging.info("Line {}: argument {} converted to two's complement: {} -> {}".format(line_num, op_arg, old_match_arg, match_arg))
                        highbyte = (match_arg >> 8)
                        lowbyte = (match_arg & 0x00ff)
                        arg_description.append("{}({}->{:02x}+{:02x})".format(op_arg, match_arg, highbyte, lowbyte))
                        asm.append({"val": highbyte, "msg": "{} high".format(op_arg)})
                        asm.append({"val": lowbyte, "msg": "{} low".format(op_arg)})

        logging.debug("{:4d} {:04x}: {} [0x{:02x}] {}".format(line_num, len(assembly), opcode.name, opcode.code, arg_description))
        assembly.extend(asm)

logging.info("Incomplete assembly")
for idx, a in enumerate(assembly):
    if idx in label_addrs:
        logging.info("{:04x} {:02x} {}     <-- {}".format(idx, a['val'], a['msg'], label_addrs[idx]))
    elif type(a['val']) is str:
        logging.info("{:04x} {} {}".format(idx, a['val'], a['msg']))
    else:
        logging.info("{:04x} {:02x} {}".format(idx, a['val'], a['msg']))

# Now make a second pass to populate labels
logging.info("Updating labels")
final_assembly = [ ]
for idx, a in enumerate(assembly):
    if type(a['val']) is str:
        hl, label = a['val'].split(':')
        offset = 0
        if '-' in label:
            label, offval = label.split('-')
            offset = -1 * int(offval)
        elif '+' in label:
            label, offval = label.split('+')
            offset = int(offval)

        if label in labels:
            addr = labels[label] + offset
            if offset:
                logging.debug("Label {} with offset {} resolved to {}".format(a['val'], offset, addr))
            if hl == 'high':
                val = (addr >> 8)
            elif hl == 'low':
                val = (addr & 0x00ff)
            else:
                raise SyntaxError("Label {} missing high/low prefix".format(a['val']))
            final_assembly.append(val)
            logging.info("{:04x}: {}->{:02x}".format(idx, a['val'], val))
        else:
            raise SyntaxError("Label {} unresolved".format(label))
    else:
        assert -128 <= a['val'] <= 255
        final_assembly.append(a['val'])

# Write output
if args.output == '-' or args.verbose >= 1:
    if args.output != '-':
        print("Final assembly")
    for idx, a in enumerate(final_assembly):
        print("{:04x} {:02x} # {}".format(idx, a, assembly[idx]['msg']), end='')
        if idx in label_addrs:
            print(" <-- {}".format(label_addrs[idx]))
        else:
            print()
if args.output != '-':
    logging.info("Writing {} bytes to {}".format(len(final_assembly), args.output))
    with open(args.output, mode='wb') as fh:
        fh.write(bytes(final_assembly))
