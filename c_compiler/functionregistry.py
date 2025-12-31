from typing import Optional, Dict
from typespec import TypeSpec
from function import Function

class FunctionRegistry:
    """Registry for storing and looking up Function objects by name."""
    
    def __init__(self):
        self._functions: Dict[str, Function] = {}
    
    def register(self, name: str, function: Function) -> None:
        """Register a Function with the given name."""
        self._functions[name] = function
    
    def lookup(self, name: str) -> Optional[Function]:
        """Look up a Function by name."""
        return self._functions.get(name)
    
    def __contains__(self, name: str) -> bool:
        """Check if a function name is registered."""
        return name in self._functions
    
    def __getitem__(self, name: str) -> Function:
        """Get a Function by name (raises KeyError if not found)."""
        return self._functions[name]
    
    def keys(self):
        """Return all registered function names."""
        return self._functions.keys()
    
    def values(self):
        """Return all registered Function objects."""
        return self._functions.values()
    
    def items(self):
        """Return all (name, Function) pairs."""
        return self._functions.items()

