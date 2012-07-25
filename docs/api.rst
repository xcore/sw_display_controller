Project structure
=================

The project is structured into
    * application: app_graphics_demo which includes the LCD-SDRAM manager and the demo application
    * component: sc_sdram_burst which handles the SDRAM
    * component: sc_lcd which handles the LCD
The below section details the APIs in the application. For details about the LCD and SDRAM APIs please refer to the respective repositories.

LCD SDRAM Manager APIs
++++++++++++++++++++++


The LCD SDRAM manager handles the double buffering of the SDRAM. It takes care of the write, read and the refresh commands for the SDRAM. The LCD SDRAM Manager code can be seen in

    * ``lcd_sdram_manager_client.xc``
    * ``lcd_sdram_manager_internal.h``
    * ``lcd_sdram_manager.xc``
    * ``lcd_sdram_manager.h``

This sections explains only the important APIs that are frequently used. Other static APIs are not discussed in this section.
The other APIs can be seen in the files mentioned above.

.. doxygenfunction:: lcd_sdram_manager
.. doxygenfunction:: register_image
.. only:: html

  .. figure:: images/register.png
     :align: left

     
.. only:: latex

  .. figure:: images/register.pdf
     :figwidth: 50%
     :align: left

.. doxygenfunction:: image_write_line_nonblocking
.. only:: html

  .. figure:: images/sdram_write.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_write.pdf
     :figwidth: 50%
     :align: left

.. doxygenfunction:: image_read_line_nonblocking
.. only:: html

  .. figure:: images/sdram_read.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_read.pdf
     :figwidth: 50%
     :align: left

.. doxygenfunction:: image_read_partial_line_nonblocking
.. only:: html

  .. figure:: images/sdram_read_partial_1.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_read_partial_1.pdf
     :figwidth: 50%
     :align: left

.. only:: html

  .. figure:: images/sdram_read_partial_2.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_read_partial_2.pdf
     :figwidth: 50%
     :align: left

.. doxygenfunction:: frame_buffer_commit
.. only:: html

  .. figure:: images/sdram_buffer_1.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_buffer_1.pdf
     :figwidth: 50%
     :align: left

.. only:: html

  .. figure:: images/sdram_buffer_2.png
     :align: left

     
.. only:: latex

  .. figure:: images/sdram_buffer_2.pdf
     :figwidth: 50%
     :align: left


Demo Application
++++++++++++++++

The project includes a sample demo which includes the working of the LCD, SDRAM and the LCD-SDRAM manager. The demo provided is only a skeleton and can be modified when required.
The current demo is run under the function name `demo_full_screen_image_load` and this thread name is invoked in the :c:func:`main` function in ``main.xc``

The demo application can be seen in

    * Demo.xc
    * Demo.h
    * Transitions.xc (different transitions are implemented in this file)

The main aim of the supplied demo is 

    * Loading of images to flash (the images are stored to flash before running the code. The images are stored in 24 bit TGA format)
    * Reading images from flash (The 24 bit TGA image is read and the 24 bit RGB colour is converted to 16 bit (565 RGB colour) before storing to the SDRAM)
    * Supporting 6 full screen images in the SDRAM
    * Refresh rates of nearly 20 (which can be seen during different transitions between the images)


The section `Application System Description` gives a brief idea of the flow of the application.	 
