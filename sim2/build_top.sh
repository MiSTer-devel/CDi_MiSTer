#!/usr/bin/env bash
set -euo pipefail

# Optional TRACE
debug_flags=()
# The Verilator PCH is also consumed by the small C++ harness objects, which
# Verilator builds with -Os.  Match that setting here so GCC accepts the PCH.
cpp_flags="-Os"
if [[ "${SIM_DEBUG:-1}" == "1" ]]; then
    debug_flags=(--trace --trace-fst --trace-structs --assert)
    # Keep the C++ harness trace support in lockstep with Verilator tracing.
    # This replaces manually defining TRACE in sim_top.cpp.
    cpp_flags+=" -DTRACE"
fi

CXXFLAGS="${CXXFLAGS:-} -march=native" verilator --top-module emu \
     "${debug_flags[@]}" \
     --savable \
     --compiler-include ../save_serialize.h \
     -O2 -CFLAGS "$cpp_flags" \
     --cc --exe --build \
    --build-jobs 8 -LDFLAGS "-lpng" sim_top.cpp imgwrite.cpp -I../rtl \
    ../rtl/*.sv ../CDi.sv ../rtl/*.v \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv  ../rtl/mpeg/fmv/*.sv  \
    tg68kdotc_verilog_wrapper.v ur6805.v
