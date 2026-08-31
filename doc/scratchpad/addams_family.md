# Addams Family Disc 2

## Questions about the pointer

How does this application get the button state and the cursor position.
There is no call to SS_PT functionality!

    CPU Read Access 00dfe46a 0043
    CPU Read Access 00dfe46c 1b70
    cdi_bpsys 0007ed42  00df0005 00000059 00000000 00080000 00000010 00000000 0000000a 00000000  0007ffb0 00dfc8b0 00dfe420 00dfc808 00dfcc30 00dfd3e8 00001500 00002bd6 2004
    CPU Read Access 0007ed44 48e7
    CPU Read Access 0007ed2a 4e93
    cdi_bpsys 0007ed2a  00df0005 00000059 00000000 00080000 00000010 00000000 0000000a 00000000  0007ffb0 00dfc8b0 00dfe420 00431b70 00dfcc30 00dfd3e8 00001500 00002bd6 2004
    CPU Write Access 00002bd2 0007
    CPU Write Access 00002bd4 ed2c
    CPU Read Access 00431b70 0c41
    pointer 00431b70  00df0005 00000059 00000000 00080000 00000010 00000000 0000000a 00000000  0007ffb0 00dfc8b0 00dfe420 00431b70 00dfcc30 00dfd3e8 00001500 00002bd2 2004

Somehow `cdi_bpsys` is directly calling functions of the `pointer` module.
The pointer is located at 00dfe46a and goes to 00431b70
It usually does an RTS at `pointer 00431bee`

## Division by Zero problem

Regression notes

Working with 176e9b6403b82f3e62a0379f44110ee49baf92ba
Crashing with 594bae844ef81a836fbeeaee652605899d7cd68f

Original commit message of the fix in main 76ce55a0ae1f5972d45b56189df75bad507fed42

    VMPEG: Fixed image size registers 00E04002 and 00E04004

    Written values were stored but could not be read back

    Concerning "Addams Family" - Disc 2, it crashed when entering the menu.
    This was caused by a "Division by Zero" exception, resetting the machine.
    This was caused by corrupted data, caused by double execution of the instructions
    at 0x0275ed0 (program of the movie player) which causes a zero value at 0xD01D8A.
    This problem already manifests even before the movie starts playback, but the crash itself is only occurring when the value is read.
    This happens only when the movie player menu is opened.

    All of this was caused by the values in mentioned registers being not the written ones but artificial ones when the VMPEG verilog implementation was first conceived.

    0027e0a0  0000000f 00000000 00000000 00000003 0000000f 00000000 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401a
    0027e0a2  0000000f 00000000 00000000 00000003 0000000f 00000000 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0400e
    0027e0a4  0000000f 00000000 00000000 00000003 0000000f 00000000 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0400e
    Exception - Division by zero
    Writing 0/video_ramdump.bin!


    0027e0a0 24 01           move.l     D1,D2
    0027e0a2 66 06           bne.b      LAB_0027e0aa
    0027e0a4 81 fc 00 00     divs.w     #0x0,D0
    0027e0a8 60 6e           bra.b      LAB_0027e118
                            LAB_0027e0aa                                    XREF[1]:     0027e0a2(j)
    0027e0aa 53 81           subq.l     #0x1,D1
    0027e0ac 67 6a           beq.b      LAB_0027e118

zuvor

    002761a0 22 05           move.l     D5,D1

davor

    00276108 2a 2e 9d 8a     move.l     (-0x6276,A6),D5

zuvor?

    00275ed0 2d 44 9d 8a     move.l     D4,(-0x6276,A6)

According to `cat log | grep -e 0276108 -e V_AsyStat -e MV_ | uniq`
there never is a NIS event. That should not be the case!


    V_AsyStat = 2020 hex  8224 dez
    V_AsyStat = 8a0c hex 35340 dez
    FMV Write FMV_DECOFF Y 203e 0000 ?
    FMV Write FMV_DECOFF X 203f 0000 ?
    FMV Write FMV_DECWIN H 203c 0001 ?
    FMV Write FMV_DECWIN W 203d 0000 ?
    Syscall @ 27831a 8d I$GetStt 00000006 00000130 00000001 00000003 00000001 00000020 00004160 00000000  002711d4 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd428 GetStt MV_Create
    Syscall @ 2783e4 8d I$GetStt 00000006 00000131 00000001 00000003 00000001 00000020 00004160 00000000  002711d4 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd428 GetStt MV_Info
    Syscall @ 2784de 8e I$SetStt 00000006 0000010c 00000001 00000000 00000001 00000000 00004160 00000000  002711d4 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Org
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002016 00000001 00000020 00004160 00000000  00273960 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002116 00000001 00000020 00004160 00000000  002738de 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002117 00000001 00000020 00004160 00000000  0027393e 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  00273304 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 27820e 8e I$SetStt 00000006 00000101 00000001 00101010 00000001 00000020 00004160 00000000  00274672 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd428 SetStt MV_BColor
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000000 00002317 00000001 00000020 00004160 00000000  002718c8 00217b52 00d02fa8 0007fde0 00d04158 00d03fc0 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000000 00002317 00000001 00000020 00004160 00000000  0027320e 00217b52 00d01108 0007fde0 00d04158 00d03f88 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 2786e2 8e I$SetStt 00000006 00000111 00000001 00000000 030001e0 00000017 00004160 00000000  00000300 00217b52 00d01108 0007d09a 00d04158 00d03fb0 00d08000 00dfd428 SetStt MV_SelStrm
    Syscall @ 27862c 8e I$SetStt 00000006 0000010f 00000001 00000028 00000001 00000000 00004160 00000000  00000300 00217b52 00d01108 0007d09a 00d04158 00d03f90 00d08000 00dfd428 SetStt MV_Pos
    Syscall @ 2787e2 8e I$SetStt 00000006 00000114 00000001 00000000 030001e0 00000000 00004160 00000000  00000300 00217b52 00d01108 0007d09a 00d04158 00d03f90 00d08000 00dfd428 SetStt MV_Window 768 480
    Syscall @ 278560 8e I$SetStt 00000006 0000010e 00000001 00000000 00000000 00000000 00000007 00000000  00000000 00d014ce 00d01108 0007d09a 00d01bb2 00d03fb0 00d08000 00dfd428 SetStt MV_Play
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 000e hex    14 dez
    Syscall @ 278708 8e I$SetStt 00000006 00000112 00000000 00000003 00000001 00000020 00004160 00000000  0027320e 00062cca 00d02fa8 0007fdf0 00d04158 00d040d8 00d08000 00dfd428 SetStt MV_Show
    FMV Write FMV_DECWIN H 203c 00f0 ?
    FMV Write FMV_DECWIN W 203d 0180 ?
    FMV Write FMV_DECOFF Y 203e 0000 ?
    FMV Write FMV_DECOFF X 203f 0000 ?
    V_AsyStat = 000e hex    14 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  0027320e 00062cca 00d02fa8 0007fe00 00d04158 00d040c4 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 2781c4 8e I$SetStt 00000006 00000100 00000001 00000003 00000001 00000020 00004160 00000000  002731d2 00062cca 00d02fa8 0007fe00 00d04158 00d040c4 00d08000 00dfd428 SetStt MV_Abort
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  002731d2 00062cca 00d02fa8 0007fe10 00d04158 00d040c0 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 2786e2 8e I$SetStt 00000006 00000111 00000001 00000000 030001e0 00000017 00004160 00000000  00000300 00062cca 00d01108 0007d09a 00d04158 00d040c0 00d08000 00dfd428 SetStt MV_SelStrm
    Syscall @ 27862c 8e I$SetStt 00000006 0000010f 00000001 00000028 00000001 00000000 00004160 00000000  00000300 00062cca 00d01108 0007d09a 00d04158 00d040a0 00d08000 00dfd428 SetStt MV_Pos
    Syscall @ 2787e2 8e I$SetStt 00000006 00000114 00000001 00000000 030001e0 00000000 00004160 00000000  00000300 00062cca 00d01108 0007d09a 00d04158 00d040a0 00d08000 00dfd428 SetStt MV_Window 768 480
    Syscall @ 278560 8e I$SetStt 00000006 0000010e 00000001 00000000 00000000 00000000 00000007 00000000  00000000 00d014ce 00d01108 0007d09a 00d01bb2 00d040c0 00d08000 00dfd428 SetStt MV_Play
    FMV Write FMV_DECWIN H 203c 00f0 ?
    FMV Write FMV_DECWIN W 203d 0180 ?
    FMV Write FMV_DECOFF Y 203e 0000 ?
    FMV Write FMV_DECOFF X 203f 0000 ?
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 000e hex    14 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    Syscall @ 278754 8e I$SetStt 00000006 00000113 f5022002 00002317 00000001 00000001 00004160 00000000  002718c8 00062cca 00df39d6 0007fe10 00d04158 00d04008 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278708 8e I$SetStt 00000006 00000112 00000001 00000001 00000001 00000001 00004160 00000000  002718c8 00062cca 00df39d6 0007fe10 00d04158 00d04008 00d08000 00dfd428 SetStt MV_Show
    FMV Write FMV_DECWIN H 203c 00f0 ?
    FMV Write FMV_DECWIN W 203d 0180 ?
    FMV Write FMV_DECOFF Y 203e 0000 ?
    FMV Write FMV_DECOFF X 203f 0000 ?
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 000e hex    14 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 000e hex    14 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 000e hex    14 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    V_AsyStat = 0000 hex     0 dez
    V_AsyStat = 0002 hex     2 dez
    00276108  00000000 0003640f 00000001 00000003 00000001 00000020 00004160 00000000  00271c8c 00062cca 00d02fa8 0007fe40 00d04158 00d04070 00d08000 00d0404c
    V_AsyStat = 0002 hex     2 dez

