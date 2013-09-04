
#ifndef LEVEL_METER_H_
#define LEVEL_METER_H_

enum colors{
BLUE = 0xF800,
GREEN = 0x07E0,
YELLOW = 0x07FF,
RED = 0x001F
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
 */

void level_meter(chanend c_dc, unsigned frBufNo, unsigned data[], unsigned N);

#endif /* LEVEL_METER_H_ */
