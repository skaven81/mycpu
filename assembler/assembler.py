#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

from gen_roms import Opcode
import fileinput
import re
import argparse
import logging
from pyparsing import Word, alphanums, nums, Regex, Literal, QuotedString, Or, And, Char, srange, printables, Optional, Combine, Group, StringStart, OneOrMore, oneOf, ParseException

parser = argparse.ArgumentParser(description='Assemble program ROM')
parser.add_argument('--opcodes', default='opcodes', help='File containing opcodes')
parser.add_argument('--verbose', '-v', action='count', default=0)
parser.add_argument('--macros', '-m', help='%-% style preprocessing macros', action='append')
parser.add_argument('sources', help='Assembly source code, specified in order', nargs='+')
parser.add_argument('--output', '-o', help='Output .hex file, or - for STDOUT')
args = parser.parse_args()

if not args.macros:
    args.macros = [ 'asm_macros' ]

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

# Read any assembler macros (%..% style)
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
#  .label - regular label
#  :label - exported/global label
#  OPCODE .label - .label gets turned into the corresponding address
#  OPCODE :label+4 - same, but with an offset
labelprefix = oneOf(': .')
label = Combine(labelprefix + Word(alphanums+"_"))
label.setName('label')
labeloffset = Combine(labelprefix + Word(':', alphanums+"_-+"))
labeloffset.setName('labeloffset')
# Variable declarations. `global` assigns a permanent address from the variable pool,
# and the name will be valid across all assembler files.  `local` assigns an address
# from the local pool, so an address might get reused across multiple files, and the
# name is localized to just the file.  Both `byte` and `word` return a single 16-bit
# address, but `word` also marks the following byte as reserved.  If a number of bytes
# is specified instead of `byte` or `word`, then an array is reserved.
#  VAR {global|local} {byte|word|<num_bytes>} $name
varprefix = Literal('VAR').setResultsName('var_declare')
varscope = Combine(Literal('global') | Literal('local')).setResultsName('scope')
varsize = Combine(Literal('byte') | Literal('word') | Word(nums)).setResultsName('size')
varname = Combine(Literal('$') + Word(alphanums+"_")).setResultsName('var')
var = varprefix + varscope + varsize + varname
var.setName('var')
# Bytes can be represented in binary, hex, char, or a number (0-255 or -128-127)
# and may include embedded arithmetic
#  OPCODE 0b00001100
#  OPCODE 0x0b
#  OPCODE 'a'
#  OPCODE 254-0x0a
#  OPCODE 'a'&0b00001111
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
#  OPCODE 0b0000111100001111
#  OPCODE 0x2911
#  OPCODE .label
#  OPCODE .label+4
#  OPCODE 2490
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
#  .label "Hello World\0"
data = label + (QuotedString(quoteChar='"', unquoteResults=True) | byte[1, ...] | word[1, ...])
data.setName('data')
# Opcodes are an opcode followed by some number of bytes and/or words
#  OPCODE
#  OPCODE 0xa0
#  OPCODE .label
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
grammar = StringStart() + ((data.setResultsName('data') ^ label.setResultsName('label') ^ opcode ^ var) + Optional(comment)) | Optional(comment)
logging.info("Generated grammar")
logging.debug(grammar)

