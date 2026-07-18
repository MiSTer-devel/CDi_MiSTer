# The Compact Disc

A sector is 2352 bytes of user data in size. This is 0x930.
This might explain why FROG.BIN has one sector header every 0x930 byte.

The cue file says:

    FILE FROG.BIN BINARY
    TRACK 01 MODE2/2352
        INDEX 01 00:00:00

Mode 1

Sync Pattern 

Sync Pattern    00 ff ff ff ff ff   ff ff ff ff ff 00
MSF             00 32 18
Mode            01
User Data       2048 bytes
Error Detection Padding to fill up 2336 bytes

Mode 2

Sync Pattern    00 ff ff ff ff ff   ff ff ff ff ff 00
MSF             00 32 18
Mode            02
User Data       2336 bytes

Audio channel mask register


For some reason, the CD-i has a different format.

The user data always starts with two copies of a header of 4 bytes.

SECTOR_FILE
    Single byte to identify a file? As a filter?
SECTOR_CHAN
    Defines channels 0 to 31?
SECTOR_SUBMODE
    SUBMODE_EOF        = 0x80,  Causes reading to stop. CDIC does that automatically.
    SUBMODE_RT         = 0x40,
    SUBMODE_FORM       = 0x20,
    SUBMODE_TRIG       = 0x10,
    SUBMODE_DATA       = 0x08,  Sector must be one of these
    SUBMODE_AUDIO      = 0x04,  Sector must be one of these
    SUBMODE_VIDEO      = 0x02,  Sector must be one of these
    SUBMODE_EOR        = 0x01,
SECTOR_CODING

## Subcode

### Q Channel

* https://bani.anime.net/iec958/q_subcode/project.htm
* https://github.com/carrotIndustries/redbook
* https://problemkaputt.de/psxspx-cdrom-subchannels.htm
* IEC 60908 (Audio recording - Compact disc digital audio system)

### Dumping

    cdrdao read-cd --read-raw --read-subchan rw_raw tocfile
    cat tocfile

This image can be converted to a CHD file

    chdman createcd -i mycd.toc -o mycd.chd

### Example TOC

Extracted using custom software on a CD-i 210/05

#### Audio CD - Richie - Lach Isch, Oda Was?

CUE File from ripping tool

    FILE "Audio-CD-swap.bin" BINARY
    TRACK 01 AUDIO
        INDEX 01 00:00:00
    TRACK 02 AUDIO
        INDEX 00 03:26:36
        INDEX 01 03:26:45
    TRACK 03 AUDIO
        INDEX 00 07:01:39
        INDEX 01 07:01:60
    TRACK 04 AUDIO
        INDEX 00 12:10:32
        INDEX 01 12:10:47

TOC data buffered without missing sectors.
TOC repeats over and over

    0  01 00 02 01 14 11 00 03 28 45 db 2d Track 2 starts at 3:28:45
    1  01 00 02 01 14 12 00 03 28 45 35 ff
    2  01 00 02 01 14 13 00 03 28 45 9f ae
    3  01 00 03 01 14 14 00 07 03 60 cd b2 Track 3 starts at 7:03:60
    4  01 00 03 01 14 15 00 07 03 60 67 e3
    5  01 00 03 01 14 16 00 07 03 60 89 31
    6  01 00 04 01 14 17 00 12 12 47 28 2c Track 4 starts at 12:12:47
    7  01 00 04 01 14 18 00 12 12 47 4d d5
    8  01 00 04 01 14 19 00 12 12 47 e7 84
    9  01 00 a0 01 14 20 00 01 00 00 8d 93 First track is 1
    10  01 00 a0 01 14 21 00 01 00 00 27 c2
    11  01 00 a0 01 14 22 00 01 00 00 c9 10
    12  01 00 a1 01 14 23 00 04 00 00 cf 62 Last track is 4
    13  01 00 a1 01 14 24 00 04 00 00 a8 b6
    14  01 00 a1 01 14 25 00 04 00 00 02 e7
    15  01 00 a2 01 14 26 00 15 37 65 f0 12 Lead out. Total length of Audio
    16  01 00 a2 01 14 27 00 15 37 65 5a 43
    17  01 00 a2 01 14 28 00 15 37 65 3f ba
    18  01 00 01 01 14 29 00 00 02 00 b5 87 Track 1 starts at 00:02:00
    19  01 00 01 01 14 30 00 00 02 00 19 a1
    20  01 00 01 01 14 31 00 00 02 00 b3 f0
    21  01 00 02 01 14 32 00 03 28 45 3d 4b Now the TOC repeats with different timecode
    22  01 00 02 01 14 13 00 03 28 45 97 1a

