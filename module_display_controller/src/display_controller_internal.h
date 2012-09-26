#ifndef _display_controller_internal_h_
#define _display_controller_internal_h_

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
