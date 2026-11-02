# MPEG Decoder Firwmare

This folder contains the firmware that drives the actual MPEG decoding inside the VMPEG replication.
Since not much is known about the actual hardware, it is substituted with a hybrid approach of software and hardware.
This project uses a modified port of the MPEG1 decoding library [pl_mpeg](https://github.com/phoboslab/pl_mpeg), augmented with
FPGA based accelerators.
It is compiled for a RISC-V target via GCC to be executed on the [VexiiRiscv](https://github.com/SpinalHDL/VexiiRiscv) soft core.

For MPEG1 video decoding, the pl_mpeg library is manually partitioned for running on multiple asymmetric cores.
One VexiiRiscv is clocked at about 80 MHz to decode the MPEG bitstream. It creates commands for image manipulation
and inserts them into a FIFO to grab by 2 identical worker cores, also running at 80 MHz.

For MP2 audio decoding, a single VexiiRiscv at CD-i system frequency of 30 MHz is sufficient.

To ensure identical results among developers, here the version information of the GNU toolchain:

    Using built-in specs.
    COLLECT_GCC=/opt/riscv/bin/riscv32-unknown-elf-gcc
    COLLECT_LTO_WRAPPER=/opt/riscv/libexec/gcc/riscv32-unknown-elf/15.1.0/lto-wrapper
    Target: riscv32-unknown-elf
    Configured with: ./configure --target=riscv32-unknown-elf --prefix=/opt/riscv --disable-shared --disable-threads --enable-languages=c,c++ --with-pkgversion=g1b306039a --with-system-zlib --enable-tls --with-newlib --with-sysroot=/opt/riscv/riscv32-unknown-elf --with-native-system-header-dir=/include --disable-libmudflap --disable-libssp --disable-libquadmath --disable-libgomp --disable-nls --disable-tm-clone-registry --src=.././gcc --disable-multilib --with-abi=ilp32 --with-arch=rv32im --with-tune=rocket --with-isa-spec=20191213 'CFLAGS_FOR_TARGET=-Os    -mcmodel=medlow' 'CXXFLAGS_FOR_TARGET=-Os    -mcmodel=medlow'
    Thread model: single
    Supported LTO compression algorithms: zlib zstd
    gcc version 15.1.0 (g1b306039a) 

