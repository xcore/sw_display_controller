
#ifndef LOADER_H_
#define LOADER_H_

#ifndef __XC__
#include "xccompat.h"
#endif
void loader(chanend c, char images[][15], unsigned image_count);
#endif /* LOADER_H_ */
