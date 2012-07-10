#include "sdram.h"

/*
 * This define all the methods that are chip specific.
 */

void init(struct sdram_ports &p) {
  timer T;
  int t;

  asm("setc res[%0], 0x200F" :: "r"(p.dq));
  asm("settw res[%0], %1" :: "r"(p.dq), "r"(32));

  p.cke <: 0;
  p.ctrl <: CTRL_NOP_8X;

  set_clock_div(p.cb, 1);
  set_port_clock(p.clk, p.cb);
  set_port_mode_clock(p.clk);

  set_port_clock(p.dq, p.cb);
  set_port_clock(p.ctrl, p.cb);
  set_port_clock(p.dqm0, p.cb);
  set_port_clock(p.dqm1, p.cb);
  set_port_clock(p.a0, p.cb);

  set_pad_delay(p.dq,0);

  start_clock(p.cb);

  p.dqm0 <: 0x0;
  p.dqm1 <: 0x0;

  T :> t;
  T when timerafter(t + 50 * TIMER_TICKS_PER_US) :> t;

  p.ctrl <: CTRL_NOP_8X;
  p.cke <: 1;

  T when timerafter(t + 100 * TIMER_TICKS_PER_US) :> t;

  p.dq <: 0x04DB04DB;
  sync(p.dq);
  p.ctrl <: (CTRL_REFRESH | (CTRL_NOP_7X << 4));
  p.ctrl <: (CTRL_PRECHARGE | (CTRL_NOP_7X << 4));
  p.ctrl <: (CTRL_REFRESH | (CTRL_NOP_7X << 4));
  p.ctrl <: (CTRL_REFRESH | (CTRL_NOP_7X << 4));
  p.ctrl <: (CTRL_REFRESH | (CTRL_NOP_7X << 4));
  sync(p.ctrl);

  // mode register
  partout(p.a0, 1, SDRAM_MODE_REGISTER);
  p.dq <: (SDRAM_MODE_REGISTER << 16)|SDRAM_MODE_REGISTER;
  sync(p.dq);
  sync(p.a0);
  p.ctrl <: CTRL_NOP_8X;
  p.ctrl <: CTRL_NOP_8X;
  p.ctrl <: (CTRL_LOAD_MODEREG | (CTRL_NOP_7X << 4));
  p.ctrl <: CTRL_NOP_8X;
  p.ctrl <: CTRL_NOP_8X;
  p.ctrl <: CTRL_NOP_8X;
}

void block_write(unsigned buffer, unsigned word_count, out port dq,
    out buffered port:32 ctrl, unsigned term_time);
void block_read(unsigned buffer, unsigned word_count, out port dq,
    out buffered port:32 ctrl, unsigned term_time, unsigned st);
void short_block_read(unsigned buffer, unsigned word_count, out port dq,
    out buffered port:32 ctrl, unsigned term_time, unsigned st);

//this can come down as the asm gets faster TODO
#define WRITE_SETUP_LATENCY (50)
#define READ_SETUP_LATENCY (50)

static const unsigned bt[2] = { 0, (1 << 11) | (1 << (11 + 16)) };

#pragma unsafe arrays
void write_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports) {
  unsigned t;
  unsigned stop_time;
  unsigned jump;
  unsigned a0rc;
  unsigned rowcol;

  if (col) {
    col = col - 1;
  } else {
    col = (SDRAM_ROW_LENGTH - 1);
  }

  a0rc = ((col) << 1) | (row & 1);

  rowcol = bt[bank] | (col << 16) | row;

  //adjust the buffer
  buffer -= 4 * (SDRAM_ROW_WORDS - word_count);
  jump = 2 * (SDRAM_ROW_WORDS - word_count);

  t = partout_timestamped(ports.dqm1, 1, 0);

  t += WRITE_SETUP_LATENCY;
  stop_time = t + (word_count << 1) + 2;

  ports.a0 @ t <: a0rc;

  ports.dq @ t<: rowcol;

  ports.ctrl @ t <: (CTRL_ACTIVE) | (CTRL_WRITE << 4) | (CTRL_NOP << 8) |
  (CTRL_NOP << 12) | (CTRL_NOP_4X << 16);

  ports.dqm0 @ t <: 0x2;
  ports.dqm1 @ t <: 0x2;

  block_write(buffer, jump, ports.dq, ports.ctrl, stop_time);

}

#pragma unsafe arrays
void read_row(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports &ports) {
  unsigned t;
  unsigned stop_time;
  unsigned jump;
  unsigned rowcol;
  unsigned a0rc;

  if (col) {
    col = col - 1;
  } else {
    col = (SDRAM_ROW_LENGTH - 1);
  }

  rowcol = bt[bank] | (col << 16) | row;

  a0rc = ((col) << 1) | (row & 1);

  if (word_count < 4) {

    t = partout_timestamped(ports.dqm1, 1, 0);
    t += READ_SETUP_LATENCY;
    stop_time = t + (4 << 1) + 4;

    ports.a0 @ t <: a0rc;
    ports.dq @ t <: rowcol;
    ports.ctrl @ t <: (CTRL_ACTIVE) | (CTRL_READ << 4) | (CTRL_NOP << 8) |
    (CTRL_NOP << 12) | (CTRL_NOP_4X << 16);

    short_block_read(buffer, word_count, ports.dq, ports.ctrl, stop_time, t+3);

  } else {

    //adjust the buffer
    buffer -= 4 * (0x3f&(SDRAM_ROW_WORDS - word_count));
    jump = 2 * (SDRAM_ROW_WORDS - word_count);

    t = partout_timestamped(ports.dqm1, 1, 0);
    t+= READ_SETUP_LATENCY;
    stop_time = t + (word_count<<1)+4;

    ports.a0 @ t <: a0rc;
    ports.dq @ t <: rowcol;
    ports.ctrl @ t <: (CTRL_ACTIVE) | (CTRL_READ << 4) | (CTRL_NOP << 8) |
    (CTRL_NOP << 12) | (CTRL_NOP_4X << 16);

    block_read(buffer, jump, ports.dq, ports.ctrl, stop_time, t+3);
  }
}
