"""Log and image checks for SIL runs and manual analysis.

Checks consume a Machine-like object exposing images, stdout_path, and output_dir.
They raise AssertionError on failure and do not build, schedule, or run simulators.
Pillow is imported only by image checks, so log analysis does not require it.
"""

from pathlib import Path
from PIL import Image, ImageChops


def lost_ride_arrow_mask(image):
    """Select the pale blue/white arrow while rejecting the brown/green mine."""

    red, green, blue = image.convert("RGB").split()
    mask = ImageChops.darker(
        red.point(lambda value: 255 if value >= 100 else 0),
        green.point(lambda value: 255 if value >= 120 else 0),
    )
    mask = ImageChops.darker(mask, blue.point(lambda value: 255 if value >= 140 else 0))
    # The arrow is slightly blue; bright warm-colored scenery is not a match.
    return ImageChops.darker(
        mask,
        ImageChops.subtract(red, blue).point(lambda value: 255 if value == 0 else 0),
    )


def lost_ride_arrow_components(mask):
    """Find eight-connected bright regions; return their exclusive bounds."""
    width, height = mask.size
    remaining = {index for index, value in enumerate(mask.tobytes()) if value}
    components = []
    while remaining:
        first = remaining.pop()
        pending = [first]
        left = right = first % width
        top = bottom = first // width
        count = 0
        while pending:
            index = pending.pop()
            y, x = divmod(index, width)
            left, right = min(left, x), max(right, x)
            top, bottom = min(top, y), max(bottom, y)
            count += 1
            for yy in range(max(0, y - 1), min(height, y + 2)):
                for xx in range(max(0, x - 1), min(width, x + 2)):
                    neighbor = yy * width + xx
                    if neighbor in remaining:
                        remaining.remove(neighbor)
                        pending.append(neighbor)
        if count >= 12:
            components.append((left, top, right + 1, bottom + 1))
    return sorted(components)


