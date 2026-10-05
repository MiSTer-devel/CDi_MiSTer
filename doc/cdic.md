# CDIC

## CD-i Fan Documentation

Coming from https://github.com/cdifan/cdichips/blob/master/ims66490cdic.md

    0000 - 09FF 	DATA buffer 0  (0xa00 (2560) in size)   Word Adr 0000
    0A00 - 13FF 	DATA buffer 1  (0xa00 (2560) in size)   Word Adr 0500
    1400 - 1DFF     Unknown ?      (0xa00 (2560) in size)   Word Adr 0a00
    1E00 - 27ff     Unknown ?      (0xa00 (2560) in size)   Word Adr 0f00
    2800 - 31FF 	ADPCM buffer 0 (0xa00 (2560) in size)   Word Adr 1400
    3200 - 3BFF 	ADPCM buffer 1 (0xa00 (2560) in size)   Word Adr 1900
    3C00 - 3FFE 	Register area  (0x400 (1024) in size)   Word Adr 1e00

### Registers

Access with word aligned addresses. Long word is fine as it is performed
as word aligned access by the CPU

    3C00 Command Register
    3C02 Time Register High
    3C04 Time Register Low
    3C06 File register
    3C08 Channel mask High (for data and audio)
    3C0A Channel mask Low (for data and audio)
    3C0C Audio channel mask
    3C80 Data select ?

These are maybe the only real registers of the CDIC

    3FF4 Audio buffer (ABUF)
    3FF6 Extra buffer (XBUF)
    3FF8 DMA Control
    3FFA AUDCTL (Audio Control, called Z-Buffer in MAME)
    3FFC Interrupt Vector
    3FFE Data buffer

## MAME behaviour with data

No datasheets available. Will use software emulation of MAME for reconstruction.

First usage in MAME when "Frog Feast" disc is inserted

    [:cdic] ':maincpu' (00429708): cdic_w: Interrupt Vector Register = 2480 & ffff
    [:cdic] ':maincpu' (0042976E): cdic_w: Z-Buffer Register Write: 0000 & ffff
    [:cdic] ':maincpu' (00429774): cdic_w: Command Register = 0024 & ffff
    [:cdic] ':maincpu' (00429780): cdic_w: Data Buffer Register = 8000 & ffff
    [:cdic] ':maincpu' (00429780): cdic_w: Data Buffer high-bit set, beginning command processing
    [:cdic] ':maincpu' (00429780): cdic_w: Reset Mode 2 command
    [:cdic] ':maincpu' (00429784): cdic_r: Data buffer Register = 0000 & ffff
    [:cdic] ':maincpu' (00429788): cdic_r: X-Buffer Register = 0000 & ffff
    [:cdic] ':maincpu' (00429788): Clearing CDIC interrupt line

But this is very early on. Nothing is really done here. No CD interaction.

    [:cdic] ':maincpu' (0042AD7A): cdic_r: Data buffer Register = 0000 & ffff
    [:cdic] ':maincpu' (00429AEE): cdic_w: Command Register = 0029 & ffff
    [:cdic] ':maincpu' (00429B00): cdic_w: Time Register (MSW) = 0002 & ffff
    [:cdic] ':maincpu' (00429B00): cdic_w: Time Register (LSW) = 1600 & ffff
    [:cdic] ':maincpu' (00429B1C): cdic_w: Data Buffer Register = c000 & ffff
    [:cdic] ':maincpu' (00429B1C): cdic_w: Data Buffer high-bit set, beginning command processing
    [:cdic] ':maincpu' (00429B20): cdic_r: Data buffer Register = 4000 & ffff
    [:cdic] ':maincpu' (00429B24): cdic_r: X-Buffer Register = 0000 & ffff
    [:cdic] ':maincpu' (00429B24): Clearing CDIC interrupt line
    [:cdic] Sector tick, waiting on spinup

Time passes

    [:cdic] About to process a disc sector
    [:cdic] Disc sector, current LBA: 000000a6, MSF: 00 02 16
    [:cdic] Sector header data: 00 ff ff ff ff ff ff ff ff ff ff 00 00 02 16 02 00 00 09 00 00 00 09 00

