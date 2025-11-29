"""
Function management for C compiler
Handles function definitions and type data
"""

import math
from variables import TypeSpec
from pycparser import c_ast
from extract_type import ExtractTypeMixin

class Function(ExtractTypeMixin):
    """Represents a function with its return type and parameter types"""

    def __init__(self, name, funcdef_node):
        """
        Args:
            name: Variable name as used in C code
            funcdef_node: AST FuncDef node
        """
        self.name = name
        self.funcdef = funcdef_node
        
        if not isinstance(self.funcdef, c_ast.FuncDef):
            raise ValueError("Must pass an AST FuncDef node")

        if 'static' in self.funcdef.decl.storage:
            self.asm_name = f'.{self.name}'
        else:
            self.asm_name = f':{self.name}'

        self.return_type = self._extract_type(self.funcdef.decl.type.type)

        self.parameter_types = []
        for param_decl in self.funcdef.decl.type.args:
            self.parameter_types.append(self._extract_type(param_decl.type))

    def __repr__(self):
        ret = f"Function('{self.name}', return={self.return_type}, params={self.parameter_types})"
        return ret

    @property
    def is_static(self):
        return 'static' in self.funcdef.decl.storage

class FunctionTable:
    """Manages functions"""
    
    def __init__(self):
        self.functions = {}
    
    def add_function(self, function):
        """Add a function"""
        if function.name in self.functions:
            raise ValueError(f"Function already defined: {function.name}")
        self.functions[function.name] = function

    def func_lookup(self, name):
        """Look up a function by name"""
        if name in self.functions:
            return self.functions[name]
        
        return None

    def get_all_functions(self):
        """Get all functions"""
        return list(self.functions.values())