In working condition on 176e9b6403b82f3e62a0379f44110ee49baf92ba
Just before a check of D1 for 0, resulting into the division by 0

    $ cat log_working | grep 0027e0a0
    0027e0a0  00000003 0000001e 00000000 0000001f f5022006 00000003 00004160 00000000  00d01c82 00062cca 0027320e 00d02fa8 0007fdf0 00d03fec 00d08000 00d03fc4
    0027e0a0  00000004 0000001e 00000000 0000001f f5022002 00000001 00004160 00000000  00d01c82 00062cca 0027320e 00d02fa8 0007fe00 00d03fec 00d08000 00d03fc4
    0027e0a0  00000005 0000001e 00000000 00000003 00000000 000000d8 00004160 00000000  00273840 00062cca 002731d2 00d02fa8 0007fe10 00d03fee 00d08000 00d03fc6
    0027e0a0  00000006 0000001e 00000000 0000001f 00000000 00000000 00000000 00000000  0000016e 00062cca 0027078c 00d02fa8 0007fe20 00d04000 00d08000 00d03fd8
    0027e0a0  00000007 0000001e 00000000 00000003 00000000 00000020 00004160 00000000  0027078c 00062cca 00271c18 00d02fa8 0007fe30 00d0409c 00d08000 00d04074
    0027e0a0  00000008 0000001e 00000000 00000004 ff010004 000001a0 00d02c30 000000ff  00017490 0006acb2 0026f030 00d02fa8 0007fe40 00002bbe 00d08000 00002b96
    0027e0a0  000116fd 00000018 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401a
    0027e0a0  000116fd 00000018 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401e
    0027e0a0  00000b9f 0000003c 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401a
    0027e0a0  000116fd 000005a0 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401e
    0027e0a0  00000031 0000003c 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401a
    0027e0a0  000116fd 00015180 00000000 00000003 000116fd 00000018 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00dfd430
    0027e0a0  00000031 0000000a 00000000 00000003 00000031 00000018 00004160 00000000  00276a4c 00062cca 00d04036 00d0402a 00d04158 00d0401e 00d08000 00d04002
    0027e0a0  00000031 0000000a 00000000 00000003 00000031 00000018 00004160 00000000  00276a4c 00062cca 00d04037 00d0402a 00d04158 00d0401e 00d08000 00d03ffe
    0027e0a0  00000023 0000000a 00000000 00000003 00000023 00000018 00004160 00000000  00276a4c 00062cca 00d04039 00d0402a 00d04158 00d0401e 00d08000 00d04002
    0027e0a0  00000023 0000000a 00000000 00000003 00000023 00000018 00004160 00000000  00276a4c 00062cca 00d0403a 00d0402a 00d04158 00d0401e 00d08000 00d03ffe
    0027e0a0  00000009 0000001e 00000000 00070100 ff010100 0000002a 0005a64a 00000008  0006a980 0006acb2 0026aeba 00d02fa8 0007fe50 00002bbe 00d08000 00002b96

    $ cat log_broken | grep 0027e0a0
    0027e0a0  00000003 0000001e 00000000 0000001f f5022006 00000003 00004160 00000000  00d01c82 00062cca 0027320e 00d02fa8 0007fdf0 00d03fec 00d08000 00d03fc4
    0027e0a0  00000004 0000001e 00000000 0000001f f5022002 00000001 00004160 00000000  00d01c82 00062cca 0027320e 00d02fa8 0007fe00 00d03fec 00d08000 00d03fc4
    0027e0a0  00000005 0000001e 00000000 00000003 00000000 000000d8 00004160 00000000  00273840 00062cca 002731d2 00d02fa8 0007fe10 00d03fee 00d08000 00d03fc6
    0027e0a0  00000006 0000001e 00000000 0000001f 00000000 00000000 00000000 00000000  0000016e 00062cca 0027078c 00d02fa8 0007fe20 00d04000 00d08000 00d03fd8
    0027e0a0  00000007 0000001e 00000000 00000003 00000000 00000020 00004160 00000000  0027078c 00062cca 00271c18 00d02fa8 0007fe30 00d0409c 00d08000 00d04074
    0027e0a0  00000018 00000018 00000000 0000001f 00000000 000000d8 00004160 00000000  00dfa3a0 00062cca 00df39fe 0007fe30 00d04158 00d04044 00d08000 00d04028
    0027e0a0  00000008 0000001e 00000000 00000004 ff010004 000001a0 00d02c30 000000ff  00017490 0006acb2 0026f030 00d02fa8 0007fe40 00002bbe 00d08000 00002b96
    0027e0a0  0000000f 00000000 00000000 00000003 0000000f 00000000 00004160 00000000  00271c8c 00062cca 00d04036 00d0402a 00d04158 00d04070 00d08000 00d0401a

