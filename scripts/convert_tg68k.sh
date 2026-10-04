#!/bin/bash

# This script converts the TG68K VHDL code to Verilog usable by Verilator
set -e

cd "$(dirname "$0")/../rtl/tg68k"

ghdl_mcode -a -fsynopsys --std=08 TG68K_Pack.vhd
ghdl_mcode -a -fsynopsys --std=08 TG68K_ALU.vhd
ghdl_mcode -a -fsynopsys --std=08 TG68KdotC_Kernel.vhd
ghdl_mcode -a -fsynopsys --std=08 tg68dotc_verilog_wrapper.vhd
ghdl_mcode synth --out=verilog -fsynopsys --std=08  --latches tg68kdotc_verilog_wrapper > /tmp/tg68kdotc_verilog_wrapper.v

# Prefix some lint tolerance
echo "// verilator lint_off INITIALDLY
// verilator lint_off COMBDLY
// verilator lint_off CASEINCOMPLETE
// verilator lint_off UNSIGNED
// verilator lint_off LATCH
"  > ../../sim2/tg68kdotc_verilog_wrapper.v

cat /tmp/tg68kdotc_verilog_wrapper.v >> ../../sim2/tg68kdotc_verilog_wrapper.v
rm /tmp/tg68kdotc_verilog_wrapper.v

