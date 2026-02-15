from typespec import TypeSpec
from variable import Variable
from dataclasses import dataclass, field
from typing import Optional, List

@dataclass
class Function:
    """Represents a C function definition with its signature."""
    name: Optional[str] = None
    return_type: Optional[TypeSpec] = None
    return_is_pointer: bool = False
    return_pointer_depth: int = 0
    parameters: List[Variable] = field(default_factory=list)
    storage: Optional[str] = ""

    def return_sizeof(self):
        """Size of the return value: 2 for pointers, else return_type.sizeof()."""
        if self.return_is_pointer:
            return 2
        return self.return_type.sizeof()

    def c_str(self):
        ret = ""
        if self.storage:
            ret = self.storage + " "
        ret += str(self.return_type.name + " ")
        ret += f'{self.name}('
        if self.parameters:
            ret += ", ".join([ p.friendly_name() for p in self.parameters ])
        ret += ')'
        return ret

    def asm_name(self):
        if self.storage == 'static':
            return f".{self.name}"
        else:
            return f":{self.name}"
