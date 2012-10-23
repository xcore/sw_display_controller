#include "loader.h"
#include <syscall.h>
#include "xccompat.h"
#include <stdio.h>
#include "chan.h"
#define SIZE (480*3*34)

inline short rgb888_to_rgb565(char b, char g, char r) {
  return (int)((r >> 3) & 0x1F) | ((int)((g >> 2) & 0x3F) << 5) | ((int)((b >> 3) & 0x1F) << 11);
}

void loader(chanend c, char images[][30], unsigned image_count){
  char buf[SIZE];
  unsigned i, j, k=0;
  while(k<image_count){

    int fp =_open(images[k], O_RDONLY, 0644);
    if(fp < 0){
      iprintf("Error: Couldn't open %s\n", images[k]);
    }
    _lseek(fp, 18, SEEK_SET);
    for(j=0;j<8;j++){
      if(_read(fp, buf, SIZE)!= SIZE){
        iprintf("Error: Couldn't read all of %s\n", images[k]);
      }
      for(i=0;i<SIZE;i+=3){
        short rgb = rgb888_to_rgb565(buf[i], buf[i+1], buf[i+2]);
        send(c, rgb);
      }
    }
    k++;
    _close(fp);
  }
}
