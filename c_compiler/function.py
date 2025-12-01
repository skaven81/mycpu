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
    storage: Optional[str] = ""
    
    # Reference to type registry for looking up types
    type_registry: Optional[TypeRegistry] = field(default=None, repr=False)

    def c_str(self):
        ret = ""
        if self.storage:
            ret = f"{self.storage} "
        ret += self.return_type.c_str()
        ret += f'{self.name}('
        ret += ", ".join([ p.c_str() for p in self.parameters.values() ])
        ret += ')'
        return ret

    def asm_name(self):
        if self.storage == 'static':
            return f".{self.name}"
        else:
            return f":{self.name}"
