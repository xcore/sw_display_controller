#ifndef _sdram_h_
#define _sdram_h_

#include <platform.h>

/* application header */
#include "sdram_configuration.h"

/* ctrl word shorthands */
#define CTRL_NOP_8X (CTRL_NOP_4X | (CTRL_NOP_4X << 16))
#define CTRL_NOP_7X (CTRL_NOP_4X | (CTRL_NOP_3X << 16))
#define CTRL_NOP_4X (CTRL_NOP_2X | (CTRL_NOP_2X << 8))
#define CTRL_NOP_3X (CTRL_NOP | (CTRL_NOP_2X << 4))
#define CTRL_NOP_2X (CTRL_NOP | (CTRL_NOP << 4))

#ifndef TIMER_TICKS_PER_US
#define TIMER_TICKS_PER_US 100
#endif

/** Structure containing the resources required for the SDRAM  ports interface.
 *
 * It consists of 32 bit address line, Control lines, Clock line,
 * Clock enable line, Data lines
 * The variable of this structure type should be configured in the application project
 * and passed as a parameter to the thread sdram_server
 *
 **/
struct sdram_ports
{
  port dq;
  out buffered port:32 a0;
  out buffered port:32 ctrl;
  out port clk;
  out buffered port:4 dqm0;
  out buffered port:4 dqm1;
  out port cke;
  clock cb;
};
/** \brief The SDRAM thread. The thread is invoked in the lcd_sdram_manager
* 
* \param client_hip The channel end number
* \param ports The structure carrying the SDRAM port details
*/
void sdram_server(chanend client_hip, struct sdram_ports &ports);

void sdram_block_write(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, const unsigned buffer[]);

void sdram_block_read(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, unsigned buffer[]);

void sdram_wait_until_idle(chanend server);

void sdram_line_read_blocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);

void sdram_line_read_nonblocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);

void sdram_line_write(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer);

#endif
