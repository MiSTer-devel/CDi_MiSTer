# Chaos Control

## Drops in MPEG Audio

Caused by false positives in Frame header detection.
Can be noticed during the introduction scene on the German version.

Problematic in `sonde.rtf` was this 

`B8 00 0A 58 00 07 FF FF FD A2 04 AB 55`

The header is starting with `FF FD`.
But the `FF` before that was wrongly detected.

Fixable by correctly jumping to the next header after the current one.

## Suddenly stopping CDIC audio when pausing frequently

The game makes use of 2 sound maps that are creating very early on during the bootup phase.

    Syscall @ 275d92 8e I$SetStt 00000004 0000003b 00000000 00000005 00000012 0000002e 00007b30 00000000  00dfbb60 00000230 0027180a 00275882 00d07b26 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Syscall @ 275db2 8e I$SetStt 00000004 0000003b 00000000 00000005 00000012 0000002e 00007b30 00000000  00df9d50 00000230 0027180a 00275882 00d07b26 00d07af4 00d08000 00dfd428 SetStt SS_SM

Afterwards those sound maps are used back and forth

    Written video_1497.png
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00000002 00000320 0000002e 0000002a 00000000  00d05f64 00d06490 00d01672 00231a42 00231a44 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1498.png
    Written video_1499.png
    Written video_1500.png
    Written video_1501.png
    Written video_1502.png
    Written video_1503.png
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00000001 00000320 0000002e 00007b30 00000000  00d05f64 00d06490 00000000 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1504.png
    Written video_1505.png
    Written video_1506.png
    Written video_1507.png
    Written video_1508.png
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00000002 00000320 0000002e 00007b30 00000000  00d05f64 00d06490 00000000 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1509.png
    Written video_1510.png
    Written video_1511.png
    Written video_1512.png
    Written video_1513.png
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00800001 00000320 00000000 00000000 00000000  00d05f64 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1514.png
    Written video_1515.png
    Written video_1516.png
    Written video_1517.png
    Written video_1518.png

Suddenly it stops, directly after resuming gameplay. This is the last one.

    Written video_1553.png
    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1554.png
    Written video_1555.png

Going into log, it is weird that CODING 0xff is detected even so we just have started.

    Written video_1553.png
    ...
    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    CDIC Write RAM 1905 0005
    Write CDIC 30320a 0005 1 1 1
    CDIC Read RAM 320a 00ff
    Read CDIC 303ff4 0000 1 1 0
    CDIC Read Audio Buffer Register 1ffa 0000
    CDIC Write RAM 1905 0005
    Write CDIC 30320a 0005 1 1 1
    CDIC Read RAM 320a 0005
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Write CH:0 ADDR:00 DATA:ffff LDS:0 UDS:1
    DMA Write CH:0 ADDR:06 DATA:00df LDS:1 UDS:1
    DMA Write CH:0 ADDR:07 DATA:9d50 LDS:1 UDS:1
    DMA Write CH:0 ADDR:05 DATA:0480 LDS:1 UDS:1
    DMA Write CH:0 ADDR:02 DATA:1212 LDS:1 UDS:0
    DMA Write CH:0 ADDR:03 DATA:8080 LDS:1 UDS:0
    Write CDIC 303ff8 f20c 1 1 1
    CDIC Write DMA Control Register 1ffc f20c
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:1 UDS:0
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Read CH:0 ADDR:06 DATA:00df LDS:1 UDS:1
    DMA Read CH:0 ADDR:07 DATA:a650 LDS:1 UDS:1
    Write CDIC 303ffa 2800 1 1 1
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Start Decoder at 2800
    Reset audio filters
    DETECT_CODING2 ff
    Write SLAVE 02 8383 1 0 1
    DAC Right 0   0
    ...
    Written video_1554.png

