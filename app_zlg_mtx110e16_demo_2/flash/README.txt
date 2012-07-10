Writing to SPI flash using programmer.c
====================================================


Writing XEFILE to flash for booting
----------------------------------------

1) make programmer.xe

              xmake

   note: add 'verbose' after xmake for debugging

2) generate BINFILE from your XEFILE

              xobjdump --split XEFILE
              XmosRomBuilder -rev -spi -bin image_n0c0.elf -o BINFILE

   note: alternative method, including stage 2 loader (currently not working)
   xflash --spi-div 3 --noinq --boot-partition-size 0x10000 XEFILE -o BINFILE

3) execute the programmer

              perl write.pl BINFILE 0

   note: this will invoke 'xrun --io programmer.xe'


Writing JPGFILE to flash, starting at sector SECTORNUM
---------------------------------------------------------------

1) make programmer.xe like above

2) generate TGAFILE from your JPGFILE

              convert JPGFILE -resize 123x45 TGAFILE

3) execute the programmer

              perl write.pl TGAFILE SECTORNUM

   note: sector size is 4KBytes
