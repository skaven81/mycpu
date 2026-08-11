import struct
from mus_writer import encode_record, write_mus, TERMINATOR, MAX_COMMENT_LEN


def test_encode_record_basic():
    rec = encode_record(4189, 16384, "A4", line=1)
    assert rec == struct.pack(">HH12s", 4189, 16384, b"A4" + b"\0" * 10)
    assert len(rec) == 16


def test_encode_record_empty_comment():
    rec = encode_record(0, 8192, "", line=1)
    divisor, duration, comment = struct.unpack(">HH12s", rec)
    assert (divisor, duration, comment) == (0, 8192, b"\0" * 12)


def test_encode_record_truncates_long_comment_and_warns():
    warnings = []
    long_comment = "this comment is way too long"
    rec = encode_record(1, 1, long_comment, line=5, warn=warnings.append)
    divisor, duration, comment = struct.unpack(">HH12s", rec)
    assert comment == long_comment.encode("ascii")[:MAX_COMMENT_LEN].ljust(12, b"\0")
    assert len(warnings) == 1
    assert "line 5" in warnings[0]


def test_encode_record_exact_fit_no_warning():
    warnings = []
    eleven_chars = "12345678901"
    assert len(eleven_chars) == MAX_COMMENT_LEN
    encode_record(1, 1, eleven_chars, line=1, warn=warnings.append)
    assert warnings == []


def test_write_mus_appends_terminator(tmp_path):
    out = tmp_path / "TEST.MUS"
    records = [
        encode_record(4189, 16384, "A4", line=1),
        encode_record(0, 8192, "", line=2),
    ]
    write_mus(str(out), records)
    data = out.read_bytes()
    assert data == records[0] + records[1] + TERMINATOR


def test_write_mus_empty_song_is_just_terminator(tmp_path):
    out = tmp_path / "EMPTY.MUS"
    write_mus(str(out), [])
    assert out.read_bytes() == TERMINATOR
