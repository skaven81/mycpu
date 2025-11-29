#!/usr/bin/env python3
"""
C compiler using pycparser for Wire Wrap Odyssey ISA
"""

import sys
import argparse
from pycparser import parse_file
from pprint import pprint
from dataclasses import dataclass
from typecollection import TypeRegistry, TypeCollector
from functioncollection import FunctionRegistry, FunctionCollector
from literalcollection import LiteralRegistry, LiteralCollector

@dataclass
class CompilerContext:
    typereg: TypeRegistry
    literalreg: LiteralRegistry
    funcreg: FunctionRegistry
    source_lines: list
    static_type: str
    jmp_to_main: bool
    verbose: int

def compile(filename, output, use_cpp=True, static_type='inline', jmp_to_main=True, verbose=0):
    """
    Comple a C file and output Odyssey assembly
    
    Args:
        filename: Path to the C source file
        output: Output file (can be sys.stdout to write to the console)
        use_cpp: Whether to use C preprocessor (default: True)
        static_type: inline (ODY executables) or asm_var (ROM library code)
        jmp_to_main: Whether to add a JMP to the main function as the first instruction, if main function exists
        verbose: verbosity level
    """
    # Read in the source file so we can emit debug output as we compile
    with open(filename, 'r') as f:
        source_lines = f.readlines()
    
    # Parse the C file
    # use_cpp=True runs the C preprocessor first (handles #include, #define, etc.)
    ast = parse_file(filename, use_cpp=use_cpp)

    # Establish compiler context for AST visitors
    context = CompilerContext(
        typereg=TypeRegistry(),
        literalreg=LiteralRegistry(),
        funcreg=FunctionRegistry(),
        source_lines=source_lines,
        static_type=static_type,
        jmp_to_main=jmp_to_main,
        verbose=verbose)

    # Pass 1: Type collection
    if verbose >= 2:
        print("Starting type collection", file=sys.stderr)
    type_collector = TypeCollector(context.typereg)
    type_collector.visit(ast)
    if verbose >= 1:
        print("Collected types:", file=sys.stderr)
        if verbose >= 2:
            pprint(context.typereg.__dict__, stream=sys.stderr)
        else:
            print([*context.typereg.keys()], file=sys.stderr)

    # Pass 2: Literal collection
    if verbose >= 2:
        print("Starting literal collection", file=sys.stderr)
    literal_collector = LiteralCollector(context.literalreg)
    literal_collector.visit(ast)
    if verbose >= 1:
        print("Collected literals:", file=sys.stderr)
        if verbose >= 2:
            pprint(context.literalreg.__dict__, stream=sys.stderr)
        else:
            print([*context.literalreg.keys()], file=sys.stderr)

    # Pass 3: Function collection
    if verbose >= 2:
        print("Starting function collection", file=sys.stderr)
    function_collector = FunctionCollector(context.funcreg, context.typereg)
    function_collector.visit(ast)
    if verbose >= 1:
        print("Collected functions:", file=sys.stderr)
        if verbose >= 2:
            pprint(context.funcreg.__dict__, stream=sys.stderr)
        else:
            print([*context.funcreg.keys()], file=sys.stderr)

    # Pass 4: Generate code
    if verbose >= 1:
        print("Starting code generation", file=sys.stderr)
    #code_generator = CodeGenerator(context, output=output)
    #code_generator.visit(ast)
        
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

    parser.add_argument('--target-rom',
                       action='store_true',
                       help='Store global and static vars using VAR statements instead of in-program labels')

    parser.add_argument('--ignore-main',
                       action='store_true',
                       help='Default behavior is that the first assembly instruction will be a JMP to the main function, if it exists. Set this to suppress that JMP instruction, even if a main function is found')

    parser.add_argument('-v', '--verbose',
                       action='count',
                       help='Verbosity, add multiple times to increase verbosity')

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

    compile(args.filename, output=output, use_cpp=use_cpp, static_type=static_type, jmp_to_main=jmp_to_main, verbose=args.verbose if args.verbose else 0)

if __name__ == "__main__":
    main()
