.. _Display_Controller_Demo_Quickstart:

sw_display_controller demo : Quick Start Guide
----------------------------------------------

In this demonstration we use the following hardware and software:
  * XA-SK-SCR480 Slice Card,
  * XA-SK-SDRAM Slice Card,
  * module_sdram,
  * module_lcd,
  * module_display_controller, 
together to create a double buffered LCD controller. This application showcases some of the key software features and serves as an example on how to use an LCD without the real-time contraint of having to update the LCD line buffer. 

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system:

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``TRIANGLE``.
   #. Connect XA-SK-SCR480 Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``STAR``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 to host PC. Note that the USB cable is not provided with the Slicekit starter kit.
   #. Set the ``XMOS LINK`` to ``OFF`` on the XTAG Adapter.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.jpg
   :width: 400px
   :align: center

   Hardware Setup for Simple GPIO Demo
   
	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'Display Controller Demo'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_display_controller) to be imported as well. 
   #. Click on the app_display_controller_demo item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial. FIXME add link.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the module_display_controller component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adaptor card) into the xCORE multicore microcontroller.

   #. Click on the ``Run`` icon (the white arrow in the green circle). 
   #. Wait until the images have loaded over the XTAG connector from the host.
   #. There should be a series of 6 images the transition from one to another.
    
