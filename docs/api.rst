.. _sec_api:

Project structure
=================

The project is structured into
    * application: app_graphics_demo which includes the LCD-SDRAM manager and the demo application
    * component: module_sdram_burst_new which handles the SDRAM
    * component: module_lcd which handles the LCD

.. _sec_config_defines:

Configuration Defines
---------------------

LCD component
+++++++++++++

The following defines must be configured by the user for the LCD component.
The defines can be seen in the file ``lcd_defines.h`` and ``lcd_ports.xc``

.. list-table:: LCD Defines
   :header-rows: 1
   :widths: 3 2 1
  
   * - Define
     - Description
     - Default
   * - **LCD_WIDTH**
     - The width of the LCD screen in terms of pixels.
     - 480 
   * - **LCD_HEIGHT**
     - The height of the LCD screen in terms of rows.       
     - 272
   * - **VERT_PORCH**
     - This is the vertical porch timing for the LCD. 
       The value given here should include the vertical blanking period, vertical front porch and vertical back porch.
       The user should refer to the LCD datasheet to find the values
     - 6330
   * - **HOR_PORCH**
     - This is the horizontal porch timing for the LCD. 
       The value given here should include the horizontal blanking period, horizontal front porch and horizontal back porch.
       The user should refer to the LCD datasheet to find the values.
     - 45
   * - **p_lcd_clk**
     - This is a out port defined in the ``lcd_ports.xc`` file. The user should give the port details which should be used as LCD clock.
     - XS1_PORT_1O
   * - **p_lcd_tim**
     - This is a out port defined in the ``lcd_ports.xc`` file. The user should give the port details which should be used as LCD signals 
     - XS1_PORT_4F
   * - **p_lcd_rgb**
     - This is a out port defined in the ``lcd_ports.xc`` file. The user should give the port details which should be used for the 32 bit    RGB lines.
       (includes 2 data of 16 bit RGB color)
     - XS1_PORT_32A
   * - **clk_lcd**
     - This is a clock defined in the ``lcd_ports.xc`` file. The user should give the clock block which can used as LCD clock
     - XS1_CLKBLK_3
	 
SDRAM component
+++++++++++++++

The following defines must be configured by the user for the SDRAM component.
The defines can be seen in the file ``sdram_configuration.h``

.. list-table:: SDRAM Defines
   :header-rows: 1
   :widths: 3 2 1
  
   * - Define
     - Description
     - Default
   * - **SDRAM_COL_BITS**
     - The number of bits in each column. The value indicates the data width.
     - 16
   * - **SDRAM_ROW_LENGTH**
     - Number of columns in each row of the SDRAM
     - 256
   * - **SDRAM_ROW_COUNT**
     - Number of rows in each bank of the SDRAM
     - 2048
   * - **SDRAM_BANK_COUNT**
     - Number of banks supported by the SDRAM
     - 2
   * - **SDRAM_REFRESH_MS**
     - The period of refresh required for the SDRAM. The value is given in terms of milliseconds 
     - 16
   * - **SDRAM_REFRESH_CYCLES**
     - Number of times the SDRAM to be refreshed for every SDRAM_REFRESH_MS
     - 2048
   * - **SDRAM_MODE_REGISTER**
     - Defines the configuration of the SDRAM. The user should go through the SDRAM datasheet to find the configuration of the SDRAM
     - 0x0027
   * - Control words
     - The control words is a combination of 4 lines  CS, WE, CAS, RAS. The user can change the control word values depending on the 
       SDRAM. The control words define the operation required for the SDRAM.
     - The below picture shows the default configuration of the SDRAM
.. only:: html

  .. figure:: images/sdram_config.png
     :align: center

     SDRAM configuration

.. only:: latex

  .. figure:: images/sdram_config.pdf
     :figwidth: 50%
     :align: center

     SDRAM configuration


API
---
LCD APIs
++++++++


