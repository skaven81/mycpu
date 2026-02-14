#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

from gen_roms import Opcode
import fileinput
import re
import argparse
import logging
import yaml
from pyparsing import Word, alphanums, nums, Regex, Literal, QuotedString, Or, And, Char, srange, printables, Optional, Combine, Group, StringStart, OneOrMore, oneOf, ParseException

parser = argparse.ArgumentParser(description='Assemble program ROM')
parser.add_argument('--opcodes', default='opcodes', help='File containing opcodes')
parser.add_argument('--verbose', '-v', action='count', default=0)
parser.add_argument('--macros', '-m', help='%%-%% style preprocessing macros', action='append')
parser.add_argument('--symbols', '-S', help='Input symbol table')
parser.add_argument('sources', help='Assembly source code, specified in order', nargs='+')
parser.add_argument('--output', '-o', help='Output .hex file, or - for STDOUT')
parser.add_argument('--output-symbols', '-s', help='Output exported symbol table')
parser.add_argument('--odyssey', '-O', help="Write output file in ODY executable format", action='store_true')
parser.add_argument('--odyssey-target', help="Memory allocation target for ODY executable", choices=["main", "ext-d", "ext-e", "ext-de"], default="main")
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
labelprefix = Literal(':') | Literal('.')
labelname = Word(alphanums+"_", min=4)
labeloffset = Combine((Literal('+')|Literal('-')) + Word(nums))
labeloffset.setName('labeloffset')
label = Combine(labelprefix + labelname + Optional(labeloffset))
label.setName('label')
# Variable declarations. `global` assigns a permanent address from the variable
# pool, and the name will be valid across all assembler files. Both `byte` and
# `word` return a single 16-bit address, but `word` also marks the following
# byte as reserved.  If a number of bytes is specified instead of `byte` or
# `word`, then an array is reserved. Currently `global` is the only scope but
# we reserve the syntax to add other scopes later.
#  VAR {global} {byte|word|dword|<num_bytes>} $name
varprefix = Literal('VAR').setResultsName('var_declare')
varscope = Literal('global').setResultsName('scope')
varsize = Combine(Literal('byte') | Literal('word') | Literal('dword') | Word(nums)).setResultsName('size')
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
mathtoken = Combine(oneOf('* / + - & |') + allbytes)
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
wordmathtoken = Combine(oneOf('* / + - & |') + allwords)
wordmathexpression = Combine(allwords + OneOrMore(wordmathtoken))
wordmathexpression.setParseAction(lambda t: [eval(t[0])])
word = wordmathexpression | label | allwords
word.setName('word')
# Data can be represented as a label followed by a combination of double-quoted strings, series of bytes, or labels.
#  .label "Hello World\0"
#  .mapping "some_cmd" :cmd_label 0x00
data = label + OneOrMore(QuotedString(quoteChar='"', unquoteResults=True) | byte | label)
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
                arg_grammar = arg_grammar + (word | label)
            else:
                arg_grammar = word | label
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
# Replace ASM macros and localize labels in the source.
# Also find and define global vars
# Also find C-generated global and local static var init function calls,
# and collect them for insertion at the top of the compiled assembly
#####
logging.info("Replacing ASM macros, localizing labels, and finding global vars")
line_num = 0
concat_source = [ ]
global_vars = { }
global_arrays = { }
next_global_var = 0x4f00 # hidden framebuffer, 256 bytes, when full goes to 0x5f10 (more hidden framebuffer)
next_global_array = 0xbcff
global_static_local_init_labels = []

# If we are importing a symbol table, read that and update vars and arrays
if args.symbols:
    logging.info("Loading variable symbols from {}".format(args.symbols))
    with open(args.symbols, 'r') as fh:
        sym = yaml.load(fh, Loader=yaml.Loader)
    global_vars = sym['global_vars']
    global_arrays = sym['global_arrays']
    next_global_var = sym['next_global_var']
    next_global_array = sym['next_global_array']
    logging.info("Loaded {} global vars, {} global arrays".format(len(global_vars), len(global_arrays)))
    logging.info("Next global var: {:04x} Next global array: {:04x}".format(next_global_var, next_global_array))

