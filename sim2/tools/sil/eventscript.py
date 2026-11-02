
def find_quit_frame(script_path, sim_dir):
    """Return the first absolute quit frame in a simulator event script."""
    previous_frame = 0
    with (sim_dir / script_path).open() as script:
        for line_number, line in enumerate(script, 1):
            fields = line.partition("#")[0].split()
            if not fields:
                continue
            if len(fields) < 2:
                raise ValueError(f"{script_path}:{line_number}: missing event command")
            frame_spec, command = fields[:2]
            try:
                if frame_spec.startswith("+"):
                    frame = previous_frame + int(frame_spec[1:])
                else:
                    frame = int(frame_spec)
            except ValueError as error:
                raise ValueError(
                    f"{script_path}:{line_number}: invalid frame {frame_spec}"
                ) from error
            if frame < 0:
                raise ValueError(
                    f"{script_path}:{line_number}: invalid frame {frame_spec}"
                )
            previous_frame = frame
            if command == "quit":
                return frame
    return None


def termination_description(
    sim_dir, event_script, save_on_first_cd_access, save_at_frame, max_frames
):
    # Without a script or checkpoint, running to the frame limit is the test.
    descriptions = []
    if event_script is not None:
        quit_frame = find_quit_frame(event_script, sim_dir)
        if quit_frame is not None:
            if quit_frame >= max_frames:
                raise ValueError(
                    f"{event_script}: quit at frame {quit_frame} is beyond max_frames={max_frames}"
                )
            descriptions.append(f"scripted quit at frame {quit_frame}")
    if save_at_frame is not None:
        save_frame, _ = save_at_frame
        if save_frame >= max_frames:
            raise ValueError(
                f"save_at_frame {save_frame} is beyond max_frames={max_frames}"
            )
        descriptions.append(f"save at frame {save_frame}")
    if save_on_first_cd_access is not None:
        descriptions.append("save on first CD access")
    if not descriptions and event_script is None:
        return f"complete at frame limit {max_frames}"
    if not descriptions:
        raise ValueError(
            f"No successful exit: event script {event_script!r} contains no quit "
            "and no save checkpoint was configured. Add '<frame> quit' to the "
            "script, save_at_frame=(frame, path), or save_on_first_cd_access=path. "
            f"The {max_frames}-frame watchdog only stops the job as a failure."
        )
    return ", ".join(descriptions)
