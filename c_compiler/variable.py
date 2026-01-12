"""
Variable management for C compiler
Handles storage location and code generation for variable access
"""

from dataclasses import dataclass, field
from typing import Optional, List, Dict
from typespec import TypeSpec

@dataclass
class Variable:
    typespec: TypeSpec
    name: str = None
    storage_class: str = 'auto'  # auto, static, register, etc.
    qualifiers: List[str] = field(default_factory=list)  # const, volatile, etc.
    offset: Optional[int] = None # only for non-static locals and parameter vars
    kind: Optional[str] = None   # global, param, struct_member, or local
    is_array: bool = False
    array_dims: List[Optional[int]] = field(default_factory=list)
    is_pointer: bool = False
    pointer_depth: int = 0
    is_struct_member: bool = False
    is_type_wrapper: bool = False
    is_virtual: bool = False

    # the assembler can't handle labels shorter than 4 characters, so
    # make sure all variable names get padded out when converted to labels
    def padded_name(self):
        return f"var_{self.name}"

    def friendly_name(self):
        return f"{'struct ' if self.typespec.is_struct else ''}{self.typespec.name} {'*'*self.pointer_depth}{'' if self.is_type_wrapper else self.name}{'[]' if self.is_array else ''}{' (virtual)' if self.is_virtual else ''}"

    def sizeof(self) -> int:
        """Calculate the size of this type in bytes."""
        # Pointer size
        if self.is_pointer:
            return 2

        # variadic parameter
        if self.typespec.base_type == '...':
            return 0
        
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

        # Simple type or struct, return size of type
        return self.typespec.sizeof()
 
    def sizeof_element(self) -> int:
        return self.typespec.sizeof()


