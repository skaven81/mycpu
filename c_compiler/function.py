from typespec import TypeSpec
from typecollection import TypeRegistry
from dataclasses import dataclass, field
from typing import Optional, Dict

@dataclass
class Function:
    """Represents a C function definition with its signature."""
    name: str
    return_type: Optional[TypeSpec] = None
    parameters: Dict[str, TypeSpec] = field(default_factory=dict)
    
    # Reference to type registry for looking up types
    _type_registry: Optional[TypeRegistry] = field(default=None, repr=False)

