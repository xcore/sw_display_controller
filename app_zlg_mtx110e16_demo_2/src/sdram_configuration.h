#ifndef _sdram_configuration_h_
#define _sdram_configuration_h_

/*
 * This header is SDRAM specific. It configures the geometry defines
 * and the configuration, including the control words.
 */

//Define the geometry of the SDRAM
#define SDRAM_COL_BITS (16)
#define SDRAM_ROW_LENGTH (256)
#define SDRAM_WORDS_PER_ROW (SDRAM_ROW_LENGTH_COLS/(32/SDRAM_BITS_PER_COL))
#define SDRAM_ROW_COUNT (2048)
#define SDRAM_BANK_COUNT 2

#define SDRAM_ROW_LENGTH_COLS SDRAM_ROW_LENGTH
#define SDRAM_BITS_PER_COL SDRAM_COL_BITS
#define SDRAM_ROW_WORDS SDRAM_WORDS_PER_ROW

#define XCORE_TIMER_TICKS_PER_MS 100000
#define SDRAM_REFRESH_MS 16
#define SDRAM_REFRESH_CYCLES 2048   //the count of refreshes per SDRAM_REFRESH_MS milliseconds

//Define the configuration of the SDRAM
#define SDRAM_MODE_REGISTER 0x0027 //CAS 2

/* ctrl word
 *
 * 4bit port                                 BURST                   LOAD
 *    offset  signal  NOP  ACTIVE WRITE READ TERM  REFRESH PRECHARGE MODEREG
 *         0  CS      0    0      0     0    0     0       0         0
 *         1  WE      1    1      0     1    0     1       0         0
 *         2  CAS     1    1      0     0    1     0       1         0
 *         3  RAS     1    0      1     1    1     0       0         0
 *                    0xE  0x6    0x8   0xA  0xC   0x2     0x4       0x0
*/
#define CTRL_NOP              0xE
#define CTRL_ACTIVE           0x6
#define CTRL_WRITE            0x8
#define CTRL_READ             0xA
#define CTRL_BURST_TERMINATE  0xC
#define CTRL_REFRESH          0x2
#define CTRL_PRECHARGE        0x4
#define CTRL_LOAD_MODEREG     0x0

#endif
