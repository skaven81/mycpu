"""`.oas` container: round-trip, validation errors, assets, atomic write."""

import io
import json
import os
import zipfile

import pytest

from studio.io import project_file
from studio.io.project_file import (
    ASSET_DIR,
    MIMETYPE,
    ProjectFileError,
    asset_name,
    load_project,
    read_assets,
    save_project,
)
from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.layers import BlankLayer, BoxLayer, ImageLayer, TextLayer


def _rich_doc():
    doc = Document(font_bank=3)

    blank = BlankLayer(name="bg", offx=1, offy=2)
    blank.set_local(0, 0, Cell(0x41, 0x0F))
    blank.set_local(3, 4, Cell(0xDB, 0x30))

    box = BoxLayer(name="frame", offx=5, offy=0,
                   params={"style": "double", "w": 8, "h": 4})
    box.set_local(0, 0, Cell(0xC9, 0x2A))

    text = TextLayer(name="caption", offx=0, offy=10,
                     text="hi\nthere", rect=(0, 10, 12, 3))
    text.set_local(1, 0, Cell(ord("h"), 0x3F))

    image = ImageLayer(name="logo", offx=20, offy=20,
                       source_ref="deadbeef.png", params={"crop": [0, 0, 4, 4]})
    image.set_local(0, 0, Cell(0xB0, 0x15))

    for layer in (blank, box, text, image):
        doc.add_layer(layer)
    doc.project_palette = [{"name": "ink", "attr": 0x3F}, {"name": "shade", "attr": 0x15}]
    doc.active_layer_index = 2
    return doc


def test_roundtrip_all_layer_kinds(tmp_path):
    doc = _rich_doc()
    path = str(tmp_path / "proj.oas")
    save_project(doc, path)
    loaded = load_project(path)

    assert loaded.to_dict() == doc.to_dict()
    assert loaded.composite() == doc.composite()
    assert loaded.font_bank == 3
    assert loaded.active_layer_index == 2
    assert [type(x) for x in loaded.layers] == [BlankLayer, BoxLayer, TextLayer, ImageLayer]


def test_archive_shape(tmp_path):
    path = str(tmp_path / "p.oas")
    save_project(_rich_doc(), path)
    with zipfile.ZipFile(path) as zf:
        names = zf.namelist()
        assert names[0] == "mimetype"
        assert zf.read("mimetype") == MIMETYPE.encode("ascii")
        info = zf.getinfo("mimetype")
        assert info.compress_type == zipfile.ZIP_STORED
        assert "document.json" in names
        body = json.loads(zf.read("document.json"))
        assert body["schema"] == 1
        # indent=2 pretty-printed
        assert b"\n  " in zf.read("document.json")


def test_load_not_a_zip(tmp_path):
    p = tmp_path / "junk.oas"
    p.write_bytes(b"this is not a zip file at all")
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert str(ei.value)


def test_load_missing_document_member(tmp_path):
    p = tmp_path / "nodoc.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", MIMETYPE)
        zf.writestr("readme.txt", "nothing here")
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert "document.json" in str(ei.value)


def test_load_wrong_mimetype(tmp_path):
    p = tmp_path / "wrong.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", "application/zip")
        zf.writestr("document.json", json.dumps(Document().to_dict()))
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert "mimetype" in str(ei.value)


def test_load_bad_schema_is_wrapped(tmp_path):
    p = tmp_path / "badschema.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", MIMETYPE)
        zf.writestr("document.json", json.dumps({"schema": 99}))
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert str(ei.value)


def test_load_bad_json(tmp_path):
    p = tmp_path / "badjson.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", MIMETYPE)
        zf.writestr("document.json", "{not json,,,")
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert "JSON" in str(ei.value)


def test_assets_write_and_read(tmp_path):
    png = b"\x89PNG\r\n\x1a\n" + b"fake-image-data"
    name = asset_name(png)
    assert name.endswith(".png") and len(name) == 64 + 4

    path = str(tmp_path / "withassets.oas")
    save_project(Document(), path, assets={name: png})

    got = read_assets(path)
    assert got == {name: png}
    with zipfile.ZipFile(path) as zf:
        assert ASSET_DIR + name in zf.namelist()


def test_read_assets_empty_for_phase2_file(tmp_path):
    path = str(tmp_path / "plain.oas")
    save_project(_rich_doc(), path)
    assert read_assets(path) == {}


def test_save_is_atomic_on_failure(tmp_path, monkeypatch):
    path = tmp_path / "keepme.oas"
    save_project(Document(font_bank=1), str(path))
    original = path.read_bytes()

    real_zipfile = zipfile.ZipFile

    class Boom(RuntimeError):
        pass

    def explode(*a, **kw):
        raise Boom("disk full")

    monkeypatch.setattr(project_file.zipfile, "ZipFile", explode)
    with pytest.raises(Boom):
        save_project(Document(font_bank=2), str(path))

    monkeypatch.setattr(project_file.zipfile, "ZipFile", real_zipfile)
    assert path.read_bytes() == original  # untouched
    # no stray temp files left behind
    leftovers = [q.name for q in tmp_path.iterdir() if q.name != "keepme.oas"]
    assert leftovers == []


