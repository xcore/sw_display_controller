#ifndef _sdram_internal_h_
#define _sdram_internal_h_

/* This list is application specific. Remove any of the commands
 * that are unused and the code will be eliminated from the
 * command handler.
 */

#define SDRAM_CMD_REFRESH                 1
#define SDRAM_CMD_WAIT_UNTIL_IDLE         2
#define SDRAM_CMD_BLOCK_WRITE             3
#define SDRAM_CMD_BLOCK_READ              4
#define SDRAM_CMD_READ_LINE_BLOCKING      5
#define SDRAM_CMD_READ_LINE_NONBLOCKING	  6
#define SDRAM_CMD_WRITE_LINE           	  7

#endif
