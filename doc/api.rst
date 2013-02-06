.. _sec_display_controller_api:

Project structure
=================

To build a project including the ``module_display_controller`` the following components are required:
    * component: sc_sdram_burst which handles the SDRAM
    * component: sc_lcd which handles the LCD and touch screen

The section below details the APIs in the application. For details about the LCD, touch screen and SDRAM APIs please refer to the respective repositories.

Configuration Defines
---------------------

The ``module_display_controller`` can be configured via the header ``display_controller_conf.h``. The module requires nothing to be additionally defined however any of the defines can be overridden by adding the header ``display_controller_conf.h`` to the application project and adding the define that needs overridding. The possible defines are:

**DISPLAY_CONTROLLER_MAX_IMAGES**
	This defines the storage space allocated to the display controller for it to store image metadata. When an image is registered with the display controller its dimensions and location in SDRAM address space are stored in a table. The define specifies how many entries are allowed in that table. Note, there is no overflow checking by default.

**DISPLAY_CONTROLLER_VERBOSE**
	This define switches on the error checking for memory overflows and causes verbose error warnings to be emitted in the event of an error.

API
---

The``module_display_controller`` functionality is defined in
    * ``display_controller_client.xc``
    * ``display_controller_internal.h``
    * ``display_controller.xc``
    * ``display_controller.h``
    * ``transitions.h``
    * ``transitions.xc``

The display controller handles the double buffering of the image data to the LCD as a real time service and manages the I/O to the SDRAM as a non-real time service. 

The display controller API is as follows:
.. doxygenfunction:: display_controller
.. doxygenfunction:: image_read_line
.. doxygenfunction:: image_read_line_p
.. doxygenfunction:: image_write_line
.. doxygenfunction:: image_write_line_p
.. doxygenfunction:: image_read_partial_line
.. doxygenfunction:: image_read_partial_line_p
.. doxygenfunction:: register_image
.. doxygenfunction:: wait_until_idle
.. doxygenfunction:: wait_until_idle_p
.. doxygenfunction:: frame_buffer_commit
.. doxygenfunction:: frame_buffer_init

The transition API is as follows:
.. doxygenfunction:: transition_wipe
.. doxygenfunction:: transition_slide
.. doxygenfunction:: transition_roll
.. doxygenfunction:: transition_dither
.. doxygenfunction:: transition_alpha_blend

The transitions use the display controller API.

