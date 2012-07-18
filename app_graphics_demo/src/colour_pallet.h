#ifndef COLOUR_PALLET_H_
#define COLOUR_PALLET_H_

#include <assert.h>

#define BLACK (0x0000)
#define WHITE (0xffff)

//This is the bit depth of the input graphics data.
#define BIT_DEPTH 1

//Set this to reflect the data storage scheme.
//#define LITTLE_ENDIAN

/*
 * For the desired bit depth define the colour pallet here. If screen is completly black then
 * You have missed this step.
 */
#if(BIT_DEPTH==1)
short colour_pallet[1<<BIT_DEPTH] = {WHITE, BLACK};
#elif(BIT_DEPTH==2)
short colour_pallet[1<<BIT_DEPTH] = {0};
#elif(BIT_DEPTH==4)
short colour_pallet[1<<BIT_DEPTH] = {0};
#elif(BIT_DEPTH==8)
short colour_pallet[1<<BIT_DEPTH] = {0};
#else
#error "BIT_DEPTH must be a power of two"
#endif

/*
 *
 */
inline void unpack_byte(unsigned line_buffer[], unsigned pixel_offset, char data, unsigned bits_per_pixel){
  unsigned mask = (1<<bits_per_pixel) - 1;
  assert(bits_per_pixel);
  for(unsigned i=0;i<8;i+=bits_per_pixel){
#ifdef LITTLE_ENDIAN
    unsigned index = (data>>i) & mask;
#else
    unsigned index = (data>>(8-bits_per_pixel -i)) & mask;
#endif
    (line_buffer, short[])[i+pixel_offset] = colour_pallet[index];
	}
}

unsigned unpack_short(unsigned line_buffer[], unsigned pixel_offset, short data, unsigned bits_per_pixel){
  unpack_byte(line_buffer, pixel_offset + 0, (data>>8)&0xff, bits_per_pixel);
  unpack_byte(line_buffer, pixel_offset + 8, (data>>0)&0xff, bits_per_pixel);
}

unsigned unpack_word(unsigned line_buffer[], unsigned pixel_offset, short data, unsigned bits_per_pixel){
  unpack_byte(line_buffer, pixel_offset + 0, (data>>24)&0xff, bits_per_pixel);
  unpack_byte(line_buffer, pixel_offset + 8, (data>>16)&0xff, bits_per_pixel);
  unpack_byte(line_buffer, pixel_offset + 16, (data>>8)&0xff, bits_per_pixel);
  unpack_byte(line_buffer, pixel_offset + 24, (data>>0)&0xff, bits_per_pixel);
}
#endif /* COLOUR_PALLET_H_ */
