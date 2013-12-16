#include <platform.h>
#include <xs1.h>
#include "lcd.h"
#include <print.h>
#include <stdlib.h>
#include <assert.h>


#define LDW(dst, mem, ind) asm("ldw %0, %1[%2]" : "=r"(dst) : "r"(mem), "r"(ind))

void lcd_init(chanend c_lcd) {
  outct(c_lcd, XS1_CT_END);
}

#pragma select handler
void get_ptr (chanend c_lcd, unsigned &ptr)
{
  ptr = inuint(c_lcd);
}


#pragma unsafe arrays
void lcd_server(chanend c_lcd) {


  chkct(c_lcd, XS1_CT_END);
  outct(c_lcd, XS1_CT_END);


  while (1) {
    timer t;
    unsigned time;
    unsigned ptr;
    unsigned x;

    t :> time;

    for (unsigned i = 0; i < LCD_VERT_PULSE_WIDTH; i++) {

      time += LCD_HSYNC_TIME*LCD_FREQ_DIVISOR;
    }

      time += LCD_HSYNC_TIME*(LCD_VERT_BACK_PORCH - LCD_VERT_PULSE_WIDTH)*LCD_FREQ_DIVISOR;


    for (int y = 0; y < LCD_HEIGHT; y++)
    {

      time += LCD_HOR_BACK_PORCH*LCD_FREQ_DIVISOR;

      select {
    	  case get_ptr(c_lcd, ptr):     // Get line buffer pointer
   		  break;
    	  case t when timerafter(time) :> void:
    		  printstrln("Data not available at right time\n");
    		  assert(0);
    	  break;
      }

      chkct(c_lcd, XS1_CT_END);


	  LDW(x, ptr, 0);

	  time += LCD_WIDTH*LCD_FREQ_DIVISOR;

	  for (unsigned i = 1; i < LCD_ROW_WORDS; i++) {
		LDW(x, ptr, i);
	  }

	  outct(c_lcd, XS1_CT_END);
      time += LCD_HOR_FRONT_PORCH*LCD_FREQ_DIVISOR;
    }

    for(unsigned i=0;i<LCD_VERT_FRONT_PORCH;i++) {
      time += LCD_HSYNC_TIME*LCD_FREQ_DIVISOR;
    }
  }
}
