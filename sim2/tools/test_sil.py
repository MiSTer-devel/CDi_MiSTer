#!/usr/bin/env python3

import argparse
import html
import json
import subprocess
import sys
from pathlib import Path

from sil import analysis
from sil import machine as sil_machine
from sil.machine import (
    SilJobError,
    Machine,
    _jobs_condition,
    _graph_jobs,
    wait_for_all,
)

dry_run = False


def write_job_graph(path):
    """Write Graphviz DOT, or render SVG with the installed dot command."""
    path = Path(path)
    colors = {
        "scheduled": "#e2e8f0",
        "complete": "#bbf7d0",
        "validated": "#bfdbfe",
        "failed": "#fecaca",
    }
    lines = [
        "digraph SIL {",
        "rankdir=LR;",
        'node [shape=box, style="rounded,filled", fontname="sans-serif"];',
    ]
    with _jobs_condition:
        jobs = {key: dict(value) for key, value in _graph_jobs.items()}
    for job_id, job in jobs.items():
        label = f"Job {job_id}: {job['callback']}\n{job['disc']}\n"
        label += f"Script: {job['script']}\n{job['stop']}\n{job['status']}"
        if job.get("error"):
            label += f"\n{job['error']}"
        lines.append(
            f'job{job_id} [label={json.dumps(label)}, fillcolor="{colors[job["status"]]}"];'
        )
        if job["parent"] is not None:
            lines.append(f'job{job["parent"]} -> job{job_id};')
    lines.append("}")
    dot_source = "\n".join(lines)
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.suffix == ".svg":
        subprocess.run(
            ["dot", "-Tsvg", "-o", str(path)], input=dot_source, text=True, check=True
        )
    else:
        path.write_text(dot_source)
    print(f"SIL graph: {path.resolve()}")


def write_gantt_chart(path):
    """Write an SVG timeline with one row for each executed Vemu process."""
    with _jobs_condition:
        jobs = [dict(job, job_id=job_id) for job_id, job in _graph_jobs.items()]
    runs = [job for job in jobs if "started_at" in job and "finished_at" in job]
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    if not runs:
        path.write_text(
            '<svg xmlns="http://www.w3.org/2000/svg" width="640" height="60">'
            '<text x="12" y="36" font-family="sans-serif">No Vemu runs were executed.</text></svg>\n'
        )
        print(f"SIL Gantt chart: {path.resolve()}")
        return

    first = min(job["started_at"] for job in runs)
    last = max(job["finished_at"] for job in runs)
    elapsed = max(last - first, 0.001)
    label_width, timeline_width, row_height = 370, 800, 28
    height = 64 + row_height * len(runs)
    colors = {"complete": "#86efac", "failed": "#fca5a5"}
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{label_width + timeline_width + 20}" height="{height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        '<text x="12" y="20" font-family="sans-serif" font-size="16">SIL run timeline</text>',
    ]
    for tick in range(6):
        x = label_width + timeline_width * tick / 5
        seconds = elapsed * tick / 5
        svg.append(f'<line x1="{x:.1f}" y1="36" x2="{x:.1f}" y2="{height - 8}" stroke="#d1d5db"/>')
        svg.append(f'<text x="{x:.1f}" y="32" text-anchor="middle" font-family="sans-serif" font-size="11">{seconds:.1f}s</text>')
    for row, job in enumerate(sorted(runs, key=lambda item: item["started_at"])):
        y = 44 + row * row_height
        start = label_width + timeline_width * (job["started_at"] - first) / elapsed
        width = max(2, timeline_width * (job["finished_at"] - job["started_at"]) / elapsed)
        duration = job["finished_at"] - job["started_at"]
        label = f'Machine {job.get("machine", "?")} · Job {job["job_id"]}: {job["callback"]}'
        svg.append(f'<text x="12" y="{y + 16}" font-family="sans-serif" font-size="12">{html.escape(label)}</text>')
        svg.append(f'<rect x="{start:.1f}" y="{y}" width="{width:.1f}" height="18" rx="3" fill="{colors.get(job["status"], "#93c5fd")}"/>')
        svg.append(f'<text x="{start + width + 5:.1f}" y="{y + 14}" font-family="sans-serif" font-size="11">{duration:.2f}s</text>')
    svg.append("</svg>")
    path.write_text("\n".join(svg) + "\n")
    print(f"SIL Gantt chart: {path.resolve()}")


