# Zelda - The Wand of Gamelon

This is a callback to [Chaos control](chaos_control.md)

Start with `CDi_unstable_260716`, when Chaos Control was fixed, the Zelda Help cutscene is again broken.
The problem might be this here.

    Syscall @ 27f1a0 8e I$SetStt 00000003 0000003b 00000001 00000001 00018620 00000000 00000020 00000004  00d026c2 0006e072 00d04c94 00d02594 00d025aa 00d03830 00d04b7a 00dfd428 SetStt SS_SM
    Syscall @ 42ae26 56 F$Alarm 00df9850 00000000 00000016 00000001 00018620 00dfd3d4 0040817c 008e0080  0042b3c8 00dfca60 00dfe690 00300000 00dfcc30 00dfd3e8 00001500 00dfd338
    Return from Syscall 2000  cdapdriv 0042ae2a  00df9850 00000000 00000016 00000001 00018620 00dfd3d4 0040817c 008e0080  0042b3c8 00dfca60 00dfe690 00300000 00dfcc30 00dfd3e8 00001500 00dfd340 2000
    Write CDIC 303ffa 0000 1 1 1
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    Write SLAVE 02 8282 1 0 1
    Read CDIC 303c0c 0000 1 1 0
    CDIC Read Audio Channel Register 1e06 0000
    Read CDIC 30280a 64ff 1 1 0
    CDIC Read RAM 280a 64ff
    CDIC Write RAM 1405 64ff
    Write CDIC 30280a 64ff 1 1 1
    CDIC Read RAM 280a 64ff
    Write CDIC 303ffa 0800 1 1 1
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0800
    Read CDIC 303ffa 0800 1 1 0
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0800
    Write CDIC 303ffa 0000 1 1 1
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 0000
    Read CDIC 303ffe 0000 1 1 0
    CDIC Read Data Buffer Register 1fff 0000
    Write CDIC 303c0c 8000 1 1 1
    CDIC Write Audio Channel Register 1e06 8000
    Write CDIC 303c00 002e 1 1 1
    CDIC Write Command Register 1e00 002e
    Read CDIC 303ffe 0000 1 1 0
    CDIC Read Data Buffer Register 1fff 0000
    Write CDIC 303ffe 8000 1 1 1
    CDIC Write Data Buffer Register 1fff 8000
    CDIC Command: Update
    DAC Right 0 254
    DAC Left 1 254

SS_SM SM_Out is used to play the audiomap from CPU side. But the currently played sector from CD is still present.
Since we knew from Chaos Control, that playback still continues, there might be a problem here.
Wand of Gamelon clearly wants to end this. It forces AUDCTL to 0, then writes 0xff coding to both buffers and then again starts playback without wanting the IRQs.
This should mean one thing. It wants to abort playback. So I guess, there must be a way of aborting playback after all. But maybe to abort the playback,
it must be forcefully restarted.

The actual audio glitch occurs shortly after here:

    Return from Syscall 2704  kernel 00409ec4  00000000 00002704 00000000 00002c96 00000001 00002000 00000000 00407df2  00002500 00002caa 00001c74 00002500 00002500 00002cd0 00001500 00002c96 2704
    CDIC Write RAM 1405 0005
    Write CDIC 30280a 0005 1 1 1
    CDIC Read RAM 280a 64ff
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Write CH:0 ADDR:00 DATA:ffff LDS:0 UDS:1
    DMA Write CH:0 ADDR:06 DATA:0007 LDS:1 UDS:1
    DMA Write CH:0 ADDR:07 DATA:507a LDS:1 UDS:1
    DMA Write CH:0 ADDR:05 DATA:0480 LDS:1 UDS:1
    DMA Write CH:0 ADDR:02 DATA:1212 LDS:1 UDS:0
    DMA Write CH:0 ADDR:03 DATA:8080 LDS:1 UDS:0
    Write CDIC 303ff8 e80c 1 1 1
    CDIC Write DMA Control Register 1ffc e80c
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:1 UDS:0
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Read CH:0 ADDR:06 DATA:0007 LDS:1 UDS:1
    DMA Read CH:0 ADDR:07 DATA:597a LDS:1 UDS:1
    Write SLAVE 02 8383 1 0 1
    Read CDIC 303ffa 0000 1 1 0
    CDIC Read Z Buffer Register / Audio Control Register 1ffd 0000
    Read CDIC 303ff4 8000 1 1 0
    CDIC Read Audio Buffer Register 1ffa 8000
    Write CDIC 303ffa 2800 1 1 1
    CDIC Write Z Buffer Register / Audio Control Register 1ffd 2800
    CDIC Write RAM 1905 0005
    Write CDIC 30320a 0005 1 1 1
    CDIC Read RAM 320a 6504
    DMA Read CH:0 ADDR:00 DATA:8000 LDS:0 UDS:1
    DMA Write CH:0 ADDR:00 DATA:ffff LDS:0 UDS:1
    DMA Write CH:0 ADDR:06 DATA:0007 LDS:1 UDS:1
    DMA Write CH:0 ADDR:07 DATA:597a LDS:1 UDS:1
    DMA Write CH:0 ADDR:05 DATA:0480 LDS:1 UDS:1
    DMA Write CH:0 ADDR:02 DATA:1212 LDS:1 UDS:0
    DMA Write CH:0 ADDR:03 DATA:8080 LDS:1 UDS:0
    Write CDIC 303ff8 f20c 1 1 1
    CDIC Write DMA Control Register 1ffc f20c
    DAC Right 0   0

First 2800 is written, then directly afterwards the 3200 buffer. This breaks the still played buffer, no matter which one.