for input_file in args.sources:
    label_prefix="{}_".format(input_file.split('/')[-1].split('.')[0].replace(' ','_').replace('-','_')).upper()
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
            if splitline[0].startswith('.'):
                logging.debug("{:16.16s} Line {}: Not processing tokens because label [{}]".format(input_file, line_num, splitline[0]))
            else:
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
            newline = re.sub(r"\.([a-zA-Z0-9_]{3}[a-zA-Z0-9_]+)", f".{label_prefix}\\1", newline)

            # Look for global variable declarations
            try:
                match = grammar.parseString(newline, parseAll=True).asDict()
            except ParseException:
                match = None # clear match since we're looping to next line
                pass # ignore parsing exceptions for now, we'll catch them later
            if match and 'var_declare' in match and match['scope'] == 'global':
                logging.debug("{:16.16s} Line {}: VAR {} {} => 0x{:04x}".format(input_file, line_num, match['scope'], match['var'], next_global_var))
                if match['var'] in global_vars or match['var'] in global_arrays:
                    raise SyntaxError("{:16.16s} Line {}: Variable {} declared twice".format(input_file, line_num, match['var']))
                if match['size'] == 'byte':
                    global_vars[match['var']] = next_global_var
                    next_global_var += 1
                elif match['size'] == 'word':
                    global_vars[match['var']] = next_global_var
                    next_global_var += 2
                elif match['size'] == 'dword':
                    global_vars[match['var']] = next_global_var
                    next_global_var += 4
                else:
                    next_global_array -= int(match['size'])
                    global_arrays[match['var']] = next_global_array + 1
                    assert 0xba00 <= next_global_array <= 0xbcff
                # If we have filled up the first global var range, roll to the next one
                if match['size'] in ('byte', 'word','dword',):
                    if next_global_var <= 0x4fff:
                        if next_global_var >= 0x4ffb:
                            logging.debug("{:16.16s} Line {}: first global var zone is full, moving to 0x5f10".format(input_file, line_num))
                            next_global_var = 0x5f10
                    assert (0x4f00 <= next_global_var <= 0x4fff) or (0x5f10 <= next_global_var <= 0x5fff)

            # Look for CALLs to .<FILENAME_>__global_local_init__; these get queued in a list
            # to be prepended to concat_source before final assembly.
            if match and match.get('opcode','') == 'CALL' and match.get('args','').endswith('__global_local_init__'):
                logging.debug("{:16.16s} Line {}: Noting CALL to global / static local var init {}".format(input_file, line_num, match['args']))
                global_static_local_init_labels.append((input_file, line_num, newline))
            else:
                if newline != oldline:
                    logging.debug("{:16.16s} Line {}: [{}]->[{}]".format(input_file, line_num, oldline, newline))
                concat_source.append((input_file, line_num, newline))


#####
# Prepend any CALLs to global and local static init functions to the concatenated input
#####
if global_static_local_init_labels:
    concat_source = global_static_local_init_labels + concat_source

#####
# Parse the assembly
#####
logging.info("Parsing source")
asm_addr = 0
assembly = [ ]
labels = { }
ext_labels = { }
label_addrs = { }

# Load labels from symbol table if present
if args.symbols:
    logging.info("Loading external label symbols from {}".format(args.symbols))
    with open(args.symbols, 'r') as fh:
        sym = yaml.load(fh, Loader=yaml.Loader)
    ext_labels = sym['labels']
    logging.info("Loaded {} external labels".format(len(ext_labels)))

current_file = None
for input_file, line_num, line in concat_source:
    logging.debug("{:16.16s} {:3d}: IN:  {}".format(input_file, line_num, line))
    if input_file != current_file:
        current_file = input_file

    # We have to replace variables inline so that the pyparsing bits that
    # handle math (e.g. `$some_var+1`) will work as expected.
    if not line.startswith('VAR') and not line.startswith('#'):
        newline = line
        for v in re.findall(r'\$[a-zA-Z0-9_]+', line.split('#')[0]):
            varval = global_vars.get(v, global_arrays.get(v))
            if not varval:
                raise SyntaxError(f"In {input_file} line {line_num}: undefined variable {v}\nSource code line: {line}")
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
        if match['label'] in labels:
            raise SyntaxError(f"In {input_file} line {line_num}: label {match['label']} is already defined")
        if match['label'] in ext_labels:
            raise SyntaxError(f"In {input_file} line {line_num}: label {match['label']} is already defined in external labels")
        labels[match['label']] = len(assembly)
        label_addrs[len(assembly)] = match['label']
        logging.debug("{:16.16s} {:3d} Label {} => 0x{:04x}".format(input_file, line_num, match['label'], len(assembly)))

    # data: assign a label and add some data to the assembly list
    if 'data' in match:
        labels[match['data'][0]] = len(assembly)
        label_addrs[len(assembly)] = match['data'][0]
        logging.debug("{:16.16s} {:3d}: Label {} => 0x{:04x} => {}".format(input_file, line_num, match['data'][0], len(assembly), match['data'][1]))
        for idx, data_item in enumerate(match['data']):
            if idx == 0:
                continue
            if type(data_item) is str:
                if data_item[0] == '.' or data_item[0] == ':':
                    assembly.append({"val": "hi>{}".format(data_item), "msg": "{} {} high".format(match['data'][0], data_item)})
                    assembly.append({"val": "lo>{}".format(data_item), "msg": "{} {} low".format(match['data'][0], data_item)})
                else:
                    data_item = data_item.replace('\\.', '.') # allow corner case of a data string that looks like a label
                    data_item = data_item.replace('\\:', ':') # allow corner case of a data string that looks like a label
                    data_item = data_item.replace('\\n', '\n')
                    data_item = data_item.replace('\\r', '\t')
                    data_item = data_item.replace('\\0', '\0')
                    for i in data_item:
                        assembly.append({"val": ord(i), "msg": "{} {}".format(match['data'][0], i if ord(i) >= 32 else "\\{:02x}".format(ord(i))) })
            elif type(data_item) is int:
                assert 0x00 <= data_item <= 0xff
                assembly.append({"val": data_item, "msg": "{} 0x{:02x}".format(match['data'][0], data_item) })
            else:
                raise SyntaxError("Unknown data type in data declaration")

    # variable declaration
    if 'var_declare' in match:
        if match['scope'] == 'global' and match['size'] in ('byte', 'word','dword',):
            logging.debug("{:16.16s} {:3d}: VAR {} {} => 0x{:04x} (already defined)".format(input_file, line_num, match['scope'], match['var'], global_vars[match['var']]))
        elif match['scope'] == 'global':
            logging.debug("{:16.16s} {:3d}: VAR {} {} => 0x{:04x} (already defined)".format(input_file, line_num, match['scope'], match['var'], global_arrays[match['var']]))
        else:
            raise SyntaxError('Variable declaration must include valid scope')
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
internal_addr_references = [ ]
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

        if label in labels or label in ext_labels:
            if label in labels:
                addr = labels[label] + offset
                if hl == 'hi':
                    internal_addr_references.append(idx)
            else:
                addr = ext_labels[label] + offset
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

