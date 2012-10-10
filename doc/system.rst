Component Description
=====================

Basics of Display Controller
----------------------------

The LCD screen types are being widely used in embedded applications due to their cost and simple interface. However, a typical LCD has no frame buffer so without constant refreshing will lose its contents. The display controller allows an application to be removed from this real time requirement of mainintaining the LCD. Additionally, the display controller allows the application to use the SDRAM as a frame buffer without disrupting the LCD refresh.

Display Controller Component Features
-------------------------------------

The display controller component is designed to interface between the ``module_sdram`` and the ``module_lcd``. This module therefore inherits all the features of these modules plus:
  * Configurability of 
     * number of images held by the image manager,
     * verbose debug mode.
  * Requires a single core for the display controller.
     * The function ``display_controller`` requires just one core, the client functions, located in ``display_controller.h`` are low overhead and are called from the application.