In the working state, 00275ed0 is never executed.

What was changed in 594bae844ef81a836fbeeaee652605899d7cd68f?

    FMV: Fixed timing of frame events and parameters

    - Decoupled SEQ event from GOP event.
    Now behaves like real VMPEG hardware
    - Fixes Lost Ride gameplay after vehicle charge intro
    - Fixes timing accuracy of temp ref and time code
    Measurable with mv_status()

Experimental rollback? Yes. SEQ GOP will not affect. Addams Family always has a SEQ with a GOP on Disc 2
Timing of tempref? Since the crash occurs when opening the playback controls, it has to...


## Playback control hangup

Addams Family Disc 2 can be broken by repeatedly pausing and resuming the movie.
At some point the playback controls will freeze, the mouse cursor will disappear,
but the movie will continue to play for a while until the system crashes.

Sometimes, the PBC graphics are replaced with rainbow pixels.

Can be replicated with simulation by pressing B1 every 5 frames.

When the issue occurs, DC_WrLCT is called very often and doesn't stop.
Can be made visible rather well with this

    cat log | grep -e png -e DC_WrLCT > log2

    cat log | grep -e png  -e DC_WrLCT -e "Syscall @ 27" -e 'Syscall @ 26' -e 'F$Send' > log3


    Written video_514.png
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007ff80 00d04158 00d04030 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 135 134
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007ff90 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1636 296
    Written video_515.png
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007ffa0 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 895 21
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fdd0 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1656 59
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fde0 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 252 142
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fdf0 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 523 189
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe00 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 657 293
    Written video_516.png
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe10 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 403 18
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe20 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1595 55
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe30 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1008 122
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe40 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 303 187
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe50 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1741 293
    Written video_517.png
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe60 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1601 18
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe70 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 267 100
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe80 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1471 173
    Syscall @ 27cf80 8e I$SetStt 00000003 00000056 00000008 00000002 000001de 00000005 00000001 00000002  00d0078c 000680ca 00d02fa8 0007fe90 00d04158 00d04084 00d08000 00dfd428 SetStt SS_DC DC_WrLCT at video pos 1401 211

Finally some module analysis added

    Found module at 73b60 - 7c448 cdi_video.config
    Found module at 7c448 - 7cdc0 cdi_video.states
    Found module at 7cdc0 - 7d016 cdi_controls.map
    Found module at 7d016 - 7eb1e cdi_seq2.epd
    Found module at 7eb1e - 7fdc2 cdi_bpsys
    Found module at 2625b0 - 27fff4 cdi_video
    Found module at 404600 - 40ae1a kernel
    Found module at 40ae1a - 40f4bc cio
    Found module at 40f4bc - 41006c FONT8X8
    Found module at 41006c - 41094a pipeman
    Found module at 41094a - 411f22 nrf
    Found module at 411f22 - 412a42 ucm
    Found module at 412a42 - 413be0 cdfm
    Found module at 413be0 - 41436e scf
    Found module at 41436e - 4161e4 math
    Found module at 4161e4 - 4162e4 copyright
    Found module at 4162e4 - 416436 init
    Found module at 416436 - 4165d8 sysgo
    Found module at 416650 - 416c8e u68070
    Found module at 416c8e - 416eb4 sgstom
    Found module at 416f3c - 417050 tim070driv
    Found module at 4170c6 - 417172 null
    Found module at 417172 - 4171d8 pipe
    Found module at 4171d8 - 4174de nvdrv
    Found module at 41753c - 42799e video
    Found module at 42799e - 427a20 vid
    Found module at 427a20 - 427aa2 vd2
    Found module at 427aa2 - 427b28 vdk
    Found module at 427b28 - 427bac v12
    Found module at 427bac - 427c30 v96
    Found module at 427c30 - 42809a msuart
    Found module at 42811c - 4284b2 gtuart
    Found module at 4285c2 - 428704 ckeydriv
    Found module at 428788 - 428ea8 pck2driv
    Found module at 428f32 - 429542 kb1driv
    Found module at 4295c8 - 42dcde cdapdriv
    Found module at 42ddee - 42deae csd_220
    Found module at 42deae - 42f418 csdinit
    Found module at 42f418 - 431354 config
    Found module at 431354 - 431a28 kbdrvr
    Found module at 431aa8 - 431de2 pointer
    Found module at 431e62 - 4325b6 sldriv
    Found module at 432638 - 4380b0 sv
    Found module at 4380b0 - 43a086 launcher
    Found module at 43a086 - 43afe2 upslbd11.ai1
    Found module at 43afe2 - 43be9e rhobd10.ai1
    Found module at 43be9e - 43c8ae sigmbc7.ai1
    Found module at 43c8ae - 43d462 upslbd10.ai1
    Found module at 43d462 - 43ebae genevas11.fnt
    Found module at 43ebae - 4437ae audiocd
    Found module at 4437ae - 44806e dsett319
    Found module at 44806e - 44b54e dmem319x
    Found module at 44b54e - 44e0ee dinfo319
    Found module at 44e0ee - 44f11e english
    Found module at 44f11e - 45038e espanol
    Found module at 45038e - 45168e francais
    Found module at 45168e - 45297e deutsch
    Found module at 45297e - 4539ce nederlands
    Found module at 4539ce - 454c8e italiano
    Found module at 454c8e - 45cddc cdgrj
    Found module at 45cddc - 46161c phil
    Found module at 46161c - 4660cc magnavox
    Found module at 4660cc - 47e8c2 play
    Found module at 47e8c2 - 47fff2 dummy
    Found module at 480000 - 4801e6 sysgo
    Found module at 4801e6 - 480276 csd_fmvvm
    Found module at 480276 - 481e82 fmvconf
    Found module at 481e82 - 482d82 vmpeg
    Found module at 482d82 - 4842e4 vcd
    Found module at 4842e4 - 489ce6 fmvll
    Found module at 489ce6 - 48dd66 dspcode
    Found module at 48dd66 - 48fbb8 MoviMan
    Found module at 48fc20 - 491a14 madriv
    Found module at 491a8c - 494c60 fmvdrv
    Found module at 494c60 - 494d3a fmvvolset
    Found module at 494d3a - 4957b6 ramtest4
    Found module at 4957b6 - 49fff6 dummy
    Found module at e40000 - e401e6 sysgo
    Found module at e401e6 - e40276 csd_fmvvm
    Found module at e40276 - e41e82 fmvconf
    Found module at e41e82 - e42d82 vmpeg
    Found module at e42d82 - e442e4 vcd
    Found module at e442e4 - e49ce6 fmvll
    Found module at e49ce6 - e4dd66 dspcode
    Found module at e4dd66 - e4fbb8 MoviMan
    Found module at e4fc20 - e51a14 madriv
    Found module at e51a8c - e54c60 fmvdrv
    Found module at e54c60 - e54d3a fmvvolset
    Found module at e54d3a - e557b6 ramtest4
    Found module at e557b6 - e5fff6 dummy