Another recording without buffering. Missing sectors but shows the end of the Lead-In area
and start of track 1

    01 00 a0 02 17 69 00 01 00 00 22 e5
    01 00 a0 02 17 70 00 01 00 00 8e c3
    01 00 a1 02 17 72 00 04 00 00 66 63
    01 01 00 00 01 68 00 00 00 07 55 2f Lead In has ended. Pregap of 2 seconds seems to have started
    01 01 00 00 01 66 00 00 00 09 7b 49
    01 01 00 00 01 64 00 00 00 11 ac f3 The timecode is backwards and counts down. Track is now 1. Index is 0.

After 2 seconds, the index 1 of track 1 starts

    01 01 00 00 00 13 00 00 01 62 ee c4
    01 01 00 00 00 02 00 00 01 73 42 df
    01 01 01 00 00 00 00 00 02 00 5a 28 Index number has switched to 1. Probably audio data. Timecode 00:00:00. Absolute time 00:02:00
    01 01 01 00 00 01 00 00 02 01 e0 58
    01 01 01 00 00 03 00 00 02 03 84 99
    01 01 01 00 00 05 00 00 02 05 29 da
    01 01 01 00 00 07 00 00 02 07 4d 1b

#### Audio CD - INXS - Listen Like Thieves (USA)

This is burned from a ROM online. This is not my own

    CATALOG 0075678127724
    FILE "INXS - Listen Like Thieves (USA) (Track 01).bin" BINARY
    TRACK 01 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:00:33
    FILE "INXS - Listen Like Thieves (USA) (Track 02).bin" BINARY
    TRACK 02 AUDIO
        INDEX 01 00:00:00
    FILE "INXS - Listen Like Thieves (USA) (Track 03).bin" BINARY
    TRACK 03 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:01:62
    FILE "INXS - Listen Like Thieves (USA) (Track 04).bin" BINARY
    TRACK 04 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:01:72
    FILE "INXS - Listen Like Thieves (USA) (Track 05).bin" BINARY
    TRACK 05 AUDIO
        INDEX 01 00:00:00
    FILE "INXS - Listen Like Thieves (USA) (Track 06).bin" BINARY
    TRACK 06 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:01:13
    FILE "INXS - Listen Like Thieves (USA) (Track 07).bin" BINARY
    TRACK 07 AUDIO
        INDEX 01 00:00:00
    FILE "INXS - Listen Like Thieves (USA) (Track 08).bin" BINARY
    TRACK 08 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:00:63
    FILE "INXS - Listen Like Thieves (USA) (Track 09).bin" BINARY
    TRACK 09 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:00:52
    FILE "INXS - Listen Like Thieves (USA) (Track 10).bin" BINARY
    TRACK 10 AUDIO
        INDEX 00 00:00:00
        INDEX 01 00:00:60
    FILE "INXS - Listen Like Thieves (USA) (Track 11).bin" BINARY
    TRACK 11 AUDIO
        INDEX 01 00:00:00

