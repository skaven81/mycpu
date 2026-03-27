#!/usr/bin/env python3
"""
C compiler using pycparser for Wire Wrap Odyssey ISA
"""

import sys
import argparse
from pycparser import parse_file
from pprint import pprint
from dataclasses import dataclass
from typeregistry import TypeRegistry
from functionregistry import FunctionRegistry
from literalregistry import LiteralRegistry
from variabletable import VariableTable
from codegen import CodeGenerator

@dataclass
class CompilerContext:
    typereg: TypeRegistry
    literalreg: LiteralRegistry
    funcreg: FunctionRegistry
    vartable: VariableTable
    source_lines: list
    static_type: str
    jmp_to_main: bool
    verbose: int
    # Optimization settings (-Ob defaults)
    rval_threshold: int = 6          # min abs(offset) for rvalue CALL helpers
    use_lval_helpers: bool = True    # lvalue CALL helpers for offset >= 10
    use_store_helpers: bool = True   # 16-bit store CALL helpers
    use_struct_self_incr: bool = True  # struct member self-increment for offset 1-2
    use_struct_helpers: bool = False  # struct member CALL helpers for offset 3+

def compile(filename, output, use_cpp=True, cpp_args="", static_type='inline', jmp_to_main=True, verbose=0, opt_settings=None):
    """
    Comple a C file and output Odyssey assembly

    Args:
        filename: Path to the C source file
        output: Output file (can be sys.stdout to write to the console)
        use_cpp: Whether to use C preprocessor (default: True)
        static_type: inline (ODY executables) or asm_var (ROM library code)
        jmp_to_main: Whether to add a JMP to the main function as the first instruction, if main function exists
        verbose: verbosity level
        opt_settings: dict of optimization settings to override defaults
    """
    # Read in the source file so we can emit debug output as we compile
    with open(filename, 'r') as f:
        source_lines = f.readlines()

    # Parse the C file
    # use_cpp=True runs the C preprocessor first (handles #include, #define, etc.)
    ast = parse_file(filename, use_cpp=use_cpp, cpp_args=cpp_args)

    # Establish compiler context for AST visitors
    context = CompilerContext(
        typereg=TypeRegistry(),
        literalreg=LiteralRegistry(),
        funcreg=FunctionRegistry(),
        vartable=VariableTable(),
        source_lines=source_lines,
        static_type=static_type,
        jmp_to_main=jmp_to_main,
        verbose=verbose)

    # Apply optimization settings
    if opt_settings:
        for key, value in opt_settings.items():
            setattr(context, key, value)

    # Build our code generator
    codegen = CodeGenerator(context, output=output)

    # Pass 1: Type collection
    if verbose >= 2:
        print("Starting type collection", file=sys.stderr)
    codegen.visit(ast, mode='type_collection')
    if verbose >= 1:
        print("Collected types:", file=sys.stderr)
        if verbose >= 2:
            pprint(context.typereg.__dict__, stream=sys.stderr)
        else:
            print([*context.typereg.keys()], file=sys.stderr)

    # Pass 2: Function collection
    if verbose >= 2:
        print("Starting function collection", file=sys.stderr)
    codegen.visit(ast, mode='function_collection')
    if verbose >= 1:
        print("Collected functions:", file=sys.stderr)
        if verbose >= 2:
            pprint(context.funcreg.__dict__, stream=sys.stderr)
        else:
            print([*context.funcreg.keys()], file=sys.stderr)

    # Pass 3: Generate code
    if verbose >= 1:
        print("Starting code generation", file=sys.stderr)
    codegen.visit(ast, mode='codegen')
    if verbose >= 1:
        print("Finished code generation", file=sys.stderr)
        
def main():
    """Main function to handle command-line execution"""
    parser = argparse.ArgumentParser(
        description='Compile a C source file into Wire Wrap Odyssey assembly',
    )

    parser.add_argument('filename',
                       help='C source file to compile')

    parser.add_argument('--output',
                       help='Output assembly file, default=STDOUT')

    parser.add_argument('--no-cpp',
                       action='store_true',
                       help='Disable C preprocessor (default: enabled)')

    parser.add_argument('--cpp-args',
                       help='Extra arguments to pass to the C preparser')

    parser.add_argument('--target-rom',
                       action='store_true',
                       help='Store global and static vars using VAR statements instead of in-program labels')

    parser.add_argument('--ignore-main',
                       action='store_true',
                       help='Default behavior is that the first assembly instruction will be a JMP to the main function, if it exists. Set this to suppress that JMP instruction, even if a main function is found')

    parser.add_argument('-v', '--verbose',
                       action='count',
                       help='Verbosity, add multiple times to increase verbosity')

    # Optimization flags
    opt_group = parser.add_argument_group('optimization')
    opt_group.add_argument('-Os', dest='opt_size', action='store_true',
                           help='Optimize for size: use all CALL helpers, rval threshold=1')
    opt_group.add_argument('-Ob', dest='opt_balanced', action='store_true',
                           help='Optimize balanced (default): helpers where cycle penalty is minimal')
    opt_group.add_argument('-Of', dest='opt_fast', action='store_true',
                           help='Optimize for speed: no CALL helpers (struct self-incr still active)')
    opt_group.add_argument('--rval-threshold', type=int, default=None,
                           help='Min stack offset for rvalue CALL helpers (overrides preset)')
    opt_group.add_argument('--no-store-helpers', action='store_true',
                           help='Disable 16-bit store CALL helpers')
    opt_group.add_argument('--no-lval-helpers', action='store_true',
                           help='Disable lvalue CALL helpers for offset >= 10')
    opt_group.add_argument('--no-struct-helpers', action='store_true',
                           help='Disable struct member CALL helpers for offset 3+')
    opt_group.add_argument('--no-struct-self-incr', action='store_true',
                           help='Disable struct self-increment optimization (debug only)')

    args = parser.parse_args()

    # use_cpp is True by default, unless --no-cpp is specified
    use_cpp = not args.no_cpp
    # If --output specified, set up a file for writing output,
    # otherwise use sys.stdout
    if args.output:
        output = open(args.output, 'w')
    else:
        output = sys.stdout
    static_type = 'inline'
    if args.target_rom:
        static_type = 'asm_var'
    jmp_to_main = not args.ignore_main

    # Build optimization settings from preset + overrides
    opt_settings = {}
    if args.opt_size:
        opt_settings['rval_threshold'] = 1
        opt_settings['use_struct_helpers'] = True
    elif args.opt_fast:
        opt_settings['rval_threshold'] = 999
        opt_settings['use_lval_helpers'] = False
        opt_settings['use_store_helpers'] = False
        opt_settings['use_struct_helpers'] = False
    # Individual overrides (applied after preset)
    if args.rval_threshold is not None:
        opt_settings['rval_threshold'] = args.rval_threshold
    if args.no_store_helpers:
        opt_settings['use_store_helpers'] = False
    if args.no_lval_helpers:
        opt_settings['use_lval_helpers'] = False
    if args.no_struct_helpers:
        opt_settings['use_struct_helpers'] = False
    if args.no_struct_self_incr:
        opt_settings['use_struct_self_incr'] = False

    compile(args.filename, output=output, use_cpp=use_cpp, cpp_args=args.cpp_args, static_type=static_type, jmp_to_main=jmp_to_main, verbose=args.verbose if args.verbose else 0, opt_settings=opt_settings)

if __name__ == "__main__":
    main()
