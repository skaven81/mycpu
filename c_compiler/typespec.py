from pycparser import c_ast
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Union

@dataclass
class TypeSpec:
    """Represents a C type specification with all its properties."""
    name: Optional[str] = None
    base_type: Optional[str] = None  # For simple types like 'int', 'char'
    is_struct: bool = False
    struct_name: Optional[str] = None
    struct_members: List['Variable'] = field(default_factory=list)
    
    # Reference to registry for looking up dependent types
    _registry: 'TypeRegistry' = field(default=None, repr=False)

    def is_signed(self) -> bool:
        # If we have a registry, try to look up the type
        if self._registry:
            try:
                resolved = self._registry.lookup(self.base_type)
                if resolved and resolved != self:
                    return resolved.is_signed()
            except KeyError:
                pass

        if self.is_struct:
            return False

        if 'unsigned' in self.base_type:
            return False
        if 'void' in self.base_type:
            return False
        return True

    def sizeof(self) -> int:
        # Struct size
        if self.is_struct:
            if not self.struct_members:
                # Empty or opaque struct
                return 0
            total = 0
            for member in self.struct_members:
                total += member.sizeof()
            return total
        
        # Base types
        if self.base_type:
            base_sizes = {
                'bool': 1,
                'char': 1,
                'signed char': 1,
                'unsigned char': 1,
                'short': 2,
                'short int': 2,
                'signed short': 2,
                'signed short int': 2,
                'unsigned short': 2,
                'unsigned short int': 2,
                'int': 2,
                'signed': 2,
                'signed int': 2,
                'unsigned': 2,
                'unsigned int': 2,
                'void': 0,
            }
            if self.base_type in base_sizes:
                return base_sizes[self.base_type]
        
        # If we have a registry, try to look up the type
        if self._registry:
            try:
                resolved = self._registry.lookup(self.base_type)
                if resolved and resolved != self:
                    return resolved.sizeof()
            except KeyError:
                pass

        raise NotImplementedError(f"Unable to compute size of {self.base_type}{' (with type registry)' if self._registry else ' (no type registry present)'}")
    
    def struct_member(self, field_name):
        if not self.is_struct:
            raise ValueError("Cannot get member_offset of a non-struct")
        if not self.struct_members:
            # Empty or opaque struct
            return None

        for member in self.struct_members:
            if member.name == field_name:
                return member

        raise ValueError(f"Field {field_name} not found in struct type {self.name}")
