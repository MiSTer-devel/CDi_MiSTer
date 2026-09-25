# Other emulators

While a FPGA based solution is the goal of this project, it is helpful to be able to emulate a CD-i in software, running on a PC.
Especially useful for debugging homebrew and when no MiSTer is around.

# cdiemu

https://www.cdiemu.org/

Might be **the** original CD-i emulator. Available since 2005, a native Windows application.
Can be run on Linux using Wine/Proton to some extent, but experiences might vary.
DVC titles can be booted using GMPEG and VMPEG ROM.

* DVC Compatibility is still not 100%
* Base case compatibility is high
* Offers debugging support using a text interface
* Offers tracing of OS9 syscalls and other events
  * Useful for reverse engineering CD-i applications
* Shows OS9 printf() output via UART window
* Reads images from CDI and BIN files
* Currently no support for CHD images
* Currently no support for multi BIN images
* Gamepad buttons cannot be remapped
* The only emulator with support for other CD-i models than Mono I

The application is closed source and therefore cannot be augmented with custom code for analysis.
Mono I emulation is free. Other models need payment.

# MAME

https://github.com/mamedev/mame

Code base is heavily inspired by shared code snippets from cdiemu. Especially the CDIC code.

* Base case compatibility is high
* Fully utilizes the support of the MAME framework
  * Machine can run with 1500% throttle
  * Supports gamepads with configurable button layout
  * Integrated CPU debugger
* DVC Compatibility is still not 100%
* Cross platform for MacOS, Linux and Windows

To compile a CD-i only MAME binary and to reduce compile times, use this:

    make SOURCES=src/mame/philips/cdi.cpp REGENIE=1 -j8

DVC support added with revision `mame0289-1072-gf43983b62ed` on `2026-09-23 05:07`.
According to their sources, the VMPEG implementation is copied from the MiSTer CD-i core.

MAME is open source and can be augmented with custom code for analysis.

# edi_emulator

https://github.com/whatever-industries/edi_emulator/

* Still very new, launched in 2026
* AI accelerated project
* Code base written in Rust, influence from MAME code visible
* Cross platform for MacOS, Linux and Windows

Even so, this emulator is new, it should be checked out.
Compatibility is already very high.

# MiniCDi

https://github.com/CatmanFan/miniCDi

* Still very new, launched in 2026
* Designed to be executed as Homebrew on Wii and 3DS
* Can also be compiled for PC

# CeDImu

https://github.com/Stovent/CeDImu

TODO
