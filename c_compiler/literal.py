from dataclasses import dataclass

@dataclass
class Literal:
    """Represents a C literal constant that needs to be stored in data section."""
    content: str  # The actual literal value
    literal_type: str  # 'string', 'float', 'array', etc.
    label: str  # The generated label like '.data_string_0'
    size: int = 0  # Size in bytes if applicable
