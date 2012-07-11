#include <assert.h>
#include <stdio.h>
#include "lcd.h"
#include "sdram.h"
#include "lcd_sdram_manager_internal.h"

//#define VERBOSE
#define MAX_IMAGES 20

struct image_properties {
  //sdram location
  unsigned bank;

  //image properties
  unsigned line_width_words;
  unsigned start_used_words;
};

unsigned registered_images = 0;
struct image_properties IP[MAX_IMAGES];
unsigned current_bank = 0;
unsigned current_bank_used_words = 0; //this is the number of words used in the current bank

#define LCD_BUFFER_DEPTH (4)
unsigned lcd_buffer_pointers[LCD_BUFFER_DEPTH][LCD_ROW_WORDS];
unsigned head = 0, tail = 0;

int first_go = 1;
unsigned current_fb_image_index;
unsigned current_fb_image_line = 0;
unsigned next_fb_image_index = 0;
unsigned current_line = 0;

//This allocates space for an image
static unsigned register_image(unsigned img_width_words,
    unsigned img_height_lines) {
  unsigned words_required = img_height_lines * img_width_words;

  unsigned next_start_row = (current_bank_used_words + words_required)
      / SDRAM_WORDS_PER_ROW;
  if (next_start_row > SDRAM_ROW_COUNT) {
    //if the image wont fix in the current bank then start the next
    current_bank++;
    current_bank_used_words = 0;
    if (current_bank == SDRAM_BANK_COUNT) {
#ifdef VERBOSE
      printf("Error: Cannot allocate enough memory\n");
#endif
      assert(0); //Out of SDRAM
    }
  }

  IP[registered_images].bank = current_bank;
  IP[registered_images].line_width_words = img_width_words;
  IP[registered_images].start_used_words = current_bank_used_words;

  current_bank_used_words += words_required;

  registered_images++;
  return registered_images - 1;
}

static inline void next_lcd_line(chanend c_lcd, chanend c_sdram, unsigned sdram_in_use) {
  unsigned bank, start_row, start_col, word_count;
  unsigned buffer_pointer;
  asm  ("mov %0, %1" : "=r"(buffer_pointer) : "r"(lcd_buffer_pointers[tail]));

  c_lcd <: buffer_pointer;
  tail = (tail+1)%LCD_BUFFER_DEPTH;

  bank = IP[current_fb_image_index].bank;
  start_row = (IP[current_fb_image_index].start_used_words + current_fb_image_line *
      IP[current_fb_image_index].line_width_words) / SDRAM_WORDS_PER_ROW;
  start_col = ((IP[current_fb_image_index].start_used_words + current_fb_image_line *
      IP[current_fb_image_index].line_width_words)*2) % SDRAM_ROW_LENGTH_COLS;
  word_count = IP[current_fb_image_index].line_width_words;

  current_fb_image_line++;
  if(current_fb_image_line == LCD_HEIGHT) {
    current_fb_image_line = 0;
    current_fb_image_index = next_fb_image_index;
  }
  if(sdram_in_use)
  c_sdram :> int;

  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(lcd_buffer_pointers[head]));
  sdram_line_read_nonblocking(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
  sdram_in_use = 1;

  head = (head+1)%LCD_BUFFER_DEPTH;
}