The TOC after burning. I should not that the CD-i 210/05 has problems
playing the first track. Only on the second try it works.

     0  01 00 a0 98 59 08 00 01 00 00 14 17
     1  01 00 a0 98 59 09 00 01 00 00 be 46
     2  01 00 a1 98 59 10 00 11 00 00 16 d0
     3  01 00 a1 98 59 11 00 11 00 00 bc 81
     4  01 00 a1 98 59 12 00 11 00 00 52 53
     5  01 00 a2 98 59 13 00 37 17 70 e0 62
     6  01 00 a2 98 59 14 00 37 17 70 87 b6
     7  01 00 a2 98 59 15 00 37 17 70 2d e7
     8  01 00 01 98 59 16 00 00 02 33 49 bd
     9  01 00 01 98 59 17 00 00 02 33 e3 ec
    10  01 00 01 98 59 18 00 00 02 33 86 15
    11  01 00 02 98 59 19 00 03 38 25 25 c8
    12  01 00 02 98 59 20 00 03 38 25 81 5a
    13  01 00 02 98 59 21 00 03 38 25 2b 0b
    14  01 00 03 98 59 22 00 07 26 20 2e 13
    15  01 00 03 98 59 23 00 07 26 20 84 42
    16  01 00 03 98 59 24 00 07 26 20 e3 96
    17  01 00 04 98 59 25 00 11 22 20 b3 d8
    18  01 00 04 98 59 26 00 11 22 20 5d 0a
    19  01 00 04 98 59 27 00 11 22 20 f7 5b
    20  01 00 05 98 59 28 00 14 27 35 83 e0
    21  01 00 05 98 59 29 00 14 27 35 29 b1
    22  01 00 05 98 59 30 00 14 27 35 85 97
    23  01 00 06 98 59 31 00 17 13 48 d8 88
    24  01 00 06 98 59 32 00 17 13 48 36 5a
    25  01 00 06 98 59 33 00 17 13 48 9c 0b
    26  01 00 07 98 59 34 00 20 03 03 06 e5
    27  01 00 07 98 59 35 00 20 03 03 ac b4
    28  01 00 07 98 59 36 00 20 03 03 42 66
    29  01 00 08 98 59 37 00 23 14 23 d6 23
    30  01 00 08 98 59 38 00 23 14 23 b3 da
    31  01 00 08 98 59 39 00 23 14 23 19 8b
    32  01 00 09 98 59 40 00 25 41 60 d0 ef
    33  01 00 09 98 59 41 00 25 41 60 7a be
    34  01 00 09 98 59 42 00 25 41 60 94 6c
    35  01 00 10 98 59 43 00 30 40 20 89 e6
    36  01 00 10 98 59 44 00 30 40 20 ee 32
    37  01 00 10 98 59 45 00 30 40 20 44 63
    38  01 00 11 98 59 46 00 33 45 63 33 60
    39  01 00 11 98 59 47 00 33 45 63 99 31
    40  01 00 11 98 59 48 00 33 45 63 fc c8