We could extract all the Signal Senders?

    cat log | grep -e png -e SS_Cont -e 'F$Send' -e 'MV_Cont' > log4


    cat log | grep MV_Tri
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002016 00000001 00000020 00004160 00000000  00273960 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002116 00000001 00000020 00004160 00000000  002738de 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002117 00000001 00000020 00004160 00000000  0027393e 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  00273304 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  002718c8 00217b52 00d02fa8 0007fed0 00d04158 00d04060 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  0027320e 00217b52 00d01108 0007fed0 00d04158 00d04028 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  0027320e 00062cca 00d02fa8 0007fef0 00d04158 00d040c4 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 00000001 00002317 00000001 00000020 00004160 00000000  002731d2 00062cca 00d02fa8 0007ff00 00d04158 00d040c0 00d08000 00dfd428 SetStt MV_Trigger
    Syscall @ 278754 8e I$SetStt 00000006 00000113 f5022002 00002317 00000001 00000001 00004160 00000000  002718c8 00062cca 00df39d6 0007ff00 00d04158 00d04008 00d08000 00dfd428 SetStt MV_Trigger

The signal base for MV is 0x2000 and the events are DER, PIC, GOP, LPD, BUF, NIS

    cat log | grep MA_Trigg
    Syscall @ 278b1c 8e I$SetStt 00000007 00000126 00000001 00002808 00000001 00000020 00004160 00000000  002738ea 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MA_Trigger
    Syscall @ 278b1c 8e I$SetStt 00000007 00000126 00000001 00002809 00000001 00000020 00004160 00000000  002738f6 00000000 00d02fa8 0007fde0 00d04158 00d0407c 00d08000 00dfd428 SetStt MA_Trigger

The signal base for MA is 0x2800 and the events are EOI and UNF. This means that MA events are non cared for in this application.

F$Send uses D1 as signal

Syscall @ 27cf1a 8e I$SetStt 00000003 00000056 00000011 00001800 00000000 000000f6 00004160 00000000  0027233c 000680ca 00212d12 0007ff70 00d04158 00d04028 00d08000 00dfd428 SetStt SS_DC DC_SSig at video pos 1277 269

The signal base for video is 0x1800


What is this?

Syscall @ e53d72 8 F$Send 03000002 0a122006 00002000 00001800 00000000 000000f6 00004160 0000008e  00dfa3a0 00dfbaf0 00dfa7a0 00e04000 00d04158 00d04028 00001500 00dff31c


    split -b 512k 0/video_ramdump.bin addams-part-
    objcopy -I binary -O binary --reverse-bytes=2 addams-part-ab addams-part-ab_swap.rom
    objcopy -I binary -O binary --reverse-bytes=2 addams-part-aa addams-part-aa_swap.rom

Play button at 610
Pause with Pause text at 611

Play button at 648
Pause with Pause text at 649

Play button with play text at 683
Pause button at 684

Where is MV_Pause


Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007fe10 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
Coming from 002784fa
Coming from 0027369a
Coming from 0026a980
Coming from 0027ae60


Signal handler at 0x027e996 and that is actually not broken. It is still called. So it seems the main loop is broken.


cat log | grep -e png -e 027e996 -e DC_WrLCT -e "Syscall @ 27" -e 'Syscall @ 26' -e 'F$Send' > log5
cat log | grep -e png -e 027e996 -e DC_WrLCT -e "Syscall @ 27" -e 'Syscall @ 26' -e 'F$Send' -e "Return from Syscall" > log6

cdi_video 002736ae  00000004 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 000680ca 00d02fa8 0007ffa0 00d04158 00d04094 00d08000 00d04088
cdi_video 002784fa  00000006 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 000680ca 00d02fa8 0007ffa0 00d04158 00d04094 00d08000 00d04084
cdi_video 002784fe  00000006 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 000680ca 00d02fa8 0007ffa0 00d04158 00d04094 00d08000 00d04084
00278500

cdi_video 00278502  00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 000680ca 00d02fa8 0007ffa0 00d04158 00d04094 00d08000 00dfd430

This is the last call to SS_PT
Syscall @ 27cfe2 8e I$SetStt 00000003 00000059 00000003 016801c2 00000168 000001c2 00000000 00000000  00000003 00062cca 0006ac50 0006acb2 00d04158 00d0407c 00d08000 00dfd428 SetStt SS_PT
Function in 0027cfd0, coming from jsr
coming from function pointer in 00d03256 ((-0x4daa,A6)) with parameter from (-0x7d78,A6),D0


Stack is around 00d03f70


00d0416a ?


Another approach...
With the current setup of having also latency with mv_continue(), I see rainbow colors starting from frame 1888 during simulation. It takes a long time to get there. Frames 1641 is reached within 7194s.
This effect of "eating" the RAM is observable very early on.

I've started adding a ramdump on every frame now to investigate this.
Frame 756 is hanging.
Comparing video_ramdump_756.bin with video_ramdump_755.bin, corruption starts to spread at 0x00184a0.
It is a pattern that grows there.

0E84DE010205
3C84DE010205

It is interesting that the address 0x00184a0 is never written before the failure condition.
The first write is at instruction 0x0026dea4
The evil address is 0x0018498.
It is stored inside 0x00d04088. That is a location on the stack.
It is copied there from (long*)0x0d009c4, which is also called (-0x763c,A6)
The address at 0x0d009c4 is incremented by 0xe at 0026de7e.

    cat log | grep -e png -e 0026de7e

Starting from frame 756 this place is executed very often.


To reduce 7.2G of log to log-part-aa

    split -b 2G log log-part-


cat log-part-aa | grep -e png -e 0026de7e
cat log-part-aa | grep -e png -e "CPU Write Access 00d009c4" | less
cat log-part-aa | grep -e png -e "CPU Write Access 00d009c6" | less

