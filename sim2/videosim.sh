mkdir -p videosim

set -e

# Prepare something that is not affecting video playback
vasmm68k_mot -Fbin -m68000 testroms/idle.asm -o idle.rom
xxd -p -c2 idle.rom cdi200.mem

verilator --top-module emu  \
     --trace --trace-fst --trace-structs --cc --assert --exe --build   \
    --build-jobs 8 videosim_top.cpp -I../rtl  \
    ../rtl/*.sv ../CDi.sv ../rtl/*.v  \
    -I../rtl/mpeg -I../rtl/mpeg/fma ../rtl/mpeg/*.v ../rtl/mpeg/*.sv \
    ../rtl/mpeg/fma/*.sv  ../rtl/mpeg/fmv/*.sv  \
    tg68kdotc_verilog_wrapper.v ur6805.v \
    /usr/lib/x86_64-linux-gnu/libpng.so && ./obj_dir/Vemu $*