def _check_lost_ride_arrow(machine, allow_jitter):
    """Share arrow detection while keeping the two tests' acceptance distinct."""

    reference_dir = Path(__file__).parent
    references = []
    for name in ("ref_lostride0.png", "ref_lostride1.png"):
        with Image.open(reference_dir / name) as image:
            mask = lost_ride_arrow_mask(image)
        components = lost_ride_arrow_components(mask)
        if not components:
            raise AssertionError(
                f"Custom Lost Ride: no arrow in reference {reference_dir / name}"
            )
        bounds = max(components, key=lambda box: (box[2] - box[0]) * (box[3] - box[1]))
        references.append((mask, bounds))

    # The sign crosses the tunnel and grows as the vehicle approaches. Search
    # this scene region, excluding the HUD and bright cockpit controls below.
    search_box = (600, 440, 1600, 700)
    minimum_score = 0.65
    checked = 0
    first_checked = None
    previous_frame = None
    worst_score = 1.0
    jitter_frames = []
    previous_jitter = False
    for frame, path in sorted(machine.images.items()):
        if frame < 1247:
            continue
        with Image.open(path) as image:
            if image.size != (1920, 1248):
                raise AssertionError(
                    f"Custom Lost Ride: unsupported frame size {image.size} in {path}"
                )
            scene = image.convert("RGB").crop(search_box)
        mask = lost_ride_arrow_mask(scene)
        best_score = 0.0
        matches = 0
        for left, top, right, bottom in lost_ride_arrow_components(mask):
            width, height = right - left, bottom - top
            # At long distance, the arrow is only one output block wide. Once
            # larger, reject thin fragments which could be half a broken arrow.
            minimum_aspect = 0.25 if height <= 16 else 0.4
            if not (
                4 <= width <= 100
                and 8 <= height <= 100
                and minimum_aspect <= width / height <= 1.2
            ):
                continue
            candidate = mask.crop((left, top, right, bottom))
            orientation_scores = [0.0, 0.0]
            for reference, bounds in references:
                arrow = reference.crop(bounds).resize(
                    candidate.size, Image.Resampling.NEAREST
                )
                for flipped in (0, 1):
                    expected_arrow = (
                        arrow.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
                        if flipped
                        else arrow
                    )
                    intersection = ImageChops.darker(
                        candidate, expected_arrow
                    ).histogram()[255]
                    union = ImageChops.lighter(candidate, expected_arrow).histogram()[
                        255
                    ]
                    orientation_scores[flipped] = max(
                        orientation_scores[flipped], intersection / union
                    )
            # Very small arrows can be almost symmetric after quantization.
            # Reject a clearly better match to the wrong (mirrored) direction.
            if orientation_scores[1] > orientation_scores[0] + 0.05:
                continue
            candidate_score = 0.0
            for reference, bounds in references:
                # Anchor each reference at the detected arrow. Independent
                # horizontal/vertical scaling handles perspective and pixel
                # quantization; retain the dark sign around it to penalize
                # duplicate arrows, instead of accepting any matching fragment.
                sx = width / (bounds[2] - bounds[0])
                sy = height / (bounds[3] - bounds[1])
                size = (round(reference.width * sx), round(reference.height * sy))
                expected = reference.resize(size, Image.Resampling.NEAREST)
                x, y = left - round(bounds[0] * sx), top - round(bounds[1] * sy)
                actual = mask.crop((x, y, x + size[0], y + size[1]))
                # Similarity alone could tolerate a second, smaller arrow on
                # the black board. Both approved signs have one bright region.
                if len(lost_ride_arrow_components(actual)) != 1:
                    continue
                intersection = ImageChops.darker(expected, actual).histogram()[255]
                union = ImageChops.lighter(expected, actual).histogram()[255]
                score = intersection / union if union else 0.0
                candidate_score = max(candidate_score, score)
            best_score = max(best_score, candidate_score)
            if candidate_score >= minimum_score:
                matches += 1

        # Pausing shifts scene progress: start looking at 1247, but allow the
        # sign to appear later. Once acquired it must remain valid every frame.
        if checked == 0 and matches == 0:
            continue
        missing_frame = previous_frame is not None and frame != previous_frame + 1
        bad_arrow = matches != 1
        # Resume jitter in the known example lasts one frame at a time. Missing
        # output is never jitter, and two bad frames in succession still fail.
        if missing_frame or (bad_arrow and (not allow_jitter or previous_jitter)):
            diagnostic = machine.output_dir / f"lost-ride-arrow-failure-{frame}.png"
            scene.save(diagnostic)
            raise AssertionError(
                f"Custom Lost Ride: missing, malformed, or duplicate arrow in {path}; "
                f"{matches} matches, best similarity {best_score:.3f} (need {minimum_score:.2f}); "
                f"previous checked frame {previous_frame}; sign-region image: {diagnostic}"
            )
        if bad_arrow:
            jitter_frames.append(frame)
        previous_jitter = bad_arrow
        if first_checked is None:
            first_checked = frame
        checked += 1
        previous_frame = frame
        worst_score = min(worst_score, best_score)
    if checked == 0:
        raise AssertionError(
            "Custom Lost Ride: no reference-matching arrow found from frame 1247 onward"
        )
    # Isolated defects are accepted only in the pause/resume test, and only
    # while at least 80% of the acquired sequence remains reference-correct.
    # This prevents alternating good/bad output from silently passing as jitter.
    if allow_jitter and len(jitter_frames) > checked * 0.20:
        raise AssertionError(
            f"Custom Lost Ride after resume: excessive jitter in {machine.output_dir}: "
            f"{len(jitter_frames)}/{checked} frames (maximum 20%); frames {jitter_frames}"
        )
    print(
        f"Custom Lost Ride arrow{' after resume' if allow_jitter else ''} passed: "
        f"{checked} frames ({first_checked}–{previous_frame}), "
        f"lowest similarity {worst_score:.3f}"
    )
    if allow_jitter:
        print(
            f"  Tolerated {len(jitter_frames)} isolated jitter frames: {jitter_frames}"
        )


def check_lost_ride_arrow(machine):
    """No-pause test: every acquired sign frame must match a reference."""
    _check_lost_ride_arrow(machine, allow_jitter=False)


def check_lost_ride_after_resume(machine):
    """Pause/resume test: tolerate bounded, isolated arrow jitter."""
    _check_lost_ride_arrow(machine, allow_jitter=True)