That address is written at
    0026dd56 Quite a formula here
    0026de7e Increment by 0xe

    cat log-part-aa | grep -e png -e 0026de7e -e 0026dd56 | less

Even in the error condition, both are executed frequently

When the value is lower than before like 0x00018320 it was written here

    0026eada (-0x7644,A6),(-0x763c,A6) So it is set to a specific value

    CPU Read Access 00d009bc 0001
    CPU Read Access 00d009be 8320
    CPU Write Access 00d009c4 0001
    CPU Write Access 00d009c6 8320

    cat log-part-aa | grep -e png -e 0026eada | less

Starting from frame 705, this is never again executed. Is that the issue?
When is 0026eada called? And is 00d009bc always that value?
It turns out that 00d009bc is never written after frame 314. So it might be
an address of a buffer to reset (-0x763c,A6)

It is part of a function at 0026e8d0

    cat log-part-aa | grep -e png -e "cdi_video 0026e8d0" | less

Starting from frame 705 this function is never again called
Where was it called last?
At 0027ba6a there is a `jsr (A0)`

The value 0026e8d0 is stored at 00212d12

    cdi_video 0027b8b2  00000000 00000000 00000001 00000003 00001800 00000001 00000000 00000000  0026e8d0 00062cca 00212d00 00d00f40 00d00f54 00d0400c 00d08000 00d03fe6 0004
    CPU Read Access 0027b8b4 216f
    CPU Read Access 00d03fe6 0026
    CPU Read Access 00d03fe8 e8d0
    CPU Write Access 00212d12 0026
    CPU Write Access 00212d14 e8d0

    cat log-part-aa | grep -e png -e "cdi_video 0027b8b2" | less

It is called even after frame 706 but much rarer
0027b8b2 is part of FUN_0027b80a

    cat log-part-aa | grep -e png -e "cdi_video 0027b80a" | less

It is called even after frame 706 but much rarer


At 0027e996 there seems to be a signal handler. (Lol, I already knew that)
It calls the function at (-0x5c7a,A6) and performs an F$RTE

The function pointer seems to be set at 027e97a.
That function is never called after frame 314.

The jump of the signal handler goes to 0027ba34

    cat log-part-aa | grep -e png -e "cdi_video 0027e996" | less
    cat log-part-aa | grep -e png -e "cdi_video 0027e996" > logbarf

Signal 00001800 is missing after frame 757.

    cat log-part-aa | grep -e png -e "cdi_video 0027e996" -e DC_SSig > logbarf

DC_SSig is missing after frame 756. But why? When is it called?

    cat log-part-aa | grep -e DC_SSig

It is always the same

    Syscall @ 27cf1a 8e I$SetStt 00000003 00000056 00000011 00001800 00000000 00000029 00000003 00000000  0026e8d0 00062cca 00d00f38 00d00f40 00d00f54 00d04030 00d08000 00dfd428 SetStt SS_DC DC_SSig at video pos 959 184

Done in function 027cf06 which does not only DC_SSig it seems.
It is subtrap 0x11, which could indicate that this is the right place where the function call is build in assembly

    0027cf50 48 e7 7e 00     movem.l    {  D6 D5 D4 D3 D2 D1},-(SP)
    0027cf54 74 11           moveq      #0x11,D2
    0027cf56 60 b8           bra.b      LAB_0027cf10

At least once `0026eb78 4e ae b1 de     jsr        (-0x4e22,A6)` is used to call 0027cf50

    CPU Read Access 00d031e0 0027
    CPU Read Access 00d031e2 cf50

The value of 00d031e2 is never changed after the initial setup.

    cat log-part-aa | grep -e png -e "cdi_video 0026eb78" -e DC_SSig  > logbarf

There are actually multiple places where it is called. This is another.

                            FUN_002685f6
    002685f6 4e 55 00 00     link.w     A5,0x0
    002685fa 48 e7 c0 00     movem.l    {  D1 D0},-(SP)
    002685fe 2f 17           move.l     (SP)=>local_c,-(SP)
    00268600 22 2e 86 94     move.l     (-0x796c,A6),D1
    00268604 20 2e 82 26     move.l     (-0x7dda,A6),D0
    00268608 4e ae b1 de     jsr        (-0x4e22,A6)


I don't get it. Is it maybe related to MV_Info? MV_Status is never called

Syscall @ 2783e4 8d I$GetStt 00000006 00000131 00000001 00000003 00000001 00000020 00004160 00000000  002711d4 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd428 GetStt MV_Info
Return from Syscall 0000  --- 002783e8  00000006 00000131 00000001 00000003 00000001 00000020 00004160 00000000  00dfa3a0 00000000 00d02fa8 0007fde0 00d04158 00d04098 00d08000 00dfd430 0000

00dfa3a0 is the video descriptor. It has a length of 53 bytes when only counting the actual data
So the descriptor goes from 00dfa3a0 to 00DFA3D5

cat log-part-aa | grep -e 00dfa3a -e 00dfa3b -e 00dfa3c -e 00dfa3d -e png | grep -e CPU -e png > logbarf

No idea, back to the callers of (-0x4e22,A6) which should always be 0027cf50, which is DC_SSig

        0026e81c 4e ae b1 de     jsr        (-0x4e22,A6)
        00268608 4e ae b1 de     jsr        (-0x4e22,A6)
        0026eb78 4e ae b1 de     jsr        (-0x4e22,A6)
        002685e4 4e ae b1 de     jsr        (-0x4e22,A6) This is from task context

Are there others?

    cat log-part-aa | grep -e png -e "CPU Read Access 00d031e2" > logbarf

In general it seems that there are pauses of 1800 activation

    cat log-part-aa | grep -e DC_SSig -e png > logbarf

Frames 734 to 739 have no signal 1800 activation using DC_SSig

    cat log-part-aa | grep -e DC_SSig -e png -e MV_ > logbarf
    cat log-part-aa | grep -e DC_SSig -e png -e MV_ -e "cdi_video 0027e996" -e 'F$RTE' > logbarf

Is there a occurence of execution of the signal handler without DC_SSig before the issue appears?

    cat log-part-aa | grep -e DC_SSig -e "cdi_video 0027e996" -e 'F$RTE' | grep -v "Return from S" > logbarf

Actually, yes. This is a call to DC_SSig in the main loop!

    Syscall @ 27cf1a 8e I$SetStt 00000003 00000056 00000011 00001800 00000000 00000020 00004160 00000000  0027233c 00062cca 00d02fa8 0007ff20 00d04158 00d04078 00d08000 00dfd428 SetStt SS_DC DC_SSig at video pos 199 204


    cat log-part-aa | grep -e Syscall -e "cdi_video 0027e996" | grep -v "Return from S" > logbarf

