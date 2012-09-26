#include <platform.h>
#include "display_controller.h"
#include "display_controller_internal.h"
#include "sdram.h"
#include <assert.h>

/*
  This registers and image with the SDRAM memory manager. It allocates
  enough memory in the SDRAM to hold an image with width img_width_words
  words and height img_height_lines lines. It returns an image handle
  that can be used for refering to the allocated image. 

  The manager will allocate a block of memory in the SDRAM such that
  it is continuous and doesn't span multiple banks. If a request for
  memory is recieved and it would require more memory that the current
  memory remaining in the bank then the next bank is used.

  When the SDRAM runs out of memory it currently errors.
  
  chanend server - This is a channel to the lcd_sdram_manager
  unsigned img_width_words - The image width in words
  unsigned img_height_lines - The image height in lines
*/
unsigned register_image(chanend server, unsigned img_width_words,
		unsigned img_height_lines) {
  unsigned image_handle;
	server	<: (char)CMD_REGISTER_IMAGE;
	master {
		server <: img_width_words;
		server <: img_height_lines;
	}
	server :> image_handle;
	return image_handle;
}

/*
  This writes a line of data to the image refered to by the image handle
  image_no.

  chanend server -  This is a channel to the lcd_sdram_manager
  unsigned line - The line of the image refered to by the image handle
  unsigned image_no -  This is the image handle
  unsigned buffer[] - The data to write to the image in SDRAM
*/
void image_write_line(chanend server, unsigned line,
		unsigned image_no, unsigned buffer[]) {
	unsigned buffer_pointer;
	server	<: (char)CMD_WRITE_LINE;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
	master {
		server <: image_no;
		server <: line;
		server <: buffer_pointer;
	}
}

/*
  This reads a line of data from the image refered to by the image handle
  image_no.

  chanend server -  This is a channel to the lcd_sdram_manager
  unsigned line - The line of the image refered to by the image handle
  unsigned image_no -  This is the image handle
  unsigned buffer[] - The buffer to be written to from the image in SDRAM
*/
void image_read_line(chanend server, unsigned line,
		unsigned image_no, unsigned buffer[]) {
	unsigned buffer_pointer;
	server	<: (char)CMD_READ_LINE;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
	master {
		server <: image_no;
		server <: line;
		server <: buffer_pointer;
	}
}

/*
  This reads a partial line of data from the image refered to by the image handle
  image_no. It reads it to the buffer but is offset from the start of the buffer 
  by buffer_offset words. The line is read from line_offset for word_count words.

  chanend server -  This is a channel to the lcd_sdram_manager.
  unsigned line - The line of the image refered to by the image handle.
  unsigned image_no -  This is the image handle.
  unsigned buffer[] - The buffer to be written to from the image in SDRAM.
  unsigned line_offset - The offset to start reading the line from.
  unsigned word_count - The count of words to read from the line
  unsigned buffer_offset - The offset to start writing the buffer from.
*/
void image_read_partial_line(chanend server, unsigned line,
		unsigned image_no, unsigned buffer[], unsigned line_offset,
		unsigned word_count, unsigned buffer_offset) {
	unsigned buffer_pointer;
  if(word_count==0)
    return;
	server	<: (char)CMD_READ_PARTIAL_LINE;
	asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
	buffer_pointer += (4*buffer_offset);
	master {
		server <: image_no;
		server <: line;
		server <: buffer_pointer;
		server <: line_offset;
		server <: word_count;
	}
}

void wait_until_idle(chanend server) {
  server <: (char)CMD_SDRAM_WAIT_UNTIL_IDLE;
}

/*
  This commits a rendered image to the lcd_sdram_manager to be drawn to the LCD. 
  The lcd_sdram_manager will finish drawing the current image it is drawing then
  switch to the image that has just been committed.

  chanend server -  This is a channel to the lcd_sdram_manager.
  unsigned image_no - The image handle of the image to commit to the LCD.
*/
void frame_buffer_commit(chanend server, unsigned image_no) {
  server <: (char)CMD_SET_FRAME_BUFFER;
  master {
    server <: image_no;
  }
  server :> int;
}


void frame_buffer_init(chanend server, unsigned image_no) {
  server <: (char)CMD_INIT_FRAME_BUFFER;
  master {
    server <: image_no;
  }
}

