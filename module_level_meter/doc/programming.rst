Programming Guide
=================

This section provides information on how to create an application using ``level_meter`` API.

Includes and Configuration
--------------------------

The application needs to include ``level_meter.h``. A configuration file ``level_meter_conf.h`` should be placed in the application directory. The color palette for the level meter display is defined in the configuration file.

Programming
-----------

The level meter module uses the APIs of display controller module. A simple application function that uses ``level_meter`` API is given below.

::

  void app(c_dc, data, N)
  {
    unsigned frBuf;

    // Create frame buffer
    frBuf = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);

    // Render level meter display frame and commit
    level_meter(c_dc, frBuf, data, N);
    display_controller_frame_buffer_commit(c_dc, frBuf);
  }

``c_dc`` is the channel connecting display controller. ``data`` is the array of unsigned data values to be displayed. ``N`` is the number of data values.