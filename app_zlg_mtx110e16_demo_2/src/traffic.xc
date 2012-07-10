#include <platform.h>

#pragma unsafe arrays
void traffic()
{
  unsigned x[8];
  unsigned i = 1;
  while (1)
  {
    unsigned y = x[(i - 1) & 7];
    crc32(y, 0x48582BAC, 0xFAC91003);
    x[i & 7] = y;
    i++;
  }
}