IRQ is now set

    [:cdic] ':maincpu' (0042B058): cdic_r: Data buffer Register = 4001 & ffff
    [:cdic] ':maincpu' (0042B068): cdic_r: X-Buffer Register = 8000 & ffff
    [:cdic] ':maincpu' (0042B068): Clearing CDIC interrupt line
    [:cdic] ':maincpu' (0042B0A0): cdic_r: Command Register = 0029 & ffff
    [:cdic] ':maincpu' (00429C42): ram_r: 0a02 : 1602 & ffff
    [:cdic] ':maincpu' (00429C5E): ram_r: 0a0a : 0900 & ffff
    [:cdic] ':maincpu' (0042AA12): cdic_w: DMA Control Register = 8a0c & ffff
    [:cdic] ':maincpu' (0042AA12): Memory address counter: 00efae50
    [:cdic] ':maincpu' (0042AA12): Doing copy, transferring 0800 bytes to main RAM
    [:cdic] ':maincpu' (00429CA8): cdic_w: Data Buffer Register = 0000 & ffff

MAME uses HLE for DMA here.
The lowest bit of the data buffer register seems to indicate the buffer were it is stored.
As the bit is set, the data buffer 1 from 0A00 - 13FF is used.
The sector header seems to match. Endianess must still be swapped though.

    0a00 00 00
    0a02 02 16
    0a04 02 00
    0a06 00 09
    0a08 00 00
    0a0a 00 09
    0a0c 00

## MAME and CDDA

* CDDA sectors are expected to be delivered to the DATA buffers and NOT the ADPCM buffers
* An IRQ is issued only on FRAC 0 (every second)

An example from the Apprentice, playing some CDDA:

    CD Data Sector delivered to a00
    Sector 1b 00 1e delivery ended at 1324. Cause IRQ. Buffer bit set to 1
    [:cdic] ':maincpu' (0042B058): cdic_r: Data buffer Register = 4001 & ffff
    [:cdic] ':maincpu' (0042B068): cdic_r: X-Buffer Register = 8000 & ffff
    [:cdic] ':maincpu' (0042B068): Clearing CDIC interrupt line
    [:cdic] ':maincpu' (0042B0A0): cdic_r: Command Register = 0028 & ffff
    [:cdic] ':maincpu' (0042AAE4): ram_r: 1324 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1324 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1326 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1328 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 132a : 0015 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 132c : 0028 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 132e : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1330 : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1332 : 0015 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1334 : 0028 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1336 : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 1338 : 006d & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 133a : 0000 & ffff
    ...
    CD Data Sector delivered to 0
    Sector 5a ff 80 delivery ended at 0924. Cause IRQ. Buffer bit set to 0
    [:cdic] ':maincpu' (0042B058): cdic_r: Data buffer Register = 4000 & ffff
    [:cdic] ':maincpu' (0042B068): cdic_r: X-Buffer Register = 8000 & ffff
    [:cdic] ':maincpu' (0042B068): Clearing CDIC interrupt line
    [:cdic] ':maincpu' (0042B0A0): cdic_r: Command Register = 0028 & ffff
    [:cdic] ':maincpu' (0042AAE4): ram_r: 0924 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0924 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0926 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0928 : 0001 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 092a : 0015 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 092c : 0029 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 092e : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0930 : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0932 : 0015 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0934 : 0029 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0936 : 0000 & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 0938 : 001b & ffff
    [:cdic] ':maincpu' (00429654): ram_r: 093a : 0091 & ffff


### Access of CDIC RAM by CPU

Not many locations in CDIC memory are actually used by the CPU without DMA

List extracted using

    cat log | grep ram_r | cut -f5 -d" " | sort | uniq

These are checked during operation by the CDIC driver:

    0000 DATA0   Time Code MinSec
    0002 DATA0   Time Code Frac & Mode
    0008 DATA0   File & Channel (second pair)
    000a DATA0   Submode & Coding (second pair)
    0016 DATA0   ???
    0a00 DATA1   Time Code MinSec
    0a02 DATA1   Time Code Frac
    0a08 DATA1   File & Channel (second pair)
    0a0a DATA1   Submode & Coding (second pair)
    0a16 DATA1   ???
    1400 ???     Selftest, not relevant for operation
    1402 ???     Selftest, not relevant for operation
    2808 ADPCM0  File & Channel (second pair)
    280a ADPCM0  Submode & Coding (second pair)
    3208 ADPCM1  File & Channel (second pair)
    320a ADPCM1  Submode & Coding (second pair)

### Commands

When bit 15 in the Data Buffer Register is set, the command is parsed and the bit is reset automatically.
Only then is it transferred into a shadow register and used for CD reading.

Setting command to 0x23 or 0x24 stops reading after the next sector.
Even without setting a bit in data buffer.

