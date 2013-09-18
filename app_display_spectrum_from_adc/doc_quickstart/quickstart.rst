.. _Display_Spectrum_from_ADC_Quickstart:

Display Spectrum from ADC Quickstart Guide
==========================================

In this demonstration we use the following hardware and software:
  * XP-SKC-U16 Slicekit 
  * XA-SK-SCR480 Slice Card,
  * XA-SK-SDRAM Slice Card,
  * XA-SK-MIXED SIGNAL Slice Card,
  * module_level_meter,
  * module_fft_simple,
  * module_display_controller,
  * module_sdram,
  * module_lcd,
  * module_usb_tile_support,
  * module_logging,
  * module_xassert,

together to create a level-meter kind of spectral display on an LCD for an analog audio input. This application showcases the use of multichannel ADC in an xCORE-USB series XMOS device to sample the analog input, and real-time rendering and display of spectrum by taking short-time fourier transform.

Hardware Setup
++++++++++++++

The XP-SKC-U16 Slicekit Core board has four slots with edge connectors: ``DIAMOND``, ``SQUARE``, ``A`` and ``U``. 

To setup up the system:

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-U16 Slicekit Core board using the connector marked with ``SQUARE``.
   #. Connect XA-SK-SCR480 Slice Card with LCD to the XP-SKC-U16 Slicekit Core board using the connector marked with ``DIAMOND``.
   #. Connect XA-SK-MIXED SIGNAL Slice Card to the XP-SKC-U16 Slicekit Core board using the connector marked with ``A``.
   #. Give the two channels of audio input from a PC or a mobile to pins 1 and 2 of J2 on the mixed signal slice card using a suitable cable. The ground is connected to pin 4 of J3.
   #. Connect the XTAG-2 to Slicekit Core board. 
   #. Connect the XTAG-2 to host PC. Note that the USB cable is not provided with the Slicekit starter kit.
   #. Set the ``XMOS LINK`` to ``OFF`` on the Slicekit Core board.
   #. Ensure the jumper on the XA-SK-SCR480 is bridged if the back light is required.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup.jpg
   :width: 5cm
   :align: center

   Hardware Setup for Display Spectrum from ADC Demo
   
	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``Display Spectrum from ADC Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends to be imported as well. 
   #. Click on the ``app_display_spectrum_from_adc`` item in the Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.
   #. There will be quite a number of warnings that ``bidirectional buffered port not supported in hardware``. These can be safely ignored for this component.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. 

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2) into the xCORE multicore microcontroller.

   #. Select ``app_display_spectrum_from_adc`` project from the Project Explorer.
   #. Click on the ``Run`` icon (the white arrow in the green circle). 
   #. At the ``Select Device`` dialog select ``XMOS XTAG-2 connect to L1[0..1]`` and click ``OK``.
   #. Play an audio in the PC or mobile. A test audio file containing a sine sweep from 20 to 20kHz is available in ``app_display_spectrum_from_adc/test_data``.
   #. The spectra of segments of mixed signal of two audio channels are displayed on LCD. 
   #. Try changing the volume of the audio input and notice the change in the height of spectral components. 


Next Steps
++++++++++

Various parameters defined in ``app_display_spectrum_from_adc.xc`` are listed below. These can be adjusted if necessary. 

   #. ``SAMP_FREQ`` is the sampling frequency of the analog audio signal.
   #. ``FFT_POINTS`` give the number of signal samples taken for FFT computation. ``FFT_SINE`` is defined accordingly.
   #. ``LEV_METER_BANDS`` give the number of FFT points to be displayed.
   #. ``LOG_SPEC`` if set to 1 computes log spectrum.
   #. ``MAX_FFT`` sets the limit for the spectral values to be displayed. Values more than this limit are clipped.
   #. ``FFT_FULL_USE`` if set puts the FFT computation to full use. If it is 0, then ``FFT_UPDATE_RATE`` determines the number of times FFT computation is done in a second. 

The colors of the level-meter display of spectrum can be changed in ``level_meter_conf.h``.