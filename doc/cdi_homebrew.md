# Usage for CD-i Homebrew

## File format of your images

This core supports CHD and CUE/BIN disc images.
Avoid usage of CHD during active development, since overwriting a mounted CHD file will result
into a crash of MiSTer Main and a need to power cycle the MiSTer.

CUE/BIN is preferred here, because you are able to
overwrite sectors **while the CD-i is reading track data**. Use this to your
advantage!

I usually build and deploy my images like this in my homebrew projects.

    ./make_image.sh && scp disk/FMVTEST.CUE disk/FMVTEST.BIN root@mister:/media/fat/games/CD-i

Then I press the User button on the MiSTer to force a reset.
If the option `OSD -> Autoplay` is activated, the system shell is skipped and the application is relaunched.

**Warning:** Without a proper remount, the image size is not updated. Keep that in mind when adding assets to the disc!

## Remote launch from dev PC

Based on the example above, it is possible to launch it by remote controlling the MiSTer.

Create the file `/media/fat/fmvtest.mgl` and have this content inside

    ```xml
    <mistergamedescription>
        <rbf>_console/CDi</rbf>
        <file delay="1" type="s" index="0" path="FMVTEST.CUE"/>
    </mistergamedescription>
    ```

Now run this on the MiSTer via SSH

    echo "load_core fmvtest.mgl" > /dev/MiSTer_cmd

It will reload the CD-i core and mount the declared image at the same time.
If the option `OSD -> Autoplay` is activated, the system shell is skipped and the application launches.

## Access to debugging terminal

The back port of a CD-i 210/05 is a serial port. OS9 will use it to provide the output of `printf()` when
it is not being used by a Pointing Device. Ensure `OSD -> Hardware Config -> Ports` is set to `UART Back`.

Log into the Linux shell of your MiSTer and use `microcom` to get the output.

    ssh root@mister
    /root# microcom /dev/ttyS1 -s 115200

This connection is bidirectional. You can also enter characters here or abort execution via `Ctrl+C`

## Bare metal development

Use `OSD -> Debug Options -> Replace Boot ROM` to replace the system ROM with a custom image.
The CD-i will reset after doing so.

## Memory dumps

Memory dumps are tedious, because Linux has no access to SDRAM.
Assemble either `sim2/testroms/dvcramsender.asm` or `sim2/testroms/videoramsender.asm`
via these lines

    ./sim2$ ./produce_test_rom.sh dvcramsender
    ./sim2$ ./produce_test_rom.sh videoramsender

Dumping memory is a destructive process as it requires a machine reset. Prepare a Linux shell:

    ssh root@mister
    /root# microcom /dev/ttyS1 -s 115200 > dump

Use `OSD -> Debug Options -> Replace Boot ROM` and load one of them.
The CD-i will restart with a black screen and the dump file will continue to grow over the next seconds.
Observe the file size via another SSH shell. It should stop at 1048576 byte, making
it ready for download.

If your application is printing to the terminal, this approach might result into unwanted data at the beginning.
Use `sim2/testroms/idle.asm` to halt the main CPU before starting `microcom` and reloading
again a RAM sender file.
