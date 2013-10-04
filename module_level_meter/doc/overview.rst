Overview
========

The level meter module is used to create a level meter display of a data array on LCD. The rendered image is stored in SDRAM.

Features
--------

  * Non-blocking SDRAM management.
  * Real time rendering.
  * Color selection for the display.
  * No real time constraints on the application.

Memory requirements
-------------------
+------------------+---------------+
| Resource         | Usage         |
+==================+===============+
| Data             |  1520 bytes   |
+------------------+---------------+
| Program          |  2160 bytes   |
+------------------+---------------+

Resource requirements
---------------------
+--------------+-------+
| Resource     | Usage |
+==============+=======+
| Channels     |   1   |
+--------------+-------+
| Timers       |   0   |
+--------------+-------+
| Clocks       |   0   |
+--------------+-------+
| Cores        |   1   |
+--------------+-------+