When playing from 00:02:00 on a real CD-i, it is interesting that the first 2 sectors are missing
in the subchannel Q data. Nonetheless, the rest is as expected.
Index 0 is counting down as it should.

     0  ff01 ff01 ff00 ff00 ff00 ff30 ff00 ff00 ff02 ff03 ff21 ff76 ffff 5800 d7fe 1d7d3  CRC OK
     1  ff01 ff01 ff00 ff00 ff00 ff29 ff00 ff00 ff02 ff04 fffd ffb7 ffff 5801 dffe 02fb  CRC OK
     2  ff01 ff01 ff00 ff00 ff00 ff28 ff00 ff00 ff02 ff05 ff47 ffc7 ffff 5800 dffe 02dd  CRC OK
     3  ff01 ff01 ff00 ff00 ff00 ff27 ff00 ff00 ff02 ff06 ff12 ff5d ffff 5801 dffe 02fb  CRC OK
     4  ff01 ff01 ff00 ff00 ff00 ff26 ff00 ff00 ff02 ff07 ffa8 ff2d ffff 5800 dffe 02fd  CRC OK
     5  ff01 ff01 ff00 ff00 ff00 ff25 ff00 ff00 ff02 ff08 ffb7 ff10 ffff 5801 dffe 02de  CRC OK
     6  ff01 ff01 ff00 ff00 ff00 ff24 ff00 ff00 ff02 ff09 ff0d ff60 ffff 5800 dffe 02fd  CRC OK
     7  ff01 ff01 ff00 ff00 ff00 ff23 ff00 ff00 ff02 ff10 ffe9 ffac ffff 5801 dffe 02fc  CRC OK
     8  ff01 ff01 ff00 ff00 ff00 ff22 ff00 ff00 ff02 ff11 ff53 ffdc ffff 5800 dffe 02dd  CRC OK
     9  ff01 ff01 ff00 ff00 ff00 ff21 ff00 ff00 ff02 ff12 ff8d ff6d ffff 5801 dffe 02fb  CRC OK
    10  ff01 ff01 ff00 ff00 ff00 ff20 ff00 ff00 ff02 ff13 ff37 ff1d ffff 5800 dffe 02f9  CRC OK
    11  ff01 ff01 ff00 ff00 ff00 ff19 ff00 ff00 ff02 ff14 ffe3 ff68 ffff 5801 dffe 02df  CRC OK
    12  ff01 ff01 ff00 ff00 ff00 ff18 ff00 ff00 ff02 ff15 ff59 ff18 ffff 5800 dffe 02f9  CRC OK
    13  ff01 ff01 ff00 ff00 ff00 ff17 ff00 ff00 ff02 ff16 ff0c ff82 ffff 5801 dffe 02fd  CRC OK
    14  ff01 ff01 ff00 ff00 ff00 ff16 ff00 ff00 ff02 ff17 ffb6 fff2 ffff 5800 dffe 02df  CRC OK
    15  ff01 ff01 ff00 ff00 ff00 ff15 ff00 ff00 ff02 ff18 ffa9 ffcf ffff 5801 dffe 02fc  CRC OK
    16  ff01 ff01 ff00 ff00 ff00 ff14 ff00 ff00 ff02 ff19 ff13 ffbf ffff 5800 dffe 02fa  CRC OK
    17  ff01 ff01 ff00 ff00 ff00 ff13 ff00 ff00 ff02 ff20 ffd3 ff11 ffff 5801 dffe 02df  CRC OK
    18  ff01 ff01 ff00 ff00 ff00 ff12 ff00 ff00 ff02 ff21 ff69 ff61 ffff 5800 dffe 02fa  CRC OK
    
