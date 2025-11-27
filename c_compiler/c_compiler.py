#!/usr/bin/env python3
"""
C compiler using pycparser for Wire Wrap Odyssey ISA
"""

import sys
import argparse
from pycparser import parse_file
from variables import TypedefRegistry, StructRegistry, VariableTable
from symbols import SymbolCollector
from typecheck import TypeChecker
from codegen import CodeGenerator
from pprint import pprint

class CompilerContext():
    def __init__(self, **kwargs):
        for k, v in kwargs.items():
            setattr(self, k, v)
        self.indent_level = 0
        self.typedef_reg = TypedefRegistry()
        self.struct_reg = StructRegistry()
        self.variable_table = VariableTable()

def compile(filename, output, use_cpp=True, static_type='inline', jmp_to_main=True, debug=False):
    """
    Comple a C file and output Odyssey assembly
    
    Args:
        filename: Path to the C source file
        output: Output file (can be sys.stdout to write to the console)
        use_cpp: Whether to use C preprocessor (default: True)
        static_type: inline or asm_var
        jmp_to_main: Whether to add a JMP to the main function as the first instruction, if main function exists
        debug: Whether to include debug comments in the assembly output
    """
    # Read in the source file so we can emit debug output as we compile
    with open(filename, 'r') as f:
        source_lines = f.readlines()
    
    # Parse the C file
    # use_cpp=True runs the C preprocessor first (handles #include, #define, etc.)
    ast = parse_file(filename, use_cpp=use_cpp)

    # Establish compiler context for AST visitors
    context = CompilerContext(
        source_lines=source_lines,
        static_type=static_type,
        jmp_to_main=jmp_to_main,
        debug=debug)

    # Pass 1: Collect symbols
    print("Starting symbol collection", file=sys.stderr)
    symbol_collector = SymbolCollector(context)
    symbol_collector.visit(ast)
    print("Done with symbol collection", file=sys.stderr)
    if context.debug:
        print("Typedefs:", file=sys.stderr)
        pprint(context.typedef_reg.typedefs, stream=sys.stderr)
        print("Structs:", file=sys.stderr)
        pprint(context.struct_reg.structs, stream=sys.stderr)
        print("Global Variables:", file=sys.stderr)
        pprint(context.variable_table.get_all_globals(), stream=sys.stderr)
        print("Functions:", file=sys.stderr)
        pprint(context.variable_table.get_all_functions(), stream=sys.stderr)

    # Pass 2: Type checks
    type_checker = TypeChecker(context)
    type_checker.visit(ast)
    
    # Pass 3: Generate code
    code_generator = CodeGenerator(context)
    code_generator.visit(ast)
        
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

    parser.add_argument('--debug',
                       action='store_true',
                       help='Emit debug comments into the assembly output')

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

    compile(args.filename, output=output, use_cpp=use_cpp, static_type=static_type, jmp_to_main=jmp_to_main, debug=args.debug)

if __name__ == "__main__":
    main()
