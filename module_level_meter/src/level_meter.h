
#ifndef LEVEL_METER_H_
#define LEVEL_METER_H_

enum colors_rgb565{		// Entered in BGR565
BLUE = 0xF800,
GREEN = 0x07E0,
YELLOW = 0x07FF,
RED = 0x001F,
TEAL = 0xFFE0,
WHITE = 0xFFFF,
CYAN = 0xFFE0,
MAGENTA = 0xF81F,
GOLD = 0x06BF,
SALMON = 0x741F,
CORAL = 0x53FF,
TURQUOISE = 0xD708,
VIOLET = 0xEC1D,
CHOCOLATE = 0x1B5A,
PEACH = 0xBEDF,
LAVENDER = 0xFF3C
};

/** This function renders the level meter display of a given data sequence.
 * It connects to  display controller for storing the rendered image frame. 
 *
 * \param c_dc    channel connecting display controller. 
 *
 * \param[in] frBufNo    index of frame buffer to be updated. 
 *
 * \param[in]    data   array containing magnitude spectrum values. 
 *
 * \param[in]  N   number of data values to be displayed as bars.
 *
 * \param[in] maxData Maximum possible data value
 */

void level_meter(chanend c_dc, unsigned frBufNo, unsigned data[], unsigned N, unsigned maxData);

#endif /* LEVEL_METER_H_ */
