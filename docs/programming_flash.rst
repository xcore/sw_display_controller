Programming The Flash
---------------------
In order to execute the project, the images should be written to Flash.
The executable can be programmed to the flash and executed from flash directly. In this case, there is no need of the XTAG2 connector once the executable has been flashed.
The executable can also be run by writing to the XTAG memory. In this case, the XTAG2 connector should be always connected to the board for the executable to run.

The following steps should be followed to write to flash
Note that the steps have been detailed only for Windows OS.

  #. The application `XMOSRomBuilder` should be copied from the location '..\\app_graphics_demo\\flash\\xmosrombuilder\\windows' and pasted to the folder '..app_graphics_demo\\flash'
  #. The images to be programmed are available in the folder '..\\app_graphics_demo\\\img'
  #. The XMOS Command prompt version 11.11.0 should be opened
  #. The directory location in the command prompt should be changed to '..\\app_graphics_demo\\flash'
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
      * In this project the number of sector used will be 9 (when built with optimization of level 3)
      * If the number of sectors used by flash varies, we should make sure we do not overwrite the image to the code sector. Hence the location of the image should be suitably changed. (sector number should be changed while writing flash and also while reading from flash in the demo.xc)
  #. To write the images, the following command is used

    `perl write.pl <image name with .tga extension> <sector number>`
    `perl write.pl 1.tga 9`  
    `perl write.pl 2.tga 107`  
    `perl write.pl 3.tga 205`  
    `perl write.pl 4.tga 303`  
    `perl write.pl lenna.tga 499`  
    `perl write.pl lcd-alpha.tga 401`  
	
We need to make sure the images written are well within the sector boundaries. If the images overlap, the sector number should be changed accordingly
