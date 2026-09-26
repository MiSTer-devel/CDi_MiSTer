#!/usr/bin/env python3
"""Extract independently decodable I-pictures from an MPEG-1 video stream."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def start_codes(data: bytes) -> list[tuple[int, int]]:
    """Return every (offset, code) MPEG start code in *data*."""
    codes: list[tuple[int, int]] = []
    offset = 0
    while True:
        offset = data.find(b"\x00\x00\x01", offset)
        if offset < 0 or offset + 3 >= len(data):
            return codes
        codes.append((offset, data[offset + 3]))
        offset += 3


def picture_type(data: bytes, offset: int) -> int | None:
    """Return the MPEG picture_coding_type at a picture start code."""
    if offset + 6 > len(data):
        return None
    return (int.from_bytes(data[offset + 4 : offset + 6], "big") >> 3) & 0x7


def extract_i_frames(data: bytes) -> list[bytes]:
    """Extract I-pictures, each prefixed with its sequence and GOP headers.

    A picture alone lacks the sequence header required by MPEG decoders.  The
    output therefore contains the most recent sequence header, the GOP header
    for the picture when present, and the picture up to (but not including) the
    following picture start code.  Pictures encountered before a sequence
    header (or after a sequence end) are skipped.
    """
    codes = start_codes(data)
    frames: list[bytes] = []
    sequence_header: bytes | None = None
    gop_header: bytes = b""

    for index, (offset, code) in enumerate(codes):
        next_offset = codes[index + 1][0] if index + 1 < len(codes) else len(data)

        if code == 0xB3:
            # Keep the sequence header and any immediately following extension
            # or user-data start-code sections, stopping at the next GOP/picture.
            end = next_offset
            follow = index + 1
            while follow < len(codes) and codes[follow][1] not in (0xB8, 0x00):
                end = codes[follow + 1][0] if follow + 1 < len(codes) else len(data)
                follow += 1
            sequence_header = data[offset:end]
            gop_header = b""
        elif code == 0xB8:
            gop_header = data[offset:next_offset]
        elif code == 0xB7:
            sequence_header = None
            gop_header = b""
        elif code == 0x00 and picture_type(data, offset) == 1:
            if sequence_header is None:
                continue

            # Include all start-code sections belonging to this picture, but no
            # following picture/GOP/sequence start code.
            end = next_offset
            follow = index + 1
            while follow < len(codes) and codes[follow][1] not in (0x00, 0xB3, 0xB8, 0xB7):
                end = codes[follow + 1][0] if follow + 1 < len(codes) else len(data)
                follow += 1
            frames.append(sequence_header + gop_header + data[offset:end] + b"\x00\x00\x01\xB7")

    return frames


def write_png(frame_path: Path) -> None:
    """Decode the single MPEG picture in *frame_path* into a sibling PNG."""
    png_path = frame_path.with_suffix(".png")
    result = subprocess.run(
        [
            "ffmpeg", "-nostdin", "-v", "error", "-y", "-i", str(frame_path),
            "-frames:v", "1", str(png_path),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        detail = result.stderr.strip() or "unknown FFmpeg error"
        raise RuntimeError(f"cannot create {png_path}: {detail}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract MPEG-1 I-pictures into .m1v files and matching PNG images."
    )
    parser.add_argument("stream", type=Path, help="input MPEG-1 elementary video stream")
    parser.add_argument(
        "output_dir", type=Path, nargs="?",
        help="destination directory (default: <stream-stem>_i_frames beside the input)",
    )
    args = parser.parse_args()

    output_dir = args.output_dir or args.stream.with_name(f"{args.stream.stem}_i_frames")
    try:
        if shutil.which("ffmpeg") is None:
            raise RuntimeError("FFmpeg is required to create PNG images but was not found in PATH")
        data = args.stream.read_bytes()
        frames = extract_i_frames(data)
        if not frames:
            parser.error("no MPEG-1 I-pictures found")
        output_dir.mkdir(parents=True, exist_ok=True)
        for number, frame in enumerate(frames):
            frame_path = output_dir / f"i_frame_{number:04d}.m1v"
            frame_path.write_bytes(frame)
            write_png(frame_path)
    except (OSError, RuntimeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"Wrote {len(frames)} I-pictures and matching PNG images to {output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
