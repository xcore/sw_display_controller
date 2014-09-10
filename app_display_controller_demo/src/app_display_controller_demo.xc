#include <platform.h>
#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"

#include "sdram_slicekit_support.h"
#include "lcd_slicekit_support.h"


#define IMAGE_COUNT (8)
static const unsigned short colour[IMAGE_COUNT] = {0, 0x07e0, 0x001f, 0x07ff,
        0xffff, 0xffe0, 0xf800, 0xf81f};

#include <stdio.h>

void load_image(client interface app_to_cmd_buffer_i to_dc, client interface res_buf_to_app_i from_dc,
        unsigned image_handle, unsigned short c){

    unsigned buffer[LCD_ROW_WORDS];
    unsigned * movable buffer_pointer = buffer;

    unsigned colour = c&0xffff;
    colour = colour | (colour << 16);

    for(unsigned w=0;w<LCD_ROW_WORDS;w++)
        buffer_pointer[w] = colour;

    for(unsigned l = 0; l< LCD_HEIGHT;l++){
        display_controller_write(to_dc, move(buffer_pointer), image_handle, l, LCD_ROW_WORDS, 0);
        unsigned r;
        {buffer_pointer, r} = from_dc.pop();
    }
}
//Refresh rate: 36.15Hz
//Avaliable read/write bandwidth: 56.35 frames per second
unsigned short fade(unsigned i){
    i=i&0xff;
    //blue green red
    if(i < 64){
        return 0x001f + (i << 5);
    } else if(i < 96){
        return 0x07ff - (i);
    } else if(i < 128){
        return 0x07e0 + (i << (5+6));
    } else if(i < 192){
        return 0xffe0 - (i << (5));
    } else if(i < 224){
        return 0xf800 + (i);
    } else {
        return 0xf81f - (i << (5+6));
    }
}


void app(client interface app_to_cmd_buffer_i to_dc, client interface res_buf_to_app_i from_dc,
        client interface dc_vsync_interface_i vsync_interface){

    unsigned current_image=0;
    for(unsigned i=1;i<IMAGE_COUNT;i++)
        load_image(to_dc, from_dc, i, colour[i]);

    unsigned i=0;
    display_controller_frame_buffer_commit(to_dc, current_image);
    while(1){
        unsigned next_image = (current_image+1)%IMAGE_COUNT;
        vsync_interface.vsync();
        load_image(to_dc, from_dc, next_image, fade(i));
        i++;
        display_controller_frame_buffer_commit(to_dc, next_image);
        current_image = next_image;
    }
}

on tile[LCD_A16_CIRCLE_TILE]: lcd_ports lcdports = LCD_A16_CIRCLE_PORTS(XS1_CLKBLK_1);
on tile[SDRAM_A16_SQUARE_TILE]: sdram_ports sdramports = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_2);

int main() {
  interface app_to_cmd_buffer_i     app_to_cmd_buffer;
  interface cmd_buffer_to_dc_i      cmd_buffer_to_dc;

  interface dc_to_res_buf_i         dc_to_res_buf;
  interface res_buf_to_app_i        res_buf_to_app;

  interface dc_vsync_interface_i    vsync_interface;

  interface memory_address_allocator_i to_memory_alloc[1];

  streaming chan c_sdram[2], c_lcd;
  par {
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] memory_address_allocator( 1, to_memory_alloc, 0, 1024*1024*8);

      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] command_buffer(app_to_cmd_buffer, cmd_buffer_to_dc);
      on tile[LCD_A16_CIRCLE_TILE]: display_controller(
              cmd_buffer_to_dc, dc_to_res_buf, vsync_interface,
              8, LCD_HEIGHT, LCD_WIDTH, 2,
              to_memory_alloc[0], c_sdram[0], c_sdram[1], c_lcd);
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] response_buffer(dc_to_res_buf, res_buf_to_app);

      on tile[LCD_A16_CIRCLE_TILE]: app(app_to_cmd_buffer, res_buf_to_app, vsync_interface);

	  on tile[LCD_A16_CIRCLE_TILE]:lcd_server(c_lcd, lcdports);
	  on tile[LCD_A16_CIRCLE_TILE]:sdram_server(c_sdram, 2, sdramports);
  }
  return 0;
}
