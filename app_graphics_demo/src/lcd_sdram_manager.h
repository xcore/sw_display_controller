/*LCD/SDRAM manager
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


/** \brief This is a thread which invokes the thread for LCD, SDRAM and LCD SDRAM Manager in a 'par' statement. The function is in `lcd_sdram_manager.h`
* 
* \param c_client The channel end number
*/
void lcd_sdram_manager(chanend c_client);
void line_buffer_commit(chanend server, unsigned frame_buffer[]);
/** \brief The function reads a line of data from the SDRAM
* 
* \param server The channel end number
* \param line The line number to be read
* \param image_no The image number whose line is to be read
* \param buffer[] The buffer which is to be filled with the read data
*/
void image_read_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);
/** \brief The function reads a line of data of required length from the SDRAM
* 
* \param server The channel end number
* \param line The line number to be read
* \param image_no The image number whose line is to be read
* \param buffer[] The buffer which is to be filled with the read data
* \param line_offset The offset from which the data is to be read in the mentioned line
* \param word_count The number of bytes to be read
* \param buffer_offset The offset in the buffer from which the read data is to be filled
*/
void image_read_partial_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[],
		unsigned line_offset, unsigned word_count, unsigned buffer_offset);
/** \brief The function writes a line of data to the SDRAM
* 
* \param server The channel end number
* \param line The line number to be written
* \param image_no The image number whose line is to be written
* \param buffer[] The buffer which contains the data to be written
*/
void image_write_line_nonblocking(chanend server, unsigned line, unsigned image_no, unsigned buffer[]);
/** \brief The function finds a memory address to which the image can be written
* 
* \param server The channel end number
* \param img_width_words The width of the image in words
* \param img_height_lines The number of rows in the image
* \return The number for the image stored in the SDRAM
*/
unsigned register_image(chanend server, unsigned img_width_words, unsigned img_height_lines);
void wait_until_idle(chanend server);
/** \brief The function is used to update the LCD frame buffer data to the LCD display
* 
* \param server The channel end number
* \param image_no The image number which is to be refreshed
*/
void frame_buffer_commit(chanend server, unsigned image_no);

#endif
