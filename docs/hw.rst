H/W Development Platforms
=========================

Both the components graphics LCD and SDRAM need separate hardware modules for testing.
Hence the project cannot be run on any XMOS specific kits available currently. The project was developed on the hardware provided by the customer. 
The supplied hardware looks like as shown in the below figure.

.. only:: html

  .. figure:: images/custHw.png
     :align: center

     Customer Hardware used for testing

.. only:: latex

  .. figure:: images/custHw.pdf
     :figwidth: 50%
     :align: center

     Customer Hardware used for testing

The supplied hardware includes the graphics LCD module (part number: TM04NDH02) and the SDRAM module (part number : IS42S16100F-7TLI).
In order to run the code, separate hardware (similar to one shown above) with LCD and SDRAM should be designed.