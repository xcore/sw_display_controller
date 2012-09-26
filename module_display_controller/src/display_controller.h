#ifndef _display_controller_h_
#define _display_controller_h_

/**
 * \brief Function to manage the LCD server and SDRAM server whilst maintaining image buffers.
 *
 * \param c_client The channel from the display_controller to the client application.
 * \param c_lcd The channel from the display_controller to the LCD server.
 * \param c_sdram The channel from the display_controller to the SDRAM server.
 */
void display_controller(chanend c_client, chanend c_lcd, chanend c_sdram);

/** \brief The function reads a line of pixel data from the SDRAM.
 *
 * \param server The channel from the client application to the display_controller.
 * \param line The image line number to be read.
 * \param image_no The image number whose line is to be read.
 * \param buffer[] The buffer which is to be filled with the read data.
 * \sa image_write_line
 * \sa image_read_partial_line
 */
void image_read_line(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);

/** \brief The function writes a line of pixel data to the registered image in SDRAM.
 *
 * \param server The channel from the client application to the display_controller.
 * \param line The image line number to be written.
 * \param image_no The image number whose line is to be written.
 * \param buffer[] The buffer which is to be written to the image.
 * \sa image_read_line
 *  \sa image_read_partial_line
 */
void image_write_line(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);

/** \brief The function writes a partial line of pixel data to the registered image in SDRAM.
 *
 * \param server The channel from the client application to the display_controller.
 * \param line The image line number to be written.
 * \param image_no The image number whose line is to be written.
 * \param buffer[] The buffer which is to be written to the image.
 * \param line_offset The offset in pixels to begin the write of the image line from.
 * \param word_count The number of words to write to the image line.
 * \param buffer_offset The offset from the begining of the buffer to write from in words.
 * \sa image_read_line
 * \sa image_write_line
 */
void image_read_partial_line(chanend server, unsigned line, unsigned image_no, unsigned buffer[],
		unsigned line_offset, unsigned word_count, unsigned buffer_offset);

/** \brief Registers an image with the display controller. Returns an image handle to refer to the image
 * from then on.
 *
 * \param server The channel from the client application to the display_controller.
 * \param img_width_words The width of the image in words.
 * \param img_height_lines The height of the image in lines(pixels).
 */
unsigned register_image(chanend server, unsigned img_width_words, unsigned img_height_lines);

//TODO
void wait_until_idle(chanend server);

/** \brief Commits the image to the display controller to be displayed on the LCD screen when the
 * current image is completly displayed. The display controller contains a single next image number
 * buffer meaning that if the buffer is empty (the previously commited image is already on the LCD
 * screen) then the command will return immediatly. If the buffer is full then this function will
 * block until the current image is on the LCD screen and the buffer is ready for a new entry. This
 * behaviour ensures that frame commits will not overwrite.
 *
 * \param server The channel from the client application to the display_controller.
 * \param image_no The image handle of the image to be displayed as per the described behaviour.
 */
void frame_buffer_commit(chanend server, unsigned image_no);

/** \brief Commits the image to the display controller to be displayed on the LCD screen and
 * initialises the display controller. This must only be called once at the begining of the
 * display controllers use.
 *
 * \param server The channel from the client application to the display_controller.
 * \param image_no The image handle of the image to be displayed as per the described behaviour.
 */
void frame_buffer_init(chanend server, unsigned image_no);

#endif