def check_addams_family_crazy_pause(machine):
    # Check for stability while hammering B1 to pause and resume

    paused = False
    timecnt = 0
    first_pause = True
    with machine.stdout_path.open() as log:
        for line in log:
            fields = line.split()

            if "MV_Pause" in fields:
                print(f"Pause after {timecnt} first_pause {first_pause}")
                assert first_pause or timecnt < 350, f"timecnt {timecnt} too large"
                paused = True
                first_pause = False
                timecnt = 0

            if "MV_Continue" in fields:
                print("Continue")
                paused = False
                timecnt = 0

            if fields and fields[0] == "desync_valid":
                desync = int(fields[3])
                # print(desync)

            if fields and fields[0] == "Time":
                timecnt += 1

    assert timecnt < 350, f"timecnt {timecnt} too large"
    print(f"Timecnt on end {timecnt}")


def check_addams_family_resume_from_slow_motion(machine):
    desync_max = 350
    stabilizing_frames_cnt = 0
    buffers_below_10 = False

    chspeed_to_normal = False

    with machine.stdout_path.open() as log:
        for line in log:
            fields = line.split()
            if "MV_ChSpeed" in fields:
                print("Chspeed")
                chspeed_to_normal = True

            if chspeed_to_normal and fields and fields[0] == "desync_valid":
                desync = int(fields[3])
                buffers = int(fields[5])

                # Move target. Must never be worse

                if buffers_below_10:
                    desync_max = desync
                    print(desync_max)

                    assert (
                        desync < desync_max + 2
                    ), f"Desync not acceptable {desync} {desync_max}"

                else:
                    stabilizing_frames_cnt += 1

                print(desync, buffers, stabilizing_frames_cnt)

                if buffers < 10 and not buffers_below_10:
                    buffers_below_10 = True
                    print("buffers below 10")

    assert stabilizing_frames_cnt > 80, "No speedup?"
    assert chspeed_to_normal
    assert buffers_below_10
    print("Addams Family - Resume from Slow Motion checked")


def check_addams_family_freeze_frame_and_resume(machine):
    at_least_frozen_once = False
    at_least_continued_once = False

    frozen = False
    desync_max = 50

    with machine.stdout_path.open() as log:
        for line in log:
            fields = line.split()

            if "MV_Freeze" in fields:
                print("Freeze")
                assert not frozen
                frozen = True
                at_least_frozen_once = True

            if "MV_Continue" in fields:
                print("Continue")
                assert frozen
                frozen = False
                at_least_continued_once = True

            if at_least_continued_once and fields and fields[0] == "desync_valid":
                desync = int(fields[3])
                print(desync)

                assert (
                    desync < desync_max + 2
                ), f"Desync not acceptable {desync} {desync_max}"

                # Move target. Must never be worse
                desync_max = desync
                print(desync_max)
    assert desync_max < 10
    assert at_least_continued_once
    assert at_least_frozen_once


def check_addams_family_pause_resume(machine):
    # Check for resync after resume
    paused = False
    desync_max = 50

    with machine.stdout_path.open() as log:
        for line in log:
            fields = line.split()

            if "MV_Pause" in fields:
                print("Pause")
                assert not paused
                paused = True

            if "MV_Continue" in fields:
                print("Continue")
                assert paused
                paused = False
                desync_max = 50

            if fields and fields[0] == "desync_valid":
                desync = int(fields[3])
                print(desync)

                assert (
                    desync < desync_max + 2
                ), f"Desync not acceptable {desync} {desync_max}"

                # Move target. Must never be worse
                desync_max = desync
                print(desync_max)


def check_addams_family_seek(machine):
    # MV_ syscall rows provide context; desync_valid rows carry the signed
    # desynchronization measurement in the fourth whitespace-separated column.
    checked = 0
    peak = 0
    previous_violation = None
    required_commands = {"MV_Next": 0, "SS_Play": 0}
    with machine.stdout_path.open() as log:
        for line_number, line in enumerate(log, 1):
            fields = line.split()
            # Count exact command tokens, avoiding similarly named commands.
            for command in required_commands:
                required_commands[command] += fields.count(command)
            # A new seek starts a fresh recovery sequence; do not combine an
            # outlier before MV_Next with one after it into a consecutive pair.
            if "MV_Next" in fields:
                previous_violation = None
            if not fields or fields[0] != "desync_valid":
                continue
            try:
                desync = int(fields[3])
            except (IndexError, ValueError) as error:
                raise AssertionError(
                    f"Addams Family Seek: malformed desync row at "
                    f"{machine.stdout_path}:{line_number}: {line.strip()}"
                ) from error
            checked += 1
            peak = max(peak, abs(desync))
            if abs(desync) > 30:
                if previous_violation is not None:
                    previous_line, previous_value = previous_violation
                    raise AssertionError(
                        f"Addams Family Seek: two consecutive measurements outside [-30, 30]: "
                        f"{previous_value} at {machine.stdout_path}:{previous_line}, "
                        f"then {desync} at {machine.stdout_path}:{line_number}\n  {line.strip()}"
                    )
                previous_violation = (line_number, desync)
            else:
                previous_violation = None

    if checked == 0:
        raise AssertionError(
            f"Addams Family Seek: no desync_valid measurements in {machine.stdout_path}"
        )
    missing = [
        f"{command}: found {count}, need at least 2"
        for command, count in required_commands.items()
        if count < 2
    ]
    if missing:
        raise AssertionError(
            f"Addams Family Seek: {'; '.join(missing)} in {machine.stdout_path}"
        )
    print(
        f"Addams Family Seek passed: {checked} measurements, peak absolute desync {peak}, "
        f"MV_Next={required_commands['MV_Next']}, SS_Play={required_commands['SS_Play']}"
    )


