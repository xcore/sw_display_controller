#include "display_controller.h"
#include "lcd.h"
#include "level_meter.h"

#include <stdio.h>	// TODO: remove later

void level_meter(chanend c_dc, unsigned frBufNo, unsigned data[], unsigned N, unsigned maxData)
{
	unsigned buf[LCD_ROW_WORDS];
	unsigned short color;

	// Clip data values
	if (maxData==0) maxData = 1; 	// To avoid div by 0
	for (int i=0; i<N; i++)
		if (data[i]>maxData) data[i] = maxData;

	// Init row buffer
	for (int i=0; i<LCD_ROW_WORDS; i++)
		buf[i] = 0;

	// Find pixel values for level meter display
	for (unsigned r=0; r<LCD_HEIGHT; r++) {

		// Get the color for this row
		if (r<LCD_HEIGHT/4) color = RED;
		else if (r<LCD_HEIGHT/2) color = YELLOW;
		else if (r<LCD_HEIGHT*3/4) color = GREEN;
		else color = BLUE;

		for (unsigned c=0; c<LCD_WIDTH; c++){
			int dataIndex = c*N/LCD_WIDTH;
			int dataHeight = data[dataIndex]*(LCD_HEIGHT-1)/maxData;
			if (r>=((LCD_HEIGHT-1)-dataHeight)) (buf, unsigned short[])[c] = color;
		}

		display_controller_image_write_line(c_dc, r, frBufNo, buf);
		display_controller_wait_until_idle(c_dc, buf);

	}

}
