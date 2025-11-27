from pycparser import c_ast
from variables import *
import sys

class CodeGenerator(c_ast.NodeVisitor):
    """
    NodeVisitor that completes the compilation and emits assembly code
    """
    def __init__(self, context):
        self.context = context
        set_type_context(self.context.typedef_reg, self.context.struct_reg)
    
    def _get_indent(self):
        """Get current indentation string"""
        return "| " * self.indent_level
    
    def _get_source_snippet(self, node):
        """Get source code snippet for a node"""
        if not hasattr(node, 'coord') or not node.coord or not self.source_lines:
            return ""
        
        coord = node.coord
        if coord.line and coord.line <= len(self.source_lines):
            line = self.source_lines[coord.line - 1].rstrip()
            prefix = self._get_indent()
            if coord.column:
                return f"\n# {prefix}  Source: {line}\n# {prefix}          {' ' * (coord.column - 1)}^"
            else:
                return f"\n# {prefix}  Source: {line}"
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

    def emit(self, asm, comment=None):
        if comment:
            print(f"{asm:<32} # {comment}", file=self.output)
        else:
            print(asm, file=self.output)
    
    def visit_Decl(self, node):
        self.debug_node(node)
        self.emit(f"Welcome to {node}")
        
    def debug_node(self, node):
        """
        Emits node info if debugging is enabled.
        """
        if not self.debug:
            return
        prefix = self._get_indent()
        node_type = node.__class__.__name__
        attr_str = self._format_attrs(node)
        source_snippet = self._get_source_snippet(node)
        
        # Print node with attributes
        if attr_str:
            self.emit(f"# {prefix}{node_type}({attr_str}){source_snippet}")
        else:
            self.emit(f"# {prefix}{node_type}{source_snippet}")

    def generic_visit(self, node):
        raise NotImplementedError(f"CodeGen: No visit_{node.__class__.__name__} function found to handle this node")
