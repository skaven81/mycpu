"""
Frame extractor for Odyssey video generation.

Yields PIL Image objects sampled at the desired output FPS from various
input sources: video files, GIFs, directories of images, or image lists.
"""

import os
import re
import glob as _glob
from pathlib import Path

from PIL import Image

VIDEO_EXTENSIONS = {".mp4", ".avi", ".mkv", ".mov", ".webm", ".flv", ".wmv"}
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".tif", ".webp"}
GIF_EXTENSIONS = {".gif"}


def _is_video(path):
    return Path(path).suffix.lower() in VIDEO_EXTENSIONS


def _is_gif(path):
    return Path(path).suffix.lower() in GIF_EXTENSIONS


def _is_image(path):
    return Path(path).suffix.lower() in IMAGE_EXTENSIONS


def _frames_from_video(path, input_fps, output_fps):
    """Yield PIL Images from a video file using imageio."""
    try:
        import imageio.v3 as iio
        reader = iio.imopen(str(path), "r")
        props = reader.properties()
        actual_fps = getattr(props, "fps", None) or input_fps
        frame_idx = 0
        out_idx = 0
        for frame_arr in reader.iter():
            t_out = out_idx / output_fps
            t_in = frame_idx / actual_fps
            if t_in >= t_out:
                yield Image.fromarray(frame_arr)
                out_idx += 1
            frame_idx += 1
        reader.close()
    except ImportError:
        # Fall back to imageio v2 API
        import imageio
        reader = imageio.get_reader(str(path))
        meta = reader.get_meta_data()
        actual_fps = meta.get("fps", input_fps)
        frame_idx = 0
        out_idx = 0
        for frame_arr in reader:
            t_out = out_idx / output_fps
            t_in = frame_idx / actual_fps
            if t_in >= t_out:
                yield Image.fromarray(frame_arr)
                out_idx += 1
            frame_idx += 1
        reader.close()


def _frames_from_gif(path, output_fps):
    """Yield PIL Images from a GIF file at the desired output FPS."""
    img = Image.open(str(path))
    frames = []
    durations = []
    try:
        while True:
            frames.append(img.copy().convert("RGB"))
            # Duration in milliseconds; default to 100ms if missing
            durations.append(img.info.get("duration", 100))
            img.seek(img.tell() + 1)
    except EOFError:
        pass

    if not frames:
        return

    # Compute cumulative timestamps for each GIF frame (in seconds)
    timestamps = []
    t = 0.0
    for d in durations:
        timestamps.append(t)
        t += d / 1000.0
    total_duration = t

    out_idx = 0
    while True:
        t_out = out_idx / output_fps
        if t_out >= total_duration:
            break
        # Find the GIF frame that covers t_out
        gif_idx = 0
        for i, ts in enumerate(timestamps):
            if ts <= t_out:
                gif_idx = i
        yield frames[gif_idx]
        out_idx += 1


def _frames_from_image_list(paths, input_fps, output_fps):
    """Yield PIL Images from a list of image paths sampled at output_fps."""
    n = len(paths)
    out_idx = 0
    while True:
        t_out = out_idx / output_fps
        src_idx = int(t_out * input_fps)
        if src_idx >= n:
            break
        yield Image.open(str(paths[src_idx])).convert("RGB")
        out_idx += 1


def extract_frames(inputs, input_fps=30.0, output_fps=14.0):
    """
    Yield PIL Image objects sampled at output_fps from the given inputs.

    Args:
        inputs: List of input paths (strings or Path objects). Can be:
                - A single video file (.mp4, .avi, etc.)
                - A single GIF file
                - A single directory (images sorted numerically/alphabetically)
                - One or more image files (.jpg, .png, etc.)
        input_fps: Assumed source frame rate (for image lists/directories).
        output_fps: Desired output frame rate.

    Yields:
        PIL.Image.Image objects in RGB mode.
    """
    inputs = [Path(p) for p in inputs]

    if len(inputs) == 1 and inputs[0].is_dir():
        # Directory: glob sorted image files (natural sort handles numeric names)
        def _natural_key(path):
            parts = re.split(r'(\d+)', path.name)
            return [int(p) if p.isdigit() else p.lower() for p in parts]

        directory = inputs[0]
        found = sorted(
            [p for p in directory.iterdir() if _is_image(p)],
            key=_natural_key,
        )
        yield from _frames_from_image_list(found, input_fps, output_fps)
        return

    if len(inputs) == 1 and _is_video(inputs[0]):
        yield from _frames_from_video(inputs[0], input_fps, output_fps)
        return

    if len(inputs) == 1 and _is_gif(inputs[0]):
        yield from _frames_from_gif(inputs[0], output_fps)
        return

    # Multiple inputs or single image: treat as image list
    image_paths = []
    for p in inputs:
        if p.is_file() and _is_image(p):
            image_paths.append(p)
        elif p.is_file() and _is_gif(p):
            # Single GIF in a list -- treat it as an image list entry
            image_paths.append(p)

    if image_paths:
        yield from _frames_from_image_list(image_paths, input_fps, output_fps)
        return

    raise ValueError(f"Could not determine input type for: {inputs}")