# ==========================================================================
# QA hardening pass (Phase 2) -- appended adversarial cases.
# ==========================================================================

def test_roundtrip_non_ascii_layer_names_and_palette(tmp_path):
    doc = Document(font_bank=2)
    a = BlankLayer(name="café —  résumé")
    a.set_local(0, 0, Cell(0x41, 0x0F))
    b = BoxLayer(name="边框 ボックス 🖼", params={"style": "single"})
    b.set_local(1, 1, Cell(0xDA, 0x2A))
    doc.add_layer(a)
    doc.add_layer(b)
    doc.project_palette = [
        {"name": "ばら色", "attr": 0x30},
        {"name": "vert forêt", "attr": 0x08},
    ]

    path = str(tmp_path / "unicode.oas")
    save_project(doc, path)
    loaded = load_project(path)

    assert [lyr.name for lyr in loaded.layers] == [a.name, b.name]
    assert loaded.project_palette == doc.project_palette
    assert loaded.to_dict() == doc.to_dict()
    # the JSON member is real UTF-8, not \uXXXX-escaped ASCII
    with zipfile.ZipFile(path) as zf:
        raw = zf.read("document.json")
    assert "café".encode("utf-8") in raw
    assert "边框".encode("utf-8") in raw


def test_load_empty_file_is_projectfileerror(tmp_path):
    p = tmp_path / "empty.oas"
    p.write_bytes(b"")
    with pytest.raises(ProjectFileError):
        load_project(str(p))


@pytest.mark.parametrize("body", ["[]", '"x"', "5", "3.14", "true", "null"])
def test_load_non_object_document_json_is_projectfileerror(tmp_path, body):
    p = tmp_path / "nonobj.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", MIMETYPE)
        zf.writestr("document.json", body)
    with pytest.raises(ProjectFileError):
        load_project(str(p))


def test_load_document_json_as_directory_entry(tmp_path):
    p = tmp_path / "dirmember.oas"
    with zipfile.ZipFile(p, "w") as zf:
        zf.writestr("mimetype", MIMETYPE)
        zf.writestr("document.json/", b"")   # a directory member, not a file
    with pytest.raises(ProjectFileError) as ei:
        load_project(str(p))
    assert "document.json" in str(ei.value)


def test_load_truncated_zip_is_projectfileerror(tmp_path):
    good = tmp_path / "good.oas"
    save_project(_rich_doc(), str(good))
    raw = good.read_bytes()
    for cut in (len(raw) // 2, len(raw) - 1, len(raw) - 3, len(raw) - 20):
        p = tmp_path / f"trunc{cut}.oas"
        p.write_bytes(raw[:cut])
        with pytest.raises(ProjectFileError):
            load_project(str(p))


def test_save_to_nonexistent_directory_errors_without_partial_file(tmp_path):
    missing = tmp_path / "no_such_dir"
    target = missing / "out.oas"
    with pytest.raises((FileNotFoundError, ProjectFileError)):
        save_project(Document(), str(target))
    assert not missing.exists()          # nothing was created
    assert not target.exists()


def test_save_to_readonly_directory_leaves_original_intact(tmp_path):
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        pytest.skip("root ignores directory write permissions")
    ro = tmp_path / "ro"
    ro.mkdir()
    target = ro / "keep.oas"
    save_project(Document(font_bank=1), str(target))
    original = target.read_bytes()

    os.chmod(ro, 0o500)
    try:
        with pytest.raises((PermissionError, OSError, ProjectFileError)):
            save_project(Document(font_bank=9), str(target))
    finally:
        os.chmod(ro, 0o700)

    assert target.read_bytes() == original            # untouched
    leftovers = sorted(q.name for q in ro.iterdir())
    assert leftovers == ["keep.oas"]                  # no stray temp file


def test_read_assets_multiple_and_ignores_directory_members(tmp_path):
    pngs = {
        asset_name(b"\x89PNG-one"): b"\x89PNG-one",
        asset_name(b"\x89PNG-two-longer"): b"\x89PNG-two-longer",
        asset_name(b"\x89PNG-three"): b"\x89PNG-three",
    }
    path = str(tmp_path / "multi.oas")
    save_project(Document(), path, assets=pngs)

    # sneak in bare directory members under assets/
    with zipfile.ZipFile(path, "a") as zf:
        zf.writestr("assets/", b"")
        zf.writestr("assets/nested/", b"")

    got = read_assets(path)
    assert got == pngs                                 # dir members ignored
    assert all(not k.endswith("/") for k in got)