Why is 0x3200 selected as buffer?
Before the error occurs, the playback of coding 05 is just aborted. But why?

    cat log |  grep -e png -e SM -e "Audio Control Registe" -e Decoder -e CODING > barf

    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00800001 00000320 00000000 00000000 00000000  00d05f64 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Written video_1514.png
    Written video_1515.png
    Written video_1516.png
    Written video_1517.png
    Written video_1518.png
    Start Decoder at 2800
    DETECT_CODING2 05
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 2800
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Written video_1519.png
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    Written video_1520.png
    Written video_1521.png
    Written video_1522.png
    Written video_1523.png

    cat log |  grep -e png -e SM -e "Audio Control Registe" -e Decoder -e CODING -e Syscall > barf

    Syscall @ 27b28c 8e I$SetStt 00000007 00000123 00000018 0000003b 00000008 0000002e 00007b30 00000000  002310f0 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt MA_Pause
    Return from Syscall 0001  cdi_cc 0027b290  00000007 000000cb 00000018 0000003b 00000008 0000002e 00007b30 00000000  002310f0 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd430 0001
    Syscall @ 277832 8e I$SetStt 00000008 00000033 00000018 0000003b 00000008 0000002e 00007b30 00000000  002310f0 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_Pause
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000

There it is. SS_Pause is breaking audiomap playback

    cat log |  grep -e png -e SM \
        -e "Audio Control Register" \
        -e "CDIC Write Command Register" \
        -e "CDIC Write Data Buffer Register" \
        -e Decoder -e CODING -e Syscall > barf


    Syscall @ 277832 8e I$SetStt 00000008 00000033 00000018 0000003b 00000008 0000002e 00007b30 00000000  002310f0 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_Pause
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Write Command Register 1e00 0024
    CDIC Write Data Buffer Register 1fff c000
    ...
    Syscall @ 277832 8e I$SetStt 00000008 00000037 ffffffc0 0000003b 00000008 00000080 00000028 00000080  00000004 00d064b2 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_Cont
    CDIC Write Command Register 1e00 002a
    CDIC Write Data Buffer Register 1fff c000
    ...
    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Start Decoder at 2800
    DETECT_CODING2 ff

I've measured on real hardware that writing 0 to AUDCTL doesn't stop the playback.
The currently played sector still continues to the end.

Maybe the next audio map is written to 3200 because it is still assumed that playback is going on.
That can be checked by measuring Level C time vs frames.

    cat log |  grep -e png -e SM -e CODING > barf


    DETECT_CODING2 05
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00000002 00000320 00000000 40041320 00000000  00d05f64 00d06490 00000000 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1212.png
    Written video_1213.png
    Written video_1214.png
    Written video_1215.png
    Written video_1216.png
    DETECT_CODING2 05
    Written video_1217.png
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 67800001 00000320 00000000 00000000 00000000  00d05f64 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1218.png
    Written video_1219.png
    Written video_1220.png
    Written video_1221.png
    DETECT_CODING2 05
    Written video_1222.png
    Written video_1223.png
    Written video_1224.png
    Written video_1225.png
    Written video_1226.png
    Written video_1227.png
    DETECT_CODING2 ff
    Written video_1228.png

Just 6 frames...

I've also found this

    Written video_1453.png
    Written video_1454.png
    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    DETECT_CODING2 ff
    DETECT_CODING2 05
    Syscall @ 276754 8e I$SetStt 00000004 0000003b 00000001 00000002 00000320 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    Written video_1455.png
    Written video_1456.png
    Written video_1457.png

In this case, a single sm_out has seemed to have refilled the 2800 buffer

Close inspection

    cat log |  grep -e png -e SM \
        -e "Audio Control Register" \
        -e "CDIC Write Command Register" \
        -e "CDIC Write Data Buffer Register" \
        -e Decoder -e CODING -e Syscall > barf

    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0800
    Start Decoder at 2800
    DETECT_CODING2 ff
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0001
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Start Decoder at 2800
    DETECT_CODING2 05

What is the difference to the failing case?

    Syscall @ 276754 8e I$SetStt 00000004 0080003b ffff0001 00000001 00000000 0000002e 00007b30 00000000  00d05f64 00d01d66 0027675e 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt SS_SM
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    Start Decoder at 2800
    DETECT_CODING2 ff

The path is very different. AUDCTL is never set to 0 before.
It should be noted that this is also happening on the sm_out() afterwards during normal playback.
!!! We have to assume that cdapdriv thinks that playback is still going on. !!!

    cat log |  grep -e png -e SM \
        -e "Audio Control Register" \
        -e "Audio Buffer Register" \
        -e "CDIC Write Command Register" \
        -e "CDIC Write Data Buffer Register" \
        -e Decoder -e CODING -e SS_Cont -e SS_Pause > barf


