Application System Description
===============================

Software Architecture
---------------------

The following Figure shows the threads running in the system

.. only:: html

  .. figure:: images/threads.png
     :align: center

     Application Software Architecture 

.. only:: latex

  .. figure:: images/threads.pdf
     :figwidth: 50%
     :align: center

     Application Software Architecture


The project uses 4 threads. The remaining 4 threads are available for the user for other applications. The 3 threads

    * :c:func:`sdram_server` (for SDRAM)
    * :c:func:`manager` (for LCD-SDRAM manager)
    * :c:func:`lcd` (for LCD)

are called inside the function :c:func:`lcd_sdram_manager`.
The 4th thread of the project is used by the demo application. 
The name of the 4th thread can change as per user implementation (currently named as :c:func:`demo_full_screen_image_load` in the file ``demo.xc``)

All the 4 threads run parallel (inside the 'par' statement). At any time, the LCD buffer expects atleast one valid data so that the :c:func:`lcd` keeps refreshing the screen all the time.

Basics of Graphics LCD
----------------------
The LCD screen as the name indicates is an array of 'Liquid Crystal Display', which are organized in some random pattern when there is no electric field and aligns to the field when there is an electric field.
The crystals themselves do not emit light, but they gate the amount of light that can pass through them. For example, a crystal which is perpendicualr to a light source will block the light from passing through it. Since the crystals do not emit light on their own, a light source or a backlight is required to get the images on the LCD screen.
The LCDs are classified into Super Twisted Nematic (STN displays) displays and Thin Filn Transistor displays (TFT displays) depending on the technology. This project uses only TFT displays.

In order to create colors in the otherwise black and white LCD screen, color filters are used for each pixel. To generate the real world colors, there are 3 segments which individually pass light through the red, blue and green filters inorder to make the RGB color. For a 320 * 240 pixel LCD screen, there is actually 320 * 3 = 960 segments (in order to generate the RGB color) and there are 240 rows.
	 
A TFT display needs 1 clock to drive 3 segments - i.e.: 1 clock to generate 1 pixel and hence 320 clock to generate the 320 pixels. The color level depends on the number of lines used to generate the color.
The LCD panel might use 24 lines to generate a color. Such LCD panel color code is defined as 24 bpp (24 bits per pixel). The LCD panel might also support 18bpp, 16 bpp, 15 bpp and 8 bpp.

LCDs required the following basic signals:

        * VSYNC (Vertical Sync) - Used to reset the LCD row pointer to top of the display
        * HSYNC (Horizontal Sync) - Used to reset the LCD column pointer to the edge of the display
        * D0 - Dx (Data lines) 	
        * LCD CLK (LCD clock)

Some panels might also need  LCDDATAENAB (to indicate valid data on data bus), LCD power, backlight power, touchscreen lines etc.
The following figure shows the LCD timing parameters. The user should be aware of these parameters to configure the LCD component.

.. only:: html

  .. figure:: images/lcd_timing.png
     :align: center

     LCD Timing Parameters

.. only:: latex

  .. figure:: images/lcd_timing.pdf
     :figwidth: 50%
     :align: center

     LCD Timing Parameters
	 
The frame buffer is the memory allocated for data used to periodically refresh the display. 
The buffer size is computed using rows * columns * size of each pixel. The LCD modules used in this project do not have an
inbuilt frame buffer. The external SDRAM is used as the frame buffer.

LCD component
-------------

The LCD display module controls the graphics controller which includes handling the clock and the data enable signals. 
The Data enable signals handle the timings for the vertical and horizontal porch and hence controls the lcd data update.
The LCD component can also be modified to support the vertical and horizontal Sync signals. 
The provided customer hardware uses a 480 * 272 pixel LCD display. The 565 RGB colour coding is used in the project.
The component can also be configured to use 24 bpp/ 18 bpp/ 16 bpp and so on.
The LCD module includes the main function :c:func:`lcd` which is handled in a thread.

