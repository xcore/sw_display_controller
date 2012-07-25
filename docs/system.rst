Application System Description
===============================

Software Architecture
---------------------

The application uses 4 threads
  #. :c:func:`manager` (for LCD SDRAM manager)
  #. Demo thread
  #. SDRAM thread (sdram_server)
  #. LCD thread (lcd)

The application invokes the threads for
  * LCD SDRAM manager
  * SDRAM
  * LCD
as one thread (:c:func:`lcd_sdram_manager`).

All the 4 threads run parallel (inside the 'par' statement).

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


The name of the 'Demo thread' changes as per the implementation (currently named as :c:func:`demo_full_screen_image_load` in the file ``demo.xc``)

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

LCD SDRAM manager
-----------------

The LCD-SDRAM Manager helps to speed up the process of writing to the SDRAM and refreshing the LCD screen. 
The LCD SDRAM Manager does a double buffering of the LCD buffer (i.e.) when one image is being updated to the LCD screen, multiple images can be updated in the background. This double buffering concept helps to run SDRAM at a fast rate thereby saving the thread timings for other activities.

The current code uses 2 frame buffers for the LCD refresh. When one frame buffer is being refreshed on the screen, the other frame buffer can be updated simultaneously. The LCD-SDRAM manager will handle the buffer data. At any time, the buffer cannot be left empty or it cannot be overfilled.
The function :c:func:`manager` in the file ``lcd_sdram_manager.xc`` is handled inside thread.

Other Components (SDRAM and LCD)
--------------------------------

The project uses the components SDRAM and LCD.
The details of the components can be found at their respective repositories.

