Programming guide
=================

Shared memory interface
-----------------------
The display controller uses a shared memory interface to move the large amount of data around from tile to tile efficiently. This means that the ``display_controller``, ``sdram_server`` and ``lcd_server`` must be one the same tile.


Source code structure
---------------------
.. list-table:: Project structure
  :header-rows: 1
  
  * - Project
    - File
    - Description
  * - module_display_controller
    - ``display_controller.h`` 
    - Header file containing the APIs for the display controller component.
  * - 
    - ``display_controller.xc``
    - File containing the implementation of the display controller component.
  * - 
    - ``display_controller_client.xc``
    - File containing the implementation of the display controller client functions.
  * - 
    - ``display_controller_internal.h``
    - Header file containing the user configurable defines for the display controller component.
  * - 
    - ``transitions.h``
    - Header file containing the APIs for the display controller transitions.
  * - 
    - ``transitions.xc``
    - File containing the implementation of the display controller transitions.

Executing the project
---------------------
The module by itself cannot be built or executed separately - it must be linked in to an application. Once the module is linked to the application, the application can be built and tested for driving a LCD screen.

The following modules should be added to the list of MODULES in order to link the component to the application project
  #. ``module_display_controller`` 
  #. ``module_lcd``
  #. ``module_sdram``
Now the module is linked to the application and can be used directly. Additionally, if the use of the touch controller is nessessary then
  #. ``module_touch_controller_lib`` or ``module_touch_controller_server``
  #. ``module_i2c_master``
should be added to the list of MODULES.

Software requirements
---------------------

The module is built on xTIMEcomposer version 12.0
The module can be used in version 12.0 or any higher version of xTIMEcomposer.