def print_test_summary():
    """Report every scheduled run, including setup and callback failures."""
    with _jobs_condition:
        jobs = {key: dict(value) for key, value in _graph_jobs.items()}
    labels = {
        "complete": "PASS",
        "validated": "VALIDATED",
        "failed": "FAIL",
        "scheduled": "NOT FINISHED",
    }
    totals = dict.fromkeys(labels, 0)
    print(
        "\nSIL summary (dry-run validation does not execute analysis):"
        if dry_run
        else "\nSIL summary:"
    )
    for job_id, job in jobs.items():
        totals[job["status"]] += 1
        print(
            f"  {labels[job['status']]:12} Job {job_id}: {job['callback']} — {job['disc']}"
        )
        if job.get("error"):
            print(f"    {job['error']}")
    print(
        f"Total: {len(jobs)} runs; {totals['complete']} passed, "
        f"{totals['validated']} validated, {totals['failed']} failed, "
        f"{totals['scheduled']} not finished",
        flush=True,
    )


def build_machine():
    sim_dir = Path(__file__).parent.parent
    subprocess.run(["bash", sim_dir / "produce_cdi_rom.sh"], check=True)
    subprocess.run([sim_dir / "build_top.sh"], check=True)


def _run_analysis(machine, analyzer, name, **options):
    """Keep dry-run policy in the runner; analysis only inspects real results."""
    if dry_run:
        print(f"{name}: analysis skipped during dry run")
        return
    analyzer(machine, **options)


def custom_lost_ride_no_pause_finish(machine):
    _run_analysis(
        machine, analysis.check_lost_ride_arrow, "Custom Lost Ride without Pause"
    )


def custom_lost_ride_with_pause_finish(machine):
    _run_analysis(
        machine, analysis.check_lost_ride_after_resume, "Custom Lost Ride with Pause"
    )


def custom_lost_ride_game_reached(machine):
    print("Custom Lost Ride is now at start of gameplay")
    restore_state = "savestates/custom_lost_ride_game_reached.vls"

    print("Explore a future without pauses")
    Machine().run_machine(
        custom_lost_ride_no_pause_finish,
        disc_image="images/lostride_recomp.bin",
        event_script="stimulus/lost_ride_recomp_no_pause.event",
        restore_state=restore_state,
    )

    print("Explore a future with pausing")
    Machine().run_machine(
        custom_lost_ride_with_pause_finish,
        disc_image="images/lostride_recomp.bin",
        event_script="stimulus/lost_ride_recomp_with_pause.event",
        restore_state=restore_state,
    )


def addams_family_seek(machine):
    _run_analysis(machine, analysis.check_addams_family_seek, "Addams Family Seek")


def check_addams_family_pause_resume(machine):
    print("Addams Family Pause and Resume Test finished")
    _run_analysis(
        machine,
        analysis.check_addams_family_pause_resume,
        "Addams Family Pause and Resume",
    )


def addams_family_crazypause(machine):
    _run_analysis(
        machine, analysis.check_addams_family_crazy_pause, "Addams Family Crazy Pause"
    )
    print("Addams Family Crazy Pause Test finished")


def secret_of_nimh(machine):
    # TODO Ensure that hardware is actually having that much desync!
    _run_analysis(machine, analysis.check_secret_of_nimh, "Secret of NIMH")


def secret_of_nimh_alt(machine):
    _run_analysis(
        machine, analysis.check_secret_of_nimh_alt, "Secret of NIMH (alternate)"
    )


def sil_test_flying_mattes(machine):
    _run_analysis(machine, analysis.check_flying_mattes, "Flying Mattes")


def sil_test_movingwindow1(machine):
    _run_analysis(
        machine, analysis.check_moving_window, "Moving Window 1", fixed_reference=False
    )


