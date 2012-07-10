#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include <flashlib.h>
#include "lcd_sdram_manager.h"
#include "demo.h"
#include "rgb888_to_rgb565.h"
#include "transitions.h"
#include "lcd_defines.h"

fl_PortHolderStruct ports = { XS1_PORT_1A, /* MISO */
XS1_PORT_1B, /* SS */
XS1_PORT_1C, /* CLK */
XS1_PORT_1D, /* MOSI */
XS1_CLKBLK_2 };

fl_DeviceSpec spec[1] = { {
#include "MX25L6445E.spec"
    } };

int flash_connect() {
  int res;
  res = fl_connectToDevice(ports, spec, 1);
  if (res != 0) {
    return (0);
  }
  return 1;
}

#define IMAGE_PIXEL_BYTES (3)
#define PAGE_SIZE (256)
#define HEADER_BYTES 18

#define IMAGE_WIDTH_WORDS (LCD_ROW_WORDS)
#define IMAGE_HEIGHT_LINES (LCD_HEIGHT)

#define LCD_WIDTH_WORDS (LCD_ROW_WORDS)
#define LCD_HEIGHT_LINES (LCD_HEIGHT)

static void demo_read_line_from_flash(unsigned img_width, unsigned img_height,
    unsigned line_number, unsigned sectnum, unsigned buffer[IMAGE_WIDTH_WORDS]) {
  unsigned StartAddr;
  unsigned char line[PAGE_SIZE];
  unsigned char big_buffer[8 * PAGE_SIZE];
  unsigned pixels_read = 0;
  unsigned index = 0;
  unsigned temp = 0;
  flash_connect();

  StartAddr = fl_getSectorAddress(sectnum);
  StartAddr += HEADER_BYTES + line_number * img_width * IMAGE_PIXEL_BYTES;

  while (temp < 8 * 256) {
    fl_readPage(StartAddr, line);
    for (unsigned i = 0; i < 256; i++) {
      big_buffer[i + temp] = line[i];
    }
    StartAddr += 256;
    temp += 256;
  }

  while (pixels_read < img_width) {
    ( buffer, short[])[pixels_read++]= rgb888_to_rgb565(big_buffer[index + 2],
        big_buffer[index + 1], big_buffer[index]);
    index += 3;
  }
  fl_disconnect();
}

static void have_a_nap(unsigned nap) {
  timer t;
  unsigned now;
  t :> now;
  t when timerafter (now + nap*10000000):> void;
}

static void load_from_flash(chanend c, unsigned image_no, unsigned sector) {
  for (unsigned line = 0; line < IMAGE_HEIGHT_LINES; line++) {
    unsigned flash_buffer[IMAGE_WIDTH_WORDS];
    demo_read_line_from_flash(480, IMAGE_HEIGHT_LINES, line, sector,
        flash_buffer);
    image_write_line_nonblocking(c, IMAGE_HEIGHT_LINES - line - 1, image_no,
        flash_buffer);
    wait_until_idle(c);
  }
  wait_until_idle(c);
}

void demo_full_screen_image_load(chanend server) {
  unsigned image0, image1, image2, image3, lenna, menu, frame_buffer[2];
  unsigned fb_index = 0;

  image0 = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, image0, 9);
  wait_until_idle(server);

  image1 = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, image1, 0x6b);
  wait_until_idle(server);

  image2 = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, image2, 0xcd);
  wait_until_idle(server);

  image3 = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, image3, 0x12f);
  wait_until_idle(server);

  lenna = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, lenna, 0x1f3);
  wait_until_idle(server);

  menu = register_image(server, IMAGE_WIDTH_WORDS, IMAGE_HEIGHT_LINES);
  load_from_flash(server, menu, 0x191);
  wait_until_idle(server);

  frame_buffer[0] = register_image(server, IMAGE_WIDTH_WORDS,IMAGE_HEIGHT_LINES);
  frame_buffer[1] = register_image(server, IMAGE_WIDTH_WORDS,IMAGE_HEIGHT_LINES);

  while (1) {
#if 1
    fb_index = transition_slide(server, frame_buffer, image0, image1,LCD_WIDTH_WORDS, fb_index);
    have_a_nap(20);
    fb_index = transition_dither(server, frame_buffer, image1, image2, 256, fb_index);
    have_a_nap(20);
    fb_index = transition_wipe(server, frame_buffer, image2, image3, LCD_WIDTH_WORDS, fb_index);
    have_a_nap(20);
    fb_index = transition_roll(server, frame_buffer, image3, lenna, LCD_WIDTH_WORDS, fb_index);
    have_a_nap(20);
    fb_index = transition_alpha_blend(server, frame_buffer, lenna, image0, 64, fb_index);
    have_a_nap(20);
#else
    frame_buffer_commit(server, image0);
#endif
  }
}

