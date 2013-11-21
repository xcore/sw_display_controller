
Evaluation platforms
====================

.. _sec_hardware_platforms:

Recommended hardware
--------------------

sliceKIT
++++++++

This module may be evaluated using the sliceKIT modular development platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (sliceKIT L2 Core Board) 
   * XA-SK-SCR480 plus XA-SK-XTAG2 (sliceKIT xTAG adaptor) 

Demonstration applications
--------------------------

Display controller application
++++++++++++++++++++++++++++++

   * Package: sw_display_controller
   * Application: app_display_controller

This combination demo employs the ``module_lcd`` along with the ``module_sdram``, ``module_touch_controller_lib``, ``module_i2c_master`` and the ``module_display_controller`` framebuffer framework component to implement a 480x272 display controller.

Required board SKUs for this demo are:

   * XP-SKC-L16 (sliceKIT L16 Core Board) plus XA-SK-XTAG2 (sliceKIT xTAG adaptor) 
   * XA-SK-SDRAM
   * XA-SK-SCR480 (which includes a 480x272 color touch screen)  

