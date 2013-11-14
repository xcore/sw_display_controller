Example Application
===================

This tutorial describes the demo applications that uses the level meter module. Section :ref:`sec_hardware` describes the required hardware setup to run the demos.

app_display_spectrum_demo
-------------------------

This application uses display controller and other modules to create a level-meter kind of spectral display on an LCD for a simulated signal. This application demonstrates real-time rendering and display of spectrum by taking short-time fourier transform.

Getting Started
+++++++++++++++

   #. Connect XA-SK-SDRAM Slice Card to the XP-SKC-L16 sliceKIT core board using the connector marked with ``STAR``.
   #. Connect XA-SK-SCR480 Slice Card with LCD to the XP-SKC-L16 sliceKIT core board using the connector marked with ``TRIANGLE``.
   #. Select ``app_display_spectrum_demo``. Build the project and run.

The spectra of segments of mixed signal of two simulated chirp waveforms are displayed on LCD. 

