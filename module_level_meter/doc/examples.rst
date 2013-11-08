Example Applications
====================

This tutorial describes the demo applications that uses the level meter module. Section :ref:`sec_hardware` describes the required hardware setup to run the demos.

app_display_spectrum
--------------------

This application uses display controller and other modules to create a level-meter kind of spectral display on an LCD for a simulated signal. This application demonstrates real-time rendering and display of spectrum by taking short-time fourier transform.

Getting Started
+++++++++++++++

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-U16 Slicekit Core board using the connector marked with ``SQUARE``.
   #. Connect XA-SK-SCR480 Slice Card with LCD to the XP-SKC-U16 Slicekit Core board using the connector marked with ``DIAMOND``.
   #. Select ``app_display_spectrum``. Build the project and run.

The spectra of segments of mixed signal of two simulated chirp waveforms are displayed on LCD. 

app_display_spectrum_from_adc
-----------------------------

This application uses ``module_usb_tile_support`` along with display controller and other modules to create a level-meter kind of spectral display on an LCD for an analog audio input. This application showcases the use of multichannel ADC in an xCORE-USB series XMOS device to sample the analog input and real-time rendering and display of spectrum by taking short-time fourier transform.

Getting Started
+++++++++++++++

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-U16 Slicekit Core board using the connector marked with ``SQUARE``.
   #. Connect XA-SK-SCR480 Slice Card with LCD to the XP-SKC-U16 Slicekit Core board using the connector marked with ``DIAMOND``.
   #. Connect XA-SK-MIXED SIGNAL Slice Card to the XP-SKC-U16 Slicekit Core board using the connector marked with ``A``.
   #. Give the two channels of audio input from a PC or a mobile to pins 1 and 2 of J2 on the mixed signal slice card using a suitable cable. The ground is connected to pin 4 of J3.
   #. Select ``app_display_spectrum_from_adc``. Build the project and run.
   #. Play an audio in the PC or mobile. 

The spectra of segments of mixed signal of two audio channels are displayed on LCD. 
   