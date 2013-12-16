#include <platform.h>
#include <print.h>

#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"

on tile[0] : sdram_ports sdramports = {
  XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_2 };

void create_frame(chanend c_dc, unsigned frBufNo){
	unsigned buf[LCD_ROW_WORDS];

	for (int i=0; i<LCD_ROW_WORDS; i++)
		buf[i]=0;

	for (unsigned r=0; r<LCD_HEIGHT; r++){
		display_controller_image_write_line(c_dc,r,frBufNo,buf);
		display_controller_wait_until_idle(c_dc,buf);
	}
}


#define ONE_SEC 100000000
void app(chanend c_dc) {
	  unsigned frBufIndex=0, frBuf[2], frames=0;
	  timer t;
	  unsigned t1,run=1;

	  // Create frame buffers
	  frBuf[0] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
	  frBuf[1] = display_controller_register_image(c_dc, LCD_ROW_WORDS, LCD_HEIGHT);
	  display_controller_frame_buffer_init(c_dc, frBuf[0]);


	  t :> t1;
	  while (run){
		  frBufIndex = 1-frBufIndex;
		  create_frame(c_dc,frBuf[frBufIndex]);		// same result obtained for with and without creating new frame

		  select{
			  case t when timerafter(t1+ONE_SEC) :> void:
			  	  run = 0;
			  break;
			  default:
				  display_controller_frame_buffer_commit(c_dc,frBuf[frBufIndex]);
				  frames++;
			  break;
		  }
	  }

/*    Observation: Printing disrupts the data availability to LCD. Uncomment to print the frame rate.
	  printstr("Max frame rate: ");
	  printuint(frames);
	  printstrln(" fps");
*/

}


int main(){
	chan c_dc, c_lcd, c_sdram;

    par {
		on tile[0]: app(c_dc);
		on tile[0]: display_controller(c_dc,c_lcd,c_sdram);
		on tile[0]: lcd_server(c_lcd);
		on tile[0]: sdram_server(c_sdram,sdramports);
	}

    return 0;
}