The bit 14 in the data buffer register must be set for the CDIC to work. Resetting it
stops the whole process.

    0x23 Reset Mode 1  According to MAME, reads only sector
    0x24 Reset Mode 2  According to MAME, reads only sector
    0x2b Stop CDDA     According to MAME, fully stops CDIC
    0x2e Update
    0x27 Fetch TOC     ?
    0x28 Play CDDA     ?
    0x29 Read Mode 1   Seek to timestamp in Time Register and start reading Mode 1
    0x2a Read Mode 2   Seek to timestamp in Time Register and start reading Mode 2
    0x2c Seek          ? According to Mame, equal to 0x29 ?

### Registers

Data Buffer Register[15] Set bit to transfer command register to shadow command register
Data Buffer Register[2] Related to Audio?
Data Buffer Register[0] Is toggled after reading a sector. Ensures double buffering is used

## Inspirations

https://raw.githubusercontent.com/MiSTer-devel/MegaCD_MiSTer/master/MegaCD.sv

	"S0,CUECHD,Insert Disk;",

https://raw.githubusercontent.com/MiSTer-devel/PSX_MiSTer/main/PSX.sv

    "H7S1,CUECHD,Load CD;",

https://github.com/MiSTer-devel/TurboGrafx16_MiSTer/blob/master/TurboGrafx16.sv

    "S0,CUECHD,Insert CD;",

Mount SD card?

PSX:

   constant RAW_SECTOR_SIZE         : integer := 2352;
   constant SECTOR_SYNC_SIZE        : integer := 12;
   constant RAW_SECTOR_OUTPUT_SIZE  : integer := RAW_SECTOR_SIZE - SECTOR_SYNC_SIZE;
   constant DATA_SECTOR_SIZE        : integer := 2048;
   constant PREGAPSIZE              : integer := 150;

   constant FRAMES_PER_SECOND       : integer := 75;
   constant FRAMES_PER_MINUTE       : integer := 75 * 60;

    seekLBA <= to_integer(setLocMinute) * FRAMES_PER_MINUTE + to_integer(setLocSecond) * FRAMES_PER_SECOND + to_integer(setLocFrame);

                      readLBA <= seekLBA;


               readLBA_buffer    <= readLBA;
                     lastReadSector    <= readLBA_buffer;
    cd_hps_lba       <= std_logic_vector(to_unsigned(lastReadSector, 32));


## Usage by games

* Tetris
    * decode_4bit_xa_unit (Philips logo and ingame)
* Zelda - Wand of Gamelon
    * decode_4bit_xa_unit (Philips logo, ingame and FMV)
* Frog Feast
    * decode_8bit_xa_unit (Menu music)
* The Apprentice
    * decode_4bit_xa_unit (Philips logo)
    * play_cdda_sector (ingame)
* Defender of the Crown
    * decode_8bit_xa_unit (ingame and intro, maybe always?)

 ## XA in PSX core

