import sys
import os
import pytest
import tempfile
import subprocess
from pathlib import Path

from PIL import Image


def make_solid(width, height, color=(128, 128, 128)):
    return Image.new("RGB", (width, height), color)


def save_images(directory, count):
    paths = []
    for i in range(count):
        p = directory / f"frame_{i:04d}.png"
        make_solid(480, 360, (i * 5 % 256, 100, 100)).save(str(p))
        paths.append(p)
    return paths


def run_cli(args):
    """Run odyssey_video.py as a subprocess and return (returncode, stdout, stderr)."""
    script = Path(__file__).parent.parent / "odyssey_video.py"
    result = subprocess.run(
        [sys.executable, str(script)] + args,
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout, result.stderr


def test_color_pipeline():
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        paths = save_images(Path(src_dir), 3)
        rc, out, err = run_cli([
            "--color",
            "--output-dir", out_dir,
            "--input-fps", "30",
            "--output-fps", "1",
            *[str(p) for p in paths],
        ])
        assert rc == 0, f"CLI failed: {err}"
        col_files = sorted(Path(out_dir).glob("*.COL"))
        assert len(col_files) > 0


def test_frame_naming():
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        paths = save_images(Path(src_dir), 5)
        rc, out, err = run_cli([
            "--color",
            "--output-dir", out_dir,
            "--input-fps", "5",
            "--output-fps", "5",
            *[str(p) for p in paths],
        ])
        assert rc == 0, f"CLI failed: {err}"
        col_files = sorted(Path(out_dir).glob("*.COL"))
        names = [f.name for f in col_files]
        assert names[0] == "0000.COL"
        assert names[1] == "0001.COL"


def test_frame_sizes_on_disk():
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        paths = save_images(Path(src_dir), 4)
        rc, out, err = run_cli([
            "--color",
            "--output-dir", out_dir,
            "--input-fps", "4",
            "--output-fps", "4",
            *[str(p) for p in paths],
        ])
        assert rc == 0, f"CLI failed: {err}"
        for f in Path(out_dir).glob("*.COL"):
            size = f.stat().st_size
            assert size % 128 == 0, f"{f.name} is {size} bytes, not a multiple of 128"


def test_gif_pipeline():
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        gif_path = Path(src_dir) / "test.gif"
        frames_src = [make_solid(480, 360, (i * 25, 0, 0)) for i in range(5)]
        frames_src[0].save(
            str(gif_path),
            save_all=True,
            append_images=frames_src[1:],
            duration=200,  # 200ms each -> 5 frames = 1 second
            loop=0,
        )
        rc, out, err = run_cli([
            "--color",
            "--output-dir", out_dir,
            "--output-fps", "2",
            str(gif_path),
        ])
        assert rc == 0, f"CLI failed: {err}"
        col_files = sorted(Path(out_dir).glob("*.COL"))
        assert len(col_files) == 2  # 1 second of GIF at 2fps


def test_block_mode_not_implemented():
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        paths = save_images(Path(src_dir), 1)
        rc, out, err = run_cli([
            "--block",
            "--output-dir", out_dir,
            str(paths[0]),
        ])
        assert rc != 0
        assert "not yet implemented" in err.lower() or "not yet implemented" in out.lower()


def test_ascii_pipeline():
    """Test --ascii mode with a mocked ascii-image-converter binary."""
    with tempfile.TemporaryDirectory() as src_dir, tempfile.TemporaryDirectory() as out_dir:
        paths = save_images(Path(src_dir), 2)

        # Create a fake ascii-image-converter script
        fake_bin_dir = Path(src_dir) / "bin"
        fake_bin_dir.mkdir()
        fake_bin = fake_bin_dir / "ascii-image-converter"
        fake_bin.write_text(
            "#!/bin/sh\n"
            "# Output 64x48 chars, one row per line\n"
            "python3 -c \""
            "[print('X' * 64) for _ in range(48)]"
            "\"\n"
        )
        fake_bin.chmod(0o755)

        env = os.environ.copy()
        env["PATH"] = str(fake_bin_dir) + ":" + env.get("PATH", "")

        script = Path(__file__).parent.parent / "odyssey_video.py"
        result = subprocess.run(
            [sys.executable, str(script),
             "--ascii",
             "--output-dir", out_dir,
             "--input-fps", "2",
             "--output-fps", "2",
             "--height", "48",
             *[str(p) for p in paths]],
            capture_output=True,
            text=True,
            env=env,
        )
        assert result.returncode == 0, f"CLI failed: {result.stderr}"
        txt_files = sorted(Path(out_dir).glob("*.TXT"))
        assert len(txt_files) == 2
        for f in txt_files:
            assert f.stat().st_size % 128 == 0
