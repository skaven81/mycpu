from pycparser import c_ast
from dataclasses import dataclass
from typing import Optional, Dict, List, Union
from literal import Literal

class LiteralRegistry:
    """Registry for storing and looking up Literal objects."""

    def __init__(self):
        self._literals: Dict[str, Literal] = {}  # label -> Literal
        self._content_to_label: Dict[tuple, str] = {}  # (content, type) -> label
        self._counters: Dict[str, int] = {}  # type -> counter for generating labels

    def register(self, content: str, literal_type: str, size: int = 0) -> Literal:
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
            size=size
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


class LiteralCollector(c_ast.NodeVisitor):
    """
    Visitor that collects literals (strings, floats, arrays) and registers them.
    Skips simple integer literals as they can be included directly in code generation.
    After instantiation, call visit(ast) to perform collection.
    """

    def __init__(self, literal_registry: LiteralRegistry):
        self.literal_registry = literal_registry

    def visit_Constant(self, node: c_ast.Constant) -> None:
        """Visit a constant node and register non-integer literals."""
        # Skip integer literals (int, long, unsigned, etc.)
        if node.type in ('int', 'long', 'unsigned', 'long long',
                        'unsigned long', 'unsigned long long'):
            return

        # Handle character literals (could be treated as integers in some cases)
        if node.type == 'char':
            # Skip single char literals as they're essentially small integers
            return

        # Handle string literals
        if node.type == 'string':
            # Remove quotes from the string value
            content = node.value
            # Calculate size (including null terminator)
            # The value includes quotes, so we need to process escape sequences
            size = len(content) - 1  # Rough estimate, actual size depends on escapes
            self.literal_registry.register(content, 'string', size)

        # Handle floating point literals
        elif node.type in ('float', 'double', 'long double'):
            content = node.value
            size = {'float': 4, 'double': 8, 'long double': 16}.get(node.type, 8)
            self.literal_registry.register(content, node.type, size)

    def visit_InitList(self, node: c_ast.InitList) -> None:
        """
        Visit an initializer list (for arrays/structs).
        Register array initializers as literals if they're constant.
        """
        # Check if all elements are constants
        if self._is_constant_init_list(node):
            # Convert the init list to a string representation
            content = self._init_list_to_string(node)
            # We don't know the exact size without type info, so use 0 for now
            self.literal_registry.register(content, 'array', 0)

        # Continue visiting children
        self.generic_visit(node)

    def _is_constant_init_list(self, node: c_ast.InitList) -> bool:
        """Check if an initializer list contains only constant values."""
        if not node.exprs:
            return True

        for expr in node.exprs:
            if isinstance(expr, c_ast.Constant):
                continue
            elif isinstance(expr, c_ast.InitList):
                if not self._is_constant_init_list(expr):
                    return False
            else:
                return False
        return True

    def _init_list_to_string(self, node: c_ast.InitList) -> str:
        """Convert an initializer list to a string representation."""
        if not node.exprs:
            return "{}"

        elements = []
        for expr in node.exprs:
            if isinstance(expr, c_ast.Constant):
                elements.append(expr.value)
            elif isinstance(expr, c_ast.InitList):
                elements.append(self._init_list_to_string(expr))

        return "{" + ", ".join(elements) + "}"