After mv_continue at some point no DC_SSig is created from signal context.
Is 002685ac executed even during failure. Turns out, no.
Is 002684fe - the function containing all this - executed even during failure. Turns out, no.

    002725ca 4e ae b3 9a     jsr        (-0x4c66,A6) -> 002684fe

002725ca is no longer executed during failure.
The function 00272548 is also no longer executed during failure.
Where is it called? From 0027be98

0027be98 is special, because it is inside the main loop of this application !!!
We can't go up the stack from here!

0027be98 is executed frequently but the pointer to call is coming from stack.

    CPU Read Access 00d040e4 0027
    CPU Read Access 00d040e6 2548

    CPU Write Access 00d040e6 ae90
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    CPU Write Access 00d040e6 2548
    CPU Write Access 00d040e6 f030
    CPU Write Access 00d040e6 aeba
    CPU Write Access 00d040e6 ae90
    CPU Write Access 00d040e6 aeba
    CPU Write Access 00d040e6 ae90
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    CPU Write Access 00d040e6 1c3e
    ...Dead...

`CPU Write Access 00d040e6 1c3e` is unusual. It only happens during the freeze.
Where does this damage occur?

    CPU Read Access 0007ff74 0027
    CPU Read Access 0007ff76 1c3e
    CPU Write Access 00d040e4 0027
    CPU Write Access 00d040e6 1c3e

Seems to be parameter D1 of `cdi_video 0027c3ae`

    cat log-part-aa | grep -e "o 0027c3ae" -e MV_Con | uniq

    cdi_video 0027c3ae  ff010004 0026ae90 0000019a 00000004 00000168 0000002a 0005a668 00000008  0006a980 0006acb2 0005a550 00dfdf42 0006ad74 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d0406c 00d08000 00d04048 0004
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00dfd430 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00dfd430 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00dfd430 0004
    Return from Syscall 0004  cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00dfd430 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    ...Dead...

The value 00271c3e comes from here

    00271c74 41 fa ff c8     lea        (-0x38,PC)=>FUN_00271c3e,A0

And only in a specific case

    00271c5c 61 00 eb 1e     bsr.w      FUN_0027077c                                     undefined FUN_0027077c()
    00271c60 4a 80           tst.l      D0
    00271c62 67 0e           beq.b      LAB_00271c72
    00271c64 72 00           moveq      #0x0,D1
    00271c66 41 fa ff b0     lea        (-0x50,PC)=>LAB_00271c18,A0
    00271c6a 20 08           move.l     A0,D0
    00271c6c 61 00 eb 4a     bsr.w      FUN_002707b8                                     undefined FUN_002707b8()
    00271c70 60 10           bra.b      LAB_00271c82
                            LAB_00271c72                                    XREF[1]:     00271c62(j)
    00271c72 42 a7           clr.l      -(SP)=>local_14
    00271c74 41 fa ff c8     lea        (-0x38,PC)=>FUN_00271c3e,A0
    00271c78 22 08           move.l     A0,D1
    00271c7a 70 00           moveq      #0x0,D0
    00271c7c 4e ae b0 d0     jsr        (-0x4f30,A6)
    00271c80 58 8f           addq.l     #0x4,SP

It turns out `cdi_video 00271c74` is only occuring in the failure case.

Tested using

    cat log-part-aa | grep -e "00271c74" -e MV_Con

The function FUN_0027077c seems to calculate D0. If the result is 0, a fail safe is used which seems to freeze the application.

                            **************************************************************
                            *                          FUNCTION                          *
                            **************************************************************
                            undefined FUN_0027077c()
            undefined         D0b:1          <RETURN>
            undefined4        Stack[-0x4]:4  local_4                                 XREF[1]:     00270788(R)  
                            FUN_0027077c                                    XREF[1]:     FUN_00271c3e:00271c5c(c)  
    0027077c 4e 55 00 00     link.w     A5,0x0
    00270780 48 e7 80 00     movem.l    {  D0},-(SP)
    00270784 20 2e a9 d6     move.l     (-0x562a,A6),D0
    00270788 4e 5d           unlk       A5=>local_4
    0027078a 4e 75           rts


    cat log-part-aa | grep -e "o 0027078a" -e MV_Con  | uniq

Bingo

    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027078a  00000001 00000000 00000001 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04070 00d08000 00d04074 0010
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027078a  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04070 00d08000 00d04074 0014
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027078a  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 0007ff70 00d04158 00d040c4 00d08000 00d040c8 0014
    cdi_video 0027078a  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 0007ff80 00d04158 00d040c4 00d08000 00d040c8 0014
    cdi_video 0027078a  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 0007ff90 00d04158 00d040c4 00d08000 00d040c8 0014
    cdi_video 0027078a  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 0007ffa0 00d04158 00d040c4 00d08000 00d040c8 0014

The location is this one

    CPU Read Access 00d029d6 0000
    CPU Read Access 00d029d8 0001

It's interesting. 00d029d8 is constantly toggling between 0001 and 0000.

    cat log-part-aa | grep -e "CPU Write Access 00d029d8" -e MV_Con

    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000003 00000020 00004160 00000000  00271a24 000680ca 00d02fa8 0007fe40 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fdd0 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    CPU Write Access 00d029d8 0001
    CPU Write Access 00d029d8 0000
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue

At some point it stops toggling. So it seems that the last MV_Continue is not the culprit. It is the one before that?

When is it set to 1?

    00270796 inside function 0027078c

It seems to be the only place.

Of course it is a function pointer called at 0027be98

cat log-part-aa | grep -e "cdi_video 0027e996" -e "CPU Write Access 00d029d8" -e Syscall > logbarf

00d029d8 is called (-0x562a,A6) in source code.
It seems to be a flag that is always cleared here, in case it is not 0.

    002707d0 4a ae a9 d6     tst.l      (-0x562a,A6)
    002707d4 67 00 04 58     beq.w      LAB_00270c2e
    002707d8 42 ae a9 d6     clr.l      (-0x562a,A6)

So it is a dance between FUN_0027078c that always sets it and FUN_002707b8 that always clears it when it is set.
Which addresses are relevant?

    00d040e4 is an important function pointer in the main control loop
    We know it is set by the function 0027c3ae

When doing this output

    cat log-part-aa | grep -e "o 0027c3ae" -e MV_ -e "CPU Write Access 00d029d8" > logbarf