def sil_test_movingwindow2(machine):
    _run_analysis(
        machine, analysis.check_moving_window, "Moving Window 2", fixed_reference=True
    )


def addams_family_resume_from_slow_motion(machine):
    _run_analysis(
        machine, analysis.check_addams_family_resume_from_slow_motion, "Addams Family Slow Motion Resume"
    )


def addams_family_freeze_frame_and_resume(machine):
    _run_analysis(
        machine, analysis.check_addams_family_freeze_frame_and_resume, "Addams Family Freeze Frame Resume"
    )

def addams_family_slowmotion_reached(machine):
    restore_state = "savestates/cdi_addams_slow_motion_reached.vls"
    # We are in slow motion right now
    # We can now either resume normal playback or go for freeze frame

    Machine().run_machine(
        addams_family_resume_from_slow_motion,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_slowmotion.event",
        restore_state=restore_state,
    )

    Machine().run_machine(
        addams_family_freeze_frame_and_resume,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_freeze.event",
        restore_state=restore_state,
    )


def addams_family_pbc_reached(machine):
    print("Addams family now allows opening PBC")
    restore_state = "savestates/cdi_addams_before_pbc.vls"

    Machine().run_machine(
        addams_family_seek,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_seek.event",
        restore_state=restore_state,
    )

    Machine().run_machine(
        check_addams_family_pause_resume,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_pause.event",
        restore_state=restore_state,
    )

    Machine().run_machine(
        addams_family_crazypause,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_crazypause.event",
        restore_state=restore_state,
    )

    # Freeze Frame and Slow Motion are taking the same pathes first
    Machine().run_machine(
        addams_family_slowmotion_reached,
        disc_image="images/addams.bin",
        event_script="stimulus/addams_slowmotion.event",
        restore_state=restore_state,
        save_at_frame=(
            357,  # Just after Slow Motion PBC has been opened
            "savestates/cdi_addams_slow_motion_reached.vls",
        ),
    )


def boot_save_state_ready(machine):
    print("Boot save state has been generated")
    restore_state = "savestates/cdi_after_boot.vls"

    Machine().run_machine(
        custom_lost_ride_game_reached,
        disc_image="images/lostride_recomp.bin",
        event_script="stimulus/lost_ride_recomp_no_pause.event",
        save_at_frame=(
            1120,
            "savestates/custom_lost_ride_game_reached.vls",
        ),
        restore_state=restore_state,
    )

    Machine().run_machine(
        addams_family_pbc_reached,
        disc_image="images/addams.bin",
        save_at_frame=(313, "savestates/cdi_addams_before_pbc.vls"),
        restore_state=restore_state,
    )

    Machine().run_machine(
        secret_of_nimh_alt,
        disc_image="images/nimh_alt.bin",
        event_script="stimulus/nimh1_alt_resume.event",
        restore_state=restore_state,
    )

    Machine().run_machine(
        secret_of_nimh,
        disc_image="images/nimh.bin",
        event_script="stimulus/nimh_resume.event",
        restore_state=restore_state,
    )

    Machine().run_machine(
        sil_test_flying_mattes,
        disc_image="images/sil_test_flying_mattes.bin",
        restore_state=restore_state,
        max_frames=500,
    )

    # Content begins around frame 154. Ending at 600 leaves about 446 content
    # frames, enough for both window tests' 400-frame minimum.
    Machine().run_machine(
        sil_test_movingwindow1,
        disc_image="images/sil_test_movingwindow1.bin",
        restore_state=restore_state,
        max_frames=600,
    )

    Machine().run_machine(
        sil_test_movingwindow2,
        disc_image="images/sil_test_movingwindow2.bin",
        restore_state=restore_state,
        max_frames=600,
    )


