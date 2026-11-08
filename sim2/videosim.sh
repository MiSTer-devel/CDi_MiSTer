set -e

# Usage: ./videosim.sh [crop] [dump-name-glob] [Verilated-model arguments...]
# crop is 0 for the full raster or 1 for cropped output (the default).
CROP="${1:-1}"
case "$CROP" in
    0|1) ;;
    *)
        echo "Usage: $0 [crop] [dump-name-glob] [Verilated-model arguments...]" >&2
        echo "  crop: 0 for full raster, 1 for cropped output" >&2
        exit 2
        ;;
esac
if [ "$#" -gt 0 ]; then
    shift
fi
DUMP_GLOB="${1:-*}"
if [ "$#" -gt 0 ]; then
    shift
fi

# Optional TRACE
debug_flags=()
# The Verilator PCH is also consumed by the small C++ harness objects, which
# Verilator builds with -Os.  Match that setting here so GCC accepts the PCH.
cpp_flags="-Os"
if [[ "${SIM_DEBUG:-0}" == "1" ]]; then
    debug_flags=(--trace --trace-fst --trace-structs --assert)
    # Keep the C++ harness trace support in lockstep with Verilator tracing.
    # This replaces manually defining TRACE in sim_top.cpp.
    cpp_flags+=" -DTRACE"
fi

mkdir -p videosim
rm -f videosim/*.png

verilator --top-module emu -CFLAGS "-DCROP=${CROP} ${cpp_flags}" \
     "${debug_flags[@]}" \
    --cc --exe --build   \
    --build-jobs 8 videosim_top.cpp -I../rtl  \
    ../rtl/*.sv ../CDi.sv ../sys/gamma_corr.sv ../rtl/*.v  \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv  ../rtl/mpeg/fmv/*.sv  \
    tg68kdotc_verilog_wrapper.v ur6805.v \
    /usr/lib/x86_64-linux-gnu/libpng.so && CDI_RAMDUMP_GLOB="${DUMP_GLOB}" CDI_VIDEO_HACKS_FILE=videosim_hacks.txt ./obj_dir/Vemu "$@"
