#include "rgb888_to_rgb565.h"

short rgb888_to_rgb565(char r, char g, char b)
{
  return (int)((r >> 3) & 0x1F) | ((int)((g >> 2) & 0x3F) << 5) | ((int)((b >> 3) & 0x1F) << 11);
}
