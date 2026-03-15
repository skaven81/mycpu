import pytest
from unittest.mock import patch, MagicMock
import subprocess

from ascii_converter import image_to_ascii_frame


def _make_mock_output(width, height):
    """Return a stdout string simulating ascii-image-converter output."""
    row = "X" * width
    return "\n".join([row] * height) + "\n"


def test_output_size_default():
    width, height = 64, 60
    mock_out = _make_mock_output(width, height)
    with patch("subprocess.run") as mock_run:
        mock_run.return_value = MagicMock(stdout=mock_out, returncode=0)
        result = image_to_ascii_frame("fake.png", width=width, height=height)
    assert len(result) == width * height  # 3840, already a multiple of 128


def test_output_size_custom_height():
    width, height = 64, 48
    mock_out = _make_mock_output(width, height)
    with patch("subprocess.run") as mock_run:
        mock_run.return_value = MagicMock(stdout=mock_out, returncode=0)
        result = image_to_ascii_frame("fake.png", width=width, height=height)
    assert len(result) == width * height  # 3072


def test_multiple_of_128():
    for height in [48, 50, 52, 60]:
        width = 64
        mock_out = _make_mock_output(width, height)
        with patch("subprocess.run") as mock_run:
            mock_run.return_value = MagicMock(stdout=mock_out, returncode=0)
            result = image_to_ascii_frame("fake.png", width=width, height=height)
        assert len(result) % 128 == 0, f"height={height} -> {len(result)} bytes not multiple of 128"


def test_newlines_stripped():
    width, height = 64, 60
    mock_out = _make_mock_output(width, height)
    assert "\n" in mock_out  # sanity: mock output has newlines
    with patch("subprocess.run") as mock_run:
        mock_run.return_value = MagicMock(stdout=mock_out, returncode=0)
        result = image_to_ascii_frame("fake.png", width=width, height=height)
    assert b"\n" not in result


def test_missing_binary_raises():
    with patch("subprocess.run", side_effect=FileNotFoundError("not found")):
        with pytest.raises(RuntimeError, match="ascii-image-converter not found"):
            image_to_ascii_frame("fake.png")


def test_nonzero_exit_raises():
    with patch("subprocess.run", side_effect=subprocess.CalledProcessError(1, "cmd", stderr="oops")):
        with pytest.raises(RuntimeError, match="ascii-image-converter failed"):
            image_to_ascii_frame("fake.png")
