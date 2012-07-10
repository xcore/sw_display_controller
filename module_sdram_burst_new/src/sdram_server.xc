#include <platform.h>
#include "sdram.h"
#include "sdram_internal.h"

/*
 * This file define the SDRAM interface. It is chip independant.
 */

extern void init(struct sdram_ports &p);
extern void write_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports);
extern void read_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports);

static inline void refresh(int ncycles, struct sdram_ports &p) {
  for (int i = 0; i < ncycles; i += 2) {
    //TODO extract this info into the config header
    /* datasheet requires at least tRFC between consecutive refreshes
     * tRFC = 60ns = 3 cycles
     * so for each 2 refreshes, we do: REF NOP NOP NOP REF NOP NOP NOP
     */
    p.ctrl <: CTRL_REFRESH | (CTRL_NOP_3X << 4) | (CTRL_REFRESH << 16) | (CTRL_NOP_3X << 20);
  }
  partout(p.ctrl, 4, CTRL_NOP);
}

static inline void write_rows(unsigned start_row, unsigned start_col,
    unsigned row_count, unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  for (unsigned row = start_row; row < start_row + row_count; row++) {
    write_row(row, start_col, bank, buffer, word_count, ports);
    buffer += word_count * 4;
  }
}

static inline void read_rows(unsigned start_row, unsigned start_col,
    unsigned row_count, unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  for (unsigned row = start_row; row < start_row + row_count; row++) {
    read_row(row, start_col, bank, buffer, word_count, ports);
    buffer += word_count * 4;
  }
}

#pragma unsafe arrays
static inline void read_line(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row, remaining_words =
      word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_ROW_LENGTH - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      unsigned adjusted_col;
      if (current_col) {
        adjusted_col = current_col - 1;
      } else {
        adjusted_col = (SDRAM_ROW_LENGTH - 1);
      }
      read_row(current_row, adjusted_col, bank, buffer, words_to_end_of_line,
          ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      unsigned adjusted_col;
      if (current_col) {
        adjusted_col = current_col - 1;
      } else {
        adjusted_col = (SDRAM_ROW_LENGTH - 1);
      }
      read_row(current_row, adjusted_col, bank, buffer, remaining_words, ports);
      return;
    }
  }
}

#pragma unsafe arrays
static inline void write_line(unsigned start_row, unsigned start_col,
    unsigned bank, unsigned buffer, unsigned word_count,
    struct sdram_ports &ports) {
  unsigned words_to_end_of_line;
  unsigned current_col = start_col, current_row = start_row, remaining_words =
      word_count;

  while (1) {
    words_to_end_of_line = (SDRAM_ROW_LENGTH - current_col) / 2;
    if (words_to_end_of_line < remaining_words) {
      unsigned adjusted_col;
      if (current_col) {
        adjusted_col = current_col - 1;
      } else {
        adjusted_col = (SDRAM_ROW_LENGTH - 1);
      }
      write_row(current_row, adjusted_col, bank, buffer, words_to_end_of_line,
          ports);
      current_col = 0;
      current_row++;
      buffer += 4 * words_to_end_of_line;
      remaining_words -= words_to_end_of_line;
    } else {
      unsigned adjusted_col;
      if (current_col) {
        adjusted_col = current_col - 1;
      } else {
        adjusted_col = (SDRAM_ROW_LENGTH - 1);
      }
      write_row(current_row, adjusted_col, bank, buffer, remaining_words, ports);
      return;
    }
  }
}

static void handle_command(char cmd, chanend client, struct sdram_ports &ports) {
  switch (cmd) {
#ifdef SDRAM_CMD_BLOCK_WRITE
    case SDRAM_CMD_BLOCK_WRITE: {
      int bank, start_row, start_col, num_rows, block_width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> num_rows;
        client :> block_width_words;
        client :> pointer;
      }
      write_rows(start_row, start_col, num_rows, bank, pointer, block_width_words, ports);
      break;
    }
#endif
#ifdef SDRAM_CMD_BLOCK_READ
    case SDRAM_CMD_BLOCK_READ: {
      int bank, start_row, start_col, num_rows, block_width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> num_rows;
        client :> block_width_words;
        client :> pointer;
      }
      read_rows(start_row, start_col, num_rows, bank, pointer, block_width_words, ports);
      break;
    }
#endif
#ifdef SDRAM_CMD_READ_LINE_BLOCKING
    case SDRAM_CMD_READ_LINE_BLOCKING: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> width_words;
        client :> pointer;
      }
      read_line(start_row, start_col, bank, pointer, width_words, ports);
      client <: 0;
      break;
    }
#endif
#ifdef SDRAM_CMD_READ_LINE_NONBLOCKING
    case SDRAM_CMD_READ_LINE_NONBLOCKING: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> width_words;
        client :> pointer;
      }
      read_line(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#ifdef SDRAM_CMD_WRITE_LINE
    case SDRAM_CMD_WRITE_LINE: {
      unsigned bank, start_row, start_col, width_words, pointer;
      slave {
        client :> bank;
        client :> start_row;
        client :> start_col;
        client :> width_words;
        client :> pointer;
      }
      write_line(start_row, start_col, bank, pointer, width_words, ports);
      break;
    }
#endif
#ifdef SDRAM_CMD_WAIT_UNTIL_IDLE
    case SDRAM_CMD_WAIT_UNTIL_IDLE: {
      break;
    }
#endif
  }
}

void sdram_server(chanend client, struct sdram_ports &ports) {
  timer t;
  unsigned T, now;
  init(ports);
  refresh(SDRAM_REFRESH_CYCLES, ports);
  t:> T;
  T += XCORE_TIMER_TICKS_PER_MS*SDRAM_REFRESH_MS/2;
  while (1) {
#pragma ordered
    select {
      case t when timerafter(T) :> now: {
        unsigned elapsed_timer_ms = (now - T)/XCORE_TIMER_TICKS_PER_MS+1;
        unsigned num_refreshes = SDRAM_REFRESH_CYCLES * elapsed_timer_ms / SDRAM_REFRESH_MS+1;
        refresh(num_refreshes, ports);
        T = now;
        T += XCORE_TIMER_TICKS_PER_MS*SDRAM_REFRESH_MS/8;
        break;
      }
      case client :> char cmd: {
        handle_command(cmd, client, ports);
        client <: 0;
        break;
      }
    }
  }
}
