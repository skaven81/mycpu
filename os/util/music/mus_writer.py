#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab
"""Binary .MUS record encoding and file writer for mkmus.py."""

import struct

MAX_COMMENT_LEN = 11  # 12-byte field, must stay null-terminated
TERMINATOR = b"\0" * 16


def encode_record(divisor: int, duration: int, comment: str, line: int, warn=None) -> bytes:
    """Encode one 16-byte note record: divisor (u16 BE), duration (u16 BE),
    comment (12 bytes, null-padded/truncated ASCII). `warn`, if given, is
    called with a message when the comment must be truncated to fit."""
    comment_bytes = comment.encode("ascii", errors="replace")
    if len(comment_bytes) > MAX_COMMENT_LEN:
        if warn is not None:
            warn(f"line {line}: comment truncated to {MAX_COMMENT_LEN} characters")
        comment_bytes = comment_bytes[:MAX_COMMENT_LEN]
    comment_field = comment_bytes.ljust(12, b"\0")
    return struct.pack(">HH12s", divisor, duration, comment_field)


def write_mus(path, records: list) -> None:
    """Write a .MUS file: each 16-byte record in order, followed by the
    all-zero terminator record."""
    with open(path, "wb") as f:
        for rec in records:
            f.write(rec)
        f.write(TERMINATOR)