[rtl/cd_xa.vhd:](https://github.com/MiSTer-devel/PSX_MiSTer/blob/main/rtl/cd_xa.vhd)

   case (RamIn_dataB(5 downto 4)) is
     when "00" => filterPos <=   0; filterNeg <= 0;
     when "01" => filterPos <=  60; filterNeg <= 0;
     when "10" => filterPos <= 115; filterNeg <= -52;
     when "11" => filterPos <=  98; filterNeg <= -55;
     when others => null;
  end case;

Filter in MAME:

	const int16_t cdicdic_device::s_xa_filter_coef[4][2] =
	{
		{ 0x000,  0x000 },
		{ 0x0F0,  0x000 }, 240
		{ 0x1CC, -0x0D0 }, 460   -208
		{ 0x188, -0x0DC }  392   -220
	};

The same, but *4 ! Cool

## Frog Feast

    [:cdic] ':maincpu' (0042A2D6): cdic_w: File Register = 0100 & ffff
    [:cdic] ':maincpu' (0042A2DC): cdic_w: Channel Register (MSW) = 0000 & ffff
    [:cdic] ':maincpu' (0042A2DC): cdic_w: Channel Register (LSW) = 0001 & ffff
    [:cdic] ':maincpu' (0042A2EC): cdic_w: Audio Channel Register = 0001 & ffff
    [:cdic] ':maincpu' (0042A304): cdic_w: Time Register (MSW) = 0035 & ffff
    [:cdic] ':maincpu' (0042A304): cdic_w: Time Register (LSW) = 4400 & ffff


    CDIC CD Data 0500     0 00ff WE:0
    CDIC CD Data 0500     1 ffff WE:0
    CDIC CD Data 0500     2 ffff WE:0
    CDIC CD Data 0500     3 ffff WE:0
    CDIC CD Data 0500     4 ffff WE:0
    CDIC CD Data 0500     5 ff00 WE:0
    CDIC CD Data 0500     6 0035 WE:1 Time Code    Time Code
    CDIC CD Data 0501     7 4402 WE:1 Time Code     Mode 2
    CDIC CD Data 0502     8 0100 WE:1 File           Channel
    CDIC CD Data 0503     9 6411 WE:1 Submode Audio   Coding 8 bps, stereo
    CDIC CD Data 0504    10 0100 WE:1 Repeat Above
    CDIC CD Data 0505    11 6411 WE:1 Repeat Above
    Switching to Audio k8Bps k37Khz kStereo
    CDIC CD Data 1e00    12 0808 WE:1
    CDIC CD Data 1e01    13 0808 WE:1
    CDIC CD Data 1e02    14 0808 WE:1
    CDIC CD Data 1e03    15 0808 WE:1
    CDIC CD Data 1e04    16 0808 WE:1
    CDIC CD Data 1e05    17 0808 WE:1
    CDIC CD Data 1e06    18 0808 WE:1
    CDIC CD Data 1e07    19 0808 WE:1
    CDIC CD Data 1e08    20 00ff WE:1
    CDIC CD Data 1e09    21 0000 WE:1


For Audio,
* High byte of File Register must match file field in header
* check the sub mode. It has to be audio
* Channel byte selects a bit in the mask. For channel 0, the lowest bit must be set.
* The same again for Audio Channel Mask
* Afterwards processing can start

One CD sector is 2352 bytes in size.
One XA Group consists of 128 byte. 18 of them fit in a sector.

There are 28 samples on 8 blocks in 18 groups when it comes to 4 BPS.


## Sector interval

CDDA has sample data on every sector. Even the highest rate for ADPCM
uses an interval of 2 sectors.
XA Mono doubles the interval compared to Stereo
XA 18 KHz doubles the interval compared to 37.8 kHz
XA 4 BPS doubles the the interval compared to 8 BPS

    Interval   BPS      Channels     Rate
    1          CDDA     Stereo       44.1 kHz
    2          8 BPS    Stereo       37.8 kHz
    4          4 BPS    Stereo       37.8 kHz
    8          4 BPS    Mono         37.8 kHz

## Available codes according to the Green Book

Duration of 1 ADPCM buffer:

    N  Sector Interleaving
    b  Bits per Sample
    fs Sampling rate in kHz
    t  Duration of one buffer in ms

                     N   b  fs    Header Coding  t
    CDDA             1   16 44.1       N/A       13.33
    Level A Stereo   2   8  37.8  00010001 0x11  26.67   Abort to 26ms
    Level A Mono     4   8  37.8  00010000 0x10  53.33
    Level B Stereo   4   4  37.8  00000001 0x01  53.33   Abort to 26ms
    Level B Mono     8   4  37.8  00000000 0x00  106.67  
    Level C Stereo   8   4  18.9  00000101 0x05  106.67  Abort to 26ms
    Level C Mono     16  4  18.9  00000100 0x04  213.33  Abort to 26ms

## Experience

### Real CDI 450
The Apprentice. CDDA is Stereo while Audio is Mono?
Zelda Wand of Gamelon. XA BGM is Mono on Left and Right. SFX is Mono on Left and Right.

### Real CD-i 210
Zelda Wand of Gamelon. XA BGM is Mono on Left and Right. SFX is Mono on Left and Right.

### MAME
Zelda Wand of Gamelon. XA BGM is Mono on Left. SFX is Mono on Right.
This feels wrong.


## Tools

    aplay -f cd -c 1 -r 37800 < 1/audio_right.bin
    aplay -f cd -c 1 -r 37800 < 1/audio_left.bin

    aplay -f cd -c 1 -r 18900 < audio_right.bin
    aplay -f cd -c 1 -r 18900 < audio_left.bin

    aplay -f cd -c 1 -r 44100 < 0/audio_left.bin

## Recordings real CD-i

### Zelda - Wand of Gamelon

    *((unsigned short *)0x303C06) = 0x0100; // File
    *((unsigned long *)0x303C08) = 0x0003; // Channel
    *((unsigned short *)0x303C0C) = 0x0001; // Audio Channel
    *((unsigned long *)0x303C02) = 0x48303100; /* Timecode */
    *((unsigned short *)0x303C00) = 0x2a; // Read Mode 2
    *((unsigned short *)0x303FFE) = 0xC000; /* Start! */

       ABUF XBUF DMA  AUDC DBUF
     0  7fff 7fff 3ffe d7fe c800 After Reset
     1  7fff 7fff 3ffe d7fe 4824 Audio Buf 0
     2  7fff 7fff 3ffe d7fe 4800
     3  7fff 7fff 3ffe d7fe 4801
     4  7fff 7fff 3ffe d7fe 4800
     5  7fff 7fff 3ffe d7fe 4801
     6  7fff 7fff 3ffe d7fe 4800
     7  7fff 7fff 3ffe d7fe 4801
     8  7fff 7fff 3ffe d7fe 4800
     9  7fff 7fff 3ffe d7fe 4801
    10  7fff 7fff 3ffe d7fe 4800
    11  7fff 7fff 3ffe d7fe 4801
    12  7fff 7fff 3ffe d7fe 4800
    13  7fff 7fff 3ffe d7fe 4801
    14  7fff 7fff 3ffe d7fe 4800
    15  7fff 7fff 3ffe d7fe 4801
    16  7fff 7fff 3ffe d7fe 4800
    17  7fff 7fff 3ffe d7fe 4825
    18  7fff 7fff 3ffe d7fe 4801
    19  7fff 7fff 3ffe d7fe 4800
    20  7fff 7fff 3ffe d7fe 4801

Again with data in buffers

        Data 0    Data 1    1400  1E00      ADPCM 0   ADPCM 1   DMA  AUDC DBUF
     1  4830 3202 ffc0 ffc0 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4824
     2  4830 3202 4830 3302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     3  4830 3402 4830 3302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     4  4830 3402 4830 3502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     5  4830 3602 4830 3502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     6  4830 3602 4830 3702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     7  4830 3802 4830 3702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     8  4830 3802 4830 3902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     9  4830 4002 4830 3902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    10  4830 4002 4830 4102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    11  4830 4202 4830 4102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    12  4830 4202 4830 4302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    13  4830 4402 4830 4302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    14  4830 4402 4830 4502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    15  4830 4602 4830 4502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    16  4830 4602 4830 4702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    17  4830 4602 4830 4802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4825
    18  4830 4902 4830 4802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    19  4830 4902 4830 5002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    20  4830 5102 4830 5002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    21  4830 5102 4830 5202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    22  4830 5302 4830 5202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    23  4830 5302 4830 5402 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    24  4830 5502 4830 5402 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    25  4830 5502 4830 5602 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    26  4830 5702 4830 5602 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    27  4830 5702 4830 5802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    28  4830 5902 4830 5802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    29  4830 5902 4830 6002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    30  4830 6102 4830 6002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    31  4830 6102 4830 6202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    32  4830 6302 4830 6202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    33  4830 6402 4830 6202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4824
    34  4830 6402 4830 6502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    35  4830 6602 4830 6502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    36  4830 6602 4830 6702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    37  4830 6802 4830 6702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    38  4830 6802 4830 6902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    39  4830 7002 4830 6902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    40  4830 7002 4830 7102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    41  4830 7202 4830 7102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    42  4830 7202 4830 7302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800

With offset of 1 frame

    *((unsigned short *)0x303C06) = 0x0100; // File
    *((unsigned long *)0x303C08) = 0x0003; // Channel
    *((unsigned short *)0x303C0C) = 0x0001; // Audio Channel
    *((unsigned long *)0x303C02) = 0x48303200; /* Timecode */
    *((unsigned short *)0x303C00) = 0x2a; // Read Mode 2
    *((unsigned short *)0x303FFE) = 0xC000; /* Start! */

     1  4830 3202 4830 3302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     2  4830 3402 4830 3302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     3  4830 3402 4830 3502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     4  4830 3602 4830 3502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     5  4830 3602 4830 3702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     6  4830 3802 4830 3702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     7  4830 3802 4830 3902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
     8  4830 4002 4830 3902 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
     9  4830 4002 4830 4102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    10  4830 4202 4830 4102 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    11  4830 4202 4830 4302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    12  4830 4402 4830 4302 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    13  4830 4402 4830 4502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    14  4830 4602 4830 4502 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    15  4830 4602 4830 4702 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    16  4830 4602 4830 4802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4824
    17  4830 4902 4830 4802 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    18  4830 4902 4830 5002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    19  4830 5102 4830 5002 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    20  4830 5102 4830 5202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
    21  4830 5302 4830 5202 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4801
    22  4830 5302 4830 5402 00 00 74f0 e1e2 f861 74e0 d000 f0f0 3ffe d7fe 4800
