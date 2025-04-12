# Notes

## Building mame for the CD-i

make SOURCES=src/mame/philips/cdi.cpp REGENIE=1 -j8

## Using mame

./mame cdimono1 -log -oslog
./mame cdimono1 -verbose -log -oslog -window &> log

## Swap 16 bit endianness

    objcopy -I binary -O binary --reverse-bytes=2 picture.bin picture2.bin

## Transmit binary

    scp 68ktest.rom root@mister:/media/fat/games/CD-i

## Ripping from CD to single CUE/BIN

In this case, a single bin

    cdrdao read-cd --read-raw --datafile cdimage.bin cdimage.toc

then byte swap and generate cue

    toc2cue -s -C cdimage2.bin cdimage.toc cdimage.cue

## Convert CUE/BIN to CHD

    chdman createcd -i cdimage.cue -o cdimage.chd

## Convert CHD to single CUE/BIN

    chdman extractcd -i cdimage.chd -o cdimage.cue 

## Convert CHD to multi bin CUE/BIN

    chdman extractcd -i cdimage.chd -sb -o cdimage.cue

## Simulation speed

Vcd:
--trace
Written video_00.png after 44.36s
-rw-rw-r-- 1 andre andre 2,5G  9. Sep 13:04 /tmp/waveform.vcd

Fst:
--trace-fst
Written video_00.png after 51.33
-rw-rw-r-- 1 andre andre 49M  9. Sep 13:02 /tmp/waveform.vcd

This means Fst is better as it is much smaller


## Auto save of NvRAM?

Seems to be not desired:
* SD Card wear out?
* Point of time to write is random?
* Unresponsive as it steals cycles from HPS IO?

https://github.com/MiSTer-devel/Main_MiSTer/issues/789
https://github.com/MiSTer-devel/Main_MiSTer/issues/760


  uVar4 = ICLR;
  uVar4 = Reserved_1B;
  DAT_00a8 = ACHR;
  DAT_00a7 = Reserved_1B;
  bVar3 = DAT_00a7 - DAT_00a9;
  bVar6 = (DAT_00a8 - cRAM00aa) - (DAT_00a7 < DAT_00a9);
  if (((((DAT_00a6 & 0x80) != 0) && (DAT_00b8 != '\0')) && (bVar6 < 4)) &&
     ((bVar6 < 3 || (bVar3 < 0xdf)))) {
    if ((bVar6 < 3) || (bVar3 < 0x2b)) {
      if (bVar6 < 3) {
        if (1 < bVar6) {
          if (0xe6 < bVar3) goto LAB_0a49;
          if (0x5f < bVar3) {
            FUN_0a79();
            if ((LAB_009e & 2) != 0) {
              FUN_0a79();
            }
            goto LAB_0a4f;
          }
        }
        if (((bVar6 < 2) && ((bool)(DAT_00a8 - cRAM00aa) != DAT_00a7 < DAT_00a9)) &&
           ((bVar3 < 0xf0 && (0x99 < bVar3)))) {
          FUN_0a79();
          goto LAB_0a4f;
        }
      }
    }
    else if ((LAB_009e & 1) == 0) {
      FUN_0a79();
      FUN_0a79();
      goto LAB_0a4f;
    }
  }
  