What does the end of the disc look like?

    33  ff01 ff11 ff01 ff03 ff31 ff67 ff00 ff37 ff17 ff55 ff73 ff93 ffff 4801 dffe 02f0  CRC OK
    34  ff01 ff11 ff01 ff03 ff31 ff68 ff00 ff37 ff17 ff56 ff26 ff09 ffff 4800 dffe 02ec  CRC OK
    35  ff01 ff11 ff01 ff03 ff31 ff69 ff00 ff37 ff17 ff57 ff9c ff79 ffff 4801 dffe 02ed  CRC OK
    36  ff01 ff11 ff01 ff03 ff31 ff70 ff00 ff37 ff17 ff58 ffc1 ffb0 ffff 4800 dffe 02f2  CRC OK
    37  ff01 ff11 ff01 ff03 ff31 ff71 ff00 ff37 ff17 ff59 ff7b ffc0 ffff 4801 dffe 02ec  CRC OK
    38  ff01 ff11 ff01 ff03 ff31 ff72 ff00 ff37 ff17 ff60 ff32 ff68 ffff 4800 dffe 02ec  CRC OK
    39  ff01 ff11 ff01 ff03 ff31 ff73 ff00 ff37 ff17 ff61 ff88 ff18 ffff 4801 dffe 02f1  CRC OK
    40  ff01 ff11 ff01 ff03 ff31 ff74 ff00 ff37 ff17 ff62 ffdf ffaf ffff 4800 dffe 02eb  CRC OK
    41  ff01 ff11 ff01 ff03 ff32 ff00 ff00 ff37 ff17 ff63 ff95 ffee ffff 4801 dffe 02ec  CRC OK
    42  ff02 ff00 ff75 ff67 ff81 ff27 ff72 ff40 ff00 ff64 ff13 ffeb ffff 4800 dffe 02f0  CRC OK
    43  ff01 ff11 ff01 ff03 ff32 ff02 ff00 ff37 ff17 ff65 ffb1 ffab ffff 4801 dffe 02eb  CRC OK
    44  ff01 ff11 ff01 ff03 ff32 ff03 ff00 ff37 ff17 ff66 ff2b ff99 ffff 4800 dffe 02ed  CRC OK
    45  ff03 ff00 ff00 ff00 ff00 ff00 ff00 ff00 ff00 ff67 ff52 ff71 ffff 4801 dffe 02ef  CRC OK
    46  ff01 ff11 ff01 ff03 ff32 ff05 ff00 ff37 ff17 ff68 ff07 ffd2 ffff 5800 dffe 02eb  CRC OK
    47  ff01 ff11 ff01 ff03 ff32 ff06 ff00 ff37 ff17 ff69 fff9 ff21 ffff 5801 dffe 02ee  CRC OK   Last sector of last track
    48  ff01 ffaa ff01 ff00 ff00 ff00 ff00 ff37 ff17 ff70 ff84 fff9 ffff 5800 dffe 02ee  CRC OK
    49  ff02 ff00 ff75 ff67 ff81 ff27 ff72 ff40 ff00 ff71 ff51 ff7f ffff 5801 dffe 02e9  CRC OK
    50  ff01 ffaa ff01 ff00 ff00 ff02 ff00 ff37 ff17 ff72 ffe0 ff38 ffff 5800 dffe 02ee  CRC OK
    51  ff01 ffaa ff01 ff00 ff00 ff03 ff00 ff37 ff17 ff73 ff5a ff48 ffff 5801 dffe 02ef  CRC OK
    52  ff01 ffaa ff01 ff00 ff00 ff04 ff00 ff37 ff17 ff74 ff4d ff7b ffff 5800 dffe 02ea  CRC OK
    53  ff01 ffaa ff01 ff00 ff00 ff05 ff00 ff37 ff18 ff00 ffc9 ff07 ffff 5801 dffe 02ef  CRC OK
    54  ff01 ffaa ff01 ff00 ff00 ff06 ff00 ff37 ff18 ff01 ff37 fff4 ffff 5800 dffe 02ef  CRC OK
    55  ff01 ffaa ff01 ff00 ff00 ff07 ff00 ff37 ff18 ff02 ffad ffc6 ffff 5801 dffe 02ea  CRC OK
    56  ff01 ffaa ff01 ff00 ff00 ff08 ff00 ff37 ff18 ff03 ffd8 ff1e ffff 5800 dffe 02ef  CRC OK
    57  ff01 ffaa ff01 ff00 ff00 ff09 ff00 ff37 ff18 ff04 ff02 ffa8 ffff 5801 dffe 02ee  CRC OK
    58  ff01 ffaa ff01 ff00 ff00 ff10 ff00 ff37 ff18 ff05 ffbe ffaf ffff 5800 dffe 02eb  CRC OK

Just garbage but data is still delivered

### Play CDDA

Recording of "Play CDDA" command.
Extracted using custom software on a CD-i 210/05.

    01 01 01 01 14 56 00 01 16 56 e4 6f
    01 01 01 01 14 58 00 01 16 58 ca 09
    01 01 01 01 14 59 00 01 16 59 70 79
    01 01 01 01 14 70 00 01 16 70 64 7a
    01 01 01 01 14 72 00 01 16 72 01 3b
    01 01 01 01 14 73 00 01 16 73 bb 4b
    01 01 01 01 15 00 00 01 17 00 70 7a
    01 01 01 01 15 01 00 01 17 01 ca 0a

It turns out that every sector get's an IRQ. From the source code
of MAME it seemed to only cause an IRQ every sector with Frame=0.
This seems to be not the case on a real machine.
Thinking about this, it might also make sense concerning CD+G
will have visual data on every sector.
