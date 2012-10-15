
Evaluation Platforms
====================

.. _sec_hardware_platforms:

Recommended Hardware
--------------------

Slicekit
++++++++

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) 
   * XA-SK-SCR480 plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 

Demonstration Applications
--------------------------

Display Controller Application
++++++++++++++++++++++++++++++

   * Package: sw_display_controller
   * Application: app_display_controller

This combination demo employs the ``module_lcd`` along with the ``module_sdram`` and the ``module_display_controller`` framebuffer framework component to implement a 480x272 display controller.

Required board SKUs for this demo are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-XTAG2 (Slicekit XTAG adaptor) 
   * XA-SK-SDRAM
   * XA-SK-SCR480 (which includes a 480x272 color touch screen)  

