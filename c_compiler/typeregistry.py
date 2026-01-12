from dataclasses import dataclass, field
from typing import Optional, List, Dict, Union
from typespec import TypeSpec

class TypeRegistry:
    """Registry for storing and looking up TypeSpec objects by name."""
    
    def __init__(self):
        self._types: Dict[str, TypeSpec] = {}
        self._add_builtins()
    
    def _add_builtins(self):
        """Add built-in C types to the registry."""
        builtins = [ 'char', 'signed char', 'unsigned char',    # 8 bit types
                     'short', 'signed short', 'unsigned short', # 16 bit types
                     'int', 'signed int', 'unsigned int',       # 16 bit types
                     'unsigned', 'signed',                      # 16 bit int by default
                     'void',                                    # 0 bytes
                   ]
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

