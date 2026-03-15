"""
ASCII frame converter for Odyssey video.

Delegates to the external 'ascii-image-converter' Go binary.
See: https://github.com/TheZoraiz/ascii-image-converter
"""

import subprocess

from common import DISPLAY_W, DISPLAY_H, pad_frame


def image_to_ascii_frame(img_path, width=DISPLAY_W, height=DISPLAY_H):
    """
    Convert an image file to an Odyssey ASCII frame (raw bytes).

    Shells out to 'ascii-image-converter' which must be installed and on PATH.
    Strips all newlines from output, encodes to ASCII bytes, and pads to a
    multiple of FRAME_ALIGN (128) bytes.

    Args:
        img_path: Path to the source image file (str or Path).
        width: Output width in characters (default 64).
        height: Output height in characters (default 60).

    Returns:
        bytes: Raw frame data, length is a multiple of 128.

    Raises:
        RuntimeError: If ascii-image-converter is not found or exits non-zero.
    """
    try:
        result = subprocess.run(
            [
                "ascii-image-converter",
                str(img_path),
                "--dimensions", f"{width},{height}",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
    except FileNotFoundError:
        raise RuntimeError(
            "ascii-image-converter not found. "
            "Install from https://github.com/TheZoraiz/ascii-image-converter"
        )
    except subprocess.CalledProcessError as exc:
        raise RuntimeError(
            f"ascii-image-converter failed (exit {exc.returncode}): {exc.stderr.strip()}"
        )

    raw = result.stdout.replace("\n", "")
    # Trim to exact expected size if the tool outputs trailing whitespace/headers
    expected = width * height
    if len(raw) > expected:
        raw = raw[:expected]
    elif len(raw) < expected:
        raw = raw.ljust(expected)

    frame = raw.encode("ascii", errors="replace")
    return pad_frame(frame)
