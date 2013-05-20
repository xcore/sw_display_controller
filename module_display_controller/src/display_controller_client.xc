#include <platform.h>
#include "display_controller.h"
#include "display_controller_internal.h"
#include "sdram.h"

unsigned display_controller_register_image(chanend server, unsigned img_width_words,
    unsigned img_height_lines) {
  unsigned image_handle;
  server <: (char)CMD_REGISTER_IMAGE;
  master {
    server <: img_width_words;
    server <: img_height_lines;
  }
  server :> image_handle;
  return image_handle;
}

void display_controller_image_write_line_p(chanend server, unsigned line, unsigned image_no,
    intptr_t buffer) {
  server <: (char)CMD_WRITE_LINE;
  master {
    server <: image_no;
    server <: line;
    server <: buffer;
  }
}

void display_controller_image_write_line(chanend server, unsigned line, unsigned image_no,
    unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  display_controller_image_write_line_p(server, line, image_no, buffer_pointer);
}

void display_controller_image_read_line_p(chanend server, unsigned line, unsigned image_no,
    intptr_t buffer) {
  server <: (char)CMD_READ_LINE;
  master {
    server <: image_no;
    server <: line;
    server <: buffer;
  }
}

void display_controller_image_read_line(chanend server, unsigned line, unsigned image_no,
    unsigned buffer[]) {
  intptr_t buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  display_controller_image_read_line_p(server, line, image_no, buffer_pointer);
}

void display_controller_image_read_partial_line_p(chanend server, unsigned line,
    unsigned image_no, intptr_t buffer, unsigned line_offset,
    unsigned word_count, unsigned buffer_offset) {
  if (word_count == 0)
    return;
  server <: (char)CMD_READ_PARTIAL_LINE;
  buffer += (4 * buffer_offset);
  master {
    server <: image_no;
    server <: line;
    server <: buffer;
    server <: line_offset;
    server <: word_count;
  }
}

void display_controller_image_read_partial_line(chanend server, unsigned line, unsigned image_no,
    unsigned buffer[], unsigned line_offset, unsigned word_count,
    unsigned buffer_offset) {
  unsigned buffer_pointer;
  asm("mov %0, %1" : "=r"(buffer_pointer) : "r"(buffer));
  display_controller_image_read_partial_line_p(server, line, image_no, buffer_pointer,
      line_offset, word_count, buffer_offset);
}

void display_controller_wait_until_idle(chanend server, unsigned buffer[]) {
  server <: (char)CMD_SDRAM_WAIT_UNTIL_IDLE;
}

void display_controller_wait_until_idle_p(chanend server, intptr_t buffer) {
  server <: (char)CMD_SDRAM_WAIT_UNTIL_IDLE;
}

void display_controller_frame_buffer_commit(chanend server, unsigned image_no) {
  server <: (char)CMD_SET_FRAME_BUFFER;
  master {
    server <: image_no;
  }
  server :> int;
}

void display_controller_frame_buffer_init(chanend server, unsigned image_no) {
  server <: (char)CMD_INIT_FRAME_BUFFER;
  master {
    server <: image_no;
  }
}

