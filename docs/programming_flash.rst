Programming The Flash
---------------------
The project is to run from the flash. Also the images should be written to flash. The following steps are done to write to flash
Note that the steps have been detailed only for Windows OS.

  #. The folder '..\\app_graphics_demo\\flash\\xmosrombuilder\\windows' is opened. The application `XMOSRomBuilder` is copied and pasted to the folder '..app_graphics_demo\\flash'
  #. The images to be programmed are available in the folder '..\\app_graphics_demo\\\img'
  #. The XMOS Command prompt version 11.11.0 is opened
  #. The directory location in the command prompt is changed to '..\\app_graphics_demo\\flash'
  #. The command 'xmake' is given
  #. Once the command is complete, the command 'Xobjdump --split <XE file name>` is given
  	 `xobjdump --split ..\\bin\\app_graphics_demo.xe'
  #. Once the dump is complete, the command 'Xmosrombuilder -rev -spi -bin image_n0c0.elf -o < name of bin file>' is given
     This step creates a .bin file 
     `xmosrombuilder -rev -spi -bin image_n0c0.elf -o app_graphics_demo.bin`
  #. Now the .bin file is ready for flashing. The code is flashed to sector 0. To flash the code the command `perl write.pl <bin file name> <sector location>` is used
     `perl write.pl app_graphics_demo.bin 0`
  #. The page size in the used flash is 256 bytes. The whole flash memory is also divided into sectors and each sector is 4K bytes long
  #. Once the flash write is complete, we need to make sure we write images without overlapping the code. Hence the number of sectors used by the program is calculated
      * i.e.: Number of bytes written divided by sector size
      * In this project the number of sector used will be 9
      * If the number of sectors used by flash varies, we should make sure we do not overwrite the image to the code sector. Hence the location of the image should be suitably changed. (sector number should be changed while writing flash and also while reading from flash in the demo.xc)
  #. To write the images, the following command is used

    `perl write.pl <image name with .tga extension> <sector number>`
    `perl write.pl 1.tga 9`
    `perl write.pl 2.tga 107`
    `perl write.pl 3.tga 205`
    `perl write.pl 4.tga 303`
    `perl write.pl lenna.tga 499`
    `perl write.pl lcd-alpha.tga 401`
	
We need to make sure the images written are well within the sector boundaries. If the images overlap, the sector number is changed accordingly
Note that the code can be run directly from the XDE too. In this case, the code will not be written to flash and hence we need to keep the XTAG2 connected to the PC always.