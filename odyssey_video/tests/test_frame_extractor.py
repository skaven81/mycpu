import pytest
import tempfile
from pathlib import Path
from PIL import Image

from frame_extractor import extract_frames


def make_test_image(width=100, height=75, color=(128, 128, 128)):
    return Image.new("RGB", (width, height), color)


def save_images(directory, count, prefix="frame_", ext=".png"):
    """Save 'count' solid images to directory, return list of paths."""
    paths = []
    for i in range(count):
        p = directory / f"{prefix}{i:04d}{ext}"
        img = Image.new("RGB", (100, 75), ((i * 4) % 256, 100, 100))
        img.save(str(p))
        paths.append(p)
    return paths


def test_single_image():
    with tempfile.TemporaryDirectory() as tmpdir:
        p = Path(tmpdir) / "test.png"
        make_test_image().save(str(p))
        frames = list(extract_frames([p], input_fps=30.0, output_fps=14.0))
    assert len(frames) == 1


def test_image_list_sampling():
    # 30 images at 30fps input -> at 14fps output we get 14 frames (covering ~1 second)
    with tempfile.TemporaryDirectory() as tmpdir:
        paths = save_images(Path(tmpdir), 30)
        frames = list(extract_frames(paths, input_fps=30.0, output_fps=14.0))
    # ceil(30/30 * 14) = 14
    assert len(frames) == 14


def test_directory_images():
    with tempfile.TemporaryDirectory() as tmpdir:
        d = Path(tmpdir)
        save_images(d, 30)
        frames = list(extract_frames([d], input_fps=30.0, output_fps=14.0))
    assert len(frames) == 14


def test_gif_extraction():
    """Create a programmatic GIF and verify frame count at output_fps."""
    with tempfile.TemporaryDirectory() as tmpdir:
        gif_path = Path(tmpdir) / "test.gif"
        # 10 frames at 100ms each = 1 second of GIF
        frames_src = [Image.new("RGB", (80, 60), (i * 25, 0, 0)) for i in range(10)]
        frames_src[0].save(
            str(gif_path),
            save_all=True,
            append_images=frames_src[1:],
            duration=100,
            loop=0,
        )
        frames = list(extract_frames([gif_path], output_fps=5.0))
    # 1 second of content at 5fps -> 5 frames
    assert len(frames) == 5


def test_output_is_pil_image():
    with tempfile.TemporaryDirectory() as tmpdir:
        p = Path(tmpdir) / "test.png"
        make_test_image().save(str(p))
        frames = list(extract_frames([p]))
    assert all(isinstance(f, Image.Image) for f in frames)


def test_fps_higher_than_input():
    # When output_fps >= input_fps, we get one frame per source image
    with tempfile.TemporaryDirectory() as tmpdir:
        paths = save_images(Path(tmpdir), 5)
        # 5 images at 30fps input -> 0.167s; at 100fps output -> ~16 frames but capped by source
        # At output_fps=30, each output frame maps to exactly one input frame -> 5 frames
        frames = list(extract_frames(paths, input_fps=30.0, output_fps=30.0))
    assert len(frames) == 5
