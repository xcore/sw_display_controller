
.. _sec_lever_meter_api:

To build a project including the ``module_level_meter``
the following modules are required:

	* ``module_display_controller``
	* ``module_sdram`` in ``sc_sdram_burst`` which handles the SDRAM
	* ``module_lcd`` in ``sc_lcd`` which handles the LCD
	
The section below details the configuration defines and the APIs used in the application.

Configuration defines
---------------------

The color palette to be used for the level meter display can be
configured via the header ``level_meter_conf.h``. The defines are:

**LEVEL_METER_NCOLORS**
	This defines the number of color used for the level meter display.
	
**LEVEL_METER_COLORS**
	This gives the colors used. The colors can be picked from the list given in ``level_meter.h``.

API
---

The ``module_level_meter`` functionality is defined in

	* ``level_meter.xc``
	* ``level_meter.h``
	
The level_meter API is:

.. doxygenfunction:: level_meter