def check_secret_of_nimh(machine):
    """Verify speed-change order and the normal disc's desync rise/recovery."""
    expected_speeds = (0x7FFFFFFF, 0)
    speed_lines = []
    readings = []
    with machine.stdout_path.open() as log:
        for line_number, line in enumerate(log, 1):
            fields = line.split()
            if "MV_ChSpeed" in fields:
                # Analyze Syscall prints D0..D7 immediately after I$SetStt.
                # D5 is therefore the sixth register, not the syscall argument
                # in D1 (which can also contain part of the speed value).
                try:
                    register_start = fields.index("I$SetStt") + 1
                    speed = int(fields[register_start + 5], 16)
                except (ValueError, IndexError) as error:
                    raise AssertionError(
                        f"Secret of NIMH: malformed MV_ChSpeed register dump "
                        f"at {machine.stdout_path}:{line_number}: {line.strip()}"
                    ) from error
                call_index = len(speed_lines)
                if call_index >= len(expected_speeds):
                    raise AssertionError(
                        f"Secret of NIMH: unexpected extra MV_ChSpeed at "
                        f"{machine.stdout_path}:{line_number}, D5={speed:08x}"
                    )
                if speed != expected_speeds[call_index]:
                    raise AssertionError(
                        f"Secret of NIMH: MV_ChSpeed call {call_index + 1} has "
                        f"D5={speed:08x}, expected {expected_speeds[call_index]:08x}, "
                        f"at {machine.stdout_path}:{line_number}"
                    )
                speed_lines.append(line_number)
                continue
            # Desync during startup or before normal speed is restored is not
            # part of this recovery sequence. Column 4 is the signed error.
            if len(speed_lines) != 2 or not fields or fields[0] != "desync_valid":
                continue
            try:
                readings.append((line_number, abs(int(fields[3]))))
            except (IndexError, ValueError) as error:
                raise AssertionError(
                    f"Secret of NIMH: malformed desync row at "
                    f"{machine.stdout_path}:{line_number}: {line.strip()}"
                ) from error

    if len(speed_lines) != 2:
        raise AssertionError(
            f"Secret of NIMH: found {len(speed_lines)} MV_ChSpeed calls in "
            f"{machine.stdout_path}; need D5=7fffffff followed by D5=00000000"
        )
    if not readings:
        raise AssertionError(
            f"Secret of NIMH: no desync measurements after normal-speed "
            f"MV_ChSpeed at {machine.stdout_path}:{speed_lines[1]}"
        )

    # The normal disc overshoots before recovering (the example peaks at 259).
    # Do not apply the alternate disc's 60-unit ceiling to this test.
    peak_index = max(range(len(readings)), key=lambda index: readings[index][1])
    peak_line, peak = readings[peak_index]
    if peak < 230 or peak_index == 0 or peak <= readings[0][1]:
        raise AssertionError(
            f"Secret of NIMH: desync did not rise to at least 230 after restoring "
            f"normal speed in {machine.stdout_path}; first={readings[0][1]}, peak={peak}"
        )
    recovery = readings[peak_index:]
    if len(recovery) < 3 or recovery[-1][1] >= peak:
        raise AssertionError(
            f"Secret of NIMH: no sustained recovery after peak {peak} at "
            f"{machine.stdout_path}:{peak_line}; need at least two later measurements "
            f"and a lower final value (found {len(recovery) - 1}, final={recovery[-1][1]})"
        )
    for previous, current in zip(recovery, recovery[1:]):
        if current[1] > previous[1] + 2:
            raise AssertionError(
                f"Secret of NIMH: desync increased during recovery from {previous[1]} "
                f"at {machine.stdout_path}:{previous[0]} to {current[1]} at "
                f"{machine.stdout_path}:{current[0]} (maximum allowed increase: 2)"
            )
    print(
        f"Secret of NIMH passed: MV_ChSpeed D5=7fffffff then 00000000, "
        f"{len(readings)} measurements, desync {readings[0][1]} → {peak} → {readings[-1][1]}"
    )


