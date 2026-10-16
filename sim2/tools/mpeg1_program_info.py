#!/usr/bin/env python3
"""Describe the container layout and end markers of an MPEG-1 program stream.

The report deliberately keeps elementary-video markers separate from program
stream markers: sequence_end_code (B7) ends one video sequence, whereas
program_end_code (B9) ends the enclosing program stream.

This application is created using AI assistance
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterator


STREAM_NAMES = {
    0xBA: "pack", 0xBB: "system header", 0xBC: "program stream map",
    0xBD: "private stream 1", 0xBE: "padding stream", 0xBF: "private stream 2",
    0xB9: "program end",
}
VIDEO_CODES = {0xB3: "sequence", 0xB7: "sequence end", 0xB8: "GOP", 0x00: "picture"}


def start_codes(data: bytes, start: int = 0, end: int | None = None) -> Iterator[tuple[int, int]]:
    """Yield MPEG start codes in the half-open range [start, end)."""
    end = len(data) if end is None else end
    offset = start
    while offset + 3 < end:
        offset = data.find(b"\x00\x00\x01", offset, end)
        if offset < 0 or offset + 3 >= end:
            return
        yield offset, data[offset + 3]
        offset += 3


def stream_name(code: int) -> str:
    if 0xC0 <= code <= 0xDF:
        return f"audio stream {code - 0xC0}"
    if 0xE0 <= code <= 0xEF:
        return f"video stream {code - 0xE0}"
    return STREAM_NAMES.get(code, f"stream 0x{code:02x}")


def parse_pack(data: bytes, offset: int) -> dict[str, object]:
    """Decode the fixed MPEG-1 pack header, without rejecting damaged data."""
    raw = data[offset + 4 : offset + 12]
    record: dict[str, object] = {"kind": "pack", "offset": offset, "truncated": len(raw) != 8}
    if len(raw) != 8:
        return record
    scr = ((raw[0] & 0x07) << 30) | (raw[1] << 22) | ((raw[2] >> 1) << 15)
    scr |= raw[3] << 7 | (raw[4] >> 1)
    record.update({
        "scr_90khz": scr,
        "scr_seconds": scr / 90_000,
        "mux_rate": ((raw[5] << 14) | (raw[6] << 6) | (raw[7] >> 2)) * 50,
    })
    return record


def pes_payload_start(data: bytes, packet_start: int, packet_end: int) -> tuple[int, int | None]:
    """Return payload start and PTS (90 kHz) for MPEG-1 or MPEG-2 PES syntax."""
    pos = packet_start + 6
    if pos >= packet_end:
        return pos, None
    # MPEG-2 PES optional-header form.
    if data[pos] & 0xC0 == 0x80 and pos + 3 <= packet_end:
        flags, header_length = data[pos + 1], data[pos + 2]
        pts = None
        if flags & 0x80 and pos + 8 <= packet_end:
            p = data[pos + 3 : pos + 8]
            pts = ((p[0] >> 1 & 7) << 30) | (p[1] << 22) | ((p[2] >> 1) << 15) | (p[3] << 7) | (p[4] >> 1)
        return min(packet_end, pos + 3 + header_length), pts
    # MPEG-1 PES optional-header form.
    while pos < packet_end and data[pos] == 0xFF:
        pos += 1
    if pos + 2 <= packet_end and data[pos] & 0xC0 == 0x40:
        pos += 2
    if pos >= packet_end:
        return pos, None
    prefix = data[pos] & 0xF0
    if prefix in (0x20, 0x30) and pos + 5 <= packet_end:
        p = data[pos : pos + 5]
        pts = ((p[0] >> 1 & 7) << 30) | (p[1] << 22) | ((p[2] >> 1) << 15) | (p[3] << 7) | (p[4] >> 1)
        return min(packet_end, pos + (10 if prefix == 0x30 else 5)), pts
    return min(packet_end, pos + 1), None  # 0x0f: no PTS/DTS


def next_container_start(data: bytes, start: int) -> int:
    """Find the next PS-level marker, skipping elementary-video start codes."""
    for offset, code in start_codes(data, start):
        if code in (0xB9, 0xBA, 0xBB) or 0xBC <= code <= 0xEF:
            return offset
    return len(data)


def inspect(data: bytes) -> Iterator[dict[str, object]]:
    """Yield top-level program-stream packets plus video end-marker context."""
    last_video: dict[str, object] | None = None
    last_sequence_end: dict[str, object] | None = None
    last_record: dict[str, object] | None = None
    picture_count = 0
    program_picture_count = 0
    offset = 0
    while True:
        found = data.find(b"\x00\x00\x01", offset)
        if found < 0 or found + 3 >= len(data):
            return
        code = data[found + 3]
        if code == 0xBA:
            record = parse_pack(data, found)
            yield record
            last_record = record
            offset = found + 12
            continue
        if code == 0xB9:
            following_offset = found + 4
            next_program = data[following_offset : following_offset + 4] == b"\x00\x00\x01\xBA"
            record = {"kind": "program end", "offset": found,
                      "previous": None if last_record is None else last_record["kind"],
                      "previous_offset": None if last_record is None else last_record["offset"],
                      "last_sequence_end_offset": None if last_sequence_end is None else last_sequence_end["offset"],
                      "bytes_after": len(data) - following_offset,
                      "next_program_offset": following_offset if next_program else None,
                      "pictures_in_program": program_picture_count}
            if last_sequence_end is not None:
                record["bytes_since_sequence_end"] = found - last_sequence_end["offset"]
            yield record
            last_record = record
            program_picture_count = 0
            last_video = None
            last_sequence_end = None
            offset = found + 4
            continue
        # System headers and PES packets all carry a two-byte packet length.
        if found + 6 > len(data):
            yield {"kind": stream_name(code), "offset": found, "truncated": True}
            return
        length = int.from_bytes(data[found + 4 : found + 6], "big")
        unbounded = length == 0
        packet_end = next_container_start(data, found + 6) if unbounded else min(len(data), found + 6 + length)
        record = {"kind": "PES" if code >= 0xBC else stream_name(code), "offset": found,
                  "stream_id": code, "stream": stream_name(code), "packet_length": length,
                  "end_offset": packet_end, "unbounded": unbounded,
                  "truncated": not unbounded and found + 6 + length > len(data)}
        if 0xE0 <= code <= 0xEF:
            payload, pts = pes_payload_start(data, found, packet_end)
            record.update({"payload_offset": payload, "pts_90khz": pts,
                           "pts_seconds": None if pts is None else pts / 90_000})
            yield record
            for video_offset, video_code in start_codes(data, payload, packet_end):
                if video_code not in VIDEO_CODES:
                    continue
                video = {"kind": VIDEO_CODES[video_code], "offset": video_offset,
                         "video_pes_offset": found, "stream": stream_name(code)}
                if video_code == 0x00:
                    picture_count += 1
                    program_picture_count += 1
                    video["picture_number"] = picture_count
                    video["program_picture_number"] = program_picture_count
                if video_code == 0xB7:
                    video["after"] = None if last_video is None else last_video["kind"]
                    video["after_offset"] = None if last_video is None else last_video["offset"]
                    last_sequence_end = video
                last_video = video
                yield video
        else:
            yield record
        last_record = record
        offset = packet_end


def print_record(record: dict[str, object]) -> None:
    kind = record["kind"]
    offset = f"0x{record['offset']:08x}"
    if kind == "pack":
        if record["truncated"]:
            print(f"PACK          @ {offset}  truncated")
        else:
            print(f"PACK          @ {offset}  SCR={record['scr_90khz']} ({record['scr_seconds']:.6f}s)  mux={record['mux_rate']} bit/s")
    elif kind == "PES":
        ending = " (truncated)" if record["truncated"] else ""
        timing = "" if record.get("pts_90khz") is None else f"  PTS={record['pts_90khz']} ({record['pts_seconds']:.6f}s)"
        length = "unbounded" if record["unbounded"] else str(record["packet_length"])
        print(f"PES           @ {offset}  {record['stream']}  length={length}  payload=0x{record.get('payload_offset', record['end_offset']):08x}{timing}{ending}")
    elif kind in VIDEO_CODES.values():
        relation = ""
        if kind == "sequence end":
            before = "none" if record["after_offset"] is None else f"{record['after']} @ 0x{record['after_offset']:08x}"
            relation = f"  after {before}"
        count = ""
        if kind == "picture":
            count = f" #{record['picture_number']} (program #{record['program_picture_number']})"
        print(f"{kind.upper():13}{count} @ {offset}  in video PES @ 0x{record['video_pes_offset']:08x}{relation}")
    elif kind == "program end":
        prior = "none" if record["previous_offset"] is None else f"{record['previous']} @ 0x{record['previous_offset']:08x}"
        seq = "none" if record["last_sequence_end_offset"] is None else f"0x{record['last_sequence_end_offset']:08x}"
        distance = "" if "bytes_since_sequence_end" not in record else f" ({record['bytes_since_sequence_end']} bytes earlier)"
        if record["next_program_offset"] is not None:
            suffix = f"; next program starts @ 0x{record['next_program_offset']:08x}"
        elif record["bytes_after"]:
            suffix = f"; WARNING: {record['bytes_after']} non-program trailing bytes"
        else:
            suffix = ""
        print(f"PROGRAM END   @ {offset}  pictures={record['pictures_in_program']}; after {prior}; last sequence end={seq}{distance}{suffix}")
    else:
        print(f"{kind.upper():13} @ {offset}  length={record['packet_length']}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Show MPEG-1 program-stream packets and sequence/program end relationships.")
    parser.add_argument("stream", type=Path, help="MPEG-1 program stream")
    parser.add_argument("--json", action="store_true", help="emit newline-delimited JSON records")
    args = parser.parse_args()
    try:
        data = args.stream.read_bytes()
    except OSError as exc:
        parser.error(f"cannot read {args.stream}: {exc}")
    for record in inspect(data):
        if args.json:
            print(json.dumps(record))
        else:
            print_record(record)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
