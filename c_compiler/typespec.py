from pycparser import c_ast
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Union

@dataclass
class TypeSpec:
    """Represents a C type specification with all its properties."""
    name: str
    base_type: Optional[str] = None  # For simple types like 'int', 'char'
    is_pointer: bool = False
    pointer_depth: int = 0
    is_array: bool = False
    array_dims: List[Optional[int]] = field(default_factory=list)
    is_struct: bool = False
    struct_name: Optional[str] = None
    struct_members: List['TypeSpec'] = field(default_factory=list)
    qualifiers: List[str] = field(default_factory=list)  # const, volatile, etc.
    
    # Reference to registry for looking up dependent types
    _registry: 'TypeRegistry' = field(default=None, repr=False)

    def is_signed(self) -> bool:
        if self.is_struct:
            return False
        if self.is_pointer:
            return False

        # If we have a registry, try to look up the type
        if self._registry:
            try:
                resolved = self._registry.lookup(self.base_type)
                if resolved and resolved != self:
                    return resolved.is_signed()
            except KeyError:
                pass

        if 'unsigned' in self.base_type:
            return False
        if 'void' in self.base_type:
            return False
        return True

    def sizeof(self) -> int:
        """Calculate the size of this type in bytes."""
        # Pointer size
        if self.is_pointer:
            return 2
        
        # Array size
        if self.is_array:
            element_size = self.sizeof_element()
            total_size = element_size
            for dim in self.array_dims:
                if dim is not None:
                    total_size *= dim
                else:
                    # Unsized array, treat as pointer
                    return 2
            return total_size
        
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
    
    def sizeof_element(self) -> int:
        """Helper to calculate size of array element."""
        # Create a temporary non-array version to calculate element size
        if not self.is_array and not self.is_pointer:
            return self.sizeof()
        
        # Build element type
        if self.base_type:
            return TypeSpec(name='', base_type=self.base_type, _registry=self._registry).sizeof()
        if self.is_struct:
            return TypeSpec(
                name='',
                is_struct=True,
                struct_name=self.struct_name,
                struct_members=self.struct_members,
                _registry=self._registry
            ).sizeof()
        return 2

    def field_offset(self, field_name) -> (int, 'TypeSpec',):
        if not self.is_struct:
            return (0, self,)
        if not self.struct_members:
            # Empty or opaque struct
            return (0, self,)

        offset = 0
        for member in self.struct_members:
            if member.name == field_name:
                return (offset, member,)
            offset += member.sizeof()

        raise ValueError(f"Field {field_name} not found in struct type {self.name}")

    def c_str(self) -> str:
        return f"{self.base_type} {'*'*self.pointer_depth}{self.name}"

