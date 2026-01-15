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
        return f"{self.storage_class if self.storage_class != 'auto' else ''} {'struct ' if self.typespec.is_struct else ''}{self.typespec.name} {'*'*self.pointer_depth}{'' if self.is_type_wrapper else self.name}{'[]' if self.is_array else ''}{' (virtual)' if self.is_virtual else ''}"

    def sizeof(self) -> int:
        """Calculate the size of this type in bytes."""
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

        # Pointer size
        if self.is_pointer:
            return 2

        # Simple type or struct, return size of type
        return self.typespec.sizeof()
 
    def sizeof_element(self) -> int:
        if self.is_pointer and self.pointer_depth > 1:
            return 2 # elements are pointers
        elif self.is_array and self.is_pointer:
            return 2 # elements are pointers
        return self.typespec.sizeof()

    def pointer_arithmetic_size(self) -> Optional[int]:
        """
        Calculate the size in bytes to advance/retreat for pointer arithmetic.
        Returns None if this variable is not a pointer type.

        For pointer arithmetic (++, --, +=, -=, +, -), the pointer moves by
        the size of the pointed-to type, not the size of the pointer itself.

        Examples:
          int *p;           // moves by sizeof(int) = 2
          char *p;          // moves by sizeof(char) = 1
          struct foo *p;    // moves by sizeof(struct foo)
          int **p;          // moves by sizeof(int*) = 2 (pointer size)
          int (*p)[5];      // moves by sizeof(int[5]) = 5 * sizeof(int) = 10
        """
        # Only pointers participate in pointer arithmetic
        if not self.is_pointer:
          return None

        # For multi-level pointers (int**, char***, etc.), we move by pointer size
        # because we're pointing to another pointer
        if self.pointer_depth > 1:
          return 2  # Size of a pointer

        # For single-level pointers, check if pointing to an array
        if self.is_array and self.array_dims:
          # Pointer to array: moves by size of entire array
          # e.g., int (*p)[5] moves by 5 * sizeof(int)
          element_size = self.typespec.sizeof()
          total_size = element_size
          for dim in self.array_dims:
            if dim is not None:
              total_size *= dim
            else:
              # Unsized dimension - treat as pointer
              return 2
          return total_size

        # void *ptr gets single-byte behavior
        if self.typespec.base_type == 'void':
            return 1

        # Regular pointer to a type (including structs)
        # Moves by the size of the pointed-to type
        return self.typespec.sizeof()
