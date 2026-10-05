# Secret of NimH

Simulation shows that log0 with

    images/nimh.bin ec9d1d4243df627315ff9006a17d5fc6

has an issue with desynchronisation during pause, while log1 with

    images/nimh_alt.bin 2a74467d0c8026c637e09c0b3951a91f

doesn't. But what is the difference?
A glimpse at log0. There is no Pause command. And there is a long collection of data until SS_Pause is called.

    $ cat log0 | grep -e MV_ -e SS -e bmp> barf

    Written video_1032.bmp
    Syscall @ 27907e 8e I$SetStt 00000006 7fff0102 00000010 00000000 00000000 7fffffff 00006010 00000000  000001c2 00000000 00d06002 00d05ff4 00d06006 00d05f6c 00d08000 00dfd428 SetStt MV_ChSpeed
    Syscall @ 27954a 8d I$GetStt 00000006 00d00132 00000010 00000003 00000000 00000022 00006010 00000000  00d05f24 00000000 00d06002 00d05ff4 00d06006 00d05f5c 00d08000 00dfd428 GetStt MV_Status
    ...
    Written video_1062.bmp
    Syscall @ 279de2 8e I$SetStt 0000000c 00000033 00000000 00000003 00000000 00000022 00006010 00000000  0026d42a 00000000 00d06002 00d05ff4 00d06006 00d05efa 00d08000 00dfd428 SetStt SS_Pause
    ...
    Written video_1081.bmp
    Syscall @ 27907e 8e I$SetStt 00000006 00000102 00000010 00000000 00000000 00000000 00006010 00000000  000001c2 00000000 00d06002 00d05ff4 00d06006 00d05f70 00d08000 00dfd428 SetStt MV_ChSpeed
    Syscall @ 279de2 8e I$SetStt 0000000c ffff0037 00000010 00000003 00000000 00000022 00006010 00000000  000001c2 00000000 00d06002 00d05ff4 00d06006 00d05f70 00d08000 00dfd428 SetStt SS_Cont

Instead it switches via MV_ChSpeed to single step and back to normal.
This is very different to what I've seen before.

The other disc on the other hand uses the already known approach with MV_Pause and a directly following SS_Pause.

    $ cat log1 | grep -e MV_ -e SS -e bmp > barf

    Syscall @ 278504 8e I$SetStt 00000006 0000010d 00000001 00000003 00000001 00000020 00004160 00000000  0027189a 00062f7a 00d02fac 0007feb0 00d04158 00d04094 00d08000 00dfd428 SetStt MV_Pause
    Written video_344.bmp
    Syscall @ 27cd8e 8e I$SetStt 0000000b ffff0033 00000001 00000003 00000001 00000020 00004160 00000000  00d0118c 00062f7a 00d02fac 0007feb0 00d04158 00d04094 00d08000 00dfd428 SetStt SS_Pause

    Syscall @ 2782f2 8e I$SetStt 00000006 00000105 00000000 00000003 00000001 00000020 00004160 00000000  00271850 00062f7a 00d02fac 0007fed0 00d04158 00d04098 00d08000 00dfd428 SetStt MV_Continue
    Syscall @ 27cd8e 8e I$SetStt 0000000b 00000037 00000001 00000003 00000001 00000020 00004160 00000000  00d0118c 00062f7a 00d02fac 0007fed0 00d04158 00d04098 00d08000 00dfd428 SetStt SS_Cont



    cat log6 | grep -e "FMV Write SYSCMD Register 2060 0022" -e "FMV Write SYSCMD Register 2060 0020" -e "FMV PACK"
    cat log6 | grep -e "FMV Write SYSCMD Register 2060" -e "FMV PACK"