The distance between MV syscalls before the failing case is very short

    cdi_video 0027c3ae  00000000 00272548 00000001 00000003 00000000 00000020 00004160 00000000  00272548 00062cca 00272548 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00272548 00000001 00000003 00000000 00000020 00004160 00000000  00272548 00062cca 00272548 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  ff010004 0026ae90 0000019a 00000004 00000168 0000002a 0005a668 00000008  0006a980 0006acb2 0005a550 00dfdf42 0006b04c 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  00000000 00272548 00000001 00000003 00000000 00000020 00004160 00000000  00272548 00062cca 00272548 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    CPU Write Access 00d029d8 0000
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027c3ae  ff010004 0026f030 0000019a 00000004 00000168 0000019a 00d02c30 000000ff  00017490 0006acb2 00d02c26 00dfdf42 0006b068 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  ff010100 0026aeba 00000000 00380100 00000168 0000002a 0005a64a 00000008  0006a980 0006acb2 0005a53c 00dfdf42 0006b084 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  ff010004 0026ae90 0000019a 00080004 00000168 0000002a 0005a64a 00000008  0006a980 0006acb2 0005a532 00dfdf42 0006ad3c 0027c3ae 00d08000 00002bc2 2000
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff40 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    cdi_video 0027c3ae  ff010100 0026aeba 00000000 ffff0100 00000168 0000002a 0005a668 00000008  0006a980 0006acb2 0005a55a 00dfdf42 0006ad58 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  ff010004 0026ae90 0000019a 00000004 00000168 0000002a 0005a668 00000008  0006a980 0006acb2 0005a550 00dfdf42 0006ad74 0027c3ae 00d08000 00002bc2 2000
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d0406c 00d08000 00d04048 0004
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004
    cdi_video 0027c3ae  00000000 00271c3e 00000001 00000003 00000000 00000020 00004160 00000000  00271c3e 00062cca 00271c3e 00000000 00d04158 00d040c0 00d08000 00d0409c 0004

Let's add time using frames to the output

    cat log-part-aa | grep -e "o 0027c3ae" -e MV_ -e "CPU Write Access 00d029d8" -e png > logbarf

The failing case has nothing between frame 721 and 738. Let's add the signal handler and RTE to the mix

    cat log-part-aa | grep -e "o 0027c3ae" -e MV_ -e "CPU Write Access 00d029d8" -e png -e "cdi_video 0027e996" -e 'F$RTE' > logbarf

There is now a lot between 721 and 738. Is the main loop hanging? I guess a hanging loop could also be problematic.
The main loop has 2 loops.

    do {
        do {                                           0027bd84
           [...]
        } while (*(int *)(unaff_A6 + -0x504c) == 0);
        [...]                                          0027be42
    } while( true );

So, is there a starve?

    cat log-part-aa | grep -e "o 0027bd84" -e MV_ > logbarf

The amount of loops through smaller loop is already very small.

    cdi_video 0027bd84  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00272548 00062cca 00d02fa8 0007fef0 00d04158 00d04108 00d08000 00d040e0 0004
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000002 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 0007ff00 00d04158 00d04108 00d08000 00d040e0 0008
    cdi_video 0027bd84  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00272548 00062cca 00d02fa8 0007ff10 00d04158 00d04108 00d08000 00d040e0 0004
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026f030 00062cca 00d02fa8 0007ff20 00d04158 00d04108 00d08000 00d040e0 0008
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026aeba 00062cca 00d02fa8 0007ff30 00d04158 00d04108 00d08000 00d040e0 0008
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff40 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 0007ff40 00d04158 00d04108 00d08000 00d040e0 0008
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026aeba 00062cca 00d02fa8 0007ff50 00d04158 00d04108 00d08000 00d040e0 0008
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027bd84  00000000 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 0007ff60 00d04158 00d04108 00d08000 00d040e0 0008
    cdi_video 0027bd84  00000000 00000000 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 0007ff70 00d04158 00d04108 00d08000 00d040e0 0004

How about the big loop? 

    cat log-part-aa | grep -e "o 0027be42" -e MV_ > logbarf

Actually equal

    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  00272548 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026f030 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026aeba 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff40 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026aeba 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  0026ae90 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000
    cdi_video 0027be42  00000014 ffffffff 00000001 00000003 00000001 00000020 00004160 00000000  00271c3e 00062cca 00d02fa8 00d02fcc 00d04158 00d04108 00d08000 00d040e0 0000

Still, something is off here. The main loop is hanging somewhere. Maybe that is a problem. It couldn't be because before the failure, something similar happens and that turned out fine

    cat log-part-aa | grep -e "o 0027be42" -e MV_ -e "o 0027c3ae" -e "CPU Write Access 00d029d8" > logbarf

In the failing case there is never a `CPU Write Access 00d029d8 0001` after `MV_Continue`
What even is the set condition of this variable
I know it is with the execution of `0027078c` and that is directly done in the main loop at `0027be98` but only if the function pointer at `00d040e4` is set to `0027078c`.
I do know that this function pointer is set by `0027c3ae`

This means a lack of execution of `cdi_video 0027c3ae D1=0027078c` is a problem. It seems to be the only case to result into `CPU Write Access 00d029d8 0001`.
Even before the last `MV_Continue` that is failing, the `MV_Continue` before that also has no `0027078c` executed.

What is the condition?
`cdi_video 0027c33c with D1=0027078c` seems to be relevant
It is executed via function pointer at `cdi_video 0026eb3c`. Is that starved?

    cat log-part-aa | grep -e "o 0026eb3c" -e MV_  > logbarf

    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000003 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007fe30 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0026eb3c  00000000 0027078c 00000000 00000003 00000000 00000000 00000000 00000000  0001833e 00062cca 00000000 00000000 00000000 00d0402c 00d08000 00d04000 0000
    cdi_video 0026eb3c  00000000 0027078c 00000000 00000003 00000000 00000000 00000000 00000000  0000016e 00062cca 00000000 00000000 00000000 00d03ffc 00d08000 00d03fd0 0000
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000003 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff90 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff40 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue

Yes, it is starving. It is not executed before the failing case.
All of this is in FUN_0026e8d0. Is that starving?

    cat log-part-aa | grep -e "o 0026e8d0" -e MV_  > logbarf

    cdi_video 0026e8d0  f5021800 00000000 00000000 00000003 00001800 000000f6 00004160 00000000  0026e8d0 00062cca 00212d12 0006acb2 00d04158 00d04008 00d08000 00d03fec 0008
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000003 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007fe30 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    cdi_video 0026e8d0  f5021800 00000000 00000000 00000003 00001800 000000f6 00004160 00000000  0026e8d0 00062cca 00212d12 00000000 00d04158 00d0404c 00d08000 00d04030 0008
    cdi_video 0026e8d0  f5021800 00000000 00000000 00000003 00001800 000000f6 00004160 00000000  0026e8d0 00062cca 00212d12 0006acb2 00d04158 00d0401c 00d08000 00d04000 0008
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000003 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff90 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff00 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007ff40 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007ff60 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue

Yes, it is also starving.
It is called via function pointer at `cdi_video 0027ba6a` inside FUN_0027ba34. Is that function starving?

    cat log-part-aa | grep -e "o 0027ba34" -e MV_  > logbarf

