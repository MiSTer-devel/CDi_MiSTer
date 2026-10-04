#!/usr/bin/env bash
set -euo pipefail

# Optional TRACE
debug_flags=()
cpp_flags="-O2 -march=native"
if [[ "${SIM_DEBUG:-1}" == "1" ]]; then
    debug_flags=(--trace --trace-fst --trace-structs --assert)
    # Keep the C++ harness trace support in lockstep with Verilator tracing.
    # This replaces manually defining TRACE in sim_top.cpp.
    cpp_flags+=" -DTRACE"
fi

verilator --top-module emu \
     "${debug_flags[@]}" \
     -O2 -CFLAGS "$cpp_flags" \
     --cc --exe --build \
    --build-jobs 8 -LDFLAGS "-lpng" sim_top.cpp imgwrite.cpp -I../rtl \
    ../rtl/*.sv ../CDi.sv ../rtl/*.v \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv  ../rtl/mpeg/fmv/*.sv  \
    tg68kdotc_verilog_wrapper.v ur6805.v
