Example Applications
====================

This tutorial describes the demo applications included in the XMOS Display Controller software component. :ref:`sec_hardware_platforms` describes the required hardware setup to run the demos.

app_display_controller_demo
---------------------------

This application demonstrates how the ``lcd_module`` is used to write image data to the LCD screen whilst imposing no real time constraints on the application. The purpose of this demonstration is to show how data is passed to the ``display_controller``. This application also demonstrates an interactive display using ``touch_controller_lib`` module.

Application Notes
-----------------

Getting Started
+++++++++++++++

   #. Plug the XA-SK-LCD Slice Card into the 'TRIANGLE' slot of the Slicekit Core Board 
   #. Plug the XA-SK-SDRAM Slice Card into the 'STAR' slot of the Slicekit Core Board 
   #. Open ``app_display_controller_demo.xc`` and build the project.
   #. run the program ensuring that it is run from the project directory where the tga images are.

The output produced should look like a series of images transitioning on the LCD when the screen is touched.

