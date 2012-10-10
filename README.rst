Display Controller Repository
.............................

:Latest release: 1.0.0alpha2
:Maintainer: andrewstanfordjason
:Description: Modules for driving parallel RGB displays in conjunction with sdram and lcd components. The main module here takes care of framebuffer management.


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

  * sc_lcd (git@github.com:xcore/sc_lcd.git)
  * sc_sdram_burst (git@github.com:xcore/sc_sdram_burst.git)
  * sc_util (git@github.com:xcore/sc_util)

