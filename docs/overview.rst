Overview
========

The app_graphics_demo application provides the whole graphics LCD display driver built using the XMOS device XS1-L1. The application includes the LCD component, SDRAM component and top layer application. The application in the project is built in such a way to get a feel of how a graphics LCD display module can be accessed using the XMOS silicon. The LCD graphics module used in this project doesn't include an in-built memory. An external SDRAM is used to store the LCD buffer content. Thus the project also shows how to access an SDRAM.

Brief description of the project
--------------------------------

The project loads images from the flash and displays them on the graphics LCD screen. Transition effects between the images have been added in the application. The project uses a 480 * 272 LCD display module. The LCD module uses an external SDRAM for the LCD buffer. The project uses an 16 bit SDRAM.
The following figure shows the flow of the project

.. only:: html

  .. figure:: images/display.png
     :align: center

     Application Flow Diagram

.. only:: latex

  .. figure:: images/display.pdf
     :figwidth: 50 %
     :align: center

     Application Flow Diagram


The project can be divided into
	* LCD display component 
	* SDRAM component 
	* LCD SDRAM Manager
	* Demo Application

Project Summary
+++++++++++++++++

+----------------------------------------------------------------+
| 	               ** Functionality **	      		             |
+----------------------------------------------------------------+
|  Application driving a graphics LCD module 		             |
+----------------------------------------------------------------+
| 		      ** Supported Device **		                     |
+-------------------------------+--------------------------------+
| | XMOS devices		        | | XS1-L1                       |
|				                | | XS1-L2		                 |
| 				                | | XS1-G4			             |
+-------------------------------+--------------------------------+
|  	               ** Requirements ** 		                     |
+-------------------------------+--------------------------------+
| XMOS Desktop Tools		    | V11.11.0 or later	             |
+-------------------------------+--------------------------------+
| XMOS LCD component		    | 1v0  		                     |
+-------------------------------+--------------------------------+
| XMOS SDRAM component		    | 1v0	                 		 |
+-------------------------------+--------------------------------+
|                     **Licensing and Support**                  |
+----------------------------------------------------------------+
| Component code provided without charge from XMOS.              |
| Component code is maintained by XMOS.                          |
+----------------------------------------------------------------+


	
LCD Display component properties
++++++++++++++++++++++++++++++++

	* Standard component to support different LCD modules
	* User has to configure the LCD properties and then the component can be directly used
	* Different color depths 24 bits, 18 bits, 16 bits based on user configuration
	* Resolution upto 800 * 600 pixels (480 * 272 pixel is used in this project)
	* Frame rate of upto 20  Fps for the resolution used in the sample project (480 * 272 pixels)
	* Uses one thread

SDRAM component properties
++++++++++++++++++++++++++

	* SDRAM component can be configured for number of banks, rows and columns in the SDRAM
	* Proper packing of the data so that no space is left unused. This helps the user to effectively store more images in the SDRAM
	* Has 2 SDRAM banks. The "self-refresh" mode in also supported
	* Uses one thread

LCD SDRAM Manager properties
++++++++++++++++++++++++++++

	* Comes as a part of the application
	* Handles the double buffering concept for the SDRAM so that the slower LCD writes can match the fast SDRAM updates
	* Takes care the LCD buffer is neither overflowing nor underflowing and has atleast one valid data to write at anytime
	* 2 frame buffers used in the current code
	* Uses one thread

Demo Application
++++++++++++++++

	* Sample demo provided to the user for understanding the application
	* Handles 6 images stored to the flash
	* Images read from flash and stored to SDRAM
	* Each image displayed for 5 seconds
	* Transition effects like Slide, Box, Dither, Roll and Alpha Blend are supported
	* Uses one thread

Resource requirements
=====================

The resource requirements for the LCD component alone are:

+--------------+-----------------------------------------------+
| Resource     | Usage                            	           |
+==============+===============================================+
| Channels     | 1 		                                       |
+--------------+-----------------------------------------------+
| Timers       | 1 (for deciding the LCD signal write timings) |
+--------------+-----------------------------------------------+
| Clocks       | 1 (the LCD clock)                             |
+--------------+-----------------------------------------------+
| Threads      | 1                                             |
+--------------+-----------------------------------------------+



The resource requirements for the SDRAM component alone are:

+--------------+-----------------------------------------------+
| Resource     | Usage                            	           |
+==============+===============================================+
| Channels     | 1 		                                       |
+--------------+-----------------------------------------------+
| Timers       | 1 (for deciding the SDRAM setup, read,        |
|	           |    write delays)			                   |
+--------------+-----------------------------------------------+
| Clocks       | 1 (the SDRAM clock)                           |
+--------------+-----------------------------------------------+
| Threads      | 1                                             |
+--------------+-----------------------------------------------+


The resource requirements for the whole project (including SDRAM component, LCD component, LCD SDRAM manager and demo application) are:

+--------------+-----------------------------------------------+
| Resource     | Usage                               	       |
+==============+===============================================+
| Channels     | 3 (SDRAM, LCD, Demo)                          |
+--------------+-----------------------------------------------+
| Timers       | 3 (1 for LCD, 1 for SDRAM, 1 for the demo     | 
|	           |    application - optional)		               |
+--------------+-----------------------------------------------+
| Clocks       | 2 (1 for LCD, 1 for SDRAM)                    |
+--------------+-----------------------------------------------+
| Threads      | 4 (LCD, SDRAM, LCD SDRAM Manager, Demo)       |
+--------------+-----------------------------------------------+

The memory usage depends on the compile and build settings. Total memory usage of current project is

+--------------+-----------------------------------------------+
| Memory       | Usage                            	           |
+==============+===============================================+
| Stack        | 5216 bytes                                    |
+--------------+-----------------------------------------------+
| Program      | 19980 bytes				                   |
+--------------+-----------------------------------------------+

The project also includes the threads for testing the SDRAM which occupies 4 threads. These test threads can be removed thereby saving 4 threads for further usage
