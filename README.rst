Display Controller Repository
.............................

:Latest release: 1.0.0
:Maintainer: andrewstanfordjason
:Description: The display controller component is used to drive a single graphics LCD screen incorporating a managed double buffer. 

Key Features
============

  * Non-blocking SDRAM management.
  * Real time servicing of the LCD.
  * Image memory manager to simplify handling of images.
  * No real time constraints on the application.

Firmware Overview
=================

The display controller component is used to drive a single graphics LCD screen incorporating a managed double buffer.

Documentation can be found at http://github.xcore.com/sc_sdram/docs/index.html

Known Issues
============

none

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the maintainer for this line.

Required software (dependencies)
================================

  * sc_i2c (git@github.com:xcore/sc_sdram_burst.git)
  * sc_uart (git@github.com:xcore/sc_lcd.git)

