#include <platform.h>
#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"
#include "sdram_slicekit_support.h"
#include "lcd_slicekit_support.h"

#include <stdio.h>
#include <stdlib.h>

void app(client interface app_to_cmd_buffer_i to_dc, client interface res_buf_to_app_i from_dc,
        client interface dc_vsync_interface_i vsync){

    unsigned current_image=0;
    unsigned buf[LCD_ROW_WORDS];
    unsigned * movable buffer_pointer = buf;
    for(unsigned i=0; i<LCD_ROW_WORDS; i++)
        buffer_pointer[i]=0xffffffff;
    timer t;
    unsigned frames = 0;
#define FRAME_COUNT 1000
    unsigned time;
    t:> time;
    while(1){

        //write the whole of the frame buffer that is not being displayed
        for(unsigned l = 0; l< LCD_HEIGHT;l++){
            display_controller_write(to_dc, move(buffer_pointer), 1, l, LCD_ROW_WORDS, 0);
            unsigned r;
            {buffer_pointer, r} = from_dc.pop();
        }
        frames++;
        if(frames == FRAME_COUNT){
            unsigned now;
            t:> now;

            unsigned clocks_per_frame = (LCD_H_FRONT_PORCH + LCD_H_BACK_PORCH + LCD_WIDTH)*(LCD_V_FRONT_PORCH + LCD_V_BACK_PORCH + LCD_HEIGHT );

            printf("Refresh rate: %.2fHz\n", (100000000.0/(LCD_CLOCK_DIVIDER*2.0))/(float)clocks_per_frame);
            printf("Avaliable read/write bandwidth: %.2f frames per second\n",100000000.0/((float)(now - time)/(float)FRAME_COUNT));
            _Exit(1);
            frames = 0;
            t:> time;
        }
        current_image = 1 - current_image;
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
              2, LCD_HEIGHT, LCD_WIDTH, 2,
              to_memory_alloc[0], c_sdram[0], c_sdram[1], c_lcd);
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] response_buffer(dc_to_res_buf, res_buf_to_app);
      on tile[LCD_A16_CIRCLE_TILE]: app(app_to_cmd_buffer, res_buf_to_app, vsync_interface);
      on tile[LCD_A16_CIRCLE_TILE]: lcd_server(c_lcd, lcdports);
      on tile[LCD_A16_CIRCLE_TILE]: sdram_server(c_sdram, 2, sdramports);
      on tile[LCD_A16_CIRCLE_TILE]: par(int i=0;i<4;i++) while(1);
  }
  return 0;
}
