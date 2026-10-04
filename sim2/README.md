# Verilator Simulation

Verilator is much faster than ModelSim but is restricted to Verilog/SystemVerilog.
VHDL source code must be converted first.

Please use the [convert scripts](../scripts/) in case the VHDL code was changed.
To be safe, a conversion is already part of the repo.

## Prerequisites

You need CD images to use with the simulation. Only the `.bin` files are required. `.chd` is not supported.

## Usage

    ./sim_top.sh

### Restart-based save states

The simulator can write a state at a frame boundary and then exit. Restart it
with that state to continue from the same simulated time:

    ./sim_top.sh 6 --save-at-frame 300 /tmp/cdi-frame-300.vls
    ./sim_top.sh 6 --load-state /tmp/cdi-frame-300.vls

To stop at a CD seek instead, use the LBA form (decimal or `0x` hexadecimal):

    ./sim_top.sh 6 --save-at-lba 0xa6 /tmp/cdi-seek-a6.vls

The state is taken after frame 299 has been written (the frame counter is
300). The LBA form saves at the `seek_lba_valid` pulse delivered to
`hps_cd_sector_cache`. It contains the RTL model, display/audio transfer
state, and pending scripted input. Use the same machine/CD image and the same
Verilator build to restore it. Supplying `--events` with `--load-state` clears
the state’s pending scripted input and replaces it with that script; `--udp`
may be added for new live input after restoring.

### RTL performance profile

`profile_rtl.sh` builds an isolated, instrumented Verilator model and uses
`gprof` plus Verilator's `verilator_profcfunc` to attribute host time back to
RTL modules and source lines. It does not modify the normal `obj_dir` build.
The instrumented model is substantially slower, so it samples a short,
representative interval and stops cleanly to write the profile data.

    ./profile_rtl.sh 20 6

The arguments are `[seconds] [machine] [simulator options]`; for example, to
replay a workload:

    ./profile_rtl.sh 30 6 --events stimulus/fmvtest.event

Prepare the desired ROM and CD image first, as for `sim_top.sh`. Results are
kept in a newly created `/tmp/scc68070-profile.*` directory and its path is
printed at the end. Set `PROFILE_DIR` to retain builds and reports in a chosen
directory, or `PROFILE_JOBS` to control the parallel build count.

### MPEG-1 GOP and picture headers

To list sequence properties, GOP timecodes, and the temporal reference and
coding type of every picture in an MPEG-1 elementary or system/program stream:

    ./tools/mpeg1_picture_info.py path/to/video.m1v

Use `--json` for newline-delimited JSON output suitable for other tools.

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

Pass `--png` to write simulation frames as PNG files. PNG output is optional;
without it, frames are written as BMP files.

Each non-comment line is `<frame|+increment> <command> [hold_frames]`. A bare
frame number is absolute; `+increment` schedules the event that many frames
after the preceding script event (the initial frame is zero). Button presses
hold for three frames unless a duration is supplied. Set the analog stick with
`<frame|+increment> analog <x> <y>`; `x` and `y` are signed 8-bit values (`-128..127`)
and are stored as `JOY0_ANALOG = { Y, X }`. Available commands are `b1`, `b2`, `analog`,
`b1b2`, `trace_on`, `trace_off`, `instructions_on`, `instructions_off`, and `quit`.

    # Skip three screens
    154 b1
    414 b1 5
    460 b1
    500 analog 0 -128

The same sequence can use relative frame increments, which is useful when
inserting or moving groups of events:

    154 b1
    +260 b1 5
    +46 b1
    +40 analog 0 -128

For live control, add `--udp <port>`. A datagram may be `b1` (scheduled for
the current frame), `<frame> b1 [hold_frames]`, or `<frame> analog <x> <y>`;
it uses the same commands as the script. For example:

    printf 'b1\n' | nc -u -w1 127.0.0.1 28070
    printf 'analog 0 -128\n' | nc -u -w1 127.0.0.1 28070
    printf 'b1b2 3\n' | nc -u -w1 127.0.0.1 28070
    ./sim_top.sh 9 --udp 28070

Every run records events as they take effect in a unique
`/tmp/cdi-input-events-*` file. Pass that file to `--events` to replay a live
UDP session deterministically.

### UDP controller GUI

`udp_controller.py` is a small Tk GUI for the live UDP interface (it uses only
Python's standard library). Start the simulator, then start the controller in
another terminal:

    ./sim_top.sh 9 --udp 28070
    ./udp_controller.py --port 28070

Click **Button 1**, **Button 2**, or **Buttons 1 + 2**, drag the analog pad,
or use the arrow keys (WASD also works). `Z`, `X`, and `C` trigger buttons 1,
2, and 1 + 2. The host, port, and button hold duration can be changed in the
window. The analog stick stays at its last position; use **Center stick** to
return it to neutral. Use **Stop simulator** to send the UDP `quit` command.
