import sys
from pathlib import Path
from collections import deque
from contextlib import contextmanager
import threading
import subprocess
import time

if __package__:
    from .eventscript import *
else:
    from eventscript import *

import tempfile


class _ThreadLocalStdout:
    """Route stdout for the current thread without affecting other SIL jobs."""

    def __init__(self, fallback):
        self.fallback = fallback
        self.stream = threading.local()

    def write(self, data):
        return getattr(self.stream, "value", self.fallback).write(data)

    def flush(self):
        return getattr(self.stream, "value", self.fallback).flush()

    def __getattr__(self, name):
        return getattr(self.fallback, name)

    @contextmanager
    def redirect(self, path):
        with path.open("w") as output:
            previous = getattr(self.stream, "value", None)
            self.stream.value = output
            try:
                yield
            finally:
                if previous is None:
                    del self.stream.value
                else:
                    self.stream.value = previous


_stdout_router = _ThreadLocalStdout(sys.stdout)
sys.stdout = _stdout_router

DEFAULT_MAX_FRAMES = 2000
MACHINE_COUNT = 13
LOG_DIR = Path("/tmp/cdi-sil-logs")

# Each Condition owns a mutex: protect ID allocation separately from job tracking.
_machine_condition = threading.Condition()
# FIFO reuse keeps a released ID behind IDs that have not been used recently.
_available_machines = deque(range(MACHINE_COUNT))

dry_run = False

_jobs_condition = threading.Condition()
_active_jobs = 0
_next_job_id = 0
_job_failed = False
_graph_jobs = {}
# Callback context belongs to its worker; parallel branches must not share it.
_callback_context = threading.local()


def alloc_machine():
    with _machine_condition:
        while not _available_machines:
            _machine_condition.wait()
        return _available_machines.popleft()


def release_machine(index):
    if not 0 <= index < MACHINE_COUNT:
        raise ValueError(f"invalid machine index: {index}")
    with _machine_condition:
        if index in _available_machines:
            raise ValueError(f"machine {index} is already available")
        _available_machines.append(index)
        print(f"Machine {index} is released")
        _machine_condition.notify()


def wait_for_all():
    """Wait for all scheduled simulator jobs and return whether they succeeded."""
    with _jobs_condition:
        while _active_jobs:
            _jobs_condition.wait()
        return not _job_failed


class SilJobError(RuntimeError):
    """A job failure with enough context to identify its SIL branch."""


