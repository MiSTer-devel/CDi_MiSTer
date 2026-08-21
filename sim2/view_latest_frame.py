#!/usr/bin/env python3
"""Show the newest display frame written by sim_top.

The simulator writes frames as <instance>/video_###.bmp.  This viewer keeps a
single window pointed at whichever such file was modified most recently.

This whole tool is AI generated
"""

import argparse
import ctypes
import os
from pathlib import Path
import struct
import sys
import tkinter as tk

try:
    from PIL import Image, ImageTk
except ImportError:
    Image = ImageTk = None


def newest_frame(output_dir: Path) -> Path | None:
    frames = output_dir.glob("[0-9]*/video_*.bmp")
    try:
        return max(frames, key=lambda path: path.stat().st_mtime_ns)
    except ValueError:
        return None


class InotifyWatcher:
    """Wake Tk only when sim_top creates or closes a frame file."""

    IN_CLOSE_WRITE = 0x00000008
    IN_MOVED_TO = 0x00000080
    IN_CREATE = 0x00000100
    IN_ISDIR = 0x40000000
    WATCH_MASK = IN_CLOSE_WRITE | IN_MOVED_TO | IN_CREATE

    def __init__(self, root: tk.Tk, output_dir: Path, callback) -> None:
        if not hasattr(root.tk, "createfilehandler") or sys.platform != "linux":
            raise OSError("inotify is unavailable")

        libc = ctypes.CDLL(None, use_errno=True)
        libc.inotify_init1.restype = ctypes.c_int
        self.fd = libc.inotify_init1(os.O_NONBLOCK | os.O_CLOEXEC)
        if self.fd < 0:
            raise OSError(ctypes.get_errno(), "inotify_init1")
        self.libc = libc
        self.root = root
        self.output_dir = output_dir
        self.callback = callback
        self.paths: dict[int, Path] = {}
        self.add_watch(output_dir)
        for directory in output_dir.glob("[0-9]*"):
            if directory.is_dir():
                self.add_watch(directory)
        root.tk.createfilehandler(self.fd, tk.READABLE, self.on_event)

    def add_watch(self, path: Path) -> None:
        encoded_path = os.fsencode(path)
        watch_descriptor = self.libc.inotify_add_watch(self.fd, encoded_path, self.WATCH_MASK)
        if watch_descriptor >= 0:
            self.paths[watch_descriptor] = path

    def on_event(self, _fd, _mask) -> None:
        try:
            data = os.read(self.fd, 65536)
        except BlockingIOError:
            return
        offset = 0
        while offset < len(data):
            watch_descriptor, event_mask, _cookie, name_length = struct.unpack_from("iIII", data, offset)
            name = data[offset + 16 : offset + 16 + name_length].rstrip(b"\0").decode(errors="replace")
            offset += 16 + name_length
            parent = self.paths.get(watch_descriptor)
            if not parent:
                continue
            if parent == self.output_dir and event_mask & self.IN_ISDIR and name.isdigit():
                self.add_watch(parent / name)
            elif name.startswith("video_") and name.endswith(".bmp") and event_mask & (
                self.IN_CLOSE_WRITE | self.IN_MOVED_TO
            ):
                self.callback(parent / name)

    def close(self) -> None:
        self.root.tk.deletefilehandler(self.fd)
        os.close(self.fd)


class LatestFrameViewer:
    def __init__(self, root: tk.Tk, output_dir: Path, fallback_interval_ms: int) -> None:
        self.root = root
        self.output_dir = output_dir
        self.fallback_interval_ms = fallback_interval_ms
        self.current_path: Path | None = None
        self.image: tk.PhotoImage | None = None
        self.source_image = None
        self.rendered_size: tuple[int, int] | None = None
        self.resize_job: str | None = None
        self.initial_size_set = False
        self.watcher: InotifyWatcher | None = None

        self.label = tk.Label(root, text="Waiting for sim_top to write a frame…")
        self.label.pack(expand=True, fill=tk.BOTH)
        root.bind("<Configure>", self.queue_resize, add="+")
        self.show(newest_frame(output_dir))
        try:
            self.watcher = InotifyWatcher(root, output_dir, self.show)
        except OSError:
            # Keep the viewer portable for non-Linux hosts and headless Tk builds.
            self.poll()
        root.protocol("WM_DELETE_WINDOW", self.close)

    def show(self, path: Path | None) -> None:
        if path and path != self.current_path:
            try:
                # Recreate the image only after sim_top has finished the write.
                if Image:
                    self.source_image = Image.open(path).convert("RGB")
                    self.source_image.load()
                    self.current_path = path
                    self.rendered_size = None
                    if not self.initial_size_set:
                        width, height = self.source_image.size
                        self.root.geometry(f"{round(width * 0.5)}x{round(height * 0.5)}")
                        self.initial_size_set = True
                    self.render()
                else:
                    self.image = tk.PhotoImage(file=path)
                    self.current_path = path
                    if not self.initial_size_set:
                        self.root.geometry(f"{round(self.image.width() * 0.5)}x{round(self.image.height() * 0.5)}")
                        self.initial_size_set = True
                    self.label.configure(image=self.image, text="")
            except (OSError, tk.TclError):
                pass
            else:
                self.root.title(f"sim_top: {path.relative_to(self.output_dir)}")

    def queue_resize(self, _event=None) -> None:
        if self.source_image is None:
            return
        if self.resize_job:
            self.root.after_cancel(self.resize_job)
        # Window managers can generate many Configure events while dragging.
        self.resize_job = self.root.after(100, self.render)

    def render(self) -> None:
        self.resize_job = None
        if self.source_image is None:
            return
        available_width = self.label.winfo_width()
        available_height = self.label.winfo_height()
        if available_width < 2 or available_height < 2:
            return
        source_width, source_height = self.source_image.size
        scale = min(available_width / source_width, available_height / source_height)
        size = (max(1, round(source_width * scale)), max(1, round(source_height * scale)))
        if size == self.rendered_size:
            return
        resized = self.source_image.resize(size, Image.Resampling.LANCZOS)
        self.image = ImageTk.PhotoImage(resized)
        self.rendered_size = size
        self.label.configure(image=self.image, text="")
    def poll(self) -> None:
        self.show(newest_frame(self.output_dir))
        self.root.after(self.fallback_interval_ms, self.poll)

    def refresh(self) -> None:
        """Fallback callback for platforms without filesystem notifications."""
        self.show(newest_frame(self.output_dir))

    def close(self) -> None:
        if self.watcher:
            self.watcher.close()
        self.root.destroy()


def main() -> int:
    parser = argparse.ArgumentParser(description="Live viewer for sim_top's latest PNG frame.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="directory containing sim_top instance directories (default: sim2)",
    )
    parser.add_argument(
        "--interval", type=float, default=5.0, help="fallback poll interval in seconds (default: 5; Linux uses inotify)"
    )
    parser.add_argument("--print", dest="print_only", action="store_true", help="print the newest frame path and exit")
    args = parser.parse_args()

    if args.interval <= 0:
        parser.error("--interval must be greater than zero")

    output_dir = args.output_dir.resolve()
    if args.print_only:
        frame = newest_frame(output_dir)
        if not frame:
            print(f"No sim_top frame found below {output_dir}", file=sys.stderr)
            return 1
        print(frame)
        return 0

    root = tk.Tk()
    root.title("sim_top: waiting for a frame")
    LatestFrameViewer(root, output_dir, round(args.interval * 1000))
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
