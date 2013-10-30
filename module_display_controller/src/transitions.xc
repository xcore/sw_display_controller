#include "transitions.h"
#include "lcd.h"
#include "display_controller.h"

static void transition_wipe_impl(chanend c_server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  image_read_partial_line(c_server, line, image_from, dst, spilt,
      LCD_ROW_WORDS - spilt, 0);
  wait_until_idle(c_server, dst);
  image_read_partial_line(c_server, line, image_to, dst, LCD_ROW_WORDS - spilt,
      spilt, LCD_ROW_WORDS - spilt);
  wait_until_idle(c_server, dst);
  image_write_line(c_server, line, next_image_fb, dst);
  wait_until_idle(c_server, dst);
}

static void transition_slide_impl(chanend c_server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  image_read_partial_line(c_server, line, image_to, dst, 0, spilt,
      LCD_ROW_WORDS - spilt);
  wait_until_idle(c_server, dst);
  image_read_partial_line(c_server, line, image_from, dst, 0,
      LCD_ROW_WORDS - spilt, 0);
  wait_until_idle(c_server, dst);
  image_write_line(c_server, line, next_image_fb, dst);
  wait_until_idle(c_server, dst);
}

static void transition_dither_impl(chanend c_server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned s, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  unsigned src[LCD_ROW_WORDS];
  unsigned threshold = s;
  unsigned data = line;
  image_read_line(c_server, line, image_to, dst);
  wait_until_idle(c_server, dst);
  image_read_line(c_server, line, image_from, src);
  wait_until_idle(c_server, src);

  for (unsigned i = 0; i < LCD_ROW_WORDS; i++) {
    crc32(data, i*line, 0x82F63B78);
    data = data % (MAX_DITHER);
    if (data > threshold) {
      dst[i] = src[i];
    }
  }
  image_write_line(c_server, line, next_image_fb, dst);
  wait_until_idle(c_server, dst);
}

static void transition_alpha_blend_impl(chanend c_server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned s, unsigned line) {
  unsigned src[LCD_ROW_WORDS];
  unsigned dst[LCD_ROW_WORDS];
  unsigned mask = 0xF81F07E0;
  image_read_line(c_server, line, image_to, dst);
  wait_until_idle(c_server, dst);
  image_read_line(c_server, line, image_from, src);
  wait_until_idle(c_server, src);
  for (unsigned i = 0; i < LCD_ROW_WORDS; i++) {
    unsigned A = dst[i];
    unsigned B = src[i];
    unsigned p;
    unsigned a = (A & mask) >> 5;
    unsigned c = B & mask;
    unsigned b = (c) >> 5;

    unsigned t = ((a - b) * s + c) & mask;

    mask = ~mask;

    a = A & mask;
    b = B & mask;

    p = ((((a - b) * s) >> 5) + b) & mask;

    dst[i] = t + p;
    mask = ~mask;
  }
  image_write_line(c_server, line, next_image_fb, dst);
  wait_until_idle(c_server, dst);
}

static void transition_roll_impl(chanend c_server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  image_read_partial_line(c_server, line, image_to, dst, 0, spilt,
      LCD_ROW_WORDS - spilt);
  wait_until_idle(c_server, dst);
  image_read_partial_line(c_server, line, image_from, dst, spilt,
      LCD_ROW_WORDS - spilt, 0);
  wait_until_idle(c_server, dst);
  image_write_line(c_server, line, next_image_fb, dst);
  wait_until_idle(c_server, dst);
}

//above here are implimentations

unsigned transition_wipe(chanend c_server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_wipe_impl(c_server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }

    frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    image_read_line(c_server, line, image_to, dst);
    wait_until_idle(c_server, dst);
    image_write_line(c_server, line, frame_buffer[next_fb_index], dst);
    wait_until_idle(c_server, dst);
  }
  frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_slide(chanend c_server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_slide_impl(c_server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }
    frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    image_read_line(c_server, line, image_to, dst);
    wait_until_idle(c_server, dst);
    image_write_line(c_server, line, frame_buffer[next_fb_index], dst);
    wait_until_idle(c_server, dst);
  }
  frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_dither(chanend c_server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = frame * MAX_DITHER / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_dither_impl(c_server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }

    frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    image_read_line(c_server, line, image_to, dst);
    wait_until_idle(c_server, dst);
    image_write_line(c_server, line, frame_buffer[next_fb_index], dst);
    wait_until_idle(c_server, dst);
  }
  frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_alpha_blend(chanend c_server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = frame * MAX_ALPHA_BLEND / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_alpha_blend_impl(c_server, frame_buffer[next_fb_index],
          image_from, image_to, fade, line);
    }

    frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    image_read_line(c_server, line, image_to, dst);
    wait_until_idle(c_server, dst);
    image_write_line(c_server, line, frame_buffer[next_fb_index], dst);
    wait_until_idle(c_server, dst);
  }
  frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_roll(chanend c_server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_roll_impl(c_server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }
    frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    image_read_line(c_server, line, image_to, dst);
    wait_until_idle(c_server, dst);
    image_write_line(c_server, line, frame_buffer[next_fb_index], dst);
    wait_until_idle(c_server, dst);
  }
  frame_buffer_commit(c_server, frame_buffer[next_fb_index]);
  return next_fb_index;
}