def check_secret_of_nimh_alt(machine):
    """Verify the alternate disc's MV_Continue recovery within 60 units."""

    resumes = 0
    checked = 0
    section_samples = 0
    previous = None
    continue_line = None
    with machine.stdout_path.open() as log:
        for line_number, line in enumerate(log, 1):
            fields = line.split()
            if "MV_Continue" in fields:
                if continue_line is not None and section_samples < 60:
                    raise AssertionError(
                        f"Secret of NIMH: only {section_samples} desync measurements (need at least 60) after "
                        f"MV_Continue at {machine.stdout_path}:{continue_line}"
                    )
                resumes += 1
                continue_line = line_number
                section_samples = 0
                previous = None
                continue
            if continue_line is None or not fields or fields[0] != "desync_valid":
                continue
            try:
                desync = int(fields[3])
            except (IndexError, ValueError) as error:
                raise AssertionError(
                    f"Secret of NIMH: malformed desync row at "
                    f"{machine.stdout_path}:{line_number}: {line.strip()}"
                ) from error

            # Each resume starts a fresh recovery sequence. Equal readings are
            # allowed, with up to 2 units of jitter between readings; the
            # absolute error must never exceed 60.
            magnitude = abs(desync)
            if magnitude > 60:
                raise AssertionError(
                    f"Secret of NIMH: column 4 is {desync}, outside [-60, 60], "
                    f"at {machine.stdout_path}:{line_number} after MV_Continue "
                    f"on line {continue_line}"
                )
            if previous is not None and magnitude > previous[1] + 2:
                raise AssertionError(
                    f"Secret of NIMH: absolute desync increased from {previous[1]} "
                    f"at {machine.stdout_path}:{previous[0]} to {magnitude} "
                    f"at {machine.stdout_path}:{line_number} after MV_Continue "
                    f"on line {continue_line} (maximum allowed increase: 2)"
                )
            previous = (line_number, magnitude)
            section_samples += 1
            checked += 1

    if resumes == 0:
        raise AssertionError(f"Secret of NIMH: no MV_Continue in {machine.stdout_path}")
    if section_samples < 60:
        raise AssertionError(
            f"Secret of NIMH: only {section_samples} desync measurements (need at least 60) after "
            f"MV_Continue at {machine.stdout_path}:{continue_line}"
        )
    print(
        f"Secret of NIMH passed: {resumes} resumes, {checked} desync measurements within ±60 (increase tolerance 2)"
    )


