Programming Guide
=================

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

Executing The Project
---------------------
The module by itself cannot be built or executed separately - it must be linked in to an application. Once the module is linked to the application, the application can be built and tested for driving a LCD screen.

The following should be done in order to link the component to the application project
  #. The module name ``module_display_controller`` should be added to the list of MODULES in the application project build options. 
  #. The module name ``module_lcd`` should be added to the list of MODULES in the application project build options. 
  #. The module name ``module_sdram`` should be added to the list of MODULES in the application project build options. 
  #. The module name ``module_touch_controller_lib`` should be added to the list of MODULES in the application project build options. 
  #. The module name ``module_i2c_master`` should be added to the list of MODULES in the application project build options. 
  #. Now the module is linked to the application and can be used directly

Software Requirements
---------------------

The module is built on XDE Tool version 12.0
The module can be used in version 12.0 or any higher version of xTIMEcomposer.

