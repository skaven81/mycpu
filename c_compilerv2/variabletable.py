"""
Variable management for C compiler
Handles storage location and code generation for variable access
"""

from dataclasses import dataclass
from typing import Optional, List, Dict
from variable import Variable

class VariableTable:
    """Manages variable scopes and lookups"""
    def __init__(self):
        self.globals = {}
        self.scopes = []
        self.local_statics = {}
        self.localvar_offset = 0
    
    def push_scope(self):
        """Enter a new scope"""
        self.scopes.append({})
    
    def pop_scope(self):
        """Exit current scope"""
        if not self.scopes:
            raise RuntimeError("Cannot pop global scope")
        self.scopes.pop()
    
    def add_global(self, variable: Variable):
        """Add a global variable"""
        if variable.name in self.globals:
            raise ValueError(f"Global variable already defined: {variable.name}")
        self.globals[variable.name] = variable

    def add(self, variable: Variable):
        """Add a variable to current scope, global scope is assumed if scopes stack is empty """

        # Global scope = global var
        if len(self.scopes) == 0:
            if variable.kind and variable.kind != 'global':
                raise ValueError("Can't register non-global var without a scope pushed")
            self.globals[variable.name] = variable
            return

        # Not global scope = local var or parameter
        scope = self.scopes[-1]
        if variable.name in scope:
            raise ValueError(f"Variable already defined in scope: {variable.name}")

        # assign offset to local non-static vars
        if variable.kind == 'local' and variable.storage_class != 'static':
            self.localvar_offset += variable.sizeof()
            variable.offset = self.localvar_offset

        # register the variable in the current scope
        scope[variable.name] = variable

        # also record the variable in the local_statics table for statics
        if variable.storage_class == 'static':
            if variable.name in self.local_statics:
                raise ValueError(f"Found duplicate static local variable definition for {variable.name}")
            self.local_statics[variable.name] = variable

    def lookup(self, name) -> Variable:
        """Look up a variable by name"""
        for scope in reversed(self.scopes):
            if name in scope:
                return scope[name]
        
        if name in self.globals:
            return self.globals[name]
        
        return None

    def get_all_globals(self) -> List[Variable]:
        """Get all global variables"""
        return list(self.globals.values())

    def get_all_local_statics(self) -> List[Variable]:
        return list(self.local_statics.values())

    def get_current_scope_vars(self):
        """Get variables in current scope"""
        if not self.scopes:
            return self.get_all_globals()
        return list(self.scopes[-1].values())

    def get_scope_depth(self) -> int:
        """Return the current scope depth, 0=global"""
        return len(self.scopes)
