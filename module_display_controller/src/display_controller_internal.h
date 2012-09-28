#ifndef _display_controller_internal_h_
#define _display_controller_internal_h_

#ifdef __display_controller_conf_h_exists__
#include "display_controller_conf.h" // This is from the application
#endif

/*
 * This defines the storage space allocated to the display controller
 * for it to store image metadata. When an image is registered with the
 * display controller its dimensions and location in SDRAM address
 * space are storred in a table. The define specifice how any entries
 * are allowed in that table. Note, there is no overflow checking by default.
 */
#ifndef DISPLAY_CONTROLLER_VERBOSE
#define DISPLAY_CONTROLLER_VERBOSE 0
#endif

/*
 * This define switchs on the error checking for memory overflows and
 * causes verbose error warnings to be emitted in the event of an error.
 */
#ifndef DISPLAY_CONTROLLER_MAX_IMAGES
#define DISPLAY_CONTROLLER_MAX_IMAGES 20
#endif

enum Server_Command {
  CMD_WRITE_LINE,
  CMD_READ_LINE,
  CMD_READ_PARTIAL_LINE,
  CMD_SDRAM_WAIT_UNTIL_IDLE,
  CMD_SET_FRAME_BUFFER,
  CMD_INIT_FRAME_BUFFER,
  CMD_REGISTER_IMAGE
};

#endif