The same LCD component can be used to drive various graphics LCD modules. The maximum resolution supported is 800 * 600.
The component supports only LCD modules with no in-built memory.
The project is designed in such a way that the external SDRAM is used for storing the LCD buffer data.
The LCD parameters are configured in the files ``lcd.h`` and ``lcd_ports.xc``.


SDRAM component
---------------

A 16 bit SDRAM module has been implemented for this project. 

The SDRAM component has the following features:

	* Configurable number of banks, number of rows, size of the row, configurable signal levels depending on the SDRAM used
	* Configuration of the SDRAM using the file ``sdram_configuration.h``
	* Supports block read, block write, write a line, read a line, read a line partially and self refresh

The SDRAM (IS42VS16100F) used in this project is a 16 Mb SDRAM. The SDRAM has 2 banks each supporting 512 K words.
Each bank in the SDRAM has 2048 rows. Each row comprises of 256 16 bit data. These configurations can also be seen in the file ``sdram_configuration.h``
The SDRAM structure looks like as shown below

.. only:: html

  .. figure:: images/sdram.png
     :align: center

     SDRAM architecture

.. only:: latex

  .. figure:: images/sdram.pdf
     :figwidth: 50%
     :align: center

     SDRAM architecture

Each row in LCD has 480 pixels.
Each row in LCD needs 480 * 2 bytes (for 16 bit 565 RGB colour) = 960 bytes
Each row in SDRAM has 256 (columns) * 2 bytes = 512 bytes
So each LCD row will need nearly 2 rows in the SDRAM.
The images in the SDRAM are packed in such a manner that there is no wastage of space while writing the rows. Thus SDRAM can have 8 full size image buffers. (i.e.) Bank 0 of size 2048 rows can store 4 images, 510 * 4 = 2040 rows. Bank 1 of size 2048 rows can store 4 images, 510 * 4 = 2040 rows.
Of the 8 available image buffers, 2 buffers will be used by the LCD frame. So leaving the LCD frame buffers, the user can store 6 full size images in the SDRAM.
The main function :c:func:`sdram_server` in the file ``sdram_server.xc`` is handled in a thread.

LCD SDRAM manager
-----------------

The LCD-SDRAM Manager is main module which helps to speed up the process of writing to the SDRAM and refreshing the LCD screen. 
The LCD SDRAM Manager does a double buffering of the LCD buffer (i.e.) when one image is being updated to the LCD screen, multiple images can be updated in the background. This double buffering concept helps to run SDRAM at a fast rate thereby saving the thread timings for other activities.

The current code uses 2 frame buffers for the LCD refresh. When one frame buffer is being refreshed on the screen, the other frame buffer can be updated simultaneously. The LCD-SDRAM manager will handle the buffer data. At any time, the buffer cannot be left empty or it cannot be overfilled.
The main function :c:func:`manager` in the file ``lcd_sdram_manager.xc`` is handled inside thread.

Demo Application
----------------

The demo code given in the project is a sample code with the following features:

   * Handles 6 images stored to Flash. All images are of size 480 * 272 pixels.
   * Image 1 stored at sector 9 
   * Image 2 stored at sector 107
   * Image 3 stored at sector 205
   * Image 4 stored at sector 303
   * Image 5 stored at sector 499
   * Image 6 stores at sector 401
   * The images are stored in SDRAM (The project uses 6 SDRAM image buffers)
   * Each image is displayed for 5 seconds and every new image comes with a transition effect. The transition effects shown are:
       * Slide
       * Wipe
       * Dither
       * Roll
       * Alpha bend

Before the program is executed, the images should be stored in flash. The project supports only .tga images.
Writing the images to the flash has been explained in further sections

The below flow diagram explains the demo application:

.. only:: html

  .. figure:: images/demo.png
     :align: center

     Demo Application Flow Diagram

.. only:: latex

  .. figure:: images/demo.pdf
     :figwidth: 50%
     :align: center

     Demo Application Flow Diagram

