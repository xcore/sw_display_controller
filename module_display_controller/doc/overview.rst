Overview
========

The display controller module is used to drive a single graphics LCD screen up to 800 * 600 pixels incorporating a managed double buffer. 

Features
--------

  * Non-blocking SDRAM management.
  * Real time servicing of the LCD.
  * Touch interactive display
  * Image memory manager to simplify handling of images.
  * No real time constraints on the application.

Memory requirements
-------------------
+------------------+---------------+
| Resource         | Usage         |
+==================+===============+
| Stack            | 6198 bytes    |
+------------------+---------------+
| Program          | 11306 bytes   |
+------------------+---------------+

Resource requirements
---------------------
+--------------+-------+
| Resource     | Usage |
+==============+=======+
| Channels     |   3   |
+--------------+-------+
| Timers       |   0   |
+--------------+-------+
| Clocks       |   0   |
+--------------+-------+
| Threads      |   1   |
+--------------+-------+

Performance
----------- 

The achievable effective bandwidth varies according to the available xCORE MIPS. The maximum pixel clock supported is 25MHz.

