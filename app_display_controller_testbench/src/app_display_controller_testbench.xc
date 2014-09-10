#include <platform.h>
#include "sdram.h"
#include "lcd.h"
#include "display_controller.h"
#include "sdram_slicekit_support.h"
#include "lcd_slicekit_support.h"

#include <stdio.h>

void app(client interface app_to_cmd_buffer_i to_dc, client interface res_buf_to_app_i from_dc){

    //image id out of range

    //display_controller_write(to_dc, move(buffer_pointer), image_no, l, SIZE, 0);


    //fill the command buffer

    //


}

on tile[LCD_A16_CIRCLE_TILE]: lcd_ports lcdports = LCD_A16_CIRCLE_PORTS(XS1_CLKBLK_1);
on tile[SDRAM_A16_SQUARE_TILE]: sdram_ports sdramports = SDRAM_A16_SQUARE_PORTS(XS1_CLKBLK_2);

int main() {
  interface app_to_cmd_buffer_i     app_to_cmd_buffer;
  interface cmd_buffer_to_dc_i      cmd_buffer_to_dc;

  interface dc_to_res_buf_i         dc_to_res_buf;
  interface res_buf_to_app_i        res_buf_to_app;

  interface memory_address_allocator_i to_memory_alloc[1];

  streaming chan c_sdram[2], c_lcd;
  par {
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] memory_address_allocator( 1, to_memory_alloc, 0, 1024*1024*8);
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] command_buffer(app_to_cmd_buffer, cmd_buffer_to_dc);
      on tile[LCD_A16_CIRCLE_TILE]: display_controller(cmd_buffer_to_dc, dc_to_res_buf,
              2, 272, 480, 2,
              to_memory_alloc[0], c_sdram[0], c_sdram[1], c_lcd);
      on tile[LCD_A16_CIRCLE_TILE]: [[distribute]] response_buffer(dc_to_res_buf, res_buf_to_app);
      on tile[LCD_A16_CIRCLE_TILE]: app(app_to_cmd_buffer, res_buf_to_app);
      on tile[LCD_A16_CIRCLE_TILE]:lcd_server(c_lcd, lcdports);
      on tile[LCD_A16_CIRCLE_TILE]:sdram_server(c_sdram, 2, sdramports);
      on tile[LCD_A16_CIRCLE_TILE]:par(int i=0;i<4;i++) while(1);
  }
  return 0;
}
