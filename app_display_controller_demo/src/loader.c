#include "loader.h"
#include <syscall.h>
#include "xccompat.h"
#define SIZE (480*3*34)

short rgb888_to_rgb565(char r, char g, char b) {
  return (int)((r >> 3) & 0x1F) | ((int)((g >> 2) & 0x3F) << 5) | ((int)((b >> 3) & 0x1F) << 11);
}

void loader(chanend c){
  char buf[SIZE];
  unsigned i, j;
  int fp =_open("1.tga", O_RDONLY, 0644);
  _lseek(fp, 18, SEEK_SET);

  for(j=0;j<8;j++){
    _read(fp, buf, SIZE);
    for(i=0;i<SIZE;i+=3){
      short rgb = rgb888_to_rgb565(buf[i], buf[i+1], buf[i+2]);

    }
  }
}
