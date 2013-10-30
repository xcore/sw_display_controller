#include <platform.h>
#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"
#include "transitions.h"
#include "loader.h"
#include "touch_controller_lib.h"
#include <print.h>


on tile[0] : lcd_ports lcdports = {
  XS1_PORT_1I, XS1_PORT_1L, XS1_PORT_16B, XS1_PORT_1J, XS1_PORT_1K, XS1_CLKBLK_1 };
on tile[0] : sdram_ports sdramports = {
  XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1G, XS1_PORT_1C, XS1_PORT_1F, XS1_CLKBLK_2 };
on tile[0] : touch_controller_ports touchports = {
		XS1_PORT_1E, XS1_PORT_1H, 1000, XS1_PORT_1D };


#define IMAGE_COUNT (6)
char images[IMAGE_COUNT][30] = { "audio2.tga", "audio.tga","audio3.tga",
		"deck.tga","sofas.tga","usb-chips.tga"};

static void load_image(chanend c_server, chanend c_loader, unsigned image_no) {
  unsigned buffer[LCD_ROW_WORDS];
  for (unsigned line = 0; line < LCD_HEIGHT; line++){
    for(unsigned i=0;i<LCD_ROW_WORDS*2;i++)
      c_loader :> (buffer, short[])[i];
	  image_write_line(c_server, line, image_no, buffer);
	  wait_until_idle(c_server, buffer);
  }
}

void app(chanend c_server, chanend c_loader){
  unsigned image[IMAGE_COUNT];
  unsigned fb_index = 0, frame_buffer[2];
  unsigned current_image=0;

  for(unsigned i=0;i<IMAGE_COUNT;i++){
    image[i] = register_image(c_server, LCD_ROW_WORDS, LCD_HEIGHT);
    load_image(c_server, c_loader, image[i]);
  }

  frame_buffer[0] = register_image(c_server, LCD_ROW_WORDS, LCD_HEIGHT);
  frame_buffer[1] = register_image(c_server, LCD_ROW_WORDS, LCD_HEIGHT);
  frame_buffer_init(c_server, image[0]);
  touch_lib_init(touchports);
  printstrln("****** Please touch any of the corners or the center of LCD screen ******");
  printstrln("******              to see different transition effects            ******");

  while(1){
    unsigned next_image = (current_image+1)%IMAGE_COUNT;
    unsigned x,y;

    touch_lib_req_next_coord(touchports,x,y);
    if (x<LCD_WIDTH/3 && y<LCD_HEIGHT/3){
    	fb_index = transition_slide(c_server, frame_buffer, image[current_image],
    			image[next_image],LCD_ROW_WORDS, fb_index);
    } else if (x>2*LCD_WIDTH/3 && y<LCD_HEIGHT/3){
    	fb_index = transition_dither(c_server, frame_buffer, image[current_image],
    			image[next_image], 256, fb_index);
    } else if (x>2*LCD_WIDTH/3 && y>2*LCD_HEIGHT/3){
    	fb_index = transition_wipe(c_server, frame_buffer, image[current_image],
    			image[next_image], LCD_ROW_WORDS, fb_index);
    } else if (x<LCD_WIDTH/3 && y>2*LCD_HEIGHT/3){
    	fb_index = transition_roll(c_server, frame_buffer, image[current_image],
    			image[next_image], LCD_ROW_WORDS, fb_index);
    } else if (x>LCD_WIDTH/3 && x<2*LCD_WIDTH/3 && y>LCD_HEIGHT/3 && y<2*LCD_HEIGHT/3){
    	fb_index = transition_alpha_blend(c_server, frame_buffer, image[current_image],
    			image[next_image], 64, fb_index);
    }
    current_image = next_image;
  }
}

int main() {
  chan c_sdram, c_lcd, c_client, c_loader;
  par {
	  on tile[0]:app(c_client, c_loader);
	  on tile[0]:display_controller(c_client, c_lcd, c_sdram);
	  on tile[0]:sdram_server(c_sdram, sdramports);
	  on tile[0]:lcd_server(c_lcd, lcdports);
	  on tile[1]:loader(c_loader, images, IMAGE_COUNT);
  }
  return 0;
}
