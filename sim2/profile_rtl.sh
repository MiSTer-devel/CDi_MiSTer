#!/usr/bin/env bash
#
# Profile generated Verilator C++ and translate the samples back to RTL blocks.
# This deliberately uses a separate --Mdir, so obj_dir/Vemu is never replaced.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

usage() {
    cat <<'EOF'
Usage: ./profile_rtl.sh [seconds] [machine] [simulator options]

Build an instrumented simulator, run it for a bounded interval, then print an
RTL-aware gprof report.  The default is a 20 second sample of machine 6.

Examples:
  ./profile_rtl.sh
  ./profile_rtl.sh 30 6
  ./profile_rtl.sh 20 6 --events stimulus/fmvtest.event

The selected CD image and ROM are the same ones used by sim_top.sh; prepare
them before profiling.  PROFILE_DIR may select where build and report files
are kept.  Without it, a new /tmp/scc68070-profile.* directory is created.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

sample_seconds="${1:-20}"
machine="${2:-6}"
if (($# >= 1)); then shift; fi
if (($# >= 1)); then shift; fi
sim_args=("$machine" "$@")

if ! [[ "$sample_seconds" =~ ^[1-9][0-9]*$ ]] || ((sample_seconds > 60)); then
    echo "seconds must be an integer from 1 to 60" >&2
    exit 2
fi
if ! [[ "$machine" =~ ^[0-9]+$ ]]; then
    echo "machine must be a non-negative integer" >&2
    exit 2
fi

for required_tool in verilator gprof verilator_profcfunc; do
    if ! command -v "$required_tool" >/dev/null; then
        echo "Required tool not found: $required_tool" >&2
        exit 1
    fi
done

if [[ -n "${PROFILE_DIR:-}" ]]; then
    profile_dir="$PROFILE_DIR"
    mkdir -p "$profile_dir"
    rm -f "$profile_dir/gmon.out" "$profile_dir/gprof.txt" "$profile_dir/rtl.txt" "$profile_dir/run.log"
else
    profile_dir="$(mktemp -d /tmp/scc68070-profile.XXXXXX)"
fi

mkdir -p "$machine"

echo "Building RTL-profiled simulator in $profile_dir"
verilator --top-module emu \
    --prof-cfuncs --assert -O2 -CFLAGS "-O2 -march=native" \
    --cc --exe --build --Mdir "$profile_dir" --build-jobs "${PROFILE_JOBS:-8}" \
    -LDFLAGS "-lpng" sim_top.cpp imgwrite.cpp -I../rtl \
    ../rtl/*.sv ../CDi.sv ../rtl/*.v \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv ../rtl/mpeg/fmv/*.sv \
    tg68kdotc_verilog_wrapper.v ur6805.v

sim_pid=""
gmon_prefix="$profile_dir/gmon.$$."
gmon_file=""
stop_simulator() {
    if [[ -n "$sim_pid" ]] && kill -0 "$sim_pid" 2>/dev/null; then
        kill -INT "$sim_pid" 2>/dev/null || true
        wait "$sim_pid" || true
    fi
}
trap stop_simulator EXIT INT TERM

echo "Sampling machine $machine for $sample_seconds seconds"
GMON_OUT_PREFIX="$gmon_prefix" "$profile_dir/Vemu" "${sim_args[@]}" >"$profile_dir/run.log" 2>&1 &
sim_pid=$!
sleep "$sample_seconds"
stop_simulator
sim_pid=""
trap - EXIT INT TERM

gmon_file="$(compgen -G "${gmon_prefix}*" | head -n 1 || true)"
if [[ -z "$gmon_file" || ! -s "$gmon_file" ]]; then
    echo "No gprof data was produced; see $profile_dir/run.log" >&2
    exit 1
fi

gprof "$profile_dir/Vemu" "$gmon_file" >"$profile_dir/gprof.txt"
verilator_profcfunc "$profile_dir/gprof.txt" >"$profile_dir/rtl.txt"

echo
echo "RTL profile: $profile_dir/rtl.txt"
echo "Raw gprof:   $profile_dir/gprof.txt"
echo "Simulator:   $profile_dir/Vemu"
echo
sed -n '1,160p' "$profile_dir/rtl.txt"
