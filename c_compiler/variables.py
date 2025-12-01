"""
Variable management for C compiler
Handles storage location and code generation for variable access
"""

from dataclasses import dataclass
from typing import Optional, List, Dict
from typespec import TypeSpec

@dataclass
class Variable:
    name: str
    typespec: TypeSpec
    storage_class: str           # auto, static, register, etc.
    offset: Optional[int] = None # only for non-static locals and parameter vars
    kind: Optional[str] = None   # global, param, or local

    def __repr__(self):
        return f"{self.typespec.c_str()} {self.name}"

class VariableTable:
    """Manages variable scopes and lookups"""
    def __init__(self):
        self.globals = {}
        self.scopes = []
    
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

    def add_local(self, variable: Variable):
        """Add a variable to current scope"""
        if not self.scopes:
            raise RuntimeError("No active scope for local variable")
        scope = self.scopes[-1]
        if variable.name in scope:
            raise ValueError(f"Variable already defined in scope: {variable.name}")
        scope[variable.name] = variable

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

    def get_current_scope_vars(self):
        """Get variables in current scope"""
        if not self.scopes:
            return []
        return list(self.scopes[-1].values())
