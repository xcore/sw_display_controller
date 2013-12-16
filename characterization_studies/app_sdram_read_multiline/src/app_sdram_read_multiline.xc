/*****************************************************************
Program: SDRAM multiline read performance
 Output: Transfer rate (MB/s) for different transfer size (words)
*****************************************************************/

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "sdram.h"

#define TIME_PERIOD  100000000

on tile[0]: sdram_ports ports = {	// SDRAM slice to STAR slot
    XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_1 };

void application(chanend c_server) {
	  unsigned buffer[SDRAM_ROW_WORDS];
	  unsigned tr_rate[SDRAM_ROW_WORDS];
	  float tr_rateMB;
	  unsigned bank = 0, row = 0, col = 0;
	  timer t;
	  unsigned t1,t2;

      // Time computation for reading words of different size in one row
      for(unsigned n=1;n<=SDRAM_ROW_WORDS;n++){
    	  unsigned running  = 1;
    	  unsigned bytes_transfered = 0;
    	  col = SDRAM_ROW_WORDS*2 - 1;
          t:> t1;
          sdram_buffer_read(c_server, bank, row, col, n, buffer);

          while(running){
        	  select {
                	case t when timerafter(t1 + TIME_PERIOD) :> t2:
                		sdram_wait_until_idle(c_server, buffer);
                        running =0;
                    break;
                    default:
                    	sdram_wait_until_idle(c_server, buffer);
                        bytes_transfered += n*4;
                        sdram_buffer_read(c_server, bank, row, col, n, buffer);
                    break;
        	  }
          }

          tr_rate[n-1] = bytes_transfered;
      }

	  for(unsigned n=1;n<=SDRAM_ROW_WORDS;n++){
		  tr_rateMB = tr_rate[n-1]/1048576.0;
		  printf("%.2f\n",tr_rateMB);
	  }

}


int main() {
  chan sdram_c;

  par {
    on tile[0]:sdram_server(sdram_c, ports);
    on tile[0]:application(sdram_c);
    on tile[0]:par (int i=0; i<6; i++) while(1);
  }

  return 0;
}

