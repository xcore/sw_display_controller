#include <assert.h>
#include <print.h>
#include "lcd.h"
#include "sdram.h"
#include "display_controller_internal.h"

#define NONE (-1)
#define LCD_BUFFER_DEPTH (4)

struct image_properties {
  //sdram location
  unsigned bank;

  //image properties
  unsigned line_width_words;
  unsigned start_used_words;
};

struct state {
  unsigned sdram_in_use;

  unsigned lcd_buffer_pointers[LCD_BUFFER_DEPTH][LCD_ROW_WORDS];
  unsigned head, tail;

  unsigned current_fb_image_index;
  unsigned current_fb_image_line;
  unsigned next_fb_image_index, next_next_fb_image_index;

  unsigned registered_images;
  struct image_properties IP[DISPLAY_CONTROLLER_MAX_IMAGES];
  unsigned current_bank;
  unsigned current_bank_used_words;
};

//This allocates space for an image
static unsigned register_image(unsigned img_width_words,
    unsigned img_height_lines, struct state &s) {
  unsigned words_required = img_height_lines * img_width_words;

  unsigned next_start_row = (s.current_bank_used_words + words_required)
      / SDRAM_ROW_WORDS;

  if(s.registered_images == DISPLAY_CONTROLLER_MAX_IMAGES) {
#if (DISPLAY_CONTROLLER_VERBOSE)
    printstrln("Error: Maximum number of images exceeded in display controller");
#endif
    assert(0); //Out of image_properties space
  }

  if (next_start_row > SDRAM_ROW_COUNT) {
    //if the image wont fix in the current bank then start the next
    s.current_bank++;
    s.current_bank_used_words = 0;
    if (s.current_bank == SDRAM_BANK_COUNT) {
#if (DISPLAY_CONTROLLER_VERBOSE)
      printstrln("Error: Cannot allocate enough memory");
#endif
      assert(0); //Out of SDRAM
    }
  }

  s.IP[s.registered_images].bank = s.current_bank;
  s.IP[s.registered_images].line_width_words = img_width_words;
  s.IP[s.registered_images].start_used_words = s.current_bank_used_words;

  s.current_bank_used_words += words_required;

  s.registered_images++;
  return s.registered_images - 1;
}

static inline void next_lcd_line(chanend client, chanend c_lcd,
    chanend c_sdram, struct state &s) {
  unsigned bank, start_row, start_col, word_count;

  lcd_update(c_lcd, s.lcd_buffer_pointers[s.tail]);
  s.tail = (s.tail + 1) % LCD_BUFFER_DEPTH;

  bank = s.IP[s.current_fb_image_index].bank;
  start_row = (s.IP[s.current_fb_image_index].start_used_words +
      s.current_fb_image_line * s.IP[s.current_fb_image_index].line_width_words)
      / SDRAM_ROW_WORDS;
  start_col = ((s.IP[s.current_fb_image_index].start_used_words +
      s.current_fb_image_line * s.IP[s.current_fb_image_index].line_width_words) * 2)
      % SDRAM_COL_COUNT;
  word_count = s.IP[s.current_fb_image_index].line_width_words;

  s.current_fb_image_line++;
  if (s.current_fb_image_line == LCD_HEIGHT) {
    s.current_fb_image_line = 0;

    if (s.next_fb_image_index != NONE) {
      s.current_fb_image_index = s.next_fb_image_index;
      if (s.next_next_fb_image_index != NONE) {
        s.next_fb_image_index = s.next_next_fb_image_index;
        s.next_next_fb_image_index = NONE;
        client <: 0;
      } else {
        s.next_fb_image_index = NONE;
      }
  }
}
if(s.sdram_in_use) {
  //TODO pass the correct buffer
  sdram_wait_until_idle(c_sdram, s.lcd_buffer_pointers[s.head]);
}

sdram_buffer_read(c_sdram, bank, start_row, start_col, word_count, s.lcd_buffer_pointers[s.head]);
s.sdram_in_use = 1;

s.head = (s.head+1)%LCD_BUFFER_DEPTH;
}

