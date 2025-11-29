from pycparser import c_ast
from variables import *
import sys

class TypeChecker(c_ast.NodeVisitor):
    """
    NodeVisitor that ensures all types are defined and compatible
    """
    def __init__(self, context):
        self.context = context
        set_type_context(self.context.typedef_reg, self.context.struct_reg)
    
    def visit_FileAST(self, node):
        print("**** Type checking begin ****", file=sys.stderr)
        self.generic_visit(node)
        print("**** Type checking end ****", file=sys.stderr)