# Generate Odyssey executable header if desired
header_offset = 0
header_msg = { }
header = [ ]
if args.odyssey:
    logging.info("Prepending Odyssey executable header")

    # Odyssey header format
    # 0-2: 'ODY'
    #   3: flag byte:
    #       0-1: memory target:
    #            0 = main memory (malloc)
    #            1 = extended memory (extmalloc) page D
    #            2 = extended memory (extmalloc) page E
    #            3 = extended memory (extmalloc) pages D+E
    #     2-7: unassigned (reserved)
    # 4-5: number of address rewrites (word)
    # 6+: rewrite offsets (words)
    # after offsets: first byte of program

    # start with the magic string
    header = [ ord('O'), ord('D'), ord('Y') ]
    header_msg[0] = "Magic string 'O'"
    header_msg[1] = "Magic string 'D'"
    header_msg[2] = "Magic string 'Y'"

    # add flag byte
    flag = 0x00
    if args.odyssey_target == 'main':
        flag |= 0x00
    elif args.odyssey_target == 'ext-d':
        flag |= 0x01
    elif args.odyssey_target == 'ext-e':
        flag |= 0x02
    elif args.odyssey_target == 'ext-de':
        flag |= 0x03
    header.append(flag)
    header_msg[3] = "Execution flags"

    # add number of target rewrites (16-bit)
    target_count = len(internal_addr_references)
    header.append( target_count >> 8 )
    header.append( target_count & 0x00ff )
    header_msg[4] = f"hi>rewrite count ({target_count})"
    header_msg[5] = f"lo>rewrite count ({target_count})"
    header_offset = len(header) + (target_count * 2)

    # add label replacement offsets
    header_msg_idx = 6
    for target_offset in internal_addr_references:
        header.append( (target_offset+header_offset) >> 8 )
        header_msg[header_msg_idx] = "hi>rewrite offset"
        header_msg_idx += 1
        header.append( (target_offset+header_offset) & 0x00ff )
        header_msg[header_msg_idx] = "lo>rewrite offset"
        header_msg_idx += 1

# Write output
if args.output == '-' or args.verbose >= 1:
    if args.output != '-':
        print("Final assembly")
    for idx, a in enumerate(header):
        print("{:04x} {:02x} # {}".format(idx, a, header_msg[idx]))
    for idx, a in enumerate(final_assembly):
        print("{:04x} {:02x} # {}".format(idx + header_offset, a, assembly[idx]['msg']), end='')
        if idx in label_addrs:
            print(" <-- {}".format(label_addrs[idx]))
        else:
            print()
if args.output != '-':
    logging.info("Writing {} bytes to {}".format(len(header) + len(final_assembly), args.output))
    with open(args.output, mode='wb') as fh:
        fh.write(bytes(header))
        fh.write(bytes(final_assembly))
if args.output_symbols:
    logging.info("Writing symbols to {}".format(args.output_symbols))
    symbol_data = { "labels": { }, "global_vars": { }, "global_arrays": { } }
    for label, addr in labels.items():
        if label[0] != ":":
            continue
        symbol_data['labels'][label] = addr
    symbol_data['global_vars'] = global_vars
    symbol_data['global_arrays'] = global_arrays
    symbol_data['next_global_var'] = next_global_var
    symbol_data['next_global_array'] = next_global_array
    with open(args.output_symbols, mode='w') as fh:
        fh.write(yaml.dump(symbol_data))