def check_flying_mattes(machine):

    if not machine.images:
        raise AssertionError("Flying Mattes: no video frames available")

    # Normalize the 4x-scaled simulator output to its logical pixel grid and
    # exclude the debug border. Coordinates below refer to the active test area.
    # The approved frame 450 has white bounds (100, 100, 116, 116): this is
    # the test's fixed pivot, rather than the center of the whole video canvas.
    expected_white = (100, 100, 116, 116)
    initial_pose = None
    previous = None
    previous_frame = None
    animation_frames = 0
    identical_frames = 1
    moving_before_pause = False
    pause_started = None
    pause = None
    final_gray = None

    for frame, path in sorted(machine.images.items()):
        with Image.open(path) as image:
            active = (
                image.resize((480, 312), Image.Resampling.NEAREST)
                .convert("L")
                .crop((81, 26, 465, 306))
            )
        white = active.point(lambda value: 255 if value >= 200 else 0)
        bounds = white.getbbox()
        # Permit a single faulty display frame when motion resumes after a
        # detected pause. The pause state is cleared below on this same frame,
        # so the next frame must pass the normal alignment check again.
        resuming_after_pause = (
            pause_started is not None
            and previous is not None
            and ImageChops.difference(active, previous).getbbox() is not None
        )
        if animation_frames == 0:
            # Boot screens precede the animation. Its first white square can
            # be offset, but must still be a solid 16x16 logical-pixel square.
            if (
                bounds is None
                or bounds[2] - bounds[0] != 16
                or bounds[3] - bounds[1] != 16
                or white.histogram()[255] != 256
            ):
                continue
            initial_pose = active
        else:
            if frame != previous_frame + 1:
                raise AssertionError(
                    f"Flying Mattes: missing video frame before {path}"
                )
            # A decoded image can span multiple display frames. Exempt repeats
            # of the first pose as well, but never a later return to its offset.
            if (
                initial_pose is not None
                and ImageChops.difference(active, initial_pose).getbbox() is not None
            ):
                initial_pose = None
            if (
                initial_pose is None
                and not resuming_after_pause
                and (
                    bounds is None
                    or any(abs(a - b) > 1 for a, b in zip(bounds, expected_white))
                    or abs(white.histogram()[255] - 256) > 16
                )
            ):
                raise AssertionError(
                    f"Flying Mattes: white square missing or off-center in {path}; "
                    f"bounds {bounds}, expected {expected_white} (tolerance 1 pixel)"
                )

        animation_frames += 1
        final_gray = active.point(lambda value: 255 if 50 <= value <= 150 else 0)
        if previous is not None:
            if ImageChops.difference(active, previous).getbbox() is None:
                identical_frames += 1
                if identical_frames >= 10 and moving_before_pause:
                    pause_started = frame - identical_frames + 1
            else:
                # Only a freeze followed by resumed motion counts as a pause.
                if pause_started is not None:
                    pause = (pause_started, previous_frame)
                moving_before_pause = True
                identical_frames = 1
                pause_started = None
        previous = active
        previous_frame = frame

    if animation_frames < 12:
        raise AssertionError(
            f"Flying Mattes: insufficient square animation frames ({animation_frames})"
        )
    if pause is None:
        raise AssertionError(
            "Flying Mattes: no pause of at least 10 frames with motion before and after"
        )

    # In the final orientation, the gray wings form an L above and to the
    # right of the white square. Check the silhouette, not just gray presence.
    expected_gray = Image.new("L", (384, 280))
    expected_gray.paste(255, (100, 84, 132, 100))
    expected_gray.paste(255, (116, 100, 132, 116))
    mismatched = ImageChops.difference(final_gray, expected_gray).histogram()[255]
    if mismatched > 32:
        raise AssertionError(
            f"Flying Mattes: last frame {machine.images[previous_frame]} does not have "
            f"gray wings above/right of the square ({mismatched} mismatched pixels; limit 32)"
        )
    print(
        f"Flying Mattes passed: {animation_frames} animation frames, centered square, "
        f"pause at {pause[0]}–{pause[1]}, final gray wings above/right"
    )