It seems that my implementation was wrong here.
The audio buffer register should have bit 15 set after playback has been finished, even so
audio control was set to 0.
Also, playback cannot be stopped on real hardware.

## Glitches in video when resuming after pausing the game

The first level is lib.rtf

Some commands for analysis

    ./mpeg1_picture_info.py 4/fmv_m1v_3.bin > a
    ./mpeg1_picture_info.py /home/andre/ChaosControl/lib_onlyvideo.m1v > b

    ./mpeg1_picture_info.py --slices 4/fmv_m1v_3.bin > a
    ./mpeg1_picture_info.py --slices /home/andre/ChaosControl/lib_onlyvideo.m1v > b

What can be noticed is this from this core

    SLICE   @ 0x00085e13  picture=0x00085b3d  vertical_pos=  3  quantiser_scale= 1
    SLICE   @ 0x00085f68  picture=0x00085b3d  vertical_pos=  4  quantiser_scale= 1
    SLICE   @ 0x000860ad  picture=0x00085b3d  vertical_pos=  5  quantiser_scale= 1
    SLICE   @ 0x00086398  picture=0x00085b3d  vertical_pos=  6  quantiser_scale= 1
    SLICE   @ 0x0008670e  picture=0x00085b3d  vertical_pos=  7  quantiser_scale= 1
    SLICE   @ 0x00086864  picture=0x00085b3d  vertical_pos=  4  quantiser_scale= 1 <- again?
    SLICE   @ 0x000869a9  picture=0x00085b3d  vertical_pos=  5  quantiser_scale= 1 <- again?
    SLICE   @ 0x00086c94  picture=0x00085b3d  vertical_pos=  6  quantiser_scale= 1 <- again?
    SLICE   @ 0x0008700a  picture=0x00085b3d  vertical_pos=  7  quantiser_scale= 1 <- again?
    SLICE   @ 0x0008732a  picture=0x00085b3d  vertical_pos= 11  quantiser_scale= 1 <- 9 and 10 are missing
    SLICE   @ 0x0008750d  picture=0x00085b3d  vertical_pos= 12  quantiser_scale= 1
    SLICE   @ 0x000876bc  picture=0x00085b3d  vertical_pos= 13  quantiser_scale= 1
    PICTURE @ 0x000878c7  GOP 00:00:03:17  temporal_ref=   2  type=B

Compared to the original MPEG file

    SLICE   @ 0x000860ad  picture=0x00085b3d  vertical_pos=  5  quantiser_scale= 1
    SLICE   @ 0x00086398  picture=0x00085b3d  vertical_pos=  6  quantiser_scale= 1
    SLICE   @ 0x0008670e  picture=0x00085b3d  vertical_pos=  7  quantiser_scale= 1
    SLICE   @ 0x00086d0a  picture=0x00085b3d  vertical_pos=  9  quantiser_scale= 1 <- 8 is missing but that is ok
    SLICE   @ 0x0008708c  picture=0x00085b3d  vertical_pos= 10  quantiser_scale= 1
    SLICE   @ 0x0008732e  picture=0x00085b3d  vertical_pos= 11  quantiser_scale= 1
    SLICE   @ 0x00087511  picture=0x00085b3d  vertical_pos= 12  quantiser_scale= 1
    SLICE   @ 0x000876c0  picture=0x00085b3d  vertical_pos= 13  quantiser_scale= 1
    PICTURE @ 0x000878cb  GOP 00:00:03:17  temporal_ref=   2  type=B
    SLICE   @ 0x000878d4  picture=0x000878cb  vertical_pos=  1  quantiser_scale= 1
    SLICE   @ 0x00087905  picture=0x000878cb  vertical_pos=  2  quantiser_scale= 1
    SLICE   @ 0x00087944  picture=0x00

This means that the pausing causes a resume on the wrong sector ?
Since the problem can still be reproduced with the current state, analysis
of the instructions executed during the fault might be required.

Replacing `pictures_in_fifo = pictures_in_dts_fifo;` with a permanent `pictures_in_fifo = pictures_in_input_fifo;` is also not helping.
I'm not sure why this only turns up with Chaos Control and no other title.

