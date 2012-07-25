Overview
========

The sw_display_controller includes the LCD graphics demo application. The application has been designed to show how a graphics LCD can be driven using the XMOS device XS1-L1.
It also includes the components SDRAM (available as sc_sdram_burst) and LCD (available as sc_lcd) which are dependencies for the application.

Graphics LCDs are widely used in many day to day user applications. Some examples include elevated displays on buildings, advertisement boards, ATM displays and so on.
Since the application uses a standalone LCD module which doesn't include an in-built memory, it also uses an external 16 bit SDRAM.
Thus the application also demonstrates how a 16 bit SDRAM can be accessed using the XCORE silicon.

Brief description of the project
--------------------------------

The aim of the project is to load pre-stored images from the flash, move them to the SDRAM image buffer and update the LCD screen with the pre-stored images.
While displaying the images, transition effects have been included for every image change inorder to showcase the capability of LCD driving by the XCORE silicon.

The implemented project uses the following:
  * Graphics LCD of resolution 480 * 272 pixels with 16 bit RGB color code
  * 16 bit SDRAM of size 2 MB
  
The following figure shows the flow of the application

.. only:: html

  .. figure:: images/display.png
     :align: center

     Application Flow Diagram

.. only:: latex

  .. figure:: images/display.pdf
     :figwidth: 50 %
     :align: center

     Application Flow Diagram


The application can be divides as
	* LCD display component 
	* SDRAM component 
	* LCD SDRAM Manager
	* Demo Application

In order to use the application,
  #. The repository sw_display_controller is downloaded. This includes the 'Demo Application' and the 'LCD SDRAM Manager',
  #. The repository sc_sdram_burst is downloaded. It includes the SDRAM component and it is linked to the application project,
  #. The repository sc_lcd is downloaded. It includes the LCD component and it is linked to the application project.
  
Project Summary
+++++++++++++++++

+----------------------------------------------------------------+
|                      ** Functionality **    .......            |
+----------------------------------------------------------------+
|  Application driving a graphics LCD module   ........          |
+----------------------------------------------------------------+
|                     ** Supported Device **.                    |
+-------------------------------+--------------------------------+
| | XMOS devices                | | XS1-L1                       |
|                               | | XS1-L2                       |
|                               | | XS1-G4                       |
+-------------------------------+--------------------------------+
|                       ** Requirements **                       |
+-------------------------------+--------------------------------+
| XMOS Desktop Tools.........   | V11.11.0 or later...           |
+-------------------------------+--------------------------------+
| XMOS LCD component            | 1v0                            |
+-------------------------------+--------------------------------+
| XMOS SDRAM component          | 1v0                            |
+-------------------------------+--------------------------------+
|                     **Licensing and Support**                  |
+----------------------------------------------------------------+
| Component code provided without charge from XMOS.              |
| Component code is maintained by XMOS                           |
+----------------------------------------------------------------+
	

Demo Application
++++++++++++++++

  * Sample demo demostrating how images are displayed on a graphics LCD
  * Highlights the usage of graphics LCD and external SDRAM
  * Handles 6 images stored to the flash
  * Images read from flash and stored to SDRAM
  * Transition effects like Slide, Box, Dither, Roll and Alpha Blend are supported
  * Uses one thread

LCD SDRAM Manager properties
++++++++++++++++++++++++++++

  * Comes as a part of the demo application
  * Handles the double buffering concept for the SDRAM so that the slower LCD writes can match the fast SDRAM updates
  * Takes care the LCD buffer is neither overflowing nor underflowing and has atleast one valid data to write at anytime
  * 2 frame buffers used in the current code
  * Uses one thread

For LCD and SDRAM properties, please refer to the respective documents available in the sc_sdram_burst and sc_lcd repositories.

Resource requirements
=====================

The resource requirements for the demo application (including LCD SDRAM Manager) are:

+--------------+-----------------------------------------------+
| Resource     | Usage                                         |
+==============+===============================================+
| Channels     | 1 (SDRAM, LCD, Demo)                          |
+--------------+-----------------------------------------------+
| Timers       | 1 (optional. Depends on the demo)             | 
+--------------+-----------------------------------------------+
| Threads      | 2 (LCD SDRAM Manager, Demo)                   |
+--------------+-----------------------------------------------+

The resource requirements for the whole project (including SDRAM component, LCD component, LCD SDRAM manager and demo application) are:

+--------------+-----------------------------------------------+
| Resource     | Usage                                         |
+==============+===============================================+
| Channels     | 3 (SDRAM, LCD, Demo)                          |
+--------------+-----------------------------------------------+
| Timers       | 3 (1 for LCD, 1 for SDRAM, 1 for the demo     | 
|              |    application - optional)                    |
+--------------+-----------------------------------------------+
| Clocks       | 2 (1 for LCD, 1 for SDRAM)                    |
+--------------+-----------------------------------------------+
| Threads      | 4 (LCD, SDRAM, LCD SDRAM Manager, Demo)       |
+--------------+-----------------------------------------------+

The memory usage depends on the optimization settings and compiler used.
Total memory usage of current project including the SDRAM and LCD components is

+--------------+-----------------------------------------------+
| Memory       | Usage                                         |
+==============+===============================================+
| Settings     | No optimization                               |
+--------------+-----------------------------------------------+
| Compiler     | XCC                                           |
+--------------+-----------------------------------------------+
| Stack        | 5228 bytes                                    |
+--------------+-----------------------------------------------+
| Program      | 30316 bytes                                   |
+--------------+-----------------------------------------------+