def check_moving_window(machine, fixed_reference):
    """Check the corner markers and exact pixels of either window test.

    Window 1 carries the same image between positions. Window 2 reveals a
    stationary image: remember each exposed pixel at its screen coordinate
    and require every later observation of that coordinate to match exactly.
    """
    name = "Moving Window 2" if fixed_reference else "Moving Window 1"

    # Work on the original pixels: resampling could hide a one-pixel shift.
    # These bounds exclude Vemu's debug border in its 1920x1248 video output.
    viewport = (323, 104, 1859, 1224)
    # Each dot is 4x4 output pixels (one logical pixel). The outer rectangle
    # includes the dots; removing four pixels per edge leaves 264x176 content.
    marker_size = (272, 184)
    dot_mask = Image.new("L", marker_size)
    for x in (0, 268):
        for y in (0, 180):
            dot_mask.paste(255, (x, y, x + 4, y + 4))

    reference = None
    reference_frame = None
    # Keep a small in-memory atlas, not copies of all the video frames. Once a
    # pixel is known it is never updated, so errors cannot cause reference drift.
    atlas = Image.new("RGB", (1536, 1120))
    # A separate validity mask distinguishes unseen pixels from actual black
    # reference pixels: 0 means unseen, 255 means already recorded.
    known = Image.new("L", atlas.size)
    checked = 0
    marker_frames = 0
    positions = set()
    previous_frame = None
    for frame, path in sorted(machine.images.items()):
        with Image.open(path) as image:
            if image.size != (1920, 1248):
                raise AssertionError(
                    f"{name}: unsupported frame size {image.size} in {path}"
                )
            active = image.convert("RGB").crop(viewport)
        # Taking the minimum of R/G/B selects near-white dots without mistaking
        # a saturated red, green, or blue area of the picture for a marker.
        red, green, blue = active.split()
        white = ImageChops.darker(ImageChops.darker(red, green), blue).point(
            lambda value: 255 if value >= 240 else 0
        )
        bounds = white.getbbox()
        # Dot positions may move together, but their size and relative spacing
        # must stay exact. Four 4x4 dots account for all 64 white pixels.
        markers_valid = (
            bounds is not None
            and (bounds[2] - bounds[0], bounds[3] - bounds[1]) == marker_size
            and white.histogram()[255] == 64
            and ImageChops.difference(white.crop(bounds), dot_mask).getbbox() is None
        )
        if marker_frames == 0 and not markers_valid:
            # Ignore boot screens, but never tolerate disappearing or displaced
            # markers once the test's four-dot rectangle has appeared.
            continue
        if not markers_valid:
            raise AssertionError(
                f"{name}: missing or unstable corner dots in {path}; bounds {bounds}"
            )
        if previous_frame is not None and frame != previous_frame + 1:
            raise AssertionError(f"{name}: missing video frame before {path}")
        previous_frame = frame
        marker_frames += 1
        # The test background is black. Any non-black pixels beyond the dot
        # rectangle indicate a stray image fragment or incorrect clipping.
        if active.getbbox() != bounds:
            raise AssertionError(f"{name}: pixels outside the marked window in {path}")
        left, top, right, bottom = bounds
        content_box = (left + 4, top + 4, right - 4, bottom - 4)
        content = active.crop(content_box)
        if reference is None:
            # The dots appear before the decoded image becomes available.
            if content.getbbox() is None:
                continue
            reference = content.copy()
            reference_frame = frame

        if fixed_reference:
            # Window 2: use absolute viewport coordinates. Never search for an
            # alignment offset: doing so would conceal the displacement we test.
            known_region = known.crop(content_box)
            if checked and known_region.getbbox() is None:
                raise AssertionError(
                    f"{name}: no reference overlap to verify content in {path}"
                )
            difference = ImageChops.difference(content, atlas.crop(content_box))
            # Newly exposed areas have no reference yet. Compare only pixels
            # seen before; overlapping windows must agree on every RGB value.
            difference = Image.composite(
                difference, Image.new("RGB", content.size), known_region
            )
        else:
            # Window 1: cropping relative to the dots removes the intended
            # movement. The entire remaining picture must match the first one.
            difference = ImageChops.difference(content, reference)
        # An all-zero difference has no bounding box. There is deliberately no
        # pixel or color tolerance: even a single changed channel must fail.
        changed = difference.getbbox()
        if changed is not None:
            raise AssertionError(
                f"{name}: content changed or displaced in {path}; "
                f"difference bounds {changed} relative to the window; "
                f"reference begins at frame {reference_frame}"
            )
        if fixed_reference:
            # Fill only newly revealed parts; previously verified pixels stay fixed.
            atlas.paste(content, content_box, ImageChops.invert(known_region))
            known.paste(255, content_box)
        checked += 1
        positions.add((left, top))

    # Count decoded content frames, excluding boot and dots-only startup. A
    # frozen image at one position must not pass merely by lasting 400 frames.
    if checked < 400 or len(positions) < 2:
        raise AssertionError(
            f"{name}: insufficient moving image output: {checked} content frames (need at least 400), "
            f"{len(positions)} positions"
        )
    print(
        f"{name} passed: {checked} exact pixel comparisons, {len(positions)} positions, stable corner dots"
    )


if __name__ == "__main__":
    # A direct file launch searches this directory; -m execution supplies the
    # package context. Analysis imports otherwise need no runner dependency.
    if __package__:
        from .machine import Machine
        from .eventscript import *
    else:
        from machine import Machine
        from eventscript import *

    # To test a single job
    machine = Machine()

    machine.stdout_path = Path(
        "/tmp/cdi-sil-logs/job-0-machine-0-zlld7awq/stdout.log"
    ).resolve()
    check_addams_family_resume_from_slow_motion(machine)
