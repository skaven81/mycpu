from dataclasses import dataclass

@dataclass
class Literal:
    """Represents a C literal constant that needs to be stored in data section."""
    content: str        # The actual literal value
    literal_type: str   # 'string', 'float', 'array', etc.
    label: str          # The generated label like '.data_string_0'
    size: int = 0       # Size in bytes if applicable
    comment: str = None # Comment to include when emitting the literal

    def asm(self):
        if self.literal_type == 'string':
            # ascii() escapes non-printable/non-ASCII characters (e.g. a
            # raw newline byte becomes the two-character sequence \n,
            # which the assembler's data-emission loop un-escapes back to
            # a real newline byte), but it only escapes a literal '"' when
            # that happens to be the quote character *it* chose to wrap
            # the repr in -- it prefers single quotes whenever content
            # contains a double quote, so a double quote in content is
            # otherwise left completely unescaped. Escaping it explicitly
            # here is what lets the assembler's own \" escape (see
            # assembler.py's split_asm_line/data grammar) receive it
            # correctly instead of the embedded '"' being mistaken for
            # the end of the assembler's quoted string.
            escaped = ascii(self.content)[1:-1].replace('"', '\\"')
            return '"' + escaped + '\\0"'
        else:
            return self.content