static unsigned client_command(char cmd, chanend client, chanend c_lcd,
    chanend c_sdram, unsigned sdram_in_use) {
  switch (cmd) {
    case  CMD_WRITE_LINE_NONBLOCKING: {
      unsigned image_no, line, buffer_pointer;
      unsigned bank, start_row, start_col, word_count;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
      }
      bank = IP[image_no].bank;
      start_row = (IP[image_no].start_used_words + line * IP[image_no].line_width_words) / SDRAM_WORDS_PER_ROW;
      start_col = ((IP[image_no].start_used_words + line * IP[image_no].line_width_words)*2) % SDRAM_ROW_LENGTH_COLS;
      word_count = IP[image_no].line_width_words;
      sdram_line_write(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
      sdram_in_use =1;
      break;
    }
    case CMD_READ_LINE_NONBLOCKING: {
      unsigned image_no, line, buffer_pointer;
      unsigned bank, start_row, start_col, word_count;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
      }
      bank = IP[image_no].bank;
      start_row = (IP[image_no].start_used_words + line * IP[image_no].line_width_words) / SDRAM_WORDS_PER_ROW;
      start_col = ((IP[image_no].start_used_words + line * IP[image_no].line_width_words)*2) % SDRAM_ROW_LENGTH_COLS;
      word_count = IP[image_no].line_width_words;
      sdram_line_read_nonblocking(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
      sdram_in_use =1;
      break;
    }
    case CMD_READ_PARTIAL_LINE_NONBLOCKING: {
      unsigned image_no, line, buffer_pointer, line_offset, word_count;
      unsigned bank, start_row, start_col;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
        client :> line_offset;
        client :> word_count;
      }
      bank = IP[image_no].bank;
      start_row = (IP[image_no].start_used_words + line * IP[image_no].line_width_words + line_offset) / SDRAM_WORDS_PER_ROW;
      start_col = ((IP[image_no].start_used_words + line * IP[image_no].line_width_words + line_offset)*2) % SDRAM_ROW_LENGTH_COLS;
      sdram_line_read_nonblocking(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
      sdram_in_use =1;
      break;
    }
    case CMD_SDRAM_WAIT_UNTIL_IDLE: {
      break;
    }
    case CMD_SET_FRAME_BUFFER: {
      unsigned image_index;
      slave {
        client :> image_index;
      }
      assert(image_index < registered_images);
      if(first_go) {
        unsigned image_no, line, buffer_pointer;
        unsigned bank, start_row, start_col, word_count;
        c_lcd <: 1;
        first_go = 0;
        current_fb_image_index = image_index;

        while((head + tail) % LCD_BUFFER_DEPTH < 2) {
          bank = IP[current_fb_image_index].bank;
          start_row = (IP[current_fb_image_index].start_used_words + current_fb_image_line *
              IP[current_fb_image_index].line_width_words) / SDRAM_WORDS_PER_ROW;
          start_col = ((IP[current_fb_image_index].start_used_words + current_fb_image_line *
              IP[current_fb_image_index].line_width_words)*2) % SDRAM_ROW_LENGTH_COLS;
          word_count = IP[current_fb_image_index].line_width_words;

          current_fb_image_line++;

          asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(lcd_buffer_pointers[head]));
          sdram_line_read_nonblocking(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
          c_sdram :> int;
          assert(!sdram_in_use);
          head = (head+1)%LCD_BUFFER_DEPTH;
        }
      }
      next_fb_image_index = image_index;
      client <: 0;
      break;
    }
    case CMD_REGISTER_IMAGE: {
      unsigned img_width_words, img_height_lines;
      slave {
        client :> img_width_words;
        client :> img_height_lines;
      }
      client <: register_image(img_width_words, img_height_lines);
      break;
    }
    default: assert(0); break;
  }
  return sdram_in_use;
}

/** This thread handles the LCD-SDRAM manager.
* It handles each command for the SDRAM as it gets registered.
* The commands include write a line to SDRAM, read a line from SDRAM,
* reading a line partially from SDRAM and sending commands for LCD screen update
*
* \param client The channel end number for the LCD SDRAM manager
* \param c_lcd The channel end number for the LCD
* \param c_sdram The channel end number for the SDRAM
*/
static void manager(chanend client, chanend c_lcd, chanend c_sdram) {
  unsigned sdram_in_use = 0;
  while (1) {
#pragma ordered
    select {
      case c_lcd :> int: {
        next_lcd_line(c_lcd, c_sdram, sdram_in_use);
        sdram_in_use=1;
        break;
      }
      case c_sdram :> int: {
        sdram_in_use = 0;
        break;
      }
      case (!sdram_in_use) => client :> char cmd: {
        sdram_in_use = client_command(cmd, client, c_lcd, c_sdram, sdram_in_use);
        break;
      }
    }
  }
}

extern struct sdram_ports sdram_ports;

void lcd_sdram_manager(chanend client) {
  chan c_sdram, c_lcd;
  par {
    sdram_server(c_sdram, sdram_ports);
    manager(client, c_lcd, c_sdram);
    lcd(c_lcd);
  }
}
