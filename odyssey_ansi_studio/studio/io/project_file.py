"""
`.oas` project container -- read and write.

WHAT
    An `.oas` file is a plain zip archive with these members:

      * ``mimetype``          -- stored (uncompressed), first member; its
                                 bytes are exactly ``MIMETYPE``.  A cheap
                                 "is this really one of ours" check on load.
      * ``document.json``     -- ``Document.to_dict()`` (schema 1), UTF-8,
                                 ``json.dumps(indent=2)``.
      * ``assets/<sha256hex>.png`` -- imported source images, keyed by the
                                 SHA-256 of their bytes.  Phase 2 writes none;
                                 :func:`save_project` takes an ``assets`` dict
                                 and :func:`read_assets` returns one, so Phase
                                 6 drops in without an API change.

WHY
    Zip keeps the human-readable JSON separate from binary assets, is
    inspectable with any unzip tool, and needs nothing outside the standard
    library.  The write is atomic (temp file in the same directory, then
    ``os.replace``) so a crash mid-save never destroys the previous file.
"""

import hashlib
import json
import os
import tempfile
import zipfile

from studio.model.document import Document

OAS_EXT = ".oas"
ASSET_DIR = "assets/"
MIMETYPE = "application/x-odyssey-ansi-studio"

_MIMETYPE_MEMBER = "mimetype"
_DOCUMENT_MEMBER = "document.json"


class ProjectFileError(Exception):
    """Raised when an `.oas` file cannot be read or is not a valid project."""


def asset_name(png_bytes: bytes) -> str:
    """Canonical ``assets/`` member basename for a blob: ``<sha256hex>.png``.

    Phase 6 helper -- keeps the naming rule in one place.
    """
    return hashlib.sha256(png_bytes).hexdigest() + ".png"


def save_project(doc: Document, path: str, *, assets: dict | None = None) -> None:
    """Write `doc` to `path` as an `.oas` archive (atomic replace).

    Args:
        doc: the document to serialize.
        assets: optional ``{"<sha256hex>.png": png_bytes}`` map; each entry is
            stored under ``assets/``.  A key that already starts with
            ``assets/`` is used as-is.
    """
    payload = json.dumps(doc.to_dict(), indent=2, ensure_ascii=False).encode("utf-8")

    target_dir = os.path.dirname(os.path.abspath(path)) or "."
    try:
        fd, tmp_path = tempfile.mkstemp(dir=target_dir, prefix=".oas-", suffix=".tmp")
    except OSError as exc:
        raise ProjectFileError(f"cannot write {path!r}: {exc}") from exc
    os.close(fd)
    try:
        with zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as zf:
            # mimetype: first, and stored uncompressed (ODF-style magic).
            info = zipfile.ZipInfo(_MIMETYPE_MEMBER)
            info.compress_type = zipfile.ZIP_STORED
            zf.writestr(info, MIMETYPE.encode("ascii"))

            zf.writestr(_DOCUMENT_MEMBER, payload)

            for name, blob in (assets or {}).items():
                arcname = name if name.startswith(ASSET_DIR) else ASSET_DIR + name
                zf.writestr(arcname, blob)
        os.replace(tmp_path, path)
    except BaseException as exc:
        # Leave the original file untouched; clean up the temp.
        try:
            os.remove(tmp_path)
        except OSError:
            pass
        if isinstance(exc, OSError):
            raise ProjectFileError(f"cannot write {path!r}: {exc}") from exc
        raise


def _open_archive(path: str) -> zipfile.ZipFile:
    if not os.path.exists(path):
        raise ProjectFileError(f"{path!r}: no such file")
    if not zipfile.is_zipfile(path):
        raise ProjectFileError(f"{path!r} is not a .oas file (not a zip archive)")
    try:
        return zipfile.ZipFile(path)
    except zipfile.BadZipFile as exc:  # pragma: no cover - is_zipfile screens most
        raise ProjectFileError(f"{path!r} is a corrupt zip archive: {exc}") from exc


def _check_mimetype(zf: zipfile.ZipFile, path: str) -> None:
    if _MIMETYPE_MEMBER not in zf.namelist():
        return  # optional member; absence is tolerated
    got = zf.read(_MIMETYPE_MEMBER).decode("ascii", "replace").strip()
    if got != MIMETYPE:
        raise ProjectFileError(
            f"{path!r} has the wrong mimetype: expected {MIMETYPE!r}, got {got!r}"
        )


def load_project(path: str) -> Document:
    """Read an `.oas` archive and return its `Document`.

    Raises:
        ProjectFileError: not a zip, wrong mimetype, missing ``document.json``,
            bad JSON, or a document dict `Document.from_dict` rejects (its
            ``ValueError`` message is wrapped in).
    """
    with _open_archive(path) as zf:
        _check_mimetype(zf, path)
        if _DOCUMENT_MEMBER not in zf.namelist():
            raise ProjectFileError(f"{path!r} has no {_DOCUMENT_MEMBER} member")
        raw = zf.read(_DOCUMENT_MEMBER)

    try:
        data = json.loads(raw)
    except (ValueError, UnicodeDecodeError) as exc:
        raise ProjectFileError(f"{_DOCUMENT_MEMBER} is not valid JSON: {exc}") from exc

    try:
        return Document.from_dict(data)
    except ValueError as exc:
        raise ProjectFileError(
            f"{_DOCUMENT_MEMBER} is not a valid document: {exc}"
        ) from exc


def read_assets(path: str) -> dict:
    """Return ``{"<basename>.png": bytes}`` for every ``assets/`` member.

    An `.oas` with no assets (every Phase 2 file) returns ``{}``.
    """
    out: dict = {}
    with _open_archive(path) as zf:
        for name in zf.namelist():
            if name.startswith(ASSET_DIR) and not name.endswith("/"):
                out[name[len(ASSET_DIR):]] = zf.read(name)
    return out
