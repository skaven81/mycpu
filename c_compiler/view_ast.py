#!/usr/bin/env python3
"""
C AST Parser using pycparser
Parses a C source file and displays the Abstract Syntax Tree
"""

import sys
import argparse
from pycparser import c_parser, c_ast, parse_file, c_generator

class ASTVisualizer(c_ast.NodeVisitor):
    """
    NodeVisitor that displays AST nodes with attributes and source code
    """
    def __init__(self, source_lines=None):
        self.source_lines = source_lines
        self.indent_level = 0
    
    def _get_indent(self):
        """Get current indentation string"""
        return "  " * self.indent_level
    
    def _get_source_snippet(self, node):
        """Get source code snippet for a node"""
        if not hasattr(node, 'coord') or not node.coord or not self.source_lines:
            return ""
        
        coord = node.coord
        if coord.line and coord.line <= len(self.source_lines):
            line = self.source_lines[coord.line - 1].rstrip()
            prefix = self._get_indent()
            if coord.column:
                return f"\n{prefix}  Source: {line}\n{prefix}          {' ' * (coord.column - 1)}^"
            else:
                return f"\n{prefix}  Source: {line}"
        return ""
    
    def _format_attrs(self, node):
        """Format node attributes with names"""
        attrs = node.attr_names if hasattr(node, 'attr_names') else []
        if not attrs:
            return ""
        
        attr_parts = []
        for attr_name in attrs:
            attr_value = getattr(node, attr_name, None)
            if attr_value is not None:
                if isinstance(attr_value, list):
                    attr_parts.append(f"{attr_name}={attr_value}")
                else:
                    attr_parts.append(f"{attr_name}='{attr_value}'")
            else:
                attr_parts.append(f"{attr_name}=None")
        return ", ".join(attr_parts)
    
    def generic_visit(self, node):
        """
        Called for all node types. Displays node info and visits children.
        """
        prefix = self._get_indent()
        node_type = node.__class__.__name__
        attr_str = self._format_attrs(node)
        source_snippet = self._get_source_snippet(node)
        
        # Print node with attributes
        if attr_str:
            print(f"{prefix}{node_type}({attr_str}){source_snippet}")
        else:
            print(f"{prefix}{node_type}{source_snippet}")
        
        # Visit children
        self.indent_level += 1
        for child_name, child in node.children():
            print(f"{self._get_indent()}[{child_name}]:")
            if isinstance(child, list):
                for item in child:
                    self.visit(item)
            else:
                self.visit(child)
        self.indent_level -= 1

def display_ast(filename, use_cpp=True):
    """
    Parse a C file and display its AST
    
    Args:
        filename: Path to the C source file
        use_cpp: Whether to use C preprocessor (default: True)
    """
    try:
        # Read source file for display
        with open(filename, 'r') as f:
            source_lines = f.readlines()
        
        # Parse the C file
        # use_cpp=True runs the C preprocessor first (handles #include, #define, etc.)
        # cpp_path: specify your gcc path if needed, e.g., 'gcc' or '/usr/bin/gcc'
        # cpp_args: preprocessor arguments, -E for preprocessing only
        if use_cpp:
            ast = parse_file(filename, use_cpp=True,
                           cpp_args=['-E', r'-I/usr/include/fakeinc'])
        else:
            # Parse without preprocessing (file must have no #includes or macros)
            ast = parse_file(filename, use_cpp=False)
        
        # Display the AST using the visitor pattern
        print(f"\n{'='*60}")
        print(f"AST for: {filename}")
        print(f"{'='*60}\n")
        
        visualizer = ASTVisualizer(source_lines)
        visualizer.visit(ast)
        
        return ast
        
    except Exception as e:
        print(f"Error parsing file '{filename}': {e}", file=sys.stderr)
        return None

def main():
    """Main function to handle command-line execution"""
    parser = argparse.ArgumentParser(
        description='Parse a C source file and display its Abstract Syntax Tree',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python parse_c_ast.py program.c              # Parse with preprocessing
  python parse_c_ast.py program.c --no-cpp     # Parse without preprocessing
        """
    )
    
    parser.add_argument('filename',
                       help='C source file to parse')
    
    parser.add_argument('--no-cpp',
                       action='store_true',
                       help='Disable C preprocessor (default: preprocessing enabled)')
    
    args = parser.parse_args()
    
    # use_cpp is True by default, unless --no-cpp is specified
    use_cpp = not args.no_cpp
    
    display_ast(args.filename, use_cpp=use_cpp)

if __name__ == "__main__":
    main()