# Only expose callbacks with implemented analysis, not callbacks that schedule
# more simulator jobs or placeholders that would report success without checks.
ANALYSIS_TESTS = {
    "lost-ride-no-pause": custom_lost_ride_no_pause_finish,
    "lost-ride-with-pause": custom_lost_ride_with_pause_finish,
    "addams-seek": addams_family_seek,
    "addams-pause-resume": check_addams_family_pause_resume,
    "addams-crazy-pause": addams_family_crazypause,
    "addams-slow-motion-resume": addams_family_resume_from_slow_motion,
    "addams-freeze-frame-resume": addams_family_freeze_frame_and_resume,
    "flying-mattes": sil_test_flying_mattes,
    "secret-of-nimh": secret_of_nimh,
    "secret-of-nimh-alt": secret_of_nimh_alt,
    "movingwindow1": sil_test_movingwindow1,
    "movingwindow2": sil_test_movingwindow2,
}


def parse_frame_range(value):
    try:
        first, last = (int(part) for part in value.split(":"))
        if first < 0 or last < first:
            raise ValueError
    except ValueError as error:
        raise argparse.ArgumentTypeError(
            "use FIRST:LAST with 0 <= FIRST <= LAST (inclusive)"
        ) from error
    return first, last


def main():
    global dry_run
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="validate the SIL job graph without running Vemu",
    )
    parser.add_argument(
        "--graph",
        type=Path,
        nargs="?",
        const=Path("/tmp/sil-graph.svg"),
        default=Path("/tmp/sil-graph.svg"),
        help="destination for the always-generated graph (.svg via Graphviz, otherwise DOT); default: /tmp/sil-graph.svg",
    )
    parser.add_argument(
        "--gantt",
        type=Path,
        nargs="?",
        const=Path("/tmp/sil-gantt.svg"),
        default=Path("/tmp/sil-gantt.svg"),
        help="destination for the always-generated SVG timeline of Vemu runs; default: /tmp/sil-gantt.svg",
    )
    parser.add_argument(
        "--analyze",
        choices=ANALYSIS_TESTS,
        help="analyze existing output without building or running Vemu",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="directory containing video frames and/or stdout.log, stderr.log",
    )
    parser.add_argument(
        "--frames",
        type=parse_frame_range,
        metavar="FIRST:LAST",
        help="inclusive video frame range for manual analysis",
    )
    args = parser.parse_args()
    if args.analyze:
        if args.output_dir is None:
            parser.error("--analyze requires --output-dir")
        if args.dry_run:
            parser.error("--analyze cannot be combined with --dry-run")
        dry_run = False
        # Manual analysis participates in the same graph and summary as runs.
        with _jobs_condition:
            _graph_jobs[0] = {
                "parent": None,
                "callback": args.analyze,
                "disc": str(args.output_dir),
                "script": "existing output",
                "stop": (
                    f"frames {args.frames}" if args.frames else "all available frames"
                ),
                "status": "scheduled",
            }
        try:
            machine = Machine.from_output_dir(args.output_dir, args.frames)
            print(f"Analyze {args.analyze}: {machine.output_dir}", flush=True)
            ANALYSIS_TESTS[args.analyze](machine)
            with _jobs_condition:
                _graph_jobs[0]["status"] = "complete"
        except (AssertionError, OSError, ValueError, ImportError) as error:
            with _jobs_condition:
                _graph_jobs[0].update(status="failed", error=str(error))
            print(
                f"ANALYSIS FAILED ({args.analyze}): {error}",
                file=sys.stderr,
                flush=True,
            )
            return 1
        finally:
            print_test_summary()
            write_job_graph(args.graph)
            write_gantt_chart(args.gantt)
        return 0
    if args.output_dir is not None or args.frames is not None:
        parser.error("--output-dir and --frames require --analyze")
    dry_run = args.dry_run
    sil_machine.dry_run = dry_run

    try:
        if not dry_run:
            build_machine()

        Machine().run_machine(
            boot_save_state_ready,
            save_on_first_cd_access="savestates/cdi_after_boot.vls",
            max_frames=200,
        )
        
        if not wait_for_all():
            return 1
    finally:
        # Include failed runs even when validation aborts the dry run. Print the
        # summary first so a graph-rendering failure cannot hide test results.
        print_test_summary()
        write_job_graph(args.graph)
        write_gantt_chart(args.gantt)

    print("Simulation has ended")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SilJobError as error:
        print(error, file=sys.stderr, flush=True)
        raise SystemExit(1)
