#!/usr/bin/env python3
"""Reconstruct DMA transfers programmed through the SCC68070 DMA registers.

The simulator log prints accesses to the DMA register bank. This tool tracks
them and emits a transfer when software sets the start bit. The register map
comes from rtl/scc68070.sv: register 2 low byte is operation control (bit 7
is direction), register 3 low byte starts, register 5 is word count, and
registers 6/7 form the 32-bit memory address counter.
"""

from __future__ import annotations

import argparse
import csv
import re
import signal
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, TextIO


DMA_WRITE = re.compile(
    r"^DMA Write CH:(?P<channel>[01]) ADDR:(?P<register>[0-9A-Fa-f]+) "
    r"DATA:(?P<data>[0-9A-Fa-f]+) LDS:(?P<lds>[01]) UDS:(?P<uds>[01])$"
)
CDIC_DMA_CONTROL = re.compile(
    r"^CDIC Write DMA Control Register\s+[0-9A-Fa-f]+\s+(?P<device_address>[0-9A-Fa-f]+)$"
)

PASSTHROUGH_PREFIXES = ("SLICE","CDIC ")
PASSTHROUGH_WORDS = ("delivery", "MV_Continue", "SS_Cont", "SS_Pause", "MV_Pause", "MA_Pause", "MA_Continue", "SLAVE")


@dataclass
class Channel:
    address: int = 0
    count: int = 0
    operation_control: int = 0


def update_word(old: int, data: int, lds: bool, uds: bool) -> int:
    """Apply byte lanes as the RTL does: UDS is high, LDS is low."""
    if uds:
        old = (old & 0x00FF) | (data & 0xFF00)
    if lds:
        old = (old & 0xFF00) | (data & 0x00FF)
    return old


def parse_args() -> argparse.Namespace:
    here = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", nargs="?", type=Path, default=here / "log0_3")
    parser.add_argument("-o", "--output", type=Path, help="output file (default: stdout)")
    parser.add_argument("--csv", action="store_true", help="write CSV rather than TSV")
    parser.add_argument("--expand", action="store_true", help="emit one row per memory word")
    return parser.parse_args()


def is_passthrough_line(text: str) -> bool:
    """Return whether a log line is a timeline marker to preserve verbatim."""
    return text.startswith(PASSTHROUGH_PREFIXES) or any(
        word in text for word in PASSTHROUGH_WORDS
    )


def transfers(log: Path) -> Iterator[dict[str, int | str]]:
    channels = [Channel(), Channel()]
    pending_channel_0: list[dict[str, int | str]] = []
    with log.open(encoding="utf-8", errors="replace") as source:
        for line_number, text in enumerate(source, 1):
            # Keep timeline markers in the output; they are deliberately not
            # converted to TSV/CSV rows so their original text is preserved.
            if is_passthrough_line(text):
                yield {"slice": text.rstrip("\r\n")}
                continue
            cdic_match = CDIC_DMA_CONTROL.match(text.rstrip("\r\n"))
            if cdic_match:
                # CDIC programs its DMA endpoint immediately after channel 0
                # is started. Attach that final field to the pending transfer.
                for transfer in pending_channel_0:
                    transfer["device_address"] = cdic_match["device_address"]
                    yield transfer
                pending_channel_0.clear()
                continue
            match = DMA_WRITE.match(text.rstrip("\r\n"))
            if not match:
                continue
            fields = match.groupdict()
            channel = channels[int(fields["channel"])]
            register, data = int(fields["register"], 16), int(fields["data"], 16)
            lds, uds = fields["lds"] == "1", fields["uds"] == "1"

            if register == 2 and lds:
                channel.operation_control = data & 0xFF
            elif register == 5:
                channel.count = update_word(channel.count, data, lds, uds)
            elif register == 6:
                high = update_word((channel.address >> 16) & 0xFFFF, data, lds, uds)
                channel.address = (channel.address & 0x0000FFFF) | (high << 16)
            elif register == 7:
                low = update_word(channel.address & 0xFFFF, data, lds, uds)
                channel.address = (channel.address & 0xFFFF0000) | low
            elif register == 3 and lds and (data & 0x80):
                # RTL drives memory_address_counter[23:1], making this a
                # 16-bit word transfer at the aligned low 24-bit address.
                start = channel.address & 0x00FFFFFE
                transfer: dict[str, int | str] = {
                    "line": line_number,
                    "channel": fields["channel"],
                    "memory_operation": "Write" if channel.operation_control & 0x80 else "Read",
                    "direction": "device-to-memory" if channel.operation_control & 0x80 else "memory-to-device",
                    "device_address": "",
                    "start_address": start,
                    "end_address": start + max(channel.count - 1, 0) * 2,
                    "word_count": channel.count,
                }
                if fields["channel"] == "0":
                    # A new start without an intervening CDIC control write
                    # cannot be associated with a device address.
                    yield from pending_channel_0
                    pending_channel_0.clear()
                    pending_channel_0.append(transfer)
                else:
                    yield transfer
    yield from pending_channel_0


def write_output(log: Path, output: TextIO, dialect: str, expand: bool) -> int:
    fields = (["line", "channel", "memory_operation", "direction", "device_address", "memory_address", "word_index"] if expand
              else ["line", "channel", "memory_operation", "direction", "device_address", "start_address", "end_address", "word_count"])
    writer = csv.DictWriter(output, fieldnames=fields, dialect=dialect, lineterminator="\n")
    writer.writeheader()
    rows = 0
    for transfer in transfers(log):
        if "slice" in transfer:
            output.write(f"{transfer['slice']}\n")
            continue
        if expand:
            for word_index in range(int(transfer["word_count"])):
                writer.writerow({
                    "line": transfer["line"], "channel": transfer["channel"],
                    "memory_operation": transfer["memory_operation"], "direction": transfer["direction"],
                    "device_address": transfer["device_address"],
                    "memory_address": f"{int(transfer['start_address']) + word_index * 2:06x}",
                    "word_index": word_index,
                })
                rows += 1
        else:
            writer.writerow({
                **transfer,
                "start_address": f"{int(transfer['start_address']):06x}",
                "end_address": f"{int(transfer['end_address']):06x}",
            })
            rows += 1
    return rows


def main() -> int:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    args = parse_args()
    dialect = "excel" if args.csv else "excel-tab"
    if args.output:
        with args.output.open("w", encoding="utf-8", newline="") as output:
            count = write_output(args.log, output, dialect, args.expand)
    else:
        count = write_output(args.log, sys.stdout, dialect, args.expand)
    print(f"Extracted {count} {'memory operations' if args.expand else 'DMA transfers'} from {args.log}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
