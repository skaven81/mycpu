from pycparser import c_ast
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Union
from typespec import TypeSpec
from typespecbuilder import TypeSpecBuilder

class TypeRegistry:
    """Registry for storing and looking up TypeSpec objects by name."""
    
    def __init__(self):
        self._types: Dict[str, TypeSpec] = {}
        self._add_builtins()
    
    def _add_builtins(self):
        """Add built-in C types to the registry."""
        builtins = ['int', 'char', 'short', 'void', 'signed', 'unsigned']
        for typename in builtins:
            spec = TypeSpec(name=typename, base_type=typename, _registry=self)
            self._types[typename] = spec
    
    def register(self, name: str, typespec: TypeSpec) -> None:
        """Register a TypeSpec with the given name."""
        typespec._registry = self
        self._types[name] = typespec
    
    def lookup(self, name: str) -> Optional[TypeSpec]:
        """Look up a TypeSpec by name."""
        return self._types.get(name)
    
    def __contains__(self, name: str) -> bool:
        """Check if a type name is registered."""
        return name in self._types
    
    def __getitem__(self, name: str) -> TypeSpec:
        """Get a TypeSpec by name (raises KeyError if not found)."""
        return self._types[name]
    
    def keys(self):
        """Return all registered type names."""
        return self._types.keys()
    
    def values(self):
        """Return all registered TypeSpec objects."""
        return self._types.values()
    
    def items(self):
        """Return all (name, TypeSpec) pairs."""
        return self._types.items()

class TypeCollector(c_ast.NodeVisitor, TypeSpecBuilder):
    """
    Visitor that collects typedef declarations and builds TypeSpec objects.
    After instantiation, call visit(ast) to perform collection
    """
    
    def __init__(self, type_registry: TypeRegistry):
        self.type_registry = type_registry
    
    def visit_Typedef(self, node: c_ast.Typedef) -> None:
        """Visit a typedef node and create a TypeSpec."""
        typespec = self._build_typespec(node.name, node.type)
        self.type_registry.register(node.name, typespec)
    

