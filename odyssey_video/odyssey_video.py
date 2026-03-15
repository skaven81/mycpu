#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "Pillow>=9.0",
#   "numpy>=1.21",
#   "imageio>=2.16",
#   "imageio-ffmpeg>=0.4",
# ]
# ///
"""
odyssey_video.py -- Convert images/GIFs/videos to Odyssey video frame files.

Frame files are named XXXX.TXT (ASCII mode) or XXXX.COL (color mode) where
XXXX is the zero-padded uppercase hex frame number (0000, 0001, ...).

All frames in a session must be the same size (a multiple of 128 bytes).
Height is computed once from the first frame and applied to all subsequent frames.

External dependency for --ascii mode:
    ascii-image-converter (Go binary) must be installed and on PATH.
    See: https://github.com/TheZoraiz/ascii-image-converter
"""

import argparse
import sys
import os
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from common import DISPLAY_W, DISPLAY_H, compute_frame_height
from frame_extractor import extract_frames


def parse_args():
    parser = argparse.ArgumentParser(
        description="Convert images/GIFs/videos to Odyssey video frame files."
    )
    mode_group = parser.add_mutually_exclusive_group(required=True)
    mode_group.add_argument(
        "--ascii",
        action="store_true",
        help="Generate ASCII art frames (.TXT files) via ascii-image-converter",
    )
    mode_group.add_argument(
        "--color",
        action="store_true",
        help="Generate color frames (.COL files) using Odyssey 64-color palette",
    )
    mode_group.add_argument(
        "--block",
        action="store_true",
        help="(not yet implemented) Half-block character mode for 2x resolution",
    )
    parser.add_argument(
        "--output-fps",
        type=float,
        default=14.0,
        metavar="N",
        help="Output frame rate (default: 14)",
    )
    parser.add_argument(
        "--input-fps",
        type=float,
        default=30.0,
        metavar="N",
        help="Source frame rate for image lists/directories (default: 30)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("."),
        metavar="DIR",
        help="Directory to write frame files (default: current directory)",
    )
    parser.add_argument(
        "--height",
        type=int,
        default=None,
        metavar="H",
        help=(
            "Override output height in character cells (must be even, 64*H must be "
            "divisible by 128). Default: auto-computed from source aspect ratio."
        ),
    )
    parser.add_argument(
        "inputs",
        nargs="+",
        metavar="input",
        help=(
            "Input file(s) or directory. Supported: video files, GIFs, "
            "image files (.jpg/.png/etc.), or a directory of images."
        ),
    )
    return parser.parse_args()


def validate_height(h):
    if h % 2 != 0:
        print(f"Error: --height must be even (got {h})", file=sys.stderr)
        sys.exit(1)
    if (DISPLAY_W * h) % 128 != 0:
        print(
            f"Error: 64 * {h} = {64 * h} is not divisible by 128",
            file=sys.stderr,
        )
        sys.exit(1)
    if h < 2 or h > DISPLAY_H:
        print(
            f"Error: --height must be between 2 and {DISPLAY_H} (got {h})",
            file=sys.stderr,
        )
        sys.exit(1)


def run_ascii_mode(args):
    from ascii_converter import image_to_ascii_frame

    out_dir = args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    frame_height = args.height  # None means auto-detect from first frame
    frame_num = 0

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        frame_iter = extract_frames(
            args.inputs, input_fps=args.input_fps, output_fps=args.output_fps
        )
        for pil_img in frame_iter:
            if frame_height is None:
                w, h = pil_img.size
                frame_height = compute_frame_height(w, h)
                print(f"Auto-detected frame height: {frame_height} rows ({DISPLAY_W}x{frame_height} cells)")

            # Save PIL image to temp file so ascii-image-converter can read it
            tmp_img = tmp_path / f"frame_{frame_num:06d}.png"
            pil_img.save(str(tmp_img))

            frame_data = image_to_ascii_frame(str(tmp_img), width=DISPLAY_W, height=frame_height)

            out_path = out_dir / f"{frame_num:04X}.TXT"
            out_path.write_bytes(frame_data)
            print(f"  [{frame_num:04X}] {out_path}  ({len(frame_data)} bytes)")
            frame_num += 1

    print(f"Done. {frame_num} frames written to {out_dir}/")


def run_color_mode(args):
    from color_converter import image_to_color_frame

    out_dir = args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    frame_height = args.height  # None means auto-detect from first frame
    frame_num = 0

    for pil_img in extract_frames(
        args.inputs, input_fps=args.input_fps, output_fps=args.output_fps
    ):
        if frame_height is None:
            w, h = pil_img.size
            frame_height = compute_frame_height(w, h)
            print(f"Auto-detected frame height: {frame_height} rows ({DISPLAY_W}x{frame_height} cells)")

        frame_data = image_to_color_frame(pil_img, height=frame_height)

        out_path = out_dir / f"{frame_num:04X}.COL"
        out_path.write_bytes(frame_data)
        print(f"  [{frame_num:04X}] {out_path}  ({len(frame_data)} bytes)")
        frame_num += 1

    print(f"Done. {frame_num} frames written to {out_dir}/")


def main():
    args = parse_args()

    if args.block:
        print("Error: block mode is not yet implemented.", file=sys.stderr)
        sys.exit(1)

    if args.height is not None:
        validate_height(args.height)

    if args.ascii:
        run_ascii_mode(args)
    elif args.color:
        run_color_mode(args)


if __name__ == "__main__":
    main()
