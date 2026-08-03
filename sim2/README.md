# Verilator Simulation

Verilator is much faster than ModelSim but is restricted to Verilog/SystemVerilog.
VHDL source code must be converted first.

Please use the [convert scripts](../scripts/) in case the VHDL code was changed.
To be safe, a conversion is already part of the repo.

## Prerequisites

You need CD images to use with the simulation. Only the `.bin` files are required. `.chd` is not supported.

## Usage

    ./sim_top.sh

### Live frame viewer

In another terminal, run the following to keep a window on the most recently
written display frame (across all numeric simulator instance directories):

    ./view_latest_frame.py

It uses Linux filesystem notifications, so it is idle between frames, and
scales the image to preserve its aspect ratio as the window is resized. Pillow
enables scaling; without it, the viewer still opens frames at native size. To
obtain the current frame path for use in another tool instead, use:

    ./view_latest_frame.py --print

### Scripted and live input

`sim_top` can feed controller and diagnostic events from a frame-based script:

    ./sim_top.sh 9 --events input-events.txt

Each non-comment line is `<frame> <command> [hold_frames]`. Button presses
hold for three frames unless a duration is supplied. Set the analog stick with
`<frame> analog <x> <y>`; `x` and `y` are signed 8-bit values (`-128..127`)
and are stored as `JOY0_ANALOG = { Y, X }`. Available commands are `b1`, `b2`, `analog`,
`trace_on`, `trace_off`, `instructions_on`, `instructions_off`, and `quit`.

    # Skip three screens
    154 b1
    414 b1 5
    460 b1
    500 analog 0 -128

For live control, add `--udp <port>`. A datagram may be `b1` (scheduled for
the current frame), `<frame> b1 [hold_frames]`, or `<frame> analog <x> <y>`;
it uses the same commands as the script. For example:

    printf 'b1\n' | nc -u -w1 127.0.0.1 28070
    printf 'analog 0 -128\n' | nc -u -w1 127.0.0.1 28070
    ./sim_top.sh 9 --udp 28070

Every run records events as they take effect in a unique
`/tmp/cdi-input-events-*` file. Pass that file to `--events` to replay a live
UDP session deterministically.
