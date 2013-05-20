#include "transitions.h"
#include "lcd.h"
#include "display_controller.h"

static void transition_wipe_impl(chanend server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  display_controller_image_read_partial_line(server, line, image_from, dst, spilt,
      LCD_ROW_WORDS - spilt, 0);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_read_partial_line(server, line, image_to, dst, LCD_ROW_WORDS - spilt,
      spilt, LCD_ROW_WORDS - spilt);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_write_line(server, line, next_image_fb, dst);
  display_controller_wait_until_idle(server, dst);
}

static void transition_slide_impl(chanend server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  display_controller_image_read_partial_line(server, line, image_to, dst, 0, spilt,
      LCD_ROW_WORDS - spilt);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_read_partial_line(server, line, image_from, dst, 0,
      LCD_ROW_WORDS - spilt, 0);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_write_line(server, line, next_image_fb, dst);
  display_controller_wait_until_idle(server, dst);
}

static void transition_dither_impl(chanend server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned s, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  unsigned src[LCD_ROW_WORDS];
  unsigned threshold = s;
  unsigned data = line;
  display_controller_image_read_line(server, line, image_to, dst);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_read_line(server, line, image_from, src);
  display_controller_wait_until_idle(server, src);

  for (unsigned i = 0; i < LCD_ROW_WORDS; i++) {
    crc32(data, i*line, 0x82F63B78);
    data = data % (MAX_DITHER);
    if (data > threshold) {
      dst[i] = src[i];
    }
  }
  display_controller_image_write_line(server, line, next_image_fb, dst);
  display_controller_wait_until_idle(server, dst);
}

static void transition_alpha_blend_impl(chanend server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned s, unsigned line) {
  unsigned src[LCD_ROW_WORDS];
  unsigned dst[LCD_ROW_WORDS];
  unsigned mask = 0xF81F07E0;
  display_controller_image_read_line(server, line, image_to, dst);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_read_line(server, line, image_from, src);
  display_controller_wait_until_idle(server, src);
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
  display_controller_image_write_line(server, line, next_image_fb, dst);
  display_controller_wait_until_idle(server, dst);
}

static void transition_roll_impl(chanend server, unsigned next_image_fb,
    unsigned image_from, unsigned image_to, unsigned spilt, unsigned line) {
  unsigned dst[LCD_ROW_WORDS];
  display_controller_image_read_partial_line(server, line, image_to, dst, 0, spilt,
      LCD_ROW_WORDS - spilt);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_read_partial_line(server, line, image_from, dst, spilt,
      LCD_ROW_WORDS - spilt, 0);
  display_controller_wait_until_idle(server, dst);
  display_controller_image_write_line(server, line, next_image_fb, dst);
  display_controller_wait_until_idle(server, dst);
}

//above here are implimentations

unsigned transition_wipe(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_wipe_impl(server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }

    display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    display_controller_image_read_line(server, line, image_to, dst);
    display_controller_wait_until_idle(server, dst);
    display_controller_image_write_line(server, line, frame_buffer[next_fb_index], dst);
    display_controller_wait_until_idle(server, dst);
  }
  display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_slide(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_slide_impl(server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }
    display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    display_controller_image_read_line(server, line, image_to, dst);
    display_controller_wait_until_idle(server, dst);
    display_controller_image_write_line(server, line, frame_buffer[next_fb_index], dst);
    display_controller_wait_until_idle(server, dst);
  }
  display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_dither(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = frame * MAX_DITHER / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_dither_impl(server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }

    display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    display_controller_image_read_line(server, line, image_to, dst);
    display_controller_wait_until_idle(server, dst);
    display_controller_image_write_line(server, line, frame_buffer[next_fb_index], dst);
    display_controller_wait_until_idle(server, dst);
  }
  display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_alpha_blend(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = frame * MAX_ALPHA_BLEND / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_alpha_blend_impl(server, frame_buffer[next_fb_index],
          image_from, image_to, fade, line);
    }

    display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    display_controller_image_read_line(server, line, image_to, dst);
    display_controller_wait_until_idle(server, dst);
    display_controller_image_write_line(server, line, frame_buffer[next_fb_index], dst);
    display_controller_wait_until_idle(server, dst);
  }
  display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
  return next_fb_index;
}

unsigned transition_roll(chanend server, unsigned frame_buffer[2],
    unsigned image_from, unsigned image_to, unsigned frames,
    unsigned cur_fb_index) {
  unsigned next_fb_index;
  for (unsigned frame = 0; frame < frames; frame++) {
    unsigned fade = (frame * LCD_ROW_WORDS) / frames;
    next_fb_index = (cur_fb_index + 1) & 1;
    for (unsigned line = 0; line < LCD_HEIGHT; line++) {
      transition_roll_impl(server, frame_buffer[next_fb_index], image_from,
          image_to, fade, line);
    }
    display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
    cur_fb_index = next_fb_index;
  }
  next_fb_index = (cur_fb_index + 1) & 1;
  for (unsigned line = 0; line < LCD_HEIGHT; line++) {
    unsigned dst[LCD_ROW_WORDS];
    display_controller_image_read_line(server, line, image_to, dst);
    display_controller_wait_until_idle(server, dst);
    display_controller_image_write_line(server, line, frame_buffer[next_fb_index], dst);
    display_controller_wait_until_idle(server, dst);
  }
  display_controller_frame_buffer_commit(server, frame_buffer[next_fb_index]);
  return next_fb_index;
}
