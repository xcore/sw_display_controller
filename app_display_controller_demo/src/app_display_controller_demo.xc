#include <platform.h>
#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"
#include "transitions.h"
#include <stdio.h>
#include "loader.h"

lcd_ports lcdports = {
  XS1_PORT_1G, XS1_PORT_1F, XS1_PORT_16A, XS1_PORT_1B, XS1_PORT_1C, XS1_CLKBLK_1 };
sdram_ports sdramports = {
  XS1_PORT_16B, XS1_PORT_1J, XS1_PORT_1I, XS1_PORT_1K, XS1_PORT_1L, XS1_CLKBLK_2 };

#define IMAGE_COUNT (6)
char images[IMAGE_COUNT][30] = { "audio2.tga", "audio.tga","audio3.tga","deck.tga","sofas.tga","usb-chips.tga"};

on stdcore[0]:out port p = XS1_PORT_8D;

static void disable_flash(){
  p <:0x80;
  p <:0xc0;
  p <:0x80;
  set_port_use_off(p);
}

static void load_image(chanend c_server, chanend c_loader, unsigned image_no) {
  unsigned buffer[LCD_ROW_WORDS];
  for (unsigned line = 0; line < LCD_HEIGHT; line++){
    for(unsigned i=0;i<LCD_ROW_WORDS*2;i++)
      c_loader :> (buffer, short[])[i];
	  image_write_line(c_server, line, image_no, buffer);
	  wait_until_idle(c_server, buffer);
  }
}

void app(chanend server, chanend c_loader){
  unsigned image[IMAGE_COUNT];
  unsigned fb_index = 0, frame_buffer[2];
  unsigned current_image=0;

  disable_flash();
  for(unsigned i=0;i<IMAGE_COUNT;i++){
    image[i] = register_image(server, LCD_ROW_WORDS, LCD_HEIGHT);
    load_image(server, c_loader, image[i]);
  }
  frame_buffer[0] = register_image(server, LCD_ROW_WORDS, LCD_HEIGHT);
  frame_buffer[1] = register_image(server, LCD_ROW_WORDS, LCD_HEIGHT);
  frame_buffer_init(server, image[0]);

  while(1){
    unsigned next_image = (current_image+1)%IMAGE_COUNT;
    fb_index = transition_slide(server, frame_buffer, image[current_image], image[next_image],LCD_ROW_WORDS, fb_index);
    current_image = next_image;
    next_image = (current_image+1)%IMAGE_COUNT;
    fb_index = transition_dither(server, frame_buffer, image[current_image], image[next_image], 256, fb_index);
    current_image = next_image;
    next_image = (current_image+1)%IMAGE_COUNT;
    fb_index = transition_wipe(server, frame_buffer, image[current_image], image[next_image], LCD_ROW_WORDS, fb_index);
    current_image = next_image;
    next_image = (current_image+1)%IMAGE_COUNT;
    fb_index = transition_roll(server, frame_buffer, image[current_image], image[next_image], LCD_ROW_WORDS, fb_index);
    current_image = next_image;
    next_image = (current_image+1)%IMAGE_COUNT;
    fb_index = transition_alpha_blend(server, frame_buffer, image[current_image], image[next_image], 64, fb_index);
    current_image = next_image;
    next_image = (current_image+1)%IMAGE_COUNT;
  }
}

int main() {
  chan c_sdram, c_lcd, client, c_loader;
  par {
	  on stdcore[0]:app(client, c_loader);
	  on stdcore[0]:display_controller(client, c_lcd, c_sdram);
	  on stdcore[0]:sdram_server(c_sdram, sdramports);
	  on stdcore[0]:lcd_server(c_lcd, lcdports);
	  on stdcore[0]:par(int i=0;i<4;i++) while(1);
	  on stdcore[1]:loader(c_loader, images, IMAGE_COUNT);
  }
  return 0;
}
