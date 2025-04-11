set -e

vasmm68k_mot -Fbin -m68000 memtest.asm -o memtest.rom
vasmm68k_mot -Fbin -m68000 ramsender.asm -o ramsender.rom
vasmm68k_mot -Fbin -m68000 romsender.asm -o romsender.rom
vasmm68k_mot -Fbin -m68000 memzero.asm -o memzero.rom
vasmm68k_mot -Fbin -m68000 unaligned_video_test.asm -o unaligned_video_test.rom
vasmm68k_mot -Fbin -m68000 byte_word_test.asm -o byte_word_test.rom
vasmm68k_mot -Fbin -m68000 slavetest.asm -o slavetest.rom
vasmm68k_mot -Fbin -m68000 cdic_audiomap.asm -o cdic_audiomap.rom
vasmm68k_mot -Fbin -m68000 cdic_cdda_play.asm -o cdic_cdda_play.rom
vasmm68k_mot -Fbin -m68000 cdic_xa_play.asm -o cdic_xa_play.rom
vasmm68k_mot -Fbin -m68000 cdic_data.asm -o cdic_data.rom
vasmm68k_mot -Fbin -m68000 uarttest.asm -o uarttest.rom
vasmm68k_mot -Fbin -m68000 nvram_backup_restore.asm -o nvram_backup_restore.rom
vasmm68k_mot -Fbin -m68000 nvramsender.asm -o nvramsender.rom
vasmm68k_mot -Fbin -m68000 cdic_sector_send.asm -o cdic_sector_send.rom

xxd -p -c2 slavetest.rom cdi200.mem
xxd -p -c1 zc405352p__slave_cdi_4.1__0d67p__lltr9403.mc68hc705c8a.7206 slave.mem
#xxd -p -c1 ../sim/cdimono1/zx405042p__cdi_slave_2.0__b43t__zzmk9213.mc68hc705c8a_withtestrom.7206 slave.mem

#dd if=/dev/urandom of=save.bin count=16
