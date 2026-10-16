# Uncover featuring Tatjana

## Display of photos

Graphical problems with the photos. Those are MPEG decoded.
How are these even displayed?

Recorded on cdiemu, which also is not capable of correctly emulating this title. The graphics are broken

This is the last MV_Play

    @00DECBF0(cdi_appl) TRAP[25572] #0 I$SetStt <= d0.w=9 d1.w=MV_Window d2.w=1 d3.l=0 d4.l=$2100178 d5.b=0
    @00DECBF4(cdi_appl) TRAP[25572] #0 I$SetStt => 
    @00DECB62(cdi_appl) TRAP[25573] #0 I$SetStt <= d0.w=9 d1.w=MV_Trigger d3.w=$1BF3 <MV nis buf eos eoi cnp lpd pic der>
    @00DECB66(cdi_appl) TRAP[25573] #0 I$SetStt => 
    @00DEC96E(cdi_appl) TRAP[25574] #0 I$SetStt <= d0.w=9 d1.w=MV_Play d2.w=1 d3.l=0 d4.l=0 d5.l=$7FFFFFFF d6.w=8 d7.l=0 a1=$6781C (a4)=MV_STAT{ ASY_Stat=0 ASY_Sig=$1C00 }
    @00E4D8B2(MoviMan) TRAP[25575] #0 F$FindPD <= a0=$DFF360 d0.w=8
    @00E4D8B6(MoviMan) TRAP[25575] #0 F$FindPD => a1=$DFAE80
    @00E4F840(madriv) WR.W 00D03698 <= 0000 [S] MA_STAT{ ASY_Stat=0 }
    @00E4F846(madriv) WR.W 00D03698 <= 0000 [S] MA_STAT{ ASY_Stat=0 }
    @00DEC972(cdi_appl) TRAP[25574] #0 I$SetStt => 
    @00DEC85A(cdi_appl) TRAP[25576] #0 I$SetStt <= d0.w=9 d1.w=MV_Next d2.b=0 d3.l=0 a1=0
    ...
    @00DF1340(cdi_appl) TRAP[25581] #0 I$SetStt <= d0.w=$B d1.w=SS_Play (a0)=PCB{ PCB_Stat=0 PCB_Sig=$116 PCB_Rec=$7FFFFFF PCB_Chan=$FFFFFFFF PCB_AChan=0 PCB_Video=$D011DA PCB_Audio=$D0125A PCB_Data=$D0129A }

d4 is 0. So, this is from CD.
d5 is the speed value. 0x7FFFFFFF means "Single step mode" according to 8.2.3.3.2 from the green book.

I think I've never tested this actually.

In the end, the stride was to blame. And also the timing of IMG and PIC SZ and RT registers.
IMG always has to come first, so the NIS event is triggered. That was also missing.

## Weird behavior of re-opening the lowest main menu item when moving the cursor away

Also can be reproduced in cdiemu. How are these even played. Everything is in one file

    @00DF42DE(cdi_appl) TRAP[66881] #0 I$Open <= (a0)="VIDEOS/alltabs" d0.b=1

Concerning the playback, it is noticable that it works with CDDA at the same time.
This is not done via Hostplay, but multiple PCLs that are simply played back
using the normal CD playback routine.

The file alltabs contains 66 pictures

               SEQUENCE | GOP
    01         All tabs closed
    02 - 06    1 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    07         All tabs closed (binary identical picture to 01)
    08 - 12    2 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    13         All tabs closed
    14 - 18    3 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    19         All tabs closed
    20 - 24    4 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    25         All tabs closed
    26 - 30    5 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    31         All tabs closed
    32 - 36    6 opens (5 frames)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    37 - 39    1 closes
    40         All tabs closed
    41         Tab 1 is fully open (Why? Not shown on real hardware but on emulators)
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    42 - 44    2 closes
    45 - 46    All tabs closed
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    47 - 49    3 closes
    50 - 51    All tabs closed
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    52 - 54    4 closes
    55 - 56    All tabs closed
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    57 - 59    5 closes
    60 - 61    All tabs closed
               SEQUENCE END | PROGRAM END | SEQUENCE | GOP
    62 - 65    6 closes
    66         All tabs closed (never shown on real VMPEG hardware)
               SEQUENCE END | PROGRAM END 

    6*6 opens + 5*6 closes = 66 total


When observing the video status register 0x0E0405C while the game is running

    1 open

    1  000 01 I
    7  001 11 B
    b  010 11 B
    e  011 10 P
    13 100 11 B

    1 close

    1 00 01 I
    7 01 11 B
    b 10 11 B
    e 11 10 P

Why is one frame missing?
Let's look at the ACK2N pin via a logic analyzer to estimate the number of DMA transfers.

    1 open   19652 bits in 17 packs (number bits is correct)
    1 close  16184 bits in 14 packs (number bits is correct)

This is an indication that nothing is missing. All 14 packs are transferred. Let's look at timing.
The numbers are FMA clock ticks. For now without `mv_abort()`

    VMPEG

    MV b080 6947    EOS
    MV b040 539     EOI
    MV b200 795     NIS
    MV b00e 2866    SEQ GOP PIC 1
    MV b002 1823    PIC 2
    MV b002 1796    PIC 3
    MV b100 1746    BUF
    MV b002 389     PIC 4
    MV b012 1433    LPD PIC 5

    MiSTer

    MV b040 7356    EOI
    MV b200 856     NIS
    MV b080 3635    EOS
    MV b00e 481     SEQ GOP PIC 1
    MV b002 1380    PIC 2
    MV b002 1794    PIC 3
    MV b002 1797    PIC 4
    MV b100 840     BUF
    MV b012 453     LPD PIC 5

It turns out that the game will stop the playback on BUF. But it is more delicate than that. BUF occurs nearly before the next PIC.
This is relevant, because shutting down via `mv_abort()` avoids the next PIC on occurring becuase IER is set to VCUP only.
But here it is important that it still occurs, because it is happening on real hardware as well.
In case of this core, I will go for a hack here. NDAT which leads to BUF is presented synchronous to PIC and about 8 horizontal lines earlier.
The CD-i application of this game is too slow to react on this because the next IRQ of PIC will interrupt earlier before IER is deactivated.

With `mv_abort()` on BUF, it should look like this.

    MV b040 7420
    MV b200 770
    MV b080 3128
    MV b00e 418
    MV b002 1499
    MV b002 1798
    MV b100 1748
    MV b002 484
    MV2 ffff8001 4

The last PIC is missing, as well as the last LPD together with it.
