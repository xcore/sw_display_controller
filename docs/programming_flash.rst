Programming The Flash
---------------------
The project is to run from the flash. Also the images should be written to flash. Follow the below steps to write to flash.
Note that the steps have been detailed only for Windows OS.

  #. Open the folder `..\app_zlg_mtx110e16_demo_2\flash\xmosrombuilder\windows`. Copy the application `XMOSRomBuilder` and paste it to the folder      `..app_zlg_mtx110e16_demo_2\flash`
  #. The images to be programmed are available in the folder `..\app_zlg_mtx110e16_demo_2\img`
  #. Open the XMOS Command prompt version 11.11.0
  #. Change directory to the location `..\app_zlg_mtx110e16_demo_2\flash`
  #. Type xmake
  #. Once the command is complete, type `Xobjdump --split <XE file name>` `xobjdump --split ..\bin\app_zlg_mtx110e16_demo_2.xe`
  #. Once the dump is complete, type `Xmosrombuilder -rev -spi -bin image_n0c0.elf -o < name of bin file>`
     This step creates a .bin file 
     `xmosrombuilder -rev -spi -bin image_n0c0.elf -o app_zlg_mtx110e16_demo_2.bin`
  #. Now the .bin file is ready for flashing. The code is flashed to sector 0. Type `perl write.pl <bin file name> <sector location>`
     `perl write.pl app_zlg_mtx110e16_demo_2.bin 0`
  #. The page size in the used flash is 256 bytes. The whole flash memory is also divided into sectors and each sector is 4K bytes long
  #. Once the flash write is complete, calculate the number of sectors used
      * i.e.: Number of bytes written/ sector size
      * In this project the number of sector used will be 9
      * If the number of sectors used by flash varies, the user should make sure they do not overwrite the image to the code sector. Hence the location of the image should be suitably changed. (sector number should be changed while writing flash and also while reading from flash in the demo.xc)
  #. To write the images, use the command

    `perl write.pl <image name with .tga extension> <sector number>`
    `perl write.pl kid.tga 9`
    `perl write.pl xmos.tga 107`
    `perl write.pl tile1_100x100.tga 205`
	
Make sure the images written are well within the sector boundaries. If the images overlap, please change the sector number accordingly
Note that the code can be run directly from the XDE too. In this case, the code will not be written to flash and hence we need to keep the XTAG2 connected to the PC always.