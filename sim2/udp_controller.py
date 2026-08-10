#!/usr/bin/env python3
"""A small UDP controller for a ``sim_top --udp`` session.

The simulator does not reply to UDP packets, so the status text reports only
whether this program successfully handed a packet to the local socket stack.
"""

import argparse
import socket
import tkinter as tk
from tkinter import ttk


class UdpController:
    PAD_SIZE = 180
    PAD_MARGIN = 18

    def __init__(self, root: tk.Tk, host: str, port: int, hold_frames: int) -> None:
        self.root = root
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.host = tk.StringVar(value=host)
        self.port = tk.StringVar(value=str(port))
        self.hold_frames = tk.StringVar(value=str(hold_frames))
        self.status = tk.StringVar(value="Ready")
        self.pressed_directions: set[str] = set()
        self.last_analog: tuple[int, int] | None = None

        root.title("sim_top UDP Controller")
        root.resizable(False, False)
        frame = ttk.Frame(root, padding=12)
        frame.grid()

        connection = ttk.LabelFrame(frame, text="Simulator", padding=8)
        connection.grid(row=0, column=0, columnspan=2, sticky="ew")
        ttk.Label(connection, text="Host").grid(row=0, column=0, sticky="w")
        ttk.Entry(connection, textvariable=self.host, width=18).grid(row=0, column=1, padx=(6, 12))
        ttk.Label(connection, text="UDP port").grid(row=0, column=2, sticky="w")
        ttk.Entry(connection, textvariable=self.port, width=7).grid(row=0, column=3, padx=(6, 0))

        buttons = ttk.LabelFrame(frame, text="Buttons", padding=8)
        buttons.grid(row=1, column=0, sticky="nsew", pady=(10, 0))
        ttk.Label(buttons, text="Hold (frames)").grid(row=0, column=0, columnspan=2)
        ttk.Spinbox(buttons, from_=1, to=9999, textvariable=self.hold_frames, width=6).grid(
            row=1, column=0, columnspan=2, pady=(2, 8)
        )
        ttk.Button(buttons, text="Button 1  (Z)", command=lambda: self.button("b1")).grid(
            row=2, column=0, columnspan=2, sticky="ew"
        )
        ttk.Button(buttons, text="Button 2  (X)", command=lambda: self.button("b2")).grid(
            row=3, column=0, columnspan=2, sticky="ew", pady=(6, 0)
        )
        ttk.Button(buttons, text="Buttons 1 + 2  (C)", command=lambda: self.button("b1b2")).grid(
            row=4, column=0, columnspan=2, sticky="ew", pady=(6, 0)
        )

        analog = ttk.LabelFrame(frame, text="Analog stick (arrows or WASD)", padding=8)
        analog.grid(row=1, column=1, sticky="nsew", padx=(10, 0), pady=(10, 0))
        self.canvas = tk.Canvas(analog, width=self.PAD_SIZE, height=self.PAD_SIZE, highlightthickness=0)
        self.canvas.grid()
        self.draw_pad(0, 0)
        self.canvas.bind("<Button-1>", self.drag_pad)
        self.canvas.bind("<B1-Motion>", self.drag_pad)
        self.canvas.bind("<ButtonRelease-1>", self.reset_analog)
        ttk.Button(analog, text="Center stick", command=self.reset_analog).grid(sticky="ew", pady=(7, 0))

        tools = ttk.LabelFrame(frame, text="Diagnostics", padding=8)
        tools.grid(row=2, column=0, columnspan=2, sticky="ew", pady=(10, 0))
        ttk.Button(tools, text="Trace on", command=lambda: self.send("trace_on")).grid(row=0, column=0)
        ttk.Button(tools, text="Trace off", command=lambda: self.send("trace_off")).grid(row=0, column=1, padx=6)
        ttk.Button(tools, text="Instructions on", command=lambda: self.send("instructions_on")).grid(row=0, column=2)
        ttk.Button(tools, text="Instructions off", command=lambda: self.send("instructions_off")).grid(row=0, column=3, padx=6)
        ttk.Button(tools, text="Stop simulator", command=lambda: self.send("quit")).grid(row=0, column=4)
        ttk.Label(frame, textvariable=self.status, foreground="#555555", wraplength=410).grid(
            row=3, column=0, columnspan=2, sticky="w", pady=(9, 0)
        )

        root.bind_all("<KeyPress>", self.key_press)
        root.bind_all("<KeyRelease>", self.key_release)
        root.protocol("WM_DELETE_WINDOW", self.close)

    def destination(self) -> tuple[str, int] | None:
        host = self.host.get().strip()
        try:
            port = int(self.port.get())
            if not host or not 1 <= port <= 65535:
                raise ValueError
        except ValueError:
            self.status.set("Enter a host and UDP port from 1 to 65535")
            return None
        return host, port

    def send(self, command: str) -> bool:
        destination = self.destination()
        if destination is None:
            return False
        try:
            self.socket.sendto(command.encode("ascii"), destination)
        except OSError as error:
            self.status.set(f"Could not send {command!r}: {error}")
            return False
        self.status.set(f"Sent: {command}")
        return True

    def button(self, command: str) -> None:
        try:
            hold = int(self.hold_frames.get())
            if hold < 1:
                raise ValueError
        except ValueError:
            self.status.set("Hold must be a positive whole number of frames")
            return
        self.send(f"{command} {hold}")

    def draw_pad(self, x: int, y: int) -> None:
        self.canvas.delete("all")
        center = self.PAD_SIZE / 2
        radius = center - self.PAD_MARGIN
        self.canvas.create_oval(center - radius, center - radius, center + radius, center + radius, fill="#f2f2f2", outline="#999999")
        self.canvas.create_line(center - radius, center, center + radius, center, fill="#cccccc")
        self.canvas.create_line(center, center - radius, center, center + radius, fill="#cccccc")
        knob_x = center + x / 127 * radius
        knob_y = center - y / 128 * radius
        self.canvas.create_oval(knob_x - 10, knob_y - 10, knob_x + 10, knob_y + 10, fill="#4c78a8", outline="")

    def set_analog(self, x: int, y: int) -> None:
        x, y = max(-128, min(127, x)), max(-128, min(127, y))
        if (x, y) == self.last_analog:
            return
        self.last_analog = (x, y)
        self.draw_pad(x, y)
        self.send(f"analog {x} {y}")

    def drag_pad(self, event: tk.Event) -> None:
        center = self.PAD_SIZE / 2
        radius = center - self.PAD_MARGIN
        dx, dy = event.x - center, event.y - center
        distance = (dx * dx + dy * dy) ** 0.5
        if distance > radius:
            dx, dy = dx * radius / distance, dy * radius / distance
        self.set_analog(round(dx / radius * 127), round(-dy / radius * 128))

    def reset_analog(self, _event=None) -> None:
        self.set_analog(0, 0)

    def key_press(self, event: tk.Event) -> None:
        key = event.keysym.lower()
        if key == "z":
            self.button("b1")
            return
        if key == "x":
            self.button("b2")
            return
        if key == "c":
            self.button("b1b2")
            return
        directions = {"left": "left", "a": "left", "right": "right", "d": "right", "up": "up", "w": "up", "down": "down", "s": "down"}
        if key in directions:
            self.pressed_directions.add(directions[key])
            self.update_directional_analog()

    def key_release(self, event: tk.Event) -> None:
        key = event.keysym.lower()
        directions = {"left": "left", "a": "left", "right": "right", "d": "right", "up": "up", "w": "up", "down": "down", "s": "down"}
        if key in directions:
            self.pressed_directions.discard(directions[key])
            self.update_directional_analog()

    def update_directional_analog(self) -> None:
        x = 127 if "right" in self.pressed_directions else -128 if "left" in self.pressed_directions else 0
        y = 127 if "down" in self.pressed_directions else -128 if "up" in self.pressed_directions else 0
        self.set_analog(x, y)

    def close(self) -> None:
        self.socket.close()
        self.root.destroy()


def main() -> int:
    parser = argparse.ArgumentParser(description="Graphical UDP input controller for sim_top")
    parser.add_argument("--host", default="127.0.0.1", help="sim_top host (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=28070, help="sim_top UDP port (default: 28070)")
    parser.add_argument("--hold", type=int, default=3, help="default button hold in frames (default: 3)")
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("--port must be between 1 and 65535")
    if args.hold < 1:
        parser.error("--hold must be positive")
    root = tk.Tk()
    UdpController(root, args.host, args.port, args.hold)
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
