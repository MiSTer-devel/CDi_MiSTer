verilator --top-module emu  \
     --trace --trace-fst --trace-structs --assert \
     -O2 -CFLAGS "-O2 -march=native" \
     --cc --exe --build \
    --build-jobs 8 -LDFLAGS "-lpng" sim_top.cpp -I../rtl \
    ../rtl/*.sv ../CDi.sv ../rtl/*.v \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv  ../rtl/mpeg/fmv/*.sv  \
    tg68kdotc_verilog_wrapper.v ur6805.v
