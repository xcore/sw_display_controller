/** LCD/SDRAM manager
 *
 * buffering management and prioritisation
 * purpose is to remove overhead from SDRAM thread
 *
 * for LCD thread
 * --------------
 *
 * periodic
 * real-time
 * read
 * priority
 * fixed size
 * data held by manager
 * buffering several items
 *
 * for SDRAM thread
 * ----------------
 *
 * ad hoc
 * non real-time
 * write/read
 * no priority
 * variable size
 * data not held by manager (only pointer)
 * only 1 item at a time
 *
 */
#ifndef _lcd_sdram_manager_h_
#define _lcd_sdram_manager_h_

void lcd_sdram_manager(chanend c_client);
void line_buffer_commit(chanend server, unsigned frame_buffer[]);
void image_read_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);
void image_read_partial_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[],
		unsigned line_offset, unsigned word_count, unsigned buffer_offset);
void image_write_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);
unsigned register_image(chanend server, unsigned img_width_words, unsigned img_height_lines);
void wait_until_idle(chanend server);
void frame_buffer_commit(chanend server, unsigned image_no);

#endif