Totally not, frequent calls. So, a state is wrong.

    undefined4 FUN_0027ba34(void)
    {
        undefined4 uVar1;
        code **ppcVar2;
        int unaff_A6;
        
        ppcVar2 = (code **)FUN_0027bae6();
        if (ppcVar2 != (code **)0x0) {
            if (*(char *)(ppcVar2 + 2) == '\x01') {
                uVar1 = *(undefined4 *)(unaff_A6 + -0x7ff4);
                *(undefined4 *)(unaff_A6 + -0x50ac) = 1;
                (**ppcVar2)();
                *(undefined4 *)(unaff_A6 + -0x50ac) = 0;
                *(undefined4 *)(unaff_A6 + -0x7ff4) = uVar1;
            }
            else {
                FUN_0027c33c(ppcVar2[1]);
            }
        }
        return 0;
    }

    cat log-part-aa | grep -e "o 0027ba50" -e MV_  > logbarf

0027ba50 is very frequently called. This means that the test of `if (*(char *)(ppcVar2 + 2) == '\x01')` is failing. It almost feels like a dynamic function registering system.

    undefined4 * FUN_0027bae6(void)
    {
        ushort in_D0w;
        int iVar1;
        undefined4 *puVar2;
        int unaff_A6;
        
        puVar2 = *(undefined4 **)(unaff_A6 + -0x50a6 + (in_D0w >> 0xb & 0xf) * 4);
        while( true ) {
            if (puVar2 == (undefined4 *)0x0) {
                return (undefined4 *)0x0;
            }
            if ((uint)*(byte *)((int)puVar2 + 6) == (uint)(in_D0w >> 0xb)) break;
            puVar2 = (undefined4 *)*puVar2;
        }
        if ((in_D0w & 0x7ff) < *(ushort *)(puVar2 + 1)) {
            iVar1 = FUN_0027e02a();
            return (undefined4 *)((int)puVar2 + iVar1 + 0x12);
        }
        return puVar2 + 2;
    }

This here might be a sister function

    undefined4 * FUN_0027ba96(void)
    {
        uint in_D0;
        uint uVar1;
        undefined4 *puVar2;
        int unaff_A6;
        
        uVar1 = (in_D0 & 0xffff) >> 0xb;
        puVar2 = *(undefined4 **)(unaff_A6 + -0x50a6 + (uVar1 & 0xf) * 4);
        while( true ) {
            if (puVar2 == (undefined4 *)0x0) {
                return (undefined4 *)0x0;
            }
            if (*(byte *)((int)puVar2 + 6) == uVar1) break;
            puVar2 = (undefined4 *)*puVar2;
        }
        return puVar2;
    }

Is there a relation?

    cat log-part-aa | grep -e "o 0027ba96" -e "o 0027bae6" -e MV_ > logbarf

FUN_0027ba96 is clearly a function that gets the base of a signal. D0 is something like 00001800.
Both are similar in that regard.

Ok it turns out, the global signal handler at 027e996 calls 0027ba34

    undefined4 FUN_0027ba34(void)
    {
        undefined4 uVar1;
        code **ppcVar2;
        int unaff_A6;
        
        ppcVar2 = (code **)FUN_0027bae6();
        if (ppcVar2 != (code **)0x0) {
            if (*(char *)(ppcVar2 + 2) == '\x01') {
                uVar1 = *(undefined4 *)(unaff_A6 + -0x7ff4);
                *(undefined4 *)(unaff_A6 + -0x50ac) = 1;
                (**ppcVar2)();
                *(undefined4 *)(unaff_A6 + -0x50ac) = 0;
                *(undefined4 *)(unaff_A6 + -0x7ff4) = uVar1;
            }
            else {
                FUN_0027c33c(ppcVar2[1]);
            }
        }
        return 0;
    }

So indeed a problem is not here but manifests as one here due to a lack of signals.
It might be possible that 0026e8d0 is one call handler in an event list registered to the 1800 signal, which is the VBlank signal.
So a lack of 0026e8d0 is not a reason for the lack of 1800, it is another effect.

    cat log-part-aa | grep \
        -e "cdi_video 0026e81c" \
        -e "cdi_video 00268608" \
        -e "cdi_video 0026eb78" \
        -e "cdi_video 002685e4" \
        -e "cdi_video 0027c3ae" \
        -e "cdi_video 0027078c" \
        -e "cdi_video 0027be98" \
        -e "cdi_video 0027e996" \
        -e "CPU Write Access 00d029d8 000" \
        -e DC_SSig \
        -e RTE \
        -e MV_ | grep -v "Return from" > logbarf


I still don't get it.
Just for curiosity, 0027c3ae has an error code. Is it ever called?
D0 would be 0x3500 at the end.

    cat log-part-aa | grep \
        -e "cdi_video 0027c41a" \
        -e MV_ | grep -v "Return from" > logbarf
    
Actually not. Even in the failing case 0027c3ae is always returning with 0.


    cat log-part-aa | grep \
        -e "cdi_video 0027e996" \
        -e "CPU Write Access 00d029d8 000" \
        -e MV_ | grep -v "Return from" > logbarf


...
Maybe I should take a break and look at this pattern again.

Syscall @ 2784fe 8e I$SetStt 00000006 0000010d 00000001 00000003 00000003 00000020 00004160 00000000  00271a6e 00062cca 00d02fa8 0007fe30 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
Syscall @ 27cd88 8e I$SetStt 00000008 ffff0033 00000001 00000003 00000003 00000020 00004160 00000000  00d01108 00062cca 00d02fa8 0007fe30 00d04158 00d04094 00d08000 00dfd428 SetStt SS_Pause

Syscall @ 2782ec 8e I$SetStt 00000006 00000105 00000000 00000003 00000002 00000020 00004160 00000000  00271a24 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
Syscall @ 27cd88 8e I$SetStt 00000008 00000037 00000001 00000003 00000002 00000020 00004160 00000000  00d01108 00062cca 00d02fa8 0007fe70 00d04158 00d04098 00d08000 00dfd428 SetStt SS_Cont

I do know that this might be problematic, because output can start early. The reason is yet unknown.


A friend had a sudden idea about a potential wrong ROM.
I've used `2969341396aa61e0143dc2351aaa6ef6  cdi200.rom` for the experiments, the one with the Magnavox Logo with 60 Hz mode.
But that is not what I use in my real CD-i. That would be `ac0d468be366779c9df633be98da250a  cdi220b.rom`.
As it turns out, the problem there also exists.

ChatGPT brambles about 

CPU Read Access 00d02c54 01d6
(-0x53ae,A6),D0


cat log-part-aa | grep "o 0027e996" | grep -v "Return from" | sort > log_barf

cat log-part-aa  | grep -e "eo 00272556" -e MV_

**There are news on this topic**:
The problem can be replicated even on real hardware. It just takes more patience and Python script
which fakes a controller and presses B1 at a rate of 15 Hz.