This is also visible in the demuxer log

    $ cat backup_chaos_control/log_only_gameplay | grep -e MV_ -e PACK > PACK_MV_log
    FMV PACK      181204
    FMV PACK      182404
    FMV PACK      183604
    FMV PACK      184804
    Syscall @ 27adc6 8e I$SetStt 00000006 0000010d 00000018 0000003b 00000008 0000002e 00007b30 00000000  002310f0 00d06490 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt MV_Pause
    FMA PACK      186004
    FMV PACK      187204
    Syscall @ 27abb4 8e I$SetStt 00000006 00000105 00000000 0000003b 00000008 00000080 00000028 00000080  00000004 00d064b2 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt MV_Continue
    FMV PACK      189604
    FMV PACK      189604 <-- Duplicate
    FMV PACK      190804

This gives indication that the problem occurs after the continue syscall.
Now with added SLICE analysis to the bitstream decoder on FPGA side.

    cat log0_2 | grep -e "FMV PACK" -e MV_Co -e "fmvdrv 00e54558" -e PIC4 -e Timecode -e SLICE > barf

    fmvdrv 00e54558  00000908 000003a7 00007531 74807480 00000908 00000914 00000000 0000008e  0022a3f8 00df6d70 00df6b90 00e04000 00dfcc30 00d07af4 00001500 00dff2f4 2400
    SLICE  13
    PIC4   10 2 20506
    SLICE   1
    SLICE   2
    SLICE   3
    FMV PACK      121204
    fmvdrv 00e54558  00000908 000003af 0000765d 0000003b 00000908 00000914 0040817c 0000008e  0022ad0c 00df6d70 00df6b90 00e04000 00dfcc30 00dfd3e8 00001500 00dff2f4 2400
    SLICE   4
    SLICE   5
    SLICE   6
    SLICE   7
    SLICE   9
    Syscall @ 27abb4 8e I$SetStt 00000006 00000105 00000000 0000003b 00000008 00000080 00000028 00000080  00000004 00d064b2 00276eb0 00d0151a 00d0649e 00d07af4 00d08000 00dfd428 SetStt MV_Continue
    FMV PACK      123604
    fmvdrv 00e54558  00000908 0000ffff 000078b5 5c805c80 00000908 00000914 0040817c 0000008e  0022b620 00df6d70 00df6b90 00e04000 00dfcc30 00dfd3e8 00001500 00dff2f4 2400
    SLICE   4  <--- Duplicate starts here
    SLICE   5
    SLICE   6
    SLICE   7
    SLICE   9
    FMV PACK      123604
    fmvdrv 00e54558  00000908 000003cc 000078b5 4a804a80 00000908 00000914 0040817c 0000008e  0022bf34 00df6d70 00df6b90 00e04000 00dfcc30 00dfd3e8 00001500 00dff2f4 2400
    SLICE  12
    SLICE  13
    PIC4    9 3 19602
    SLICE   1
    SLICE   2
    SLICE   3
    SLICE   4

In this case these are all the addresses of PCL buffers. Exactly 16 PCL buffers to feed the FMV

    fmvdrv 00e54558  .. A0 0003ca80 ...
    fmvdrv 00e54558  .. A0 0003d394 ...
    fmvdrv 00e54558  .. A0 0003dca8 ...
    fmvdrv 00e54558  .. A0 0003e5bc ...
    fmvdrv 00e54558  .. A0 0003eed0 ...
    fmvdrv 00e54558  .. A0 0003f7e4 ...
    fmvdrv 00e54558  .. A0 000400f8 ...
    fmvdrv 00e54558  .. A0 00040a0c ...
    fmvdrv 00e54558  .. A0 002291d0 ...
    fmvdrv 00e54558  .. A0 00229ae4 ...
    fmvdrv 00e54558  .. A0 0022a3f8 ...
    fmvdrv 00e54558  .. A0 0022ad0c ...
    fmvdrv 00e54558  .. A0 0022b620 ... This had the same data as 0022ad0c ???
    fmvdrv 00e54558  .. A0 0022bf34 ...
    fmvdrv 00e54558  .. A0 0022c848 ...
    fmvdrv 00e54558  .. A0 0022d15c ...


It turned out to be a bug in the CDIC during CMD24. This will be fixed.