class Machine:
    """One SIL run with direct access to its video output and separate logs.

    Call run_machine(callback, ...) to start. Successful callbacks receive this
    object. images maps absolute frame numbers to PNG/BMP paths; open_image()
    loads a frame with Pillow when pixel analysis is needed. stdout_path and
    stderr_path expose the complete process logs. Analyze images in the callback:
    later reuse of the machine ID can overwrite them. Dry runs produce no artifacts.
    """

    def __init__(self):
        # Filled by the worker. Video files are stable for the callback's duration.
        self.machine_index = None
        self.job_id = None
        self.output_dir = None
        self.stdout_path = None
        self.stderr_path = None
        self.analysis_path = None
        self.images = {}
        self.result = None
        self.thread = None

    @classmethod
    def from_output_dir(cls, directory, frame_range=None):
        """Load existing results for manual analysis without starting Vemu."""
        directory = Path(directory).resolve()
        if not directory.is_dir():
            raise ValueError(f"output directory does not exist: {directory}")
        machine = cls()
        machine.output_dir = directory
        machine.stdout_path = directory / "stdout.log"
        machine.stderr_path = directory / "stderr.log"
        for path in sorted(directory.glob("video_*")):
            number = path.stem.removeprefix("video_")
            if path.suffix.lower() not in (".png", ".bmp") or not number.isdecimal():
                continue
            frame = int(number)
            if (
                frame_range is not None
                and not frame_range[0] <= frame <= frame_range[1]
            ):
                continue
            if frame in machine.images:
                raise ValueError(f"multiple images for frame {frame} in {directory}")
            machine.images[frame] = path
        machine.images = dict(sorted(machine.images.items()))
        if frame_range is not None and not machine.images:
            raise ValueError(
                f"no video frames in range {frame_range[0]}:{frame_range[1]} in {directory}"
            )
        return machine

    def open_image(self, frame):
        """Return a loaded Pillow image; callers may edit it independently."""
        # Keep Pillow optional for runs that only need file paths or log analysis.
        from PIL import Image

        with Image.open(self.images[frame]) as image:
            return image.copy()

    def run_machine(
        self,
        callback,
        disc_image=None,
        restore_state=None,
        event_script=None,
        save_on_first_cd_access=None,
        save_at_frame=None,
        max_frames=DEFAULT_MAX_FRAMES,
    ):
        """Start a simulator asynchronously and call callback(self) on success.

        save_at_frame must be a (frame, state_path) pair. max_frames is a
        non-zero frame watchdog. Call wait_for_all() after scheduling work to
        surface any failed simulator process or callback.
        """
        if self.thread is not None:
            raise RuntimeError("a Machine represents one run; create another Machine")
        sim_dir = Path(__file__).parent.parent.parent
        if save_at_frame is not None:
            try:
                save_frame, save_path = save_at_frame
            except (TypeError, ValueError) as error:
                raise ValueError(
                    "save_at_frame must be a (frame, state_path) pair"
                ) from error
        if max_frames <= 0:
            raise ValueError("max_frames must be positive")

        def worker():
            machine_index = None
            command_text = "(command not constructed)"
            try:
                machine_index = alloc_machine()
                self.machine_index = machine_index
                with _jobs_condition:
                    _graph_jobs[job_id]["machine"] = machine_index
                command = [sim_dir / "obj_dir" / "Vemu", str(machine_index), "--auto"]

                if disc_image is not None:
                    command.extend(("--image", str(disc_image)))
                if restore_state is not None:
                    command.extend(("--load-state", str(restore_state)))
                if event_script is not None:
                    command.extend(("--events", str(event_script)))
                if save_on_first_cd_access is not None:
                    command.extend(
                        ("--save-on-first-cd-access", str(save_on_first_cd_access))
                    )
                if save_at_frame is not None:
                    command.extend(("--save-at-frame", str(save_frame), str(save_path)))
                command.extend(("--max-frames", str(max_frames)))

                command_text = subprocess.list2cmdline(
                    [str(argument) for argument in command]
                )
                termination = termination_description(
                    sim_dir,
                    event_script,
                    save_on_first_cd_access,
                    save_at_frame,
                    max_frames,
                )
                with _jobs_condition:
                    _graph_jobs[job_id]["stop"] = termination

                if dry_run:
                    # Still invoke callbacks below, so validation follows every branch.
                    print(
                        "Dry-run machine:",
                        command_text,
                        f"({termination}; watchdog {max_frames} frames)",
                    )
                else:
                    LOG_DIR.mkdir(parents=True, exist_ok=True)
                    # Keep only the logs in a unique per-job directory.
                    log_dir = Path(
                        tempfile.mkdtemp(
                            prefix=f"job-{job_id}-machine-{machine_index}-", dir=LOG_DIR
                        )
                    )
                    stdout_path = self.stdout_path = log_dir / "stdout.log"
                    stderr_path = self.stderr_path = log_dir / "stderr.log"
                    self.analysis_path = log_dir / "analysis.log"
                    video_dir = self.output_dir = sim_dir / str(machine_index)

                    def video_files():
                        return [
                            path
                            for path in video_dir.glob("video_*")
                            if path.suffix in (".png", ".bmp")
                        ]

                    # Vemu reuses <sim_dir>/<machine_index>; record old frames so stale
                    # output from an earlier run is excluded from this run's images.
                    before = {path: path.stat() for path in video_files()}
                    print(
                        f"Run machine {machine_index}; stdout: {stdout_path}; stderr: {stderr_path} ({termination})"
                    )
                    print(f"  $ {command_text}")
                    started_at = time.monotonic()
                    with _jobs_condition:
                        _graph_jobs[job_id]["started_at"] = started_at
                    try:
                        with stdout_path.open("w") as stdout_log, stderr_path.open(
                            "w"
                        ) as stderr_log:
                            result = subprocess.run(
                                command, cwd=sim_dir, stdout=stdout_log, stderr=stderr_log
                            )
                    finally:
                        with _jobs_condition:
                            _graph_jobs[job_id]["finished_at"] = time.monotonic()
                    self.result = result

                    # Reference new/changed frames in place; do not duplicate them.
                    for path in video_files():
                        old_stat = before.get(path)
                        new_stat = path.stat()
                        if old_stat is not None and (
                            old_stat.st_mtime_ns,
                            old_stat.st_ctime_ns,
                            old_stat.st_size,
                        ) == (
                            new_stat.st_mtime_ns,
                            new_stat.st_ctime_ns,
                            new_stat.st_size,
                        ):
                            continue
                        self.images[int(path.stem.removeprefix("video_"))] = path
                    self.images = dict(sorted(self.images.items()))
                    if result.returncode:
                        raise subprocess.CalledProcessError(
                            result.returncode,
                            command,
                            stderr=f"see {stdout_path} and {stderr_path}",
                        )

                # Hold the ID until the callback finishes analyzing its video files.
                # Child jobs start asynchronously and can wait for an available ID.
                with _jobs_condition:
                    _graph_jobs[job_id]["status"] = (
                        "validated" if dry_run else "complete"
                    )
                previous_parent = getattr(_callback_context, "parent", None)
                _callback_context.parent = job_id
                try:
                    if self.analysis_path is None:
                        callback(self)
                    else:
                        with _stdout_router.redirect(self.analysis_path):
                            callback(self)
                finally:
                    _callback_context.parent = previous_parent
            except BaseException as error:
                # A child's dry-run error already identifies its failing graph node.
                if not isinstance(error, SilJobError):
                    with _jobs_condition:
                        _graph_jobs[job_id].update(status="failed", error=str(error))
                # Dry runs execute synchronously, so a bad child stops its parent
                # callback immediately instead of disappearing into a worker thread.
                if dry_run:
                    if isinstance(error, SilJobError):
                        raise
                    raise SilJobError(
                        f"DRY RUN FAILED: SIL job {job_id}, machine {self.machine_index}\n"
                        f"  Callback: {getattr(callback, '__name__', repr(callback))}\n"
                        f"  Disc: {disc_image or '(default)'}\n"
                        f"  Restore state: {restore_state or '(none)'}\n"
                        f"  Event script: {event_script or '(none)'}\n"
                        f"  Command: {command_text}\n"
                        f"  Reason: {error}"
                    ) from error
                print(
                    f"SIL job {job_id} on machine {machine_index} failed: {error}",
                    file=sys.stderr,
                    flush=True,
                )
                if isinstance(error, subprocess.CalledProcessError) and error.stderr:
                    print(error.stderr, file=sys.stderr, flush=True)
                with _jobs_condition:
                    global _job_failed
                    _job_failed = True
            finally:
                if machine_index is not None:
                    release_machine(machine_index)
                with _jobs_condition:
                    global _active_jobs
                    # Keep the parent active through its callback: child jobs must be
                    # registered before wait_for_all() can observe zero active jobs.
                    _active_jobs -= 1
                    _jobs_condition.notify_all()

        with _jobs_condition:
            global _active_jobs, _next_job_id
            job_id = _next_job_id
            self.job_id = job_id
            _graph_jobs[job_id] = {
                "parent": getattr(_callback_context, "parent", None),
                "callback": getattr(callback, "__name__", repr(callback)),
                "disc": str(disc_image or "default disc"),
                "script": str(event_script or "none"),
                "stop": f"frame limit {max_frames}",
                "status": "scheduled",
            }
            _next_job_id += 1
            # Register before starting the thread, preventing an early completion race.
            _active_jobs += 1
        if dry_run:
            # No processes need concurrency here. Propagate errors directly to the
            # caller and stop exploring sibling branches after the first failure.
            self.thread = threading.current_thread()
            worker()
            return self
        thread = threading.Thread(target=worker)
        self.thread = thread
        thread.start()
        return self
