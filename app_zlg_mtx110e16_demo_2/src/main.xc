#include <platform.h>
#include "sdram.h"
#include "traffic.h"
#include "demo.h"
#include "lcd_sdram_manager.h"

struct sdram_ports sdram_ports = {
  XS1_PORT_16A, /* DQ/A */
  XS1_PORT_1K, /* A0 */
  XS1_PORT_4E, /* CTRL */
  XS1_PORT_1H, /* CLK */
  XS1_PORT_1E, /* DQM0 */
  XS1_PORT_1L, /* DQM1 */
  XS1_PORT_1G, /* CKE */
  XS1_CLKBLK_1
};

//out port p_lcd_clk = XS1_PORT_1O;
//out port p_lcd_tim = XS1_PORT_4F;
//out port p_lcd_rgb = XS1_PORT_32A;
//clock clk_lcd = XS1_CLKBLK_3;

void demo_full_screen_image_load(chanend c);

int main()
{
  chan c;
  par {
    lcd_sdram_manager(c);
    demo_full_screen_image_load(c);
    traffic();
    traffic();
    traffic();
    traffic();
  }
  return 0;
}
