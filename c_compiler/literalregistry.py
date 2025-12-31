from dataclasses import dataclass
from typing import Optional, Dict, List, Union
from literal import Literal

class LiteralRegistry:
    """Registry for storing and looking up Literal objects."""

    def __init__(self):
        self._literals: Dict[str, Literal] = {}  # label -> Literal
        self._content_to_label: Dict[tuple, str] = {}  # (content, type) -> label
        self._counters: Dict[str, int] = {}  # type -> counter for generating labels

    def register(self, content: str, literal_type: str, size: int = 0, comment: str = None) -> Literal:
        """
        Register a literal and return the Literal object.
        If the same content with same type already exists, return existing literal.
        """
        # Check if this literal already exists
        key = (content, literal_type)
        if key in self._content_to_label:
            existing_label = self._content_to_label[key]
            return self._literals[existing_label]

        # Generate new label
        if literal_type not in self._counters:
            self._counters[literal_type] = 0

        label = f".data_{literal_type}_{self._counters[literal_type]}"
        self._counters[literal_type] += 1

        # Create and store the literal
        literal = Literal(
            content=content,
            literal_type=literal_type,
            label=label,
            size=size,
            comment=comment
        )

        self._literals[label] = literal
        self._content_to_label[key] = label

        return literal

    def lookup_by_label(self, label: str) -> Optional[Literal]:
        """Look up a Literal by its label."""
        return self._literals.get(label)

    def lookup_by_content(self, content: str, literal_type: str) -> Optional[Literal]:
        """Look up a Literal by its content and type."""
        key = (content, literal_type)
        label = self._content_to_label.get(key)
        if label:
            return self._literals[label]
        return None

    def __contains__(self, label: str) -> bool:
        """Check if a label is registered."""
        return label in self._literals

    def __getitem__(self, label: str) -> Literal:
        """Get a Literal by label (raises KeyError if not found)."""
        return self._literals[label]

    def get_all_literals(self) -> List[Literal]:
        """Return all registered literals."""
        return list(self._literals.values())

    def get_literals_by_type(self, literal_type: str) -> List[Literal]:
        """Return all literals of a specific type."""
        return [lit for lit in self._literals.values() if lit.literal_type == literal_type]

    def keys(self):
        """Return all registered labels."""
        return self._literals.keys()

    def values(self):
        """Return all registered Literal objects."""
        return self._literals.values()

    def items(self):
        """Return all (label, Literal) pairs."""
        return self._literals.items()


