Source code structure
---------------------

The project contains:
	* application app_graphics_demo
	* module module_sdram_burst_fast
	* module module_lcd

.. list-table:: Project structure
  :header-rows: 1
  
  * - Project
    - File
    - Description
  * - app_graphics_demo
    - ``lcd_sdram_manager.h`` 
    - Header file containing the APIs for the LCD SDRAM manager
  * - 
    - ``lcd_sdram_manager.xc``
    - File containing the implementation of LCD SDRAM Manager. These APIs are used for handling the double buffering
  * - 
    - ``lcd_sdram_manager_internal.h``
    - Header file containing the defines for the internal use in LCD SDRAM Manager APIs.
  * - 
    - ``lcd_sdram_manager_client.xc``
    - File containing the internal implementation of the LCD SDRAM Manager. These APIs are internally used in the ``lcd_sdram_manager.xc``
  * - 
    - ``rgb888_to_rgb565.h``
    - Header file containing the prototype for :c:func::`rgb888_to_rgb565`
  * - 
    - ``rgb888_to_rgb565.c``
    - File containing the implementation of color conversion - i.e: converting 24 bit RGB to 16 bit RGB color.
  * - 
    - ``sdram_configurations.h``
    - Header file containing the user configurable SDRAM parameters.	
  * - 
    - ``main.xc``
    - File containing the implementation of the main function. This function handles the invokation of the threads in a "par" statement.
  * - 
    - ``demo.h``
    - Header file containing the prototype for user defined demo application	
  * - 
    - ``demo.xc``
    - File containing the implementation of the user specific demo functionality	
  * - 
    - ``transitions.h``
    - Header file containing the prototypes for the transition functions
  * - 
    - ``transitions.xc``
    - File containing the implementation of the transition functions like slide, wipe, roll, box, dither and alpha blend
  * - 
    - ``traffic.h``
    - Header file containing the prototype for test functions
  * - 
    - ``traffic.xc``
    - File containing the implementation of test functions
  * - module_lcd
    - ``lcd.h`` 
    - Header file containing the APIs for the LCD component
  * - 
    - ``lcd.xc``
    - File containing the implementation of the LCD component thread
  * - 
    - ``lcd_defines.xc``
    - Header file containing the user configurable defines for the LCD
  * - 
    - ``lcd_ports.xc``
    - File containing the defines for the port parameters of the LCD
  * - module_sdram_burst_fast
    - ``sdram_server.h`` 
    - Header file containing the APIs for the SDRAM component
  * - 
    - ``sdram_server.xc``
    - File containing the implementation of the SDRAM component including the SDRAM threads, SDRAM reads and writes
  * - 
    - ``sdram_internal.h``
    - Header file containing the internal defines used by the SDRAM component
  * - 
    - ``sdram_client.xc``
    - File containing the implementation of the internal APIs used by the SDRAM component. These APIs are used by the ``sdram_server.xc``