#####
# Replace ASM macros and localize labels in the source.  Also find and define global vars
#####
logging.info("Replacing ASM macros, localizing labels, and finding global vars")
line_num = 0
concat_source = [ ]
global_vars = { }
global_arrays = { }
next_global_var = 0x4f00 # hidden framebuffer, 256 bytes
next_global_array = 0xb5ff # grows downward
for input_file in args.sources:
    label_prefix="{}_".format(input_file.split('/')[-1].split('.')[0].replace(' ','_')).upper()
    with open(input_file, 'r') as fh:
        while True:
            line = fh.readline()
            line_num += 1
            if not line:
                break
            line = line.rstrip()
            if not line:
                continue
            
            # Look for ASM macros and replace them
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

            # Look for dot-style labels and replace them with localized
            # versions that have the filename prepended
            newline = re.sub(r"\.([a-zA-Z0-9_]+)", f".{label_prefix}\\1", newline)

            if newline != oldline:
                logging.debug("{:16.16s} Line {}: [{}]->[{}]".format(input_file, line_num, oldline, newline))
            concat_source.append((input_file, line_num, newline))

            # Look for global variable declarations
            try:
                match = grammar.parseString(newline, parseAll=True).asDict()
            except ParseException:
                pass # ignore parsing exceptions for now, we'll catch them later
            if match and 'var_declare' in match and match['scope'] == 'global':
                logging.debug("{:16.16s} Line {}: VAR {} {} => 0x{:04x}".format(input_file, line_num, match['scope'], match['var'], next_global_var))
                if match['size'] == 'byte':
                    global_vars[match['var']] = next_global_var
                    next_global_var += 1
                    assert 0x4f00 <= next_global_var <= 0x4fff
                elif match['size'] == 'word':
                    global_vars[match['var']] = next_global_var
                    next_global_var += 2
                    assert 0x4f00 <= next_global_var <= 0x4fff
                else:
                    next_global_array -= int(match['size'])
                    global_arrays[match['var']] = next_global_array + 1
                    assert 0xb000 <= next_global_array <= 0xb5ff