static void client_command(char cmd, chanend client, chanend c_lcd,
    chanend c_sdram, struct state &s) {
  switch (cmd) {
    case  CMD_WRITE_LINE: {
      unsigned image_no, line, buffer_pointer;
      unsigned bank, start_row, start_col, word_count;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
      }
      bank = s.IP[image_no].bank;
      start_row = (s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words) / SDRAM_ROW_WORDS;
      start_col = ((s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words)*2) % SDRAM_COL_COUNT;
      word_count = s.IP[image_no].line_width_words;
      sdram_buffer_write_p(c_sdram, bank, start_row, start_col, word_count, buffer_pointer );
      s.sdram_in_use = 1;
      break;
    }
    case CMD_READ_LINE: {
      unsigned image_no, line, buffer_pointer;
      unsigned bank, start_row, start_col, word_count;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
      }
      bank = s.IP[image_no].bank;
      start_row = (s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words) / SDRAM_ROW_WORDS;
      start_col = ((s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words)*2) % SDRAM_COL_COUNT;
      word_count = s.IP[image_no].line_width_words;
      sdram_buffer_read_p(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
      s.sdram_in_use =1;
      break;
    }
    case CMD_READ_PARTIAL_LINE: {
      unsigned image_no, line, buffer_pointer, line_offset, word_count;
      unsigned bank, start_row, start_col;
      slave {
        client :> image_no;
        client :> line;
        client :> buffer_pointer;
        client :> line_offset;
        client :> word_count;
      }
      bank = s.IP[image_no].bank;
      start_row = (s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words + line_offset) / SDRAM_ROW_WORDS;
      start_col = ((s.IP[image_no].start_used_words + line * s.IP[image_no].line_width_words + line_offset)*2) % SDRAM_COL_COUNT;
      sdram_buffer_read_p(c_sdram, bank, start_row, start_col, word_count, buffer_pointer);
      s.sdram_in_use =1;
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
#if (DISPLAY_CONTROLLER_VERBOSE)
      if(image_index >= s.registered_images) {
        printstr("Error: Frame buffer commit image(");
	printint(image_index);
        printstr(") is out of range(");
	printint(s.registered_images);
        printstrln(")");
      }
#endif
      if(s.next_fb_image_index == NONE) {
        s.next_fb_image_index = image_index;
        client <: 0;
      } else {
        s.next_next_fb_image_index = image_index;
      }
      break;
    }
    case CMD_INIT_FRAME_BUFFER: {
      unsigned image_index;
      unsigned image_no, line, buffer_pointer;
      unsigned bank, start_row, start_col, word_count;
      slave {
        client :> image_index;
      }
      assert(s.current_fb_image_index == NONE);
#if (DISPLAY_CONTROLLER_VERBOSE)
      if(s.current_fb_image_index != NONE)
        printstrln("Error: Frame buffer commit before frame buffer init");
#endif
#if (DISPLAY_CONTROLLER_VERBOSE)
      if(image_index >= s.registered_images) {
        printstr("Error: Frame buffer commit image(");
	printint(image_index);
        printstr(") is out of range(");
	printint(s.registered_images);
        printstrln(")");
      }
#endif
      s.current_fb_image_index = image_index;
      s.next_fb_image_index = NONE;
      s.next_next_fb_image_index = NONE;
      s.head = 0;
      s.tail = 0;
      s.current_fb_image_line = 0;
      while((s.head + s.tail) % LCD_BUFFER_DEPTH < 2) {
        bank = s.IP[s.current_fb_image_index].bank;
        start_row = (s.IP[s.current_fb_image_index].start_used_words + s.current_fb_image_line *
            s.IP[s.current_fb_image_index].line_width_words) / SDRAM_ROW_WORDS;
        start_col = ((s.IP[s.current_fb_image_index].start_used_words + s.current_fb_image_line *
                s.IP[s.current_fb_image_index].line_width_words)*2) % SDRAM_COL_COUNT;
        word_count = s.IP[s.current_fb_image_index].line_width_words;

        s.current_fb_image_line++;

        sdram_buffer_read(c_sdram, bank, start_row, start_col, word_count, s.lcd_buffer_pointers[s.head]);
        sdram_wait_until_idle(c_sdram, s.lcd_buffer_pointers[s.head]);
        assert(!s.sdram_in_use);
        s.head = (s.head+1)%LCD_BUFFER_DEPTH;
      }
      lcd_init(c_lcd);
      break;
    }
    case CMD_REGISTER_IMAGE: {
      unsigned img_width_words, img_height_lines;
      slave {
        client :> img_width_words;
        client :> img_height_lines;
      }
      client <: register_image(img_width_words, img_height_lines, s);
      break;
    }
    default: {
#if (XCC_VERSION_MAJOR >= 12)
      __builtin_unreachable();
#endif
    break;
    }
  }
  return;
}

void display_controller(chanend client, chanend c_lcd, chanend c_sdram) {
  struct state s;
  s.sdram_in_use = 0;
  s.registered_images = 0;
  s.current_bank = 0;
  s.current_bank_used_words = 0;
  s.current_fb_image_index = NONE;
  while (1) {
#pragma ordered
    select {
      case lcd_req(c_lcd): {
        next_lcd_line(client, c_lcd, c_sdram, s);
        break;
      }
      case chkct(c_sdram, XS1_CT_END):{
        s.sdram_in_use = 0;
        break;
      }
      case (!s.sdram_in_use) => client :> char cmd: {
        client_command(cmd, client, c_lcd, c_sdram, s);
        break;
      }
    }
  }
}