The LCD display module functionalities can be seen in
        * ``lcd.xc``
        * ``lcd.h``
        * ``lcd_defines.h``

The function :c:func:`lcd` in lcd.xc is handled in the thread.
This sections explains only the important APIs used by the user. Other static APIs are not discussed in this section.
Please refer to the files ``lcd.xc`` and ``lcd.h`` for the list of APIs.

Note that to enable the application use the LCD module, the user should add the module to the build options of the project. 
To achieve that, do the following:

  #. Open the file ``BuildOptions`` available in ..\app_graphics_demo folder
  #. Add the name ``module_lcd`` to the option ``MODULE`` in the BuildOptions. This will enable the application project to use the LCD module		   
  #. Add the object names lcd and lcd_ports to the option ``OBJNAMES``
  #. Add the module ``module_lcd`` to the ``References`` option in the project settings of the application project


.. doxygenfunction:: lcd
LCD SDRAM Manager APIs
++++++++++++++++++++++


The LCD SDRAM manager handles the double buffering of the SDRAM. It takes care of the write, read and the refresh commands for the SDRAM. The LCD SDRAM Manager code can be seen in

    * ``lcd_sdram_manager_client.xc``
    * ``lcd_sdram_manager_internal.h``
    * ``lcd_sdram_manager.xc``
    * ``lcd_sdram_manager.h``

This sections explains only the important APIs used by the user. Other static APIs are not discussed in this section.
Please refer to the files mentioned above for the list of APIs.

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


SDRAM APIs
++++++++++


The SDRAM module handles the 16 bit reads, writes and refresh of the SDRAM. The LCD-SDRAM manager submits 
the commands to the SDRAM module in a queue. The SDRAM module processes the commands and returns the 
required data. The SDRAM code can be seen as a separate module ``module_sdram_burst_new``in the project.

Note that to enable the application use the SDRAM module, the user should add the module to the build options of the project 
To achieve that, do the following

  #. Open the file ``BuildOptions`` available in ..\app_graphics_demo folder
  #. Add the name ``module_sdram_burst_new`` to the option ``MODULE`` in the BuildOptions. This will enable the application project to use the SDRAM module		    
  #. Add the object names sdram_server and sdram_client to the option ``OBJNAMES``   
  #. Add the module ``module_sdram_burst_new`` to the ``References`` option in the project settings of the application project

The SDRAM code can be seen in

    * ``sdram_server.xc``
    * ``sdram.h``
    * ``sdram_client.xc``

This sections explains only the important APIs used by the user. Other static APIs are not discussed in this section.
Please refer to the files mentioned above for the list of APIs.   
The SDRAM APIs for read, write and buffer commits are handled by the LCD-SDRAM Manager. 
Hence the user might not directly need them. The user might need only the SDRAM thread which is invoked in the main.xc.
The SDRAM APIs by themselves take care of the SDRAM refresh.


.. doxygenfunction:: sdram_server
Demo Application
++++++++++++++++

The project includes a sample demo for the user to visualize the working of the LCD, SDRAM and the LCD-SDRAM manager. The demo provided is only a skeleton and it is completely user modifiable.
The current demo is run under the function name `demo_full_screen_image_load` and this thread name is invoked in the :c:func:`main` function in ``main.xc``

The demo application can be seen in

    * Demo.xc
    * Demo.h
    * Transitions.xc (different transitions are implemented in this file)

The main aim of the supplied demo is to show the user

    * Loading of images to flash (the images are stored to flash before running the code. The images are stored in 24 bit TGA format)
    * Supporting reading images from flash (The 24 bit TGA image is read and the 24 bit RGB colour is converted to 16 bit (565 RGB colour) before storing to the SDRAM)
    * Supporting 4 full screen images in the SDRAM
    * Refresh rates of nearly 20 (which can be seen during different transitions between the images)


Refer to the section `Application System Description` to understand the flow of the application.	 