#####
# Parse the assembly
#####
logging.info("Parsing source")
asm_addr = 0
assembly = [ ]
labels = { }
label_addrs = { }
current_file = None
for input_file, line_num, line in concat_source:
    logging.debug("{:16.16s} {:3d}: IN:  {}".format(input_file, line_num, line))
    if input_file != current_file:
        # Reset local vars for each new file
        local_vars = { }
        local_arrays = { }
        next_local_var = 0x5f10 # hidden framebuffer, 240 bytes, after interrupt addresses
        next_local_array = 0xb600 # grows upward
        current_file = input_file

    # We have to replace variables inline so that the pyparsing bits that
    # handle math (e.g. `$some_var+1`) will work as expected.
    if not line.startswith('VAR'):
        newline = line
        for v in re.findall('\$[a-zA-Z0-9_]+', line):
            varval = local_vars.get(v, global_vars.get(v, None))
            if not varval:
                raise SyntaxError(f"In {input_file} line {line_num}: undefined variable {v}")
            newline = newline.replace(v, f"0x{varval:04x}")
        if newline != line:
            logging.debug("{:16.16s} {:3d}: VAR: {}".format(input_file, line_num, newline))
            line = newline;
    
    try:
        match = grammar.parseString(line, parseAll=True).asDict()
    except ParseException:
        print(f"ERROR on line {line_num}: {line}")
        raise
    logging.debug("{:16.16s} {:3d}: OUT: {}".format(input_file, line_num, match))

    # comments will result in an empty dict
    if not match:
        continue

    # label: the next opcode/data/whatever will be associated with this label
    if 'label' in match:
        labels[match['label']] = len(assembly)
        label_addrs[len(assembly)] = match['label']
        logging.debug("{:16.16s} {:3d} Label {} => 0x{:04x}".format(input_file, line_num, match['label'], len(assembly)))

    # data: assign a label and add some data to the assembly list
    if 'data' in match:
        labels[match['data'][0]] = len(assembly)
        label_addrs[len(assembly)] = match['data'][0]
        logging.debug("{:16.16s} {:3d}: Label {} => 0x{:04x} => {}".format(input_file, line_num, match['data'][0], len(assembly), match['data'][1]))
        match['data'][1] = match['data'][1].replace('\\n', '\n')
        match['data'][1] = match['data'][1].replace('\\r', '\t')
        match['data'][1] = match['data'][1].replace('\\0', '\0')
        for i in match['data'][1]:
            assembly.append({"val": ord(i), "msg": "{} {}".format(match['data'][0], i if ord(i) >= 32 else "\\{:02x}".format(ord(i))) })

    # variable declaration
    if 'var_declare' in match:
        if match['scope'] == 'global':
            logging.debug("{:16.16s} {:3d}: VAR {} {} => 0x{:04x} (already defined)".format(input_file, line_num, match['scope'], match['var'], global_vars[match['var']]))
        elif match['scope'] == 'local':
            logging.debug("{:16.16s} {:3d}: VAR {} {} => 0x{:04x}".format(input_file, line_num, match['scope'], match['var'], next_local_var))
            if match['size'] == 'byte':
                local_vars[match['var']] = next_local_var
                next_local_var += 1
                assert 0x5f10 <= next_local_var <= 0x5fff
            elif match['size'] == 'word':
                local_vars[match['var']] = next_local_var
                next_local_var += 2
                assert 0x5f10 <= next_local_var <= 0x5fff
            else:
                local_arrays[match['var']] = next_local_array
                next_local_array += int(match['size'])
                assert 0xb600 <= next_local_array <= 0xb9ff
        else:
            raise SyntaxError('Variable declaration must include local or global scope')
        continue

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
                            raise SyntaxError("{} Line {}: argument {} must be a single character".format(input_file, line_num, op_arg))
                        asm.append({"val": ord(match_arg[0]), "msg": op_arg})
                        arg_description.append("{}('{}'->{:02x})".format(op_arg, match_arg[0], ord(match_arg[0])))
                    else: # number
                        if match_arg < -128 or match_arg > 255:
                            raise SyntaxError("{} Line {}: argument {} must be between -128 and 255".format(input_file, line_num, op_arg))
                        if match_arg < 0:
                            # convert negative numbers to two's complement
                            old_match_arg = match_arg
                            match_arg = int(match_arg % (1<<8))
                            logging.info("{} Line {}: argument {} converted to two's complement: {} -> {}".format(input_file, line_num, op_arg, old_match_arg, match_arg))
                        asm.append({"val": match_arg, "msg": op_arg})
                        arg_description.append("{}({}->{:02x})".format(op_arg, match_arg, match_arg))
                elif op_arg.startswith('@'):
                    # word = binword | hexword | label | number | var
                    if type(match_arg) is str:
                        if len(match_arg) > 1 and (match_arg.startswith('.') or match_arg.startswith(':')):
                            # For the first pass we just put the label in, and will resolve
                            # it on the second pass.
                            arg_description.append("{}({})".format(op_arg, match_arg))
                            asm.append({"val": "hi>{}".format(match_arg), "msg": "{} high".format(op_arg)})
                            asm.append({"val": "lo>{}".format(match_arg), "msg": "{} low".format(op_arg)})
                        else:
                            raise SyntaxError("{} Line {}: argument {}:{} is a string, but does not look like a label or declared variable name".format(input_file, line_num, op_arg, match_arg))
                    else:
                        if match_arg < -32768 or match_arg > 65535:
                            raise SyntaxError("{} Line {}: argument {} must be between -32768 and 65535".format(input_file, line_num, op_arg))
                        if match_arg < 0:
                            # convert negative numbers to two's complement
                            old_match_arg = match_arg
                            match_arg = int(match_arg % (1<<16))
                            logging.info("{} Line {}: argument {} converted to two's complement: {} -> {}".format(input_file, line_num, op_arg, old_match_arg, match_arg))
                        highbyte = (match_arg >> 8)
                        lowbyte = (match_arg & 0x00ff)
                        arg_description.append("{}({}->{:02x}+{:02x})".format(op_arg, match_arg, highbyte, lowbyte))
                        asm.append({"val": highbyte, "msg": "{} high".format(op_arg)})
                        asm.append({"val": lowbyte, "msg": "{} low".format(op_arg)})

        logging.debug("{:16.16s} {:3d}: {:04x}: {} [0x{:02x}] {}".format(input_file, line_num, len(assembly), opcode.name, opcode.code, arg_description))
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
        hl, label = a['val'].split('>')
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
            if hl == 'hi':
                val = (addr >> 8)
            elif hl == 'lo':
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
