#include <platform.h>
#include <print.h>
#include "sdram.h"
#include "sdram_internal.h"
/*
void sdram_refresh(chanend server, int ncycles)
{
  server <: (char)SDRAM_CMD_REFRESH;
  master {
    server <: ncycles;
  }
}
*/

void sdram_block_write(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, const unsigned buffer[])
{
  int pointer;
  asm("mov %0, %1" : "=r"(pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_BLOCK_WRITE;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: num_rows;
    server <: block_width_words;
    server <: pointer;
  }
}

void sdram_block_read(chanend server, int bank, int start_row, int start_col, int num_rows,
		int block_width_words, unsigned buffer[])
{
  int pointer;
  asm("mov %0, %1" : "=r"(pointer) : "r"(buffer));
  server <: (char)SDRAM_CMD_BLOCK_READ;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: num_rows;
    server <: block_width_words;
    server <: pointer;
  }
}

void sdram_line_read_blocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer)
{
  server <: (char)SDRAM_CMD_READ_LINE_BLOCKING;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer_pointer;
  }
  //TODO get the ack back
}

void sdram_line_read_nonblocking(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer)
{
  server <: (char)SDRAM_CMD_READ_LINE_NONBLOCKING;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer_pointer;
  }
}

void sdram_line_write(chanend server, int bank, int start_row, int start_col,
		int width_words, unsigned buffer_pointer)
{
  server <: (char)SDRAM_CMD_WRITE_LINE;
  master {
    server <: bank;
    server <: start_row;
    server <: start_col;
    server <: width_words;
    server <: buffer_pointer;
  }
}

void sdram_wait_until_idle(chanend server)
{
  server <: (char)SDRAM_CMD_WAIT_UNTIL_IDLE;
}
